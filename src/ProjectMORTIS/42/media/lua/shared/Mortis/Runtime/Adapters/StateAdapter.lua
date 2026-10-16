local Capabilities = require "Mortis/API/Capabilities"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"
local ActionDiagnostics = require "Mortis/Core/ActionDiagnostics"

local StateAdapter = {}

local busyTokens = {
    "attack", "hit", "stagger", "fall", "knock", "getup", "get up",
    "climb", "fence", "window", "thump", "grapple", "bite", "lunge",
    "death", "dead", "ragdoll",
}

local function safeCall(zombie, method, capability, ...)
    if not Capabilities.has(capability or ("zombie." .. method)) then return nil, "capability unavailable" end
    local ok, value = GameAdapter.call(zombie, method, ...)
    if not ok then return nil, value end
    return value
end

function StateAdapter.getNativeState(zombie)
    local state, err = safeCall(zombie, "getCurrentState", "zombie.getCurrentState")
    if state == nil then return nil, err end
    return state
end

function StateAdapter.getNativeStateKey(zombie)
    local state, err = StateAdapter.getNativeState(zombie)
    if state == nil then return nil, err end
    local ok, value = pcall(tostring, state)
    if not ok then return nil, value end
    return value
end

function StateAdapter.getVariable(zombie, name)
    return safeCall(zombie, "getVariableString", "zombie.getVariableString", name)
end

function StateAdapter.getVariableBoolean(zombie, name)
    return safeCall(zombie, "getVariableBoolean", "zombie.getVariableBoolean", name)
end

function StateAdapter.isCrawling(zombie)
    local value, err = safeCall(zombie, "isCrawling", "zombie.isCrawling")
    if value == nil then return nil, err end
    return value == true
end

function StateAdapter.isGettingUp(zombie)
    local value, err = safeCall(zombie, "isGettingUp", "zombie.isGettingUp")
    if value == nil then return nil, err end
    return value == true
end

function StateAdapter.isBusy(zombie)
    local gettingUp = StateAdapter.isGettingUp(zombie)
    if gettingUp == true then return true, "getting-up" end

    local key = StateAdapter.getNativeStateKey(zombie)
    if type(key) == "string" then
        local lower = string.lower(key)
        for _, token in ipairs(busyTokens) do
            if string.find(lower, token, 1, true) then return true, token end
        end
    end
    return false, key or "unknown"
end

-- Release a living zombie from a framework-controlled prone state. Consumers
-- must not call methods on getStateMachine(): Build 42 exposes that Java object
-- to Lua, but its methods are not safely indexable in every runtime binding.
-- IsoGameCharacter.changeState(State) is the documented public transition.
-- Wake without a standing/get-up animation. ZombieIdleState preserves crawling
-- and sets on-floor from that flag; IsoZombie.shouldGetUpFromCrawl respects
-- setCanWalk(false). Consumers own the anatomical decision to use this path.
-- Apply crawler posture without resetting an active attack/path state. All
-- required bindings are checked before writes; already-correct flags are kept.
function StateAdapter.getCanWalk(zombie)
    local value,err=safeCall(zombie,"isCanWalk","zombie.isCanWalk")
    if type(value)~="boolean" then return nil,err or "walking permission unavailable" end
    return value
end

function StateAdapter.setWalkingAllowed(zombie,allowed)
    if type(allowed)~="boolean" then return false,"boolean walking permission required" end
    if not Capabilities.has("zombie.setCanWalk") then return false,"walking capability unavailable" end
    local current=StateAdapter.getCanWalk(zombie)
    if current==allowed then return true,"unchanged" end
    return GameAdapter.call(zombie,"setCanWalk",allowed)
end

function StateAdapter.maintainCrawler(zombie)
    if zombie==nil then return false,"missing zombie" end
    local flags={{"isCanWalk","setCanWalk",false},{"isCrawling","setCrawler",true},
        {"isOnFloor","setOnFloor",true}}
    for _,flag in ipairs(flags) do
        if not Capabilities.has("zombie."..flag[2]) then return false,"crawler capability unavailable" end
    end
    for _,flag in ipairs(flags) do
        local read,value=GameAdapter.call(zombie,flag[1])
        if not read or value~=flag[3] then
            local ok,err=GameAdapter.call(zombie,flag[2],flag[3])
            if not ok then return false,err end
        end
    end
    return true,"crawler-posture"
