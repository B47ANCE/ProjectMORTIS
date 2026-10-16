local Tissue=require "Mortis/Runtime/TissueModel"
local Model=require "Mortis/Runtime/DetachedMaterialModel"
local function material(amount) return assert(Tissue.new(amount,{nutritionDensity={calories=10,proteins=1}})) end
local record={schemaVersion=1,regionId="arm",metadata={},subtree={schemaVersion=1,rootRegionId="arm",regions={
    arm={regionId="arm",material=material(5)},hand={regionId="hand",parent="arm",material=material(2)},
    finger={regionId="finger",parent="hand",material=material(1)}}}}
assert(Model.validate(record))
local source,hand,receipt=assert(Model.divide(record,"hand","divide:1"))
assert(receipt.regionId=="hand" and source.subtree.totals.remaining==5 and hand.subtree.totals.remaining==3)
assert(not source.subtree.regions.hand and hand.subtree.regions.hand and hand.subtree.regions.finger)
assert(source.subtree.totals.remaining+hand.subtree.totals.remaining==8)
assert(not Model.divide(record,"arm","divide:root"))

local eaten,withdrawn=assert(Model.withdraw(hand,"hand",1,{transactionId="eat:1",expectedRevision=0}))
assert(eaten.subtree.totals.remaining==2 and withdrawn.remaining==1)
assert(eaten.subtree.totals.nutrition.calories+assert(Tissue.snapshot(withdrawn)).nutrition.calories
    ==hand.subtree.totals.nutrition.calories)
local decayed=assert(Model.applyLoss(eaten,"finger",{transactionId="decay:1",expectedRevision=0,
    viableLoss=.25,edibleLoss=.5,mechanism="decomposition"}))
assert(decayed.subtree.totals.remaining==2 and decayed.subtree.totals.edible==1.5)
local regenerated=assert(Model.applyGain(decayed,"finger",{transactionId="regen:1",expectedRevision=1,
    viableGain=.25,edibleGain=.5,mechanism="regeneration"}))
assert(regenerated.subtree.totals.remaining==2 and regenerated.subtree.totals.edible==2)
assert(record.subtree.totals==nil and record.subtree.regions.hand.material.remaining==2,
    "pure detached transitions must not mutate their input")
print("M.O.R.T.I.S. detached subtree division and material conservation checks passed")
