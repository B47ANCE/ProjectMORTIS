local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"
local Anatomy = require "Mortis/Runtime/AnatomyRuntime"
local Authority = require "Mortis/Runtime/Authority"
local Entity = require "Mortis/Runtime/Adapters/EntityAdapter"

local Attachments = { registry = Registry.new("anatomy attachment") }
local ROOT_KEY = "MORTIS_LIVING"
local STATE_KEY = "anatomyAttachments"
local FORMAT_VERSION = 1
local MAX_PROCESSED_OPERATIONS = 32
local stateByEntity = setmetatable({}, { __mode = "k" })

local function copySerializable(value, seen)
    local kind = type(value)
    if value == nil or kind == "boolean" or kind == "number" or kind == "string" then return value end
    if kind ~= "table" then return nil end
    seen = seen or {}
    if seen[value] then return nil end
    seen[value] = true
    local result = {}
    for key, child in pairs(value) do
        if type(key) == "string" or type(key) == "number" then
            local copied = copySerializable(child, seen)
            if copied ~= nil then result[key] = copied end
        end
    end
    seen[value] = nil
    return result
end

local function emit(name, entity, result)
    local Mortis = rawget(_G, "Mortis")
    if Mortis and Mortis.Events then Mortis.Events:emit(name, entity, Util.deepCopy(result)) end
end

local function mountKey(regionId, socketId)
    return tostring(regionId) .. "\31" .. tostring(socketId)
end

local function freshState(speciesId)
    return {
        schemaVersion = FORMAT_VERSION,
        speciesId = speciesId,
        revision = 0,
        mounts = {},
        processedOperations = {},
    }
end

