local function deepCopy(value, seen)
    if type(value) ~= "table" then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local result = {}
    seen[value] = result
    for key, child in pairs(value) do result[deepCopy(key, seen)] = deepCopy(child, seen) end
    return result
end

local Registry = {}
function Registry.new()
    local entries = {}
    return {
        register=function(_, id, definition)
            if entries[id] then error("duplicate") end
            entries[id] = deepCopy(definition)
            return deepCopy(entries[id])
        end,
        get=function(_, id) return entries[id] and deepCopy(entries[id]) or nil end,
        has=function(_, id) return entries[id] ~= nil end,
        all=function() return deepCopy(entries) end,
    }
end

local regionState = { attached=true, disabled=false, destroyed=false }
local anatomyState = { speciesId="Mortis.Humanoid" }
local entityData = {}
local emitted = {}
local regionDefinition = {
    attachmentSockets = {
        distal = {
            id="distal", socketType="humanoid.leftHand",
            compatibilityTags={"prosthetic.hand.left"}, exclusive=true,
            availability="missing",
        },
    },
}

local mocks = {
    ["Mortis/Core/Registry"] = Registry,
    ["Mortis/Core/Util"] = {
        deepCopy=deepCopy,
        assertString=function(value, label)
            if type(value) ~= "string" or value == "" then error(label .. " required") end
            return value
        end,
    },
    ["Mortis/API/Species"] = {},
    ["Mortis/Runtime/AnatomyRuntime"] = {
        get=function() return anatomyState end,
        getRegion=function() return regionState, regionDefinition, "leftHand" end,
    },
    ["Mortis/Runtime/Authority"] = {
        canWriteCanonicalState=function() return true end,
        isDedicatedServerRuntime=function() return false end,
    },
    ["Mortis/Runtime/Adapters/EntityAdapter"] = {
        getModData=function() return entityData end,
        transmitModData=function() return true end,
    },
}

local realRequire = require
require = function(name) return mocks[name] or realRequire(name) end
local Attachments = dofile(arg[1])
_G.Mortis = { Events={ emit=function(_, name, _, result) emitted[#emitted+1]={name=name,result=deepCopy(result)} end } }

Attachments.register({
    id="Test.HookHand", providerId="Test.Provider",
    socketTypes={"humanoid.leftHand"}, capabilityModifiers={grip=0.2},
})
assert(Attachments.has("Test.HookHand"), "registered attachment should be discoverable")

local definition = Attachments.get("Test.HookHand")
definition.socketTypes[1] = "mutated"
assert(Attachments.get("Test.HookHand").socketTypes[1] == "humanoid.leftHand", "registry views must be protected copies")

local socket = assert(Attachments.getSocket({}, "leftHand", "distal"))
assert(socket.available == false and socket.naturalState == "attached", "latent socket must be unavailable while natural anatomy is attached")
local allowed, reason = Attachments.canAttach({}, "leftHand", "distal", "Test.HookHand")
assert(allowed == false and reason == "socket unavailable", "unavailable socket must reject attachments")

regionState.attached = false
socket = assert(Attachments.getSocket({}, "leftHand", "distal"))
assert(socket.available == true and socket.naturalState == "missing", "socket must become available when topology state permits")
assert(Attachments.canAttach({}, "leftHand", "distal", "Test.HookHand") == true, "matching attachment should be accepted")

local entity = {}
local installed, installResult = Attachments.attach(entity, "leftHand", "distal", "Test.HookHand", {
    operationId="install-1", data={quality=0.75, unsafe=function() end},
})
assert(installed == true and installResult.attachmentId == "Test.HookHand", "authoritative attach should install compatible definition")
assert(installResult.data.quality == 0.75 and installResult.data.unsafe == nil, "attachment data must be serializable")
assert(Attachments.getAttachment(entity, "leftHand", "distal").operationId == "install-1", "installed attachment must be queryable")
assert(Attachments.canAttach(entity, "leftHand", "distal", "Test.HookHand") == false, "exclusive occupied socket must reject a second attachment")
assert(Attachments.attach(entity, "leftHand", "distal", "Test.HookHand", {operationId="install-1"}) == false, "replayed operation must be rejected")
assert(type(entityData.MORTIS_LIVING.anatomyAttachments) == "table", "attachment state must persist in entity modData")

Attachments.release(entity)
assert(Attachments.getAttachment(entity, "leftHand", "distal").attachmentId == "Test.HookHand", "released runtime state must restore from modData")

local detached, detachResult = Attachments.detach(entity, "leftHand", "distal", {operationId="detach-1"})
assert(detached == true and detachResult.attachmentId == "Test.HookHand", "detach should return the removed attachment record")
assert(Attachments.getAttachment(entity, "leftHand", "distal") == nil, "detached socket must be empty")
assert(Attachments.detach(entity, "leftHand", "distal", {operationId="detach-1"}) == false, "detach replay must be rejected")
assert(#emitted >= 4, "install and detach must emit neutral transition events")

Attachments.register({
    id="Test.RightOnly", providerId="Test.Provider",
    compatibilityTags={"prosthetic.hand.right"},
})
local compatible, incompatibleReason = Attachments.canAttach({}, "leftHand", "distal", "Test.RightOnly")
assert(compatible == false and incompatibleReason == "incompatible", "mismatched attachment must fail closed")

print("MORTIS anatomy attachment registry/query checks passed")
