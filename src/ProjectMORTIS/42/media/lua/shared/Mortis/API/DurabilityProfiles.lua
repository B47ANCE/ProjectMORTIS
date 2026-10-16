local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local Profiles = { registry = Registry.new("durability profile") }

local function positive(value, name, default)
    if value == nil then return default end
    value = tonumber(value)
    if not value or value <= 0 then error(name .. " must be > 0", 3) end
    return value
end

local function normalize(definition)
    if type(definition) ~= "table" then error("durability profile definition must be a table", 3) end
    local result = Util.deepCopy(definition)
    result.id = Util.assertString(result.id, "durability profile id")
    result.healthMultiplier = positive(result.healthMultiplier, "healthMultiplier", 1.0)
    result.damageTakenMultiplier = positive(result.damageTakenMultiplier, "damageTakenMultiplier", 1.0)
    result.weaponDamageMultiplier = positive(result.weaponDamageMultiplier, "weaponDamageMultiplier", result.damageTakenMultiplier)
    result.environmentDamageMultiplier = positive(result.environmentDamageMultiplier, "environmentDamageMultiplier", result.damageTakenMultiplier)
    result.fireDamageMultiplier = positive(result.fireDamageMultiplier, "fireDamageMultiplier", result.environmentDamageMultiplier)
    result.vehicleDamageMultiplier = positive(result.vehicleDamageMultiplier, "vehicleDamageMultiplier", result.damageTakenMultiplier)
    result.staggerMultiplier = positive(result.staggerMultiplier, "staggerMultiplier", 1.0)

    if result.damageTypeMultipliers ~= nil then
        if type(result.damageTypeMultipliers) ~= "table" then
            error("damageTypeMultipliers must be a table", 3)
        end
        local copy = {}
        for key, value in pairs(result.damageTypeMultipliers) do
            if type(key) ~= "string" or key == "" then error("damageTypeMultipliers keys must be strings", 3) end
            copy[key] = positive(value, "damageTypeMultipliers." .. key, 1.0)
        end
        result.damageTypeMultipliers = copy
    else
        result.damageTypeMultipliers = {}
    end
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
