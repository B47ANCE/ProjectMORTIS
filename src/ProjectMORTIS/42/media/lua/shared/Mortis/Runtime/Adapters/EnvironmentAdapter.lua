local Capabilities = require "Mortis/API/Capabilities"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local EnvironmentAdapter = {}

function EnvironmentAdapter.getSquare(zombie)
    if not Capabilities.has("zombie.getSquare") then return nil, "capability unavailable" end
    local ok, value = GameAdapter.call(zombie, "getSquare")
    if not ok then return nil, value end
    return value
end

function EnvironmentAdapter.getPosition(zombie)
    local keys = { "getX", "getY", "getZ" }
    local values = {}
    for i, method in ipairs(keys) do
        if not Capabilities.has("zombie." .. method) then return nil, "capability unavailable: " .. method end
        local ok, value = GameAdapter.call(zombie, method)
        if not ok then return nil, value end
        values[i] = value
    end
    return { x = values[1], y = values[2], z = values[3] }
end

function EnvironmentAdapter.isOutside(zombie)
    local square, reason = EnvironmentAdapter.getSquare(zombie)
    if not square then return nil, reason end
    local ok, value = GameAdapter.call(square, "isOutside")
    if not ok then return nil, value end
    return value == true
end

return EnvironmentAdapter
