local ScriptItem = {}

local function invoke(object, method, ...)
    if object == nil then return false, nil end
    local ok, fn = pcall(function() return object[method] end)
    if not ok or type(fn) ~= "function" then return false, nil end
    return pcall(fn, object, ...)
end

local function first(object, methods, default)
    for _, method in ipairs(methods) do
        local ok, value = invoke(object, method)
        if ok and value ~= nil then return value, method end
    end
    return default, nil
end

local function text(object, methods, default)
    local value, method = first(object, methods, default)
    return value ~= nil and tostring(value) or default, method
end

local function number(object, methods, default)
    local value, method = first(object, methods, default)
    value = tonumber(value)
    return value ~= nil and value or default, method
end

local function boolean(object, methods, default)
    local value, method = first(object, methods, nil)
    if value == nil then return default, method end
    return value == true, method
end

local function listFromJava(value)
    local out = {}
    if value == nil then return out end

    if type(value) == "table" then
        for _, v in ipairs(value) do out[#out + 1] = tostring(v) end
        if #out > 0 then return out end
    end

    -- Script-item tags are commonly Java Sets. Calling get(i) on a Set inside
    -- pcall still makes Kahlua print an exception for every item, so prefer the
    -- Collection iterator shared by both Sets and Lists.
    local okIter, iterator = pcall(function() return value:iterator() end)
    if okIter and iterator then
        while true do
            local okHas, has = pcall(function() return iterator:hasNext() end)
            if not okHas or not has then break end
            local okNext, item = pcall(function() return iterator:next() end)
            if okNext and item ~= nil then out[#out + 1] = tostring(item) end
        end
        return out
    end

    local okSize, size = pcall(function() return value:size() end)
    if okSize and tonumber(size) then
        for i = 0, tonumber(size) - 1 do
            local okGet, item = pcall(function() return value:get(i) end)
            if okGet and item ~= nil then out[#out + 1] = tostring(item) end
        end
    end
    return out
end

local function list(object, methods)
    for _, method in ipairs(methods) do
        local ok, value = invoke(object, method)
        if ok and value ~= nil then return listFromJava(value), method end
    end
    return {}, nil
end

function ScriptItem.snapshot(script)
    local categories, categoriesMethod = list(script, {
        "getWeaponCategories", -- Build 42.12+ name
        "getCategories",       -- compatibility with older bindings/mod APIs
    })
    local tags, tagsMethod = list(script, { "getTags", "getItemTags" })

    local typeString, typeMethod = text(script, { "getTypeString", "getItemType", "getType" }, nil)
    local fullType, fullTypeMethod = text(script, { "getFullName", "getFullType", "getModuleDotType" }, nil)
    local name = text(script, { "getName", "getItemName" }, nil)
    local displayName = text(script, { "getDisplayName" }, name)

    local result = {
        script = script,
        fullType = fullType,
        type = name,
        displayName = displayName,
        itemType = typeString,
        categories = categories,
        tags = tags,

        damageCategory = text(script, { "getDamageCategory" }, nil),
        weaponSubCategory = text(script, { "getWeaponSubCategory", "getSubCategory" }, nil),
        swingAnim = text(script, { "getSwingAnim" }, nil),

        ranged = boolean(script, { "isRanged", "getRanged" }, false),
        aimedFirearm = boolean(script, { "isAimedFirearm", "getIsAimedFirearm" }, false),
        aimedHandWeapon = boolean(script, { "isAimedHandWeapon", "getIsAimedHandWeapon" }, false),
        twoHanded = boolean(script, { "isTwoHandWeapon", "getTwoHandWeapon", "isTwoHanded" }, false),
        useEndurance = boolean(script, { "isUseEndurance", "getUseEndurance" }, false),

        minDamage = number(script, { "getMinDamage" }, 0),
        maxDamage = number(script, { "getMaxDamage" }, 0),
        knockdownMod = number(script, { "getKnockdownMod" }, 0),
        pushBackMod = number(script, { "getPushBackMod" }, 0),
        enduranceMod = number(script, { "getEnduranceMod" }, 1),
        weaponWeight = number(script, { "getWeaponWeight", "getWeight", "getActualWeight" }, 1),

        obsolete = boolean(script, { "getObsolete", "isObsolete" }, false),
        hidden = boolean(script, { "isHidden", "getHidden" }, false),

        methods = {
            categories = categoriesMethod,
            tags = tagsMethod,
            type = typeMethod,
            fullType = fullTypeMethod,
        },
    }

    return result
end

function ScriptItem.isWeapon(snapshot)
    if type(snapshot) ~= "table" then return false end
    local itemType = string.lower(tostring(snapshot.itemType or ""))
    if itemType == "weapon" or itemType:find("weapon", 1, true) then return true end
    if #snapshot.categories > 0 then return true end
    if snapshot.ranged or snapshot.aimedFirearm or snapshot.aimedHandWeapon then return true end
    return (tonumber(snapshot.maxDamage) or 0) > 0 and snapshot.swingAnim ~= nil
end

return ScriptItem
