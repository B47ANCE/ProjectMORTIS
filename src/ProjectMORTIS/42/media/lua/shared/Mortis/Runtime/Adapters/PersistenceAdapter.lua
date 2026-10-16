local Capabilities = require "Mortis/API/Capabilities"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local PersistenceAdapter = {}

function PersistenceAdapter.getModData(zombie)
    if zombie == nil then return nil, "zombie is required" end
    if not Capabilities.has("zombie.getModData") then return nil, "capability unavailable: zombie.getModData" end
    local ok, value = GameAdapter.call(zombie, "getModData")
    if not ok then return nil, value end
    if type(value) ~= "table" then return nil, "getModData did not return a table" end
    return value
end

function PersistenceAdapter.transmitModData(zombie)
    if zombie == nil then return false, "zombie is required" end
    if not Capabilities.has("zombie.transmitModData") then return false, "capability unavailable: zombie.transmitModData" end
    local ok, value = GameAdapter.call(zombie, "transmitModData")
    if not ok then return false, value end
    return true, value
end

return PersistenceAdapter
