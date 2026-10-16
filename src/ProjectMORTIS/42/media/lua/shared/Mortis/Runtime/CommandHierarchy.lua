local Authority = require "Mortis/Runtime/Authority"
local Components = require "Mortis/Runtime/Components"
local Identity = require "Mortis/Runtime/Identity"

-- Reusable, persistent command relationships. This deliberately sits above
-- logical groups: a subordinate leader may retain ownership of its own group.
local Hierarchy = {}
local COMPONENT = "Mortis.CommandHierarchy"

local function finite(v)
    v = tonumber(v)
    return v and v == v and v ~= math.huge and v ~= -math.huge and v or nil
end

local function copyPoint(point)
    if type(point) ~= "table" then return nil end
    local x, y, z = finite(point.x), finite(point.y), finite(point.z) or 0
    if not x or not y then return nil end
    return { x = x, y = y, z = z }
end

local function state(entity)
    local value = Components.get(entity, COMPONENT)
    if type(value) ~= "table" then value = {} end
    return value
end

function Hierarchy.assign(superior, subordinate, role)
    if not superior or not subordinate or superior == subordinate then return false, "invalid hierarchy relationship" end
    if not Authority.canWriteCanonicalState(subordinate) then return false, "command hierarchy requires server authority" end
    local superiorId = Identity.getStableId(superior) or Identity.ensureStableId(superior)
    local subordinateId = Identity.getStableId(subordinate) or Identity.ensureStableId(subordinate)
    local value = state(subordinate)
    value.superiorId = superiorId
    value.subordinateId = subordinateId
    value.role = type(role) == "string" and role:sub(1, 64) or "subordinate"
    Components.set(subordinate, COMPONENT, value)
    return true, value
end

function Hierarchy.clear(subordinate, expectedSuperiorId)
    if not subordinate then return false, "missing subordinate" end
    if not Authority.canWriteCanonicalState(subordinate) then return false, "command hierarchy requires server authority" end
    local value = state(subordinate)
    if expectedSuperiorId and value.superiorId ~= expectedSuperiorId then return false, "superior mismatch" end
    Components.remove(subordinate, COMPONENT)
    return true
end

function Hierarchy.canDesert(subordinate, expectedSuperiorId)
    if not subordinate then return false,"missing subordinate" end
    if not Authority.canWriteCanonicalState(subordinate) then return false,"command hierarchy requires server authority" end
    local value=state(subordinate)
    if not value.superiorId or (expectedSuperiorId and value.superiorId~=expectedSuperiorId) then
        return false,"superior mismatch"
    end
    return true
end

-- Breaks current command without erasing the personal relationship. Consumers
-- decide the gameplay meaning of desertion/retribution; M.O.R.T.I.S. owns the
-- durable identity link only.
function Hierarchy.desert(subordinate, expectedSuperiorId, worldAgeHours)
    local allowed,reason=Hierarchy.canDesert(subordinate,expectedSuperiorId)
    if not allowed then return false,reason end
    local value=state(subordinate)
    value.formerSuperiorId=value.superiorId
    value.desertedWorldAgeHours=finite(worldAgeHours)
    value.superiorId=nil;value.role="independent-deserter";value.objective=nil
    Components.set(subordinate,COMPONENT,value)
    return true,value
end

function Hierarchy.clearFormerSuperior(subordinate,expectedSuperiorId)
    if not subordinate or not Authority.canWriteCanonicalState(subordinate) then return false,"command hierarchy requires server authority" end
    local value=state(subordinate)
    if expectedSuperiorId and value.formerSuperiorId~=expectedSuperiorId then return false,"former superior mismatch" end
    value.formerSuperiorId=nil;value.desertedWorldAgeHours=nil
    if value.role=="independent-deserter" then value.role=nil end
    Components.set(subordinate,COMPONENT,value)
    return true
end

function Hierarchy.desertedFrom(subordinate,superiorId)
    local value=state(subordinate)
    return type(superiorId)=="string" and value.formerSuperiorId==superiorId
end

function Hierarchy.get(entity)
    local value = state(entity)
    if not value.superiorId and not value.formerSuperiorId and not value.objective then return nil end
    return value
end

function Hierarchy.setObjective(entity, kind, point, observedWorldAgeHours, targetStableId)
    if not entity or not Authority.canWriteCanonicalState(entity) then return false, "command objective requires server authority" end
    if type(kind) ~= "string" or kind == "" then return false, "objective kind is required" end
    local location = copyPoint(point)
    if not location then return false, "objective point is invalid" end
    local value = state(entity)
    value.objective = {
        kind = kind:sub(1, 64), point = location,
        observedWorldAgeHours = finite(observedWorldAgeHours),
        targetStableId = type(targetStableId)=="string" and targetStableId:sub(1,128) or nil,
    }
    Components.set(entity, COMPONENT, value)
    return true, value.objective
end

function Hierarchy.isCommittedRival(entity,stableId)
    local value=Hierarchy.get(entity)
    local objective=value and value.objective
    return objective and objective.kind=="destroy-rival-alpha" and objective.targetStableId==stableId or false
end

function Hierarchy.clearObjective(entity)
    if not entity or not Authority.canWriteCanonicalState(entity) then return false, "command objective requires server authority" end
    local value = state(entity)
    value.objective = nil
    Components.set(entity, COMPONENT, value)
    return true
end

function Hierarchy.setMemory(entity,key,value)
    if not entity or not Authority.canWriteCanonicalState(entity) then return false,"command memory requires server authority" end
    if type(key)~="string" or key=="" or #key>64 then return false,"invalid command-memory key" end
    local kind=type(value)
    if value~=nil and kind~="string" and kind~="number" and kind~="boolean" then return false,"command-memory value must be scalar" end
    if kind=="number" and not finite(value) then return false,"command-memory number must be finite" end
    local stateValue=state(entity);stateValue.memory=type(stateValue.memory)=="table" and stateValue.memory or {}
    stateValue.memory[key]=value
    Components.set(entity,COMPONENT,stateValue)
    return true
end

function Hierarchy.getMemory(entity,key)
    local value=state(entity)
    if type(value.memory)=="table" then return value.memory[key] end
    return nil
end

Hierarchy.COMPONENT = COMPONENT
return Hierarchy
