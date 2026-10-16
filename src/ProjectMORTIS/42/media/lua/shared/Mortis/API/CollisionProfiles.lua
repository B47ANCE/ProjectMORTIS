local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local Profiles = { registry = Registry.new("collision profile") }

local function num(value, default, name, minValue)
    if value == nil then return default end
    value = tonumber(value)
    if value == nil then error(name .. " must be numeric", 3) end
    if minValue ~= nil and value < minValue then error(name .. " must be >= " .. tostring(minValue), 3) end
    return value
end

local function normalize(definition)
    if type(definition) ~= "table" then error("collision profile definition must be a table", 3) end
    local result = Util.deepCopy(definition)
    result.id = Util.assertString(result.id, "collision profile id")
    result.enabled = result.enabled ~= false
    result.radius = num(result.radius, 0.32, "collision radius", 0.05)
    result.mass = num(result.mass, 1.0, "collision mass", 0.05)
    result.cooldownTicks = math.floor(num(result.cooldownTicks, 12, "collision cooldownTicks", 1))
    result.minRelativeSpeed = num(result.minRelativeSpeed, 0.015, "collision minRelativeSpeed", 0)
    result.softCollision = result.softCollision ~= false

    result.trip = result.trip or {}
    if type(result.trip) ~= "table" then error("collision trip configuration must be a table", 3) end
    result.trip.enabled = result.trip.enabled == true
    result.trip.baseChance = num(result.trip.baseChance, 0, "trip baseChance", 0)
    if result.trip.baseChance > 1 then error("trip baseChance must be <= 1", 3) end
    result.trip.impactChance = num(result.trip.impactChance, 0.35, "trip impactChance", 0)
    result.trip.minImpact = num(result.trip.minImpact, 0.08, "trip minImpact", 0)
    result.trip.cooldownTicks = math.floor(num(result.trip.cooldownTicks, 90, "trip cooldownTicks", 1))
    result.trip.canTripOthers = result.trip.canTripOthers ~= false
    result.trip.canBeTripped = result.trip.canBeTripped ~= false
    result.trip.allowMutualTrip = result.trip.allowMutualTrip == true
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
