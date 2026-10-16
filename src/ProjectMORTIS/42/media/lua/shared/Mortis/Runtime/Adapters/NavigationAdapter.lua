local Capabilities = require "Mortis/API/Capabilities"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local NavigationAdapter = {}

function NavigationAdapter.pathToCharacter(zombie, target)
    if not Capabilities.has("zombie.pathToCharacter") then return false, "capability unavailable" end
    return GameAdapter.call(zombie, "pathToCharacter", target)
end

function NavigationAdapter.pathToLocation(zombie, x, y, z)
    if not Capabilities.has("zombie.pathToLocationF") then return false, "capability unavailable" end
    return GameAdapter.call(zombie, "pathToLocationF", x, y, z)
end

function NavigationAdapter.wander(zombie)
    if not Capabilities.has("zombie.Wander") then return false, "capability unavailable" end
    return GameAdapter.call(zombie, "Wander")
end

return NavigationAdapter
