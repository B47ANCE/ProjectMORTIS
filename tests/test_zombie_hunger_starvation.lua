local states = setmetatable({}, { __mode = "k" })
package.loaded["Mortis/Runtime/Authority"] = { canWriteCanonicalState=function() return true end, canRunCanonicalAI=function() return true end }
package.loaded["Mortis/Runtime/Components"] = { get=function(zombie) return states[zombie] end, set=function(zombie,_,value) states[zombie]=value return value end }
package.loaded["Mortis/API/FoodSources"] = { all=function() return {} end }
package.loaded["Mortis/Core/FaultIsolation"] = { call=function(_,_,callback,...) return true,callback(...) end }
package.loaded["Mortis/Core/Random"] = { next=function() return 0.5 end }
package.loaded["Mortis/Runtime/SystemSettings"] = {
    number=function(key) if key=="HungerDaysToFull" then return 7 elseif key=="FoodValueMultiplier" then return 1 elseif key=="DesiccationYearsToTerminal" then return 2 end return 0 end,
    bool=function() return true end,
}
package.loaded["Mortis/Runtime/Adapters/CombatAdapter"]={setHealth=function(zombie,value)zombie.health=value;return true end,getHealth=function(zombie)return zombie.health end}

local age=100
function getGameTime() return {getWorldAgeHours=function() return age end} end
CharacterStat={HUNGER="HUNGER"}
local vanillaHunger=0
local stats={
    get=function(_,stat) assert(stat==CharacterStat.HUNGER) return vanillaHunger end,
    set=function(_,stat,value) assert(stat==CharacterStat.HUNGER) vanillaHunger=value return true end,
}

local Hunger=require "Mortis/Runtime/ZombieHungerRuntime"
local zombie={getStats=function() return stats end}
assert(Hunger.advance(zombie))
assert(math.abs(Hunger.getLevel(zombie)-0.375)<0.0001,"new hunger must initialize within 0-75%")
assert(math.abs(vanillaHunger-0.375)<0.0001,"vanilla CharacterStat.HUNGER must be canonical")
local drive,level=Hunger.getDrive(zombie,0.25)
assert(math.abs(level-0.375)<0.0001 and drive>0 and drive<1,"hunger drive must ramp above its consumer threshold")
assert(states[zombie].hungerBackend==Hunger.BACKEND,"component must record completed vanilla migration")
age=age+4.375*24
assert(Hunger.advance(zombie))
assert(Hunger.getStarvationHours(zombie)==0,"store depletion begins rather than completes starvation")
age=age+7*24
assert(Hunger.advance(zombie))
assert(Hunger.hasStarvedFor(zombie,7))
assert(Hunger.feed(zombie,0.5))
assert(math.abs(vanillaHunger-0.5)<0.0001,"feeding must update vanilla hunger")
assert(Hunger.getStarvationHours(zombie)==0,"feeding must reset continuous starvation")
age=age+3.5*24
assert(Hunger.advance(zombie))
assert(Hunger.getStarvationHours(zombie)==0,"depleting hunger stores is not starvation time")
age=age+7*24
assert(Hunger.advance(zombie))
assert(Hunger.hasStarvedFor(zombie,7),"seven days after store depletion should qualify")
assert(Hunger.setTestState(zombie,1,1))
assert(math.abs(Hunger.getStarvationHours(zombie)-1)<0.0001,"test state must preserve accelerated starvation hours")

Mortis={Events={emit=function() error("optional consumer failed") end}}
assert(Hunger.feed(zombie,0.1),"committed feeding must survive observer failure")

local stuckValue=0.75
local stuckStats={
    get=function() return stuckValue end,
    set=function() return true end,
}
local stuckZombie={getStats=function() return stuckStats end}
states[stuckZombie]={hunger=stuckValue,hungerBackend=Hunger.BACKEND,lastWorldAgeHours=age-24,desiccation=0}
local ok,reason=Hunger.advance(stuckZombie)
assert(ok==false and reason=="vanilla-hunger-write-failed")
assert(states[stuckZombie].hunger==stuckValue and states[stuckZombie].lastWorldAgeHours==age-24,
    "failed native advancement must preserve hunger and elapsed-time checkpoint")
ok,reason=Hunger.feed(stuckZombie,0.25)
assert(ok==false and reason=="vanilla-hunger-write-failed" and states[stuckZombie].hunger==stuckValue,
    "failed native feeding must not claim or persist consumption")

local normalized=Hunger.deserializeState({
    hunger=math.huge,desiccation=0/0,lastWorldAgeHours=200,
    starvingSinceWorldAgeHours=250,lastFedWorldAgeHours=-10,
    hungerBackend="untrusted-backend",injectedCallback=function() end,
})
assert(normalized.hunger==-1 and normalized.desiccation==0)
assert(normalized.starvingSinceWorldAgeHours==nil and normalized.lastFedWorldAgeHours==nil)
assert(normalized.hungerBackend==nil and normalized.injectedCallback==nil,
    "persisted hunger must use a validated allow-list")
normalized=Hunger.serializeState({hunger=1,desiccation=0.25,lastWorldAgeHours=200,
    starvingSinceWorldAgeHours=100,lastFedWorldAgeHours=90,hungerBackend=Hunger.BACKEND})
assert(normalized.hunger==1 and normalized.starvingSinceWorldAgeHours==100)
assert(normalized.hungerBackend==Hunger.BACKEND)

local terminal={health=1,getStats=function()return stats end};vanillaHunger=1
states[terminal]={hunger=1,hungerBackend=Hunger.BACKEND,lastWorldAgeHours=age,starvingSinceWorldAgeHours=age,desiccation=0}
local terminalEvents=0;Mortis={Events={emit=function(_,name,zombie,payload)assert(name=="ZombieTerminalWithering"and zombie==terminal and payload.desiccation==1);terminalEvents=terminalEvents+1 end}}
age=age+2*365*24;assert(Hunger.advance(terminal));assert(Hunger.getDesiccation(terminal)==1 and Hunger.isTerminallyWithered(terminal));assert(terminal.health==0 and terminalEvents==1 and states[terminal].terminalWitheringApplied)
age=age+24;assert(Hunger.advance(terminal));assert(terminalEvents==1,"terminal event must be emitted once")
normalized=Hunger.serializeState(states[terminal]);assert(normalized.terminalWithering and normalized.terminalEventEmitted and normalized.terminalWitheringApplied)
print("M.O.R.T.I.S. continuous zombie-starvation checks passed")
