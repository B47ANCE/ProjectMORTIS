next=nil -- Build 42 Kahlua release compatibility.
local function deepCopy(value, seen)
    if type(value) ~= "table" then return value end
    seen = seen or {}; if seen[value] then return seen[value] end
    local result = {}; seen[value] = result
    for key, child in pairs(value) do result[deepCopy(key, seen)] = deepCopy(child, seen) end
    return result
end

local anatomy = {speciesId="Test.Humanoid",regions={
    leftHand={attached=true,disabled=false,destroyed=false},
    rightHand={attached=false,disabled=false,destroyed=false},
    leftLeg={attached=true,disabled=true,destroyed=false},
}}
local species = {regions={
    leftHand={capabilityModifiers={grip=.5,manipulation=.25}},
    rightHand={capabilityModifiers={grip=.5,manipulation=.25}},
    leftLeg={capabilityModifiers={locomotion=.5}},
}}
local attachmentState = {mounts={
    ["rightHand\31distal"]={attachmentId="Test.Prosthetic",regionId="rightHand",socketId="distal"},
}}
local definitions = { ["Test.Prosthetic"]={id="Test.Prosthetic",capabilityModifiers={grip=.2,manipulation=.15}} }
local mocks = {
    ["Mortis/Core/Util"]={deepCopy=deepCopy},
    ["Mortis/API/Species"]={get=function(id) return id=="Test.Humanoid" and deepCopy(species) or nil end},
    ["Mortis/Runtime/AnatomyRuntime"]={get=function() return deepCopy(anatomy) end},
    ["Mortis/API/AnatomyAttachments"]={
        snapshot=function() return deepCopy(attachmentState) end,
        get=function(id) return definitions[id] and deepCopy(definitions[id]) or nil end,
    },
}
local realRequire=require
require=function(name) return mocks[name] or realRequire(name) end
local Capabilities=dofile(arg[1])

local snapshot=assert(Capabilities.snapshot({}))
assert(snapshot.total.grip==.7 and snapshot.total.manipulation==.4,
    "active natural anatomy and installed attachments must add deterministically")
assert(snapshot.total.locomotion==nil,"disabled natural regions must not contribute")
assert(snapshot.natural.rightHand==nil,"missing natural anatomy must not contribute")
assert(snapshot.attachments["rightHand\31distal"].attachmentId=="Test.Prosthetic",
    "attachment provenance must remain inspectable")
local grip, view=Capabilities.get({},"grip")
assert(grip==.7 and view.total.grip==.7,"single-capability queries must return the aggregate and snapshot")
assert(Capabilities.get({},"unknown")==0,"unknown entity capabilities must resolve to zero")
assert(Capabilities.get({},"")==nil,"empty capability ids must fail closed")

print("MORTIS anatomy capability aggregation checks passed")

for _,region in pairs(species.regions) do region.integrity=100 end
for _,region in pairs(anatomy.regions) do region.integrity=100 end
anatomy.regions.leftHand.integrity=50
local functional=assert(Capabilities.functionalSnapshot({}))
assert(functional.total.grip==.45,"half-integrity hand contribution plus prosthetic must compose")
assert(functional.regionFunction.leftHand==.5 and functional.regionFunction.leftLeg==0)
assert(functional.baseline.grip==1,"baseline is intact natural anatomy, not current function")
assert(Capabilities.snapshot({}).total.grip==.7,"legacy binary capability API must remain unchanged")
species.regions.leftHand.critical=true
anatomy.regions.leftHand.destroyed=true
functional=assert(Capabilities.functionalSnapshot({}))
assert(functional.total.grip==.2 and functional.criticalDestroyed[1]=="leftHand")
anatomy.regions.leftHand.integrity=0/0
assert(not Capabilities.functionalSnapshot({}),"invalid trauma state must not poison capability math")
print("MORTIS opt-in progressive anatomical impairment checks passed")
anatomy.regions.leftHand.integrity=100;anatomy.regions.leftHand.destroyed=false
species.regions.leftArm={integrity=100}
anatomy.regions.leftArm={integrity=25,attached=true}
species.regions.leftHand.parent="leftArm"
functional=assert(Capabilities.functionalSnapshot({}))
assert(functional.regionFunction.leftHand==.25,"hand function must be limited by its supporting arm")
anatomy.regions.leftArm.disabled=true
functional=assert(Capabilities.functionalSnapshot({}))
assert(functional.regionFunction.leftHand==0 and functional.total.grip==.2)
species.regions.rightHand.parent="leftArm" -- Synthetic mount to exercise generic support mapping.
functional=assert(Capabilities.functionalSnapshot({}))
assert(functional.total.grip==0,"prosthetic output cannot bypass disabled supporting anatomy")
assert(Capabilities.snapshot({}).total.grip==.7,"legacy binary API remains unchanged")
species.regions.leftArm.parent="leftHand"
assert(not Capabilities.functionalSnapshot({}),"support cycles must fail within the traversal budget")
