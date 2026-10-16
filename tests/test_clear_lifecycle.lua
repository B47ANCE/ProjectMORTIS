dofile('tests/test_engine_tracked_batches.lua')
local Engine=require 'Mortis/Runtime/Engine'
local Identity=require 'Mortis/Runtime/Identity'
local Types=require 'Mortis/API/Types'
local Behaviors=require 'Mortis/API/Behaviors'
local Profiles=require 'Mortis/Runtime/ProfileRuntime'
local detached,durability,appearance=0,0,0
local definition={behaviors={'test-behavior'}}
Types.get=function(id)return id=='test' and definition or nil end
Identity.getType=function(z)return Types.get(z.typeId)end
Behaviors.get=function()return{onDetach=function()detached=detached+1 end}end
Profiles.applyDurability=function(_,def)assert(def==nil);durability=durability+1 end
Profiles.applyAppearance=function(_,def)assert(def==nil);appearance=appearance+1 end
local zombie={stableId='clear-lifecycle',typeId='test',onlineId=1000}
Engine.onCreated(zombie)
zombie.typeId=nil;zombie.stableId=nil
Engine.onReplicated(zombie,'test')
assert(detached==1 and durability==1 and appearance==1)
assert(Engine.findTrackedByStableId('clear-lifecycle')==nil)
Engine.onReplicated(zombie,nil)
assert(detached==1,'repeated untyped reconciliation must not detach twice')
print('Clear detaches the prior lifecycle and restores supported profiles')
