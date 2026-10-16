local ScriptItem = require "Mortis/Runtime/Adapters/ScriptItemAdapter"
local Overrides = require "Mortis/API/WeaponCatalogOverrides"
local Compatibility = require "Mortis/API/WeaponCompatibility"
local Util = require "Mortis/Core/Util"

local Catalog = {}

local entries = {}
local order = {}
local built = false
local lastBuildReason = nil

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function contains(value, needle)
    return lower(value):find(string.lower(needle), 1, true) ~= nil
end

local function collectionContains(values, needle)
    for _, value in ipairs(values or {}) do
        if contains(value, needle) then return true end
    end
    return false
end

local function evidence(snapshot)
    return lower(table.concat({
        snapshot.fullType or "",
        snapshot.type or "",
        snapshot.displayName or "",
        snapshot.itemType or "",
        snapshot.damageCategory or "",
        snapshot.weaponSubCategory or "",
        snapshot.swingAnim or "",
        table.concat(snapshot.categories or {}, " "),
        table.concat(snapshot.tags or {}, " "),
    }, " "))
end

local function categoryFamily(snapshot)
    local cats = snapshot.categories or {}
    local text = evidence(snapshot)

    if collectionContains(cats, "Axe") or contains(snapshot.damageCategory, "Axe") then return "axe" end
    if collectionContains(cats, "LongBlade") or contains(snapshot.weaponSubCategory, "LongBlade") or text:find("longblade", 1, true) then
        return "long-sharp"
    end
    if collectionContains(cats, "SmallBlade") or collectionContains(cats, "ShortBlade") or
       contains(snapshot.weaponSubCategory, "SmallBlade") or contains(snapshot.weaponSubCategory, "ShortBlade") or
       text:find("smallblade", 1, true) or text:find("shortblade", 1, true) then
        return "short-sharp"
    end
    if collectionContains(cats, "Spear") or contains(snapshot.weaponSubCategory, "Spear") then return "spear" end
    if collectionContains(cats, "Blunt") or collectionContains(cats, "LongBlunt") or collectionContains(cats, "SmallBlunt") then
        return "blunt"
    end
    if snapshot.ranged or snapshot.aimedFirearm then return "firearm" end
    return "other"
end

local function result(channel, status, confidence, reason, multipliers)
    local r = {
        channel = channel,
        status = status,
        confidence = confidence,
        reason = reason,
        confirmed = status == "auto-confirmed",
    }
    for k, v in pairs(multipliers or {}) do r[k] = v end
    return r
end

local function recommend(snapshot)
    local family = categoryFamily(snapshot)
    local text = evidence(snapshot)

    if family == "firearm" then
        return family, result("ballistic", "auto-confirmed", 0.99, "ranged/firearm metadata",
            { magnitudeMultiplier=1.0, crushPowerMultiplier=0.35 })
    end

    if family == "axe" then
        return family, result("chop", "auto-confirmed", 0.99, "weapon category Axe",
            { magnitudeMultiplier=1.15, severPowerMultiplier=1.25 })
    end

    if family == "spear" then
        return family, result("pierce", "auto-confirmed", 0.98, "weapon category Spear",
            { magnitudeMultiplier=0.85, severPowerMultiplier=0.08 })
    end

    if family == "blunt" then
        return family, result("crush", "auto-confirmed", 0.98, "blunt weapon category",
            { magnitudeMultiplier=1.0, crushPowerMultiplier=0.95 })
    end

    -- Long/short sharp categories identify the compatibility pool, but do not
    -- by themselves decide chop vs cut vs pierce. Ambiguous tools are surfaced
    -- for human confirmation.
    if family == "long-sharp" then
        if text:find("machete", 1, true) or text:find("falchion", 1, true) or
           text:find("kukri", 1, true) or text:find("bolo", 1, true) or
           text:find("chopper", 1, true) then
            return family, result("chop", "review", 0.78, "LongBlade with chopping-name evidence",
                { magnitudeMultiplier=1.05, severPowerMultiplier=0.90 })
        end
        if text:find("katana", 1, true) or text:find("sword", 1, true) or
           text:find("rapier", 1, true) or text:find("saber", 1, true) or
           text:find("sabre", 1, true) then
            return family, result("cut", "review", 0.82, "LongBlade with sword-name evidence",
                { magnitudeMultiplier=0.95, severPowerMultiplier=0.45 })
        end
        return family, result("cut", "review", 0.58, "LongBlade category is sharp but chop/cut semantics are ambiguous",
            { magnitudeMultiplier=0.90, severPowerMultiplier=0.38 })
    end

    if family == "short-sharp" then
        if text:find("cleaver", 1, true) or text:find("hatchet", 1, true) or
           text:find("chopper", 1, true) then
            return family, result("chop", "review", 0.82, "ShortBlade with cleaver/chopper evidence",
                { magnitudeMultiplier=1.0, severPowerMultiplier=0.78 })
        end
        if text:find("stiletto", 1, true) or text:find("dagger", 1, true) or
           text:find("icepick", 1, true) or text:find("ice pick", 1, true) then
            return family, result("pierce", "review", 0.78, "ShortBlade with piercing-name evidence",
                { magnitudeMultiplier=0.80, severPowerMultiplier=0.05 })
        end
        if text:find("knife", 1, true) then
            return family, result("cut", "review", 0.68, "ShortBlade knife; cut vs pierce depends on weapon design",
                { magnitudeMultiplier=0.88, severPowerMultiplier=0.22 })
        end
        return family, result("cut", "review", 0.52, "ShortBlade category is sharp but exact trauma semantics are ambiguous",
            { magnitudeMultiplier=0.86, severPowerMultiplier=0.20 })
    end

    if snapshot.ranged then
        return family, result("ballistic", "auto-confirmed", 0.95, "ranged flag",
            { magnitudeMultiplier=1.0, crushPowerMultiplier=0.35 })
    end

    return family, result("impact", "unknown", 0.25, "weapon metadata did not map to a known trauma family",
        { magnitudeMultiplier=0.70, crushPowerMultiplier=0.30 })
