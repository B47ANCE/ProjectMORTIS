local Capabilities = require "Mortis/API/Capabilities"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local Ragdoll = {}

local SETTERS = {
    { capability="zombie.setRagdolling", method="setRagdolling" },
    { capability="zombie.setRagdoll", method="setRagdoll" },
    { capability="zombie.setIsRagdolling", method="setIsRagdolling" },
}

local GETTERS = {
    { capability="zombie.isRagdolling", method="isRagdolling" },
    { capability="zombie.isRagdoll", method="isRagdoll" },
    { capability="zombie.getRagdolling", method="getRagdolling" },
}

function Ragdoll.isAvailable()
    for _, entry in ipairs(SETTERS) do
        if Capabilities.has(entry.capability) then return true end
    end
    return false
end

function Ragdoll.isRagdolling(zombie)
    for _, entry in ipairs(GETTERS) do
        if Capabilities.has(entry.capability) then
            local ok, value = GameAdapter.call(zombie, entry.method)
            if ok then return value == true end
        end
    end
    return false
end

function Ragdoll.start(zombie, options)
    options = options or {}
    for _, entry in ipairs(SETTERS) do
        if Capabilities.has(entry.capability) then
            local ok, result = GameAdapter.call(zombie, entry.method, true)
            if ok then return true, entry.method end
        end
    end
    return false, "no verified ragdoll setter exposed"
end

return Ragdoll
