local anatomy={
    get=function() return {speciesId="Mortis.Humanoid",speciesVersion=1} end,
    getRegion=function() return {attached=true},{severable=true},"leftArm" end,
}
local identity={ensureStableId=function() return "entity-7" end,getTypeId=function() return "Test.Feral" end}
package.loaded["Mortis/Runtime/AnatomyRuntime"]=anatomy
package.loaded["Mortis/Runtime/Identity"]=identity
local api=dofile(arg[1])
api.registerClassifier({id="Test.signature",classify=function(_,record)
    assert(record.sourceTypeId=="Test.Feral")
    return {signature="feral"}
end})
local record=assert(api.capture({},"leftArm",{test=true}))
assert(record.schemaVersion==1 and record.regionId=="leftArm")
assert(record.classifications["Test.signature"].signature=="feral")
local data={}
local item={getModData=function() return data end}
assert(api.write(item,record))
local restored=assert(api.read(item))
assert(restored.sourceStableId=="entity-7" and restored.metadata.test==true)
restored.regionId="mutated"
assert(api.read(item).regionId=="leftArm","reads must not expose canonical item data")
local Tissue=require "Mortis/Runtime/TissueModel"
record.subtree={schemaVersion=1,rootRegionId="leftArm",regions={
    leftArm={regionId="leftArm",material=assert(Tissue.new(4,{nutritionDensity={calories=5}}))}}}
assert(api.write(item,record))
local loss=assert(api.applyMaterialLoss(item,"leftArm",{transactionId="decay:item",expectedRevision=0,
    viableLoss=1,edibleLoss=1,mechanism="decomposition"}))
assert(loss.regionId=="leftArm" and api.read(item).subtree.totals.remaining==4)
local food,feeding=assert(api.withdrawMaterial(item,"leftArm",1,
    {transactionId="feed:item",expectedRevision=1,mechanism="feeding"}))
assert(food.remaining==1 and feeding.mechanism=="feeding")
local gain=assert(api.applyMaterialGain(item,"leftArm",{transactionId="regen:item",expectedRevision=2,
    remainingGain=1,viableGain=1,edibleGain=1,mechanism="regeneration"}))
assert(gain.kind=="gain" and api.read(item).subtree.totals.remaining==4)
print("M.O.R.T.I.S. detached-part provenance checks passed")
