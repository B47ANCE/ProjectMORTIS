local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local Overrides = { registry = Registry.new("weapon catalog override") }

local VALID_CHANNELS = {
    cut=true, chop=true, pierce=true, crush=true, impact=true,
    ballistic=true, burn=true,
}

local function normalize(fullType, definition)
    if type(definition) ~= "table" then error("weapon override must be a table", 3) end
    local d = Util.deepCopy(definition)
    d.fullType = Util.assertString(fullType or d.fullType, "weapon full type")
    if d.channel ~= nil then
        d.channel = string.lower(Util.assertString(d.channel, "weapon override channel"))
        if not VALID_CHANNELS[d.channel] then error("unsupported trauma channel: " .. d.channel, 3) end
    end
    d.status = d.status or "manual"
    d.confirmed = d.confirmed ~= false
    d.notes = d.notes
    return d
end

function Overrides.register(fullType, definition)
    local d = normalize(fullType, definition)
    return Overrides.registry:register(d.fullType, d)
end

function Overrides.replace(fullType, definition)
    local d = normalize(fullType, definition)
    return Overrides.registry:replace(d.fullType, d)
end

function Overrides.get(fullType) return Overrides.registry:get(fullType) end
function Overrides.has(fullType) return Overrides.registry:has(fullType) end
function Overrides.all() return Overrides.registry:all() end

return Overrides
