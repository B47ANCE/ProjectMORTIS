local Model = require 'Mortis/Creator/Model'
local Types = require 'Mortis/API/Types'
local Traits = require 'Mortis/API/Traits'
local Behaviors = require 'Mortis/API/Behaviors'
local Profiles = require 'Mortis/Runtime/ProfileRuntime'
local root = 'tests/fixtures/creator_export/'
local draft = dofile(root .. 'draft.lua')
local file = assert(io.open(root .. 'Definitions.lua', 'rb'))
local golden = file:read('*a'); file:close()
assert(Model.export(draft) == golden, 'reviewed export fixture differs from the generator')
assert(not Types.has(draft.id), 'draft/export must not register content')

-- Only bootstrap is substituted. Registries and profile interpretation are real.
-- No fake provider is shipped in runtime source; these markers exercise guards.
local originalRequire = require
local registrations = 0
require = function(name)
    if name == 'Mortis/init' then
        return {Types=Types, Traits=Traits, Behaviors=Behaviors,
            registerType=function(definition)
                registrations = registrations + 1
                return Types.register(definition)
            end}
    end
    return originalRequire(name)
end
local function install() return assert(loadstring(golden, '@creator-export-fixture'))() end
local ok, err = pcall(install)
assert(not ok and tostring(err):find('Required traits provider is missing', 1, true))
assert(registrations == 0 and not Types.has(draft.id))
Traits.register({id='CreatorFixture.RequiredTrait'})
ok, err = pcall(install)
assert(not ok and tostring(err):find('Required behaviors provider is missing', 1, true))
assert(registrations == 0 and not Types.has(draft.id))
Behaviors.register({id='CreatorFixture.RequiredBehavior'})
install()
assert(registrations == 1)
local installed = assert(Types.get(draft.id))
assert(installed.displayName == draft.displayName)
assert(Profiles.resolveLocomotion(installed).tier == 'inherit')
assert(Profiles.resolveDurability(installed).healthMultiplier == 1)
assert(Profiles.resolveDurability(installed).damageTakenMultiplier == 1)
assert(next(Profiles.resolveAppearance(installed)) == nil)
assert(next(installed.spawn) == nil, 'fixture must not supply a spawn policy')
assert(installed.traits[1] == 'CreatorFixture.RequiredTrait')
assert(installed.behaviors[1] == 'CreatorFixture.RequiredBehavior')
local before = Types.get(draft.id)
ok, err = pcall(install)
assert(not ok and tostring(err):find('already registered', 1, true))
assert(registrations == 1 and Types.get(draft.id).displayName == before.displayName)
require = originalRequire
print('Reviewed creator golden export, provider guards and duplicate preservation pass')
