local Mortis = require "Mortis/init"
local Replication = require "Mortis/Runtime/Replication"
local Network = require "Mortis/Runtime/Adapters/NetworkAdapter"
local Logger = require "Mortis/Core/Logger"

local Server = {}
local SESSION_EPOCH = Replication.newSessionEpoch()
local dirtyPerTick = 24

local function sendSnapshot(player, zombie, bumpReason)
    local reconciled, reconcileStatus = Mortis.Engine.reconcilePersistence(zombie)
    if not reconciled and reconcileStatus ~= "not typed" then
        Logger.warn("Persistence reconciliation before snapshot failed: " .. tostring(reconcileStatus))
    end
    local onlineId = Network.getOnlineID(zombie)
    if bumpReason then Replication.bumpRevision(zombie, bumpReason) end
    local snapshot, err = Replication.buildSnapshot(zombie, onlineId, { sessionEpoch = SESSION_EPOCH })
    if not snapshot then return false, err end
    local ok, sendErr = Network.sendServer(player, Replication.MODULE, Replication.CMD_SNAPSHOT, snapshot)
    if not ok then return false, sendErr end
    Mortis.Components.markReplicationClean(zombie)
    return true
end

function Server.sendZombie(player, zombie)
    return sendSnapshot(player, zombie, nil)
end

function Server.broadcastZombie(zombie, reason)
    return sendSnapshot(nil, zombie, reason)
end

local function resolveZombie(args)
    local zombie
    if type(args.stableId) == "string" then zombie = Mortis.Engine.findTrackedByStableId(args.stableId) end
    if not zombie and type(args.onlineId) == "number" then zombie = Mortis.Engine.findTrackedByOnlineID(args.onlineId) end
    return zombie
end

local function onClientCommand(module, command, player, args)
    if module ~= Replication.MODULE then return end
    args = args or {}

    if command == Replication.CMD_REQUEST or command == Replication.CMD_RECONCILE then
        local zombie = resolveZombie(args)
        if not zombie then return end
        local ok, err = sendSnapshot(player, zombie, nil)
        if not ok then Logger.warn("Snapshot request failed: " .. tostring(err)) end
    end
end

if Events and Events.OnClientCommand and type(Events.OnClientCommand.Add) == "function" then
    Events.OnClientCommand.Add(onClientCommand)
end

Mortis.Events:on("ThreatAssigned", function(zombie)
    Server.broadcastZombie(zombie, "assigned")
end)

if Events and Events.OnTick and type(Events.OnTick.Add) == "function" then
    Events.OnTick.Add(function()
        local zombies = Mortis.Engine.collectReplicationDirty(dirtyPerTick)
        for i = 1, #zombies do
            local ok, err = Server.broadcastZombie(zombies[i], "component-dirty")
            if not ok then Logger.warn("Replication broadcast failed: " .. tostring(err)) end
        end
    end)
end

Logger.info("M.O.R.T.I.S. replication epoch: " .. SESSION_EPOCH)
return Server
