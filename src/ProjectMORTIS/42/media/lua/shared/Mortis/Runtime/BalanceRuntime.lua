local BalanceProfiles = require "Mortis/API/BalanceProfiles"
local Trip = require "Mortis/Runtime/Adapters/TripAdapter"
local State = require "Mortis/Runtime/Adapters/StateAdapter"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"
local Authority = require "Mortis/Runtime/Authority"
local Identity = require "Mortis/Runtime/Identity"
local Random = require "Mortis/Core/Random"
local Scheduler = require "Mortis/Core/Scheduler"
local Util = require "Mortis/Core/Util"
local Settings = require "Mortis/Runtime/PhysicalSettings"

local Balance = {}

Balance.Causes = {
    COLLISION = "collision",
    PRONE_ENTITY = "prone-entity",
    CORPSE = "corpse",
    RANDOM_MOVEMENT = "random-movement",
    STAIRS = "stairs",
    LUNGE = "lunge",
    SHOVE = "shove",
    SHOVE_CHAIN = "shove-chain",
    MELEE_HIT = "melee-hit",
    PROJECTILE_HIT = "projectile-hit",
    PLAYER_COLLISION = "player-collision",
}

local lastAnyTrip = setmetatable({}, { __mode = "k" })
local lastCauseTrip = setmetatable({}, { __mode = "k" })
local lastCauseAttempt = setmetatable({}, { __mode = "k" })
local lastGroupAttempt = {}


local CAUSE_SETTING = {
    ["collision"] = "EnableCollisionTrips",
    ["prone-entity"] = "EnableProneTrips",
    ["corpse"] = "EnableCorpseTrips",
    ["random-movement"] = "EnableRandomTrips",
    ["stairs"] = "EnableStairTrips",
    ["lunge"] = "EnableLungeTrips",
    ["player-collision"] = "EnablePlayerCollisionTrips",
}
local CAUSE_MULTIPLIER = {
    ["collision"] = "CollisionTripChanceMultiplier",
    ["prone-entity"] = "ProneTripChanceMultiplier",
    ["corpse"] = "CorpseTripChanceMultiplier",
    ["stairs"] = "StairTripChanceMultiplier",
    ["lunge"] = "LungeTripChanceMultiplier",
    ["shove"] = "ShoveTripChanceMultiplier",
    ["shove-chain"] = "ShoveTripChanceMultiplier",
}

local function causeEnabled(cause)
    local setting = CAUSE_SETTING[cause]
    return setting == nil or Settings.bool(setting)
end

local function clamp01(value)
    return math.max(0, math.min(1, tonumber(value) or 0))
end

local function defaultProfile()
    return BalanceProfiles.get("Mortis.DefaultZombieBalance")
end

local function profileFor(entity)
    local typeDef = Identity.getType(entity)
    local ref = typeDef and (typeDef.balance or typeDef.balanceProfile) or nil
    if type(ref) == "string" then
        return BalanceProfiles.get(ref) or defaultProfile()
    elseif type(ref) == "table" then
        if ref.profile then
            local base = BalanceProfiles.get(ref.profile)
            return base and Util.merge(base, ref) or ref
        end
        return ref
    end
    return defaultProfile()
end

local function speedClass(entity, context)
    if context and context.speedClass then return context.speedClass end

    local crawling = State.isCrawling(entity)
    if crawling == true then return "crawler" end

    local okWalk, walk = GameAdapter.call(entity, "getWalkType")
    if okWalk and walk ~= nil then
        local lower = string.lower(tostring(walk))
        if lower:find("sprint", 1, true) then return "sprinter" end
        if lower:find("fast", 1, true) then return "fast" end
        if lower:find("shambl", 1, true) then return "shambler" end
    end
    return "unknown"
end

local function stateMultiplier(entity, profile)
    local snapshot = State.snapshot(entity)
    local key = string.lower(tostring(snapshot.nativeState or ""))
    for token, multiplier in pairs(profile.stateMultipliers or {}) do
        if key:find(string.lower(tostring(token)), 1, true) then
            return tonumber(multiplier) or 1
        end
    end
    return 1
end

function Balance.getProfile(entity)
    return profileFor(entity)
end

function Balance.computeChance(entity, cause, context)
    context = context or {}
    local profile = context.profile or profileFor(entity)
    if not profile or profile.enabled == false then return 0, profile end

    if not causeEnabled(cause) then return 0, profile end

    local base = context.chanceOverride
    if base == nil then base = (profile.causes or {})[cause] or 0 end
    base = tonumber(base) or 0

    base = base * Settings.number("GlobalTripChanceMultiplier")
    if CAUSE_MULTIPLIER[cause] then base=base*Settings.number(CAUSE_MULTIPLIER[cause]) end
    if cause == Balance.Causes.RANDOM_MOVEMENT then
        base = base * Settings.number("RandomTripChanceMultiplier")
    end

    local impact = tonumber(context.impact) or tonumber(context.relativeSpeed) or 0
    local penetration = tonumber(context.penetration) or 0

    local chance = base
        + impact * (tonumber(profile.impactChanceScale) or 0)
        + penetration * (tonumber(profile.penetrationChanceScale) or 0)

    local speed = speedClass(entity, context)
    chance = chance * (tonumber((profile.speedMultipliers or {})[speed]) or 1)
    chance = chance * stateMultiplier(entity, profile)

    local mass = tonumber(context.mass) or tonumber(context.victimMass) or 1
    local resistance = math.max(0.05, (tonumber(profile.massResistance) or 1) * mass)
    chance = chance / resistance

    return clamp01(chance), profile, speed
