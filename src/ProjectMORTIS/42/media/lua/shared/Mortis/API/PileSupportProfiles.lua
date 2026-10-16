local Adapter = require "Mortis/Runtime/Adapters/PileSupportAdapter"

local Profiles = { MAX_PROFILES=64 }
local entries, count = {}, 0

local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, entry in pairs(value) do
        if key ~= "object" then result[key] = copy(entry) end
    end
    return result
end

local function bounded(value, fallback, minimum, maximum)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge or value == -math.huge then value = fallback end
    return math.max(minimum, math.min(maximum, value))
end

local function normalize(id, value, facts)
    if type(value) ~= "table" or value.supported ~= true then return nil end
    return {
        profileId=id,
        kind=type(value.kind) == "string" and value.kind or "static-object",
        height=bounded(value.height, facts.surfaceHeight or 0, 0, 8),
        stability=bounded(value.stability, 0.5, 0, 1),
        footprintArea=bounded(value.footprintArea, 1, 0.05, 16),
        loadCapacity=bounded(value.loadCapacity, 0, 0, 100000),
        source=facts.source,
        evidence=type(value.evidence) == "string" and value.evidence or nil,
    }
end

function Profiles.register(definition)
    if type(definition) ~= "table" then error("pile support profile must be a table", 2) end
    local id = definition.id
    if type(id) ~= "string" or id == "" then error("pile support profile requires id", 2) end
    if entries[id] then error("pile support profile already registered: " .. id, 2) end
    if count >= Profiles.MAX_PROFILES then error("pile support profile limit reached", 2) end
    if type(definition.classify) ~= "function" then error("pile support profile requires classify(facts, context)", 2) end
    entries[id] = { id=id, priority=tonumber(definition.priority) or 0, classify=definition.classify }
    count = count + 1
    return true
end

function Profiles.has(id) return entries[id] ~= nil end

local function sorted()
    local result = {}
    for _, entry in pairs(entries) do result[#result+1] = entry end
    table.sort(result, function(a,b) return a.priority == b.priority and a.id < b.id or a.priority > b.priority end)
    return result
end

function Profiles.classify(object, context)
    local ok, facts = Adapter.observe(object)
    if not ok then return false, facts end
    for _, entry in ipairs(sorted()) do
        local callbackOk, value = pcall(entry.classify, facts, context or {})
        if callbackOk then
            local result = normalize(entry.id, value, facts)
            if result then return true, result end
        end
    end
    return false, "no verified support profile"
end

function Profiles.describe(object)
    local ok, facts = Adapter.observe(object)
    return ok and copy(facts) or nil, ok and nil or facts
end

function Profiles.all()
    local result = {}
    for _, entry in ipairs(sorted()) do result[#result+1] = { id=entry.id, priority=entry.priority } end
    return result
end

return Profiles
