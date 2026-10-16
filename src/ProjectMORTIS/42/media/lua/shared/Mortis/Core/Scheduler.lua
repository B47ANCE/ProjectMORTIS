local Scheduler = {
    frame = 0,
    externalClock = false,
    classes = {
        critical = 1,
        fast = 3,
        normal = 10,
        slow = 30,
        dormant = math.huge,
    },
    budgets = {},
    used = {},
}

local objectPhase = setmetatable({}, { __mode = "k" })
local fallbackCounters = setmetatable({}, { __mode = "k" })
local phaseCursor = {}
local classStats = {}
local budgetStats = {}

local function classKey(className)
    return Scheduler.classes[className or "normal"] and (className or "normal") or "normal"
end

local function statFor(collection, key)
    local entry = collection[key]
    if not entry then entry = {}; collection[key] = entry end
    return entry
end

local function intervalFor(className)
    return Scheduler.classes[className or "normal"] or Scheduler.classes.normal
end

function Scheduler.configure(className, interval)
    assert(type(className) == "string", "scheduler class name must be a string")
    assert(type(interval) == "number" and interval >= 1, "scheduler interval must be >= 1")
    Scheduler.classes[className] = math.floor(interval)
end

function Scheduler.configureBudget(name, perFrame)
    assert(type(name) == "string" and name ~= "", "budget name must be a non-empty string")
    if perFrame == nil then
        Scheduler.budgets[name] = nil
        Scheduler.used[name] = nil
        return
    end
    assert(type(perFrame) == "number" and perFrame >= 0, "budget must be >= 0")
    Scheduler.budgets[name] = math.floor(perFrame)
end

function Scheduler.consumeBudget(name, amount)
    local limit = Scheduler.budgets[name]
    amount = math.max(1, math.floor(tonumber(amount) or 1))
    local metrics = statFor(budgetStats, name)
    metrics.requests = (metrics.requests or 0) + 1
    metrics.requestedUnits = (metrics.requestedUnits or 0) + amount
    if limit == nil then
        metrics.accepted = (metrics.accepted or 0) + 1
        metrics.acceptedUnits = (metrics.acceptedUnits or 0) + amount
        return true
    end
    local used = Scheduler.used[name] or 0
    if used + amount > limit then
        metrics.deferred = (metrics.deferred or 0) + 1
        metrics.deferredUnits = (metrics.deferredUnits or 0) + amount
        return false
    end
    Scheduler.used[name] = used + amount
    metrics.accepted = (metrics.accepted or 0) + 1
    metrics.acceptedUnits = (metrics.acceptedUnits or 0) + amount
    return true
end

function Scheduler.getBudgetState(name)
    return { limit = Scheduler.budgets[name], used = Scheduler.used[name] or 0 }
end

function Scheduler.useExternalClock(enabled)
    Scheduler.externalClock = enabled == true
end

function Scheduler.advance()
    Scheduler.frame = Scheduler.frame + 1
    Scheduler.used = {}
end

local function shouldRunFallback(zombie, interval)
    local count = (fallbackCounters[zombie] or 0) + 1
    fallbackCounters[zombie] = count
    return (count % interval) == 1
end

local function assignPhase(zombie, interval)
    local perObject = objectPhase[zombie]
    if not perObject then
        perObject = {}
        objectPhase[zombie] = perObject
    end
    if perObject[interval] == nil then
        local cursor = phaseCursor[interval] or 0
        perObject[interval] = cursor % interval
        phaseCursor[interval] = cursor + 1
    end
    return perObject[interval]
end

function Scheduler.shouldRun(zombie, className, explicitInterval)
    local interval = explicitInterval or intervalFor(className)
    local metrics = statFor(classStats, classKey(className))
    metrics.considered = (metrics.considered or 0) + 1
    if interval == math.huge then
        metrics.deferred = (metrics.deferred or 0) + 1
        return false
    end
    if interval <= 1 then
        metrics.ran = (metrics.ran or 0) + 1
        return true
    end

    local run
    if not Scheduler.externalClock then
        run = shouldRunFallback(zombie, interval)
    else
        local phase = assignPhase(zombie, interval)
        run = (Scheduler.frame % interval) == phase
    end
    local field = run and "ran" or "deferred"
    metrics[field] = (metrics[field] or 0) + 1
    return run
end

function Scheduler.getDiagnostics()
    local result = { frame = Scheduler.frame, externalClock = Scheduler.externalClock, classes = {}, budgets = {} }
    for name, metrics in pairs(classStats) do
        result.classes[name] = {
            considered = metrics.considered or 0,
            ran = metrics.ran or 0,
            deferred = metrics.deferred or 0,
        }
    end
    for name, metrics in pairs(budgetStats) do
        result.budgets[name] = {
            limit = Scheduler.budgets[name], used = Scheduler.used[name] or 0,
            requests = metrics.requests or 0, accepted = metrics.accepted or 0,
            deferred = metrics.deferred or 0, requestedUnits = metrics.requestedUnits or 0,
            acceptedUnits = metrics.acceptedUnits or 0, deferredUnits = metrics.deferredUnits or 0,
        }
    end
    return result
end

function Scheduler.release(zombie)
    objectPhase[zombie] = nil
    fallbackCounters[zombie] = nil
end

function Scheduler.reset()
    Scheduler.frame = 0
    Scheduler.used = {}
    objectPhase = setmetatable({}, { __mode = "k" })
    fallbackCounters = setmetatable({}, { __mode = "k" })
    phaseCursor = {}
    classStats = {}
    budgetStats = {}
end

return Scheduler
