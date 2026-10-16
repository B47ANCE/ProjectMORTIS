local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local Profiles = { registry = Registry.new("appearance profile") }

local function optionalString(value, name)
    if value == nil then return nil end
    return Util.assertString(value, name)
end

local function normalize(definition)
    if type(definition) ~= "table" then error("appearance profile definition must be a table", 3) end
    local result = Util.deepCopy(definition)
    result.id = Util.assertString(result.id, "appearance profile id")
    result.skinTextureName = optionalString(result.skinTextureName or result.bodyTexture, "skinTextureName")
    result.bodyTexture = nil -- canonical field is skinTextureName
    if result.skinTextureIndex ~= nil then
        result.skinTextureIndex = math.floor(tonumber(result.skinTextureIndex) or -1)
        if result.skinTextureIndex < 0 then error("skinTextureIndex must be >= 0", 3) end
    end
    result.hairModel = optionalString(result.hairModel, "hairModel")
    result.beardModel = optionalString(result.beardModel, "beardModel")
    result.outfit = optionalString(result.outfit, "outfit")
    result.refreshModel = result.refreshModel ~= false
    return result
end

function Profiles.register(definition)
    local normalized = normalize(definition)
    return Profiles.registry:register(normalized.id, normalized)
end
function Profiles.get(id) return Profiles.registry:get(id) end
function Profiles.has(id) return Profiles.registry:has(id) end
function Profiles.all() return Profiles.registry:all() end

return Profiles
