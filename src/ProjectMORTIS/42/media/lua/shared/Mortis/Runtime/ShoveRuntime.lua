local Balance = require "Mortis/Runtime/BalanceRuntime"
local Collision = require "Mortis/Runtime/Adapters/CollisionAdapter"
local Environment = require "Mortis/Runtime/Adapters/PhysicalEnvironmentAdapter"
local Authority = require "Mortis/Runtime/Authority"
local Util = require "Mortis/Core/Util"

local Shove = {}

local function tracked()
    local Mortis = rawget(_G, "Mortis")
    return Mortis and Mortis.Engine and Mortis.Engine.listTracked and Mortis.Engine.listTracked() or {}
end

local function direction(attacker, target, context)
    if context and context.directionX and context.directionY then
        local x, y = tonumber(context.directionX), tonumber(context.directionY)
        local mag = math.sqrt(x*x + y*y)
        if mag > 0 then return x/mag, y/mag end
    end

    local ax, ay = Environment.position(attacker)
    local tx, ty = Environment.position(target)
    if ax and tx then
        local dx, dy = tx-ax, ty-ay
        local mag = math.sqrt(dx*dx + dy*dy)
        if mag > 0.0001 then return dx/mag, dy/mag end
    end
    return 0, 0
end

local function candidatesBehind(origin, dx, dy, range, width, exclude)
    local ox, oy, oz = Collision.position(origin)
    if not ox then return {} end
    local result = {}
    for _, candidate in ipairs(tracked()) do
        if candidate ~= origin and candidate ~= exclude then
            local x, y, z = Collision.position(candidate)
            if x and math.abs(z-oz) < 0.25 then
                local rx, ry = x-ox, y-oy
                local forward = rx*dx + ry*dy
                local lateral = math.abs(rx*(-dy) + ry*dx)
                if forward > 0 and forward <= range and lateral <= width then
                    result[#result+1] = { entity=candidate, forward=forward, lateral=lateral }
                end
            end
        end
    end
    table.sort(result, function(a,b) return a.forward < b.forward end)
    return result
end

function Shove.computeImpulse(attacker, context)
    context = context or {}
    local impulse = tonumber(context.impulse)
    if impulse then return math.max(0, impulse) end

    -- Strength is optional metadata. Vanilla shove effectiveness remains the
    -- primary source; this term only scales propagation when a trusted caller
    -- provides it.
    local strength = tonumber(context.strength)
    local base = tonumber(context.baseImpulse) or 1.0
    if strength then base = base * (0.75 + math.max(0, strength) * 0.05) end
    return base
end

function Shove.propagate(attacker, primaryTarget, context)
    context = context or {}
    if not Authority.canWriteCanonicalState(primaryTarget) then return false, "non-authority" end

    local dx, dy = direction(attacker, primaryTarget, context)
    if dx == 0 and dy == 0 then return false, "direction unavailable" end

    local maxChain = math.max(0, math.floor(tonumber(context.maxChain) or 3))
    local range = tonumber(context.chainSpacing) or 1.15
    local width = tonumber(context.chainWidth) or 0.55
    local decay = math.max(0, math.min(1, tonumber(context.impulseDecay) or 0.65))
    local impulse = Shove.computeImpulse(attacker, context)
    local current = primaryTarget
    local previous = attacker
    local chain = {}

    for index=1,maxChain do
        local nearby = candidatesBehind(current, dx, dy, range, width, previous)
        local nextHit = nearby[1]
        if not nextHit then break end

        impulse = impulse * decay
        if impulse <= 0.05 then break end

        local chance = math.min(0.95, math.max(0, impulse * (tonumber(context.tripChancePerImpulse) or 0.55)))
        local ok, result = Balance.attempt(nextHit.entity, Balance.Causes.SHOVE_CHAIN, {
            chanceOverride = chance,
            impact = impulse,
            fallOnFront = false,
            sourceEntity = current,
            chainIndex = index,
        })
        chain[#chain+1] = {
            entity = nextHit.entity,
            distance = nextHit.forward,
            impulse = impulse,
            tripped = ok,
            result = result,
        }

        previous = current
        current = nextHit.entity
        if not ok and context.continueThroughStanding ~= true then break end
    end

    local Mortis = rawget(_G, "Mortis")
    if Mortis and Mortis.Events then
        Mortis.Events:emit("ShoveChainResolved", primaryTarget, chain, context)
    end

    return true, chain
end

return Shove
