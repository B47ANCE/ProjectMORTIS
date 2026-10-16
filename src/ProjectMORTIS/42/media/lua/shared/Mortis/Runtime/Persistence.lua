local ComponentSchemas = require "Mortis/API/Components"
local RuntimeComponents = require "Mortis/Runtime/Components"
local PersistenceAdapter = require "Mortis/Runtime/Adapters/PersistenceAdapter"
local FaultIsolation = require "Mortis/Core/FaultIsolation"
local Logger = require "Mortis/Core/Logger"
local Util = require "Mortis/Core/Util"

local Persistence = {}
local ROOT_KEY = "ProjectMORTIS"
local FORMAT_VERSION = 1

local function deepSerializableCopy(value, seen)
    local t = type(value)
    if value == nil or t == "boolean" or t == "number" or t == "string" then return value end
    if t ~= "table" then return nil end

    seen = seen or {}
    if seen[value] then return nil end
    seen[value] = true

    local result = {}
    for k, v in pairs(value) do
        local kt = type(k)
        if kt == "string" or kt == "number" then
            local copied = deepSerializableCopy(v, seen)
            if copied ~= nil then result[k] = copied end
        end
    end
    seen[value] = nil
    return result
end

local function getRoot(zombie, create)
    local modData, err = PersistenceAdapter.getModData(zombie)
    if not modData then return nil, err end
    local root = modData[ROOT_KEY]
    if root == nil and create then
        root = { formatVersion = FORMAT_VERSION, components = {} }
        modData[ROOT_KEY] = root
    end
    if root ~= nil and type(root) ~= "table" then
        if not create then return nil, "invalid M.O.R.T.I.S. modData root" end
        root = { formatVersion = FORMAT_VERSION, components = {} }
        modData[ROOT_KEY] = root
    end
    if root then
        root.formatVersion = tonumber(root.formatVersion) or FORMAT_VERSION
        if type(root.components) ~= "table" then root.components = {} end
    end
    return root
end

local function serializeComponent(schema, value)
    if schema.serialize then
        local ok, result = FaultIsolation.call("component:" .. schema.id, "serialize", schema.serialize, value)
        if not ok then return nil, "serialize failed" end
        value = result
    end
    local copied = deepSerializableCopy(value)
    if copied == nil then return nil, "component produced no serializable payload" end
    return copied
end

local function migrateComponent(schema, payload, storedVersion)
    local version = math.max(1, math.floor(tonumber(storedVersion) or 1))
    if version > schema.version then
        return nil, "stored component version is newer than local schema"
    end
    local value = payload
    while version < schema.version do
        local migration = schema.migrations[version]
        if not migration then
            return nil, "missing migration from component version " .. tostring(version)
        end
        local ok, migrated = FaultIsolation.call("component:" .. schema.id, "migrate-v" .. tostring(version), migration, value)
        if not ok then return nil, "migration failed at version " .. tostring(version) end
        value = migrated
        version = version + 1
    end
    return value
end

local function deserializeComponent(schema, record)
    local payload, err = migrateComponent(schema, record.data, record.version)
    if payload == nil and err then return nil, err end
    if schema.deserialize then
        local ok, result = FaultIsolation.call("component:" .. schema.id, "deserialize", schema.deserialize, payload, schema.version)
        if not ok then return nil, "deserialize failed" end
        payload = result
    end
    return payload
end

function Persistence.readIdentity(zombie)
    local root = getRoot(zombie, false)
    if not root then return nil end
    if type(root.identity) ~= "table" then return nil end
    local stableId = root.identity.stableId
    local typeId = root.identity.typeId
    if type(stableId) ~= "string" or stableId == "" then stableId = nil end
    if type(typeId) ~= "string" or typeId == "" then typeId = nil end
    if stableId == nil and typeId == nil then return nil end
    return {
        stableId = stableId,
        typeId = typeId,
        schemaVersion = tonumber(root.identity.schemaVersion) or 1,
    }
end

function Persistence.writeIdentity(zombie, stableId, typeId, transmit)
    local root, err = getRoot(zombie, true)
    if not root then return false, err end
    root.identity = {
        schemaVersion = 1,
        stableId = stableId,
        typeId = typeId,
    }
    if transmit then PersistenceAdapter.transmitModData(zombie) end
    return true
end

function Persistence.clearIdentity(zombie, transmit)
    local root = getRoot(zombie, false)
    if not root then return false end
    root.identity = nil
    if transmit then PersistenceAdapter.transmitModData(zombie) end
    return true
end

-- An additive root field survives stream-out and dedicated restart. It is not
-- a new gameplay identity and must not restore a typed lifecycle.
function Persistence.writeAssignmentClear(zombie, stableId)
    if type(stableId)~="string" or stableId=="" then return false,"stable identity required" end
    local root, err = getRoot(zombie, true)
    if not root then return false, err end
    root.assignmentClear = { stableId=stableId }
    root.identity = nil
    return true
