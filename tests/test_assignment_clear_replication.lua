dofile('tests/test_component_roundtrip.lua')
local Identity=require 'Mortis/Runtime/Identity'
local Persistence=require 'Mortis/Runtime/Persistence'
local Replication=require 'Mortis/Runtime/Replication'
local Components=require 'Mortis/Runtime/Components'
local server,client={},{}
assert(Identity.restore(server,'clear-id','Test'))
Components.set(server,'Nested',{enabled=true})
assert(Persistence.flushZombie(server,'clear-id','Test',false))
local snap=assert(Replication.buildSnapshot(server,5,{sessionEpoch='clear-test',revision=1}))
assert(Replication.applySnapshot(client,snap))
assert(Persistence.writeAssignmentClear(server,'clear-id'))
Identity.clear(server)
local clear=assert(Replication.buildClear(server,5,{sessionEpoch='clear-test',revision=2}))
assert(Replication.applyClear(client,clear))
assert(Identity.getTypeId(client)==nil and Identity.getStableId(client)==nil)
assert(client.modData.ProjectMORTIS.identity==nil)
assert(not Components.isDirty(client) and not Components.isReplicationDirty(client))
assert(Replication.applyClear(client,clear)==false,'duplicate clear must be stale')
assert(Replication.applySnapshot(client,snap)==false,'old assignment cannot undo clear')
-- New native object / late join can consume a persisted clear after restart.
local late={}
assert(Identity.restore(late,'clear-id','Test'))
assert(Replication.applyClear(late,clear))
assert(Identity.getTypeId(late)==nil)
assert(Identity.restore(server,'new-id','Test'))
local assigned=assert(Replication.buildSnapshot(server,5,{sessionEpoch='clear-test',revision=3}))
assert(Replication.applySnapshot(client,assigned))
assert(Replication.applyClear(client,clear)==false,'old stable ID clear cannot undo reassignment')
assert(Identity.getTypeId(client)=='Test' and Identity.getStableId(client)=='new-id')
local foreign={protocolVersion=2,stableId='other-id',sessionEpoch='clear-test',revision=99,cleared=true}
assert(Replication.applyClear(client,foreign)==false,'foreign identity must not clear current assignment')
local bad={protocolVersion=2,stableId='new-id',sessionEpoch='clear-test',revision=math.huge,cleared=true}
assert(Replication.applyClear(client,bad)==false)
-- Clearing cached identity and tombstone must survive the native-data boundary.
local saved=Persistence.readAssignmentClear(server)
assert(saved=='clear-id')
Replication.setSessionEpoch('persistent-revision')
assert(Replication.bumpRevision(server)==1)
Replication.release(server)
assert(Replication.bumpRevision(server)==2,'same-epoch reload must retain revision monotonicity')
local replacement={modData=server.modData}
assert(Replication.bumpRevision(replacement)==3,'native wrapper replacement must retain revision')
Replication.setSessionEpoch('restarted-server')
assert(Replication.bumpRevision(replacement)==4,'in-memory revisions may continue safely in a new epoch')
print('Assignment clear, replay rejection and stream/restart cache tests passed')
