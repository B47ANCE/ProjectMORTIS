local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local FoodSources = { registry = Registry.new("food source provider"), TRANSACTION_VERSION = 1 }

function FoodSources.register(definition)
    if type(definition) ~= "table" then error("food source provider must be a table", 2) end
    local normalized = Util.deepCopy(definition)
    normalized.id = Util.assertString(normalized.id, "food source provider id")
    normalized.priority = tonumber(normalized.priority) or 0
    if normalized.priority~=normalized.priority or normalized.priority==math.huge or normalized.priority==-math.huge then
        error("food source provider priority must be finite",2)
    end
    normalized.sourceClass = normalized.sourceClass or "registered-food-source"
    if type(normalized.findNearby) ~= "function" then
        error("food source provider findNearby must be a function", 2)
    end
    if normalized.consume ~= nil and type(normalized.consume) ~= "function" then
        error("food source provider consume must be a function", 2)
    end
    if normalized.transactionVersion~=nil or normalized.reserve~=nil
        or normalized.commit~=nil or normalized.rollback~=nil then
        if normalized.transactionVersion~=FoodSources.TRANSACTION_VERSION then
            error("food source transactionVersion must be 1",2)
        end
        for _,name in ipairs({"reserve","commit","rollback"}) do
            if type(normalized[name])~="function" then error("food source "..name.." must be a function",2) end
        end
    end
    return FoodSources.registry:register(normalized.id, normalized)
end

function FoodSources.get(id) return FoodSources.registry:get(id) end
function FoodSources.has(id) return FoodSources.registry:has(id) end
function FoodSources.all() return FoodSources.registry:all() end

return FoodSources
