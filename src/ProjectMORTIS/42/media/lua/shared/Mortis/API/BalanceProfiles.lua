local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local Profiles = { registry = Registry.new("balance profile") }

local function number(value, default, name, minValue, maxValue)
    if value == nil then return default end
    value = tonumber(value)
    if value == nil then error(name .. " must be numeric", 3) end
    if minValue ~= nil and value < minValue then error(name .. " must be >= " .. tostring(minValue), 3) end
    if maxValue ~= nil and value > maxValue then error(name .. " must be <= " .. tostring(maxValue), 3) end
    return value
end

local function normalize(definition)
    if type(definition) ~= "table" then error("balance profile definition must be a table", 3) end
    local d = Util.deepCopy(definition)
    d.id = Util.assertString(d.id, "balance profile id")
    d.enabled = d.enabled ~= false
    d.globalCooldownTicks = math.floor(number(d.globalCooldownTicks, 45, "globalCooldownTicks", 1))
    d.causeCooldownTicks = math.floor(number(d.causeCooldownTicks, 75, "causeCooldownTicks", 1))
    d.impactChanceScale = number(d.impactChanceScale, 0.35, "impactChanceScale", 0)
    d.penetrationChanceScale = number(d.penetrationChanceScale, 0.20, "penetrationChanceScale", 0)
    d.tripOutcome = d.tripOutcome or "native"

    d.causes = d.causes or {}
    d.speedMultipliers = d.speedMultipliers or {
        sprinter = 1.35,
        fast = 1.15,
        shambler = 1.0,
        crawler = 0.0,
        unknown = 1.0,
    }
    d.stateMultipliers = d.stateMultipliers or {}
    d.massResistance = number(d.massResistance, 1.0, "massResistance", 0.05)

    for cause, chance in pairs(d.causes) do
        d.causes[cause] = number(chance, 0, "cause chance " .. tostring(cause), 0, 1)
    end
    return d
end

function Profiles.register(definition)
    local d = normalize(definition)
    return Profiles.registry:register(d.id, d)
end
function Profiles.get(id) return Profiles.registry:get(id) end
function Profiles.has(id) return Profiles.registry:has(id) end
function Profiles.all() return Profiles.registry:all() end

return Profiles
