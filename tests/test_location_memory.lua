package.loaded["Mortis/Runtime/Authority"]={canWriteCanonicalState=function()return true end}
local schemas={}
package.loaded["Mortis/API/Components"]={isPersistent=function()return true end,isReplicated=function()return false end,
    get=function(_,id)return schemas[id]end}
local Memory=require "Mortis/Runtime/LocationMemory"
local alpha={}
assert(Memory.observe(alpha,"player-sighting",{x=10,y=10,z=0},1,1,{mergeRadius=8,maxRecords=2}))
assert(Memory.observe(alpha,"barricade",{x=12,y=11,z=0},2,2,{mergeRadius=8,maxRecords=2}))
local best=assert(Memory.best(alpha,3,{worldAgeHours=2,maxAgeHours=24}))
assert(best.score==3 and best.observations==2 and best.evidence.barricade==2)
assert(Memory.get(alpha,best.key,{worldAgeHours=2,maxAgeHours=24})==best)
Memory.observe(alpha,"noise",{x=100,y=100,z=0},1,3,{mergeRadius=8,maxRecords=2})
Memory.observe(alpha,"combat",{x=200,y=200,z=0},1,4,{mergeRadius=8,maxRecords=2})
assert(#Memory.list(alpha,{worldAgeHours=4,maxAgeHours=24})==2,"record cap must evict oldest location")
assert(not Memory.best(alpha,1,{worldAgeHours=100,maxAgeHours=24}),"expired evidence must not remain actionable")
print("M.O.R.T.I.S. bounded persistent location-memory checks passed")
