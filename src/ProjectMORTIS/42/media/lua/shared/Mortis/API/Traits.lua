local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local Traits = { registry = Registry.new("trait") }

function Traits.register(definition)
    if type(definition) ~= "table" then error("trait definition must be a table", 2) end
    local id = Util.assertString(definition.id, "trait id")
    local normalized = Util.deepCopy(definition)
    normalized.defaults = normalized.defaults or {}
    return Traits.registry:register(id, normalized)
end

function Traits.get(id) return Traits.registry:get(id) end
function Traits.has(id) return Traits.registry:has(id) end
function Traits.all() return Traits.registry:all() end

return Traits
