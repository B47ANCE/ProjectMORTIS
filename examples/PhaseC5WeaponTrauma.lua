local Mortis = require "Mortis/init"

-- Third-party weapon mods can override classification without patching core.
Mortis.registerWeaponTraumaClassifier({
    id = "Example.ExecutionerAxe",
    priority = 1000,

    matches = function(weapon, snapshot)
        return snapshot.fullType == "Example.ExecutionerAxe"
    end,

    classify = function(weapon, snapshot)
        return {
            channel = "chop",
            magnitudeMultiplier = 1.35,
            severPowerMultiplier = 1.60,
            confidence = "exact",
            reason = "explicit mod weapon classifier",
        }
    end,
})

-- Generic trusted hit route for an extension that has an exact body part:
--
-- Mortis.Engine.applyLivingHitTrauma(
--     target,
--     attacker,
--     bodyPart,
--     weapon,
--     damage,
--     { source = "MyMod.CustomCombat" }
-- )
