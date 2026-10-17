local Sources = require 'Mortis/API/FoodSources'
local Hunger = require 'Mortis/Runtime/ZombieHungerRuntime'
local zombie = {getX=function()return 0 end,getY=function()return 0 end,getZ=function()return 0 end}
local function discover(candidate, actor)
 Sources.registry.entries={}
 Sources.register({id='Broken',priority=100,findNearby=function()return candidate end})
 Sources.register({id='Healthy',findNearby=function()return {x=1,y=0,z=0}end})
 local ok,found,provider=pcall(Hunger.findNearby,actor or zombie,12)
 assert(ok,'malformed provider output must not escape discovery')
 return found,provider
end
for _,candidate in ipairs({{source=7},{x=0,y=0,z=0/0},{x=0,y=0,z=math.huge},
 {x=0,y=0,priority=0/0},{x=0,y=0,priority=math.huge},
 {source={getX=function()return 0 end,getY=function()return nil end}},
 {source={getX=function()return 0 end,getY=function()return 0 end,getZ=function()return nil end}},
 {source=setmetatable({},{__index=function()error('unreadable source')end})}})do
 local _,provider=discover(candidate)
 assert(provider and provider.id=='Healthy','invalid candidate must not hide a healthy provider')
end
local candidate,provider=discover({x=0,y=0}, {getX=function()return nil end,getY=function()return 0 end,getZ=function()return 0 end})
assert(candidate==nil and provider==nil,'unavailable native coordinates must not throw or select food')
Sources.registry.entries={}
local observedRadius
Sources.register({id='Range',findNearby=function(_,radius)observedRadius=radius;return {x=1,y=0,z=0}end})
Hunger.findNearby(zombie,math.huge);assert(observedRadius==12,'nonfinite search radius must not reach providers')
assert(not pcall(Sources.register,{id='Priority',priority=math.huge,findNearby=function()end}),
 'provider priority must be finite')
Sources.registry.entries={}
Sources.register({id='B.Tie',findNearby=function()return {x=1,y=0,z=0}end})
Sources.register({id='A.Tie',findNearby=function()return {x=1,y=0,z=0}end})
local _,winner=Hunger.findNearby(zombie,12)
assert(winner.id=='A.Tie','equal scores need deterministic provider precedence')
Sources.registry.entries={}
Sources.register({id='Native.Position',findNearby=function()return {source=zombie}end})
local native=Hunger.findNearby(zombie,12)
assert(native and native.source==zombie,'valid source getters remain supported')
print('Malformed food discovery cannot crash or poison healthy source selection')
