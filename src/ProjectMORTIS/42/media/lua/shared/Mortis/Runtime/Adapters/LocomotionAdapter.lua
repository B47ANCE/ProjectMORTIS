local Capabilities = require "Mortis/API/Capabilities"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local LocomotionAdapter = {}

local tierMethods = {
    sprinter = "doSprinter",
    fastShambler = "doFastShambler",
    shambler = "doShambler",
}

function LocomotionAdapter.setTier(zombie, tier)
    local method = tierMethods[tier]
    if not method then return false, "unknown locomotion tier: " .. tostring(tier) end
    if not Capabilities.has("zombie." .. method) then return false, "capability unavailable" end
    return GameAdapter.call(zombie, method)
end

function LocomotionAdapter.setWalkType(zombie, walkType)
    if type(walkType) ~= "string" or walkType == "" then return false, "walkType must be a non-empty string" end
    if not Capabilities.has("zombie.setWalkType") then return false, "capability unavailable" end
    local ok, err = GameAdapter.call(zombie, "setWalkType", walkType)
    if not ok then return false, err end
    if Capabilities.has("zombie.setSpeedTypeFromWalkType") then
        return GameAdapter.call(zombie, "setSpeedTypeFromWalkType")
    end
    return true
end

function LocomotionAdapter.setSpeedMultiplier(zombie, multiplier)
    multiplier = tonumber(multiplier)
    if not multiplier or multiplier~=multiplier or multiplier==math.huge or multiplier <= 0 then
        return false, "speed multiplier must be finite and > 0"
    end
    -- Legacy profile API: DoZombieSpeeds initializes randomized speed/animation
    -- state; it is NOT a pure scalar setter. Do not call per tick for injury
    -- scaling. Keep existing profile behavior while a composed tier ceiling is
    -- implemented for anatomical impairment.
    if not Capabilities.has("zombie.DoZombieSpeeds") then return false, "capability unavailable" end
    return GameAdapter.call(zombie, "DoZombieSpeeds", multiplier)
end

function LocomotionAdapter.setCrawler(zombie, enabled)
    if not Capabilities.has("zombie.setCrawler") then return false, "capability unavailable" end
    return GameAdapter.call(zombie, "setCrawler", enabled == true)
end

function LocomotionAdapter.isCrawling(zombie)
    if not Capabilities.has("zombie.isCrawling") then return nil, "capability unavailable" end
    local ok, value = GameAdapter.call(zombie, "isCrawling")
    if not ok then return nil, value end
    return value == true
end

function LocomotionAdapter.setCrawlerSpeed(zombie, ...)
    if not Capabilities.has("zombie.doCrawlerSpeed") then return false, "capability unavailable" end
    return GameAdapter.call(zombie, "doCrawlerSpeed", ...)
end

function LocomotionAdapter.matches(zombie, profile)
    if type(profile) ~= "table" then return false, "profile must be a table" end
    if profile.crawler ~= nil then
        local current, err = LocomotionAdapter.isCrawling(zombie)
        if current == nil then return false, err end
        if current ~= (profile.crawler == true) then return false, "crawler mismatch" end
    end
    -- B42 exposes the speedType field but no stable Lua getter is documented.
    -- Tier/walkType/speed-multiplier correctness is therefore reasserted at a
    -- conservative interval by ProfileRuntime instead of reading raw fields.
    return true, "observable fields matched"
end

return LocomotionAdapter
