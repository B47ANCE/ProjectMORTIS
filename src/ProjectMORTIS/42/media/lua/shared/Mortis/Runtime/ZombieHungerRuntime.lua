local Authority = require "Mortis/Runtime/Authority"
local Components = require "Mortis/Runtime/Components"
local FoodSources = require "Mortis/API/FoodSources"
local FaultIsolation = require "Mortis/Core/FaultIsolation"
local Settings = require "Mortis/Runtime/SystemSettings"
local Random = require "Mortis/Core/Random"
local Combat = require "Mortis/Runtime/Adapters/CombatAdapter"
local Util = require "Mortis/Core/Util"
local Logger = require "Mortis/Core/Logger"

local Hunger = {}
local COMPONENT = "Mortis.ZombieHunger"
local VANILLA_BACKEND = "character-stat-hunger-v1"
local pendingFood = setmetatable({}, {__mode="k"})
local quarantinedFood = {}

local function finite(value)
    value=tonumber(value)
    if not value or value~=value or value==math.huge or value==-math.huge then return nil end
    return value
end

local function clamp01(value)
    return math.max(0, math.min(1, finite(value) or 0))
end

local function worldAgeHours()
    if type(getGameTime) ~= "function" then return nil end
    local ok, gameTime = pcall(getGameTime)
    if not ok or not gameTime or not gameTime.getWorldAgeHours then return nil end
    local okAge, age = pcall(function() return gameTime:getWorldAgeHours() end)
    age=okAge and finite(age) or nil
    return age and age>=0 and age or nil
end

-- IsoAnimal:getHunger() is a thin read of the inherited Stats container's
-- CharacterStat.HUNGER value. IsoZombie inherits the same persistent Stats
-- container from IsoGameCharacter, although it does not inherit IsoAnimal's
-- feeding/trough methods. Use that shared vanilla resource as canonical state.
local function vanillaHunger(zombie)
    if not zombie or not zombie.getStats or not CharacterStat or not CharacterStat.HUNGER then return nil end
    local ok,value=pcall(function() return zombie:getStats():get(CharacterStat.HUNGER) end)
    return ok and finite(value) or nil
end

local function setVanillaHunger(zombie,value)
    if not Authority.canWriteCanonicalState(zombie) then return false end
    if not zombie or not zombie.getStats or not CharacterStat or not CharacterStat.HUNGER then return false end
    local target=clamp01(value)
    local written=pcall(function() zombie:getStats():set(CharacterStat.HUNGER,target) end)
    if not written then return false end
    local verified=vanillaHunger(zombie)
    return verified~=nil and math.abs(clamp01(verified)-target)<=0.000001
end

-- Component persistence is an explicit allow-list. This prevents unrelated or
-- malformed modData fields from becoming live hunger state after save/load.
function Hunger.serializeState(state)
    state=type(state)=="table" and state or {}
    local rawHunger=finite(state.hunger)
    local hunger=(rawHunger and rawHunger>=0) and clamp01(rawHunger) or -1
    local last=finite(state.lastWorldAgeHours)
    if not last or last<0 then last=-1 end
    local starving=finite(state.starvingSinceWorldAgeHours)
    if hunger<1 or not starving or starving<0 or last<0 or starving>last then starving=nil end
    local fed=finite(state.lastFedWorldAgeHours)
    if not fed or fed<0 or (last>=0 and fed>last) then fed=nil end
    return {
        hunger=hunger,
        desiccation=clamp01(state.desiccation),
        lastWorldAgeHours=last,
        starvingSinceWorldAgeHours=starving,
        lastFedWorldAgeHours=fed,
        hungerBackend=state.hungerBackend==VANILLA_BACKEND and VANILLA_BACKEND or nil,
        terminalWithering=state.terminalWithering==true,
        terminalEventEmitted=state.terminalEventEmitted==true,
        terminalWitheringApplied=state.terminalWitheringApplied==true,
    }
end

function Hunger.deserializeState(payload)
    return Hunger.serializeState(payload)
end

