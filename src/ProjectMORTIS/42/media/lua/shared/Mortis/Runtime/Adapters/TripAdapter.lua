local Capabilities = require "Mortis/API/Capabilities"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"
local State = require "Mortis/Runtime/Adapters/StateAdapter"
local Ragdoll = require "Mortis/Runtime/Adapters/RagdollAdapter"
local ActionDiagnostics = require "Mortis/Core/ActionDiagnostics"

local TripAdapter = {}
local function reject(action,reason,context)return ActionDiagnostics.record("rejection",action,reason,context)end

function TripAdapter.canTrip(zombie, options)
    options = options or {}
    if zombie == nil then return reject("trip.canTrip","missing zombie") end

    if Capabilities.has("zombie.isDead") then
        local ok, dead = GameAdapter.call(zombie, "isDead")
        if ok and dead == true then return reject("trip.canTrip","dead") end
    end

    local crawling = State.isCrawling(zombie)
    if crawling == true then return reject("trip.canTrip","crawler") end

    if Capabilities.has("zombie.isOnFloor") then
        local ok, value = GameAdapter.call(zombie, "isOnFloor")
        if ok and value == true then return reject("trip.canTrip","already on floor") end
    end
    if Capabilities.has("zombie.isKnockedDown") then
        local ok, value = GameAdapter.call(zombie, "isKnockedDown")
        if ok and value == true then return reject("trip.canTrip","already knocked down") end
    end

    local busy, reason = State.isBusy(zombie)
    if busy then
        local allowed = options.allowBusyReasons
        if type(allowed) ~= "table" or allowed[reason] ~= true then
            return reject("trip.canTrip","native state busy: " .. tostring(reason),{busyReason=tostring(reason)})
        end
    end
    return true
end

function TripAdapter.trip(zombie, options)
    options = options or {}
    local allowed, reason = TripAdapter.canTrip(zombie, options)
    if not allowed then return false, reason end

    local fallOnFront = options.fallOnFront
    if fallOnFront == nil then fallOnFront = true end

    if options.preferredOutcome == "ragdoll" then
        local ragdollOk, ragdollMode = Ragdoll.start(zombie, options)
        if ragdollOk then return true, "ragdoll:" .. tostring(ragdollMode) end
        -- Fall through to native knockdown if the installed runtime does not
        -- expose a safe ragdoll setter.
    end

    if Capabilities.has("zombie.setFallOnFront") then
        local ok, err = GameAdapter.call(zombie, "setFallOnFront", fallOnFront == true)
        if not ok then return reject("trip.trip",err or "setFallOnFront failed") end
    end

    -- Build 42's IsoZombie.knockDown(boolean) is the canonical transition. In
    -- addition to the knocked-down flag it establishes the normal hit force,
    -- reaction, direction and `wasHit` event used by native animation/network
    -- state. If it is exposed but fails, stop: falling through after a partial
    -- native transition could apply the trip twice.
    if Capabilities.has("zombie.knockDown") then
        local ok, err = GameAdapter.call(zombie, "knockDown", options.hitFromBehind == true)
        if ok then return true, "native-knockdown" end
        return reject("trip.trip",err or "knockDown failed")
    end

    -- Compatibility fallback for runtimes which expose the older raw setter
    -- but not the complete transition method.
    if Capabilities.has("zombie.setKnockedDown") then
        local ok, err = GameAdapter.call(zombie, "setKnockedDown", true)
        if ok then return true, "legacy-knocked-down" end
        return reject("trip.trip",err or "setKnockedDown failed")
    end

    if Capabilities.has("zombie.setStaggerBack") then
        local ok, err = GameAdapter.call(zombie, "setStaggerBack", true)
        if ok then return true, "stagger-fallback" end
        return reject("trip.trip",err or "setStaggerBack failed")
    end

    return reject("trip.trip","no verified trip/knockdown capability")
end

return TripAdapter
