local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local Components = { registry = Registry.new("component schema") }

local validPersistence = {
    none = true,
    session = true,
    save = true,
    saveAndReplicate = true,
}

local validReplication = {
    none = true,
    serverToClients = true,
}

local function normalize(definition)
    if type(definition) ~= "table" then error("component definition must be a table", 3) end
    local result = Util.deepCopy(definition)
    result.id = Util.assertString(result.id, "component id")
    result.version = math.max(1, math.floor(tonumber(result.version) or 1))
    result.persistence = result.persistence or "none"
    result.replication = result.replication or (result.persistence == "saveAndReplicate" and "serverToClients" or "none")
    result.defaults = result.defaults or {}
    result.migrations = result.migrations or {}

    if not validPersistence[result.persistence] then
        error("invalid component persistence mode: " .. tostring(result.persistence), 3)
    end
    if not validReplication[result.replication] then
        error("invalid component replication mode: " .. tostring(result.replication), 3)
    end
    if result.serialize ~= nil and type(result.serialize) ~= "function" then error("component serialize must be a function", 3) end
    if result.deserialize ~= nil and type(result.deserialize) ~= "function" then error("component deserialize must be a function", 3) end
    for version, migration in pairs(result.migrations) do
        if type(version) ~= "number" or type(migration) ~= "function" then
            error("component migrations must be numeric-version => function", 3)
        end
    end
    return result
end

function Components.register(definition)
    local normalized = normalize(definition)
    return Components.registry:register(normalized.id, normalized)
end

function Components.get(id) return Components.registry:get(id) end
function Components.has(id) return Components.registry:has(id) end
function Components.all() return Components.registry:all() end

function Components.isPersistent(id)
    local schema = Components.get(id)
    return schema ~= nil and (schema.persistence == "save" or schema.persistence == "saveAndReplicate")
end

function Components.isReplicated(id)
    local schema = Components.get(id)
    return schema ~= nil and schema.replication == "serverToClients"
end

return Components
