local Identity = require "Mortis/Runtime/Identity"
local Types = require "Mortis/API/Types"
local Traits = require "Mortis/API/Traits"
local Behaviors = require "Mortis/API/Behaviors"
local Scheduler = require "Mortis/Core/Scheduler"
local FaultIsolation = require "Mortis/Core/FaultIsolation"
local Authority = require "Mortis/Runtime/Authority"
local Context = require "Mortis/Runtime/Context"
local Capabilities = require "Mortis/API/Capabilities"
local Components = require "Mortis/Runtime/Components"
local Persistence = require "Mortis/Runtime/Persistence"
local Logger = require "Mortis/Core/Logger"
local Network = require "Mortis/Runtime/Adapters/NetworkAdapter"
local Replication = require "Mortis/Runtime/Replication"
local ProfileRuntime = require "Mortis/Runtime/ProfileRuntime"
local DamageRuntime = require "Mortis/Runtime/DamageRuntime"
local StateAdapter = require "Mortis/Runtime/Adapters/StateAdapter"
local HitTraumaRuntime = require "Mortis/Runtime/HitTraumaRuntime"
local ZombieHunger = require "Mortis/Runtime/ZombieHungerRuntime"
local HungerScheduler = require "Mortis/Runtime/HungerScheduler"
local SystemSettings = require "Mortis/Runtime/SystemSettings"
local DetachedParts = require "Mortis/API/DetachedParts"

local Engine = {}

local behaviorState = setmetatable({}, { __mode = "k" })
local tracked = setmetatable({}, { __mode = "k" })
local trackedOrder = setmetatable({}, { __mode = "v" })
local trackedSlot = setmetatable({}, { __mode = "k" })
local trackedCursors = {}
local trackedOrderHighWater = 0
local trackedByStableId = setmetatable({}, { __mode = "v" })
local trackedByOnlineId = setmetatable({}, { __mode = "v" })
local recentHit = setmetatable({}, { __mode = "k" })
local indexedIdentity = setmetatable({}, { __mode = "k" })
local refreshIndexes

local function removeIndexes(zombie)
    local indexed=indexedIdentity[zombie] or {}
    local stableId = indexed.stableId
    if stableId and trackedByStableId[stableId] == zombie then trackedByStableId[stableId] = nil end
    local onlineId = indexed.onlineId
    if type(onlineId) == "number" and trackedByOnlineId[onlineId] == zombie then trackedByOnlineId[onlineId] = nil end
    local slot = trackedSlot[zombie]
    if slot then
        trackedOrder[slot] = nil
        trackedSlot[zombie] = nil
    end
    indexedIdentity[zombie]=nil
end

local function indexZombie(zombie)
    if zombie == nil then return nil end
    if not tracked[zombie] then
        trackedOrderHighWater = trackedOrderHighWater + 1
        trackedOrder[trackedOrderHighWater] = zombie
        trackedSlot[zombie] = trackedOrderHighWater
    end
    tracked[zombie] = true

    local prior=indexedIdentity[zombie] or {}
    if prior.stableId and trackedByStableId[prior.stableId]==zombie then trackedByStableId[prior.stableId]=nil end
    if prior.onlineId and trackedByOnlineId[prior.onlineId]==zombie then trackedByOnlineId[prior.onlineId]=nil end
    local stableId = Identity.getStableId(zombie)
    if type(stableId) == "string" and stableId ~= "" then
        local existing = trackedByStableId[stableId]
        if existing and existing ~= zombie then
            if Authority.canWriteCanonicalState(zombie) then
                local oldId = stableId
                stableId = Identity.regenerateStableId(zombie)
                Logger.warn("Duplicate M.O.R.T.I.S. stable ID detected; reassigned " .. tostring(oldId) .. " -> " .. tostring(stableId))
                local typeId = Identity.getTypeId(zombie)
                if typeId then Persistence.flushZombie(zombie, stableId, typeId, false) end
            else
                Logger.warn("Duplicate M.O.R.T.I.S. stable ID observed on client: " .. tostring(stableId))
            end
        end
        if not trackedByStableId[stableId] or trackedByStableId[stableId] == zombie then
            trackedByStableId[stableId] = zombie
        end
    end

    local onlineId = Network.getOnlineID(zombie)
    if type(onlineId) == "number" and onlineId >= 0 then
        trackedByOnlineId[onlineId] = zombie
    end
    indexedIdentity[zombie]={stableId=stableId,onlineId=onlineId}
    return stableId
