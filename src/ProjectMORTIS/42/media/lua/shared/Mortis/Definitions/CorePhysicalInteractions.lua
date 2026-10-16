local Mortis = require "Mortis/init"

if not Mortis.PhysicalInteractionProviders.registry:has("Mortis.BasicEnvironment") then
    Mortis.registerPhysicalInteractionProvider({
        id = "Mortis.BasicEnvironment",
        priority = -100,

        inspect = function(context)
            local target = context and context.target
            if not target then return {} end

            local square = Mortis.PhysicalEnvironment.square(target)
            local support, supportMethod = Mortis.PhysicalEnvironment.hasSupport(square)

            return {
                supportKnown = support ~= nil,
                hasSupport = support,
                supportProbe = supportMethod,
                -- Low-wall/ledge geometry remains runtime-observed. M.O.R.T.I.S.
                -- does not invent a fall or apply fall damage.
            }
        end,
    })
end


if not Mortis.BalanceProfiles.has("Mortis.DefaultZombieBalance") then
    Mortis.registerBalanceProfile({
        id = "Mortis.DefaultZombieBalance",
        globalCooldownTicks = 45,
        causeCooldownTicks = 75,
        attemptCooldownTicks = 30,
        groupCooldownTicks = 90,
        impactChanceScale = 0.04,
        penetrationChanceScale = 0.02,
        causes = {
            collision = 0.0025,
            ["prone-entity"] = 0.06,
            corpse = 0.04,
            ["random-movement"] = 0.00020,
            stairs = 0.012,
            lunge = 0.025,
            shove = 0.12,
            ["shove-chain"] = 0.20,
            ["melee-hit"] = 0.00,
            ["projectile-hit"] = 0.00,
            ["player-collision"] = 0.015,
        },
        speedMultipliers = {
            sprinter = 1.40,
            fast = 1.15,
            shambler = 1.0,
            crawler = 0.0,
            unknown = 1.0,
        },
    })
end

if not Mortis.CollisionProfiles.has("Mortis.DefaultZombieCollision") then
    Mortis.registerCollisionProfile({
        id = "Mortis.DefaultZombieCollision",
        radius = 0.32,
        mass = 1.0,
        cooldownTicks = 10,
        minRelativeSpeed = 0.025,
        softCollision = true,
        trip = {
            enabled = true,
            baseChance = 0.0, -- centralized in BalanceRuntime
            impactChance = 0.0,
            minImpact = 0.02,
            cooldownTicks = 75,
            canTripOthers = true,
            canBeTripped = true,
            allowMutualTrip = false,
        },
    })
end

return true
