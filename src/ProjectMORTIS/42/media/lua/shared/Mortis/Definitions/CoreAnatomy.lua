local Mortis = require "Mortis/init"

local channels = {
    { id="cut", structuralMultiplier=.65, bleedMultiplier=.85, severMultiplier=.20 },
    { id="chop", structuralMultiplier=1.0, bleedMultiplier=1.0, severMultiplier=1.0 },
    { id="pierce", structuralMultiplier=.35, bleedMultiplier=.70, severMultiplier=.05 },
    { id="crush", structuralMultiplier=1.0, bleedMultiplier=.25, crushMultiplier=1.0 },
    { id="impact", structuralMultiplier=.60, bleedMultiplier=.15, crushMultiplier=.45 },
    { id="ballistic", structuralMultiplier=.85, bleedMultiplier=.90, crushMultiplier=.35 },
    { id="burn", structuralMultiplier=.25, bleedMultiplier=0 },
}
for _, c in ipairs(channels) do if not Mortis.TraumaChannels.has(c.id) then Mortis.registerTraumaChannel(c) end end

if not Mortis.Species.has("Mortis.Humanoid") then
    Mortis.registerSpecies({
        id="Mortis.Humanoid", displayName="Humanoid", defaultRegion="torso",
        -- Gameplay nutrition per relative tissue unit. These values are a
        -- registered policy surface, not an inference from structural health.
        tissueNutritionDensity={calories=20,proteins=1.5,lipids=1,carbohydrates=0},
        aliases={
            body="torso", chest="torso", back="torso", skull="head", groin="pelvis",
            torso_upper="torso", torso_lower="torso",
            upperarm_l="leftArm", forearm_l="leftArm", hand_l="leftHand",
            upperarm_r="rightArm", forearm_r="rightArm", hand_r="rightHand",
            upperleg_l="leftLeg", lowerleg_l="leftLeg", foot_l="leftFoot",
            upperleg_r="rightLeg", lowerleg_r="rightLeg", foot_r="rightFoot",
            leftupperarm="leftArm", leftforearm="leftArm",
            rightupperarm="rightArm", rightforearm="rightArm",
            lefthand="leftHand", righthand="rightHand",
            leftthigh="leftLeg", leftlowerleg="leftLeg",
            rightthigh="rightLeg", rightlowerleg="rightLeg",
            leftfoot="leftFoot", rightfoot="rightFoot",
        },
        regions={
            -- Relative gameplay tissue units total 100; not measured body mass.
            -- Capacities describe each region alone, excluding its descendants.
            torso={integrity=160, tissueCapacity=32, critical=true},
            head={integrity=70, tissueCapacity=7, critical=true, channelMultipliers={crush=1.35, impact=1.20, ballistic=1.15}},
            neck={integrity=45, tissueCapacity=2, critical=true, severable=true, parent="torso", channelMultipliers={chop=1.30, cut=1.15}},
            pelvis={integrity=110, tissueCapacity=16, parent="torso"},
            leftArm={integrity=85, tissueCapacity=5, severable=true, parent="torso", disableThreshold=20, capabilityModifiers={manipulation=0.25}},
            rightArm={integrity=85, tissueCapacity=5, severable=true, parent="torso", disableThreshold=20, capabilityModifiers={manipulation=0.25}},
            leftHand={integrity=45, tissueCapacity=1.5, severable=true, parent="leftArm", disableThreshold=12, capabilityModifiers={manipulation=0.25,grip=0.5},
                attachmentSockets={distal={socketType="humanoid.leftHand", compatibilityTags={"prosthetic.hand.left"}, availability="missing"}}},
            rightHand={integrity=45, tissueCapacity=1.5, severable=true, parent="rightArm", disableThreshold=12, capabilityModifiers={manipulation=0.25,grip=0.5},
                attachmentSockets={distal={socketType="humanoid.rightHand", compatibilityTags={"prosthetic.hand.right"}, availability="missing"}}},
            leftLeg={integrity=105, tissueCapacity=13, severable=true, parent="pelvis", disableThreshold=25, capabilityModifiers={locomotion=0.35,balance=0.2}},
            rightLeg={integrity=105, tissueCapacity=13, severable=true, parent="pelvis", disableThreshold=25, capabilityModifiers={locomotion=0.35,balance=0.2}},
            leftFoot={integrity=55, tissueCapacity=2, severable=true, parent="leftLeg", disableThreshold=15, capabilityModifiers={locomotion=0.15,balance=0.3}},
            rightFoot={integrity=55, tissueCapacity=2, severable=true, parent="rightLeg", disableThreshold=15, capabilityModifiers={locomotion=0.15,balance=0.3}},
        }
    })
end

if not Mortis.EntityResolvers.registry:has("Mortis.DefaultHumanoid") then
    Mortis.registerEntityResolver({
        id="Mortis.DefaultHumanoid", priority=-100,
        matches=function(entity)
            local kind=Mortis.Entity.kind(entity)
            return kind=="player" or kind=="infected"
        end,
        resolveSpecies=function() return "Mortis.Humanoid" end,
    })
end
return true
