local Capabilities = require "Mortis/API/Capabilities"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local AnimationAdapter = {}

function AnimationAdapter.getState(zombie)
    if not Capabilities.has("zombie.getCurrentState") then return nil, "capability unavailable" end
    local ok, value = GameAdapter.call(zombie, "getCurrentState")
    if not ok then return nil, value end
    return value
end

function AnimationAdapter.getVariable(zombie, name)
    if not Capabilities.has("zombie.getVariableString") then return nil, "capability unavailable" end
    local ok, value = GameAdapter.call(zombie, "getVariableString", name)
    if not ok then return nil, value end
    return value
end

return AnimationAdapter
