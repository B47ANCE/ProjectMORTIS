local Capabilities = require "Mortis/API/Capabilities"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"
local Authority = require "Mortis/Runtime/Authority"

local NetworkAdapter = {}

function NetworkAdapter.isAuthority(zombie)
    return Authority.canRunCanonicalAI(zombie)
end

function NetworkAdapter.getOnlineID(zombie)
    if not Capabilities.has("zombie.getOnlineID") then return nil, "capability unavailable" end
    local ok, value = GameAdapter.call(zombie, "getOnlineID")
    if not ok then return nil, value end
    return value
end

function NetworkAdapter.hasUsableOnlineID(zombie)
    local id = NetworkAdapter.getOnlineID(zombie)
    return type(id) == "number" and id >= 0
end

-- B42 command signatures have varied across examples/builds. Keep overload
-- selection inside the runtime adapter so extension code never depends on it.
function NetworkAdapter.sendClient(module, command, args)
    if type(sendClientCommand) ~= "function" then return false, "sendClientCommand unavailable" end
    args = args or {}
    local player = type(getPlayer) == "function" and getPlayer() or nil
    if player ~= nil then
        local ok, err = pcall(sendClientCommand, player, module, command, args)
        if ok then return true end
        -- Some runtimes/examples expose the legacy three-argument overload.
        local okLegacy, errLegacy = pcall(sendClientCommand, module, command, args)
        if okLegacy then return true end
        return false, tostring(err) .. " / " .. tostring(errLegacy)
    end
    local ok, err = pcall(sendClientCommand, module, command, args)
    return ok, err
end

function NetworkAdapter.sendServer(player, module, command, args)
    if type(sendServerCommand) ~= "function" then return false, "sendServerCommand unavailable" end
    args = args or {}
    local ok, err
    if player ~= nil then
        ok, err = pcall(sendServerCommand, player, module, command, args)
    else
        ok, err = pcall(sendServerCommand, module, command, args)
    end
    return ok, err
end

return NetworkAdapter
