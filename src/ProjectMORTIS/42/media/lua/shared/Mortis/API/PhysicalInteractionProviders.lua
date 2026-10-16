local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local Providers = { registry = Registry.new("physical interaction provider") }

function Providers.register(definition)
    if type(definition) ~= "table" then error("physical interaction provider must be a table", 2) end
    local d = Util.deepCopy(definition)
    d.id = Util.assertString(d.id, "physical interaction provider id")
    d.priority = tonumber(d.priority) or 0
    if type(d.inspect) ~= "function" then error("physical interaction provider requires inspect(context)", 2) end
    return Providers.registry:register(d.id, d)
end

function Providers.allSorted()
    local list = {}
    for _, d in pairs(Providers.registry:all()) do list[#list+1] = d end
    table.sort(list, function(a,b)
        if a.priority == b.priority then return a.id < b.id end
        return a.priority > b.priority
    end)
    return list
end

function Providers.inspect(context)
    local result = {}
    for _, d in ipairs(Providers.allSorted()) do
        local ok, value = pcall(d.inspect, context)
        if ok and type(value) == "table" then
            for k, v in pairs(value) do
                if result[k] == nil then result[k] = v end
            end
        end
    end
    return result
end

return Providers
