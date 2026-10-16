local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local Weapon = {}

local function get(weapon, method, default)
    if weapon == nil then return default end
    local ok, value = GameAdapter.call(weapon, method)
    if ok and value ~= nil then return value end
    return default
end

local function number(weapon, method, default)
    local value = tonumber(get(weapon, method, default))
    return value or default
end

local function boolean(weapon, method, default)
    local value = get(weapon, method, nil)
    if value == nil then return default end
    return value == true
end

local function stringValue(weapon, method)
    local value = get(weapon, method, nil)
    return value ~= nil and tostring(value) or nil
end

function Weapon.snapshot(weapon)
    if weapon == nil then
        return {
            present = false,
            isRanged = false,
            category = "Unarmed",
            damageCategory = nil,
            type = "BareHands",
            fullType = "BareHands",
            swingAnim = nil,
            sharpness = 0,
            maxSharpness = 0,
            hasSharpness = false,
            minDamage = 0,
            maxDamage = 0,
            knockdownMod = 0,
        }
    end

    return {
        present = true,
        isRanged = boolean(weapon, "isRanged", false),
        category = stringValue(weapon, "getCategory"),
        damageCategory = stringValue(weapon, "getDamageCategory"),
        type = stringValue(weapon, "getType"),
        fullType = stringValue(weapon, "getFullType"),
        swingAnim = stringValue(weapon, "getSwingAnim"),
        sharpness = number(weapon, "getSharpness", 0),
        maxSharpness = number(weapon, "getMaxSharpness", 0),
        hasSharpness = boolean(weapon, "hasSharpness", false),
        minDamage = number(weapon, "getMinDamage", 0),
        maxDamage = number(weapon, "getMaxDamage", 0),
        knockdownMod = number(weapon, "getKnockdownMod", 0),
        pushBackMod = number(weapon, "getPushBackMod", 0),
    }
end

local function haystack(snapshot)
    return string.lower(table.concat({
        snapshot.category or "",
        snapshot.damageCategory or "",
        snapshot.type or "",
        snapshot.fullType or "",
        snapshot.swingAnim or "",
    }, " "))
end

function Weapon.defaultClassification(weapon)
    local s = Weapon.snapshot(weapon)
    local text = haystack(s)

    if not s.present then
        return {
            channel = "impact",
            magnitudeMultiplier = 0.45,
            crushPowerMultiplier = 0.25,
            confidence = "medium",
            reason = "unarmed",
            snapshot = s,
        }
    end

    if s.isRanged or text:find("firearm", 1, true) or text:find("gun", 1, true) then
        return {
            channel = "ballistic",
            magnitudeMultiplier = 1.0,
            crushPowerMultiplier = 0.35,
            confidence = "high",
            reason = "ranged/firearm",
            snapshot = s,
        }
    end

    if text:find("axe", 1, true) or text:find("chop", 1, true) then
        return {
            channel = "chop",
            magnitudeMultiplier = 1.15,
            severPowerMultiplier = 1.25,
            confidence = "high",
            reason = "axe/chop category",
            snapshot = s,
        }
    end

    if text:find("spear", 1, true) or text:find("stab", 1, true) or text:find("pierce", 1, true) then
        return {
            channel = "pierce",
            magnitudeMultiplier = 0.85,
            severPowerMultiplier = 0.08,
            confidence = "high",
            reason = "spear/stab/pierce category",
            snapshot = s,
        }
    end

    if text:find("blade", 1, true) or text:find("knife", 1, true) or
       text:find("machete", 1, true) or text:find("sword", 1, true) or
       s.hasSharpness or s.sharpness > 0 then
        local sharpnessRatio = 1.0
        if s.maxSharpness and s.maxSharpness > 0 then
            sharpnessRatio = math.max(0.15, math.min(1.25, s.sharpness / s.maxSharpness))
        end
        return {
            channel = "cut",
            magnitudeMultiplier = 0.90,
            severPowerMultiplier = 0.38 * sharpnessRatio,
            confidence = "high",
            reason = "blade/sharpness",
            snapshot = s,
        }
    end

    if text:find("blunt", 1, true) or text:find("club", 1, true) or
       text:find("hammer", 1, true) or text:find("bat", 1, true) or
       text:find("crowbar", 1, true) or text:find("sledge", 1, true) then
        return {
            channel = "crush",
            magnitudeMultiplier = 1.0,
            crushPowerMultiplier = 0.90 + math.max(0, s.knockdownMod) * 0.15,
            confidence = "high",
            reason = "blunt category",
            snapshot = s,
        }
    end

    return {
        channel = "impact",
        magnitudeMultiplier = 0.70,
        crushPowerMultiplier = 0.30,
        confidence = "low",
        reason = "generic fallback",
        snapshot = s,
    }
end

return Weapon
