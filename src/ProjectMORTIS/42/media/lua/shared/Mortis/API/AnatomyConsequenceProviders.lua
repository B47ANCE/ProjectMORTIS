local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local Providers = { registry = Registry.new("anatomy consequence provider") }

local CALLBACKS = {
    onDisabled=true,
    onSevered=true,
    onDestroyed=true,
    onCriticalDestroyed=true,
    onBleeding=true,
    onTrauma=true,
}

function Providers.register(definition)
    if type(definition) ~= "table" then error("anatomy consequence provider must be a table", 2) end
    local d = Util.deepCopy(definition)
    d.id = Util.assertString(d.id, "anatomy consequence provider id")
    d.priority = tonumber(d.priority) or 0
    local found = false
    for name in pairs(CALLBACKS) do
        if d[name] ~= nil and type(d[name]) ~= "function" then
            error(name .. " must be a function", 2)
        end
        found = found or type(d[name]) == "function"
    end
    if not found then error("anatomy consequence provider requires at least one callback", 2) end
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

return Providers
