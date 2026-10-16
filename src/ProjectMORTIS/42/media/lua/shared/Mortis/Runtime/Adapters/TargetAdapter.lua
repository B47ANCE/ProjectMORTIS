local Capabilities = require "Mortis/API/Capabilities"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local TargetAdapter = {}

function TargetAdapter.get(zombie)
    if not Capabilities.has("zombie.getTarget") then return nil, "capability unavailable" end
    local ok, target = GameAdapter.call(zombie, "getTarget")
    if not ok then return nil, target end
    return target
end

function TargetAdapter.set(zombie, target)
    if not Capabilities.has("zombie.setTarget") then return false, "capability unavailable" end
    local ok, result = GameAdapter.call(zombie, "setTarget", target)
    return ok, result
end

function TargetAdapter.clear(zombie)
    return TargetAdapter.set(zombie, nil)
end

function TargetAdapter.isVisible(zombie)
    if not Capabilities.has("zombie.isTargetVisible") then return nil, "capability unavailable" end
    local ok, visible = GameAdapter.call(zombie, "isTargetVisible")
    if not ok then return nil, visible end
    return visible == true
end

return TargetAdapter
