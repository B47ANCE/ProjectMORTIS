local AttackKinds = require "Mortis/API/AttackKinds"
local Anatomy = require "Mortis/Runtime/AnatomyRuntime"
local Trauma = require "Mortis/Runtime/TraumaRuntime"
local Balance = require "Mortis/Runtime/BalanceRuntime"
local ShoveRuntime = require "Mortis/Runtime/ShoveRuntime"
local Collision = require "Mortis/Runtime/Adapters/CollisionAdapter"
local Environment = require "Mortis/Runtime/Adapters/PhysicalEnvironmentAdapter"
local Providers = require "Mortis/API/PhysicalInteractionProviders"
local Authority = require "Mortis/Runtime/Authority"
local Scheduler = require "Mortis/Core/Scheduler"
local Random = require "Mortis/Core/Random"

local Runtime = {}

local shoveCooldown = setmetatable({}, { __mode = "k" })
local stompCooldown = setmetatable({}, { __mode = "k" })

local function emit(name, ...)
    local Mortis = rawget(_G, "Mortis")
    if Mortis and Mortis.Events then Mortis.Events:emit(name, ...) end
end

local function canonical(entity)
    return Authority.canWriteCanonicalState(entity)
end

local function cooldownReady(map, entity, ticks)
    local frame = Scheduler.frame or 0
    local last = map[entity] or -1000000
    if frame < last + ticks then return false end
    map[entity] = frame
    return true
end

function Runtime.applyShove(target, attacker, context)
    context = context or {}
    if not canonical(target) then return false, "non-authority" end
    if not cooldownReady(shoveCooldown, target, tonumber(context.cooldownTicks) or 12) then
        return false, "shove cooldown"
    end

    local result = {
        sourceKind = AttackKinds.SHOVE,
        attacker = attacker,
        target = target,
        damage = tonumber(context.damage) or 0,
        tripAttempted = false,
        tripped = false,
        environment = {},
    }

    -- Small generic impact trauma can be requested when a trustworthy shove
    -- damage value exists. If vanilla reports zero, no anatomical damage is
    -- invented.
    if result.damage > 0 then
        local ok, traumaResult = Trauma.apply(target, {
            region = context.region or "torso",
            channel = "impact",
            magnitude = result.damage * (tonumber(context.damageToTrauma) or 10),
            attacker = attacker,
            source = AttackKinds.SHOVE,
            flags = { shove = true },
        })
        result.traumaApplied = ok
        result.trauma = traumaResult
    end

    -- M.O.R.T.I.S. can request loss-of-balance. Vanilla remains responsible
    -- for native knockdown, movement, wall/fence traversal, falling, landing,
    -- and fall damage after the transition starts.
    local tripChance = tonumber(context.tripChance)
    if tripChance and tripChance > 0 then
        result.tripAttempted = true
        local ok, tripResult = Balance.attempt(target, Balance.Causes.SHOVE, {
            chanceOverride = math.min(1, math.max(0, tripChance)),
            impact = tonumber(context.impulse) or 0,
            fallOnFront = context.fallOnFront == true,
            sourceEntity = attacker,
        })
        result.tripped = ok
        result.tripResult = tripResult
        result.tripMode = ok and tripResult.tripMode or nil
    end

    if context.domino ~= false and Settings.bool("EnableShoveDomino") then
        context.maxChain = context.maxChain or Settings.number("ShoveDominoMaxChain")
        context.impulseDecay = context.impulseDecay or Settings.number("ShoveDominoImpulseDecay")
        local chainOk, chain = ShoveRuntime.propagate(attacker, target, context)
        result.dominoResolved = chainOk
        result.dominoChain = chain
    end

    local providerContext = {
        kind = AttackKinds.SHOVE,
        attacker = attacker,
        target = target,
        context = context,
    }
    result.environment = Providers.inspect(providerContext)

    emit("LivingEntityShoved", target, result)
    return true, result
end

function Runtime.applyStomp(target, attacker, bodyPart, damage, context)
    context = context or {}
    if not canonical(target) then return false, "non-authority" end
    if not cooldownReady(stompCooldown, target, tonumber(context.cooldownTicks) or 6) then
        return false, "stomp cooldown"
    end

    local prone = Environment.isProne(target)
    if not prone and context.requireProne ~= false then
        return false, "target is not prone"
    end

    local anatomy = Anatomy.ensure(target)
    if not anatomy then return false, "target has no anatomy" end

    local region = bodyPart or context.region or "torso"
    local magnitude = math.max(0, tonumber(damage) or 0) * (tonumber(context.damageToTrauma) or 30)

    local ok, result = Trauma.apply(target, {
        region = region,
        bodyPart = bodyPart,
        channel = "crush",
        magnitude = magnitude,
        crushPower = magnitude * (tonumber(context.crushPowerMultiplier) or 1.15),
        attacker = attacker,
        source = AttackKinds.STOMP,
        flags = { stomp = true, groundedTarget = prone == true },
    })

    if ok then
        result.sourceKind = AttackKinds.STOMP
        emit("LivingEntityStomped", target, result)
    end
    return ok, result
end

-- A prone living entity is a trip obstacle. This does not push coordinates;
-- it only requests the same native trip/knockdown bridge used by C4.
function Runtime.tryTripOverProne(movingEntity, proneEntity, context)
    context = context or {}
    if not canonical(movingEntity) then return false, "non-authority" end

    local prone = Environment.isProne(proneEntity)
    if not prone then return false, "obstacle entity is not prone" end

    local collision = Collision.makeContext(
        movingEntity, proneEntity,
        { radius = tonumber(context.movingRadius) or 0.32 },
        { radius = tonumber(context.proneRadius) or 0.40 },
        context.velocityMoving or { x=0, y=0, speed=0 },
        context.velocityProne or { x=0, y=0, speed=0 }
    )
    if not collision then return false, "not in trip-over contact range" end

    local chance = tonumber(context.tripChance) or 0.55
    local ok, balanceResult = Balance.attempt(movingEntity, Balance.Causes.PRONE_ENTITY, {
        chanceOverride = math.min(1, math.max(0, chance)),
        impact = collision.relativeSpeed,
        penetration = collision.penetration,
        fallOnFront = true,
        sourceEntity = proneEntity,
        groupThrottleKey = context.groupThrottleKey or tostring(proneEntity),
        groupCooldownTicks = tonumber(context.groupCooldownTicks) or 120,
    })
    if ok then
        local result = {
            sourceKind = "prone-entity",
            mover = movingEntity,
            obstacle = proneEntity,
            collision = collision,
            tripMode = balanceResult.tripMode,
            balance = balanceResult,
        }
        emit("LivingEntityTrippedOverProne", movingEntity, result)
        return true, result
    end
    return false, balanceResult
end

return Runtime
