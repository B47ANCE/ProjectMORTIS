local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local Corpse = {}

local function iterCollection(collection, callback)
    if collection == nil then return end
    if type(collection) == "table" then
        for _, value in ipairs(collection) do callback(value) end
        return
    end
    local okSize, size = pcall(function() return collection:size() end)
    if okSize and tonumber(size) then
        for i=0, tonumber(size)-1 do
            local okGet, value = pcall(function() return collection:get(i) end)
            if okGet and value ~= nil then callback(value) end
        end
    end
end

function Corpse.isCorpse(object)
    if object == nil then return false end
    for _, method in ipairs({ "isDeadBody", "isCorpse" }) do
        local ok, value = GameAdapter.call(object, method)
        if ok and value == true then return true end
    end

    for _, method in ipairs({ "getObjectName", "getType" }) do
        local ok, value = GameAdapter.call(object, method)
        if ok and value ~= nil then
            local lower = string.lower(tostring(value))
            if lower:find("deadbody", 1, true) or lower:find("corpse", 1, true) then
                return true
            end
        end
    end
    return false
end

function Corpse.onSquare(square)
    local result = {}
    if not square then return result end

    for _, method in ipairs({ "getStaticMovingObjects", "getMovingObjects", "getObjects" }) do
        local ok, collection = GameAdapter.call(square, method)
        if ok and collection ~= nil then
            iterCollection(collection, function(object)
                if Corpse.isCorpse(object) then result[#result+1] = object end
            end)
        end
    end
    return result
end

function Corpse.under(entity)
    local ok, square = GameAdapter.call(entity, "getSquare")
    if not ok then return {} end
    return Corpse.onSquare(square)
end

return Corpse
