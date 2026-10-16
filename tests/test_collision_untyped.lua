local emitted=0
local mocks={
    ["Mortis/API/CollisionProfiles"]={get=function() return {id="default",enabled=true,radius=0.4,cooldownTicks=1,minRelativeSpeed=0,trip={enabled=false}} end},
    ["Mortis/Runtime/Adapters/CollisionAdapter"]={
        position=function(z) return z.x,z.y,0 end,
        makeContext=function() return {relativeSpeed=0,penetration=0.1,normalX=1,normalY=0,velocityA={speed=0},velocityB={speed=0}} end,
    },
    ["Mortis/Runtime/BalanceRuntime"]={Causes={COLLISION="collision"},attempt=function() return false end},
    ["Mortis/Runtime/Adapters/StateAdapter"]={},
    ["Mortis/Runtime/Identity"]={getType=function() return nil end,getTypeId=function() return nil end,getStableId=function() return nil end},
    ["Mortis/Core/Random"]={},
    ["Mortis/Core/Scheduler"]={frame=20},
    ["Mortis/Core/FaultIsolation"]={call=function(_,_,fn,...) return true,fn(...) end},
    ["Mortis/API/Behaviors"]={get=function() return nil end},
    ["Mortis/API/Traits"]={get=function() return nil end},
    ["Mortis/Runtime/Context"]={create=function(z,typeDef) return {zombie=z,type=typeDef} end},
    ["Mortis/Runtime/WallSafeSeparationRuntime"]={resolvePair=function() return true end},
    ["Mortis/Core/Util"]={deepCopy=function(value) local copy={} for k,v in pairs(value) do copy[k]=v end return copy end},
}

local realRequire=require
require=function(name) return mocks[name] or realRequire(name) end
Mortis={Events={emit=function() emitted=emitted+1 end}}

local Runtime=dofile(arg[1])
local a={x=10.0,y=10.0}
local b={x=10.1,y=10.0}
local count=Runtime.update({a,b})
assert(count==1,"expected one untyped collision pair")
assert(emitted==2,"expected symmetric collision events")

print("MORTIS untyped collision regression checks passed")
