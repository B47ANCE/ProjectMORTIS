local Authority = require "Mortis/Runtime/Authority"
local Identity = require "Mortis/Runtime/Identity"
local Components = require "Mortis/Runtime/Components"

local GroupAdapter = {}
local groups = {}
local entityGroup = setmetatable({}, { __mode = "k" })
local snapshot
local sequence = 0
local COMPONENT = "Mortis.LogicalGroupMembership"

local function emit(name, ...)
    local mortis = rawget(_G, "Mortis")
    if mortis and mortis.Events and type(mortis.Events.emit) == "function" then
        pcall(mortis.Events.emit, mortis.Events, name, ...)
    end
end

local function authoritative(entity)
    return Authority.canWriteCanonicalState(entity)
end

local function requireOwner(owner)
    if type(owner) ~= "string" or owner == "" then
        return nil, "logical group owner must be a non-empty string"
    end
    return owner
end

local function requireEntity(entity)
    if entity == nil then return nil, "logical group entity is required" end
    return entity
end

local function stableId(entity)
    return Identity.getStableId(entity) or Identity.ensureStableId(entity)
end

local function resolve(groupOrId)
    if type(groupOrId) == "table" then return groups[groupOrId.id] end
    return groups[groupOrId]
end

local function membership(entity)
    local value=entity and Components.get(entity,COMPONENT) or nil
    return type(value)=="table" and value or nil
end

local function persistMember(group,entity,role)
    if not group or not entity then return end
    Components.set(entity,COMPONENT,{groupId=group.id,owner=group.owner,role=role,
        leaderStableId=group.leader and Identity.getStableId(group.leader) or nil})
end

local function persistGroup(group)
    if not group then return end
    local leaderId=group.leader and Identity.getStableId(group.leader) or nil
    for entity,role in pairs(group.members) do
        Components.set(entity,COMPONENT,{groupId=group.id,owner=group.owner,role=role,leaderStableId=leaderId})
    end
end

function GroupAdapter.restore(entity)
    if not entity then return nil,"logical group entity is required" end
    local current=entityGroup[entity]
    if current and groups[current] then return snapshot(groups[current]) end
    local value=membership(entity)
    if not value or type(value.groupId)~="string" or value.groupId=="" or type(value.owner)~="string" or value.owner=="" then return nil end
    local group=groups[value.groupId]
    if not group then
        group={id=value.groupId,owner=value.owner,leader=nil,members=setmetatable({},{__mode="k"}),metadata=nil}
        groups[value.groupId]=group
    elseif group.owner~=value.owner then
        return nil,"persisted logical group owner mismatch"
    end
    local role=value.role=="leader" and "leader" or value.role=="co-leader" and "co-leader" or "member"
    group.members[entity]=role;entityGroup[entity]=group.id
    local id=Identity.getStableId(entity)
    if role=="leader" or (type(value.leaderStableId)=="string" and value.leaderStableId==id) then
        if not group.leader then group.leader=entity;group.members[entity]="leader" end
    end
    emit("LogicalGroupRestored",snapshot(group),entity)
    return snapshot(group)
end

snapshot = function(group)
    if not group then return nil end
    local members = {}
    for entity, role in pairs(group.members) do
        members[#members + 1] = {
            entity = entity,
            stableId = Identity.getStableId(entity),
            role = role,
        }
    end
    table.sort(members, function(a, b)
        return tostring(a.stableId or a.entity) < tostring(b.stableId or b.entity)
    end)
    return {
        id = group.id,
        owner = group.owner,
        leader = group.leader,
        members = members,
        size = #members,
        metadata = group.metadata,
    }
end

local function removeMember(group, entity)
    if not group or group.members[entity] == nil then return false end
    group.members[entity] = nil
    if entityGroup[entity] == group.id then entityGroup[entity] = nil end
    if group.leader == entity then group.leader = nil end
    Components.remove(entity,COMPONENT)
    return true
end

function GroupAdapter.create(owner, leader, options)
    local validOwner, ownerErr = requireOwner(owner)
    if not validOwner then return nil, ownerErr end
    local validLeader, leaderErr = requireEntity(leader)
    if not validLeader then return nil, leaderErr end
    if not authoritative(leader) then return nil, "logical group creation requires server authority" end
    if entityGroup[leader] then return nil, "logical group leader already belongs to a group" end

    sequence = sequence + 1
    local leaderId = stableId(leader)
    local id = string.format("%s:%s:%06d", validOwner, tostring(leaderId), sequence % 1000000)
    local group = {
        id = id,
        owner = validOwner,
        leader = leader,
        members = setmetatable({}, { __mode = "k" }),
        metadata = type(options) == "table" and options.metadata or nil,
    }
    group.members[leader] = "leader"
    groups[id] = group
    entityGroup[leader] = id
    persistMember(group,leader,"leader")
    emit("LogicalGroupCreated", snapshot(group))
    return snapshot(group)
end

function GroupAdapter.get(groupOrId)
    return snapshot(resolve(groupOrId))
end

