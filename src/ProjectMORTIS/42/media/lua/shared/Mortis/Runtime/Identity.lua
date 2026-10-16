local Components = require "Mortis/Runtime/Components"
local Types = require "Mortis/API/Types"
local NetworkAdapter = require "Mortis/Runtime/Adapters/NetworkAdapter"

local Identity = {}
local TYPE_KEY = "Mortis.Identity.Type"
local STABLE_KEY = "Mortis.Identity.StableId"
local sequence = 0

local MOD = 2147483647
local function hashString(value)
    local text = tostring(value or "Mortis")
    local hash = 5381
    for i = 1, #text do hash = (hash * 33 + string.byte(text, i)) % MOD end
    if hash <= 0 then hash = 1 end
    return hash
end

local function positionPart(zombie)
    local parts = {}
    for _, name in ipairs({ "getX", "getY", "getZ" }) do
        local ok, fn = pcall(function() return zombie and zombie[name] end)
        if ok and type(fn) == "function" then
            local okValue, value = pcall(fn, zombie)
            if okValue and value ~= nil then parts[#parts + 1] = tostring(value) end
        end
    end
    return table.concat(parts, ":")
end

local function createStableId(zombie)
    sequence = sequence + 1
    local onlineId = NetworkAdapter.getOnlineID(zombie)
    local source = table.concat({
        tostring(zombie),
        tostring(onlineId or "offline"),
        positionPart(zombie),
        tostring(sequence),
    }, "|")
    return string.format("MORTIS-%08X-%06d", hashString(source), sequence % 1000000)
end

function Identity.regenerateStableId(zombie)
    local value = createStableId(zombie)
    Components.setRestored(zombie, STABLE_KEY, value)
    return value
end

function Identity.ensureStableId(zombie)
    local value = Components.get(zombie, STABLE_KEY)
    if type(value) == "string" and value ~= "" then return value end
    return Identity.regenerateStableId(zombie)
end

function Identity.validateRestore(zombie, typeId)
    if zombie == nil then return false, "zombie is required" end
    -- Validate an explicit type before touching either identity component.
    -- A missing type remains valid for stable-ID-only vanilla bootstrap.
    if typeId ~= nil and (type(typeId) ~= "string" or typeId == "" or not Types.has(typeId)) then
        return false, "unknown or invalid threat type: " .. tostring(typeId)
    end
    return true
end

function Identity.restore(zombie, stableId, typeId)
    local valid, err = Identity.validateRestore(zombie, typeId)
    if not valid then return false, err end
    if type(stableId) == "string" and stableId ~= "" then
        Components.setRestored(zombie, STABLE_KEY, stableId)
    end
    if typeId ~= nil then
        Components.setRestored(zombie, TYPE_KEY, typeId)
        return true
    end
    return false
end

function Identity.assign(zombie, typeId)
    if not Types.has(typeId) then error("cannot assign unknown infected type: " .. tostring(typeId), 2) end
    Identity.ensureStableId(zombie)
    local previous = Components.get(zombie, TYPE_KEY)
    Components.setRestored(zombie, TYPE_KEY, typeId)
    return previous
end

function Identity.getStableId(zombie)
    return Components.get(zombie, STABLE_KEY)
end

function Identity.getTypeId(zombie)
    return Components.get(zombie, TYPE_KEY)
end

function Identity.getType(zombie)
    local id = Identity.getTypeId(zombie)
    return id and Types.get(id) or nil
end

function Identity.clear(zombie)
    Components.remove(zombie, TYPE_KEY)
    Components.remove(zombie, STABLE_KEY)
end

function Identity.clearReplicated(zombie)
    Components.removeReplicated(zombie, TYPE_KEY)
    Components.removeReplicated(zombie, STABLE_KEY)
end

return Identity
