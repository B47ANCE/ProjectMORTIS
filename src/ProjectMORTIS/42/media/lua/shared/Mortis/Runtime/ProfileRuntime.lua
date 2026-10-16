local Util = require "Mortis/Core/Util"
local LocomotionProfiles = require "Mortis/API/LocomotionProfiles"
local DurabilityProfiles = require "Mortis/API/DurabilityProfiles"
local AppearanceProfiles = require "Mortis/API/AppearanceProfiles"
local Locomotion = require "Mortis/Runtime/Adapters/LocomotionAdapter"
local Durability = require "Mortis/Runtime/Adapters/DurabilityAdapter"
local Appearance = require "Mortis/Runtime/Adapters/AppearanceAdapter"
local Components = require "Mortis/Runtime/Components"
local Authority = require "Mortis/Runtime/Authority"
local Logger = require "Mortis/Core/Logger"
local Scheduler = require "Mortis/Core/Scheduler"
local State = require "Mortis/Runtime/Adapters/StateAdapter"
local Baseline = require "Mortis/Runtime/LocomotionBaseline"
local Persistence = require "Mortis/Runtime/Persistence"

local ProfileRuntime = {}

local unpackValues = unpack or (table and table.unpack)
if not unpackValues then
    unpackValues = function(values, first, last)
        first = first or 1
        last = last or #values
        if first > last then return end
        return values[first], unpackValues(values, first + 1, last)
    end
end
local STATE_COMPONENT = "Mortis.ProfileState"

local function resolve(registry, value, inlineKey)
    if value == nil then return nil, nil end
    if type(value) == "string" then
        local profile = registry.get(value)
        if not profile then return nil, "unknown " .. inlineKey .. " profile: " .. value end
        return profile, value
    end
    if type(value) ~= "table" then return nil, inlineKey .. " profile reference must be a string or table" end

    local base = nil
    local profileId = value.profile or value.id
    if value.profile ~= nil then
        base = registry.get(value.profile)
        if not base then return nil, "unknown " .. inlineKey .. " profile: " .. tostring(value.profile) end
    end
    local overrides = Util.deepCopy(value)
    overrides.profile = nil
    -- `id` on an inline profile is data, not a registry reference unless the
    -- caller used the dedicated `profile` key.
    if value.profile == nil then overrides.id = nil end
    return Util.merge(base or {}, overrides), profileId
end

local function getState(zombie)
    local state = Components.get(zombie, STATE_COMPONENT)
    if type(state) ~= "table" then state = {} end
    state.locomotion = state.locomotion or {}
    state.durability = state.durability or { appliedScale = 1.0 }
    state.appearance = state.appearance or {}
    return state
end

local function saveState(zombie, state)
    if Authority.canWriteCanonicalState(zombie) then
        Components.set(zombie, STATE_COMPONENT, state)
    else
        -- Client-local reconciliation cache only. Do not dirty persistent state
        -- or echo profile bookkeeping toward the server.
        Components.setRestored(zombie, STATE_COMPONENT, state)
    end
end

function ProfileRuntime.resolveLocomotion(typeDef)
    return resolve(LocomotionProfiles, typeDef and (typeDef.locomotion or typeDef.locomotionProfile), "locomotion")
end

function ProfileRuntime.resolveDurability(typeDef)
    return resolve(DurabilityProfiles, typeDef and (typeDef.durability or typeDef.durabilityProfile), "durability")
end

function ProfileRuntime.resolveAppearance(typeDef)
    return resolve(AppearanceProfiles, typeDef and (typeDef.appearance or typeDef.appearanceProfile), "appearance")
end

local function checkpoint(zombie,state)
    saveState(zombie,state)
    return Persistence.flushComponents(zombie,false)
end

function ProfileRuntime.hasPendingLocomotionRestore(zombie)
    local bucket=Components.allFor(zombie)
    local state=bucket and bucket[STATE_COMPONENT]
    return type(state)=="table" and type(state.locomotion)=="table" and state.locomotion.restorePending==true
end

