local Settings = {}

local DEFAULTS = {
    EnableCollisionTrips = true,
    EnableProneTrips = true,
    EnableCorpseTrips = true,
    EnableRandomTrips = true,
    EnableStairTrips = true,
    EnableLungeTrips = true,
    EnablePlayerCollisionTrips = true,
    EnableShoveDomino = true,
    EnableStompRepair = true,
    EnableRagdollTrips = false,
    EnableSoftSeparation = true,

    GlobalTripChanceMultiplier = 1.0,
    RandomTripChanceMultiplier = 1.0,
    CollisionTripChanceMultiplier = 1.0,
    ProneTripChanceMultiplier = 1.0,
    CorpseTripChanceMultiplier = 1.0,
    StairTripChanceMultiplier = 1.0,
    LungeTripChanceMultiplier = 1.0,
    ShoveTripChanceMultiplier = 1.0,
    TripCooldownMultiplier = 1.0,
    GroupPileThrottleMultiplier = 1.0,
    PlayerCollisionTripChance = 0.08,
    ShoveDominoMaxChain = 3,
    ShoveDominoImpulseDecay = 0.65,
    StompRepairRange = 1.45,
    SoftSeparationStrength = 0.35,
    SoftSeparationMaxCorrection = 0.08,
}

local function sandbox()
    local vars = rawget(_G, "SandboxVars")
    return vars and vars.MORTISPhysical or nil
end

function Settings.get(name)
    local vars = sandbox()
    if vars and vars[name] ~= nil then return vars[name] end
    return DEFAULTS[name]
end

function Settings.bool(name)
    return Settings.get(name) == true
end

function Settings.number(name)
    return tonumber(Settings.get(name)) or tonumber(DEFAULTS[name]) or 0
end

function Settings.snapshot()
    local result = {}
    for name in pairs(DEFAULTS) do result[name] = Settings.get(name) end
    return result
end

function Settings.defaults()
    local result = {}
    for k, v in pairs(DEFAULTS) do result[k] = v end
    return result
end

return Settings
