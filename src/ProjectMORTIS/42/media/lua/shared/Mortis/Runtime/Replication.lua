local Identity = require "Mortis/Runtime/Identity"
local Components = require "Mortis/Runtime/Components"
local ComponentSchemas = require "Mortis/API/Components"
local Persistence = require "Mortis/Runtime/Persistence"
local FaultIsolation = require "Mortis/Core/FaultIsolation"

local Replication = {}
Replication.PROTOCOL_VERSION = 2
Replication.MODULE = "ProjectMORTIS"
Replication.CMD_REQUEST = "RequestThreatSnapshot"
Replication.CMD_SNAPSHOT = "ThreatSnapshot"
Replication.CMD_CLEAR = "ThreatClear"
Replication.CMD_RECONCILE = "RequestThreatReconcile"

local revisions = setmetatable({}, { __mode = "k" })
local lastApplied = {}
local lastAppliedByZombie = setmetatable({}, { __mode = "k" })
local sessionEpoch = nil
local epochSequence = 0

function Replication.validId(value)
    return type(value)=="string" and #value>0 and #value<=128
end

function Replication.validOnlineId(value)
    return type(value)=="number" and value>=0 and value<=2147483647 and value==math.floor(value)
end

local function validEnvelope(snapshot)
    if type(snapshot)~="table" then return false,"invalid snapshot" end
    if tonumber(snapshot.protocolVersion)~=Replication.PROTOCOL_VERSION then return false,"unsupported protocol version" end
    if not Replication.validId(snapshot.stableId) or not Replication.validId(snapshot.sessionEpoch) then return false,"snapshot identity/epoch missing" end
    local revision=tonumber(snapshot.revision)
    if not revision or revision~=revision or revision==math.huge or revision<0 or revision~=math.floor(revision) then return false,"invalid snapshot revision" end
    if snapshot.onlineId~=nil and not Replication.validOnlineId(snapshot.onlineId) then return false,"invalid online ID" end
    return true
end

local function copySerializable(value, seen)
    local t = type(value)
    if value == nil or t == "boolean" or t == "number" or t == "string" then return value end
    if t ~= "table" then return nil end
    seen = seen or {}
    if seen[value] then return nil end
    seen[value] = true
    local out = {}
    for k, v in pairs(value) do
        if type(k) == "string" or type(k) == "number" then
            local copied = copySerializable(v, seen)
            if copied ~= nil then out[k] = copied end
        end
    end
    seen[value] = nil
    return out
end

local function serializeComponent(schema, value)
    if schema.serialize then
        local ok, serialized = FaultIsolation.call("component:" .. schema.id, "replicate-serialize", schema.serialize, value)
        if not ok then return nil, "serialize failed" end
        value = serialized
    end
    local copied = copySerializable(value)
    if copied == nil then return nil, "component produced no serializable payload" end
    return copied
end

local function migrate(schema, payload, storedVersion)
    local version = math.max(1, math.floor(tonumber(storedVersion) or 1))
    if version > schema.version then return nil, "snapshot component version is newer than local schema" end
    local value = payload
    while version < schema.version do
        local migration = schema.migrations[version]
        if not migration then return nil, "missing migration from v" .. tostring(version) end
        local ok, migrated = FaultIsolation.call("component:" .. schema.id, "replicate-migrate-v" .. tostring(version), migration, value)
        if not ok then return nil, "migration failed" end
        value = migrated
        version = version + 1
    end
    return value
end

function Replication.newSessionEpoch()
    epochSequence = epochSequence + 1
    local now = (os and type(os.time) == "function") and os.time() or 0
    local token = tostring({}):gsub("table: ", "")
    sessionEpoch = string.format("MORTIS-SESSION-%s-%04d-%s", tostring(now), epochSequence, token)
    return sessionEpoch
end

function Replication.setSessionEpoch(value)
    if type(value) == "string" and value ~= "" then sessionEpoch = value end
    return sessionEpoch
end

function Replication.getSessionEpoch()
    return sessionEpoch
end

function Replication.getRevision(zombie)
    return math.max(revisions[zombie] or 0,Persistence.readReplicationRevision(zombie,sessionEpoch))
end

function Replication.bumpRevision(zombie, _reason)
    local nextRevision = Replication.getRevision(zombie) + 1
    local saved,err=Persistence.writeReplicationRevision(zombie,sessionEpoch,nextRevision)
    if not saved then return nil,err end
    revisions[zombie] = nextRevision
    return nextRevision
end

function Replication.release(zombie)
    revisions[zombie] = nil
    lastAppliedByZombie[zombie] = nil
end

function Replication.buildSnapshot(zombie, onlineId, options)
    options = options or {}
    local stableId = Identity.getStableId(zombie)
    local typeId = Identity.getTypeId(zombie)
    if not stableId or not typeId then return nil, "zombie is not typed" end

    local components = {}
    local bucket = Components.allFor(zombie) or {}
    for id, schema in pairs(ComponentSchemas.all()) do
        if ComponentSchemas.isReplicated(id) then
            local value = bucket[id]
            if value ~= nil then
                local serialized, err = serializeComponent(schema, value)
                if err then return nil, "component " .. tostring(id) .. ": " .. tostring(err) end
                components[id] = {
                    version = schema.version,
                    data = serialized,
                }
            end
        end
    end

    return {
        protocolVersion = Replication.PROTOCOL_VERSION,
        sessionEpoch = options.sessionEpoch or sessionEpoch or "unknown",
        revision = tonumber(options.revision) or Replication.getRevision(zombie),
        stableId = stableId,
        typeId = typeId,
        onlineId = onlineId,
        components = components,
    }
end

