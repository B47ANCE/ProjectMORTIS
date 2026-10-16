local Species = require "Mortis/API/Species"
local HitLocation = {}

local function text(value)
    if value == nil then return nil end
    if type(value) == "string" then return value end
    for _, method in ipairs({ "toString", "name", "getType", "getDisplayName" }) do
        local ok, result = pcall(function()
            local fn = value[method]
            return type(fn) == "function" and fn(value) or nil
        end)
        if ok and result ~= nil then return tostring(result) end
    end
    return tostring(value)
end

function HitLocation.resolve(speciesOrId, bodyPart)
    local species = type(speciesOrId) == "table" and speciesOrId or Species.get(speciesOrId)
    if not species then return nil end
    local candidate = text(bodyPart)
    if candidate then
        local direct = Species.resolveRegion(species, candidate)
        if direct then return direct, candidate end
        local compact = string.lower(candidate):gsub("[^%w]", "")
        for alias, target in pairs(species._aliasMap or {}) do
            if string.lower(alias):gsub("[^%w]", "") == compact then return target, candidate end
        end
    end
    return species.defaultRegion, candidate
end
return HitLocation
