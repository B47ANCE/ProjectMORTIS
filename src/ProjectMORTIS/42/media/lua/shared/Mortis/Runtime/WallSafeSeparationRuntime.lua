local Response = require "Mortis/Runtime/Adapters/CollisionResponseAdapter"
local Collision = require "Mortis/Runtime/Adapters/CollisionAdapter"
local Environment = require "Mortis/Runtime/Adapters/PhysicalEnvironmentAdapter"
local Settings = require "Mortis/Runtime/PhysicalSettings"
local Authority = require "Mortis/Runtime/Authority"

local Separation = {}

local function candidateSquare(entity, dx, dy)
    local x, y, z = Collision.position(entity)
    if x == nil then return nil end
    local current = Environment.square(entity)
    if not current then return nil end

    local cell = nil
    local okCell, c = pcall(function() return current:getCell() end)
    if okCell then cell = c end
    if not cell and type(getCell) == "function" then
        local ok, value = pcall(getCell)
        if ok then cell = value end
    end
    if not cell then return nil end

    local tx, ty = x + dx, y + dy
    local okSq, square = pcall(function()
        return cell:getGridSquare(math.floor(tx), math.floor(ty), math.floor(z))
    end)
    if not okSq then return nil end
    return square
end

local function safeCorrection(entity, dx, dy)
    local current = Environment.square(entity)
    local target = candidateSquare(entity, dx, dy)
    if not current or not target then return false, "target square unavailable" end

    local support = Environment.hasSupport(target)
    if support == false then return false, "would move into unsupported square" end

    local obstacle = Environment.inspectLowObstacleBetween(current, target)
    if obstacle.known and obstacle.blocked == true then
        return false, "blocked square transition"
    end

    return true
end

function Separation.resolvePair(a, b, collisionContext, profileA, profileB)
    if not Settings.bool("EnableSoftSeparation") then return false, "disabled" end
    if not Authority.canWriteCanonicalState(a) or not Authority.canWriteCanonicalState(b) then
        return false, "non-authority"
    end

    local plan = Response.plan(
        collisionContext,
        tonumber(profileA and profileA.mass) or 1,
        tonumber(profileB and profileB.mass) or 1
    )
    if not plan then return false, "no correction required" end

    local strength = math.max(0, Settings.number("SoftSeparationStrength"))
    local maxCorrection = math.max(0.001, Settings.number("SoftSeparationMaxCorrection"))

    local function clamp(value)
        value = value * strength
        if value > maxCorrection then return maxCorrection end
        if value < -maxCorrection then return -maxCorrection end
        return value
    end

    plan.ax, plan.ay = clamp(plan.ax), clamp(plan.ay)
    plan.bx, plan.by = clamp(plan.bx), clamp(plan.by)

    local safeA, reasonA = safeCorrection(a, plan.ax, plan.ay)
    local safeB, reasonB = safeCorrection(b, plan.bx, plan.by)
    if not safeA or not safeB then
        return false, "unsafe correction: " .. tostring(reasonA or reasonB)
    end

    -- This path is intentionally reachable only when the admin explicitly
    -- enables the experimental sandbox option. The adapter itself still
    -- requires runtimeVerified=true.
    local okA, modeA = Response.apply(a, plan.ax, plan.ay, { runtimeVerified=true })
    local okB, modeB = Response.apply(b, plan.bx, plan.by, { runtimeVerified=true })

    if okA and okB then
        local Mortis = rawget(_G, "Mortis")
        if Mortis and Mortis.Events then
            Mortis.Events:emit("ZombieSoftSeparated", a, b, plan)
        end
        return true, plan
    end
    return false, "separation apply failed: " .. tostring(modeA) .. " / " .. tostring(modeB)
end

return Separation
