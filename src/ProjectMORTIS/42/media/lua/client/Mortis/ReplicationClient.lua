local Mortis = require "Mortis/init"
local Replication = require "Mortis/Runtime/Replication"
local Network = require "Mortis/Runtime/Adapters/NetworkAdapter"
local Logger = require "Mortis/Core/Logger"

local Client = {}
local pendingByOnlineId = {}
local pendingByStableId = {}
local requested = {}
local requestedCount = 0
local requestsByToken = {}
local requestSequence = 0
local tick = 0
local sweepQueue = nil
local sweepIndex = 1

local REQUEST_RETRY_TICKS = 180
local PENDING_TTL_TICKS = 900
local RECONCILE_SWEEP_TICKS = 600
local REQUEST_BUDGET = 16
local MAX_PENDING = 512

local function requestKey(stableId, onlineId)
    if type(stableId) == "string" and stableId ~= "" then return "s:" .. stableId end
    if type(onlineId) == "number" and onlineId >= 0 then return "o:" .. tostring(onlineId) end
    return nil
end

local function clearRequest(snapshot)
    local function remove(key)
        if requested[key] then
            requestsByToken[requested[key].token]=nil
            requested[key]=nil;requestedCount=requestedCount-1
        end
    end
    if type(snapshot.stableId) == "string" then remove("s:" .. snapshot.stableId) end
    if type(snapshot.onlineId) == "number" and snapshot.onlineId >= 0 then remove("o:" .. tostring(snapshot.onlineId)) end
end

local function requestZombie(zombie, reconcile)
    local onlineId = Network.getOnlineID(zombie)
    local stableId = Mortis.getStableId(zombie)
    if (type(onlineId) ~= "number" or onlineId < 0) and type(stableId) ~= "string" then return false end

    local key = requestKey(stableId, onlineId)
    local state = key and requested[key] or nil
    if state and (tick - state.tick) < REQUEST_RETRY_TICKS then return true end
    if not state and requestedCount>=MAX_PENDING then return false end

    local command = reconcile and Replication.CMD_RECONCILE or Replication.CMD_REQUEST
    -- Native online ID is the request locator. A cached stable ID may have
    -- been authoritatively cleared/reassigned while this client was absent.
    local args=Replication.validOnlineId(onlineId) and {onlineId=onlineId} or {stableId=stableId}
    requestSequence=requestSequence+1
    args.requestToken="MORTIS-REQ-"..tostring(requestSequence)
    local ok = Network.sendClient(Replication.MODULE, command, args)
    if ok == true and key then
        if not state then requestedCount=requestedCount+1 end
        if state then requestsByToken[state.token]=nil end
        local record={tick=tick,attempts=(state and state.attempts or 0)+1,token=args.requestToken,
            key=key,onlineId=onlineId,entity=setmetatable({zombie},{__mode="v"})}
        requested[key]=record
        requestsByToken[record.token]=record
    end
    return ok == true
end

local function apply(zombie, snapshot)
    local ok, previousOrReason
    local request=type(snapshot.requestToken)=="string" and requestsByToken[snapshot.requestToken]
    local correlated=request and request.entity[1]==zombie and request.onlineId==snapshot.onlineId
        and tick-request.tick<PENDING_TTL_TICKS
    if snapshot.cleared then ok,previousOrReason=Replication.applyClear(zombie,snapshot,{reconciledRequest=correlated==true})
    else ok,previousOrReason=Replication.applySnapshot(zombie,snapshot) end
    if ok then
        if request then
            requested[request.key]=nil;requestsByToken[request.token]=nil;requestedCount=requestedCount-1
        end
        clearRequest(snapshot)
        Mortis.Engine.onReplicated(zombie, previousOrReason)
        return true
    end
    if previousOrReason ~= "stale" then
        Logger.warn("Could not apply threat snapshot: " .. tostring(previousOrReason) .. " [" .. Replication.describeSnapshot(snapshot) .. "]")
    else
        clearRequest(snapshot)
    end
    return false
end

local function takePending(zombie)
    local stableId = Mortis.getStableId(zombie)
    local onlineId = Network.getOnlineID(zombie)
    local record
    if type(stableId) == "string" then record = pendingByStableId[stableId] end
    local online=type(onlineId)=="number" and pendingByOnlineId[onlineId] or nil
    if online and (not record or (online.snapshot.sessionEpoch==record.snapshot.sessionEpoch and online.snapshot.revision>record.snapshot.revision)) then record=online end
    if not record or not record.snapshot then return nil end
    if record.expires<=tick then return nil end

    local snapshot = record.snapshot
    if pendingByStableId[snapshot.stableId]==record then pendingByStableId[snapshot.stableId]=nil end
    if snapshot.onlineId and pendingByOnlineId[snapshot.onlineId]==record then pendingByOnlineId[snapshot.onlineId]=nil end
    return snapshot
end

function Client.onZombieCreated(zombie)
    local snapshot = takePending(zombie)
    if snapshot then apply(zombie, snapshot) end

    -- Always reconcile a streamed zombie with the server. Local modData is a
    -- bootstrap cache only; the server remains authoritative in multiplayer.
    requestZombie(zombie, true)
end

