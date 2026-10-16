local Util = require "Mortis/Core/Util"
local Schemas = require "Mortis/API/Components"

-- Runtime component state. Weak keys prevent this table from keeping removed
-- IsoZombie instances alive. Persistent component schemas are serialized by
-- Mortis/Runtime/Persistence; this table remains the live working set.
local Components = {
    state = setmetatable({}, { __mode = "k" }),
    dirty = setmetatable({}, { __mode = "k" }),
    replicationDirty = setmetatable({}, { __mode = "k" }),
}

local function bucketFor(zombie, create)
    if zombie == nil then error("zombie is required", 3) end
    local bucket = Components.state[zombie]
    if not bucket and create then
        bucket = {}
        Components.state[zombie] = bucket
    end
    return bucket
end

local function markDirty(zombie, componentId)
    if Schemas.isPersistent(componentId) then Components.dirty[zombie] = true end
    if Schemas.isReplicated(componentId) then Components.replicationDirty[zombie] = true end
end

function Components.set(zombie, componentId, value)
    Util.assertString(componentId, "componentId")
    bucketFor(zombie, true)[componentId] = value
    markDirty(zombie, componentId)
    return value
end

-- Used by the persistence layer to restore state without immediately marking
-- the restored value dirty again.
function Components.setRestored(zombie, componentId, value)
    Util.assertString(componentId, "componentId")
    bucketFor(zombie, true)[componentId] = value
    return value
end

-- Applied from the authoritative server. Does not mark the value dirty for
-- persistence or trigger a replication echo back to the server.
function Components.setReplicated(zombie, componentId, value)
    Util.assertString(componentId, "componentId")
    bucketFor(zombie, true)[componentId] = value
    return value
end

-- Authoritative replication can also remove a component. This intentionally
-- avoids marking persistence/replication dirty on the receiving client.
function Components.removeReplicated(zombie, componentId)
    Util.assertString(componentId, "componentId")
    local bucket = bucketFor(zombie, false)
    if bucket then bucket[componentId] = nil end
end

function Components.get(zombie, componentId)
    Util.assertString(componentId, "componentId")
    local bucket = bucketFor(zombie, false)
    local value
    if bucket then value=bucket[componentId] end
    if value == nil then
        local schema = Schemas.get(componentId)
        if schema and schema.defaults ~= nil then
            value = Util.deepCopy(schema.defaults)
            bucketFor(zombie, true)[componentId] = value
        end
    end
    return value
end

function Components.remove(zombie, componentId)
    local bucket = bucketFor(zombie, false)
    if bucket then bucket[componentId] = nil end
    markDirty(zombie, componentId)
end

function Components.allFor(zombie)
    return bucketFor(zombie, false)
end

function Components.isDirty(zombie)
    return Components.dirty[zombie] == true
end

function Components.markClean(zombie)
    Components.dirty[zombie] = nil
end

function Components.isReplicationDirty(zombie)
    return Components.replicationDirty[zombie] == true
end

function Components.markReplicationClean(zombie)
    Components.replicationDirty[zombie] = nil
end

function Components.clear(zombie)
    Components.state[zombie] = nil
    Components.dirty[zombie] = nil
    Components.replicationDirty[zombie] = nil
end

return Components
