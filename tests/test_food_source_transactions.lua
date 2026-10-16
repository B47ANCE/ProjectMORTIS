local authority=true
isClient=function()return not authority end
isServer=function()return authority end
local states=setmetatable({},{__mode="k"})
local failCache=false
package.loaded['Mortis/Runtime/Components']={
 get=function(z)return states[z]end,
 allFor=function(z)return {['Mortis.ZombieHunger']=states[z]}end,
 set=function(z,_,state)
  if failCache then local mode=failCache;failCache=false;if mode=='after'then states[z]=state end;error('cache failure')end
  states[z]=state;return state
 end,
}
package.loaded['Mortis/Core/Logger']={rateLimited=function()end,once=function()end}
package.loaded['Mortis/Core/Profiler']={measure=function(_,fn)return fn()end}
package.loaded['Mortis/Core/Random']={next=function()return .5 end}
local multiplier=1
package.loaded['Mortis/Runtime/SystemSettings']={bool=function()return true end,
 number=function(key)if key=='FoodValueMultiplier'then return multiplier elseif key=='HungerDaysToFull'then return 7 end;return 0 end}
CharacterStat={HUNGER='HUNGER'}
getGameTime=function()return {getWorldAgeHours=function()return 100 end}end
local Sources=require 'Mortis/API/FoodSources'
local Faults=require 'Mortis/Core/FaultIsolation'
local Hunger=require 'Mortis/Runtime/ZombieHungerRuntime'
local events=0
Mortis={Events={emit=function(_,name,z,before,after,metadata)
 assert(name=='ZombieFed' and before==.8 and math.abs(after-.55)<.00001)
 assert(metadata.sourceId=='shared-food' and metadata.sourceClass=='registered-food-source')
 assert(metadata.source.remaining==2 and not metadata.source.held,'notify only after source commit')
 assert(states[z].hunger==after and z.level==after)
 events=events+1
end}}
local serial=0
local function fixture(options)
 options=options or {};serial=serial+1;Sources.registry.entries={};Faults.resetAll()
 local food={remaining=3,held=false,reserves=0,commits=0,rollbacks=0}
 local z={level=.8,x=0,y=0,z=0}
 local stats={get=function()return z.level end,set=function(_,_,v)
   if options.ignore then return end
   if options.partial then z.level=v;error('setter threw after writing')end
   if options.failRestore and v==.8 then return end
   if options.rounded then v=math.floor(v*100000+.5)/100000 end
   z.level=v
 end}
 function z:getStats()return stats end
 function z:getTarget()return self.target end
 function z:getX()return self.x end;function z:getY()return self.y end;function z:getZ()return self.z end
 states[z]={hunger=.8,hungerBackend=Hunger.BACKEND,lastWorldAgeHours=100,
  desiccation=.2,lastFedWorldAgeHours=90}
 local provider={id='Test.Food'..serial,transactionVersion=1,
  findNearby=function()return {x=0,y=0,z=0,sourceId='shared-food',source=food}end,
  reserve=function(_,_,tx)
   food.reserves=food.reserves+1
   if food.held or food.remaining==0 then return {reserved=false}end
   food.held=true;tx.held=true
   if options.reserveError then error('reserve failed after lease')end
   if options.quoteError then return setmetatable({reserved=true},{__index=function()error('invalid lazy quote')end})end
   if options.reenter then
    assert(Hunger.updateFoodSeeking(z)==false);assert(Hunger.feed(z,.2)==false)
    assert(Hunger.advance(z)==false);assert(Hunger.setTestState(z,0,0)==false)
    assert(Hunger.applyTerminalWithering(z)==false)
   end
   return {reserved=true,foodValue=options.value or .25}
  end,
  commit=function(_,_,tx)
   food.commits=food.commits+1
   assert(math.abs(Hunger.getLevel(z)-.8)<.00001,'callbacks observe pre-transaction hunger')
   if options.reject then return false end
   food.remaining=food.remaining-1;tx.removed=true;food.held=false
   if options.commitError then error('commit failed after mutation')end
   if options.partialReject then return false end
   return true
  end,
  rollback=function(_,_,tx)
   food.rollbacks=food.rollbacks+1
   if options.rollbackError then error('rollback unavailable')end
   if tx.removed then food.remaining=food.remaining+1;tx.removed=false end
   if tx.held then food.held=false;tx.held=false end
   return true
  end}
 Sources.register(provider)
 return z,food,provider
end
local function unchanged(z,food)
 assert(z.level==.8 and states[z].hunger==.8)
 assert(states[z].lastFedWorldAgeHours==90 and states[z].desiccation==.2)
 assert(food.remaining==3 and not food.held)
end

local z,food=fixture({ignore=true})
assert(Hunger.updateFoodSeeking(z)==false)
assert(food.commits==0,'failed feed must not commit food removal')
unchanged(z,food);assert(events==0)

for _,options in ipairs({{reserveError=true},{quoteError=true},{reject=true},{commitError=true},{partialReject=true},{partial=true}})do
 z,food=fixture(options);assert(Hunger.updateFoodSeeking(z)==false)
 unchanged(z,food);assert(food.rollbacks==1 and events==0)
end
z,food=fixture();failCache=true
assert(Hunger.updateFoodSeeking(z)==false);unchanged(z,food);assert(food.commits==0)
z,food=fixture();failCache='after'
assert(Hunger.updateFoodSeeking(z)==false);unchanged(z,food);assert(food.commits==0)
local provider
z,food,provider=fixture({reject=true})
Faults.failures['food-source:'..provider.id..':rollback']={count=3,disabled=true}
assert(Hunger.updateFoodSeeking(z)==false);unchanged(z,food);assert(food.rollbacks==1)
z,food=fixture()
local dispatch=Faults.call
Faults.call=function(owner,name,...)if name=='commit'then error('dispatcher failed')end;return dispatch(owner,name,...)end
assert(Hunger.updateFoodSeeking(z)==false);unchanged(z,food);Faults.call=dispatch
z,food=fixture({ignore=true});states[z].lastWorldAgeHours=0
assert(Hunger.updateFoodSeeking(z)==false and food.reserves==0,'failed advancement must stop before reservation')

