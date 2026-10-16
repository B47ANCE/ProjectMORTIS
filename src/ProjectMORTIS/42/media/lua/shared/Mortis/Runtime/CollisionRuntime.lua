local CollisionProfiles = require "Mortis/API/CollisionProfiles"
local Collision = require "Mortis/Runtime/Adapters/CollisionAdapter"
local Balance = require "Mortis/Runtime/BalanceRuntime"
local State = require "Mortis/Runtime/Adapters/StateAdapter"
local Identity = require "Mortis/Runtime/Identity"
local Random = require "Mortis/Core/Random"
local Scheduler = require "Mortis/Core/Scheduler"
local FaultIsolation = require "Mortis/Core/FaultIsolation"
local Behaviors = require "Mortis/API/Behaviors"
local Traits = require "Mortis/API/Traits"
local Context = require "Mortis/Runtime/Context"
local Separation = require "Mortis/Runtime/WallSafeSeparationRuntime"
local Util = require "Mortis/Core/Util"

local Runtime = {}
local lastPosition = setmetatable({}, { __mode = "k" })
local pairCooldown = {}

local function profileFor(typeDef)
    if typeDef then
        local ref = typeDef.collision or typeDef.collisionProfile
        if type(ref) == "string" then
            return CollisionProfiles.get(ref) or CollisionProfiles.get("Mortis.DefaultZombieCollision")
        elseif type(ref) == "table" then
            if ref.profile then
                local base = CollisionProfiles.get(ref.profile)
                if base then
                    local overrides = Util.deepCopy(ref)
                    overrides.profile = nil
                    return Util.merge(base, overrides)
                end
            end
            return ref
        end
    end
    return CollisionProfiles.get("Mortis.DefaultZombieCollision")
end

local function objectKey(zombie)
    return Identity.getStableId(zombie) or tostring(zombie)
end

local function pairKey(a, b)
    local ka, kb = objectKey(a), objectKey(b)
    if ka < kb then return ka .. "|" .. kb end
    return kb .. "|" .. ka
end

local function velocityFor(zombie, x, y)
    local prior = lastPosition[zombie]
    local frame = Scheduler.frame or 0
    local v = { x = 0, y = 0, speed = 0 }
    if prior and frame > prior.frame then
        local dt = frame - prior.frame
        v.x, v.y = (x - prior.x) / dt, (y - prior.y) / dt
        v.speed = math.sqrt(v.x * v.x + v.y * v.y)
    end
    lastPosition[zombie] = { x = x, y = y, frame = frame }
    return v
end

local function eachTrait(typeDef, callback)
    if type(typeDef) ~= "table" then return end
    for _, entry in ipairs(typeDef.traits or {}) do
        local id, config
        if type(entry) == "string" then
            id, config = entry, {}
        else
            id, config = entry.id, entry.config or {}
        end
        local trait = Traits.get(id)
        if trait then callback(id, trait, config) end
    end
end

local function emitCollision(zombie, other, typeDef, collisionContext)
    local ctx = Context.create(zombie, typeDef)
    eachTrait(typeDef, function(id, trait, config)
        if trait.onCollision then
            FaultIsolation.call("trait:" .. id, "onCollision", trait.onCollision,
                zombie, other, collisionContext, config, typeDef, ctx)
        end
    end)
    for _, behaviorId in ipairs(type(typeDef)=="table" and typeDef.behaviors or {}) do
        local behavior = Behaviors.get(behaviorId)
        if behavior and behavior.onCollision then
            FaultIsolation.call("behavior:" .. behaviorId, "onCollision",
                behavior.onCollision, ctx, other, collisionContext)
        end
    end
    local Mortis = rawget(_G, "Mortis")
    if Mortis and Mortis.Events then
        Mortis.Events:emit("ZombieCollision", zombie, other, collisionContext, typeDef)
    end
end

local function emitTrip(zombie, other, typeDef, collisionContext, mode)
    local ctx = Context.create(zombie, typeDef)
    local tripContext = Util.deepCopy(collisionContext)
    tripContext.tripMode = mode
    eachTrait(typeDef, function(id, trait, config)
        if trait.onTrip then
            FaultIsolation.call("trait:" .. id, "onTrip", trait.onTrip,
                zombie, other, tripContext, config, typeDef, ctx)
        end
    end)
    for _, behaviorId in ipairs(type(typeDef)=="table" and typeDef.behaviors or {}) do
        local behavior = Behaviors.get(behaviorId)
        if behavior and behavior.onTrip then
            FaultIsolation.call("behavior:" .. behaviorId, "onTrip",
                behavior.onTrip, ctx, other, tripContext)
        end
    end
    local Mortis = rawget(_G, "Mortis")
    if Mortis and Mortis.Events then
        Mortis.Events:emit("ZombieTripped", zombie, other, tripContext, typeDef)
    end
end