function GroupAdapter.getFor(entity)
    if entity and not entityGroup[entity] then GroupAdapter.restore(entity) end
    return snapshot(groups[entityGroup[entity]])
end

function GroupAdapter.getIdFor(entity)
    if entity and not entityGroup[entity] then GroupAdapter.restore(entity) end
    return entityGroup[entity]
end

function GroupAdapter.isMember(groupOrId, entity)
    if entity and not entityGroup[entity] then GroupAdapter.restore(entity) end
    local group = resolve(groupOrId)
    return group ~= nil and group.members[entity] ~= nil
end

function GroupAdapter.count(groupOrId, role)
    local group = resolve(groupOrId)
    if not group then return 0 end
    local count = 0
    for _, memberRole in pairs(group.members) do
        if role == nil or role == memberRole then count = count + 1 end
    end
    return count
end

function GroupAdapter.join(groupOrId, entity, role)
    local group = resolve(groupOrId)
    if not group then return nil, "logical group does not exist" end
    if not requireEntity(entity) then return nil, "logical group entity is required" end
    if not authoritative(entity) then return nil, "logical group membership requires server authority" end
    local currentId = entityGroup[entity]
    if currentId and currentId ~= group.id then return nil, "entity already belongs to another logical group" end
    if currentId == group.id then return snapshot(group) end
    stableId(entity)
    group.members[entity] = role == "co-leader" and "co-leader" or "member"
    entityGroup[entity] = group.id
    persistMember(group,entity,group.members[entity])
    emit("LogicalGroupJoined", snapshot(group), entity)
    return snapshot(group)
end

function GroupAdapter.leave(entity)
    local id = entityGroup[entity]
    local group = groups[id]
    if not group then return false end
    if not authoritative(entity) then return false, "logical group membership requires server authority" end
    local wasLeader = group.leader == entity
    removeMember(group, entity)
    if wasLeader then
        local preferred, fallback = {}, {}
        for candidate, role in pairs(group.members) do
            local target = role == "co-leader" and preferred or fallback
            target[#target + 1] = candidate
        end
        local function byStableId(a, b) return tostring(Identity.getStableId(a) or a) < tostring(Identity.getStableId(b) or b) end
        table.sort(preferred, byStableId)
        table.sort(fallback, byStableId)
        local replacement = preferred[1] or fallback[1]
        if replacement then
            group.leader = replacement
            group.members[replacement] = "leader"
            persistGroup(group)
        else
            groups[group.id] = nil
        end
    end
    emit("LogicalGroupLeft", id, entity, snapshot(group))
    return true
end

function GroupAdapter.merge(primaryOrId, secondaryOrId)
    local primary, secondary = resolve(primaryOrId), resolve(secondaryOrId)
    if not primary or not secondary then return nil, "both logical groups must exist" end
    if primary.id == secondary.id then return snapshot(primary) end
    if primary.owner ~= secondary.owner then return nil, "logical groups with different owners cannot merge" end
    if not authoritative(primary.leader) then return nil, "logical group merge requires server authority" end
    for entity, role in pairs(secondary.members) do
        primary.members[entity] = role == "leader" and "co-leader" or role
        entityGroup[entity] = primary.id
    end
    groups[secondary.id] = nil
    persistGroup(primary)
    emit("LogicalGroupsMerged", snapshot(primary), secondary.id)
    return snapshot(primary)
end

function GroupAdapter.disband(groupOrId)
    local group = resolve(groupOrId)
    if not group then return false end
    if not authoritative(group.leader) then return false, "logical group disband requires server authority" end
    for entity in pairs(group.members) do entityGroup[entity] = nil;Components.remove(entity,COMPONENT) end
    groups[group.id] = nil
    emit("LogicalGroupDisbanded", group.id, group.owner)
    return true
end

function GroupAdapter.prune(groupOrId, predicate)
    local group = resolve(groupOrId)
    if not group then return nil, "logical group does not exist" end
    if type(predicate) ~= "function" then return nil, "logical group prune predicate is required" end
    local stale = {}
    local leader
    for entity in pairs(group.members) do
        local ok, keep = pcall(predicate, entity)
        if not ok or not keep then
            if entity == group.leader then leader = entity else stale[#stale + 1] = entity end
        end
    end
    if leader then stale[#stale + 1] = leader end
    for _, entity in ipairs(stale) do GroupAdapter.leave(entity) end
    return GroupAdapter.get(group.id), #stale
end

-- Host-test hook and hot-reload recovery helper. Persistent components remain
-- on entities and are reconstructed lazily by getFor/getIdFor.
function GroupAdapter.resetRuntimeIndex()
    groups={};entityGroup=setmetatable({},{__mode="k"});sequence=0
    return true
end

-- Vanilla rally groups remain deliberately separate. Consumers own their
-- logical behavior through this adapter instead of mutating ZombieGroup internals.
function GroupAdapter.getVanillaGroup(_zombie)
    return nil, "vanilla zombie group access is intentionally unsupported"
end

GroupAdapter.COMPONENT=COMPONENT

return GroupAdapter