local function stateFor(zombie)
    -- Provider callbacks see the last committed state, never a provisional
    -- native write. Failed compensation keeps the entity blocked for diagnosis.
    if pendingFood[zombie] then return Util.deepCopy(pendingFood[zombie].before) end
    if not Authority.canWriteCanonicalState(zombie) then
        -- Observation must not instantiate schema defaults, migrate saved data,
        -- consume random state or call native setters on a client.
        local bucket = Components.allFor(zombie)
        local cached = bucket and bucket[COMPONENT]
        return Hunger.serializeState(type(cached)=="table" and cached or {
            hunger=vanillaHunger(zombie) or -1,
        })
    end
    local state = Components.get(zombie, COMPONENT)
    if type(state) ~= "table" then
        state = { hunger=-1, desiccation=0.0, lastWorldAgeHours=-1, starvingSinceWorldAgeHours=nil }
    end
    local rawHunger = finite(state.hunger)
    if rawHunger == nil or rawHunger < 0 then
        state.hunger = Random.next(zombie) * 0.75
        if setVanillaHunger(zombie,state.hunger) then state.hungerBackend=VANILLA_BACKEND end
        Components.set(zombie, COMPONENT, state)
    else
        state.hunger = clamp01(rawHunger)
        if state.hungerBackend~=VANILLA_BACKEND then
            -- One-time migration for saves created before the vanilla Stats
            -- adapter. Preserve their exact hunger and starvation progress.
            if setVanillaHunger(zombie,state.hunger) then
                state.hungerBackend=VANILLA_BACKEND
                Components.set(zombie,COMPONENT,state)
            end
        else
            local vanilla=vanillaHunger(zombie)
            if vanilla~=nil then state.hunger=clamp01(vanilla) end
        end
    end
    state.desiccation = clamp01(state.desiccation)
    state.terminalWithering=state.terminalWithering==true or state.desiccation>=1
    state.terminalEventEmitted=state.terminalEventEmitted==true
    state.terminalWitheringApplied=state.terminalWitheringApplied==true
    state.lastWorldAgeHours = finite(state.lastWorldAgeHours) or -1
    state.starvingSinceWorldAgeHours = finite(state.starvingSinceWorldAgeHours)
    local now=worldAgeHours()
    if state.lastWorldAgeHours<0 or (now and state.lastWorldAgeHours>now) then state.lastWorldAgeHours=-1 end
    if state.starvingSinceWorldAgeHours and (state.starvingSinceWorldAgeHours<0
        or (now and state.starvingSinceWorldAgeHours>now)) then state.starvingSinceWorldAgeHours=nil end
    return state
end

local function hasVanillaTarget(zombie)
    if not zombie or not zombie.getTarget then return nil end
    local ok, target = pcall(function() return zombie:getTarget() end)
    if not ok then return nil end
    return ok and target ~= nil
end

local function position(candidate)
    if type(candidate) ~= "table" then return nil end
    -- Provider-owned objects/getters are untrusted callback output too.
    local ok,x,y,z=pcall(function()
        local cx,cy,cz=rawget(candidate,"x"),rawget(candidate,"y"),rawget(candidate,"z")
        if cx~=nil or cy~=nil then
            return cx,cy,cz==nil and 0 or cz
        end
        local source=rawget(candidate,"source")
        if source then
            local sourceZ=0
            if source.getZ then sourceZ=source:getZ() end
            return source:getX(),source:getY(),sourceZ
        end
    end)
    if not ok then return nil end
    x,y,z=finite(x),finite(y),finite(z)
    if x and y and z then return x,y,z end
end

local function distanceSquared(zombie, candidate)
    local x, y, z = position(candidate)
    if not x then return nil end
    local ok, zx, zy, zz = pcall(function() return zombie:getX(), zombie:getY(), zombie:getZ() end)
    zx,zy,zz=finite(zx),finite(zy),finite(zz)
    if not ok or not zx or not zy or not zz then return nil end
    local dx, dy, dz = x-zx, y-zy, z-zz
    return finite(dx*dx+dy*dy+dz*dz), x, y, z
end

function Hunger.get(zombie)
    if not zombie then return nil, "zombie required" end
    return stateFor(zombie)
end

function Hunger.getLevel(zombie)
    local state = stateFor(zombie)
    if pendingFood[zombie] then return state.hunger end
    local vanilla=vanillaHunger(zombie)
    if vanilla~=nil then
        state.hunger=clamp01(vanilla)
        return state.hunger
    end
    return state.hunger
end

function Hunger.isHungry(zombie, threshold)
    return Hunger.getLevel(zombie) >= (tonumber(threshold) or 0.25)
end

function Hunger.feed(zombie, amount, metadata)
    if not Authority.canWriteCanonicalState(zombie) then return false, "non-authority" end
    if pendingFood[zombie] then return false,"food-transaction-pending" end
    local state = stateFor(zombie)
    local before = state.hunger
    local nextHunger=clamp01(before - math.max(0, finite(amount) or 0))
    if state.hungerBackend==VANILLA_BACKEND and not setVanillaHunger(zombie,nextHunger) then
        return false,"vanilla-hunger-write-failed"
    end
    state.hunger = nextHunger
    state.lastFedWorldAgeHours = worldAgeHours() or state.lastFedWorldAgeHours
    if state.hunger < 1 then state.starvingSinceWorldAgeHours = nil end
    Components.set(zombie, COMPONENT, state)
    local Mortis = rawget(_G, "Mortis")
    if Mortis and Mortis.Events then
        pcall(function() Mortis.Events:emit("ZombieFed", zombie, before, state.hunger, metadata or {}) end)
    end
    return true, state
