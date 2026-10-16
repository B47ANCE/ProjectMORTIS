local Mortis = require "Mortis/init"

if not Mortis.PileSupportProfiles.has("Mortis.VanillaDumpster") then
    Mortis.registerPileSupportProfile({
        id="Mortis.VanillaDumpster",
        priority=100,
        classify=function(facts)
            -- Build 42.20 vanilla tile definitions expose this semantic through
            -- the container property. No sprite-name matching is used.
            if facts.containerType ~= "dumpster" or facts.solid ~= true then return nil end
            return {
                supported=true,
                kind="static-container",
                height=(facts.surfaceHeight and facts.surfaceHeight > 0) and facts.surfaceHeight or 46/96,
                stability=0.85,
                footprintArea=1,
                loadCapacity=300,
                evidence="vanilla container=dumpster + solid; Surface=46 where exposed",
            }
        end,
    })
end

return true
