local Logger = {
    prefix = "[MORTIS]",
    minimumLevel = "INFO",
    _rate = {},
    _once = {},
}

local order = { DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4 }

local function now()
    if type(getTimestampMs) == "function" then
        local ok, value = pcall(getTimestampMs)
        if ok and type(value) == "number" then return value / 1000 end
    end
    if os and type(os.clock) == "function" then return os.clock() end
    return 0
end

local function enabled(level)
    return (order[level] or 2) >= (order[Logger.minimumLevel] or 2)
end

local function emit(level, message, category)
    if not enabled(level) then return end
    local cat = category and (" [" .. tostring(category) .. "]") or ""
    print(string.format("%s [%s]%s %s", Logger.prefix, level, cat, tostring(message)))
end

function Logger.setMinimumLevel(level)
    level = tostring(level or "INFO"):upper()
    assert(order[level], "invalid log level: " .. level)
    Logger.minimumLevel = level
end

function Logger.debug(message, category) emit("DEBUG", message, category) end
function Logger.info(message, category) emit("INFO", message, category) end
function Logger.warn(message, category) emit("WARN", message, category) end
function Logger.error(message, category) emit("ERROR", message, category) end

function Logger.once(key, level, message, category)
    key = tostring(key)
    if Logger._once[key] then return false end
    Logger._once[key] = true
    emit((level or "INFO"):upper(), message, category)
    return true
end

function Logger.rateLimited(key, seconds, level, message, category)
    key = tostring(key)
    seconds = tonumber(seconds) or 5
    local t = now()
    local last = Logger._rate[key]
    if last ~= nil and (t - last) < seconds then return false end
    Logger._rate[key] = t
    emit((level or "WARN"):upper(), message, category)
    return true
end

function Logger.resetRateLimits()
    Logger._rate = {}
    Logger._once = {}
end

return Logger
