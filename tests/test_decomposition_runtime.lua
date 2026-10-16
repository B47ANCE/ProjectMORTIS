local Tissue = require "Mortis/Runtime/TissueModel"
local DetachedModel = require "Mortis/Runtime/DetachedMaterialModel"

local records = setmetatable({}, { __mode="k" })
package.loaded["Mortis/Runtime/Authority"] = { canWriteCanonicalState=function() return true end }
package.loaded["Mortis/API/DetachedParts"] = {
    applyMaterialLoss=function(item,region,request)
        local nextRecord, receipt = DetachedModel.applyLoss(records[item],region,request)
        if not nextRecord then return nil,receipt end
        records[item]=nextRecord
        return receipt
    end,
}
package.loaded["Mortis/API/BiologicalMaterial"] = nil
package.loaded["Mortis/API/DecompositionPolicies"] = nil
package.loaded["Mortis/Runtime/DecompositionRuntime"] = nil

local Policies = require "Mortis/API/DecompositionPolicies"
local Runtime = require "Mortis/Runtime/DecompositionRuntime"
local function material(amount) return assert(Tissue.new(amount,{nutritionDensity={calories=10}})) end
local function detached(amount)
    local item={}
    records[item]={schemaVersion=1,regionId="arm",metadata={},subtree={schemaVersion=1,
        rootRegionId="arm",regions={arm={regionId="arm",material=material(amount)}}}}
    return item
end

Policies.register({id="Test.rot",intervalHours=2,maxCatchupHours=4,maxOperations=2,
    plan=function(_,context)
        assert(context.elapsedHours<=4 and context.actualElapsedHours>=context.elapsedHours)
        return {{regionId="arm",expectedRevision=context.sequence,viableLoss=1,edibleLoss=1}}
    end})

local first,second=detached(5),detached(5)
assert(Runtime.track(first,{kind="detached",policyId="Test.rot",lastWorldAgeHours=10}))
assert(Runtime.track(second,{kind="detached",policyId="Test.rot",lastWorldAgeHours=10}))
assert(not Runtime.track({}, {kind="detached",policyId="missing",lastWorldAgeHours=10}))

local early=assert(Runtime.processBatch(11,1,1))
assert(early.processed==0 and early.deferred==1)
local one=assert(Runtime.processBatch(12,1,1))
assert(one.processed==1 and records[second].subtree.regions.arm.material.edible==4,
    "fair cursor must process the next due tracked item")
local two=assert(Runtime.processBatch(12,1,2))
assert(two.processed==1 and records[first].subtree.regions.arm.material.edible==4)
local state=assert(Runtime.inspect(first))
assert(state.lastWorldAgeHours==12 and state.sequence==1)

local none=assert(Runtime.processBatch(12,2,2))
assert(none.processed==0 and none.deferred==2,"same world age must not double-apply")
local later=assert(Runtime.processBatch(20,2,2))
assert(later.processed==2 and records[first].subtree.regions.arm.material.edible==3)
assert(Runtime.untrack(first) and not Runtime.inspect(first))
local report=Runtime.getDiagnostics();report.processed=0
assert(Runtime.getDiagnostics().processed==4,"diagnostics must be protected")
print("M.O.R.T.I.S. bounded explicit decomposition scheduling checks passed")
