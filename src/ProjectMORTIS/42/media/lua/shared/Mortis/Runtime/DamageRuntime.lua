local Identity = require "Mortis/Runtime/Identity"
local Authority = require "Mortis/Runtime/Authority"
local Durability = require "Mortis/Runtime/Adapters/DurabilityAdapter"
local ProfileRuntime = require "Mortis/Runtime/ProfileRuntime"

local DamageRuntime = {}

local function durabilityProfile(zombie)
    local typeDef = Identity.getType(zombie)
    if not typeDef then return nil, "not typed" end
    return ProfileRuntime.resolveDurability(typeDef)
end

local function normalizeKind(kind)
    kind = tostring(kind or "generic")
    if kind == "WEAPONHIT" or kind == "weapon" then return "weapon" end
    if kind == "CARHITDAMAGE" or kind == "CARCRASHDAMAGE" or kind == "vehicle" then return "vehicle" end
    if kind == "fire" or kind == "BURN" then return "fire" end
    if kind == "environment" then return "environment" end
    return kind
end

function DamageRuntime.getMultiplier(zombie, kind)
    local profile, err = durabilityProfile(zombie)
    if not profile then
        if err then return nil, err end
        return 1.0
    end

    local normalized = normalizeKind(kind)
    local overrides = profile.damageTypeMultipliers or {}
    if overrides[kind] ~= nil then return tonumber(overrides[kind]) or 1.0 end
    if overrides[normalized] ~= nil then return tonumber(overrides[normalized]) or 1.0 end

    if normalized == "weapon" then return tonumber(profile.weaponDamageMultiplier) or tonumber(profile.damageTakenMultiplier) or 1.0 end
    if normalized == "vehicle" then return tonumber(profile.vehicleDamageMultiplier) or tonumber(profile.damageTakenMultiplier) or 1.0 end
    if normalized == "fire" then return tonumber(profile.fireDamageMultiplier) or tonumber(profile.environmentDamageMultiplier) or 1.0 end
    if normalized == "environment" then return tonumber(profile.environmentDamageMultiplier) or tonumber(profile.damageTakenMultiplier) or 1.0 end
    return tonumber(profile.damageTakenMultiplier) or 1.0
end

function DamageRuntime.apply(zombie, amount, kind, metadata)
    if not Authority.canWriteCanonicalState(zombie) then return false, "non-authority" end
    amount = tonumber(amount)
    if not amount or amount < 0 then return false, "damage amount must be >= 0" end

    local multiplier, err = DamageRuntime.getMultiplier(zombie, kind)
    if multiplier == nil then return false, err end
    local effective = amount * multiplier
    local health, healthErr = Durability.getHealth(zombie)
    if health == nil then return false, healthErr end
    local target = math.max(0, health - effective)
    local ok, setErr = Durability.setHealth(zombie, target)
    if not ok then return false, setErr end
    return true, {
        baseDamage = amount,
        effectiveDamage = effective,
        multiplier = multiplier,
        kind = normalizeKind(kind),
        metadata = metadata,
        healthBefore = health,
        healthAfter = target,
    }
end

function DamageRuntime.adjustPostDamage(zombie, reportedDamage, damageType, metadata)
    if not Authority.canWriteCanonicalState(zombie) then return false, "non-authority" end
    reportedDamage = tonumber(reportedDamage)
    if not reportedDamage or reportedDamage < 0 then return false, "reported damage must be >= 0" end

    local multiplier, err = DamageRuntime.getMultiplier(zombie, damageType)
    if multiplier == nil then return false, err end
    if multiplier == 1.0 or reportedDamage == 0 then
        return true, {
            baseDamage = reportedDamage,
            effectiveDamage = reportedDamage,
            adjustment = 0,
            multiplier = multiplier,
            kind = normalizeKind(damageType),
            metadata = metadata,
        }
    end

    local health, healthErr = Durability.getHealth(zombie)
    if health == nil then return false, healthErr end
    local adjustment = reportedDamage * (multiplier - 1.0)
    local target = math.max(0, health - adjustment)
    local ok, setErr = Durability.setHealth(zombie, target)
    if not ok then return false, setErr end

    return true, {
        baseDamage = reportedDamage,
        effectiveDamage = reportedDamage * multiplier,
        adjustment = adjustment,
        multiplier = multiplier,
        kind = normalizeKind(damageType),
        metadata = metadata,
        healthBeforeAdjustment = health,
        healthAfter = target,
    }
end

return DamageRuntime
