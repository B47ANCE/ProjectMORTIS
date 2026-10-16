local Capabilities = require "Mortis/API/Capabilities"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local CombatAdapter = {}

function CombatAdapter.getHealth(zombie)
    if not Capabilities.has("zombie.getHealth") then return nil, "capability unavailable" end
    local ok, value = GameAdapter.call(zombie, "getHealth")
    if not ok then return nil, value end
    return value
end

function CombatAdapter.setHealth(zombie, value)
    if not Capabilities.has("zombie.setHealth") then return false, "capability unavailable" end
    return GameAdapter.call(zombie, "setHealth", value)
end

function CombatAdapter.isDead(zombie)
    if not Capabilities.has("zombie.isDead") then return nil, "capability unavailable" end
    local ok, value = GameAdapter.call(zombie, "isDead")
    if not ok then return nil, value end
    return value == true
end

return CombatAdapter
