local Capabilities = require "Mortis/API/Capabilities"
local FaultIsolation = require "Mortis/Core/FaultIsolation"
local Profiler = require "Mortis/Core/Profiler"
local Scheduler = require "Mortis/Core/Scheduler"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"
local Authority = require "Mortis/Runtime/Authority"
local Persistence = require "Mortis/Runtime/Persistence"
local LocomotionProfiles = require "Mortis/API/LocomotionProfiles"
local DurabilityProfiles = require "Mortis/API/DurabilityProfiles"
local AppearanceProfiles = require "Mortis/API/AppearanceProfiles"
local ActionDiagnostics = require "Mortis/Core/ActionDiagnostics"

local Diagnostics = {}

local function tableCount(value)
    local count = 0
    for _ in pairs(value or {}) do count = count + 1 end
    return count
end

function Diagnostics.snapshot()
    local Engine = require "Mortis/Runtime/Engine"
    return {
        runtimeVersion = GameAdapter.getVersion(),
        authority = Authority.mode(),
        capabilities = Capabilities.all(),
        persistence = {
            available = Persistence.isAvailable(),
            trackedZombies = Engine.trackedCount(),
            formatVersion = Persistence.FORMAT_VERSION,
        },
        faults = FaultIsolation.all(),
        profiler = Profiler.snapshot(),
        scheduler = {
            frame = Scheduler.frame,
            externalClock = Scheduler.externalClock,
        },
        profiles = {
            locomotion = tableCount(LocomotionProfiles.all()),
            durability = tableCount(DurabilityProfiles.all()),
            appearance = tableCount(AppearanceProfiles.all()),
        },
        actionDiagnostics = ActionDiagnostics.snapshot(),
    }
end

function Diagnostics.capabilitySummary()
    local values = Capabilities.all()
    local yes, no = 0, 0
    for _, value in pairs(values) do
        if value == true then yes = yes + 1 else no = no + 1 end
    end
    return { available = yes, unavailable = no, total = yes + no }
end

return Diagnostics