local function restoreState(speciesId, stored)
    local state = freshState(speciesId)
    if type(stored) ~= "table" or stored.speciesId ~= speciesId then return state end
    local storedVersion = math.max(1, math.floor(tonumber(stored.schemaVersion) or 1))
    if storedVersion > FORMAT_VERSION then return nil, "attachment state is newer than this Project M.O.R.T.I.S. version" end
    state.revision = math.max(0, math.floor(tonumber(stored.revision) or 0))
    state.mounts = copySerializable(stored.mounts) or {}
    for _, operationId in ipairs(stored.processedOperations or {}) do
        if type(operationId) == "string" and operationId ~= "" then
            state.processedOperations[#state.processedOperations + 1] = operationId
            if #state.processedOperations >= MAX_PROCESSED_OPERATIONS then break end
        end
    end
    return state
end

local function getState(entity)
    local existing = stateByEntity[entity]
    if existing then return existing end
    local anatomy, anatomyErr = Anatomy.get(entity)
    if not anatomy then return nil, anatomyErr end
    local data = Entity.getModData(entity)
    if not data then return nil, "entity has no modData" end
    local root = data[ROOT_KEY]
    local stored = type(root) == "table" and root[STATE_KEY] or nil
    local state, restoreErr = restoreState(anatomy.speciesId, stored)
    if not state then return nil, restoreErr end
    stateByEntity[entity] = state
    return state
end

local function saveState(entity, state, transmit)
    local data = Entity.getModData(entity)
    if not data then return false, "entity has no modData" end
    data[ROOT_KEY] = data[ROOT_KEY] or {}
    data[ROOT_KEY][STATE_KEY] = copySerializable(state)
    if transmit then Entity.transmitModData(entity) end
    return true
end

local function hasProcessed(state, operationId)
    for _, existing in ipairs(state.processedOperations) do
        if existing == operationId then return true end
    end
    return false
end

local function recordProcessed(state, operationId)
    state.processedOperations[#state.processedOperations + 1] = operationId
    while #state.processedOperations > MAX_PROCESSED_OPERATIONS do table.remove(state.processedOperations, 1) end
end

local function normalizeStringList(values, label)
    if values == nil then return {} end
    if type(values) ~= "table" then error(label .. " must be a table", 3) end
    local result, seen = {}, {}
    for _, value in ipairs(values) do
        local text = Util.assertString(value, label .. " entry")
        if not seen[text] then
            seen[text] = true
            result[#result + 1] = text
        end
    end
    table.sort(result)
    return result
end

local function normalizeNumericMap(values, label)
    if values == nil then return {} end
    if type(values) ~= "table" then error(label .. " must be a table", 3) end
    local result = {}
    for key, value in pairs(values) do
        local id = Util.assertString(key, label .. " key")
        local number = tonumber(value)
        if not number or number ~= number or number == math.huge or number == -math.huge then
            error(label .. " value for '" .. id .. "' must be finite", 3)
        end
        result[id] = number
    end
    return result
end

local function listContains(values, expected)
    for _, value in ipairs(values or {}) do
        if value == expected then return true end
    end
    return false
end

local function sharesValue(a, b)
    for _, value in ipairs(a or {}) do
        if listContains(b, value) then return true end
    end
    return false
end

local function isAvailable(socket, regionState)
    local rule = socket.availability or "missing"
    if rule == "always" then return true end
    if rule == "missing" then return regionState.attached == false end
    if rule == "attached" then return regionState.attached ~= false end
    if rule == "disabled" then return regionState.disabled == true end
    if rule == "destroyed" then return regionState.destroyed == true end
    return false
end

function Attachments.register(definition)
    if type(definition) ~= "table" then error("anatomy attachment definition must be a table", 2) end
    local def = Util.deepCopy(definition)
    def.id = Util.assertString(def.id, "anatomy attachment id")
    def.providerId = Util.assertString(def.providerId, "anatomy attachment providerId")
    def.version = math.max(1, math.floor(tonumber(def.version) or 1))
    def.displayName = def.displayName or def.id
    def.socketTypes = normalizeStringList(def.socketTypes, "attachment socketTypes")
    def.compatibilityTags = normalizeStringList(def.compatibilityTags, "attachment compatibilityTags")
    if #def.socketTypes == 0 and #def.compatibilityTags == 0 then
        error("anatomy attachment must declare a socketType or compatibilityTag", 2)
    end
    def.capabilityModifiers = normalizeNumericMap(def.capabilityModifiers, "attachment capabilityModifiers")
    return Attachments.registry:register(def.id, def)
end

function Attachments.get(id) return Attachments.registry:get(id) end
function Attachments.has(id) return Attachments.registry:has(id) end
function Attachments.all() return Attachments.registry:all() end

function Attachments.isCompatible(socket, attachmentOrId)
    if type(socket) ~= "table" then return false, "socket required" end
    local attachment = type(attachmentOrId) == "table" and Util.deepCopy(attachmentOrId) or Attachments.get(attachmentOrId)
    if not attachment then return false, "unknown attachment: " .. tostring(attachmentOrId) end
    if listContains(attachment.socketTypes, socket.socketType) then return true end
    if sharesValue(attachment.compatibilityTags, socket.compatibilityTags) then return true end
    return false, "incompatible"
end

function Attachments.getSocket(entity, region, socketId)
    local regionState, regionDefinition, regionId = Anatomy.getRegion(entity, region)
    if not regionState then return nil, regionDefinition end
    local socket = regionDefinition.attachmentSockets and regionDefinition.attachmentSockets[socketId]
    if not socket then return nil, "unknown socket: " .. tostring(socketId) end
    local result = Util.deepCopy(socket)
    result.regionId = regionId
    result.available = isAvailable(result, regionState)
    result.naturalState = regionState.attached == false and "missing" or
        (regionState.destroyed and "destroyed" or (regionState.disabled and "disabled" or "attached"))
    local state = getState(entity)
    result.mountedAttachment = state and Util.deepCopy(state.mounts[mountKey(regionId, socketId)]) or nil
    return result
end

function Attachments.getSockets(entity, region)
    local regionState, regionDefinition, regionId = Anatomy.getRegion(entity, region)
    if not regionState then return nil, regionDefinition end
    local result = {}
    for socketId, socket in pairs(regionDefinition.attachmentSockets or {}) do
        local view = Util.deepCopy(socket)
        view.regionId = regionId
        view.available = isAvailable(view, regionState)
        view.naturalState = regionState.attached == false and "missing" or
            (regionState.destroyed and "destroyed" or (regionState.disabled and "disabled" or "attached"))
        local state = getState(entity)
        view.mountedAttachment = state and Util.deepCopy(state.mounts[mountKey(regionId, socketId)]) or nil
        result[socketId] = view
    end
    return result
end

function Attachments.canAttach(entity, region, socketId, attachmentOrId)
    local socket, err = Attachments.getSocket(entity, region, socketId)
    if not socket then return false, err end
    if not socket.available then return false, "socket unavailable" end
    if socket.exclusive and socket.mountedAttachment then return false, "socket occupied" end
    return Attachments.isCompatible(socket, attachmentOrId)
end

function Attachments.getAttachment(entity, region, socketId)
    local socket, err = Attachments.getSocket(entity, region, socketId)
    if not socket then return nil, err end
    return socket.mountedAttachment and Util.deepCopy(socket.mountedAttachment) or nil
end

function Attachments.attach(entity, region, socketId, attachmentId, options)
    options = options or {}
    local operationId = options.operationId
    if type(operationId) ~= "string" or operationId == "" then return false, "operationId required" end
    if not Authority.canWriteCanonicalState(entity) then return false, "non-authority" end

    local state, stateErr = getState(entity)
    if not state then return false, stateErr end
    if hasProcessed(state, operationId) then return false, "duplicate operation" end

    local allowed, reason = Attachments.canAttach(entity, region, socketId, attachmentId)
    if not allowed then
        local rejected = { operationId=operationId, attachmentId=attachmentId, region=region, socketId=socketId, reason=reason }
        emit("AttachmentRejected", entity, rejected)
        return false, reason
    end

    local socket = Attachments.getSocket(entity, region, socketId)
    local attachment = Attachments.get(attachmentId)
    local key = mountKey(socket.regionId, socketId)
    local previousRevision = state.revision
    state.revision = previousRevision + 1
    state.mounts[key] = {
        attachmentId = attachment.id,
        attachmentVersion = attachment.version,
        providerId = attachment.providerId,
        regionId = socket.regionId,
        socketId = socketId,
        operationId = operationId,
        installedRevision = state.revision,
        data = copySerializable(options.data) or {},
    }
    recordProcessed(state, operationId)

    local transmit = options.transmit ~= false and Authority.isDedicatedServerRuntime()
    local saved, saveErr = saveState(entity, state, transmit)
    if not saved then
        state.mounts[key] = nil
        state.revision = previousRevision
        table.remove(state.processedOperations)
        return false, saveErr
    end

    local result = Util.deepCopy(state.mounts[key])
    result.revision = state.revision
    emit("AttachmentInstalled", entity, result)
    emit("AttachmentChanged", entity, result)
    return true, result
end

function Attachments.detach(entity, region, socketId, options)
    options = options or {}
    local operationId = options.operationId
    if type(operationId) ~= "string" or operationId == "" then return false, "operationId required" end
    if not Authority.canWriteCanonicalState(entity) then return false, "non-authority" end

    local socket, socketErr = Attachments.getSocket(entity, region, socketId)
    if not socket then return false, socketErr end
    local state, stateErr = getState(entity)
    if not state then return false, stateErr end
    if hasProcessed(state, operationId) then return false, "duplicate operation" end
    local key = mountKey(socket.regionId, socketId)
    local mounted = state.mounts[key]
    if not mounted then return false, "socket empty" end

    local previousRevision = state.revision
    state.revision = previousRevision + 1
    state.mounts[key] = nil
    recordProcessed(state, operationId)
    local transmit = options.transmit ~= false and Authority.isDedicatedServerRuntime()
    local saved, saveErr = saveState(entity, state, transmit)
    if not saved then
        state.mounts[key] = mounted
        state.revision = previousRevision
        table.remove(state.processedOperations)
        return false, saveErr
    end

    local result = Util.deepCopy(mounted)
    result.removalOperationId = operationId
    result.revision = state.revision
    emit("AttachmentRemoved", entity, result)
    emit("AttachmentChanged", entity, result)
    return true, result
end

function Attachments.snapshot(entity)
    local state, err = getState(entity)
    return state and Util.deepCopy(state) or nil, err
end

function Attachments.flush(entity, transmit)
    local state, err = getState(entity)
    if not state then return false, err end
    return saveState(entity, state, transmit == true)
end

function Attachments.release(entity) stateByEntity[entity] = nil end

Attachments.FORMAT_VERSION = FORMAT_VERSION
Attachments.MAX_PROCESSED_OPERATIONS = MAX_PROCESSED_OPERATIONS

return Attachments
