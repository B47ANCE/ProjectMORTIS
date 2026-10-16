local function stub(name, value)
    package.loaded[name] = nil
    package.preload[name] = function() return value end
end

local identity = {}
function identity.getStableId(z) return z.stableId end
function identity.getTypeId(z) return z.typeId end
function identity.getType() return nil end
function identity.restore() return false end

local components = {}
function components.isDirty() return false end
function components.isReplicationDirty(z) return z.dirty == true end
function components.clear() end

stub("Mortis/Runtime/Identity", identity)
stub("Mortis/API/Types", { get=function() return nil end, has=function() return true end })
stub("Mortis/API/Traits", { get=function() return nil end })
stub("Mortis/API/Behaviors", { get=function() return nil end })
stub("Mortis/Core/Scheduler", { shouldRun=function() return false end, release=function() end })
stub("Mortis/Core/FaultIsolation", { call=function(_,_,fn,...) return true,fn(...) end })
stub("Mortis/Runtime/Authority", {
    canWriteCanonicalState=function() return true end,
    canRunCanonicalAI=function() return true end,
})
stub("Mortis/Runtime/Context", { create=function() return {} end })
stub("Mortis/API/Capabilities", { observeZombie=function() end })
stub("Mortis/Runtime/Components", components)
stub("Mortis/Runtime/Persistence", {
    loadComponents=function() end, readIdentity=function() return nil end,
    flushComponents=function() return true end, flushZombie=function() return true end,
})
stub("Mortis/Core/Logger", { warn=function() end, rateLimited=function() end })
stub("Mortis/Runtime/Adapters/NetworkAdapter", { getOnlineID=function(z) return z.onlineId end })
stub("Mortis/Runtime/Replication", { release=function() end, forgetApplied=function() end })
stub("Mortis/Runtime/ProfileRuntime", {})
stub("Mortis/Runtime/DamageRuntime", {})
stub("Mortis/Runtime/Adapters/StateAdapter", {})
stub("Mortis/Runtime/HitTraumaRuntime", { clear=function() end })
stub("Mortis/Runtime/ZombieHungerRuntime", {})
stub("Mortis/Runtime/SystemSettings", { bool=function() return false end })
stub("Mortis/API/DetachedParts", { snapshotDeath=function() return true,{} end })

package.loaded["Mortis/Runtime/Engine"] = nil
local Engine = require "Mortis/Runtime/Engine"

local zombies = {}
for i=1,5 do
    zombies[i] = { stableId="z"..i, onlineId=i, typeId="test", dirty=(i % 2 == 0) }
    Engine.onCreated(zombies[i])
end

local a = Engine.takeTrackedBatch("runtime", 2)
local b = Engine.takeTrackedBatch("runtime", 2)
local c = Engine.takeTrackedBatch("runtime", 2)
assert(#a == 2 and a[1] == zombies[1] and a[2] == zombies[2], "first batch must begin at head")
assert(#b == 2 and b[1] == zombies[3] and b[2] == zombies[4], "second batch must continue fairly")
assert(#c == 2 and c[1] == zombies[5] and c[2] == zombies[1], "batch must wrap fairly")

local independent = Engine.takeTrackedBatch("other-consumer", 1)
assert(independent[1] == zombies[1], "consumer cursors must be independent")

local dirty = Engine.collectReplicationDirty(1)
local dirty2 = Engine.collectReplicationDirty(1)
assert(dirty[1] == zombies[2], "dirty scan should find first eligible zombie")
assert(dirty2[1] == zombies[4], "dirty scan should resume instead of rescanning the head")
assert(Engine.findTrackedByOnlineID(5) == zombies[5], "online index should remain valid")

zombies[5].onlineId=55
Engine.takeTrackedBatch('index-refresh',5)
assert(Engine.findTrackedByOnlineID(5)==nil,'obsolete online ID must be removed')
assert(Engine.findTrackedByOnlineID(55)==zombies[5])
assert(Engine.findTrackedByOnlineID(0/0)==nil,'NaN lookup must fail closed')

print("Project M.O.R.T.I.S. tracked batch tests passed")