function ProfileRuntime.applyLocomotion(zombie, typeDef, force, retainBaseline)
    if not Authority.canWriteCanonicalState(zombie) then return true, "non-authority" end
    local bucket=Components.allFor(zombie)
    if bucket and bucket["Mortis.LocomotionOverrideBaseline"]~=nil then
        return false,"locomotion override owns movement; release or coordinated clear required"
    end
    local profile, profileIdOrError = ProfileRuntime.resolveLocomotion(typeDef)
    local state = getState(zombie)
    local movement=state.locomotion
    if not profile then
        if profileIdOrError then return false, profileIdOrError end
        if movement.baseline then
            -- Force never bypasses a native attack/get-up/climb transition.
            if State.isBusy(zombie) then return false,"locomotion restore deferred while native state busy" end
            movement.restorePending=true
            local saved,saveError=checkpoint(zombie,state)
            if not saved then return false,saveError end
            local restored,restoreError=Baseline.restore(zombie,movement.baseline)
            if not restored then return false,restoreError end
            if not retainBaseline then state.locomotion={} end
            return checkpoint(zombie,state)
        end
        if movement.signature or movement.attempted then return false,"legacy locomotion baseline unavailable" end
        return true, "no profile"
    end

    if movement.restorePending then return false,"locomotion restoration pending" end
    if not movement.baseline and (movement.signature or movement.attempted) then return false,"legacy locomotion baseline unavailable" end
    local signature = table.concat({
        tostring(profileIdOrError or "inline"),
        tostring(profile.tier or "inherit"),
        tostring(profile.walkType or ""),
        tostring(profile.speedMultiplier or ""),
        tostring(profile.crawler),
    }, ":")
    if not force and state.locomotion.signature == signature then
        local matched = Locomotion.matches(zombie, profile)
        if matched then return true, "already applied" end
    end

    local busy, busyReason = State.isBusy(zombie)
    if busy then return false, "deferred while native state busy: " .. tostring(busyReason) end

    if movement.baseline and movement.attempted and movement.signature~=signature then
        if busy then return false,"locomotion profile transition deferred while native state busy" end
        local restored,restoreError=Baseline.restore(zombie,movement.baseline)
        if not restored then return false,restoreError end
    end
    if not movement.baseline then
        local original,captureError=Baseline.capture(zombie)
        if not original then return false,captureError end
        movement.baseline=original
    end
    movement.attempted=true
    local saved,saveError=checkpoint(zombie,state)
    if not saved then return false,saveError end

    if profile.walkType ~= nil then
        local ok, err = Locomotion.setWalkType(zombie, profile.walkType)
        if not ok then return false, err end
    end
    if profile.tier and profile.tier ~= "inherit" then
        local ok, err = Locomotion.setTier(zombie, profile.tier)
        if not ok then return false, err end
    end
    if profile.speedMultiplier ~= nil then
        local ok, err = Locomotion.setSpeedMultiplier(zombie, profile.speedMultiplier)
        if not ok then return false, err end
    end
    if profile.crawler ~= nil then
        local ok, err = Locomotion.setCrawler(zombie, profile.crawler)
        if not ok then return false, err end
        if profile.crawler == true and profile.crawlerArgs ~= nil then
            ok, err = Locomotion.setCrawlerSpeed(zombie, unpackValues(profile.crawlerArgs, 1, #profile.crawlerArgs))
            if not ok then return false, err end
        end
    end

    state.locomotion.signature = signature
    state.locomotion.lastAppliedFrame = Scheduler.frame
    state.locomotion.profileId = profileIdOrError
    saveState(zombie, state)
    return true
end

function ProfileRuntime.applyDurability(zombie, typeDef, force)
    if not Authority.canWriteCanonicalState(zombie) then return true, "non-authority" end
    local profile, profileIdOrError = ProfileRuntime.resolveDurability(typeDef)
    local state = getState(zombie)
    if not profile then
        if profileIdOrError then return false, profileIdOrError end
        local oldScale = tonumber(state.durability.appliedScale) or 1.0
        if oldScale ~= 1.0 then
            local ok, err = Durability.scaleHealth(zombie, oldScale, 1.0)
            if not ok then return false, err end
            state.durability = { appliedScale = 1.0 }
            saveState(zombie, state)
            return true, "restored baseline durability"
        end
        return true, "no profile"
    end

    local oldScale = tonumber(state.durability.appliedScale) or 1.0
    local newScale = tonumber(profile.healthMultiplier) or 1.0
    if not force and state.durability.profileId == profileIdOrError and oldScale == newScale then
        return true, "already applied"
    end

    local health, err = Durability.getHealth(zombie)
    if health == nil then return false, err end
    if oldScale <= 0 then oldScale = 1.0 end
    local baseEquivalent = health / oldScale
    local newHealth = math.max(0, baseEquivalent * newScale)
    local ok, setErr = Durability.setHealth(zombie, newHealth)
    if not ok then return false, setErr end

    state.durability.profileId = profileIdOrError
    state.durability.appliedScale = newScale
    state.durability.damageTakenMultiplier = profile.damageTakenMultiplier
    state.durability.weaponDamageMultiplier = profile.weaponDamageMultiplier
    state.durability.environmentDamageMultiplier = profile.environmentDamageMultiplier
    state.durability.fireDamageMultiplier = profile.fireDamageMultiplier
    state.durability.vehicleDamageMultiplier = profile.vehicleDamageMultiplier
    state.durability.damageTypeMultipliers = Util.deepCopy(profile.damageTypeMultipliers or {})
    state.durability.staggerMultiplier = profile.staggerMultiplier
    saveState(zombie, state)
    return true
end

function ProfileRuntime.applyAppearance(zombie, typeDef, force)
    local profile, profileIdOrError = ProfileRuntime.resolveAppearance(typeDef)
    local state = getState(zombie)
    if not profile then
        if profileIdOrError then return false, profileIdOrError end
        if state.appearance.signature and type(state.appearance.baseline) == "table" then
            local restore = Util.deepCopy(state.appearance.baseline)
            restore.refreshModel = true
            local ok, err = Appearance.apply(zombie, restore)
            if not ok then return false, err end
            state.appearance = { baseline = state.appearance.baseline }
            saveState(zombie, state)
            return true, "restored baseline appearance"
        end
        return true, "no profile"
    end

    if state.appearance.baseline == nil then
        local baseline = Appearance.capture(zombie)
        if type(baseline) == "table" then state.appearance.baseline = baseline end
    end
    local signature = table.concat({
        tostring(profileIdOrError or "inline"),
        tostring(profile.skinTextureName or ""),
        tostring(profile.skinTextureIndex or ""),
        tostring(profile.hairModel or ""),
        tostring(profile.beardModel or ""),
        tostring(profile.outfit or ""),
    }, ":")
    if not force and state.appearance.signature == signature then
        local matched, reason = Appearance.matches(zombie, profile)
        if matched then return true, "already applied" end
        Logger.info("Appearance drift detected; reapplying profile " .. tostring(profileIdOrError or "inline") .. " (" .. tostring(reason) .. ")")
    end

    local ok, err = Appearance.apply(zombie, profile)
    if not ok then return false, err end
    state.appearance.profileId = profileIdOrError
    state.appearance.signature = signature
    saveState(zombie, state)
    return true
end

function ProfileRuntime.applyAll(zombie, typeDef, force)
    local results = {}
    local okL, errL = ProfileRuntime.applyLocomotion(zombie, typeDef, force)
    results.locomotion = { ok = okL, reason = errL }
    local okD, errD = ProfileRuntime.applyDurability(zombie, typeDef, force)
    results.durability = { ok = okD, reason = errD }
    local okA, errA = ProfileRuntime.applyAppearance(zombie, typeDef, force)
    results.appearance = { ok = okA, reason = errA }

    if not okL then Logger.warn("Locomotion profile apply failed: " .. tostring(errL)) end
    if not okD then Logger.warn("Durability profile apply failed: " .. tostring(errD)) end
    if not okA then Logger.warn("Appearance profile apply failed: " .. tostring(errA)) end
    return okL and okD and okA, results
end

function ProfileRuntime.reconcile(zombie, typeDef)
    local results = {}

    -- Durability scaling is idempotent and remains authority-only.
    local okD, errD = ProfileRuntime.applyDurability(zombie, typeDef, false)
    results.durability = { ok = okD, reason = errD }

    -- Appearance is observable through HumanVisual getters, so reconcile drift
    -- on both authority and clients.
    local okA, errA = ProfileRuntime.applyAppearance(zombie, typeDef, false)
    results.appearance = { ok = okA, reason = errA }

    -- Tier/speed fields do not have a stable documented Lua getter. Reassert
    -- them conservatively after the profile's interval, never during a native
    -- attack/hit/get-up/climb/thump transition.
    local okL, errL = true, "non-authority"
    if Authority.canWriteCanonicalState(zombie) then
        local profile = ProfileRuntime.resolveLocomotion(typeDef)
        if profile then
            local state = getState(zombie)
            local last = tonumber(state.locomotion.lastAppliedFrame) or -1000000
            local interval = tonumber(profile.reconcileInterval) or 600
            local matched, matchReason = Locomotion.matches(zombie, profile)
            local due = (Scheduler.frame - last) >= interval
            if matched == false or due then
                local busy = State.isBusy(zombie)
                if not busy then
                    okL, errL = ProfileRuntime.applyLocomotion(zombie, typeDef, true)
                else
                    okL, errL = true, "deferred while native state busy"
                end
            else
                okL, errL = true, matchReason or "not due"
            end
        else
            okL, errL = ProfileRuntime.applyLocomotion(zombie, typeDef, false)
        end
    end
    results.locomotion = { ok = okL, reason = errL }

    return okL and okD and okA, results
end

function ProfileRuntime.getState(zombie)
    return Util.deepCopy(getState(zombie))
end

return ProfileRuntime
