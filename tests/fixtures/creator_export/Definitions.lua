-- MORTIS creator definition. Review and install in a separate content mod.
-- No spawning policy is supplied. Install matching content on server and clients.
local Mortis = require "Mortis/init"
assert(not Mortis.Types.has("CreatorFixture.Example"), "Zombie type ID is already registered")
assert(Mortis.Traits.has("CreatorFixture.RequiredTrait"), "Required traits provider is missing: CreatorFixture.RequiredTrait")
assert(Mortis.Behaviors.has("CreatorFixture.RequiredBehavior"), "Required behaviors provider is missing: CreatorFixture.RequiredBehavior")
Mortis.registerType({
    id = "CreatorFixture.Example",
    displayName = "Fixture \"quoted\" name \\ sample",
    locomotion = { tier = "inherit" },
    durability = { healthMultiplier = 1, damageTakenMultiplier = 1 },
    appearance = {
    },
    traits = {"CreatorFixture.RequiredTrait"},
    behaviors = {"CreatorFixture.RequiredBehavior"},
})
