local Mortis = require "Mortis/init"

local Patch = Mortis.beginCompatibilityPatch({
    id = "MORTIS.TargetMod",
    displayName = "M.O.R.T.I.S. - Target Mod Compatibility",
    kind = "patch",
    targetModId = "TARGET_MOD_ID",
    verified = true,
    version = 1,
})

Patch.weapon("TargetMod.HeavyMachete", {
    channel = "chop",
    magnitudeMultiplier = 1.05,
    severPowerMultiplier = 0.95,
    reason = "verified compatibility classification",
})

Patch.weapon("TargetMod.CombatKnife", {
    channel = "pierce",
    magnitudeMultiplier = 0.88,
    severPowerMultiplier = 0.08,
    reason = "verified compatibility classification",
})

return true
