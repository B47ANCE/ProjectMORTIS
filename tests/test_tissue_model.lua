local Tissue=require "Mortis/Runtime/TissueModel"

local original=assert(Tissue.new(10,{remaining=8,viable=6,edible=4,
    nutritionDensity={calories=20,proteins=2,lipids=1,carbohydrates=.5}}))
local view=assert(Tissue.snapshot(original))
assert(view.remainingFraction==.8 and view.viableFraction==.6 and view.edibleFraction==.4)
assert(view.nutrition.calories==80 and view.nutrition.proteins==8)

local degraded,receipt=assert(Tissue.applyLoss(original,{transactionId="decay:1",expectedRevision=0,
    viableLoss=1,edibleLoss=2,mechanism="decomposition"}))
assert(degraded.remaining==8 and degraded.viable==5 and degraded.edible==2 and degraded.revision==1)
local replay,replayReceipt=assert(Tissue.applyLoss(degraded,{transactionId="decay:1",expectedRevision=0,
    viableLoss=1,edibleLoss=2,mechanism="decomposition"}))
assert(replay.remaining==8 and replayReceipt.replayed==true)
assert(not Tissue.applyLoss(degraded,{transactionId="decay:1",expectedRevision=0,viableLoss=2,edibleLoss=2}))
assert(not Tissue.applyLoss(degraded,{transactionId="damage:stale",expectedRevision=0,remainingLoss=1,viableLoss=1,edibleLoss=1}))
assert(not Tissue.applyLoss(degraded,{transactionId="invalid:hierarchy",expectedRevision=1,remainingLoss=7}))

local restored,gainReceipt=assert(Tissue.applyGain(degraded,{transactionId="heal:1",expectedRevision=1,
    viableGain=1,edibleGain=1,mechanism="regeneration"}))
assert(restored.remaining==8 and restored.viable==6 and restored.edible==3 and restored.revision==2)
assert(gainReceipt.kind=="gain" and gainReceipt.mechanism=="regeneration")
local restoredReplay,restoredReplayReceipt=assert(Tissue.applyGain(restored,{transactionId="heal:1",
    expectedRevision=1,viableGain=1,edibleGain=1,mechanism="regeneration"}))
assert(restoredReplay.edible==3 and restoredReplayReceipt.replayed)
assert(not Tissue.applyGain(restored,{transactionId="heal:1",expectedRevision=1,viableGain=2,edibleGain=1}))
assert(not Tissue.applyGain(restored,{transactionId="heal:overflow",expectedRevision=2,remainingGain=3}))

local source,part,withdrawReceipt=assert(Tissue.withdraw(degraded,2,{transactionId="harvest:1",expectedRevision=1}))
assert(source.remaining+part.remaining==degraded.remaining)
assert(source.viable+part.viable==degraded.viable)
assert(source.edible+part.edible==degraded.edible)
assert(withdrawReceipt.mechanism=="withdrawal")
local combinedCalories=assert(Tissue.snapshot(source)).nutrition.calories+assert(Tissue.snapshot(part)).nutrition.calories
assert(combinedCalories==assert(Tissue.snapshot(degraded)).nutrition.calories)

for _,bad in ipairs({
    {schemaVersion=1,capacity=10,remaining=11,viable=1,edible=1,revision=0,nutritionDensity={}},
    {schemaVersion=1,capacity=10,remaining=8,viable=9,edible=1,revision=0,nutritionDensity={}},
    {schemaVersion=1,capacity=10,remaining=8,viable=7,edible=8,revision=0,nutritionDensity={}},
}) do assert(not Tissue.validate(bad)) end

print("M.O.R.T.I.S. tissue conservation model checks passed")
