unpack=unpack or table.unpack
local species={id="Test.Humanoid",version=1,regions={
    arm={integrity=80,tissueCapacity=8,severable=true},hand={integrity=40,tissueCapacity=1,severable=true,parent="arm"},
}}
package.loaded["Mortis/API/Species"]={get=function(id) return id==species.id and species end,
    has=function(id) return id==species.id end,
    resolveRegion=function(_,id) return species.regions[id] and id end}
package.loaded["Mortis/API/EntityResolvers"]={resolve=function() return species.id end}
package.loaded["Mortis/Runtime/Identity"]={ensureStableId=function() return "zombie-1" end,
    getStableId=function() return "zombie-1" end,getTypeId=function() return "Test.Feral" end}
local Anatomy=require "Mortis/Runtime/AnatomyRuntime"
local Detached=require "Mortis/API/DetachedParts"
local Util=require "Mortis/Core/Util"
local function entity(data,corpse)
    return {getModData=function() return data end,
        getObjectName=function() return corpse and "DeadBody" or "Zombie" end,
        isZombie=function() return true end} -- Native corpses can report isZombie.
end
local data={}
local live=entity(data,false)
assert(Anatomy.attach(live,species.id))
assert(Anatomy.sever(live,"hand"))
assert(Detached.snapshotDeath(live))
local saved=Util.deepCopy(data)
local corpse=entity(saved,true)
assert(Detached.capture(corpse,"arm").sourceTypeId=="Test.Feral")
assert(Detached.capture(corpse,"arm").tissue.remaining==8)
assert(Anatomy.consumeTissue(corpse,"arm",4,{transactionId="postmortem:1",expectedRemaining=8}))
local recovered=assert(Detached.capture(corpse,"arm"))
assert(recovered.tissue.capacity==8 and recovered.tissue.remaining==4,
    "recovery must sample postmortem tissue, not frozen death quantity")
assert(recovered.subtree.rootRegionId=="arm" and recovered.subtree.regions.arm
    and not recovered.subtree.regions.hand,"already-missing descendants must stay missing")
assert(saved[Detached.DEATH_KEY].regions.arm.tissue.remaining==8,"death evidence stays frozen")
local itemData={};local item={getModData=function() return itemData end}
assert(Detached.write(item,recovered))
recovered.tissue.remaining=8
assert(Detached.read(item).tissue.remaining==4,"part item owns a copy of recovery-time tissue")
local unknownData=Util.deepCopy(saved)
unknownData.MORTIS_LIVING.anatomy.schemaVersion=1
unknownData.MORTIS_LIVING.anatomy.regions.arm.material=nil
unknownData.MORTIS_LIVING.anatomy.regions.arm.remainingTissue=nil
assert(not Detached.capture(entity(unknownData,true),"arm"),
    "unknown current material must fail closed instead of falling back to intact death evidence")
assert(not Anatomy.getRegion(corpse,"hand").attached)
assert(not Anatomy.sever(corpse,"hand"),"missing limb must not be harvested twice")
local detached=assert(Anatomy.sever(corpse,"arm"))
assert(detached.subtree.totals.remaining==4 and Anatomy.getRegion(corpse,"arm").material==nil)
local reloaded=entity(Util.deepCopy(saved),true)
assert(not Anatomy.getRegion(reloaded,"arm").attached,"sever survives a new object/load")
assert(not Anatomy.getRegion(reloaded,"hand").attached)

local function rejected(modify)
    local damaged=Util.deepCopy(data)
    modify(damaged)
    local unknown=entity(damaged,true)
    assert(not Anatomy.get(unknown),"invalid corpse anatomy must fail closed")
    assert(not Detached.capture(unknown,"arm"))
    assert(not Anatomy.attach(unknown,species.id),"explicit attach must not fabricate corpse limbs")
end
rejected(function(d) d.MORTIS_LIVING=nil end)
rejected(function(d) d.MORTIS_LIVING="invalid" end)
rejected(function(d) d.MORTIS_LIVING.anatomy="invalid" end)
rejected(function(d) d.MORTIS_LIVING.anatomy.regions.hand=nil end)
rejected(function(d) d.MORTIS_LIVING.anatomy.regions.hand.attached=nil end)
rejected(function(d) d.MORTIS_LIVING.anatomy.schemaVersion=999 end)
rejected(function(d) d.MORTIS_LIVING.anatomy.speciesVersion=999 end)
assert(not Anatomy.get(entity({},true)),"unknown native corpse must not use living resolver")
print("M.O.R.T.I.S. corpse anatomy preserves harvested limbs and rejects missing state")
