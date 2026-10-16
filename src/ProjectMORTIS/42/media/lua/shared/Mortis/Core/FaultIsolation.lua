local Logger = require "Mortis/Core/Logger"
local Profiler = require "Mortis/Core/Profiler"

local FaultIsolation = {
    failures = {},
    threshold = 3,
}

local unpackValues = unpack or (table and table.unpack)
if not unpackValues then
    unpackValues = function(values, first, last)
        first = first or 1
        last = last or #values
        if first > last then return end
        return values[first], unpackValues(values, first + 1, last)
    end
end

local protectedCall = xpcall or function(fn, handler)
    local results = { pcall(fn) }
    if results[1] then
        return true, unpackValues(results, 2, #results)
    end
    return false, handler(results[2])
end

local function keyFor(owner, callback)
    return tostring(owner or "unknown") .. ":" .. tostring(callback or "callback")
end

function FaultIsolation.configure(options)
    options = options or {}
    if options.threshold ~= nil then
        local value = tonumber(options.threshold)
        assert(value and value >= 1, "fault threshold must be >= 1")
        FaultIsolation.threshold = math.floor(value)
    end
end

function FaultIsolation.isDisabled(owner, callback)
    local state = FaultIsolation.failures[keyFor(owner, callback)]
    return state and state.disabled or false
end

function FaultIsolation.getState(owner, callback)
    local state = FaultIsolation.failures[keyFor(owner, callback)]
    if not state then return nil end
    return {
        count = state.count,
        disabled = state.disabled,
        lastError = state.lastError,
    }
end

function FaultIsolation.all()
    local result = {}
    for key, state in pairs(FaultIsolation.failures) do
        result[key] = { count = state.count, disabled = state.disabled, lastError = state.lastError }
    end
    return result
end

function FaultIsolation.call(owner, callback, fn, ...)
    if type(fn) ~= "function" then return true end
    local key = keyFor(owner, callback)
    local state = FaultIsolation.failures[key]
    if state and state.disabled then return false, "disabled" end

    local args = { ... }
    local ok, result
    local function invoke()
        return protectedCall(function()
            return fn(unpackValues(args, 1, #args))
        end, function(err)
            return tostring(err) .. "\n" .. (debug and debug.traceback and debug.traceback() or "")
        end)
    end

    ok, result = Profiler.measure("callback:" .. key, invoke)
    if ok then return true, result end

    state = state or { count = 0, disabled = false }
    state.count = state.count + 1
    state.lastError = result
    if state.count >= FaultIsolation.threshold then state.disabled = true end
    FaultIsolation.failures[key] = state

    Logger.rateLimited("fault:" .. key, 2, "ERROR",
        string.format("Callback failure %s (%d/%d): %s", key, state.count, FaultIsolation.threshold, tostring(result)),
        "FAULT")
    if state.disabled then
        Logger.once("fault-disabled:" .. key, "ERROR", "Disabled repeatedly failing callback: " .. key, "FAULT")
    end
    return false, result
end

function FaultIsolation.reset(owner, callback)
    FaultIsolation.failures[keyFor(owner, callback)] = nil
end

function FaultIsolation.resetAll()
    FaultIsolation.failures = {}
end

return FaultIsolation
