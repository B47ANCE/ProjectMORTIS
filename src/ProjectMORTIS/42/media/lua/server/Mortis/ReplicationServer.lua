local Mortis = require "Mortis/init"
local Replication = require "Mortis/Runtime/Replication"
local Network = require "Mortis/Runtime/Adapters/NetworkAdapter"
local Logger = require "Mortis/Core/Logger"

local Server = {}
local SESSION_EPOCH = Replication.newSessionEpoch()
local dirtyPerTick = 24
local pending = setmetatable({}, {__mode="k"})
local callers = setmetatable({}, {__mode="k"})
local tick, globalRequests = 0, 0
-- Protocol admission limits, not gameplay tuning.
local PER_PLAYER_REQUESTS, GLOBAL_REQUESTS, MAX_DISTANCE = 32, 128, 160

local function sendFailure(reason)
    Logger.rateLimited("replication-send",5,"WARN","Replication send deferred: "..tostring(reason))
    return false,reason
end

local function sendSnapshot(player, zombie, reason, requestToken)
    if player==nil then pending[zombie]=true end
    local reconciled, reconcileStatus = Mortis.Engine.reconcilePersistence(zombie)
    if not reconciled and reconcileStatus ~= "not typed" then return sendFailure(reconcileStatus) end
    local onlineId = Network.getOnlineID(zombie)
    if not Replication.validOnlineId(onlineId) then onlineId=nil end
    local revision,revisionError=Replication.bumpRevision(zombie, reason or "reply")
    if not revision then return sendFailure(revisionError) end
    local options={sessionEpoch=SESSION_EPOCH}
    local snapshot,err = Replication.buildSnapshot(zombie,onlineId,options)
    if not snapshot and err=="zombie is not typed" then
        snapshot,err=Replication.buildClear(zombie,onlineId,options)
        if not snapshot then pending[zombie]=nil;return false,err end
    end
    if not snapshot then return sendFailure(err) end
    snapshot.requestToken=requestToken
    local command=snapshot.cleared and Replication.CMD_CLEAR or Replication.CMD_SNAPSHOT
    local ok,sendErr=Network.sendServer(player,Replication.MODULE,command,snapshot)
    if not ok then return sendFailure(sendErr) end
    -- Only delivery to all clients acknowledges a globally dirty component.
    if player==nil then
        pending[zombie]=nil
        Mortis.Components.markReplicationClean(zombie)
    end
    return true
end

function Server.sendZombie(player,zombie) return sendSnapshot(player,zombie,nil) end
function Server.broadcastZombie(zombie,reason) return sendSnapshot(nil,zombie,reason) end

local function resolveZombie(args)
    local byStable=args.stableId and Mortis.Engine.findTrackedByStableId(args.stableId)
    local byOnline=args.onlineId and Mortis.Engine.findTrackedByOnlineID(args.onlineId,true)
    if args.stableId and args.onlineId and (not byStable or byStable~=byOnline) then return nil end
    return byOnline or byStable
end

local function nearby(player,zombie)
    local ok,distance=pcall(function()
        local dx,dy=player:getX()-zombie:getX(),player:getY()-zombie:getY()
        return dx*dx+dy*dy
    end)
    return ok and type(distance)=="number" and distance<=MAX_DISTANCE*MAX_DISTANCE
end

local function onClientCommand(module,command,player,args)
    if module~=Replication.MODULE or (command~=Replication.CMD_REQUEST and command~=Replication.CMD_RECONCILE) then return end
    if player==nil or type(args)~="table" then return end
    if args.stableId~=nil and not Replication.validId(args.stableId) then return end
    if args.onlineId~=nil and not Replication.validOnlineId(args.onlineId) then return end
    if args.requestToken~=nil and not Replication.validId(args.requestToken) then return end
    if args.stableId==nil and args.onlineId==nil then return end
    local state=callers[player]
    if not state or state.tick~=tick then state={tick=tick,count=0,seen={}};callers[player]=state end
    if state.count>=PER_PLAYER_REQUESTS or globalRequests>=GLOBAL_REQUESTS then return end
    local key=tostring(args.onlineId)..":"..tostring(args.stableId)
    if state.seen[key] then return end
    state.seen[key]=true;state.count=state.count+1;globalRequests=globalRequests+1
    local zombie=resolveZombie(args)
    if not zombie or not nearby(player,zombie) then return end
    -- Unassigned vanilla entities require no typed-state reply.
    sendSnapshot(player,zombie,nil,args.requestToken)
end

-- Server Lua also loads in SP, where no remote reconciliation is needed.
if type(isServer)=="function" and isServer()~=true then return Server end
if Events and Events.OnClientCommand and type(Events.OnClientCommand.Add)=="function" then Events.OnClientCommand.Add(onClientCommand) end
Mortis.Events:on("ThreatAssigned",function(zombie) Server.broadcastZombie(zombie,"assigned") end)
Mortis.Events:on("ThreatCleared",function(zombie) Server.broadcastZombie(zombie,"cleared") end)
if Events and Events.OnTick and type(Events.OnTick.Add)=="function" then
    Events.OnTick.Add(function()
        tick=tick+1;globalRequests=0
        local retry={}
        for zombie in pairs(pending) do
            retry[#retry+1]=zombie
            if #retry>=dirtyPerTick then break end
        end
        local sent={}
        for _,zombie in ipairs(retry) do sendSnapshot(nil,zombie,"retry");sent[zombie]=true end
        local zombies=Mortis.Engine.collectReplicationDirty(dirtyPerTick)
        for _,zombie in ipairs(zombies) do
            if not sent[zombie] then Server.broadcastZombie(zombie,"component-dirty") end
        end
    end)
end
Logger.info("M.O.R.T.I.S. replication epoch: "..SESSION_EPOCH)
return Server
