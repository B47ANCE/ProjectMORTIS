local Profiler = {
    enabled = false,
    samples = {},
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

local function nowMs()
    if type(getTimestampMs) == "function" then
        local ok, value = pcall(getTimestampMs)
        if ok and type(value) == "number" then return value end
    end
    if os and type(os.clock) == "function" then return os.clock() * 1000 end
    return 0
end

function Profiler.setEnabled(enabled)
    Profiler.enabled = enabled == true
end

function Profiler.record(name, elapsedMs)
    if not Profiler.enabled then return end
    local entry = Profiler.samples[name]
    if not entry then
        entry = { calls = 0, totalMs = 0, maxMs = 0, lastMs = 0 }
        Profiler.samples[name] = entry
    end
    entry.calls = entry.calls + 1
    entry.totalMs = entry.totalMs + elapsedMs
    entry.lastMs = elapsedMs
    if elapsedMs > entry.maxMs then entry.maxMs = elapsedMs end
end

function Profiler.measure(name, fn)
    if not Profiler.enabled then return fn() end
    local start = nowMs()
    local results = { fn() }
    Profiler.record(name, nowMs() - start)
    return unpackValues(results, 1, #results)
end

function Profiler.snapshot()
    local result = {}
    for name, entry in pairs(Profiler.samples) do
        result[name] = {
            calls = entry.calls,
            totalMs = entry.totalMs,
            maxMs = entry.maxMs,
            lastMs = entry.lastMs,
            averageMs = entry.calls > 0 and (entry.totalMs / entry.calls) or 0,
        }
    end
    return result
end

function Profiler.reset()
    Profiler.samples = {}
end

return Profiler
