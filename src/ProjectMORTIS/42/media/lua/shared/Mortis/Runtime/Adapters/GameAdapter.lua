local GameAdapter = {}

local unpackValues = unpack or (table and table.unpack)
if not unpackValues then
    unpackValues = function(values, first, last)
        first = first or 1
        last = last or #values
        if first > last then return end
        return values[first], unpackValues(values, first + 1, last)
    end
end

function GameAdapter.getVersion()
    if type(getCore) ~= "function" then return "unknown" end
    local ok, core = pcall(getCore)
    if not ok or not core then return "unknown" end
    local methods = { "getVersion", "getGameVersion" }
    for _, name in ipairs(methods) do
        local okMethod, value = pcall(function()
            local fn = core[name]
            return fn and fn(core) or nil
        end)
        if okMethod and value ~= nil then return tostring(value) end
    end
    return "unknown"
end

function GameAdapter.call(object, methodName, ...)
    if object == nil then return false, "object is nil" end
    local okMethod, fn = pcall(function() return object[methodName] end)
    if not okMethod or type(fn) ~= "function" then
        return false, "method unavailable: " .. tostring(methodName)
    end

    local args = { ... }
    local ok, a, b, c, d = pcall(function()
        return fn(object, unpackValues(args, 1, #args))
    end)
    if not ok then return false, a end
    return true, a, b, c, d
end

return GameAdapter
