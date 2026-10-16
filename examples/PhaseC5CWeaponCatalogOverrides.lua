local Mortis = require "Mortis/init"

-- C5C automatically scans ScriptManager's final item registry, including
-- weapon mods. Long/Short Blade entries are intentionally recommendations when
-- "chop vs cut vs pierce" cannot be inferred confidently.

-- Human-confirmed override:
Mortis.registerWeaponCatalogOverride("SomeWeaponMod.HeavyMachete", {
    channel = "chop",
    magnitudeMultiplier = 1.05,
    severPowerMultiplier = 0.95,
    notes = "Confirmed: heavy forward-weighted machete",
})

-- Runtime/dev-session confirmation is also possible:
-- Mortis.WeaponCatalog.confirm("SomeWeaponMod.Cleaver", {
--     channel = "chop",
--     severPowerMultiplier = 0.80,
--     notes = "Reviewed in-game",
-- })

-- Useful review APIs:
-- Mortis.WeaponCatalog.getLongSharp()
-- Mortis.WeaponCatalog.getShortSharp()
-- Mortis.WeaponCatalog.getReviewQueue()
-- print(Mortis.WeaponCatalog.formatReviewReport())
