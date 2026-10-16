local Authority = require "Mortis/Runtime/Authority"
local Material = require "Mortis/API/BiologicalMaterial"
local Policies = require "Mortis/API/DecompositionPolicies"

local Runtime = {}
local tracked = setmetatable({}, { __mode = "k" })
local order = setmetatable({}, { __mode = "v" })
local slots = setmetatable({}, { __mode = "k" })
local highWater, cursor = 0, 0
local diagnostics = { tracked=0, considered=0, processed=0, deferred=0, failed=0, operations=0 }

local function finite(value)
    value = tonumber(value)
    if value and value == value and value > -math.huge and value < math.huge then return value end
end

local function isServerAuthority(target, kind)
    if kind == "entity" then return Authority.canWriteCanonicalState(target) end
    local client = rawget(_G, "isClient")
    if type(client) == "function" then
        local ok, value = pcall(client)
        if ok and value == true then return false end
    end
    return true
end

function Runtime.track(target, definition)
    if target == nil then return nil, "decomposition target required" end
    if type(definition) ~= "table" then return nil, "decomposition tracking definition required" end
    local policy = Policies.get(definition.policyId)
    if not policy then return nil, "unknown decomposition policy" end
    local kind = definition.kind
    if kind ~= "entity" and kind ~= "detached" then return nil, "kind must be entity or detached" end
    local last = finite(definition.lastWorldAgeHours)
    if not last or last < 0 then return nil, "lastWorldAgeHours must be a non-negative finite number" end
    local sequence = math.max(0, math.floor(finite(definition.sequence) or 0))
    local existing = tracked[target]
    if existing then
        existing.policyId, existing.kind = policy.id, kind
        existing.lastWorldAgeHours, existing.sequence = last, sequence
        return true
    end
    highWater = highWater + 1
    order[highWater], slots[target] = target, highWater
    tracked[target] = { policyId=policy.id, kind=kind, lastWorldAgeHours=last, sequence=sequence }
    diagnostics.tracked = diagnostics.tracked + 1
    return true
end

function Runtime.untrack(target)
    local record = tracked[target]
    if not record then return false end
    tracked[target] = nil
    local slot = slots[target]
    if slot then order[slot] = nil; slots[target] = nil end
    diagnostics.tracked = math.max(0, diagnostics.tracked - 1)
    return true
end

function Runtime.inspect(target)
    local value = tracked[target]
    if not value then return nil end
    return { policyId=value.policyId, kind=value.kind,
        lastWorldAgeHours=value.lastWorldAgeHours, sequence=value.sequence }
end

local function apply(target, record, operation, operationId)
    if type(operation) ~= "table" or type(operation.regionId) ~= "string" then
        return nil, "policy returned invalid operation"
    end
    local request = {}
    for key, value in pairs(operation) do if key ~= "regionId" then request[key] = value end end
    request.transactionId = request.transactionId or operationId
    if record.kind == "entity" then
        return Material.decomposeEntity(target, operation.regionId, request, operation.options)
    end
    return Material.decomposeDetached(target, operation.regionId, request)
end

local function processOne(target, record, now)
    local policy = Policies.get(record.policyId)
    if not policy then return nil, "tracked policy is no longer registered" end
    local elapsed = now - record.lastWorldAgeHours
    if elapsed < 0 then return nil, "world age moved backwards" end
    if elapsed < policy.intervalHours then return false, "not due" end
    if not isServerAuthority(target, record.kind) then return nil, "server authority required" end
    local boundedElapsed = math.min(elapsed, policy.maxCatchupHours)
    local ok, operations = pcall(policy.plan, target, {
        kind=record.kind, elapsedHours=boundedElapsed, actualElapsedHours=elapsed,
        nowWorldAgeHours=now, sequence=record.sequence,
    })
    if not ok then return nil, "decomposition policy failed: " .. tostring(operations) end
    if operations == nil then operations = {} end
    if type(operations) ~= "table" then return nil, "decomposition policy must return an operation list" end
    if #operations > policy.maxOperations then return nil, "decomposition policy operation limit exceeded" end
    for index, operation in ipairs(operations) do
        local operationId = "Mortis.Decomposition:" .. policy.id .. ":" .. record.sequence .. ":" .. index
        local committed, err = apply(target, record, operation, operationId)
        if not committed then return nil, err end
        diagnostics.operations = diagnostics.operations + 1
    end
    record.sequence = record.sequence + 1
    record.lastWorldAgeHours = now
    return true
end

function Runtime.processBatch(nowWorldAgeHours, limit, inspectLimit)
    local now = finite(nowWorldAgeHours)
    if not now or now < 0 then return nil, "finite non-negative world age required" end
    limit = math.max(1, math.floor(tonumber(limit) or 8))
    inspectLimit = math.max(limit, math.floor(tonumber(inspectLimit) or (limit * 4)))
    inspectLimit = math.min(inspectLimit, math.max(highWater, 1))
    local result = { considered=0, processed=0, deferred=0, failed=0, failures={} }
    local inspected = 0
    while inspected < inspectLimit and result.processed < limit and highWater > 0 do
        cursor = cursor + 1; if cursor > highWater then cursor = 1 end
        inspected = inspected + 1
        local target = order[cursor]
        local record = target and tracked[target]
        if record then
            result.considered = result.considered + 1
            local ok, reason = processOne(target, record, now)
            if ok then result.processed = result.processed + 1
            elseif ok == false then result.deferred = result.deferred + 1
            else
                result.failed = result.failed + 1
                result.failures[#result.failures + 1] = tostring(reason)
            end
        end
    end
    diagnostics.considered = diagnostics.considered + result.considered
    diagnostics.processed = diagnostics.processed + result.processed
    diagnostics.deferred = diagnostics.deferred + result.deferred
    diagnostics.failed = diagnostics.failed + result.failed
    return result
end

function Runtime.getDiagnostics()
    local result = {}; for key,value in pairs(diagnostics) do result[key]=value end; return result
end

function Runtime.reset()
    tracked=setmetatable({}, {__mode="k"});order=setmetatable({}, {__mode="v"})
    slots=setmetatable({}, {__mode="k"});highWater,cursor=0,0
    diagnostics={tracked=0,considered=0,processed=0,deferred=0,failed=0,operations=0}
end

return Runtime
