package.loaded["Mortis/Runtime/Authority"] = {
    canWriteCanonicalState = function() return true end,
}

local ids = setmetatable({}, { __mode = "k" })
local nextId = 0
package.loaded["Mortis/Runtime/Identity"] = {
    getStableId = function(entity) return ids[entity] end,
    ensureStableId = function(entity)
        if not ids[entity] then nextId = nextId + 1; ids[entity] = "Z" .. nextId end
        return ids[entity]
    end,
}

local Groups = require "Mortis/Runtime/Adapters/GroupAdapter"
local smartA, smartB, feralA, feralB = {}, {}, {}, {}

local first = assert(Groups.create("ProjectNightfall", smartA))
assert(first.size == 1 and first.leader == smartA)
assert(Groups.join(first.id, feralA))
assert(Groups.count(first.id) == 2)
assert(Groups.count(first.id, "member") == 1)
assert(Groups.getIdFor(feralA) == first.id)

-- Membership survives a lost runtime index and reconstructs incrementally as
-- streamed entities are observed again.
Groups.resetRuntimeIndex()
local restoredLeader=assert(Groups.getFor(smartA))
assert(restoredLeader.id==first.id and restoredLeader.leader==smartA and restoredLeader.size==1)
local restoredFollower=assert(Groups.getFor(feralA))
assert(restoredFollower.id==first.id and restoredFollower.size==2)

local second = assert(Groups.create("ProjectNightfall", smartB))
assert(Groups.join(second.id, feralB))
local merged = assert(Groups.merge(first.id, second.id))
assert(merged.size == 4)
assert(Groups.count(first.id, "co-leader") == 1)
assert(Groups.get(second.id) == nil)
assert(Groups.getIdFor(smartB) == first.id)

assert(Groups.leave(smartA))
local afterLeader = assert(Groups.get(first.id))
assert(afterLeader.leader == smartB)
assert(Groups.count(first.id, "leader") == 1)

local pruned, removed = Groups.prune(first.id, function(entity) return entity ~= feralA end)
assert(removed == 1 and pruned.size == 2)
assert(Groups.getIdFor(feralA) == nil)
assert(Groups.disband(first.id))
assert(Groups.getIdFor(smartB) == nil and Groups.getIdFor(feralB) == nil)

print("M.O.R.T.I.S. logical group tests passed")
