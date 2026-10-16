local Species=require "Mortis/API/Species"
Species.register{id="Test.Tissue",defaultRegion="torso",regions={
    torso={integrity=10,tissueCapacity=8},hand={integrity=100,tissueCapacity=1,severable=true,parent="torso"}}}
for _,value in ipairs({0,-1,math.huge,0/0,"bad"}) do
    assert(not pcall(Species.register,{id="Invalid",defaultRegion="part",regions={part={tissueCapacity=value}}}))
end
package.loaded["Mortis/API/EntityResolvers"]={resolve=function() return "Test.Tissue" end}
local Anatomy=require "Mortis/Runtime/AnatomyRuntime"
local Util=require "Mortis/Core/Util"
local function entity(data,corpse)
    return {getModData=function() return data end,getObjectName=function() return corpse and "DeadBody" or "Zombie" end}
end
local data={};local live=entity(data)
local state=assert(Anatomy.attach(live,"Test.Tissue"))
local view=assert(Anatomy.tissueSnapshot(live))
assert(view.capacity==9 and view.remaining==9 and view.regions.torso.weight==8)
assert(Anatomy.applyMaterialLoss(live,"torso",{transactionId="setup:loss",expectedRevision=0,
    remainingLoss=6,viableLoss=6,edibleLoss=6,mechanism="test"}))
state.regions.torso.integrity=0;state.regions.torso.destroyed=true
assert(Anatomy.flush(live))
local corpse=entity(Util.deepCopy(data),true)
view=assert(Anatomy.tissueSnapshot(corpse))
assert(view.remaining==3 and view.capacity==9,"structural destruction does not erase soft tissue")
view.regions.torso.remaining=0
assert(Anatomy.getRegion(corpse,"torso").remainingTissue==2)
assert(Anatomy.sever(corpse,"hand"))
view=assert(Anatomy.tissueSnapshot(corpse))
assert(view.remaining==2 and view.capacity==8 and not view.regions.hand.attached)
for _,isCorpse in ipairs({false,true}) do
    local legacy=Util.deepCopy(data)
    legacy.MORTIS_LIVING.anatomy.schemaVersion=1
    legacy.MORTIS_LIVING.anatomy.regions.torso.material=nil
    legacy.MORTIS_LIVING.anatomy.regions.torso.remainingTissue=nil
    local loaded=entity(legacy,isCorpse)
    assert(Anatomy.get(loaded))
    assert(not Anatomy.tissueSnapshot(loaded),"unknown tissue must not refill from species defaults")
    assert(Anatomy.getRegion(loaded,"torso").remainingTissue==nil)