end

function Persistence.readAssignmentClear(zombie)
    local root = getRoot(zombie, false)
    local record = root and root.assignmentClear
    if type(record)=="table" and type(record.stableId)=="string" and record.stableId~="" then
        return record.stableId
    end
    return nil
end

function Persistence.readReplicationRevision(zombie, epoch)
    local root=getRoot(zombie,false)
    local record=root and root.replicationRevision
    if type(record)~="table" or record.epoch~=epoch then return 0 end
    local value=record.revision
    if type(value)~="number" or value~=value or value<0 or value==math.huge or value~=math.floor(value) then return 0 end
    return value
end

function Persistence.writeReplicationRevision(zombie, epoch, revision)
    local root,err=getRoot(zombie,true)
    if not root then return false,err end
    root.replicationRevision={epoch=epoch,revision=revision}
    return true
end

function Persistence.loadComponents(zombie)
    local root = getRoot(zombie, false)
    if not root or type(root.components) ~= "table" then return 0 end
    local loaded = 0
    for id, record in pairs(root.components) do
        local schema = ComponentSchemas.get(id)
        if schema and ComponentSchemas.isPersistent(id) and type(record) == "table" then
            local value, err = deserializeComponent(schema, record)
            if err then
                Logger.warn("Could not restore component " .. tostring(id) .. ": " .. tostring(err))
            else
                RuntimeComponents.setRestored(zombie, id, value)
                loaded = loaded + 1
            end
        end
    end
    RuntimeComponents.markClean(zombie)
    return loaded
end

function Persistence.flushComponents(zombie, transmit)
    local root, err = getRoot(zombie, true)
    if not root then return false, err end
    local bucket = RuntimeComponents.allFor(zombie)
    root.components = root.components or {}
    local staged, registered = {}, {}

    for id, schema in pairs(ComponentSchemas.all()) do
        if ComponentSchemas.isPersistent(id) then
            registered[id] = true
            local value
            if bucket then value = bucket[id] end
            if value ~= nil then
                local serialized, serializeErr = serializeComponent(schema, value)
                if serializeErr then
                    Logger.rateLimited("persist:" .. tostring(id), 2, "WARN",
                        "Could not persist component " .. tostring(id) .. ": " .. tostring(serializeErr))
                    return false, "component " .. tostring(id) .. ": " .. tostring(serializeErr)
                end
                staged[id] = { version = schema.version, data = serialized }
            end
        end
    end

    -- Do not publish a mixture of old and new components if any serializer
    -- failed. Unknown saved components are retained for temporarily absent mods.
    for id in pairs(registered) do root.components[id] = staged[id] end
    RuntimeComponents.markClean(zombie)
    if transmit then PersistenceAdapter.transmitModData(zombie) end
    return true
end

function Persistence.flushZombie(zombie, stableId, typeId, transmit)
    local ok, err = Persistence.writeIdentity(zombie, stableId, typeId, false)
    if not ok then return false, err end
    local okComponents, componentErr = Persistence.flushComponents(zombie, false)
    if not okComponents then return false, componentErr end
    if transmit then PersistenceAdapter.transmitModData(zombie) end
    return true
end

-- Mirrors an authoritative server snapshot into the local zombie modData without
-- transmitting it back. This is useful on MP clients so stream-out/stream-in can
-- restore the last server-confirmed identity while an explicit reconciliation
-- request is in flight. Only component records present in the authoritative
-- snapshot are mirrored.
function Persistence.mirrorSnapshot(zombie, snapshot)
    if type(snapshot) ~= "table" then return false, "invalid snapshot" end
    local root, err = getRoot(zombie, true)
    if not root then return false, err end

    root.identity = {
        schemaVersion = 1,
        stableId = snapshot.stableId,
        typeId = snapshot.typeId,
    }
    root.components = root.components or {}

    local incoming = snapshot.components or {}
    for id, schema in pairs(ComponentSchemas.all()) do
        if ComponentSchemas.isPersistent(id) and ComponentSchemas.isReplicated(id) then
            local record = incoming[id]
            if type(record) == "table" then
                root.components[id] = deepSerializableCopy(record)
            else
                root.components[id] = nil
            end
        end
    end
    return true
end

function Persistence.identityMatches(zombie, stableId, typeId)
    local record = Persistence.readIdentity(zombie)
    if not record then return stableId == nil and typeId == nil end
    return record.stableId == stableId and record.typeId == typeId
end

function Persistence.isAvailable()
    return require("Mortis/API/Capabilities").has("zombie.getModData")
end

Persistence.ROOT_KEY = ROOT_KEY
Persistence.FORMAT_VERSION = FORMAT_VERSION
return Persistence
