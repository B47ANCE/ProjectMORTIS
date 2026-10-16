local ActionDiagnostics=require "Mortis/Core/ActionDiagnostics"
local Capabilities = { values = {}, probed = false }

local function eventExists(name)
    return Events ~= nil and Events[name] ~= nil and type(Events[name].Add) == "function"
end

local function globalExists(name)
    return rawget(_G, name) ~= nil
end

local function instanceMethodExists(object, methodName)
    if object == nil then return false end
    local ok, value = pcall(function() return object[methodName] end)
    return ok and type(value) == "function"
end

function Capabilities.probe()
    local v = Capabilities.values or {}

    local eventNames = {
        "OnTick",
        "OnZombieCreate",
        "OnZombieUpdate",
        "OnZombieDead",
        "OnCharacterDeath",
        "OnHitZombie",
        "OnWeaponHitCharacter",
        "OnPlayerGetDamage",
        "OnPlayerAttackFinished",
        "OnGameStart",
        "OnServerStarted",
        "OnPostSave",
        "OnServerStartSaving",
        "OnClientCommand",
        "OnServerCommand",
        "OnConnected",
        "OnDisconnect",
    }
    for _, name in ipairs(eventNames) do
        v["events." .. name] = eventExists(name)
    end

    v["runtime.isClient"] = type(isClient) == "function"
    v["runtime.isServer"] = type(isServer) == "function"
    v["runtime.getCore"] = type(getCore) == "function"
    v["runtime.Events"] = globalExists("Events")
    v["network.sendClientCommand"] = type(sendClientCommand) == "function"
    v["network.sendServerCommand"] = type(sendServerCommand) == "function"

    Capabilities.values = v
    Capabilities.probed = true
    return Capabilities.all()
end

-- Java instance methods are most reliably observed from a real IsoZombie at
-- runtime. This intentionally augments the startup probe when the first zombie
-- is created rather than assuming class-global Lua bindings are present.
function Capabilities.observeZombie(zombie)
    if not Capabilities.probed then Capabilities.probe() end
    local methods = {
        "doSprinter",
        "doFastShambler",
        "doShambler",
        "doCrawlerSpeed",
        "doZombieSpeed",
        "DoZombieSpeeds",
        "setWalkType",
        "getWalkType",
        "setSpeedTypeFromWalkType",
        "isCrawling",
        "setCrawler",
        "setBecomeCrawler",
        "setFallOnFront",
        "isFallOnFront",
        "knockDown",
        "setKnockedDown",
        "isKnockedDown",
        "setOnFloor",
        "isOnFloor",
        "setStaggerBack",
        "setRagdolling",
        "setRagdoll",
        "setIsRagdolling",
        "isRagdolling",
        "isRagdoll",
        "getRagdolling",
        "setX",
        "setY",
        "isGettingUp",
        "isCanWalk",
        "setCanWalk",
        "getAttackOutcome",
        "getAttackDidDamage",
        "getVariableBoolean",
        "pathToCharacter",
        "pathToLocationF",
        "Wander",
        "tryThump",
        "getOnlineID",
        "getTarget",
        "setTarget",
        "getTargetSeenTime",
        "setTargetSeenTime",
        "isTargetVisible",
        "addAggro",
        "getHealth",
        "setHealth",
        "isDead",
        "getSquare",
        "getX",
        "getY",
        "getZ",
        "getCurrentState",
        "changeState",
        "getVariableString",
        "getHumanVisual",
        "resetModel",
        "resetModelNextFrame",
        "dressInPersistentOutfit",
        "getEmitter",
        "getModData",
        "transmitModData",
    }

    for _, methodName in ipairs(methods) do
        Capabilities.values["zombie." .. methodName] = instanceMethodExists(zombie, methodName)
    end
    Capabilities.values["zombie.instanceObserved"] = zombie ~= nil
    return Capabilities.all()
end


function Capabilities.observeHumanVisual(visual)
    if not Capabilities.probed then Capabilities.probe() end
    local methods = {
        "setSkinTextureName",
        "setSkinTextureIndex",
        "getSkinTexture",
        "getSkinTextureIndex",
        "setHairModel",
        "getHairModel",
        "setBeardModel",
        "getBeardModel",
    }
    for _, methodName in ipairs(methods) do
        Capabilities.values["humanVisual." .. methodName] = instanceMethodExists(visual, methodName)
    end
    Capabilities.values["humanVisual.instanceObserved"] = visual ~= nil
    return Capabilities.all()
end

function Capabilities.has(name)
    if not Capabilities.probed then Capabilities.probe() end
    local available=Capabilities.values[name] == true
    if not available then ActionDiagnostics.recordCapability(name,{observed=Capabilities.values[name]~=nil})end
    return available
end

function Capabilities.get(name)
    if not Capabilities.probed then Capabilities.probe() end
    return Capabilities.values[name]
end

function Capabilities.all()
    if not Capabilities.probed then Capabilities.probe() end
    local copy = {}
    for k, v in pairs(Capabilities.values) do copy[k] = v end
    return copy
end

return Capabilities
