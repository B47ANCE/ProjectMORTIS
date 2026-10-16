local calls = {}
local capabilities = {
    ["zombie.isDead"] = true,
    ["zombie.isOnFloor"] = true,
    ["zombie.isKnockedDown"] = true,
    ["zombie.setFallOnFront"] = true,
    ["zombie.knockDown"] = true,
    ["zombie.setKnockedDown"] = true,
    ["zombie.setStaggerBack"] = true,
}
local state = { dead=false, onFloor=false, knockedDown=false, crawling=false, busy=false }
local fail = {}

local mocks = {
    ["Mortis/API/Capabilities"] = { has=function(name) return capabilities[name] == true end },
    ["Mortis/Runtime/Adapters/GameAdapter"] = {
        call=function(_, method, value)
            calls[#calls+1] = { method=method, value=value }
            if fail[method] then return false, fail[method] end
            if method == "isDead" then return true, state.dead end
            if method == "isOnFloor" then return true, state.onFloor end
            if method == "isKnockedDown" then return true, state.knockedDown end
            return true
        end,
    },
    ["Mortis/Runtime/Adapters/StateAdapter"] = {
        isCrawling=function() return state.crawling end,
        isBusy=function() return state.busy, state.busyReason end,
    },
    ["Mortis/Runtime/Adapters/RagdollAdapter"] = { start=function() return false, "unavailable" end },
    ["Mortis/Core/ActionDiagnostics"] = { record=function(_,_,reason) return false, reason end },
}
local realRequire = require
require = function(name) return mocks[name] or realRequire(name) end
local Trip = dofile(arg[1])

local function reset()
    calls = {}
    fail = {}
    state = { dead=false, onFloor=false, knockedDown=false, crawling=false, busy=false }
end

local ok, mode = Trip.trip({}, { fallOnFront=false, hitFromBehind=true })
assert(ok and mode == "native-knockdown", "canonical knockDown must be preferred")
assert(calls[#calls-1].method == "setFallOnFront" and calls[#calls-1].value == false)
assert(calls[#calls].method == "knockDown" and calls[#calls].value == true)
for _, call in ipairs(calls) do
    assert(call.method ~= "setKnockedDown", "raw setter must not run when knockDown exists")
end

reset()
fail.knockDown = "native failure"
ok, mode = Trip.trip({}, {})
assert(not ok and mode == "native failure", "canonical failure must fail closed")
for _, call in ipairs(calls) do
    assert(call.method ~= "setKnockedDown", "must not fall through after canonical failure")
end

reset()
capabilities["zombie.knockDown"] = false
ok, mode = Trip.trip({}, {})
assert(ok and mode == "legacy-knocked-down", "legacy runtime must retain safe fallback")
assert(calls[#calls].method == "setKnockedDown")
capabilities["zombie.knockDown"] = true

for field, reason in pairs({ dead="dead", onFloor="already on floor", knockedDown="already knocked down", crawling="crawler" }) do
    reset()
    state[field] = true
    ok, mode = Trip.trip({}, {})
    assert(not ok and mode == reason, "expected rejection for " .. field)
    for _, call in ipairs(calls) do
        assert(call.method ~= "knockDown" and call.method ~= "setKnockedDown", "rejection must not mutate")
    end
end

reset()
state.busy, state.busyReason = true, "climbing"
ok, mode = Trip.trip({}, {})
assert(not ok and mode == "native state busy: climbing")
ok, mode = Trip.trip({}, { allowBusyReasons={ climbing=true } })
assert(ok and mode == "native-knockdown", "explicitly permitted busy reason should proceed")

print("MORTIS native trip adapter regression checks passed")
