local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local Behaviors = { registry = Registry.new("behavior") }
local callbacks = { "onAttach", "onDetach", "canRun", "score", "onEnter", "onTick", "onExit", "onStimulus", "onTargetChanged", "onDamaged", "onKilled", "onUpdate" }

function Behaviors.register(definition)
    if type(definition) ~= "table" then error("behavior definition must be a table", 2) end
    local id = Util.assertString(definition.id, "behavior id")
    local normalized = Util.deepCopy(definition)
    normalized.priority = normalized.priority or 0
    normalized.tickClass = normalized.tickClass or "normal"
    for _, name in ipairs(callbacks) do
        if normalized[name] ~= nil and type(normalized[name]) ~= "function" then
            error("behavior " .. name .. " must be a function", 2)
        end
    end
    return Behaviors.registry:register(id, normalized)
end

function Behaviors.get(id) return Behaviors.registry:get(id) end
function Behaviors.has(id) return Behaviors.registry:has(id) end
function Behaviors.all() return Behaviors.registry:all() end

return Behaviors
