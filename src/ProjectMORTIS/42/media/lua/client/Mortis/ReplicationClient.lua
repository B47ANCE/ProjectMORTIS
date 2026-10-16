local Mortis = require "Mortis/init"
local Replication = require "Mortis/Runtime/Replication"
local Network = require "Mortis/Runtime/Adapters/NetworkAdapter"
local Logger = require "Mortis/Core/Logger"

local Client = {}
local pendingByOnlineId = {}
local pendingByStableId = {}
local requested = {}
local tick = 0
local sweepQueue = nil
local sweepIndex = 1

local REQUEST_RETRY_TICKS = 180
local PENDING_TTL_TICKS = 900
local RECONCILE_SWEEP_TICKS = 600
local REQUEST_BUDGET = 16

local function requestKey(stableId, onlineId)
    if type(stableId) == "string" and stableId ~= "" then return "s:" .. stableId end
    if type(onlineId) == "number" and onlineId >= 0 then return "o:" .. tostring(onlineId) end
    return nil
end

local function clearRequest(snapshot)
    if type(snapshot.stableId) == "string" then requested["s:" .. snapshot.stableId] = nil end
    if type(snapshot.onlineId) == "number" and snapshot.onlineId >= 0 then requested["o:" .. tostring(snapshot.onlineId)] = nil end
end

local function requestZombie(zombie, reconcile)
    local onlineId = Network.getOnlineID(zombie)
    local stableId = Mortis.getStableId(zombie)
    if (type(onlineId) ~= "number" or onlineId < 0) and type(stableId) ~= "string" then return false end

    local key = requestKey(stableId, onlineId)
    local state = key and requested[key] or nil
    if state and (tick - state.tick) < REQUEST_RETRY_TICKS then return true end

    local command = reconcile and Replication.CMD_RECONCILE or Replication.CMD_REQUEST
    local ok = Network.sendClient(Replication.MODULE, command, { onlineId = onlineId, stableId = stableId })
    if ok == true and key then
        requested[key] = { tick = tick, attempts = (state and state.attempts or 0) + 1 }
    end
    return ok == true
end

local function apply(zombie, snapshot)
    local ok, previousOrReason = Replication.applySnapshot(zombie, snapshot)
    if ok then
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
    if not record and type(onlineId) == "number" and onlineId >= 0 then record = pendingByOnlineId[onlineId] end
    if not record or not record.snapshot then return nil end

    local snapshot = record.snapshot
    if type(snapshot.stableId) == "string" then pendingByStableId[snapshot.stableId] = nil end
    if type(snapshot.onlineId) == "number" and snapshot.onlineId >= 0 then pendingByOnlineId[snapshot.onlineId] = nil end
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
    if module ~= Replication.MODULE or command ~= Replication.CMD_SNAPSHOT then return end
    args = args or {}

    local zombie
    if type(args.stableId) == "string" then zombie = Mortis.Engine.findTrackedByStableId(args.stableId) end
    if not zombie and type(args.onlineId) == "number" then zombie = Mortis.Engine.findTrackedByOnlineID(args.onlineId) end

    if zombie then
        apply(zombie, args)
        return
    end

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
end


local function resetTransientState()
    pendingByOnlineId = {}
    pendingByStableId = {}
    requested = {}
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
        if tick == 1 or tick % RECONCILE_SWEEP_TICKS == 1 then beginReconcileSweep() end
        advanceReconcileSweep()
    end)
end

return Client