end
local depleted=Util.deepCopy(data)
depleted.MORTIS_LIVING.anatomy.schemaVersion=1
depleted.MORTIS_LIVING.anatomy.regions.torso.material=nil
depleted.MORTIS_LIVING.anatomy.regions.torso.remainingTissue=0
assert(Anatomy.tissueSnapshot(entity(depleted,true)).regions.torso.remaining==0)
local request={transactionId="UV:1",expectedRemaining=2}
local consumed=assert(Anatomy.consumeTissue(corpse,"torso",.5,request))
assert(consumed.before==2 and consumed.after==1.5)
assert(Anatomy.consumeTissue(corpse,"torso",.5,request).replayed)
local corpseReload=entity(Util.deepCopy(corpse:getModData()),true)
assert(Anatomy.consumeTissue(corpseReload,"torso",.5,request).replayed,"retry must survive reload")
assert(not Anatomy.consumeTissue(corpseReload,"torso",.6,request),"same ID cannot change amount")
assert(Anatomy.consumeTissue(corpseReload,"torso",.5,{transactionId="UV:2",expectedRemaining=1.5}))
assert(not Anatomy.consumeTissue(corpseReload,"torso",.5,request),"superseded replay must fail stale, not consume twice")
assert(Anatomy.getRegion(corpseReload,"torso").remainingTissue==1)
assert(not Anatomy.consumeTissue(corpseReload,"hand",.1,{transactionId="UV:3",expectedRemaining=1}))
local savedRoot=corpseReload:getModData().MORTIS_LIVING
corpseReload:getModData().MORTIS_LIVING="failed storage"
assert(not Anatomy.consumeTissue(corpseReload,"torso",.5,{transactionId="UV:3",expectedRemaining=1}))
assert(Anatomy.getRegion(corpseReload,"torso").remainingTissue==1,"failed persistence rolls back tissue")
assert(Anatomy.getRegion(corpseReload,"torso").lastTissueLoss.id=="UV:2")
corpseReload:getModData().MORTIS_LIVING=savedRoot
isClient=function() return true end
assert(not Anatomy.consumeTissue(corpseReload,"torso",.5,{transactionId="UV:3",expectedRemaining=1}))
isClient=function() return false end
assert(Anatomy.consumeTissue(corpseReload,"torso",1,{transactionId="UV:3",expectedRemaining=1}))
assert(Anatomy.getRegion(corpseReload,"torso").remainingTissue==0)
local profileEntity=entity({})
assert(Anatomy.attach(profileEntity,"Test.Tissue"))
local profiled=assert(Anatomy.applyNutritionProfile(profileEntity,"Test.LowNutrition",.25))
assert(profiled.multiplier==.25)
local profileView=assert(Anatomy.materialSnapshot(profileEntity,"torso"))
assert(profileView.nutrition.calories==0,"unspecified species nutrition remains zero")
local revision=profileView.revision
assert(Anatomy.applyNutritionProfile(profileEntity,"Test.LowNutrition",.25).replayed)
assert(Anatomy.materialSnapshot(profileEntity,"torso").revision==revision,"profile replay must not compound")
assert(not Anatomy.applyNutritionProfile(profileEntity,"bad",-1))
local profileMaterial=assert(Anatomy.materialSnapshot(profileEntity,"torso"))
local withdrawn,withdrawReceipt=assert(Anatomy.withdrawMaterial(profileEntity,"torso",1,
    {transactionId="harvest:attached",expectedRevision=profileMaterial.revision}))
assert(withdrawn.remaining==1 and withdrawReceipt.regionId=="torso")
local afterWithdraw=assert(Anatomy.materialSnapshot(profileEntity,"torso"))
assert(afterWithdraw.remaining==7)
assert(Anatomy.applyMaterialGain(profileEntity,"torso",{transactionId="regenerate:attached",
    expectedRevision=afterWithdraw.revision,remainingGain=1,viableGain=1,edibleGain=1,mechanism="regeneration"}))
assert(Anatomy.materialSnapshot(profileEntity,"torso").remaining==8)
local registeredResolver
package.loaded["Mortis/init"]={Species=Species,registerSpecies=Species.register,
    TraumaChannels={has=function() return true end},
    EntityResolvers={registry={has=function() return false end}},
    Entity={kind=function(e) return e.kind end},
    registerEntityResolver=function(def) registeredResolver=def end}
require "Mortis/Definitions/CoreAnatomy"
assert(registeredResolver.matches({kind="infected"}))
assert(registeredResolver.resolveSpecies()=="Mortis.Humanoid")
local humanoid=entity({})
assert(Anatomy.attach(humanoid,"Mortis.Humanoid"))
local body=assert(Anatomy.tissueSnapshot(humanoid))
assert(body.capacity==100 and body.remaining==100)
assert(body.regions.torso.weight>body.regions.leftHand.weight)
assert(body.regions.leftArm.weight==body.regions.rightArm.weight)
local severed=assert(Anatomy.sever(humanoid,"leftArm"))
assert(severed.subtree.rootRegionId=="leftArm" and severed.subtree.regions.leftArm
    and severed.subtree.regions.leftHand and severed.subtree.totals.remaining==6.5)
assert(Anatomy.getRegion(humanoid,"leftArm").material==nil
    and Anatomy.getRegion(humanoid,"leftHand").material==nil,"source must relinquish detached material")
assert(Anatomy.tissueSnapshot(humanoid).capacity==93.5,"arm and child hand quantities are not double-counted")
print("MORTIS canonical tissue capacity, persistence, corpse and missing-part checks passed")
