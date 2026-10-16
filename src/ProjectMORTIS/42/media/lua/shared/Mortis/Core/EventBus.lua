local Util = require "Mortis/Core/Util"

local EventBus = {}
EventBus.__index = EventBus

function EventBus.new()
    return setmetatable({ handlers = {} }, EventBus)
end

function EventBus:on(eventName, handler)
    Util.assertString(eventName, "eventName")
    if type(handler) ~= "function" then error("handler must be a function", 2) end
    local bucket = self.handlers[eventName]
    if not bucket then
        bucket = {}
        self.handlers[eventName] = bucket
    end
    bucket[#bucket + 1] = handler
    return handler
end

function EventBus:off(eventName, handler)
    local bucket = self.handlers[eventName]
    if not bucket then return false end
    for index = #bucket, 1, -1 do
        if bucket[index] == handler then
            table.remove(bucket, index)
            return true
        end
    end
    return false
end

function EventBus:emit(eventName, ...)
    local bucket = self.handlers[eventName]
    if not bucket then return true end
    -- snapshot avoids mutation-during-dispatch bugs
    local snapshot = {}
    for i = 1, #bucket do snapshot[i] = bucket[i] end
    for i = 1, #snapshot do
        local ok, err = pcall(snapshot[i], ...)
        if not ok then
            print(string.format("[MORTIS] [ERROR] event '%s' handler failed: %s", eventName, tostring(err)))
        end
    end
    return true
end

return EventBus
