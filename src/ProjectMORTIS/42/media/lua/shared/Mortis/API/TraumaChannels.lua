local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"
local Channels = { registry = Registry.new("trauma channel") }

function Channels.register(definition)
    if type(definition) ~= "table" then error("trauma channel definition must be a table", 2) end
    local d = Util.deepCopy(definition)
    d.id = Util.assertString(d.id, "trauma channel id")
    d.structuralMultiplier = tonumber(d.structuralMultiplier) or 1
    d.bleedMultiplier = tonumber(d.bleedMultiplier) or 0
    d.severMultiplier = tonumber(d.severMultiplier) or 0
    d.crushMultiplier = tonumber(d.crushMultiplier) or 0
    return Channels.registry:register(d.id, d)
end
function Channels.get(id) return Channels.registry:get(id) end
function Channels.has(id) return Channels.registry:has(id) end
function Channels.all() return Channels.registry:all() end
return Channels
