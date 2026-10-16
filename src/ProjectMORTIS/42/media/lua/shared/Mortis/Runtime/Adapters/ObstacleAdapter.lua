local Capabilities = require "Mortis/API/Capabilities"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local ObstacleAdapter = {}

function ObstacleAdapter.tryThump(zombie, square)
    if not Capabilities.has("zombie.tryThump") then return false, "capability unavailable" end
    return GameAdapter.call(zombie, "tryThump", square)
end

return ObstacleAdapter
