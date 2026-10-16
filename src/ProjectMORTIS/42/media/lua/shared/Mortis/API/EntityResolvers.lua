local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"
local R = { registry = Registry.new("entity resolver") }

function R.register(definition)
    if type(definition) ~= "table" then error("entity resolver definition must be a table", 2) end
    local d = Util.deepCopy(definition)
    d.id = Util.assertString(d.id, "entity resolver id")
    d.priority = tonumber(d.priority) or 0
    if type(d.matches) ~= "function" or type(d.resolveSpecies) ~= "function" then
        error("entity resolver requires matches and resolveSpecies functions", 2)
    end
    return R.registry:register(d.id, d)
end

function R.resolve(entity)
    local list = {}
    for _, d in pairs(R.registry:all()) do list[#list+1] = d end
    table.sort(list, function(a,b) return a.priority == b.priority and a.id < b.id or a.priority > b.priority end)
    for _, d in ipairs(list) do
        local ok, match = pcall(d.matches, entity)
        if ok and match == true then
            local ok2, speciesId = pcall(d.resolveSpecies, entity)
            if ok2 and speciesId then return speciesId, d.id end
        end
    end
    return nil
end
return R
