local EventBus = require "Mortis/Core/EventBus"
local Logger = require "Mortis/Core/Logger"
local Types = require "Mortis/API/Types"
local Traits = require "Mortis/API/Traits"
local Behaviors = require "Mortis/API/Behaviors"
local ComponentSchemas = require "Mortis/API/Components"
local Capabilities = require "Mortis/API/Capabilities"
local Components = require "Mortis/Runtime/Components"
local Identity = require "Mortis/Runtime/Identity"
local Persistence = require "Mortis/Runtime/Persistence"
local Authority = require "Mortis/Runtime/Authority"
local Context = require "Mortis/Runtime/Context"
local Engine = require "Mortis/Runtime/Engine"
local Scheduler = require "Mortis/Core/Scheduler"
local FaultIsolation = require "Mortis/Core/FaultIsolation"
local Profiler = require "Mortis/Core/Profiler"
local Random = require "Mortis/Core/Random"
local Diagnostics = require "Mortis/Core/Diagnostics"
local ActionDiagnostics = require "Mortis/Core/ActionDiagnostics"
local Target = require "Mortis/Runtime/Adapters/TargetAdapter"
local Navigation = require "Mortis/Runtime/Adapters/NavigationAdapter"
local Locomotion = require "Mortis/Runtime/Adapters/LocomotionAdapter"
local Combat = require "Mortis/Runtime/Adapters/CombatAdapter"
local Durability = require "Mortis/Runtime/Adapters/DurabilityAdapter"
local Obstacles = require "Mortis/Runtime/Adapters/ObstacleAdapter"
local Environment = require "Mortis/Runtime/Adapters/EnvironmentAdapter"
local Animation = require "Mortis/Runtime/Adapters/AnimationAdapter"
local State = require "Mortis/Runtime/Adapters/StateAdapter"
local Appearance = require "Mortis/Runtime/Adapters/AppearanceAdapter"
local Network = require "Mortis/Runtime/Adapters/NetworkAdapter"
local PersistenceAdapter = require "Mortis/Runtime/Adapters/PersistenceAdapter"
local Sound = require "Mortis/Runtime/Adapters/SoundAdapter"
local Groups = require "Mortis/Runtime/Adapters/GroupAdapter"
local CommandHierarchy = require "Mortis/Runtime/CommandHierarchy"
local LocationMemory = require "Mortis/Runtime/LocationMemory"
local InfectedSignals = require "Mortis/Runtime/InfectedSignals"
local Spawn = require "Mortis/Runtime/Adapters/SpawnAdapter"
local Replication = require "Mortis/Runtime/Replication"
local LocomotionProfiles = require "Mortis/API/LocomotionProfiles"
local DurabilityProfiles = require "Mortis/API/DurabilityProfiles"
local AppearanceProfiles = require "Mortis/API/AppearanceProfiles"
local ProfileRuntime = require "Mortis/Runtime/ProfileRuntime"
local DamageRuntime = require "Mortis/Runtime/DamageRuntime"
local CollisionProfiles = require "Mortis/API/CollisionProfiles"
local CollisionRuntime = require "Mortis/Runtime/CollisionRuntime"
local Collision = require "Mortis/Runtime/Adapters/CollisionAdapter"
local Trip = require "Mortis/Runtime/Adapters/TripAdapter"
local Species = require "Mortis/API/Species"
local TraumaChannels = require "Mortis/API/TraumaChannels"
local EntityResolvers = require "Mortis/API/EntityResolvers"
local Entity = require "Mortis/Runtime/Adapters/EntityAdapter"
local Anatomy = require "Mortis/Runtime/AnatomyRuntime"
local TissueModel = require "Mortis/Runtime/TissueModel"
local DetachedMaterialModel = require "Mortis/Runtime/DetachedMaterialModel"
local BiologicalMaterial = require "Mortis/API/BiologicalMaterial"
local DecompositionPolicies = require "Mortis/API/DecompositionPolicies"
local DecompositionRuntime = require "Mortis/Runtime/DecompositionRuntime"
local AnatomyAttachments = require "Mortis/API/AnatomyAttachments"
local AnatomyCapabilities = require "Mortis/API/AnatomyCapabilities"
local Trauma = require "Mortis/Runtime/TraumaRuntime"
local HitLocation = require "Mortis/Runtime/Adapters/HitLocationAdapter"
local Weapon = require "Mortis/Runtime/Adapters/WeaponAdapter"
local WeaponTraumaClassifiers = require "Mortis/API/WeaponTraumaClassifiers"
local HitTrauma = require "Mortis/Runtime/HitTraumaRuntime"
local WeaponCatalogOverrides = require "Mortis/API/WeaponCatalogOverrides"
local WeaponCatalog = require "Mortis/Runtime/WeaponCatalog"
local ScriptItem = require "Mortis/Runtime/Adapters/ScriptItemAdapter"
local WeaponCompatibility = require "Mortis/API/WeaponCompatibility"
local CompatibilityPatch = require "Mortis/API/CompatibilityPatch"
local AttackKinds = require "Mortis/API/AttackKinds"
local PhysicalInteractionProviders = require "Mortis/API/PhysicalInteractionProviders"
local AnatomyConsequenceProviders = require "Mortis/API/AnatomyConsequenceProviders"
local AnatomyConsequences = require "Mortis/Runtime/AnatomyConsequenceRuntime"
local PhysicalEnvironment = require "Mortis/Runtime/Adapters/PhysicalEnvironmentAdapter"
local PhysicalInteractions = require "Mortis/Runtime/PhysicalInteractionRuntime"
local BalanceProfiles = require "Mortis/API/BalanceProfiles"
local Balance = require "Mortis/Runtime/BalanceRuntime"
local MovementBalance = require "Mortis/Runtime/MovementBalanceRuntime"
local Corpse = require "Mortis/Runtime/Adapters/CorpseAdapter"
local CollisionResponse = require "Mortis/Runtime/Adapters/CollisionResponseAdapter"
local ShoveRuntime = require "Mortis/Runtime/ShoveRuntime"
local StompRuntime = require "Mortis/Runtime/StompRuntime"
local PhysicalSettings = require "Mortis/Runtime/PhysicalSettings"
local Ragdoll = require "Mortis/Runtime/Adapters/RagdollAdapter"
local CharacterCollision = require "Mortis/Runtime/CharacterCollisionRuntime"
local PhysicalAttackObserver = require "Mortis/Runtime/PhysicalAttackObserver"
local WallSafeSeparation = require "Mortis/Runtime/WallSafeSeparationRuntime"
local DeveloperReports = require "Mortis/Runtime/DeveloperReports"
local LocomotionOverrides = require "Mortis/Runtime/LocomotionOverrides"
local CrowdFlow = require "Mortis/Runtime/CrowdFlowRuntime"
local FoodSources = require "Mortis/API/FoodSources"
local ZombieHunger = require "Mortis/Runtime/ZombieHungerRuntime"
local DetachedParts = require "Mortis/API/DetachedParts"
local SystemSettings = require "Mortis/Runtime/SystemSettings"
local Compatibility = require "Mortis/API/Compatibility"
local PileModel = require "Mortis/Runtime/PileModel"
local PileSupportProfiles = require "Mortis/API/PileSupportProfiles"
local PileObservations = require "Mortis/Runtime/PileObservationRuntime"
local PileTraversalLinks = require "Mortis/Runtime/PileTraversalLinks"

