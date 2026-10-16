isClient=function()return true end
isServer=function()return false end
local state=nil
local writes=0
package.loaded['Mortis/Runtime/Components']={
 allFor=function()return state and {['Mortis.ZombieHunger']=state} or nil end,
 get=function()error('client observation must not initialize defaults')end,
 set=function()error('client observation must not persist')end,
}
package.loaded['Mortis/Core/Random']={next=function()error('client must not initialize hunger')end}
CharacterStat={HUNGER='HUNGER'}
local zombie={getStats=function()return{get=function()return 0.9 end,set=function()writes=writes+1 end}end}
local Hunger=require 'Mortis/Runtime/ZombieHungerRuntime'
assert(Hunger.getLevel(zombie)==0.9)
assert(writes==0 and state==nil)
state={hunger=0.7,hungerBackend='legacy',desiccation=0.2,lastWorldAgeHours=10}
local observed=Hunger.get(zombie)
observed.hunger=0.1
assert(state.hunger==0.7 and state.hungerBackend=='legacy' and writes==0)
assert(Hunger.advance(zombie)==false and Hunger.feed(zombie,0.1)==false)
assert(Hunger.getDesiccation(zombie)==0.2 and writes==0)
print('Client hunger reads remain detached and read-only')
