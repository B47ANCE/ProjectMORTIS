local Capabilities = require "Mortis/API/Capabilities"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local AppearanceAdapter = {}

function AppearanceAdapter.getHumanVisual(zombie)
    if not Capabilities.has("zombie.getHumanVisual") then return nil, "capability unavailable" end
    local ok, value = GameAdapter.call(zombie, "getHumanVisual")
    if not ok then return nil, value end
    if value ~= nil then Capabilities.observeHumanVisual(value) end
    return value
end

function AppearanceAdapter.refresh(zombie)
    -- These refresh methods are intentionally capability-gated because their
    -- Lua exposure has varied. HumanVisual mutation itself is documented in
    -- current B42 JavaDocs; refresh semantics still require live verification.
    if Capabilities.has("zombie.resetModelNextFrame") then
        return GameAdapter.call(zombie, "resetModelNextFrame")
    end
    if Capabilities.has("zombie.resetModel") then
        return GameAdapter.call(zombie, "resetModel")
    end
    return true, "no explicit model refresh capability; visual state mutated"
end

function AppearanceAdapter.apply(zombie, definition)
    if type(definition) ~= "table" then return false, "appearance definition must be a table" end
    local visual, reason = AppearanceAdapter.getHumanVisual(zombie)
    if not visual then return false, reason end

    local changed = false

    -- Outfit first. Some native dressing paths can rebuild item/body visuals,
    -- so skin/hair/beard overrides are deliberately applied after clothing.
    if definition.outfit ~= nil then
        if not Capabilities.has("zombie.dressInPersistentOutfit") then
            return false, "capability unavailable: zombie.dressInPersistentOutfit"
        end
        local outfitOk, outfitErr = GameAdapter.call(zombie, "dressInPersistentOutfit", definition.outfit)
        if not outfitOk then return false, outfitErr end
        changed = true
        -- Dressing may replace/rebuild the HumanVisual reference.
        visual, reason = AppearanceAdapter.getHumanVisual(zombie)
        if not visual then return false, reason end
    end

    local function set(method, capability, value)
        if value == nil then return true end
        if not Capabilities.has(capability) then return false, "capability unavailable: " .. capability end
        local ok, err = GameAdapter.call(visual, method, value)
        if not ok then return false, err end
        changed = true
        return true
    end

    local ok, err = set("setSkinTextureName", "humanVisual.setSkinTextureName", definition.skinTextureName)
    if not ok then return false, err end
    ok, err = set("setSkinTextureIndex", "humanVisual.setSkinTextureIndex", definition.skinTextureIndex)
    if not ok then return false, err end
    ok, err = set("setHairModel", "humanVisual.setHairModel", definition.hairModel)
    if not ok then return false, err end
    ok, err = set("setBeardModel", "humanVisual.setBeardModel", definition.beardModel)
    if not ok then return false, err end

    if changed and definition.refreshModel ~= false then
        local refreshOk, refreshReason = AppearanceAdapter.refresh(zombie)
        if not refreshOk then return false, refreshReason end
    end

    -- Verify fields that have documented/current getters. This catches native
    -- visual rebuilds that occur synchronously during outfit/model refresh.
    local matched, matchReason = AppearanceAdapter.matches(zombie, definition)
    if matched == false and not string.find(tostring(matchReason), "capability unavailable", 1, true) then
        return false, "appearance verification failed: " .. tostring(matchReason)
    end
    return true, changed and "applied" or "no changes"
end

function AppearanceAdapter.matches(zombie, definition)
    if type(definition) ~= "table" then return false, "appearance definition must be a table" end
    local visual, reason = AppearanceAdapter.getHumanVisual(zombie)
    if not visual then return false, reason end

    local checks = {
        skinTextureName = "getSkinTexture",
        skinTextureIndex = "getSkinTextureIndex",
        hairModel = "getHairModel",
        beardModel = "getBeardModel",
    }
    local compared = false
    for key, getter in pairs(checks) do
        local expected = definition[key]
        if expected ~= nil then
            local capability = "humanVisual." .. getter
            if not Capabilities.has(capability) then return false, "capability unavailable: " .. capability end
            local ok, actual = GameAdapter.call(visual, getter)
            if not ok then return false, actual end
            compared = true
            if tostring(actual) ~= tostring(expected) then return false, "mismatch:" .. key end
        end
    end
    if not compared then return true, "no comparable visual fields" end
    return true, "matched"
end

function AppearanceAdapter.capture(zombie)
    local visual, reason = AppearanceAdapter.getHumanVisual(zombie)
    if not visual then return nil, reason end
    local result = {}
    local getters = {
        skinTextureName = "getSkinTexture",
        skinTextureIndex = "getSkinTextureIndex",
        hairModel = "getHairModel",
        beardModel = "getBeardModel",
    }
    for key, method in pairs(getters) do
        local capability = "humanVisual." .. method
        if Capabilities.has(capability) then
            local ok, value = GameAdapter.call(visual, method)
            if ok then result[key] = value end
        end
    end
    return result
end

return AppearanceAdapter
