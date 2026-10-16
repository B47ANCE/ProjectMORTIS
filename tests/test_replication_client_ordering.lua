dofile('tests/test_component_roundtrip.lua')
isClient=function()return true end
local Identity=require 'Mortis/Runtime/Identity'
local Persistence=require 'Mortis/Runtime/Persistence'
local Replication=require 'Mortis/Runtime/Replication'
local Components=require 'Mortis/Runtime/Components'
local callbacks,tracked,requests={}, {}, {}
local transitions=0
Events={OnServerCommand={Add=function(fn)callbacks.command=fn end},OnZombieCreate={Add=function()end}}
package.loaded['Mortis/Runtime/Adapters/NetworkAdapter']={getOnlineID=function(z)return z.onlineId end,
 sendClient=function(_,_,args)requests[#requests+1]=args;return true end}
package.loaded['Mortis/init']={getStableId=Identity.getStableId,Engine={
 findTrackedByStableId=function(id)for _,z in ipairs(tracked)do if Identity.getStableId(z)==id then return z end end end,
 findTrackedByOnlineID=function(id)for _,z in ipairs(tracked)do if z.onlineId==id then return z end end end,
 onReplicated=function()transitions=transitions+1 end}}
local Client=require 'Mortis/ReplicationClient'
local server,client={onlineId=7},{onlineId=7}
tracked={client}
assert(Identity.restore(server,'a','Test'))
local one=assert(Replication.buildSnapshot(server,7,{sessionEpoch='ordering',revision=1}))
callbacks.command('ProjectMORTIS','ThreatSnapshot',one)
assert(Identity.getTypeId(client)=='Test')
assert(Persistence.writeAssignmentClear(server,'a'));Identity.clear(server)
local clear=assert(Replication.buildClear(server,7,{sessionEpoch='ordering',revision=2}))
callbacks.command('ProjectMORTIS','ThreatClear',clear)
assert(Identity.getTypeId(client)==nil and transitions==2)
callbacks.command('ProjectMORTIS','ThreatSnapshot',one)
assert(Identity.getTypeId(client)==nil,'late typed snapshot must not undo clear')
assert(Identity.restore(server,'b','Test'))
local newer=assert(Replication.buildSnapshot(server,7,{sessionEpoch='ordering',revision=3}))
callbacks.command('ProjectMORTIS','ThreatSnapshot',newer)
callbacks.command('ProjectMORTIS','ThreatClear',clear)
assert(Identity.getStableId(client)=='b' and Identity.getTypeId(client)=='Test')
-- Cache failure must permit retry of the same clear revision.
local adapter=require 'Mortis/Runtime/Adapters/PersistenceAdapter'
local getData=adapter.getModData
adapter.getModData=function()return nil,'cache unavailable' end
local nextClear={protocolVersion=2,cleared=true,stableId='b',onlineId=7,sessionEpoch='ordering',revision=4}
callbacks.command('ProjectMORTIS','ThreatClear',nextClear)
assert(Identity.getTypeId(client)=='Test')
adapter.getModData=getData
callbacks.command('ProjectMORTIS','ThreatClear',nextClear)
assert(Identity.getTypeId(client)==nil)
-- A queued older clear must not overwrite a newer assignment for the same ID.
tracked={}
newer.revision=5
callbacks.command('ProjectMORTIS','ThreatSnapshot',newer)
callbacks.command('ProjectMORTIS','ThreatClear',clear)
local restream={onlineId=7}
assert(Identity.restore(restream,'a','Test'))
tracked={restream}
Client.onZombieCreated(restream)
assert(Identity.getStableId(restream)=='b')
assert(#requests==1 and requests[1].onlineId==7 and requests[1].stableId==nil)
local mismatch={protocolVersion=2,cleared=true,stableId='b',onlineId=8,sessionEpoch='ordering',revision=6}
callbacks.command('ProjectMORTIS','ThreatClear',mismatch)
assert(Identity.getTypeId(restream)=='Test','native online ID must agree before applying')
-- A client may have missed multiple complete assign/clear cycles. A clear for
-- the latest identity may replace an older cache only through its own live
-- request token, bound to the current native object/online ID.
local missed={onlineId=7}
assert(Identity.restore(missed,'much-older-id','Test'))
tracked={missed}
Client.onZombieCreated(missed)
local latest={protocolVersion=2,cleared=true,stableId='b',onlineId=7,sessionEpoch='ordering',revision=6}
callbacks.command('ProjectMORTIS','ThreatClear',latest)
assert(Identity.getTypeId(missed)=='Test','uncorrelated foreign clear must fail closed')
latest.requestToken=requests[#requests].requestToken
callbacks.command('ProjectMORTIS','ThreatClear',latest)
assert(Identity.getTypeId(missed)==nil,'correlated current-state reply must repair an older cache')
assert(Identity.restore(missed,'newer-live-id','Test'))
latest.revision=7
callbacks.command('ProjectMORTIS','ThreatClear',latest)
assert(Identity.getTypeId(missed)=='Test','consumed request token must not authorize another identity replacement')
assert(pcall(callbacks.command,'ProjectMORTIS','ThreatClear',42))
assert(not Components.isReplicationDirty(restream))
print('Client clear, pending ordering, cache retry and native-ID binding passed')
