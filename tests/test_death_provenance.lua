unpack=unpack or table.unpack -- PZ Lua compatibility in the host runtime.
next=nil -- Build 42 Kahlua release compatibility.
local sourceData={}
local source={getModData=function() return sourceData end,getObjectName=function() return "Player" end,
    isPlayer=function() return true end}
local identity="original-zombie"
local sourceType="Test.Feral"
local captures=0
local regions={leftArm={attached=true},leftHand={attached=false}}
package.loaded["Mortis/Runtime/AnatomyRuntime"]={
    get=function() return {speciesId="Test.Humanoid",speciesVersion=1,regions=regions} end,
    getRegion=function(_,id) return regions[id],{severable=true},id end,
    flush=function() sourceData.anatomyFlushed=true; return true end,
}
package.loaded["Mortis/Runtime/Identity"]={getStableId=function() return identity end,
    ensureStableId=function() return identity end,getTypeId=function() return sourceType end}
local API=require "Mortis/API/DetachedParts"
API.registerClassifier{id="Test.Class",classify=function() captures=captures+1; return sourceType end}
local record=assert(API.snapshotDeath(source))
assert(sourceData.anatomyFlushed and captures==2)
assert(API.snapshotPlayerDeath(source),"player-specific death capture must use the same frozen provenance")
assert(not API.snapshotPlayerDeath({isPlayer=function()return false end}),"non-player character deaths must fail closed")
assert(record.regions.leftArm.classifications["Test.Class"]=="Test.Feral")
identity=nil; sourceType=nil
assert(API.snapshotDeath(source) and captures==2,"duplicate callback must preserve frozen identity")
-- Simulate IsoDeadBody's native LuaManager.copyTable rather than sharing the
-- source table by reference. This catches accidental reliance on the removed
-- living object after the engine constructs its corpse.
local function copy(value)
    if type(value)~="table" then return value end
    local result={}
    for key,item in pairs(value) do result[copy(key)]=copy(item) end
    return result
end
local corpseData=copy(sourceData)
local corpse={getModData=function() return corpseData end,getObjectName=function() return "DeadBody" end}
sourceData[API.DEATH_KEY].regions.leftArm.sourceTypeId="source-mutated-after-copy"
local part=assert(API.capture(corpse,"leftArm",{procedureId="test"}))
assert(part.sourceStableId=="original-zombie" and part.sourceTypeId=="Test.Feral")
assert(part.metadata.sourceLifecycle=="corpse" and captures==2)
part.classifications["Test.Class"]="tampered"
assert(API.capture(corpse,"leftArm").classifications["Test.Class"]=="Test.Feral")
local unknown={getObjectName=corpse.getObjectName,getModData=function() return {} end}
assert(not API.capture(unknown,"leftArm"))
isClient=function() return true end
assert(not API.snapshotDeath(source))
isClient=function() return false end
identity="reanimated-zombie"; sourceType="Test.SmartFeral"
assert(API.snapshotDeath(source).regions.leftArm.sourceTypeId=="Test.SmartFeral")
assert(captures==4,"a new live identity must refresh death classification")
local valid=sourceData[API.DEATH_KEY]
sourceData[API.DEATH_KEY]={schemaVersion=1}
identity=nil
assert(not API.snapshotDeath(source),"malformed duplicate snapshots must fail closed")
assert(sourceData[API.DEATH_KEY].regions==nil,"unknown stored state must not be replaced")
sourceData[API.DEATH_KEY]=valid
print("M.O.R.T.I.S. frozen death/corpse provenance checks passed")
