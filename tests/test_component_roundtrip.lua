-- Exercise real component, persistence and replication paths; mock only schemas,
-- type registration and the native modData/network boundary.
local schemas = {
    Flag={id="Flag",version=1,defaults=true,migrations={}},
    Nested={id="Nested",version=1,migrations={}},
    Migrated={id="Migrated",version=2,migrations={[1]=function(value)
        assert(value==false); return false
    end},serialize=function(value) return value end,
       deserialize=function(value) return value end},
}
package.loaded["Mortis/API/Components"]={
    get=function(id) return schemas[id] end,
    all=function() return schemas end,
    isPersistent=function(id) return schemas[id]~=nil end,
    isReplicated=function(id) return schemas[id]~=nil end,
}
local cacheUnavailable=false
package.loaded["Mortis/Runtime/Adapters/PersistenceAdapter"]={
    getModData=function(z)
        if cacheUnavailable then return nil,"native cache unavailable" end
        z.modData=z.modData or {}; return z.modData
    end,
    transmitModData=function() error("unexpected network echo") end,
}
package.loaded["Mortis/Core/FaultIsolation"]={call=function(_,_,fn,...) return pcall(fn,...) end}
local warnings={}
package.loaded["Mortis/Core/Logger"]={
    warn=function(message) warnings[#warnings+1]=message end,
    rateLimited=function(_,_,_,message) warnings[#warnings+1]=message end,
}
package.loaded["Mortis/API/Types"]={has=function(id) return id=="Test" end}
package.loaded["Mortis/Runtime/Adapters/NetworkAdapter"]={getOnlineID=function() return 1 end}
local Components=require "Mortis/Runtime/Components"
local Identity=require "Mortis/Runtime/Identity"
local Persistence=require "Mortis/Runtime/Persistence"
local Replication=require "Mortis/Runtime/Replication"
local server={}
assert(Identity.restore(server,"z1","Test"))
Components.set(server,"Flag",false)
Components.set(server,"Nested",{enabled=false,nested={walking=false},zero=0})
Components.set(server,"Migrated",false)
assert(Persistence.flushComponents(server,false))
local records=server.modData.ProjectMORTIS.components
assert(records.Flag and records.Flag.data==false,"flush must persist false, not delete it")
assert(records.Nested.data.enabled==false and records.Nested.data.nested.walking==false)
records.Migrated.version=1
Components.clear(server)
assert(Persistence.loadComponents(server)==3)
assert(Identity.restore(server,"z1","Test"))
assert(Components.get(server,"Flag")==false,"reload must not restore true default")
assert(Components.get(server,"Migrated")==false)
assert(not Components.isDirty(server) and not Components.isReplicationDirty(server))
local snapshot=assert(Replication.buildSnapshot(server,1,{sessionEpoch="test",revision=1}))
assert(snapshot.components.Flag.data==false)
snapshot.components.Migrated.version=1
local client={}
assert(Replication.applySnapshot(client,snapshot))
assert(Components.get(client,"Flag")==false)
assert(Components.get(client,"Migrated")==false)
assert(Components.get(client,"Nested").nested.walking==false)
assert(not Components.isDirty(client) and not Components.isReplicationDirty(client))
Components.clear(client)
assert(Persistence.loadComponents(client)==3)
assert(Components.get(client,"Flag")==false,"mirrored snapshot must survive stream-out/reload")
-- False and absence remain distinct, including authoritative removal.
Components.remove(server,"Flag")
assert(Persistence.flushComponents(server,false))
assert(records.Flag==nil)
local removed=assert(Replication.buildSnapshot(server,1,{sessionEpoch="test",revision=2}))
assert(Replication.applySnapshot(client,removed))
assert(Components.allFor(client).Flag==nil)
assert(client.modData.ProjectMORTIS.components.Flag==nil)
assert(Components.get(client,"Flag")==true,"absent flag still receives schema default")

-- A failed component flush keeps the entire preceding component snapshot and
-- the dirty flag, so the engine's next update can retry without lost changes.
local beforeNested=records.Nested
local beforeMigrated=records.Migrated
Components.set(server,"Nested",{enabled=true})
Components.remove(server,"Migrated")
Components.set(server,"Flag",false)
schemas.Flag.serialize=function() error("temporary serializer failure") end
local failedSnapshot,snapshotErr=Replication.buildSnapshot(server,1,{revision=3})
assert(failedSnapshot==nil and type(snapshotErr)=="string","do not send partial state after serializer failure")
local saved,err=Persistence.flushComponents(server,false)
assert(saved==false and type(err)=="string","failed flush must be observable")
assert(Components.isDirty(server),"failed save must remain retryable")
assert(records.Nested==beforeNested and records.Migrated==beforeMigrated and records.Flag==nil,
    "failed preflight must not commit writes or deletions")
schemas.Flag.serialize=function() return nil end
assert(Replication.buildSnapshot(server,1)==nil,"nil payload must not become a network deletion")
assert(Persistence.flushComponents(server,false)==false,"missing serialized payload is not a successful save")
assert(Components.isDirty(server) and records.Nested==beforeNested)
schemas.Flag.serialize=function(value) return value end
assert(Persistence.flushComponents(server,false))
assert(not Components.isDirty(server))
assert(records.Flag.data==false and records.Nested.data.enabled==true and records.Migrated==nil)

local copy=require("Mortis/Core/Util").deepCopy
local nextSnapshot=assert(Replication.buildSnapshot(server,1,{sessionEpoch="test",revision=3}))
local clientNested=Components.get(client,"Nested")
local clientSaved=copy(client.modData.ProjectMORTIS)
local function rejectUnchanged(bad)
    local ok,result,reason=pcall(Replication.applySnapshot,client,bad)
    assert(ok and result==false and type(reason)=="string","bad update must return failure, not throw or accept")
    assert(Components.get(client,"Nested")==clientNested,"failed update changed live component")
    assert(Components.get(client,"Flag")==true,"failed update changed another component")
    assert(client.modData.ProjectMORTIS.components.Nested.data.enabled==clientSaved.components.Nested.data.enabled,
        "failed update replaced mirrored state")
    assert(Replication.lastApplied("z1").revision==2,"failed update consumed revision")
end
for _,malformed in ipairs({false,5,"invalid"}) do
    local bad=copy(nextSnapshot); bad.components=malformed; rejectUnchanged(bad)
end
local bad=copy(nextSnapshot); bad.components.Nested=false; rejectUnchanged(bad)
bad=copy(nextSnapshot); bad.components.Nested.data=nil; rejectUnchanged(bad)
bad=copy(nextSnapshot); bad.components.Nested.version=99; rejectUnchanged(bad)
for _,revision in ipairs({-1,1.5,math.huge,0/0}) do
    bad=copy(nextSnapshot); bad.revision=revision; rejectUnchanged(bad)
end
schemas.Nested.deserialize=function() error("temporary decoder failure") end
rejectUnchanged(nextSnapshot)
schemas.Nested.deserialize=function(value) value.enabled="mutated"; error("after mutation") end
rejectUnchanged(nextSnapshot)
assert(nextSnapshot.components.Nested.data.enabled==true,"failed decoder must not mutate retry input")
schemas.Nested.deserialize=function() return nil end
rejectUnchanged(nextSnapshot)
schemas.Nested.deserialize=nil
assert(Replication.applySnapshot(client,nextSnapshot),"corrected same revision must be retryable")
assert(Components.get(client,"Flag")==false and Components.get(client,"Nested").enabled==true)
assert(Components.allFor(client).Migrated==nil)
assert(Replication.applySnapshot(client,nextSnapshot)==false,"successful revision must still reject replays")

local unknown=copy(nextSnapshot)
unknown.stableId="unknown-id"; unknown.typeId="Missing.Mod.Type"; unknown.revision=4
local priorId,priorType=Identity.getStableId(client),Identity.getTypeId(client)
assert(Replication.applySnapshot(client,unknown)==false)
assert(Identity.getStableId(client)==priorId and Identity.getTypeId(client)==priorType,
    "unknown type must not partially replace identity")
assert(Replication.lastApplied("unknown-id")==nil)
local cacheUpdate=copy(nextSnapshot)
cacheUpdate.revision=4; cacheUpdate.components.Nested.data.enabled=false
local oldLive=Components.get(client,"Nested")
local oldCache=client.modData.ProjectMORTIS.components.Nested
cacheUnavailable=true
local cacheAccepted,cacheError=Replication.applySnapshot(client,cacheUpdate)
assert(cacheAccepted==false and type(cacheError)=="string","cache failure must reject update")
assert(Components.get(client,"Nested")==oldLive and Identity.getStableId(client)==priorId)
assert(client.modData.ProjectMORTIS.components.Nested==oldCache)
assert(Replication.lastApplied("z1").revision==3)
cacheUnavailable=false
assert(Replication.applySnapshot(client,cacheUpdate),"cache recovery must accept the same revision")
assert(Components.get(client,"Nested").enabled==false)
assert(client.modData.ProjectMORTIS.components.Nested.data.enabled==false)
for _,invalidType in ipairs({false,3,""}) do
    assert(Identity.restore(client,"bad-id",invalidType)==false)
    assert(Identity.getStableId(client)==priorId and Identity.getTypeId(client)==priorType)
end
-- Untyped vanilla identities still bootstrap their stable ID without attaching
-- a type; the false return means no typed lifecycle should be attached.
local untyped={}
assert(Identity.restore(untyped,"vanilla-id",nil)==false)
assert(Identity.getStableId(untyped)=="vanilla-id" and Identity.getTypeId(untyped)==nil)
print("M.O.R.T.I.S. component persistence/replication roundtrip tests passed")