end

function Hunger.advance(zombie)
    if not Authority.canWriteCanonicalState(zombie) then return false, "non-authority" end
    if pendingFood[zombie] then return false,"food-transaction-pending" end
    local now = worldAgeHours()
    if not now then return false, "world age unavailable" end
    local state = stateFor(zombie)
    if state.lastWorldAgeHours < 0 then
        state.lastWorldAgeHours = now
        if state.hunger >= 1 and state.starvingSinceWorldAgeHours == nil then
            state.starvingSinceWorldAgeHours = now
        end
        Components.set(zombie, COMPONENT, state)
        return true, state
    end
    local elapsed = math.max(0, now - state.lastWorldAgeHours)
    -- Avoid rewriting every loaded zombie's ModData on each behavior poll.
    -- Hourly world-age batches are more than precise enough for this resource.
    if elapsed < 1 then return true, state end
    local previousAge = state.lastWorldAgeHours
    -- Initial behavior stays simple: zombies become hungry over one in-game
    -- week. Years-scale irreversible desiccation is intentionally a later,
    -- separately tunable consequence rather than being hidden in this rate.
    local days=math.max(0.01,finite(Settings.number("HungerDaysToFull")) or 7)
    local before = state.hunger
    local nextHunger=clamp01(before + elapsed / (24 * days))
    if state.hungerBackend==VANILLA_BACKEND and not setVanillaHunger(zombie,nextHunger) then
        return false,"vanilla-hunger-write-failed"
    end
    state.lastWorldAgeHours = now
    state.hunger = nextHunger
    if nextHunger >= 1 and state.starvingSinceWorldAgeHours == nil then
        local hoursUntilEmpty = before >= 1 and 0 or (1 - before) * 24 * days
        state.starvingSinceWorldAgeHours = math.min(now, previousAge + hoursUntilEmpty)
    elseif state.hunger < 1 then
        state.starvingSinceWorldAgeHours = nil
    end
    if Settings.bool("EnableZombieDesiccation") and state.hunger>=1 and state.starvingSinceWorldAgeHours then
        local starvingElapsed=math.max(0,now-math.max(previousAge,state.starvingSinceWorldAgeHours))
        local years=math.max(1,finite(Settings.number("DesiccationYearsToTerminal"))or 5)
        state.desiccation=clamp01(state.desiccation+starvingElapsed/(24*365*years))
        if state.desiccation>=1 then state.terminalWithering=true end
    end
    Components.set(zombie, COMPONENT, state)
    if state.terminalWithering then Hunger.applyTerminalWithering(zombie,state)end
    return true, state
end

function Hunger.applyTerminalWithering(zombie,state)
    if not Authority.canWriteCanonicalState(zombie)then return false,"non-authority"end
    if pendingFood[zombie] then return false,"food-transaction-pending" end
    state=state or stateFor(zombie);if not state.terminalWithering then return false,"not-terminal"end
    local Mortis=rawget(_G,"Mortis")
    if not state.terminalEventEmitted then
        state.terminalEventEmitted=true;Components.set(zombie,COMPONENT,state)
        if Mortis and Mortis.Events then pcall(function()Mortis.Events:emit("ZombieTerminalWithering",zombie,{desiccation=state.desiccation,starvationHours=Hunger.getStarvationHours(zombie)})end)end
    end
    if state.terminalWitheringApplied then return true,state end
    if not Settings.bool("EnableTerminalWithering")then return true,state end
    local applied,reason=Combat.setHealth(zombie,0);if not applied then return false,reason or"terminal-health-write-failed"end
    local health,readReason=Combat.getHealth(zombie)
    if type(health)~="number"or health>0 then return false,readReason or"terminal-health-readback-failed"end
    state.terminalWitheringApplied=true;Components.set(zombie,COMPONENT,state);return true,state
end

function Hunger.getStarvationHours(zombie, now)
    local state = stateFor(zombie)
    if state.hunger < 1 or state.starvingSinceWorldAgeHours == nil then return 0 end
    now = finite(now) or worldAgeHours()
    if not now then return 0 end
    return math.max(0, now - state.starvingSinceWorldAgeHours)
end

