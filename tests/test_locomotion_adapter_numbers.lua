package.loaded["Mortis/API/Capabilities"]={has=function() return true end}
local calls=0
package.loaded["Mortis/Runtime/Adapters/GameAdapter"]={call=function(_,method,value)
    calls=calls+1
    assert(method=="DoZombieSpeeds" and value==.5)
    return true
end}
local Adapter=require "Mortis/Runtime/Adapters/LocomotionAdapter"
for _,value in ipairs({0,-1,math.huge,-math.huge,0/0,"invalid"}) do
    assert(not Adapter.setSpeedMultiplier({},value))
end
assert(calls==0,"invalid speed must never reach native animation state")
assert(Adapter.setSpeedMultiplier({},.5) and calls==1)
print("MORTIS native locomotion numeric-boundary checks passed")
