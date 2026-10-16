local authority=true
package.loaded["Mortis/Runtime/Authority"]={canWriteCanonicalState=function() return authority end}
package.loaded["Mortis/API/Species"]={get=function() return {regions={head={critical=true},arm={}}} end}
local data={MORTIS_LIVING={anatomy={schemaVersion=1,speciesId="Test",regions={head={attached=true},arm={destroyed=true}}}}}
local kind="infected"
package.loaded["Mortis/Runtime/Adapters/EntityAdapter"]={getModData=function() return data end,kind=function() return kind end}
local health,calls=1,0
local ignore=false
package.loaded["Mortis/Runtime/Adapters/CombatAdapter"]={getHealth=function() return health end,
    setHealth=function(_,value) calls=calls+1;if not ignore then health=value end;return true end}
local Systemic=require "Mortis/Runtime/SystemicTrauma"
local policy={allowDeath=true}
assert(Systemic.resolveCriticalFailure({},policy) and calls==0,"noncritical injury cannot kill")
data.MORTIS_LIVING.anatomy.regions.head.destroyed=true
assert(not Systemic.resolveCriticalFailure({},{allowDeath=false}) and calls==0)
authority=false
assert(not Systemic.resolveCriticalFailure({},policy) and calls==0)
authority=true;kind="player"
assert(not Systemic.resolveCriticalFailure({},policy) and calls==0)
kind="infected";ignore=true
assert(not Systemic.resolveCriticalFailure({},policy) and health==1)
ignore=false
assert(Systemic.resolveCriticalFailure({},policy) and health==0)
local before=calls
assert(Systemic.resolveCriticalFailure({},policy) and calls==before,"retries must not repeat native death requests")
data={}
assert(not Systemic.resolveCriticalFailure({},policy))
print("MORTIS policy-gated committed critical-trauma consequences passed")