end

local function compactTrackedOrder()
    local replacement = setmetatable({}, { __mode = "v" })
    local highWater = 0
    for slot = 1, trackedOrderHighWater do
        local zombie = trackedOrder[slot]
        if zombie and tracked[zombie] then
            highWater = highWater + 1
            replacement[highWater] = zombie
            trackedSlot[zombie] = highWater
        end
    end
    trackedOrder = replacement
    trackedOrderHighWater = highWater
    for channel in pairs(trackedCursors) do trackedCursors[channel] = 0 end
end

local function trackedBatch(channel, limit, inspectLimit, predicate)
    channel = tostring(channel or "default")
    limit = math.max(1, math.floor(tonumber(limit) or 1))
    if trackedOrderHighWater == 0 then return {} end
    inspectLimit = math.max(limit, math.floor(tonumber(inspectLimit) or limit))
    inspectLimit = math.min(inspectLimit, trackedOrderHighWater)

    local result = {}
    local cursor = tonumber(trackedCursors[channel]) or 0
    local inspected, holes = 0, 0
    while inspected < inspectLimit and #result < limit do
        cursor = cursor + 1
        if cursor > trackedOrderHighWater then cursor = 1 end
        inspected = inspected + 1
        local zombie = trackedOrder[cursor]
        if zombie and tracked[zombie] then
            refreshIndexes(zombie)
            if not predicate or predicate(zombie) then result[#result + 1] = zombie end
        else
            holes = holes + 1
        end
    end
    trackedCursors[channel] = cursor

    -- Weak values naturally leave holes when streamed zombies are collected.
    -- Compact only after a bounded pass observes substantial fragmentation.
    if holes >= 16 and holes * 2 >= inspected then compactTrackedOrder() end
    return result
end

refreshIndexes = function(zombie)
    if not tracked[zombie] then return indexZombie(zombie) end
    local prior=indexedIdentity[zombie] or {}
    local stableId = Identity.getStableId(zombie)
    local onlineId = Network.getOnlineID(zombie)
    if prior.stableId~=stableId or prior.onlineId~=onlineId then return indexZombie(zombie) end
    if type(stableId) == "string" and stableId ~= "" and trackedByStableId[stableId] ~= zombie then
        indexZombie(zombie)
    end
    if type(onlineId) == "number" and onlineId >= 0 and trackedByOnlineId[onlineId] ~= zombie then
        trackedByOnlineId[onlineId] = zombie
    end
    return stableId
end

local function stateFor(zombie)
    local state = behaviorState[zombie]
    if not state then
        state = { active = {} }
        behaviorState[zombie] = state
    end
    return state
end

local function eachTrait(typeDef, callback)
    for _, entry in ipairs(typeDef.traits or {}) do
        local id, config
        if type(entry) == "string" then id, config = entry, {} else id, config = entry.id, entry.config or {} end
        local trait = Traits.get(id)
        if trait then callback(id, trait, config) end
    end
end

local function attachType(zombie, previousTypeId)
    if previousTypeId then
        local previousType = Types.get(previousTypeId)
        if previousType then
            local previousCtx = Context.create(zombie, previousType)
            for _, behaviorId in ipairs(previousType.behaviors or {}) do
                local behavior = Behaviors.get(behaviorId)
                if behavior and behavior.onExit and stateFor(zombie).active[behaviorId] then
                    FaultIsolation.call("behavior:" .. behaviorId, "onExit", behavior.onExit, previousCtx, "type-reassigned")
                end
                if behavior and behavior.onDetach then
                    FaultIsolation.call("behavior:" .. behaviorId, "onDetach", behavior.onDetach, previousCtx)
                end
            end
        end
        behaviorState[zombie] = nil
    end

    local typeDef = Identity.getType(zombie)
    if not typeDef then
        if previousTypeId then
            local restored,reason=ProfileRuntime.applyLocomotion(zombie,nil,true)
            if not restored then Logger.rateLimited("clear-locomotion",5,"WARN","Locomotion restore pending: "..tostring(reason)) end
            ProfileRuntime.applyDurability(zombie,nil,true)
            ProfileRuntime.applyAppearance(zombie,nil,true)
        end
        return
    end
    indexZombie(zombie)
    local ctx = Context.create(zombie, typeDef)

    -- Phase C profiles are applied before extension callbacks so traits and
    -- behaviors observe the effective locomotion/durability/appearance state.
    ProfileRuntime.applyAll(zombie, typeDef, true)

    eachTrait(typeDef, function(id, trait, config)
        if trait.onAssigned then
            FaultIsolation.call("trait:" .. id, "onAssigned", trait.onAssigned, zombie, config, typeDef, ctx)
        end
    end)

    local bstate = stateFor(zombie)
    for _, behaviorId in ipairs(typeDef.behaviors or {}) do
        local behavior = Behaviors.get(behaviorId)
        if behavior and behavior.onAttach then
            FaultIsolation.call("behavior:" .. behaviorId, "onAttach", behavior.onAttach, ctx)
        end
        bstate.active[behaviorId] = false
    end
end

function Engine.onAssigned(zombie, previousTypeId)
    indexZombie(zombie)
    return attachType(zombie, previousTypeId)
end

function Engine.onCreated(zombie)
    Capabilities.observeZombie(zombie)

    -- Restore persisted M.O.R.T.I.S. identity and persistent components from
    -- the zombie's own modData. This is intentionally attempted on both server
    -- and client; only the server is allowed to author canonical changes.
    -- Generic persistent components such as zombie hunger apply to ordinary
    -- vanilla zombies as well as typed extension zombies.
    Persistence.loadComponents(zombie)
    local record = Persistence.readIdentity(zombie)
    if record then
        if record.typeId and not Types.has(record.typeId) then
            Logger.warn("Persisted threat type is not registered: " .. tostring(record.typeId))
        else
            local restored = Identity.restore(zombie, record.stableId, record.typeId)
            if restored then attachType(zombie, nil) end
        end
    end
    -- Track every observed zombie, including untyped client zombies. This lets
    -- explicit MP reconciliation resolve a server snapshot by online ID before
    -- that zombie has received a M.O.R.T.I.S. identity.
    indexZombie(zombie)
    return zombie
end


local function notifyDamaged(zombie, hit)
    local typeDef = Identity.getType(zombie)
    if not typeDef then return false end
    local ctx = Context.create(zombie, typeDef)

    eachTrait(typeDef, function(id, trait, config)
        if trait.onDamaged then
            FaultIsolation.call("trait:" .. id, "onDamaged", trait.onDamaged, zombie, hit, config, typeDef, ctx)
        end
    end)
    for _, behaviorId in ipairs(typeDef.behaviors or {}) do
        local behavior = Behaviors.get(behaviorId)
        if behavior and behavior.onDamaged then
            FaultIsolation.call("behavior:" .. behaviorId, "onDamaged", behavior.onDamaged, ctx, hit)
        end
    end
    return true
end

function Engine.onHitZombie(zombie, attacker, bodyPart, weapon)
    -- Trauma anatomy is independent of threat typing: all zombies can carry the
    -- built-in humanoid anatomy. Existing damage-profile callbacks still remain
    -- limited to typed M.O.R.T.I.S. threats.
    HitTraumaRuntime.stageZombieHit(zombie, attacker, bodyPart, weapon)

    if not Identity.getTypeId(zombie) then return true end
    recentHit[zombie] = {
        attacker = attacker,
        bodyPart = bodyPart,
        weapon = weapon,
        damageType = "WEAPONHIT",
    }
    return true
end

function Engine.onDamageEvent(character, damageType, damage)
    if character == nil or not Identity.getTypeId(character) then return false end
    if not Authority.canWriteCanonicalState(character) then return false end

    local hit = recentHit[character] or {}
    recentHit[character] = nil
    hit.damageType = damageType or hit.damageType
    hit.reportedDamage = tonumber(damage) or 0

    local ok, result = DamageRuntime.adjustPostDamage(character, hit.reportedDamage, hit.damageType, hit)
    if ok and type(result) == "table" then
        hit.baseDamage = result.baseDamage
        hit.effectiveDamage = result.effectiveDamage
        hit.multiplier = result.multiplier
        hit.healthAfter = result.healthAfter
        hit.adjustment = result.adjustment
    else
        hit.damageAdjustmentError = result
    end

    local traumaDamage = hit.reportedDamage
    if type(result) == "table" and tonumber(result.effectiveDamage) then
        traumaDamage = tonumber(result.effectiveDamage)
    end
    local traumaOk, traumaResult = HitTraumaRuntime.consumeStagedZombieHit(character, traumaDamage)
    hit.traumaApplied = traumaOk
    hit.trauma = traumaResult

    notifyDamaged(character, hit)
    return ok, result
end

function Engine.applyCustomDamage(zombie, amount, kind, metadata)
    if not Identity.getTypeId(zombie) then return false, "not typed" end
    local ok, result = DamageRuntime.apply(zombie, amount, kind, metadata)
    if ok then notifyDamaged(zombie, result) end
    return ok, result
end

function Engine.onWeaponHitCharacter(attacker, target, weapon, damage)
    return HitTraumaRuntime.observeCharacterHit(attacker, target, weapon, damage)
end

function Engine.applyLivingHitTrauma(target, attacker, bodyPart, weapon, damage, options)
    return HitTraumaRuntime.applyHit(target, attacker, bodyPart, weapon, damage, options)
end

function Engine.onDead(zombie)
    local stableIdAtDeath = Identity.getStableId(zombie)
    local typeIdAtDeath = Identity.getTypeId(zombie)
    local typeDef = Identity.getType(zombie)
    if typeDef then
        -- OnZombieDead occurs before the corpse object exists. Reassert the
        -- HumanVisual profile so vanilla corpse construction sees the intended
        -- body material when it copies zombie visual state.
        ProfileRuntime.applyAppearance(zombie, typeDef, true)
        local ctx = Context.create(zombie, typeDef)
        eachTrait(typeDef, function(id, trait, config)
            if trait.onKilled then
                FaultIsolation.call("trait:" .. id, "onKilled", trait.onKilled, zombie, config, typeDef, ctx)
            end
        end)
        for _, behaviorId in ipairs(typeDef.behaviors or {}) do
            local behavior = Behaviors.get(behaviorId)
            if behavior and behavior.onKilled then
                FaultIsolation.call("behavior:" .. behaviorId, "onKilled", behavior.onKilled, ctx)
            end
            if behavior and behavior.onDetach then
                FaultIsolation.call("behavior:" .. behaviorId, "onDetach", behavior.onDetach, ctx)
            end
        end

        if Authority.canWriteCanonicalState(zombie) then
            Persistence.flushZombie(zombie, Identity.getStableId(zombie), Identity.getTypeId(zombie), true)
        end
    end

    -- Death providers have finished; capture their final classifications/anatomy
    -- while the original identity still exists, before native corpse creation.
    if Authority.canWriteCanonicalState(zombie) then
        local ok,record,reason=pcall(DetachedParts.snapshotDeath,zombie)
        if not ok or not record then
            pcall(Logger.rateLimited,"death-provenance",30,"WARN",
                "Death provenance unavailable: "..tostring(ok and reason or record),"Anatomy")
        end
    end
    local mortis=rawget(_G,"Mortis")
    if mortis and mortis.Events then
        mortis.Events:emit("ThreatKilled",zombie,typeIdAtDeath,stableIdAtDeath)
    end
    removeIndexes(zombie)
    tracked[zombie] = nil
    Replication.release(zombie)
    Replication.forgetApplied(stableIdAtDeath)
    Scheduler.release(zombie)
    HungerScheduler.release(zombie)
    behaviorState[zombie] = nil
    recentHit[zombie] = nil
    HitTraumaRuntime.clear(zombie)
    Components.clear(zombie)
end

local function observeNativeState(zombie, typeDef, ctx)
    local key = StateAdapter.getNativeStateKey(zombie)
    if key == nil then return end
    local bstate = stateFor(zombie)
    local previous = bstate.nativeStateKey
    if previous == nil then
        bstate.nativeStateKey = key
        return
    end
    if previous == key then return end
    bstate.nativeStateKey = key

    local snapshot = StateAdapter.snapshot(zombie)
    snapshot.previousState = previous
    snapshot.currentState = key

    eachTrait(typeDef, function(id, trait, config)
        if trait.onNativeStateChanged then
            FaultIsolation.call("trait:" .. id, "onNativeStateChanged", trait.onNativeStateChanged, zombie, snapshot, config, typeDef, ctx)
        end
    end)
    for _, behaviorId in ipairs(typeDef.behaviors or {}) do
        local behavior = Behaviors.get(behaviorId)
        if behavior and behavior.onNativeStateChanged then
            FaultIsolation.call("behavior:" .. behaviorId, "onNativeStateChanged", behavior.onNativeStateChanged, ctx, snapshot)
        end
    end

    local Mortis = rawget(_G, "Mortis")
    if Mortis and Mortis.Events then
        Mortis.Events:emit("NativeStateChanged", zombie, snapshot, typeDef)
    end
end

local function runBehavior(zombie, typeDef, behaviorId, behavior, ctx)
    if not Scheduler.shouldRun(zombie, behavior.tickClass, behavior.tickInterval) then return end

    local allowed = true
    if behavior.canRun then
        local ok, result = FaultIsolation.call("behavior:" .. behaviorId, "canRun", behavior.canRun, ctx)
        allowed = ok and result ~= false
    end

    local bstate = stateFor(zombie)
    local wasActive = bstate.active[behaviorId] == true

    if not allowed then
        if wasActive and behavior.onExit then
            FaultIsolation.call("behavior:" .. behaviorId, "onExit", behavior.onExit, ctx, "canRun=false")
        end
        bstate.active[behaviorId] = false
        return
    end

    if not wasActive then
        if behavior.onEnter then
            FaultIsolation.call("behavior:" .. behaviorId, "onEnter", behavior.onEnter, ctx)
        end
        bstate.active[behaviorId] = true
    end

    if behavior.onTick then
        FaultIsolation.call("behavior:" .. behaviorId, "onTick", behavior.onTick, ctx, 0)
    elseif behavior.onUpdate then
        FaultIsolation.call("behavior:" .. behaviorId, "onUpdate", behavior.onUpdate, zombie, typeDef, ctx)
    end
end

function Engine.update(zombie)
    refreshIndexes(zombie)
    if SystemSettings.bool("EnableZombieHunger") and Scheduler.shouldRun(zombie, "hunger", 300) then
        HungerScheduler.enqueue(zombie)
    end
    if Components.isDirty(zombie) then Persistence.flushComponents(zombie, false) end

    local typeDef = Identity.getType(zombie)
    if not typeDef then
        if Authority.canWriteCanonicalState(zombie) and ProfileRuntime.hasPendingLocomotionRestore(zombie)
            and Scheduler.shouldRun(zombie,"locomotion-restore",120) then
            local restored,reason=ProfileRuntime.applyLocomotion(zombie,nil,false)
            if not restored then Logger.rateLimited("clear-locomotion",5,"WARN","Locomotion restore pending: "..tostring(reason)) end
        end
        return
    end

    -- Profile reconciliation is allowed on clients so appearance can be
    -- repaired after streaming/model rebuilds. Locomotion and durability
    -- adapters remain authority-gated inside ProfileRuntime.
    if Scheduler.shouldRun(zombie, "slow", 120) then
        ProfileRuntime.reconcile(zombie, typeDef)
    end

    if not Authority.canRunCanonicalAI(zombie) then return end

    local ctx = Context.create(zombie, typeDef)

    if Scheduler.shouldRun(zombie, "fast", 3) then
        observeNativeState(zombie, typeDef, ctx)
    end

    eachTrait(typeDef, function(id, trait, config)
        local tickClass = trait.tickClass or "normal"
        local interval = trait.tickInterval
        if trait.onUpdate and Scheduler.shouldRun(zombie, tickClass, interval) then
            FaultIsolation.call("trait:" .. id, "onUpdate", trait.onUpdate, zombie, config, typeDef, ctx)
        end
    end)

    for _, behaviorId in ipairs(typeDef.behaviors or {}) do
        local behavior = Behaviors.get(behaviorId)
        if behavior then runBehavior(zombie, typeDef, behaviorId, behavior, ctx) end
    end

    -- Persistent component writes are staged into zombie modData promptly, so
    -- the game can include them whenever that zombie is serialized. Network
    -- transmission is reserved for explicit replication work later in Phase B.
    if Components.isDirty(zombie) then
        Persistence.flushComponents(zombie, false)
    end
end

local function processHunger(zombie)
    local ok,result=ZombieHunger.updateFoodSeeking(zombie,SystemSettings.number("FoodSearchRadius"))
    -- This work now runs outside Engine.update. Flush its component changes
    -- before a delayed actor can stream out; network replication stays separate.
    if Components.isDirty(zombie) then Persistence.flushComponents(zombie,false) end
    return ok,result
end
function Engine.updateHungerBudget() return HungerScheduler.update(processHunger) end
function Engine.getHungerSchedulingDiagnostics() return HungerScheduler.getDiagnostics() end

function Engine.onReplicated(zombie, previousTypeId)
    indexZombie(zombie)
    local current = Identity.getTypeId(zombie)
    if current ~= previousTypeId then
        attachType(zombie, previousTypeId)
    end
end

function Engine.findTrackedByStableId(stableId)
    if type(stableId) ~= "string" then return nil end
    local zombie=trackedByStableId[stableId]
    if zombie then refreshIndexes(zombie) end
    return trackedByStableId[stableId]
end

function Engine.findTrackedByOnlineID(onlineId, indexedOnly)
    if type(onlineId) ~= "number" or onlineId~=onlineId or onlineId<0 or onlineId>2147483647 or onlineId~=math.floor(onlineId) then return nil end
    local zombie = trackedByOnlineId[onlineId]
    if zombie then refreshIndexes(zombie);zombie=trackedByOnlineId[onlineId] end
    if zombie then return zombie end
    if indexedOnly then return nil end
    -- Online IDs may become valid after OnZombieCreate. Refresh lazily.
    for candidate in pairs(tracked) do
        refreshIndexes(candidate)
        if trackedByOnlineId[onlineId] then return trackedByOnlineId[onlineId] end
    end
    return nil
end

function Engine.listTracked(limit)
    local result = {}
    limit = math.max(1, math.floor(tonumber(limit) or 2147483647))
    for zombie in pairs(tracked) do
        if #result >= limit then break end
        refreshIndexes(zombie)
        result[#result + 1] = zombie
    end
    return result
end

-- Return a fair, channel-specific slice of tracked zombies. Independent
-- cursors prevent collision, movement, and extension consumers from starving
-- one another. The scan itself is bounded by inspectLimit.
function Engine.takeTrackedBatch(channel, limit, inspectLimit)
    return trackedBatch(channel, limit, inspectLimit, nil)
end

function Engine.reconcilePersistence(zombie)
    local stableId = Identity.getStableId(zombie)
    local typeId = Identity.getTypeId(zombie)
    if not stableId or not typeId then return false, "not typed" end
    if Persistence.identityMatches(zombie, stableId, typeId) then return true, "matched" end
    if not Authority.canWriteCanonicalState(zombie) then return false, "client cannot author reconciliation" end
    local ok, err = Persistence.flushZombie(zombie, stableId, typeId, false)
    if ok then return true, "repaired" end
    return false, err
end

function Engine.flushTracked(transmit)
    local count = 0
    for zombie in pairs(tracked) do
        if Identity.getTypeId(zombie) and Authority.canWriteCanonicalState(zombie) then
            local ok = Persistence.flushZombie(zombie, Identity.getStableId(zombie), Identity.getTypeId(zombie), transmit == true)
            if ok then count = count + 1 end
        end
    end
    return count
end

function Engine.collectReplicationDirty(limit)
    limit = math.max(1, math.floor(tonumber(limit) or 24))
    return trackedBatch("replication-dirty", limit, limit * 4, function(zombie)
        return Components.isReplicationDirty(zombie) and
            Identity.getTypeId(zombie) and Authority.canWriteCanonicalState(zombie)
    end)
end

function Engine.trackedCount()
    local count = 0
    for _ in pairs(tracked) do count = count + 1 end
    return count
end

return Engine