local Mortis = rawget(_G, "Mortis") or {}
Mortis.VERSION = "0.24.0-dev.1"
Mortis.Types = Types
Mortis.Traits = Traits
Mortis.Behaviors = Behaviors
Mortis.ComponentSchemas = ComponentSchemas
Mortis.Capabilities = Capabilities
Mortis.Components = Components
Mortis.Identity = Identity
Mortis.Persistence = Persistence
Mortis.Authority = Authority
Mortis.Context = Context
Mortis.Engine = Engine
Mortis.Scheduler = Scheduler
Mortis.FaultIsolation = FaultIsolation
Mortis.Profiler = Profiler
Mortis.Random = Random
Mortis.Diagnostics = Diagnostics
Mortis.ActionDiagnostics = ActionDiagnostics
Mortis.Target = Target
Mortis.Navigation = Navigation
Mortis.Locomotion = Locomotion
Mortis.Combat = Combat
Mortis.Durability = Durability
Mortis.Obstacles = Obstacles
Mortis.Environment = Environment
Mortis.Animation = Animation
Mortis.State = State
Mortis.Appearance = Appearance
Mortis.Network = Network
Mortis.PersistenceAdapter = PersistenceAdapter
Mortis.Sound = Sound
Mortis.Groups = Groups
Mortis.CommandHierarchy = CommandHierarchy
Mortis.LocationMemory = LocationMemory
Mortis.Signals = InfectedSignals
Mortis.Spawn = Spawn
Mortis.Replication = Replication
Mortis.LocomotionProfiles = LocomotionProfiles
Mortis.DurabilityProfiles = DurabilityProfiles
Mortis.AppearanceProfiles = AppearanceProfiles
Mortis.Profiles = ProfileRuntime
Mortis.DamageRuntime = DamageRuntime
Mortis.CollisionProfiles = CollisionProfiles
Mortis.CollisionRuntime = CollisionRuntime
Mortis.Collision = Collision
Mortis.Trip = Trip
Mortis.Piles = PileModel
Mortis.PileSupportProfiles = PileSupportProfiles
Mortis.PileObservations = PileObservations
Mortis.PileTraversalLinks = PileTraversalLinks
Mortis.Species = Species
Mortis.TraumaChannels = TraumaChannels
Mortis.EntityResolvers = EntityResolvers
Mortis.Entity = Entity
Mortis.Anatomy = Anatomy
Mortis.TissueModel = TissueModel
Mortis.DetachedMaterialModel = DetachedMaterialModel
Mortis.BiologicalMaterial = BiologicalMaterial
Mortis.DecompositionPolicies = DecompositionPolicies
Mortis.DecompositionRuntime = DecompositionRuntime
Mortis.AnatomyAttachments = AnatomyAttachments
Mortis.AnatomyCapabilities = AnatomyCapabilities
Mortis.Trauma = Trauma
Mortis.SystemicTrauma = require "Mortis/Runtime/SystemicTrauma"
Mortis.ClothingCoverage = require "Mortis/Runtime/ClothingCoverage"
Mortis.HitLocation = HitLocation
Mortis.Weapon = Weapon
Mortis.WeaponTraumaClassifiers = WeaponTraumaClassifiers
Mortis.HitTrauma = HitTrauma
Mortis.WeaponCatalogOverrides = WeaponCatalogOverrides
Mortis.WeaponCatalog = WeaponCatalog
Mortis.ScriptItem = ScriptItem
Mortis.WeaponCompatibility = WeaponCompatibility
Mortis.CompatibilityPatch = CompatibilityPatch
Mortis.AttackKinds = AttackKinds
Mortis.PhysicalInteractionProviders = PhysicalInteractionProviders
Mortis.AnatomyConsequenceProviders = AnatomyConsequenceProviders
Mortis.AnatomyConsequences = AnatomyConsequences
Mortis.PhysicalEnvironment = PhysicalEnvironment
Mortis.PhysicalInteractions = PhysicalInteractions
Mortis.BalanceProfiles = BalanceProfiles
Mortis.Balance = Balance
Mortis.MovementBalance = MovementBalance
Mortis.Corpse = Corpse
Mortis.CollisionResponse = CollisionResponse
Mortis.ShoveRuntime = ShoveRuntime
Mortis.StompRuntime = StompRuntime
Mortis.PhysicalSettings = PhysicalSettings
Mortis.Ragdoll = Ragdoll
Mortis.CharacterCollision = CharacterCollision
Mortis.PhysicalAttackObserver = PhysicalAttackObserver
Mortis.WallSafeSeparation = WallSafeSeparation
Mortis.DeveloperReports = DeveloperReports
Mortis.LocomotionOverrides = LocomotionOverrides
Mortis.CrowdFlow = CrowdFlow
Mortis.FoodSources = FoodSources
Mortis.ZombieHunger = ZombieHunger
Mortis.DetachedParts = DetachedParts
Mortis.SystemSettings = SystemSettings
Mortis.VERSION = "0.23.2"
Mortis.API_VERSION = Compatibility.VERSION
Mortis.Compatibility = Compatibility
Mortis.Events = Mortis.Events or EventBus.new()
Mortis.Log = Logger

