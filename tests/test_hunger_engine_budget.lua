-- Run the actual Engine, Scheduler and FIFO. Unrelated engine/native services
-- are boundaries; hungry searches and persistence calls are measured directly.
local function stub(name,value)package.loaded['Mortis/'..name]=value end
local dirty=setmetatable({},{__mode='k'});local calls,flushes=0,0
stub('Runtime/Identity',{getStableId=function(z)return 'actor-'..z.id end,getTypeId=function()end,getType=function()end})
stub('API/Types',{});stub('API/Traits',{});stub('API/Behaviors',{})
stub('Runtime/Context',{});stub('API/Capabilities',{})
stub('Runtime/Components',{isDirty=function(z)return dirty[z]end,clear=function(z)dirty[z]=nil end})
stub('Runtime/Persistence',{flushComponents=function(z)flushes=flushes+1;dirty[z]=nil;return true end})
stub('Runtime/Adapters/NetworkAdapter',{getOnlineID=function(z)return z.id end})
stub('Runtime/Replication',{release=function()end,forgetApplied=function()end})
stub('Runtime/ProfileRuntime',{hasPendingLocomotionRestore=function()return false end})
stub('Runtime/DamageRuntime',{});stub('Runtime/Adapters/StateAdapter',{})
stub('Runtime/HitTraumaRuntime',{clear=function()end})
stub('API/DetachedParts',{snapshotDeath=function()return true,{}end})
stub('Runtime/ZombieHungerRuntime',{updateFoodSeeking=function(z)
    calls=calls+1;dirty[z]=true;return false,'no-nearby-source'
end})
isServer=function()return true end;isClient=function()return false end
SandboxVars={MORTISSystems={HungerWorkPerTick=32}}
local Scheduler=require 'Mortis/Core/Scheduler';Scheduler.useExternalClock(true)
local Engine=arg and arg[1] and dofile(arg[1])or require 'Mortis/Runtime/Engine'
local population={}
for i=1,10000 do
    population[i]={id=i,getSquare=function()return true end,isDead=function()return false end}
    Engine.update(population[i])
end
assert(calls==0,'per-zombie callbacks must only enqueue, not perform food searches: '..calls)
assert(Engine.getHungerSchedulingDiagnostics().queued==34,'staggered 300-tick admission retained')
Scheduler.advance();assert(Engine.updateHungerBudget()==32)
assert(calls==32 and flushes==32,'worker must stage component changes outside Engine.update')
assert(Engine.updateHungerBudget()==0 and calls==32)
Engine.onDead(population[9601])
assert(Engine.getHungerSchedulingDiagnostics().queued==1,'death cancels queued work in constant time')
Scheduler.advance();assert(Engine.updateHungerBudget()==1 and calls==33)
assert(Engine.getHungerSchedulingDiagnostics().queued==0)
print('10000 Engine updates: zero direct searches, at most 32 worker calls/tick and prompt persistence staging')
