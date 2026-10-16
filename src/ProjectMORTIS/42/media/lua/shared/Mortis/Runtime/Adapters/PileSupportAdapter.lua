local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local Adapter = {}

local function call(object, method, ...)
    if object == nil then return false, nil end
    return GameAdapter.call(object, method, ...)
end

local function booleanProperty(properties, name)
    if not properties then return nil end
    for _, method in ipairs({ "Is", "has" }) do
        local ok, value = call(properties, method, name)
        if ok then return value == true end
    end
    return nil
end

-- Inspect one object explicitly supplied by a bounded local caller. This never
-- searches a square, cell, chunk, object list or sprite-name catalog.
function Adapter.observe(object)
    if object == nil then return false, "missing support object" end
    local facts = { object=object, source="native-properties" }
    local observed = false

    local okContainer, container = call(object, "getContainer")
    if okContainer and container then
        local okType, containerType = call(container, "getType")
        if okType and type(containerType) == "string" and containerType ~= "" then
            facts.containerType = containerType
            observed = true
        end
    end

    local okSurface, surface = call(object, "getSurfaceOffsetNoTable")
    surface = okSurface and tonumber(surface) or nil
    if surface and surface == surface and surface >= 0 and surface <= 768 then
        facts.surfacePixels = surface
        facts.surfaceHeight = surface / 96
        observed = true
    end

    local okTable, tableSurface = call(object, "isTableSurface")
    if okTable then facts.tableSurface = tableSurface == true; observed = true end

    local okProperties, properties = call(object, "getProperties")
    if okProperties and properties then
        facts.solid = booleanProperty(properties, "solid")
        facts.solidTrans = booleanProperty(properties, "solidtrans")
        if facts.solid ~= nil or facts.solidTrans ~= nil then observed = true end
    end

    if not observed then return false, "no verified support properties exposed" end
    return true, facts
end

return Adapter