function Mortis.negotiateAPI(request) return Compatibility.negotiate(Mortis,request) end

function Mortis.registerType(definition) return Types.register(definition) end
function Mortis.registerTrait(definition) return Traits.register(definition) end
function Mortis.registerBehavior(definition) return Behaviors.register(definition) end
function Mortis.registerComponent(definition) return ComponentSchemas.register(definition) end
function Mortis.registerLocomotionProfile(definition) return LocomotionProfiles.register(definition) end
function Mortis.registerDurabilityProfile(definition) return DurabilityProfiles.register(definition) end
function Mortis.registerAppearanceProfile(definition) return AppearanceProfiles.register(definition) end
function Mortis.registerCollisionProfile(definition) return CollisionProfiles.register(definition) end
function Mortis.registerSpecies(definition) return Species.register(definition) end
function Mortis.registerAnatomyAttachment(definition) return AnatomyAttachments.register(definition) end
function Mortis.registerTraumaChannel(definition) return TraumaChannels.register(definition) end
function Mortis.registerEntityResolver(definition) return EntityResolvers.register(definition) end
function Mortis.registerWeaponTraumaClassifier(definition) return WeaponTraumaClassifiers.register(definition) end
function Mortis.registerAnatomyConsequenceProvider(definition)
    return AnatomyConsequenceProviders.register(definition)
