local Scheduler=require 'Mortis/Core/Scheduler'
local Settings=require 'Mortis/Runtime/SystemSettings'
local Work=require 'Mortis/Runtime/HungerScheduler'
isServer=function()return true end;isClient=function()return false end
SandboxVars={MORTISSystems={HungerWorkPerTick=32}}
local function actor(id)
    return {id=id,getSquare=function()return true end,isDead=function(self)return self.dead==true end}
end
local zombie=actor(0)
assert(not Work.enqueue(zombie),'no population fallback without a global clock')
Scheduler.useExternalClock(true)
local population,visited={},{}
for i=1,100000 do population[i]=actor(i);assert(Work.enqueue(population[i])) end
for i=1,#population do assert(Work.enqueue(population[i])) end
assert(Work.getDiagnostics().queued==100000,'one queue record per actor')
local function process(z)
    assert(not visited[z.id],'one accepted poll cannot execute twice')
    visited[z.id]=true
    assert(Work.enqueue(z),'callback re-entry must deduplicate the in-flight actor')
    assert(Work.update(process)==0,'nested drain must not multiply work')
    return false,'no-nearby-source'
end
local ticks=0
while Work.getDiagnostics().queued>0 do
    Scheduler.advance();local done=Work.update(process)
    assert(done<=32 and Work.update(process)==0,'strict budget across repeated calls')
    ticks=ticks+1;assert(ticks<=3125,'FIFO must serve every accepted actor')
end
for i=1,#population do assert(visited[i])end
local result=Work.getDiagnostics()
assert(result.attempted==100000 and result.checked==100000 and result.fed==0 and result.errors==0)
assert(ticks==3125)
-- A fresh actor joins the tail; stable update order cannot jump existing work.
local order={};for i=1,20 do assert(Work.enqueue(population[i]))end
SandboxVars.MORTISSystems.HungerWorkPerTick=1
for i=1,20 do
    Work.enqueue(population[20]);Scheduler.advance()
    assert(Work.update(function(z)order[#order+1]=z.id;return false end)==1)
end
for i=1,20 do assert(order[i]==i)end
-- Dead/cancelled/collected work is bounded and never fed; clients never run it.
local stale=actor(100001);assert(Work.enqueue(stale));stale.dead=true
local gone=actor(100002);assert(Work.enqueue(gone));assert(Work.release(gone))
local weak=actor(100003);assert(Work.enqueue(weak));weak=nil;collectgarbage('collect')
Scheduler.advance();assert(Work.update(function()error('dead actor processed')end)==0)
Scheduler.advance();assert(Work.update(function()error('collected actor processed')end)==0)
assert(Work.getDiagnostics().queued==0)
assert(Work.enqueue(zombie));isServer=function()return false end;isClient=function()return true end
Scheduler.advance();assert(Work.update(function()error('client work')end)==0 and not Work.enqueue(population[1]))
isServer=function()return true end;isClient=function()return false end
for _,bad in ipairs({0,-1,1.5,513,math.huge,0/0,'bad'})do
    SandboxVars.MORTISSystems.HungerWorkPerTick=bad;Scheduler.advance()
    assert(Work.update(function()error('invalid budget ran')end)==0)
end
SandboxVars.MORTISSystems.HungerWorkPerTick=2;Scheduler.advance()
assert(Work.update(function()error('intentional worker failure')end)==1)
assert(Work.getDiagnostics().errors==1 and Work.getDiagnostics().checked==100020)
assert(Work.enqueue(zombie));SandboxVars.MORTISSystems.EnableZombieHunger=false;Scheduler.advance()
assert(Work.update(function()error('disabled work')end)==0 and Work.getDiagnostics().queued==0)
-- Missing saves use the default; the supported maximum still shares one frame.
SandboxVars.MORTISSystems.EnableZombieHunger=true;SandboxVars.MORTISSystems.HungerWorkPerTick=nil
for i=1,700 do assert(Work.enqueue(population[i])) end
Scheduler.advance();assert(Work.update(function()return false end)==32)
SandboxVars.MORTISSystems.HungerWorkPerTick=512
assert(Work.update(function()return false end)==480)
assert(Work.update(function()return false end)==0)
Scheduler.advance();assert(Work.update(function()return false end)==188)
local capacity=Work.getDiagnostics().maximumQueued;local retained={}
for i=1,capacity do retained[i]=actor(i+200000);assert(Work.enqueue(retained[i])) end
assert(not Work.enqueue(actor(999999)) and Work.getDiagnostics().overflow==1)
assert(Work.getDiagnostics().queued==capacity,'overflow must not evict accepted actors')
for _,z in ipairs(retained)do assert(Work.release(z))end
assert(Work.getDiagnostics().queued==0)
print('100000 actors: strict 32-work budget, FIFO coverage in 3125 ticks, cancellation/realm/config/failure checks passed')
