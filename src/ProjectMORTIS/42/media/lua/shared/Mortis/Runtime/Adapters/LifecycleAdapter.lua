local Capabilities = require "Mortis/API/Capabilities"

local LifecycleAdapter = {}

function LifecycleAdapter.bind(name, callback)
    local capability = "events." .. name
    if not Capabilities.has(capability) then return false, "capability unavailable: " .. capability end
    Events[name].Add(callback)
    return true
end

return LifecycleAdapter