function Replication.buildClear(zombie, onlineId, options)
    options=options or {}
    if Identity.getTypeId(zombie) then return nil,"zombie is still typed" end
    local stableId=Persistence.readAssignmentClear(zombie)
    if not stableId then return nil,"no assignment clear" end
    return {protocolVersion=Replication.PROTOCOL_VERSION,cleared=true,
        sessionEpoch=options.sessionEpoch or sessionEpoch or "unknown",
        revision=options.revision or Replication.getRevision(zombie),stableId=stableId,onlineId=onlineId}
end

function Replication.lastApplied(stableId)
    return type(stableId) == "string" and lastApplied[stableId] or nil
end

function Replication.forgetApplied(stableId)
    if type(stableId) == "string" then lastApplied[stableId] = nil end
end

local function checkFreshness(zombie, snapshot)
    local stableId = snapshot.stableId
    local revision = math.max(0, math.floor(tonumber(snapshot.revision) or 0))
    local epoch = tostring(snapshot.sessionEpoch or "unknown")

    local objectPrevious = lastAppliedByZombie[zombie]
    if objectPrevious and objectPrevious.epoch == epoch and revision <= objectPrevious.revision then
        return false, "stale", objectPrevious
    end

    local globalPrevious = lastApplied[stableId]
    if globalPrevious and globalPrevious.epoch == epoch and revision < globalPrevious.revision then
        return false, "stale", globalPrevious
    end

    return true, nil, { stableId = stableId, epoch = epoch, revision = revision }
end

function Replication.applySnapshot(zombie, snapshot)
    if zombie == nil then return false, "zombie is required" end
    local valid, envelopeError=validEnvelope(snapshot)
    if not valid then return false,envelopeError end
    if snapshot.cleared~=nil then return false,"clear is not a typed snapshot" end
    if type(snapshot.typeId) ~= "string" or snapshot.typeId == "" then
        return false, "snapshot identity missing"
    end
    if type(snapshot.components) ~= "table" then return false, "invalid snapshot components" end

    local fresh, freshnessReason, appliedRecord = checkFreshness(zombie, snapshot)
    if not fresh then return false, freshnessReason end

    -- Decode every known component before mutating identity, live state or the
    -- mirrored cache. Rejected updates must not consume their revision.
    local incomingComponents, staged = snapshot.components, {}
    for id, record in pairs(incomingComponents) do
        local schema = ComponentSchemas.get(id)
        if schema and ComponentSchemas.isReplicated(id) then
            if type(record) ~= "table" or record.data == nil then
                return false, "invalid component record: " .. tostring(id)
            end
            local version = tonumber(record.version)
            if not version or version ~= version or version == math.huge or version < 1 or version ~= math.floor(version) then
                return false, "invalid component version: " .. tostring(id)
            end
            -- Migrations/deserializers may mutate their input. Keep the wire
            -- record intact for persistence and a retry of this same snapshot.
            local payload, err = migrate(schema, copySerializable(record.data), version)
            if err then return false, "component " .. tostring(id) .. ": " .. tostring(err) end
            if schema.deserialize then
                local ok, value = FaultIsolation.call("component:" .. id, "replicate-deserialize", schema.deserialize, payload, schema.version)
                if not ok then return false, "component deserialize failed: " .. tostring(id) end
                payload = value
            end
            if payload == nil then return false, "component decoded no payload: " .. tostring(id) end
            staged[id] = payload
        end
    end

    local previous = Identity.getTypeId(zombie)
    local validIdentity, identityError = Identity.validateRestore(zombie, snapshot.typeId)
    if not validIdentity then return false, identityError end
    -- Native cache access is the remaining fallible boundary. Complete it
    -- before publishing live components or consuming the incoming revision.
    local mirrored, mirrorError = Persistence.mirrorSnapshot(zombie, snapshot)
    if not mirrored then return false, mirrorError end
    Identity.restore(zombie, snapshot.stableId, snapshot.typeId)
    for id in pairs(ComponentSchemas.all()) do
        if ComponentSchemas.isReplicated(id) then
            if incomingComponents[id] == nil then
                Components.removeReplicated(zombie, id)
            else
                Components.setReplicated(zombie, id, staged[id])
            end
        end
    end

    Components.markReplicationClean(zombie)
    lastApplied[snapshot.stableId] = appliedRecord
    lastAppliedByZombie[zombie] = appliedRecord
    return true, previous
end

function Replication.applyClear(zombie, snapshot, options)
    if zombie==nil then return false,"zombie is required" end
    local valid,err=validEnvelope(snapshot)
    if not valid then return false,err end
    if snapshot.cleared~=true then return false,"invalid clear" end
    local fresh,reason,record=checkFreshness(zombie,snapshot)
    if not fresh then return false,reason end
    local current=Identity.getStableId(zombie)
    if current and current~=snapshot.stableId and not (options and options.reconciledRequest==true) then return false,"clear identity mismatch" end
    local previous=Identity.getTypeId(zombie)
    -- Complete the fallible native-cache boundary before live mutation.
    local mirrored,mirrorError=Persistence.writeAssignmentClear(zombie,snapshot.stableId)
    if not mirrored then return false,mirrorError end
    Identity.clearReplicated(zombie)
    Components.markReplicationClean(zombie)
    lastApplied[snapshot.stableId]=record
    lastAppliedByZombie[zombie]=record
    return true,previous
end

function Replication.describeSnapshot(snapshot)
    if type(snapshot) ~= "table" then return "invalid" end
    return string.format("%s/%s rev=%s epoch=%s online=%s",
        tostring(snapshot.stableId), tostring(snapshot.typeId), tostring(snapshot.revision),
        tostring(snapshot.sessionEpoch), tostring(snapshot.onlineId))
end

return Replication
