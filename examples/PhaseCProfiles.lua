local Mortis = require "Mortis/init"

Mortis.registerLocomotionProfile({
    id = "ProjectNightfall.FeralLocomotion",
    tier = "sprinter",
})

Mortis.registerLocomotionProfile({
    id = "ProjectNightfall.SmartFeralLocomotion",
    tier = "fastShambler",
})

Mortis.registerDurabilityProfile({
    id = "ProjectNightfall.FeralDurability",
    healthMultiplier = 1.0,
    weaponDamageMultiplier = 1.0,
    damageTypeMultipliers = {
        ["ProjectNightfall.UV"] = 1.5,
    },
})

Mortis.registerDurabilityProfile({
    id = "ProjectNightfall.SmartFeralDurability",
    healthMultiplier = 1.35,
    weaponDamageMultiplier = 0.85,
    damageTypeMultipliers = {
        ["ProjectNightfall.UV"] = 1.15,
    },
})

Mortis.registerAppearanceProfile({
    id = "ProjectNightfall.FeralFemaleAppearance",
    skinTextureName = "PN_Feral_FemaleBody01",
})

Mortis.registerAppearanceProfile({
    id = "ProjectNightfall.SmartFeralFemaleAppearance",
    skinTextureName = "PN_SmartFeral_FemaleBody01",
})

Mortis.registerType({
    id = "ProjectNightfall.FeralFemale",
    displayName = "Feral Female",
    locomotion = "ProjectNightfall.FeralLocomotion",
    durability = "ProjectNightfall.FeralDurability",
    appearance = "ProjectNightfall.FeralFemaleAppearance",
})

Mortis.registerType({
    id = "ProjectNightfall.SmartFeralFemale",
    displayName = "Smart Feral Female",
    locomotion = "ProjectNightfall.SmartFeralLocomotion",
    durability = "ProjectNightfall.SmartFeralDurability",
    appearance = "ProjectNightfall.SmartFeralFemaleAppearance",
})


Mortis.registerCollisionProfile({
    id = "Example.FeralCollision",
    radius = 0.32,
    mass = 1.0,
    cooldownTicks = 12,
    minRelativeSpeed = 0.015,
    trip = {
        enabled = true,
        baseChance = 0.02,
        impactChance = 0.45,
        minImpact = 0.08,
        cooldownTicks = 90,
        canTripOthers = true,
        canBeTripped = true,
        allowMutualTrip = false,
    },
})

-- Attach to a threat definition with:
-- collision = "Example.FeralCollision"
