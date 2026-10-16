local Balance = require "Mortis/Runtime/BalanceRuntime"
local Environment = require "Mortis/Runtime/Adapters/PhysicalEnvironmentAdapter"
local Corpse = require "Mortis/Runtime/Adapters/CorpseAdapter"
local State = require "Mortis/Runtime/Adapters/StateAdapter"
local Collision = require "Mortis/Runtime/Adapters/CollisionAdapter"

local Movement = {}

local previousPosition = setmetatable({}, { __mode = "k" })

local function velocity(entity)
    local x, y = Collision.position(entity)
    if x == nil then return 0,nil,nil end
    local prior = previousPosition[entity]
    previousPosition[entity] = { x=x, y=y }
    if not prior then return 0,x,y end
    local dx, dy = x-prior.x, y-prior.y
    return math.sqrt(dx*dx + dy*dy),x,y
end

function Movement.update(entity)
    if entity == nil then return 0 end
    local speed,x,y = velocity(entity)
    if speed <= 0.001 then return 0 end

    local attempts = 0
    local state = State.getNativeStateKey(entity)
    local lowerState = string.lower(tostring(state or ""))

    if lowerState:find("lunge", 1, true) then
        attempts = attempts + 1
        Balance.attempt(entity, Balance.Causes.LUNGE, {
            impact = speed,
            allowBusyReasons = { lunge=true, attack=true },
            fallOnFront = true,
        })
    end

    local onStairs = Environment.isOnStairs(entity)
    if onStairs == true then
        attempts = attempts + 1
        Balance.attempt(entity, Balance.Causes.STAIRS, {
            impact = speed * 0.5,
            fallOnFront = true,
        })
    end

    local corpses = Corpse.under(entity)
    if #corpses > 0 then
        attempts = attempts + 1
        Balance.attempt(entity, Balance.Causes.CORPSE, {
            impact = speed,
            obstacleCount = #corpses,
            fallOnFront = true,
            groupThrottleKey = string.format("corpse:%d:%d",math.floor(x or 0),math.floor(y or 0)),
            groupCooldownTicks = 120,
        })
    end

    -- Random movement trips are intentionally centralized here so they cannot
    -- stack with independent collision/stair/corpse rolls without the shared
    -- BalanceRuntime cooldown.
    attempts = attempts + 1
    Balance.attempt(entity, Balance.Causes.RANDOM_MOVEMENT, {
        impact = speed * 0.15,
        fallOnFront = true,
    })

    return attempts
end

return Movement
