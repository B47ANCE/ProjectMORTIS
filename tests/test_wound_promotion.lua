local species={id="Test.Species",version=1,defaultRegion="head",regions={
    head={integrity=100,critical=true,disableThreshold=10},arm={integrity=100}}}
package.loaded["Mortis/API/Species"]={get=function() return species end,has=function() return true end,
    resolveRegion=function(_,id) return species.regions[id] and id end}
package.loaded["Mortis/API/EntityResolvers"]={resolve=function() return species.id end}
local data={}
package.loaded["Mortis/Runtime/Adapters/EntityAdapter"]={getModData=function() return data end,transmitModData=function() end}
local authority=true
package.loaded["Mortis/Runtime/Authority"]={canWriteCanonicalState=function() return authority end}
package.loaded["Mortis/API/TraumaChannels"]={get=function(id)
    if id=="burn" then return {structuralMultiplier=.25,bleedMultiplier=0} end
end}
local events={}
local Anatomy=require "Mortis/Runtime/AnatomyRuntime"
package.loaded["Mortis/Runtime/AnatomyConsequenceRuntime"]={dispatch=function(name,entity,result)
    assert(data.MORTIS_LIVING.anatomy.regions[result.region].integrity==result.integrityAfter,
        "consequences must observe already persisted anatomy")
    events[name]=(events[name] or 0)+1
end}
local Trauma=require "Mortis/Runtime/TraumaRuntime"
local entity={}
local function promote(stage,magnitude)
    return Trauma.promote(entity,{region="head",woundId="Test.UVBurn",stage=stage,magnitude=magnitude,channel="burn"})
end
assert(promote(1,40))
assert(Anatomy.get(entity).regions.head.integrity==90)
assert(promote(1,40))
assert(events.onTrauma==1,"replaying a wound stage must not apply injury twice")
Anatomy.detach(entity)
assert(Anatomy.get(entity).regions.head.wounds["Test.UVBurn"].stage==1)
assert(promote(1,40) and events.onTrauma==1,"reload must preserve replay protection")
assert(promote(2,80))
assert(Anatomy.get(entity).regions.head.integrity==80,"promotions apply only cumulative delta")
assert(Anatomy.get(entity).regions.arm.integrity==100,"trauma is localized")
assert(Trauma.promote(entity,{region="arm",woundId="Test.Repair",stage=2,magnitude=40,channel="burn"}))
assert(Anatomy.get(entity).regions.arm.integrity==90)
local repairRequest={region="arm",woundId="Test.Repair",stage=2,magnitude=4,channel="burn",
    transactionId="repair-recovery-test"}
local repairData=data
data=nil
assert(not Trauma.repair(entity,repairRequest))
assert(Anatomy.get(entity).regions.arm.integrity==90)
assert(Anatomy.get(entity).metadata.lastRepairTransactionId==nil,
    "failed repair must not retain a successful replay marker")
data=repairData
assert(Trauma.repair(entity,repairRequest))
assert(Anatomy.get(entity).regions.arm.integrity==91)
Anatomy.detach(entity)
local retryOk,retryResult=Trauma.repair(entity,repairRequest)
assert(retryOk and retryResult.replayed and Anatomy.get(entity).regions.arm.integrity==91,
    "save/reload must retain repair replay protection")
local repaired,result=Trauma.repair(entity,{region="arm",woundId="Test.Repair",stage=1,magnitude=20,channel="burn"})
assert(repaired and result.repaired==20 and result.remaining==16)
assert(Anatomy.get(entity).regions.arm.integrity==96
    and Anatomy.get(entity).regions.arm.wounds["Test.Repair"].stage==1)
assert(not Trauma.repair(entity,{region="arm",woundId="Test.Repair",stage=0,magnitude=1,
    channel="burn",transactionId="invalid-zero-stage"}),"partial repair cannot create an unsaveable stage-zero wound")
assert(Anatomy.get(entity).regions.arm.integrity==96
    and Anatomy.get(entity).regions.arm.wounds["Test.Repair"].magnitude==16)
assert(Anatomy.get(entity).metadata.lastRepairTransactionId~="invalid-zero-stage")
Anatomy.detach(entity)
assert(Anatomy.get(entity).regions.arm.wounds["Test.Repair"].magnitude==16,
    "rejected stage-zero repair must preserve the wound through reload")
assert(Trauma.repair(entity,{region="arm",woundId="Test.Repair",magnitude=100,channel="burn"}))
assert(Anatomy.get(entity).regions.arm.integrity==100
    and Anatomy.get(entity).regions.arm.wounds["Test.Repair"]==nil)
assert(Trauma.repair(entity,{region="arm",woundId="Test.Repair",magnitude=1,channel="burn"}))
assert(not promote(3,60))
authority=false
assert(not promote(3,120))
authority=true
local saved=data
local traumaBeforeFailure=events.onTrauma
data=nil
assert(not promote(3,400))
local region=Anatomy.get(entity).regions.head
assert(region.integrity==80 and region.wounds["Test.UVBurn"].stage==2)
assert(not region.destroyed and not region.disabled and not events.onCriticalDestroyed)
assert(events.onTrauma==traumaBeforeFailure,"failed persistence must not publish effects")
data=saved
assert(promote(3,400))
assert(events.onCriticalDestroyed==1 and Anatomy.get(entity).regions.head.destroyed)
assert(promote(3,400) and events.onCriticalDestroyed==1)
assert(not promote(4,math.huge))
assert(not promote(4,0/0))
assert(not Trauma.apply(entity,{region="arm",channel="burn",magnitude=math.huge}))
assert(not Trauma.apply(entity,{region="arm",channel="burn",magnitude=0/0}))
print("MORTIS localized wound promotion, persistence, rollback and authority checks passed")
