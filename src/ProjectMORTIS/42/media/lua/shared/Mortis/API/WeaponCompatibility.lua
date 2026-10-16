local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local Compatibility = {
    providers = Registry.new("weapon compatibility provider"),
    entries = Registry.new("verified weapon compatibility entry"),
}

local VALID_CHANNELS = {
    cut=true, chop=true, pierce=true, crush=true, impact=true,
    ballistic=true, burn=true,
}

function Compatibility.registerProvider(definition)
    if type(definition) ~= "table" then error("compatibility provider must be a table", 2) end
    local d = Util.deepCopy(definition)
    d.id = Util.assertString(d.id, "compatibility provider id")
    d.displayName = d.displayName or d.id
    d.kind = d.kind or "patch"
    d.targetModId = d.targetModId
    d.verified = d.verified ~= false
    d.version = d.version or 1
    return Compatibility.providers:register(d.id, d)
end

function Compatibility.registerWeapon(providerId, fullType, definition)
    local provider = Compatibility.providers:get(providerId)
    if not provider then error("unknown compatibility provider: " .. tostring(providerId), 2) end
    if type(definition) ~= "table" then error("weapon compatibility definition must be a table", 2) end

    local d = Util.deepCopy(definition)
    d.fullType = Util.assertString(fullType, "weapon full type")
    d.channel = string.lower(Util.assertString(d.channel, "trauma channel"))
    if not VALID_CHANNELS[d.channel] then error("unsupported trauma channel: " .. d.channel, 2) end
    d.providerId = providerId
    d.providerKind = provider.kind
    d.providerName = provider.displayName
    d.targetModId = provider.targetModId
    d.verified = provider.verified == true
    d.status = provider.kind == "core" and "core-verified" or "patch-verified"
    d.confidence = 1.0
    d.reason = d.reason or ("verified by " .. provider.displayName)
    return Compatibility.entries:register(d.fullType, d)
end

function Compatibility.get(fullType) return Compatibility.entries:get(fullType) end
function Compatibility.has(fullType) return Compatibility.entries:has(fullType) end
function Compatibility.getProvider(id) return Compatibility.providers:get(id) end
function Compatibility.all() return Compatibility.entries:all() end
function Compatibility.allProviders() return Compatibility.providers:all() end

return Compatibility
