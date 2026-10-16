local Anatomy = require "Mortis/Runtime/AnatomyRuntime"
local Trauma = require "Mortis/Runtime/TraumaRuntime"
local Species = require "Mortis/API/Species"
local HitLocation = require "Mortis/Runtime/Adapters/HitLocationAdapter"
local WeaponAdapter = require "Mortis/Runtime/Adapters/WeaponAdapter"
local Classifiers = require "Mortis/API/WeaponTraumaClassifiers"
local WeaponCatalog = require "Mortis/Runtime/WeaponCatalog"
local Authority = require "Mortis/Runtime/Authority"
local Util = require "Mortis/Core/Util"

local Runtime = {}

-- Vanilla zombie health damage is on a much smaller numeric scale than our
-- anatomical integrity values. This is a conversion unit, not a gore balance
-- rule; extensions can override it per call.
-- IMPORTANT: reportedDamage is already post-vanilla combat damage. Vanilla
-- exhaustion/endurance penalties are therefore already represented. Do not
-- apply another attacker-endurance multiplier here.
Runtime.DEFAULT_DAMAGE_TO_TRAUMA = 30.0

local stagedZombieHits = setmetatable({}, { __mode = "k" })

local function emit(name, ...)
    local Mortis = rawget(_G, "Mortis")
    if Mortis and Mortis.Events then Mortis.Events:emit(name, ...) end
end

function Runtime.classifyWeapon(weapon)
    local snapshot = WeaponAdapter.snapshot(weapon)

    -- Explicit runtime classifiers remain the highest-priority escape hatch.
    local custom = Classifiers.classify(weapon, snapshot)
    if custom then
        custom.snapshot = custom.snapshot or snapshot
        custom.catalogStatus = "runtime-classifier"
        return custom
    end

    local fallback = WeaponAdapter.defaultClassification(weapon)

    -- Then consult the catalog built from the complete loaded script registry.
    -- This makes vanilla and modded weapon scripts participate automatically.
    return WeaponCatalog.classificationForRuntimeWeapon(weapon, fallback) or fallback
end

function Runtime.stageZombieHit(zombie, attacker, bodyPart, weapon)
    if zombie == nil then return false end
    local anatomy = Anatomy.ensure(zombie)
    if not anatomy then return false end

    local species = Species.get(anatomy.speciesId)
    if not species then return false end
    local region, rawLocation = HitLocation.resolve(species, bodyPart)

    stagedZombieHits[zombie] = {
        attacker = attacker,
        bodyPart = bodyPart,
        rawLocation = rawLocation,
        region = region,
        weapon = weapon,
        classification = Runtime.classifyWeapon(weapon),
    }

    emit("LivingEntityHitStaged", zombie, stagedZombieHits[zombie])
    return true
end

function Runtime.consumeStagedZombieHit(zombie, reportedDamage, options)
    if not Authority.canWriteCanonicalState(zombie) then return false, "non-authority" end
    local staged = stagedZombieHits[zombie]
    stagedZombieHits[zombie] = nil
    if not staged then return false, "no staged zombie hit" end

    options = options or {}
    local classification = staged.classification or Runtime.classifyWeapon(staged.weapon)
    local damage = tonumber(reportedDamage) or 0
    local scale = tonumber(options.damageToTrauma) or Runtime.DEFAULT_DAMAGE_TO_TRAUMA
    local magnitude = damage * scale * (tonumber(classification.magnitudeMultiplier) or 1)

    local traumaContext = {
        region = staged.region,
        bodyPart = staged.bodyPart,
        channel = classification.channel,
        magnitude = magnitude,
        attacker = staged.attacker,
        weapon = staged.weapon,
        source = "weapon-hit",
        metadata = {
            reportedDamage = damage,
            rawLocation = staged.rawLocation,
            locationConfidence = staged.region and "exact-event" or "fallback",
            classifierId = classification.classifierId,
            classificationReason = classification.reason,
            classificationConfidence = classification.confidence,
            weapon = Util.deepCopy(classification.snapshot or {}),
        },
    }

    if classification.severPowerMultiplier then
        traumaContext.severPower = magnitude * tonumber(classification.severPowerMultiplier)
    end
    if classification.crushPowerMultiplier then
        traumaContext.crushPower = magnitude * tonumber(classification.crushPowerMultiplier)
    end

    local ok, result = Trauma.apply(zombie, traumaContext)
    if ok then
        result.hit = staged
        result.classification = classification
        emit("LivingEntityWeaponTrauma", zombie, result)
    end
    return ok, result
end

-- Generic trusted entry point for players, NPCs, animals, or custom creatures.
-- Callers that have a real body-part result can receive the same exact regional
-- behavior as OnHitZombie without M.O.R.T.I.S. inventing a hit location.
function Runtime.applyHit(target, attacker, bodyPart, weapon, damage, options)
    if not Authority.canWriteCanonicalState(target) then return false, "non-authority" end
    local anatomy, err = Anatomy.ensure(target)
    if not anatomy then return false, err end
    local species = Species.get(anatomy.speciesId)
    if not species then return false, "missing species definition" end

    local region, rawLocation = HitLocation.resolve(species, bodyPart)
    local classification = Runtime.classifyWeapon(weapon)
    options = options or {}
    local scale = tonumber(options.damageToTrauma) or Runtime.DEFAULT_DAMAGE_TO_TRAUMA
    local magnitude = (tonumber(damage) or 0) * scale * (tonumber(classification.magnitudeMultiplier) or 1)

    local ctx = {
        region = region,
        bodyPart = bodyPart,
        channel = classification.channel,
        magnitude = magnitude,
        attacker = attacker,
        weapon = weapon,
        source = options.source or "weapon-hit",
        metadata = {
            reportedDamage = tonumber(damage) or 0,
            rawLocation = rawLocation,
            locationConfidence = bodyPart ~= nil and "provided" or "fallback",
            classificationReason = classification.reason,
            classificationConfidence = classification.confidence,
            classifierId = classification.classifierId,
            weapon = Util.deepCopy(classification.snapshot or {}),
        },
    }
    if classification.severPowerMultiplier then ctx.severPower = magnitude * classification.severPowerMultiplier end
    if classification.crushPowerMultiplier then ctx.crushPower = magnitude * classification.crushPowerMultiplier end
    return Trauma.apply(target, ctx)
end

-- OnWeaponHitCharacter is client-local in current Lua docs. We expose it as an
-- observation signal but never let it author server trauma in MP.
function Runtime.observeCharacterHit(attacker, target, weapon, damage)
    local classification = Runtime.classifyWeapon(weapon)
    local observation = {
        attacker = attacker,
        target = target,
        weapon = weapon,
        damage = tonumber(damage) or 0,
        classification = classification,
        authoritative = false,
        bodyPart = nil,
    }
    emit("LivingEntityWeaponHitObserved", target, observation)
    return observation
end

function Runtime.clear(entity)
    stagedZombieHits[entity] = nil
end

return Runtime
