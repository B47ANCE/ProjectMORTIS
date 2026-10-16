-- Pure, bounded pile semantics. This module never scans the world and never
-- moves an entity; an authoritative observer must supply a local snapshot.
local PileModel = {}

PileModel.Modes = { INCIDENTAL="INCIDENTAL", COMMANDED="COMMANDED" }
PileModel.MAX_CONTRIBUTORS = 64
PileModel.MAX_REGION_AREA = 64
PileModel.MAX_SUPPORT_HEIGHT = 8

local function finite(value, fallback, minimum, maximum)
    value = tonumber(value)
    if value == nil or value ~= value or value == math.huge or value == -math.huge then value = fallback end
    if minimum and value < minimum then value = minimum end
    if maximum and value > maximum then value = maximum end
    return value
end

local function postureFactor(posture)
    if posture == "prone" or posture == "corpse" then return 1 end
    if posture == "crouched" or posture == "kneeling" then return 0.65 end
    return 0.20
end

function PileModel.evaluate(observation)
    if type(observation) ~= "table" then return false, "observation must be a table" end
    local mode = observation.mode or PileModel.Modes.INCIDENTAL
    if mode ~= PileModel.Modes.INCIDENTAL and mode ~= PileModel.Modes.COMMANDED then
        return false, "invalid pile mode"
    end
    if mode == PileModel.Modes.COMMANDED then
        if observation.commanded ~= true or type(observation.orderId) ~= "string" or observation.orderId == "" then
            return false, "commanded pile requires explicit order authority"
        end
    end

    local contributors = observation.contributors
    if type(contributors) ~= "table" then return false, "contributors must be a table" end
    if #contributors > PileModel.MAX_CONTRIBUTORS then return false, "contributor limit exceeded" end
    local regionArea = finite(observation.regionArea, 1, 0.25, PileModel.MAX_REGION_AREA)
    local support = type(observation.support) == "table" and observation.support or {}
    local supportHeight = finite(support.height, 0, 0, PileModel.MAX_SUPPORT_HEIGHT)
    local supportStability = finite(support.stability, supportHeight > 0 and 0.5 or 1, 0, 1)

    local mass, volume, proneMass, livingMass, orientationMoment = 0, 0, 0, 0, 0
    local accepted = 0
    for _, contributor in ipairs(contributors) do
        if type(contributor) == "table" then
            local contributorMass = finite(contributor.mass, 0, 0, 1000)
            local footprint = finite(contributor.footprintArea, 0, 0, 4)
            local thickness = finite(contributor.thickness, 0, 0, 1.5)
            if contributorMass > 0 and footprint > 0 and thickness > 0 then
                local factor = postureFactor(contributor.posture)
                mass = mass + contributorMass
                volume = volume + footprint * thickness * factor
                orientationMoment = orientationMoment + contributorMass * factor
                if factor == 1 then proneMass = proneMass + contributorMass end
                if contributor.living == true then livingMass = livingMass + contributorMass end
                accepted = accepted + 1
            end
        end
    end

    if accepted == 0 then
        return true, { mode=mode, contributorCount=0, effectiveHeight=supportHeight,
            density=0, stability=supportStability, totalMass=0, traversable=false }
    end

    local arealMass = mass / regionArea
    -- Compression is continuous and bounded: added mass still matters, but it
    -- cannot produce linear count-based height forever.
    local compression = 1 / (1 + arealMass / 1400)
    local bodyHeight = math.min(4, (volume / regionArea) * compression)
    local density = math.min(1, volume / regionArea)
    local proneRatio = mass > 0 and proneMass / mass or 0
    local livingRatio = mass > 0 and livingMass / mass or 0
    local alignment = mass > 0 and orientationMoment / mass or 0
    local bodyStability = math.min(1, density * 0.45 + proneRatio * 0.40 + alignment * 0.15)
    bodyStability = bodyStability * (1 - livingRatio * 0.35)
    local stability = math.max(0, math.min(1, bodyStability * supportStability))
    local effectiveHeight = supportHeight + bodyHeight

    return true, {
        mode=mode,
        orderId=mode == PileModel.Modes.COMMANDED and observation.orderId or nil,
        contributorCount=accepted,
        totalMass=mass,
        density=density,
        compression=compression,
        supportHeight=supportHeight,
        bodyHeight=bodyHeight,
        effectiveHeight=effectiveHeight,
        stability=stability,
        livingMassRatio=livingRatio,
        traversable=effectiveHeight > 0.20 and stability >= finite(observation.minimumStability, 0.25, 0, 1),
    }
end

return PileModel
