next=nil -- Match the supported Kahlua surface; use pairs rather than next.
local function list(values) return {size=function() return #values end,get=function(_,i) return values[i+1] end} end
local names={"UpperArm_L","ForeArm_L","UpperArm_R","ForeArm_R","Head"}
local mappings={UpperArm_L="leftArm",ForeArm_L="leftArm",UpperArm_R="rightArm",ForeArm_R="rightArm",Head="head"}
package.loaded["Mortis/API/Species"]={get=function() return {} end,resolveRegion=function(_,name) return mappings[name] end}
BloodBodyPartType={MAX={index=function() return #names end},FromIndex=function(i) return names[i+1] end}
BloodClothingType={getCoveredParts=function(types) return list(types) end}
local Coverage=require "Mortis/Runtime/ClothingCoverage"
local function garment(id,covered,holes)
    return {getItemType=function() return id end,getScriptItem=function()
        return {getBloodClothingType=function() return covered end,getFabricType=function() return "Test.Fabric" end}
    end,getHole=function(_,part) return (holes or {})[part] or 0 end}
end
local sleeves={"UpperArm_L","ForeArm_L","UpperArm_R","ForeArm_R"}
local holes={ForeArm_L=1}
local visuals={garment("Test.Jacket",sleeves,holes),garment("Test.Shirt",sleeves)}
local zombie={getItemVisuals=function() return list(visuals) end}
local snapshot=assert(Coverage.snapshot(zombie,"Test.Humanoid"))
local access=assert(Coverage.region(zombie,"Test.Humanoid","ForeArm_L"))
assert(access.region=="leftArm" and access.covered and #access.layers==2)
assert(access.layers[1].parts.ForeArm_L.hole==1,
    "a torn garment remains anatomical clothing, not automatic procedure access")
assert(not Coverage.region(zombie,"Test.Humanoid","Head").covered)
assert(not Coverage.region(zombie,"Test.Humanoid","unknown"))
mappings.UnmappedRegion="tail"
local unmapped,unmappedReason=Coverage.region(zombie,"Test.Humanoid","UnmappedRegion")
assert(unmapped==nil and unmappedReason=="anatomical region has no native clothing mapping",
    "a known canonical region without native parts is unknown access, not uncovered skin")
local resolve=function(id,part,fabric)
    assert(fabric=="Test.Fabric","native fabric facts must reach consumer policy")
    return id=="Test.Jacket" and .1 or .5
end
local value=assert(Coverage.transmission(snapshot,resolve))
assert(math.abs(value.parts.UpperArm_L-.05)<1e-9)
assert(value.parts.ForeArm_L==.5,"underlying shirt still protects the torn sleeve")
assert(math.abs(value.regions.leftArm-.275)<1e-9)
assert(math.abs(value.regions.rightArm-.05)<1e-9,"one sleeve hole must not expose the other arm")
assert(value.regions.head==1,"uncovered regions receive full exposure")
holes.ForeArm_L=0
local repaired=assert(Coverage.snapshot(zombie,"Test.Humanoid"))
assert(Coverage.transmission(repaired,resolve).regions.leftArm==.05)
assert(snapshot.layers[1].parts.ForeArm_L.hole==1,"snapshots must not alias native mutable data")
visuals={}
assert(Coverage.transmission(Coverage.snapshot(zombie,"Test.Humanoid"),resolve).regions.head==1)
visuals={{getScriptItem=function() error("bad mod") end}}
assert(not Coverage.snapshot(zombie,"Test.Humanoid"))
zombie.getItemVisuals=function() return {size=function() return 100000 end} end
assert(not Coverage.snapshot(zombie,"Test.Humanoid"),"over-budget scans must reject, not truncate coverage")
assert(not Coverage.transmission(snapshot,function() return nil end))
assert(not Coverage.transmission(snapshot,function() return 0/0 end))
assert(not Coverage.transmission(snapshot,resolve,{Head=math.huge}))
print("MORTIS clothing snapshot, layered transmission, local holes and bounds checks passed")
