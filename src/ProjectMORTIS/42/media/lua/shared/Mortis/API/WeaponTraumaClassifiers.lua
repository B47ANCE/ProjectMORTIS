local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local Classifiers = { registry = Registry.new("weapon trauma classifier") }

function Classifiers.register(definition)
    if type(definition) ~= "table" then error("weapon trauma classifier must be a table", 2) end
    local d = Util.deepCopy(definition)
    d.id = Util.assertString(d.id, "weapon trauma classifier id")
    d.priority = tonumber(d.priority) or 0
    if type(d.matches) ~= "function" then error("weapon trauma classifier requires matches(weapon, snapshot)", 2) end
    if type(d.classify) ~= "function" then error("weapon trauma classifier requires classify(weapon, snapshot)", 2) end
    return Classifiers.registry:register(d.id, d)
end

function Classifiers.allSorted()
    local list = {}
    for _, d in pairs(Classifiers.registry:all()) do list[#list + 1] = d end
    table.sort(list, function(a, b)
        if a.priority == b.priority then return a.id < b.id end
        return a.priority > b.priority
    end)
    return list
end

function Classifiers.classify(weapon, snapshot)
    for _, d in ipairs(Classifiers.allSorted()) do
        local okMatch, matches = pcall(d.matches, weapon, snapshot)
        if okMatch and matches == true then
            local okClassify, result = pcall(d.classify, weapon, snapshot)
            if okClassify and type(result) == "table" and result.channel then
                result.classifierId = d.id
                return result
            end
        end
    end
    return nil
end

return Classifiers
