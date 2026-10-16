local Capabilities = require "Mortis/API/Capabilities"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local SoundAdapter = {}

function SoundAdapter.getEmitter(zombie)
    if not Capabilities.has("zombie.getEmitter") then return nil, "capability unavailable" end
    local ok, value = GameAdapter.call(zombie, "getEmitter")
    if not ok then return nil, value end
    return value
end

function SoundAdapter.play(zombie, soundId)
    local emitter, reason = SoundAdapter.getEmitter(zombie)
    if not emitter then return false, reason end
    return GameAdapter.call(emitter, "playSound", soundId)
end

function SoundAdapter.emitWorldSound(source,radius,volume)
    if not source or type(addSound)~="function" then return false,"world-sound API unavailable" end
    local ok,x,y,z=pcall(function() return source:getX(),source:getY(),source:getZ() end)
    if not ok or not x or not y then return false,"world-sound source position unavailable" end
    local emitted,reason=pcall(addSound,source,math.floor(x),math.floor(y),math.floor(tonumber(z) or 0),
        math.max(1,math.floor(tonumber(radius) or 20)),math.max(1,math.floor(tonumber(volume) or 20)))
    return emitted,emitted and nil or reason
end

return SoundAdapter
