local Environment = require "Mortis/Runtime/Adapters/PhysicalEnvironmentAdapter"
local Collision = require "Mortis/Runtime/Adapters/CollisionAdapter"
local Authority = require "Mortis/Runtime/Authority"
local Trauma = require "Mortis/Runtime/TraumaRuntime"
local HitLocation = require "Mortis/Runtime/Adapters/HitLocationAdapter"
local Anatomy = require "Mortis/Runtime/AnatomyRuntime"
local Species = require "Mortis/API/Species"

local Stomp = {}

local function tracked()
    local Mortis = rawget(_G, "Mortis")
    return Mortis and Mortis.Engine and Mortis.Engine.listTracked and Mortis.Engine.listTracked() or {}
end

local function distanceSquared(a, b)
    local ax, ay, az = Collision.position(a)
    local bx, by, bz = Collision.position(b)
    if not ax or not bx or math.abs(az-bz) > 0.25 then return nil end
    local dx, dy = bx-ax, by-ay
    return dx*dx + dy*dy
end

function Stomp.acquireTarget(attacker, options)
    options = options or {}
    local maxRange = tonumber(options.range) or 1.45
    local best, bestD2

    for _, candidate in ipairs(options.candidates or tracked()) do
        if candidate ~= attacker then
            local prone = Environment.isProne(candidate)
            if prone == true then
                local d2 = distanceSquared(attacker, candidate)
                if d2 and d2 <= maxRange*maxRange and (bestD2 == nil or d2 < bestD2) then
                    best, bestD2 = candidate, d2
                end
            end
        end
    end
    return best, bestD2 and math.sqrt(bestD2) or nil
end

function Stomp.validate(attacker, target, options)
    options = options or {}
    if not target then return false, "no target" end
    if not Authority.canWriteCanonicalState(target) then return false, "non-authority" end

    local prone = Environment.isProne(target)
    if prone ~= true then return false, "target not prone/grounded" end

    local d2 = distanceSquared(attacker, target)
    local maxRange = tonumber(options.range) or 1.45
    if not d2 or d2 > maxRange*maxRange then return false, "target out of range" end
    return true
end

-- Only use this when a caller has independently confirmed that vanilla's stomp
-- animation/action executed but failed to apply the expected hit. This avoids
-- double damage.
function Stomp.repairMiss(attacker, target, bodyPart, damage, options)
    options = options or {}
    if options.vanillaMissed ~= true then
        return false, "repair requires vanillaMissed=true"
    end

    local valid, reason = Stomp.validate(attacker, target, options)
    if not valid then return false, reason end

    local anatomy, err = Anatomy.ensure(target)
    if not anatomy then return false, err end
    local species = Species.get(anatomy.speciesId)
    if not species then return false, "missing species" end
    local region = HitLocation.resolve(species, bodyPart)

    local magnitude = math.max(0, tonumber(damage) or 0) *
        (tonumber(options.damageToTrauma) or 30)

    local ok, result = Trauma.apply(target, {
        region = region,
        bodyPart = bodyPart,
        channel = "crush",
        magnitude = magnitude,
        crushPower = magnitude * (tonumber(options.crushPowerMultiplier) or 1.15),
        attacker = attacker,
        source = "stomp-repair",
        flags = { stomp=true, vanillaRepair=true },
    })

    local Mortis = rawget(_G, "Mortis")
    if ok and Mortis and Mortis.Events then
        Mortis.Events:emit("StompMissRepaired", target, result)
    end
    return ok, result
end

return Stomp