for _,bad in ipairs({0,-1,math.huge,0/0,1e-300,'0.25'})do
 z,food=fixture({value=bad});assert(Hunger.updateFoodSeeking(z)==false);unchanged(z,food)
 assert(food.commits==0 and events==0)
end
z,food=fixture({value=1e-8,rounded=true})
assert(Hunger.updateFoodSeeking(z)==false and food.commits==0,'native rounding must not consume food for no relief')
unchanged(z,food)
for _,bad in ipairs({-1,math.huge,0/0,'invalid'})do
 z,food,provider=fixture()
 Sources.registry.entries[provider.id].findNearby=function()return {x=0,y=0,z=0,consumeDistance=bad}end
 assert(Hunger.updateFoodSeeking(z)==false and food.reserves==0,'invalid consume distance must not reserve')
 unchanged(z,food)
end
z,food=fixture();multiplier=0
assert(Hunger.updateFoodSeeking(z)==false);unchanged(z,food);assert(food.reserves==0);multiplier=1
z,food=fixture();z.target={}
assert(Hunger.updateFoodSeeking(z)==false and food.reserves==0);z.target=nil
local getTarget=z.getTarget
z.getTarget=function()error('target unavailable')end
assert(Hunger.updateFoodSeeking(z)==false and food.reserves==0,'unknown vanilla targeting must fail closed')
z.getTarget=getTarget
authority=false;assert(Hunger.updateFoodSeeking(z)==false and food.reserves==0);authority=true

z,food=fixture({reenter=true})
assert(Hunger.updateFoodSeeking(z)==true)
assert(food.remaining==2 and food.commits==1 and food.rollbacks==0 and not food.held)
assert(math.abs(z.level-.55)<.00001 and states[z].hunger==z.level and events==1)

z,food,provider=fixture()
local other={level=.8,getX=function()return 0 end,getY=function()return 0 end,getZ=function()return 0 end,getTarget=function()return nil end}
function other:getStats()return {get=function()return self.level end,set=function(_,_,v)self.level=v end}end
states[other]={hunger=.8,hungerBackend=Hunger.BACKEND,lastWorldAgeHours=100,desiccation=0}
local reserve=provider.reserve
Sources.registry.entries[provider.id].reserve=function(actor,candidate,tx)
 local quote=reserve(actor,candidate,tx)
 if actor==z and quote.reserved then
  assert(Hunger.updateFoodSeeking(other)==false and food.held,'another zombie cannot steal this reservation')
 end
 return quote
end
assert(Hunger.updateFoodSeeking(z)==true)
assert(food.remaining==2 and food.commits==1 and other.level==.8)

z,food=fixture();Mortis.Events.emit=function()error('observer failed')end
assert(Hunger.updateFoodSeeking(z)==true and food.remaining==2 and food.rollbacks==0)
Mortis.Events.emit=function()events=events+1 end

z,food=fixture({reject=true,rollbackError=true})
local accepted,why=Hunger.updateFoodSeeking(z)
assert(accepted==false and why=='food-transaction-rollback-failed')
local reserves=food.reserves
assert(Hunger.updateFoodSeeking(z)==false and food.reserves==reserves,'quarantined provider must not retry')
assert(Hunger.feed(z,.1)==false,'unresolved zombie transaction must remain blocked')

-- Quarantine is provider-wide, but must not poison other zombies' discovery.
local healthy={level=.8,x=0,y=0,z=0,getX=z.getX,getY=z.getY,getZ=z.getZ,getTarget=z.getTarget}
function healthy:getStats()return {get=function()return self.level end,set=function(_,_,v)self.level=v end}end
states[healthy]={hunger=.8,hungerBackend=Hunger.BACKEND,lastWorldAgeHours=100,desiccation=0}
local healthyCommits=0
Sources.register({id='Healthy.AfterQuarantine',priority=-1,transactionVersion=1,
 findNearby=function()return {x=0,y=0,z=0}end,
 reserve=function()return {reserved=true,foodValue=.25}end,
 commit=function()healthyCommits=healthyCommits+1;return true end,
 rollback=function()return true end})
assert(Hunger.updateFoodSeeking(healthy)==true and healthyCommits==1,
 'quarantined provider must not starve a healthy provider on another zombie')

z,food=fixture({reject=true,failRestore=true})
accepted,why=Hunger.updateFoodSeeking(z)
assert(accepted==false and why=='food-transaction-rollback-failed' and food.remaining==3)
assert(Hunger.feed(z,.1)==false)

local consumed=0
z=fixture({ignore=true}) -- A failed native feed must never reach legacy consume.
Sources.registry.entries={}
Sources.register({id='Legacy',findNearby=function()return {x=0,y=0,z=0}end,
 consume=function()consumed=consumed+1;return {consumed=true,foodValue=.25}end})
accepted,why=Hunger.updateFoodSeeking(z)
assert(accepted==false and why=='food-source-transaction-required' and consumed==0 and z.level==.8)
assert(not pcall(Sources.register,{id='Incomplete',findNearby=function()end,reserve=function()end}))
assert(Sources.TRANSACTION_VERSION==1)
print('Food transactions preserve resources on failure, isolate observers and block unsafe legacy consumption')
