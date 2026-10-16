local Util = {}

function Util.assertString(value, name)
    if type(value) ~= "string" or value == "" then
        error((name or "value") .. " must be a non-empty string", 3)
    end
    return value
end

function Util.shallowCopy(source)
    local result = {}
    if source then
        for key, value in pairs(source) do
            result[key] = value
        end
    end
    return result
end

function Util.deepCopy(value, seen)
    if type(value) ~= "table" then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local result = {}
    seen[value] = result
    for key, item in pairs(value) do
        result[Util.deepCopy(key, seen)] = Util.deepCopy(item, seen)
    end
    return result
end

function Util.merge(base, override)
    local result = Util.deepCopy(base or {})
    if override then
        for key, value in pairs(override) do
            if type(value) == "table" and type(result[key]) == "table" then
                result[key] = Util.merge(result[key], value)
            else
                result[key] = Util.deepCopy(value)
            end
        end
    end
    return result
end

function Util.readonly(value, name)
    return setmetatable({}, {
        __index = value,
        __newindex = function()
            error((name or "table") .. " is read-only", 2)
        end,
        __pairs = function() return pairs(value) end,
        __len = function() return #value end,
        __metatable = false,
    })
end

return Util