local function onServerCommand(module, command, args)
    if module ~= Replication.MODULE or (command ~= Replication.CMD_SNAPSHOT and command~=Replication.CMD_CLEAR) then return end
    if type(args)~="table" or not Replication.validId(args.stableId) or not Replication.validId(args.sessionEpoch) then return end
    if type(args.revision)~="number" or args.revision<0 or args.revision==math.huge or args.revision~=math.floor(args.revision) then return end
    if args.onlineId~=nil and not Replication.validOnlineId(args.onlineId) then return end
    if command==Replication.CMD_CLEAR and args.cleared~=true then return end
    if command==Replication.CMD_SNAPSHOT and args.cleared~=nil then return end

    local zombie
    if type(args.stableId) == "string" then zombie = Mortis.Engine.findTrackedByStableId(args.stableId) end
    if not zombie and type(args.onlineId) == "number" then zombie = Mortis.Engine.findTrackedByOnlineID(args.onlineId) end

    if zombie then
        if args.onlineId~=nil and Network.getOnlineID(zombie)~=args.onlineId then return end
        apply(zombie, args)
        return
    end

    local existing=pendingByStableId[args.stableId] or (args.onlineId and pendingByOnlineId[args.onlineId])
    if existing and existing.snapshot.sessionEpoch==args.sessionEpoch and existing.snapshot.revision>=args.revision then return end
    local onlineExisting=args.onlineId and pendingByOnlineId[args.onlineId]
    if onlineExisting and onlineExisting.snapshot.sessionEpoch==args.sessionEpoch and onlineExisting.snapshot.revision>=args.revision then return end
    if not existing then
        local count=0
        for _ in pairs(pendingByStableId) do count=count+1 end
        if count>=MAX_PENDING then return end
    end
    local function remove(record)
        if not record then return end
        local old=record.snapshot
        if pendingByStableId[old.stableId]==record then pendingByStableId[old.stableId]=nil end
        if old.onlineId and pendingByOnlineId[old.onlineId]==record then pendingByOnlineId[old.onlineId]=nil end
    end
    remove(pendingByStableId[args.stableId])
    if args.onlineId then remove(pendingByOnlineId[args.onlineId]) end
    local record = { snapshot = args, expires = tick + PENDING_TTL_TICKS }
    if type(args.stableId) == "string" then pendingByStableId[args.stableId] = record end
    if type(args.onlineId) == "number" and args.onlineId >= 0 then pendingByOnlineId[args.onlineId] = record end
end

local function cleanupPending()
    for key, record in pairs(pendingByOnlineId) do
        if record.expires and record.expires <= tick then pendingByOnlineId[key] = nil end
    end
    for key, record in pairs(pendingByStableId) do
        if record.expires and record.expires <= tick then pendingByStableId[key] = nil end
    end
    for key,record in pairs(requested) do
        if tick-record.tick>=PENDING_TTL_TICKS then
            requestsByToken[record.token]=nil;requested[key]=nil;requestedCount=requestedCount-1
        end
    end
end


local function resetTransientState()
    pendingByOnlineId = {}
    pendingByStableId = {}
    requested = {}
    requestedCount = 0
    requestsByToken = {}
    sweepQueue = nil
    sweepIndex = 1
end

local function beginReconcileSweep()
    -- A temporary strong-reference queue is acceptable here: it is bounded to
    -- the duration of one reconciliation sweep and released immediately after.
    sweepQueue = Mortis.Engine.listTracked()
    sweepIndex = 1
end

local function advanceReconcileSweep()
    if not sweepQueue then return end
    local sent = 0
    while sweepIndex <= #sweepQueue and sent < REQUEST_BUDGET do
        local zombie = sweepQueue[sweepIndex]
        sweepIndex = sweepIndex + 1
        if zombie ~= nil then
            requestZombie(zombie, true)
            sent = sent + 1
        end
    end
    if sweepIndex > #sweepQueue then
        sweepQueue = nil
        sweepIndex = 1
    end
end

-- SP still loads client presentation and test tools, but has no MP peer.
if type(isClient)=="function" and isClient()~=true then return Client end
if Events and Events.OnServerCommand and type(Events.OnServerCommand.Add) == "function" then
    Events.OnServerCommand.Add(onServerCommand)
end

if Events and Events.OnZombieCreate and type(Events.OnZombieCreate.Add) == "function" then
    Events.OnZombieCreate.Add(Client.onZombieCreated)
end


if Events and Events.OnConnected and type(Events.OnConnected.Add) == "function" then
    Events.OnConnected.Add(function()
        resetTransientState()
        beginReconcileSweep()
    end)
end

if Events and Events.OnDisconnect and type(Events.OnDisconnect.Add) == "function" then
    Events.OnDisconnect.Add(function()
        resetTransientState()
    end)
end

if Events and Events.OnTick and type(Events.OnTick.Add) == "function" then
    Events.OnTick.Add(function()
        tick = tick + 1
        if tick % 120 == 0 then cleanupPending() end
        if not sweepQueue and (tick == 1 or tick % RECONCILE_SWEEP_TICKS == 1) then beginReconcileSweep() end
        advanceReconcileSweep()
    end)
end

return Client