local function attemptTrip(victim, other, victimType, victimProfile, otherProfile, collisionContext)
    local trip = victimProfile.trip or {}
    local otherTrip = otherProfile.trip or {}
    if trip.enabled ~= true or trip.canBeTripped == false or otherTrip.canTripOthers == false then return false end

    local impact = collisionContext.relativeSpeed + collisionContext.penetration * 0.25
    if impact < (tonumber(trip.minImpact) or 0) then return false end

    local ok, result = Balance.attempt(victim, Balance.Causes.COLLISION, {
        impact = impact,
        relativeSpeed = collisionContext.relativeSpeed,
        penetration = collisionContext.penetration,
        victimMass = tonumber(victimProfile.mass) or 1,
        sourceEntity = other,
        fallOnFront = (collisionContext.velocityA.speed or 0) >=
                      (collisionContext.velocityB.speed or 0),
        groupThrottleKey = collisionContext.groupThrottleKey,
        groupCooldownTicks = 90,
    })
    if ok then
        emitTrip(victim, other, victimType, collisionContext, result.tripMode)
    end
    return ok
end

function Runtime.update(tracked)
    if type(tracked) ~= "table" or #tracked == 0 then return 0 end

    -- Collision outcomes/trip rolls are canonical only on SP/host/server.
    if type(isClient) == "function" and isClient() and
       not (type(isServer) == "function" and isServer()) then
        return 0
    end

    local entries, maxRadius = {}, 0.32
    for _, zombie in ipairs(tracked) do
        local typeDef = Identity.getType(zombie)
        local profile = profileFor(typeDef)
        if profile and profile.enabled ~= false then
            local x, y, z = Collision.position(zombie)
            if x ~= nil then
                local v = velocityFor(zombie, x, y)
                entries[#entries + 1] = {
                    zombie=zombie, typeDef=typeDef, profile=profile,
                    x=x, y=y, z=z, velocity=v
                }
                maxRadius = math.max(maxRadius, tonumber(profile.radius) or 0.32)
            end
        end
    end

    local cellSize = math.max(0.5, maxRadius * 2)
    local buckets = {}
    local function bkey(cx, cy, z)
        return tostring(cx) .. ":" .. tostring(cy) .. ":" .. tostring(math.floor(z + 0.5))
    end
    for _, e in ipairs(entries) do
        e.cx, e.cy = math.floor(e.x / cellSize), math.floor(e.y / cellSize)
        local k = bkey(e.cx, e.cy, e.z)
        buckets[k] = buckets[k] or {}
        buckets[k][#buckets[k] + 1] = e
    end

    local seen, collisions, frame = {}, 0, Scheduler.frame or 0
    for _, a in ipairs(entries) do
        for ox=-1,1 do
            for oy=-1,1 do
                local bucket = buckets[bkey(a.cx+ox, a.cy+oy, a.z)]
                if bucket then
                    for _, b in ipairs(bucket) do
                        if a.zombie ~= b.zombie then
                            local pk = pairKey(a.zombie, b.zombie)
                            if not seen[pk] then
                                seen[pk] = true
                                local cooldown = math.max(
                                    tonumber(a.profile.cooldownTicks) or 12,
                                    tonumber(b.profile.cooldownTicks) or 12)
                                if frame >= (pairCooldown[pk] or -1000000) + cooldown then
                                    local c = Collision.makeContext(
                                        a.zombie, b.zombie,
                                        a.profile, b.profile,
                                        a.velocity, b.velocity)
                                    local minSpeed = math.min(
                                        tonumber(a.profile.minRelativeSpeed) or 0,
                                        tonumber(b.profile.minRelativeSpeed) or 0)
                                    if c and c.relativeSpeed >= minSpeed then
                                        pairCooldown[pk] = frame
                                        collisions = collisions + 1
                                        c.typeA, c.typeB = Identity.getTypeId(a.zombie), Identity.getTypeId(b.zombie)
                                        c.profileA, c.profileB = a.profile.id, b.profile.id
                                        c.groupThrottleKey = bkey(a.cx,a.cy,a.z)
                                        emitCollision(a.zombie, b.zombie, a.typeDef, c)

                                        local reverse = Util.deepCopy(c)
                                        reverse.normalX, reverse.normalY = -c.normalX, -c.normalY
                                        reverse.velocityA, reverse.velocityB = c.velocityB, c.velocityA
                                        reverse.typeA, reverse.typeB = c.typeB, c.typeA
                                        reverse.profileA, reverse.profileB = c.profileB, c.profileA
                                        emitCollision(b.zombie, a.zombie, b.typeDef, reverse)

                                        Separation.resolvePair(
                                            a.zombie, b.zombie, c,
                                            a.profile, b.profile
                                        )

                                        local trippedA = attemptTrip(
                                            a.zombie, b.zombie, a.typeDef,
                                            a.profile, b.profile, c)
                                        local mutual =
                                            (a.profile.trip and a.profile.trip.allowMutualTrip == true) or
                                            (b.profile.trip and b.profile.trip.allowMutualTrip == true)
                                        if not trippedA or mutual then
                                            attemptTrip(
                                                b.zombie, a.zombie, b.typeDef,
                                                b.profile, a.profile, reverse)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return collisions
end

function Runtime.getProfile(typeDef)
    return profileFor(typeDef)
end

return Runtime