function Hunger.hasStarvedFor(zombie, days, now)
    return Hunger.getStarvationHours(zombie, now) >= math.max(0, tonumber(days) or 0) * 24
end
function Hunger.getDesiccation(zombie)return stateFor(zombie).desiccation end
function Hunger.isTerminallyWithered(zombie)return stateFor(zombie).terminalWithering==true end

-- Return a normalized motivation value without taking ownership of target
-- selection. Consumers such as Nightfall decide how hunger affects their AI.
-- The threshold creates a dead zone while preserving a smooth, tunable ramp.
function Hunger.getDrive(zombie, threshold)
    local level = Hunger.getLevel(zombie)
    threshold = clamp01(threshold or 0)
    if level <= threshold then return 0, level end
    return clamp01((level - threshold) / math.max(0.0001, 1 - threshold)), level
end

-- Test tooling must mutate hunger through M.O.R.T.I.S. so the vanilla Stats
-- value, starvation clock, component persistence, and events stay coherent.
-- This is intentionally explicit and is not used by production simulation.
function Hunger.setTestState(zombie, level, starvationHours)
    if not Authority.canWriteCanonicalState(zombie) then return false, "non-authority" end
    if pendingFood[zombie] then return false,"food-transaction-pending" end
    local now = worldAgeHours()
    if not now then return false, "world age unavailable" end
    local state = stateFor(zombie)
    local before = state.hunger
    local nextHunger=clamp01(level)
    if state.hungerBackend==VANILLA_BACKEND and not setVanillaHunger(zombie,nextHunger) then
        return false,"vanilla-hunger-write-failed"
    end
    state.hunger = nextHunger
    state.lastWorldAgeHours = now
    starvationHours = math.max(0, finite(starvationHours) or 0)
    state.starvingSinceWorldAgeHours = state.hunger >= 1 and (now - starvationHours) or nil
    Components.set(zombie, COMPONENT, state)
    local Mortis = rawget(_G, "Mortis")
    if Mortis and Mortis.Events then
        pcall(function() Mortis.Events:emit("ZombieHungerTestState", zombie, before, state.hunger, starvationHours) end)
    end
    return true, state
end

function Hunger.findNearby(zombie, radius)
    radius = math.max(1, finite(radius) or 12)
    local best, bestProvider, bestScore
    for id, provider in pairs(FoodSources.all()) do
        local ok,candidate
        if not quarantinedFood[id] then
            ok,candidate=FaultIsolation.call("food-source:" .. id, "findNearby", provider.findNearby, zombie, radius)
        end
        if ok and type(candidate) == "table" then
            local distance = distanceSquared(zombie, candidate)
            if distance and distance <= radius*radius then
                local priority=rawget(candidate,"priority")
                priority=finite(priority==nil and (provider.priority or 0) or priority)
                local score=priority and finite(priority*100000-distance)
                if score and (bestScore == nil or score > bestScore or (score==bestScore and id<bestProvider.id)) then
                    best, bestProvider, bestScore = candidate, provider, score
                end
            end
        end
    end
    return best, bestProvider
end