end
function Mortis.registerWeaponCatalogOverride(fullType, definition)
    return WeaponCatalogOverrides.register(fullType, definition)
end

function Mortis.registerWeaponCompatibilityProvider(definition)
    return WeaponCompatibility.registerProvider(definition)
end

function Mortis.registerVerifiedWeapon(providerId, fullType, definition)
    return WeaponCompatibility.registerWeapon(providerId, fullType, definition)
end

function Mortis.beginCompatibilityPatch(definition)
    return CompatibilityPatch.begin(definition)
end

function Mortis.registerPhysicalInteractionProvider(definition)
    return PhysicalInteractionProviders.register(definition)
end

function Mortis.registerPileSupportProfile(definition)
    return PileSupportProfiles.register(definition)
end

function Mortis.registerBalanceProfile(definition)
    return BalanceProfiles.register(definition)
end

function Mortis.registerFoodSourceProvider(definition)
    return FoodSources.register(definition)
end

function Mortis.registerDetachedPartClassifier(definition)
    return DetachedParts.registerClassifier(definition)
end

function Mortis.registerDecompositionPolicy(definition)
    return DecompositionPolicies.register(definition)
end


-- Internal persistent component used to keep deterministic AI streams stable
-- across save/load. Register only once in case shared Lua is reloaded.
if not ComponentSchemas.has("Mortis.RandomState") then
    ComponentSchemas.register({
        id = "Mortis.RandomState",
        version = 1,
        persistence = "save",
        replication = "none",
        defaults = {},
    })
end

if not ComponentSchemas.has("Mortis.ProfileState") then
    ComponentSchemas.register({
        id = "Mortis.ProfileState",
        version = 1,
        persistence = "save",
        replication = "none",
        defaults = {
            locomotion = {},
            durability = { appliedScale = 1.0 },
            appearance = {},
        },
    })
end

