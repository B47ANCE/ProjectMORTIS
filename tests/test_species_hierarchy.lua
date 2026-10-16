local Species=require "Mortis/API/Species"
local function rejected(id,regions)
    local ok=pcall(Species.register,{id=id,defaultRegion="root",regions=regions})
    assert(not ok and not Species.has(id),"invalid hierarchy must never reach registry: "..id)
end
rejected("Test.SelfCycle",{root={parent="root"}})
rejected("Test.TwoCycle",{root={parent="child"},child={parent="root"}})
rejected("Test.MissingParent",{root={parent="missing"}})
local chain={root={}}
local previous="root"
for index=1,Species.MAX_PARENT_DEPTH do
    local id="part"..index
    chain[id]={parent=previous};previous=id
end
assert(Species.register{id="Test.MaximumDepth",defaultRegion="root",regions=chain})
chain.tooDeep={parent=previous}
rejected("Test.ExcessDepth",chain)
assert(Species.register{id="Test.Branches",defaultRegion="root",regions={
    root={},left={parent="root"},right={parent="root"},hand={parent="left"}}})
assert(Species.get("Test.Branches").regions.hand.parent=="left")
for index,value in ipairs({0,-1,math.huge,-math.huge,0/0,"invalid"}) do
    rejected("Test.BadIntegrity"..index,{root={integrity=value}})
end
for index,value in ipairs({-1,math.huge,0/0,"invalid"}) do
    rejected("Test.BadDisable"..index,{root={disableThreshold=value}})
    rejected("Test.BadDestroy"..index,{root={destroyThreshold=value}})
end
assert(Species.register{id="Test.NumericText",defaultRegion="root",regions={root={integrity="50"}}})
assert(Species.get("Test.NumericText").regions.root.integrity==50)
assert(Species.get("Test.Branches").regions.root.integrity==100,"omitted integrity keeps the documented default")
print("MORTIS species hierarchy cycle, depth and pre-registration validation passed")