end

function StateAdapter.requestCrawlerWake(zombie)
    if zombie == nil then return false,"missing zombie" end
    local calls = {{"setCanWalk",false},{"setCrawler",true},{"setKnockedDown",false}}
    for _,call in ipairs(calls) do
        if not Capabilities.has("zombie."..call[1]) then return false,"crawler capability unavailable" end
    end
    local idle=rawget(_G,"ZombieIdleState")
    if not Capabilities.has("zombie.changeState") or idle==nil or type(idle.instance)~="function" then
        return false,"crawler idle transition unavailable"
    end
    local resolved,state=pcall(idle.instance)
    if not resolved or state==nil then return false,"crawler idle state unavailable" end
    for _,call in ipairs(calls) do
        local ok,err=GameAdapter.call(zombie,call[1],call[2])
        if not ok then return false,err end
    end
    local ok,err=GameAdapter.call(zombie,"changeState",state)
    if not ok then return false,err end
    return true,"crawler-idle-state"
end

function StateAdapter.requestStand(zombie, options)
    options = options or {}
    if zombie == nil then return ActionDiagnostics.record("rejection","state.requestStand","missing zombie") end

    local released = false
    local releaseMethods = {
        { "setKnockedDown", false },
        { "setFallOnFront", false },
        { "setCrawler", false },
        { "setCanWalk", true },
    }
    for _, call in ipairs(releaseMethods) do
        if Capabilities.has("zombie." .. call[1]) then
            local ok = GameAdapter.call(zombie, call[1], call[2])
            released = released or ok
        end
    end

    local getUpClass = rawget(_G, "ZombieGetUpState")
    if options.forceTransition ~= false
        and Capabilities.has("zombie.changeState")
        and getUpClass ~= nil and type(getUpClass.instance) == "function" then
        local okState, state = pcall(getUpClass.instance)
        if okState and state ~= nil then
            local transitioned, reason = GameAdapter.call(zombie, "changeState", state)
            if transitioned then return true, "get-up-state" end
            if not released then return false, reason end
        end
    end

    if released then return true, "released-to-vanilla-ai" end
    return ActionDiagnostics.record("rejection","state.requestStand","no verified stand capability")
end

-- Enter the engine's living fake-dead state atomically. Setting isFakeDead on
-- a zombie that is already in ZombieOnGroundState is lethal in Build 42:
-- ZombieOnGroundState explicitly calls die() when that flag is true. Consumers
-- must therefore request the exposed FakeDeadZombieState itself and must never
-- approximate this transition with a loose collection of prone-state flags.
function StateAdapter.requestFakeDead(zombie)
    if zombie == nil then return ActionDiagnostics.record("rejection","state.requestFakeDead","missing zombie") end
    if not Capabilities.has("zombie.changeState") then
        return ActionDiagnostics.record("rejection","state.requestFakeDead","changeState capability unavailable")
    end
    local fakeDeadClass=rawget(_G,"FakeDeadZombieState")
    if fakeDeadClass==nil or type(fakeDeadClass.instance)~="function" then
        return ActionDiagnostics.record("rejection","state.requestFakeDead","FakeDeadZombieState unavailable")
    end
    local okState,state=pcall(fakeDeadClass.instance)
    if not okState or state==nil then
        return ActionDiagnostics.record("rejection","state.requestFakeDead","FakeDeadZombieState instance unavailable")
    end
    local transitioned,reason=GameAdapter.call(zombie,"changeState",state)
    if not transitioned then return false,reason end
    return true,"fake-dead-state"
end

function StateAdapter.snapshot(zombie)
    local key = StateAdapter.getNativeStateKey(zombie)
    local crawling = StateAdapter.isCrawling(zombie)
    local gettingUp = StateAdapter.isGettingUp(zombie)
    local busy, reason = StateAdapter.isBusy(zombie)
    return {
        nativeState = key,
        crawling = crawling,
        gettingUp = gettingUp,
        busy = busy,
        busyReason = reason,
    }
end

return StateAdapter
