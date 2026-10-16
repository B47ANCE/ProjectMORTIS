package.loaded["Mortis/Runtime/Authority"] = { canWriteCanonicalState = function() return true end }
local schemas = {}
package.loaded["Mortis/API/Components"] = {
    isPersistent=function() return true end, isReplicated=function() return false end,
    get=function(id) return schemas[id] end,
}
local ids, sequence = setmetatable({}, {__mode="k"}), 0
package.loaded["Mortis/Runtime/Identity"] = {
    getStableId=function(e) return ids[e] end,
    ensureStableId=function(e) sequence=sequence+1; ids[e]=ids[e] or ("Z"..sequence); return ids[e] end,
}
local Hierarchy = require "Mortis/Runtime/CommandHierarchy"
local alpha, smart = {}, {}
assert(Hierarchy.assign(alpha, smart, "commander"))
local relationship = assert(Hierarchy.get(smart))
assert(relationship.superiorId == ids[alpha] and relationship.role == "commander")
assert(Hierarchy.setObjective(smart, "destroy-rival-alpha", {x=10,y=20,z=0}, 12.5,"Z9"))
assert(Hierarchy.get(smart).objective.point.x == 10)
assert(Hierarchy.isCommittedRival(smart,"Z9"))
assert(Hierarchy.setMemory(smart,"assignedFollowers",12))
assert(Hierarchy.getMemory(smart,"assignedFollowers")==12)
assert(Hierarchy.setMemory(smart,"shelterConfirmed",false))
assert(Hierarchy.getMemory(smart,"shelterConfirmed")==false,"negative observations must not become unknown")
assert(Hierarchy.getMemory(smart,"absentObservation")==nil)
local Components=require "Mortis/Runtime/Components"
schemas["Test.Boolean"]={defaults=true}
assert(Components.get(smart,"Test.Boolean")==true)
Components.set(smart,"Test.Boolean",false)
assert(Components.get(smart,"Test.Boolean")==false,"stored false must not be replaced by schema defaults")
Components.remove(smart,"Test.Boolean")
assert(Components.get(smart,"Test.Boolean")==true,"absent components still initialize their defaults")
assert(Hierarchy.desert(smart,ids[alpha],15))
assert(Hierarchy.desertedFrom(smart,ids[alpha]) and Hierarchy.get(smart).superiorId==nil)
assert(Hierarchy.clearFormerSuperior(smart,ids[alpha]))
assert(not Hierarchy.desertedFrom(smart,ids[alpha]))
assert(Hierarchy.assign(alpha,smart,"commander"))
assert(not Hierarchy.clear(smart, "wrong"))
assert(Hierarchy.clear(smart, ids[alpha]))
assert(Hierarchy.get(smart) == nil)
print("M.O.R.T.I.S. command hierarchy tests passed")
