local Mortis = require "Mortis/init"

Mortis.registerSpecies({
    id="Example.Canine", displayName="Canine", defaultRegion="torso",
    regions={
        torso={integrity=130, critical=true},
        head={integrity=55, critical=true, channelMultipliers={crush=1.25}},
        neck={integrity=40, critical=true, severable=true, parent="torso"},
        leftForeleg={integrity=65, severable=true, parent="torso", disableThreshold=18},
        rightForeleg={integrity=65, severable=true, parent="torso", disableThreshold=18},
        leftHindleg={integrity=75, severable=true, parent="torso", disableThreshold=20},
        rightHindleg={integrity=75, severable=true, parent="torso", disableThreshold=20},
        tail={integrity=30, severable=true, parent="torso"},
    }
})

-- Animal mods register a resolver matching their real animal runtime.
-- Mortis.registerEntityResolver({
--   id="Example.CanineResolver", priority=100,
--   matches=function(entity) return MyAnimalAPI.isCanine(entity) end,
--   resolveSpecies=function() return "Example.Canine" end,
-- })

-- Generic trauma works for zombies, players, animals, and custom creatures:
-- Mortis.Trauma.apply(entity, {
--   region="leftArm", channel="chop", magnitude=38,
--   severPower=45, attacker=player, weapon=weapon
-- })

-- Intentional amputation is an extension gameplay rule:
-- Mortis.Trauma.sever(player, "leftArm", {
--   flags={intentional=true, amputation=true}
-- })
