local handlers,listeners,sends={},{},{}
isServer=function()return true end
local zombie={dirty=true,onlineId=7}
local fail=false
local buildFail=false
local lookups=0
local player={getX=function()return 0 end,getY=function()return 0 end}
zombie.getX=player.getX;zombie.getY=player.getY
Events={OnClientCommand={Add=function(fn)handlers.command=fn end},OnTick={Add=function(fn)handlers.tick=fn end}}
local replication={MODULE='ProjectMORTIS',CMD_REQUEST='request',CMD_RECONCILE='reconcile',CMD_SNAPSHOT='snapshot',CMD_CLEAR='clear',
 newSessionEpoch=function()return 'test' end,buildSnapshot=function()if buildFail then return nil,'serialize failed' end;if zombie.cleared then return nil,'zombie is not typed' end;return {stableId='z',typeId='Test'} end,
 bumpRevision=function()return 1 end,buildClear=function()return{stableId='z',cleared=true}end,
 validId=function(v)return type(v)=='string' and #v>0 and #v<=128 end,
 validOnlineId=function(v)return type(v)=='number' and v>=0 and v<2147483648 and v==math.floor(v)end}
local Mortis={Engine={reconcilePersistence=function()return true end,
 findTrackedByStableId=function(id)return id=='z' and zombie or nil end,
 findTrackedByOnlineID=function(id,indexOnly)lookups=lookups+1;assert(indexOnly==true);return id==7 and zombie or nil end,
 collectReplicationDirty=function()return zombie.dirty and {zombie} or {}end},
 getStableId=function()return 'z'end,
 Persistence={readAssignmentClear=function()return 'z'end},
 Components={markReplicationClean=function(z)z.dirty=false end},
 Events={on=function(_,name,fn)listeners[name]=fn end}}
package.loaded['Mortis/init']=Mortis
package.loaded['Mortis/Runtime/Replication']=replication
package.loaded['Mortis/Runtime/Adapters/NetworkAdapter']={getOnlineID=function(z)return z.onlineId end,
 sendServer=function(p,_,command)if fail then return false,'failure' end;sends[#sends+1]={player=p,command=command};return true end}
package.loaded['Mortis/Core/Logger']={info=function()end,warn=function()end,rateLimited=function()end}
local Server=require 'Mortis/ReplicationServer'
handlers.command('ProjectMORTIS','request',player,{onlineId=7})
assert(zombie.dirty,'direct reply must retain broadcast dirtiness')
handlers.tick()
assert(#sends==2 and sends[1].player==player and sends[2].player==nil)
assert(not zombie.dirty)
local before=#sends
for i=1,1000 do handlers.command('ProjectMORTIS','request',player,{onlineId=7})end
assert(#sends-before<=1,'same-tick repeated requests must coalesce')
for _,args in ipairs({42,false,'bad',{onlineId=-1},{onlineId=0/0},{stableId=string.rep('x',129)},{onlineId=7,stableId='wrong'}})do
 assert(pcall(handlers.command,'ProjectMORTIS','request',player,args))
end
assert(#sends-before<=1,'malformed/mismatched requests must not send')
assert(type(listeners.ThreatCleared)=='function')
zombie.cleared=true;fail=true;listeners.ThreatCleared(zombie,'Test','z')
fail=false;handlers.tick()
assert(sends[#sends].command=='clear','failed clear broadcast must retry')
zombie.cleared=false;buildFail=true
local prior=#sends
listeners.ThreatAssigned(zombie)
assert(#sends==prior)
buildFail=false;handlers.tick()
assert(#sends==prior+1,'snapshot serializer failure must retain pending assignment')
local distant={getX=function()return 10000 end,getY=function()return 0 end}
prior=#sends
handlers.command('ProjectMORTIS','request',distant,{onlineId=7})
assert(#sends==prior,'remote entity request must be rejected')
handlers.tick()
local start=lookups
for i=100,1099 do handlers.command('ProjectMORTIS','request',player,{onlineId=i})end
assert(lookups-start==32,'distinct requests must respect the per-player budget')
for peer=1,4 do
 local other={getX=player.getX,getY=player.getY}
 for i=100,1099 do handlers.command('ProjectMORTIS','request',other,{onlineId=i})end
end
assert(lookups-start==128,'global budget must bound all callers together')
print('Directed delivery, request limits and clear retry tests passed')
