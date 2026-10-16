local Mortis = require "Mortis/init"

Mortis.registerTrait({
    id = "ProjectNightfall.UVVulnerable",
    defaults = { damageMultiplier = 1.0 },
    onUpdate = function(zombie, config, typeDef)
        -- Project Nightfall owns UV detection and damage policy.
        -- M.O.R.T.I.S. only supplies lifecycle/composition infrastructure.
    end,
})

Mortis.registerType({
    id = "ProjectNightfall.Feral",
    displayName = "Feral",
    stats = {
        intelligence = 0.20,
        aggression = 1.00,
    },
    traits = {
        { id = "ProjectNightfall.UVVulnerable", config = { damageMultiplier = 1.0 } },
    },
})

Mortis.registerType({
    id = "ProjectNightfall.FeralFemale",
    displayName = "Feral Female",
    extends = "ProjectNightfall.Feral",
    stats = {
        intelligence = 0.30,
    },
    appearance = {
        sex = "female",
        bodyTexture = "PN_Feral_FemaleBody01",
    },
})

Mortis.registerType({
    id = "ProjectNightfall.SmartFeralFemale",
    displayName = "Smart Feral Female",
    stats = {
        intelligence = 0.90,
        aggression = 0.85,
    },
    traits = {
        { id = "ProjectNightfall.UVVulnerable", config = { damageMultiplier = 0.75 } },
    },
})
