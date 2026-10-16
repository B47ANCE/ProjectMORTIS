local Mortis = require "Mortis/init"

local PROVIDER = "Mortis.Vanilla"

if not Mortis.WeaponCompatibility.getProvider(PROVIDER) then
    Mortis.registerWeaponCompatibilityProvider({
        id = PROVIDER,
        displayName = "Project M.O.R.T.I.S. Vanilla",
        kind = "core",
        targetModId = "Base",
        verified = true,
        version = 1,
    })
end

local function weapon(fullType, channel, data)
    data = data or {}
    data.channel = channel
    Mortis.registerVerifiedWeapon(PROVIDER, fullType, data)
end

-- Explicit vanilla classifications.
-- This list is intentionally data, not heuristics. It grows only when an item
-- has been reviewed against the installed/current vanilla scripts.
weapon("Base.Axe", "chop", {
    magnitudeMultiplier = 1.15, severPowerMultiplier = 1.25,
    reason = "verified vanilla axe",
})
weapon("Base.HandAxe", "chop", {
    magnitudeMultiplier = 1.05, severPowerMultiplier = 1.00,
    reason = "verified vanilla hand axe",
})
weapon("Base.WoodAxe", "chop", {
    magnitudeMultiplier = 1.20, severPowerMultiplier = 1.30,
    reason = "verified vanilla wood axe",
})
weapon("Base.Machete", "chop", {
    magnitudeMultiplier = 1.05, severPowerMultiplier = 0.90,
    reason = "verified vanilla heavy chopping blade",
})
weapon("Base.Katana", "cut", {
    magnitudeMultiplier = 1.10, severPowerMultiplier = 0.70,
    reason = "verified vanilla long cutting blade",
})
weapon("Base.MeatCleaver", "chop", {
    magnitudeMultiplier = 0.95, severPowerMultiplier = 0.72,
    reason = "verified vanilla cleaver",
})
weapon("Base.HuntingKnife", "pierce", {
    magnitudeMultiplier = 0.88, severPowerMultiplier = 0.08,
    reason = "verified vanilla hunting knife primary trauma",
})
weapon("Base.KitchenKnife", "cut", {
    magnitudeMultiplier = 0.82, severPowerMultiplier = 0.12,
    reason = "verified vanilla kitchen knife",
})
weapon("Base.BreadKnife", "cut", {
    magnitudeMultiplier = 0.72, severPowerMultiplier = 0.08,
    reason = "verified vanilla serrated kitchen blade",
})
weapon("Base.Screwdriver", "pierce", {
    magnitudeMultiplier = 0.70, severPowerMultiplier = 0.02,
    reason = "verified vanilla piercing tool",
})
weapon("Base.Crowbar", "crush", {
    magnitudeMultiplier = 1.00, crushPowerMultiplier = 0.95,
    reason = "verified vanilla blunt weapon",
})
weapon("Base.BaseballBat", "crush", {
    magnitudeMultiplier = 0.95, crushPowerMultiplier = 0.82,
    reason = "verified vanilla blunt weapon",
})
weapon("Base.Sledgehammer", "crush", {
    magnitudeMultiplier = 1.25, crushPowerMultiplier = 1.40,
    reason = "verified vanilla heavy blunt weapon",
})
weapon("Base.Sledgehammer2", "crush", {
    magnitudeMultiplier = 1.25, crushPowerMultiplier = 1.40,
    reason = "verified vanilla heavy blunt variant",
})
weapon("Base.Hammer", "crush", {
    magnitudeMultiplier = 0.82, crushPowerMultiplier = 0.75,
    reason = "verified vanilla hammer",
})
weapon("Base.BallPeenHammer", "crush", {
    magnitudeMultiplier = 0.84, crushPowerMultiplier = 0.80,
    reason = "verified vanilla hammer",
})
weapon("Base.ClubHammer", "crush", {
    magnitudeMultiplier = 0.92, crushPowerMultiplier = 0.90,
    reason = "verified vanilla club hammer",
})
weapon("Base.MetalBar", "crush", {
    magnitudeMultiplier = 0.88, crushPowerMultiplier = 0.82,
    reason = "verified vanilla improvised blunt weapon",
})
weapon("Base.MetalPipe", "crush", {
    magnitudeMultiplier = 0.88, crushPowerMultiplier = 0.82,
    reason = "verified vanilla improvised blunt weapon",
})
weapon("Base.Nightstick", "crush", {
    magnitudeMultiplier = 0.84, crushPowerMultiplier = 0.76,
    reason = "verified vanilla blunt weapon",
})

return true
