local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"
local Capabilities = require "Mortis/API/Capabilities"

local CollisionAdapter = {}

local function coord(zombie, method)
    if not Capabilities.has("zombie." .. method) then return nil end
    local ok, value = GameAdapter.call(zombie, method)
    if not ok then return nil end
    return tonumber(value)
end

function CollisionAdapter.position(zombie)
    local x, y, z = coord(zombie, "getX"), coord(zombie, "getY"), coord(zombie, "getZ")
    if x == nil or y == nil or z == nil then return nil end
    return x, y, z
end

function CollisionAdapter.makeContext(a, b, profileA, profileB, velocityA, velocityB)
    local ax, ay, az = CollisionAdapter.position(a)
    local bx, by, bz = CollisionAdapter.position(b)
    if ax == nil or bx == nil or math.abs(az - bz) > 0.25 then return nil end

    local dx, dy = bx - ax, by - ay
    local distance = math.sqrt(dx * dx + dy * dy)
    local combined = (tonumber(profileA.radius) or 0.32) + (tonumber(profileB.radius) or 0.32)
    if distance > combined then return nil end

    velocityA = velocityA or { x = 0, y = 0, speed = 0 }
    velocityB = velocityB or { x = 0, y = 0, speed = 0 }
    local rvx, rvy = velocityA.x - velocityB.x, velocityA.y - velocityB.y
    local relativeSpeed = math.sqrt(rvx * rvx + rvy * rvy)
    local nx, ny = 0, 0
    if distance > 0.0001 then nx, ny = dx / distance, dy / distance end

    return {
        distance = distance,
        penetration = math.max(0, combined - distance),
        combinedRadius = combined,
        normalX = nx,
        normalY = ny,
        relativeSpeed = relativeSpeed,
        velocityA = velocityA,
        velocityB = velocityB,
    }
end

return CollisionAdapter
