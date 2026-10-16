local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local Types = { registry = Registry.new("infected type") }

local function normalize(definition)
    if type(definition) ~= "table" then error("infected type definition must be a table", 3) end
    local result = Util.deepCopy(definition)
    result.id = Util.assertString(result.id, "infected type id")
    result.displayName = result.displayName or result.id
    result.stats = result.stats or {}
    result.traits = result.traits or {}
    result.behaviors = result.behaviors or {}
    result.spawn = result.spawn or {}
    if result.appearance == nil and result.appearanceProfile == nil then result.appearance = {} end
    return result
end

local function resolve(id, stack)
    local current = Types.registry:get(id)
    if not current then return nil end
    if not current.extends then return current end

    stack = stack or {}
    if stack[id] then error("infected type inheritance cycle at " .. id, 3) end
    stack[id] = true
    local parent = resolve(current.extends, stack)
    if not parent then error("unknown parent infected type: " .. tostring(current.extends), 3) end
    stack[id] = nil

    local child = Util.deepCopy(current)
    child.extends = nil
    return Util.merge(parent, child)
end

function Types.register(definition)
    local normalized = normalize(definition)
    return Types.registry:register(normalized.id, normalized)
end

function Types.get(id)
    local resolved = resolve(id)
    return resolved and Util.deepCopy(resolved) or nil
end

function Types.getRaw(id) return Types.registry:get(id) end
function Types.has(id) return Types.registry:has(id) end
function Types.all() return Types.registry:all() end

return Types