end

function Balance.canAttempt(entity, cause, profile, context)
    if not Authority.canWriteCanonicalState(entity) then return false, "non-authority" end
    profile = profile or profileFor(entity)
    if not profile or profile.enabled == false then return false, "balance disabled" end

    local frame = Scheduler.frame or 0
    local cooldownMultiplier=math.max(0,Settings.number("TripCooldownMultiplier"))
    local globalCooldown = (tonumber(profile.globalCooldownTicks) or 45)*cooldownMultiplier
    if frame < (lastAnyTrip[entity] or -1000000) + globalCooldown then
        return false, "global balance cooldown"
    end

    local perEntity = lastCauseTrip[entity]
    local last = perEntity and perEntity[cause] or -1000000
    local causeCooldown = (tonumber(profile.causeCooldownTicks) or 75)*cooldownMultiplier
    if frame < last + causeCooldown then
        return false, "cause cooldown"
    end
    local perEntityAttempt = lastCauseAttempt[entity]
    local lastAttempt = perEntityAttempt and perEntityAttempt[cause] or -1000000
    local attemptCooldown = (tonumber(profile.attemptCooldownTicks) or 30)*cooldownMultiplier
    if frame < lastAttempt + attemptCooldown then
        return false, "cause attempt cooldown"
    end
    local groupKey = context and context.groupThrottleKey or nil
    if groupKey ~= nil then
        groupKey = tostring(cause)..":"..tostring(groupKey)
        local groupCooldown = (tonumber(context.groupCooldownTicks)
            or tonumber(profile.groupCooldownTicks) or 90)
            * math.max(0,Settings.number("GroupPileThrottleMultiplier"))
        if frame < (lastGroupAttempt[groupKey] or -1000000) + groupCooldown then
            return false, "group pile cooldown"
        end
    end
    return true
end

function Balance.attempt(entity, cause, context)
    context = context or {}
    local chance, profile, speed = Balance.computeChance(entity, cause, context)
    if chance <= 0 then return false, "zero chance" end
    local allowed, reason = Balance.canAttempt(entity, cause, profile, context)
    if not allowed then return false, reason end
    local frame = Scheduler.frame or 0
    lastCauseAttempt[entity] = lastCauseAttempt[entity] or {}
    lastCauseAttempt[entity][cause] = frame
    if context.groupThrottleKey ~= nil then
        lastGroupAttempt[tostring(cause)..":"..tostring(context.groupThrottleKey)] = frame
    end
    if not Random.chance(entity, chance) then return false, "balance roll failed" end

    local allowBusy = context.allowBusyReasons
    if cause == Balance.Causes.LUNGE and allowBusy == nil then
        allowBusy = { lunge=true, attack=true }
    end

    local ok, mode = Trip.trip(entity, {
        fallOnFront = context.fallOnFront,
        allowBusyReasons = allowBusy,
        preferredOutcome = context.preferredOutcome or
            (Settings.bool("EnableRagdollTrips") and "ragdoll" or profile.tripOutcome),
    })
    if not ok then return false, mode end

    lastAnyTrip[entity] = frame
    lastCauseTrip[entity] = lastCauseTrip[entity] or {}
    lastCauseTrip[entity][cause] = frame

    local result = {
        entity = entity,
        cause = cause,
        chance = chance,
        profileId = profile.id,
        speedClass = speed,
        tripMode = mode,
        context = Util.deepCopy(context),
    }

    local Mortis = rawget(_G, "Mortis")
    if Mortis and Mortis.Events then
        Mortis.Events:emit("BalanceFailed", entity, result)
    end
    return true, result
end

function Balance.forceTrip(entity, cause, context)
    context = context or {}
    context.chanceOverride = 1
    return Balance.attempt(entity, cause or "forced", context)
end

function Balance.reset(entity)
    if entity then
        lastAnyTrip[entity] = nil
        lastCauseTrip[entity] = nil
        lastCauseAttempt[entity] = nil
    else
        lastAnyTrip = setmetatable({}, { __mode = "k" })
        lastCauseTrip = setmetatable({}, { __mode = "k" })
        lastCauseAttempt = setmetatable({}, { __mode = "k" })
        lastGroupAttempt = {}
    end
end

return Balance
