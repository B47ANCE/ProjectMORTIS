local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local FoodSources = { registry = Registry.new("food source provider") }

function FoodSources.register(definition)
    if type(definition) ~= "table" then error("food source provider must be a table", 2) end
    local normalized = Util.deepCopy(definition)
    normalized.id = Util.assertString(normalized.id, "food source provider id")
    normalized.priority = tonumber(normalized.priority) or 0
    normalized.sourceClass = normalized.sourceClass or "registered-food-source"
    if type(normalized.findNearby) ~= "function" then
        error("food source provider findNearby must be a function", 2)
    end
    if normalized.consume ~= nil and type(normalized.consume) ~= "function" then
        error("food source provider consume must be a function", 2)
    end
    return FoodSources.registry:register(normalized.id, normalized)
end

function FoodSources.get(id) return FoodSources.registry:get(id) end
function FoodSources.has(id) return FoodSources.registry:has(id) end
function FoodSources.all() return FoodSources.registry:all() end

return FoodSources
