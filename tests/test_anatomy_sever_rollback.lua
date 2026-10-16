local species={id="Test.Species",version=1,regions={
    arm={integrity=80,tissueCapacity=8,severable=true},
    hand={integrity=40,tissueCapacity=1,severable=true,parent="arm"},
}}
package.loaded["Mortis/API/Species"]={get=function(id) return id==species.id and species end,
    has=function(id) return id==species.id end,resolveRegion=function(_,id) return species.regions[id] and id end}
package.loaded["Mortis/API/EntityResolvers"]={resolve=function() return species.id end}
local data={}
package.loaded["Mortis/Runtime/Adapters/EntityAdapter"]={getModData=function() return data end,transmitModData=function() end}
local authority=true
package.loaded["Mortis/Runtime/Authority"]={canWriteCanonicalState=function() return authority end}
local Anatomy=require "Mortis/Runtime/AnatomyRuntime"
local entity={}
local state=assert(Anatomy.attach(entity,species.id,{persist=false}))
state.regions.arm.disabled=true
state.regions.hand.disabled=false
state.regions.arm.trauma={cut=2}
data=nil
assert(not Anatomy.sever(entity,"arm"))
assert(state.regions.arm.attached and state.regions.arm.disabled)
assert(state.regions.hand.attached and not state.regions.hand.disabled)
assert(state.regions.arm.trauma.cut==2)
data={MORTIS_LIVING="invalid"}
assert(not Anatomy.sever(entity,"arm"))
assert(data.MORTIS_LIVING=="invalid" and state.regions.arm.disabled and state.regions.hand.attached)
data={}
authority=false
assert(not Anatomy.sever(entity,"arm"))
assert(state.regions.hand.attached)
authority=true
local result=assert(Anatomy.sever(entity,"arm"))
assert(#result.detachedRegions==2 and not state.regions.arm.attached and not state.regions.hand.attached)
assert(data.MORTIS_LIVING.anatomy.regions.hand.disabled)
assert(not Anatomy.sever(entity,"arm"))
print("M.O.R.T.I.S. sever rollback preserves prior disability and descendants")