local function feedFromSource(zombie,candidate,provider)
    if provider.transactionVersion~=1 or type(provider.reserve)~="function"
        or type(provider.commit)~="function" or type(provider.rollback)~="function" then
        Logger.once("food-provider-upgrade:"..provider.id,"WARN",
            "Unsafe consume skipped; provider requires food transactions: "..provider.id,"FOOD")
        return false,"food-source-transaction-required"
    end
    if quarantinedFood[provider.id] then return false,"food-provider-quarantined" end
    local multiplier=finite(Settings.number("FoodValueMultiplier"))
    if not multiplier or multiplier<=0 then return false,"invalid-food-value-multiplier" end
    local before=Util.deepCopy(stateFor(zombie))
    if before.hunger<=0 then return false,"not-hungry" end
    local entry={before=before,context={}}
    pendingFood[zombie]=entry
    local touchedNative,touchedCache=false,false
    local function abort(reason)
        -- Compensation is never skipped by the callback circuit breaker.
        -- Rollback must be idempotent, including a reserve that threw midway.
        local called,released=pcall(provider.rollback,zombie,candidate,entry.context)
        local sourceRestored=called and released==true
        local nativeRestored=true
        if touchedNative then
            local value=vanillaHunger(zombie)
            if value==nil or math.abs(value-before.hunger)>0.000001 then
                setVanillaHunger(zombie,before.hunger)
                value=vanillaHunger(zombie)
            end
            nativeRestored=value~=nil and math.abs(value-before.hunger)<=0.000001
        end
        local cacheRestored=true
        if touchedCache then
            local original=Util.deepCopy(before)
            local restored,result=pcall(Components.set,zombie,COMPONENT,original)
            cacheRestored=restored and result==original
        end
        if not sourceRestored or not nativeRestored or not cacheRestored then
            entry.failed=true;quarantinedFood[provider.id]=true
            Logger.once("food-transaction:"..provider.id,"ERROR",
                "Food transaction compensation failed; provider quarantined: "..provider.id,"FOOD")
            return false,"food-transaction-rollback-failed"
        end
        pendingFood[zombie]=nil
        return false,reason
    end
    local owner="food-source:"..provider.id
    local called,ok,quote=pcall(FaultIsolation.call,owner,"reserve",provider.reserve,zombie,candidate,entry.context)
    if not called or not ok or type(quote)~="table" or rawget(quote,"reserved")~=true then return abort("food-reservation-rejected") end
    local value=rawget(quote,"foodValue")
    local amount=type(value)=="number" and finite(value) or nil
    amount=amount and finite(amount*multiplier)
    if not amount or amount<=0 then return abort("invalid-food-value") end
    local after=Util.deepCopy(before)
    after.hunger=clamp01(before.hunger-amount)
    if after.hunger>=before.hunger then return abort("food-value-no-effect") end
    after.lastFedWorldAgeHours=worldAgeHours() or after.lastFedWorldAgeHours
    if after.hunger<1 then after.starvingSinceWorldAgeHours=nil end
    if before.hungerBackend==VANILLA_BACKEND then
        touchedNative=true
        if not setVanillaHunger(zombie,after.hunger) then return abort("vanilla-hunger-write-failed") end
        if (vanillaHunger(zombie) or before.hunger)>=before.hunger then return abort("food-value-no-effect") end
    end
    touchedCache=true
    local saved,cached=pcall(Components.set,zombie,COMPONENT,after)
    if not saved or cached~=after then return abort("food-hunger-cache-failed") end
    local dispatched,committed,result=pcall(FaultIsolation.call,owner,"commit",provider.commit,zombie,candidate,entry.context)
    if not dispatched or not committed or result~=true then return abort("food-commit-rejected") end
    pendingFood[zombie]=nil
    local metadata={providerId=provider.id,sourceId=rawget(candidate,"sourceId"),
        sourceClass=rawget(candidate,"sourceClass") or provider.sourceClass or "registered-food-source",source=rawget(candidate,"source")}
    local Mortis=rawget(_G,"Mortis")
    if Mortis and Mortis.Events then
        pcall(function()Mortis.Events:emit("ZombieFed",zombie,before.hunger,after.hunger,metadata)end)
    end
    return true,after
end

function Hunger.updateFoodSeeking(zombie, radius)
    if not Settings.bool("EnableZombieHunger") then return false,"disabled" end
    if not Authority.canRunCanonicalAI(zombie) then return false, "non-authority" end
    if pendingFood[zombie] then return false,"food-transaction-pending" end
    local advanced,advanceError=Hunger.advance(zombie)
    if not advanced then return false,advanceError end
    if not Hunger.isHungry(zombie,Settings.number("FoodSeekingMinimumHunger")) then
        return false,"not-hungry"
    end
    local target=hasVanillaTarget(zombie)
    if target==nil then return false,"vanilla-target-unavailable" end
    if target then return false, "vanilla-target-active" end

    local candidate, provider = Hunger.findNearby(zombie, radius)
    if not candidate then return false, "no-nearby-source" end
    local distance, x, y, z = distanceSquared(zombie, candidate)
    if not distance then return false, "invalid-source-position" end

    local consumeDistance=rawget(candidate,"consumeDistance")
    consumeDistance=finite(consumeDistance==nil and 1.25 or consumeDistance)
    if not consumeDistance or consumeDistance<0 then return false,"invalid-consume-distance" end
    consumeDistance=math.max(0.5,consumeDistance)
    if distance <= consumeDistance*consumeDistance and (provider.consume or provider.reserve) then
        return feedFromSource(zombie,candidate,provider)
    end

    if zombie.pathToLocationF then
        local ok = pcall(function() zombie:pathToLocationF(x+0.5, y+0.5, z) end)
        if ok then return true, "seeking", candidate, provider.id end
    elseif zombie.pathToLocation then
        local ok = pcall(function() zombie:pathToLocation(math.floor(x), math.floor(y), math.floor(z)) end)
        if ok then return true, "seeking", candidate, provider.id end
    end
    return false, "pathing-unavailable"
end

Hunger.COMPONENT = COMPONENT
Hunger.BACKEND = VANILLA_BACKEND
return Hunger