if not ComponentSchemas.has("Mortis.ZombieHunger") then
    ComponentSchemas.register({
        id = "Mortis.ZombieHunger",
        version = 3,
        persistence = "save",
        replication = "none",
        defaults = {
            -- Negative is an initialization sentinel. ZombieHungerRuntime
            -- replaces it once with a deterministic value in [0.0, 0.75].
            hunger = -1,
            desiccation = 0.0,
            lastWorldAgeHours = -1,
            starvingSinceWorldAgeHours = nil,
            terminalWithering = false,
            terminalEventEmitted = false,
            terminalWitheringApplied = false,
        },
        migrations = {
            [1] = function(value) return value end,
            [2] = function(value) return value end,
        },
        serialize = ZombieHunger.serializeState,
        deserialize = ZombieHunger.deserializeState,
    })
end

if not ComponentSchemas.has("Mortis.CommandHierarchy") then
    ComponentSchemas.register({
        id = "Mortis.CommandHierarchy",
        version = 1,
        persistence = "saveAndReplicate",
        replication = "serverToClients",
        defaults = {},
    })
end

if not ComponentSchemas.has("Mortis.LogicalGroupMembership") then
    ComponentSchemas.register({
        id="Mortis.LogicalGroupMembership",version=1,persistence="saveAndReplicate",
        replication="serverToClients",defaults={},
    })
end

if not ComponentSchemas.has("Mortis.LocationMemory") then
    ComponentSchemas.register({
        id="Mortis.LocationMemory",version=1,persistence="saveAndReplicate",
        replication="serverToClients",defaults={records={},order={}},
    })
end

if not ComponentSchemas.has("Mortis.SignalMemory") then
    ComponentSchemas.register({
        id="Mortis.SignalMemory",version=1,persistence="saveAndReplicate",
        replication="serverToClients",defaults={},
    })
end

function Mortis.assign(zombie, typeId)
    if not Authority.canWriteCanonicalState(zombie) then
        return nil, "M.O.R.T.I.S. type assignment requires server authority"
    end
    local previous = Identity.assign(zombie, typeId)
    local stableId = Identity.ensureStableId(zombie)
    local transmit = Authority.isDedicatedServerRuntime()
    local ok, err = Persistence.flushZombie(zombie, stableId, typeId, transmit)
    if not ok and Persistence.isAvailable() then
        Logger.warn("Could not persist assignment for " .. tostring(stableId) .. ": " .. tostring(err))
    end
    Engine.onAssigned(zombie, previous)
    stableId = Identity.getStableId(zombie) or stableId
    Mortis.Events:emit("ThreatAssigned", zombie, typeId, previous, stableId)
    return zombie
end

function Mortis.getTypeId(zombie) return Identity.getTypeId(zombie) end
function Mortis.getStableId(zombie) return Identity.getStableId(zombie) end

-- Return an infected to vanilla identity without destroying the entity. This
-- is intentionally authoritative and symmetrical with assign(), allowing
-- consumers with temporary infected types to end their lifecycle cleanly.
function Mortis.clearAssignment(zombie)
    if not Authority.canWriteCanonicalState(zombie) then
        return false, "M.O.R.T.I.S. type clearing requires server authority"
    end
    local previous = Identity.getTypeId(zombie)
    if not previous then return true end
    -- Keep the original checkpoint until detach callbacks have finished. An
    -- owner released by onDetach may itself restore a previous movement tier.
    local restored,restoreError=ProfileRuntime.applyLocomotion(zombie,nil,true,true)
    if not restored then return false,restoreError end
    local stableId = Identity.getStableId(zombie)
    local recorded,recordError=Persistence.writeAssignmentClear(zombie,stableId)
    if not recorded then return false,recordError end
    Identity.clear(zombie)
    local transmit = Authority.isDedicatedServerRuntime()
    Persistence.flushComponents(zombie, transmit)
    Engine.onAssigned(zombie, previous)
    Mortis.Events:emit("ThreatCleared", zombie, previous, stableId)
    return true
end

_G.Mortis = Mortis
return Mortis
