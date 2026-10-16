local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local Policies = { registry = Registry.new("biological decomposition policy") }

function Policies.register(definition)
    if type(definition) ~= "table" then error("decomposition policy must be a table", 2) end
    local value = Util.deepCopy(definition)
    value.id = Util.assertString(value.id, "decomposition policy id")
    value.intervalHours = tonumber(value.intervalHours)
    if not value.intervalHours or value.intervalHours <= 0 then
        error("decomposition policy intervalHours must be greater than zero", 2)
    end
    if type(value.plan) ~= "function" then error("decomposition policy plan must be a function", 2) end
    value.maxOperations = math.max(1, math.min(32, math.floor(tonumber(value.maxOperations) or 16)))
    value.maxCatchupHours = math.max(value.intervalHours,
        tonumber(value.maxCatchupHours) or (value.intervalHours * 24))
    return Policies.registry:register(value.id, value)
end

function Policies.get(id) return Policies.registry:get(id) end
function Policies.has(id) return Policies.registry:has(id) end

return Policies