end

local function applyAuthority(entry)
    local verified = Compatibility.get(entry.fullType)
    if verified then
        local merged = Util.merge(entry, {
            classification = Util.deepCopy(verified),
        })
        merged.compatibility = {
            verified = true,
            providerId = verified.providerId,
            providerName = verified.providerName,
            providerKind = verified.providerKind,
            targetModId = verified.targetModId,
        }
        return merged
    end

    -- Development-session/manual confirmations are useful while authoring a
    -- patch but are not shipped as "official support" unless moved into a
    -- verified provider.
    local override = Overrides.get(entry.fullType)
    if override then
        local merged = Util.merge(entry, {
            classification = Util.merge(entry.classification, override),
        })
        merged.classification.status = "manual-unverified"
        merged.classification.confirmed = override.confirmed ~= false
        merged.classification.confidence = 1.0
        merged.classification.reason = override.notes or "manual development override"
        merged.compatibility = { verified=false, providerKind="development" }
        return merged
    end

    entry.compatibility = { verified=false, providerKind="discovered" }
    return entry
end

local function scriptManager()
    local manager = rawget(_G, "ScriptManager")
    if manager and manager.instance then return manager.instance end
    return nil
end

local function javaListItems(list)
    local result = {}
    if list == nil then return result end
    local okSize, size = pcall(function() return list:size() end)
    if not okSize then return result end
    for i=0, tonumber(size)-1 do
        local okGet, item = pcall(function() return list:get(i) end)
        if okGet and item ~= nil then result[#result + 1] = item end
    end
    return result
end

function Catalog.build(reason)
    entries, order = {}, {}
    lastBuildReason = reason or "manual"

    local manager = scriptManager()
    if not manager then
        built = false
        return false, "ScriptManager.instance unavailable"
    end

    local ok, allItems = pcall(function() return manager:getAllItems() end)
    if not ok or allItems == nil then
        built = false
        return false, "ScriptManager:getAllItems unavailable"
    end

    local scanned, weapons = 0, 0
    for _, script in ipairs(javaListItems(allItems)) do
        scanned = scanned + 1
        local snapshot = ScriptItem.snapshot(script)
        if not snapshot.obsolete and ScriptItem.isWeapon(snapshot) and snapshot.fullType then
            local family, classification = recommend(snapshot)
            local entry = applyAuthority({
                fullType = snapshot.fullType,
                displayName = snapshot.displayName,
                family = family,
                sharpFamily = family == "long-sharp" or family == "short-sharp",
                snapshot = snapshot,
                classification = classification,
            })
            entries[entry.fullType] = entry
            order[#order + 1] = entry.fullType
            weapons = weapons + 1
        end
    end

    table.sort(order)
    built = true

    local Mortis = rawget(_G, "Mortis")
    if Mortis and Mortis.Events then
        Mortis.Events:emit("WeaponCatalogBuilt", weapons, scanned, lastBuildReason)
    end
    return true, { scanned=scanned, weapons=weapons, reason=lastBuildReason }
end

function Catalog.ensure()
    if built then return true end
    return Catalog.build("lazy")
end

function Catalog.isBuilt() return built end
function Catalog.get(fullType)
    Catalog.ensure()
    local entry = entries[fullType]
    return entry and Util.deepCopy(entry) or nil
end

function Catalog.getAll()
    Catalog.ensure()
    local result = {}
    for _, fullType in ipairs(order) do result[#result + 1] = Util.deepCopy(entries[fullType]) end
    return result
end

function Catalog.getByFamily(family)
    local result = {}
    for _, entry in ipairs(Catalog.getAll()) do
        if entry.family == family then result[#result + 1] = entry end
    end
    return result
end

function Catalog.getLongSharp() return Catalog.getByFamily("long-sharp") end
function Catalog.getShortSharp() return Catalog.getByFamily("short-sharp") end

function Catalog.getReviewQueue()
    local result = {}
    for _, entry in ipairs(Catalog.getAll()) do
        local status = entry.classification and entry.classification.status
        if status == "review" or status == "unknown" then result[#result + 1] = entry end
    end
    return result
end

function Catalog.confirm(fullType, classification)
    if type(classification) == "string" then classification = { channel=classification } end
    classification = classification or {}
    classification.confirmed = true
    Overrides.replace(fullType, classification)
    if entries[fullType] then
        local original = entries[fullType]
        entries[fullType] = applyAuthority(original)
    end
    return Catalog.get(fullType)
end

function Catalog.override(fullType, classification)
    return Catalog.confirm(fullType, classification)
end

function Catalog.clearOverride(fullType)
    -- Registry intentionally has no delete API. Rebuilding without an override
    -- is done by restart/config change; this avoids hidden mutable registry rules.
    return false, "remove the registered override from configuration and restart/rebuild"
end

function Catalog.classificationForRuntimeWeapon(weapon, fallbackClassification)
    local ok, fullType = pcall(function() return weapon and weapon:getFullType() end)
    if not ok or not fullType then return fallbackClassification end
    fullType = tostring(fullType)

    -- Production authority: explicit verified core/compatibility provider.
    local verified = Compatibility.get(fullType)
    if verified then
        local c = Util.deepCopy(verified)
        c.catalogFullType = fullType
        c.compatibilityVerified = true
        return c
    end

    -- Development override can be exercised deliberately while building a
    -- compatibility patch, but is visibly unverified.
    local override = Overrides.get(fullType)
    if override then
        local c = Util.merge(fallbackClassification or {}, override)
        c.catalogFullType = fullType
        c.catalogStatus = "manual-unverified"
        c.compatibilityVerified = false
        return c
    end

    -- Discovery recommendation is NOT authoritative. Keep the conservative
    -- runtime fallback classification and attach only informational metadata.
    local entry = Catalog.get(fullType)
    local c = Util.deepCopy(fallbackClassification or {})
    if entry then
        c.discoverySuggestion = entry.classification and Util.deepCopy(entry.classification) or nil
        c.catalogFamily = entry.family
        c.catalogFullType = fullType
        c.catalogStatus = "discovered-unverified"
        c.compatibilityVerified = false
    end
    return c
end

function Catalog.summary()
    local result = {
        total=0, coreVerified=0, patchVerified=0, review=0, unknown=0, manualUnverified=0,
        longSharp=0, shortSharp=0,
    }
    for _, entry in ipairs(Catalog.getAll()) do
        result.total = result.total + 1
        if entry.family == "long-sharp" then result.longSharp = result.longSharp + 1 end
        if entry.family == "short-sharp" then result.shortSharp = result.shortSharp + 1 end
        local status = entry.classification and entry.classification.status or "unknown"
        if status == "core-verified" then result.coreVerified = result.coreVerified + 1
        elseif status == "patch-verified" then result.patchVerified = result.patchVerified + 1
        elseif status == "review" then result.review = result.review + 1
        elseif status == "manual-unverified" then result.manualUnverified = result.manualUnverified + 1
        else result.unknown = result.unknown + 1 end
    end
    return result
end

function Catalog.formatReviewReport()
    local lines = {}
    local summary = Catalog.summary()
    lines[#lines+1] = string.format(
        "MORTIS Weapon Catalog: %d weapons | core verified=%d | patch verified=%d | Long Sharp=%d | Short Sharp=%d | review=%d | unknown=%d | dev-manual=%d",
        summary.total, summary.coreVerified, summary.patchVerified, summary.longSharp,
        summary.shortSharp, summary.review, summary.unknown, summary.manualUnverified)

    for _, entry in ipairs(Catalog.getReviewQueue()) do
        local c = entry.classification or {}
        lines[#lines+1] = string.format(
            "%s | %s | family=%s | suggested=%s | confidence=%.2f | %s",
            tostring(entry.fullType),
            tostring(entry.displayName or ""),
            tostring(entry.family),
            tostring(c.channel),
            tonumber(c.confidence) or 0,
            tostring(c.reason or ""))
    end
    return table.concat(lines, "\n")
end

return Catalog
