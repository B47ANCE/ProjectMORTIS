local mocks={
 ["Mortis/Runtime/Adapters/GameAdapter"]={call=function(o,m)local f=o and o[m];if type(f)~="function"then return false end;return true,f(o)end},
 ["Mortis/API/PileSupportProfiles"]={classify=function(o)
   if o.support then return true,{height=o.height or .5,stability=o.stability or .8,profileId="test"}end
   return false,"unknown"
 end},
 ["Mortis/Runtime/PileModel"]={MAX_CONTRIBUTORS=64,evaluate=function(o)
   if o.mode=="COMMANDED"and(not o.commanded or not o.orderId)then return false,"commanded pile requires explicit order authority"end
   return true,{effectiveHeight=(o.support and o.support.height or 0)+#o.contributors}
 end},
}
local realRequire=require;require=function(n)return mocks[n]or realRequire(n)end
local Runtime=dofile(arg[1])
local function entity(x,y,z)local e={};function e:getX()return x end;function e:getY()return y end;function e:getZ()return z end;return e end
local near=entity(10.2,10.1,0)
local far=entity(20,20,0)
local support=entity(10,10,0);support.support=true;support.height=.6
local unknown=entity(10,10,0)
local ok,result=Runtime.build({center={x=10,y=10,z=0},radius=1,contributors={
 {entity=near,mass=75,footprintArea=.5,thickness=.3,posture="prone",living=true},
 {entity=far,mass=75,footprintArea=.5,thickness=.3},
 {entity=near,mass=0,footprintArea=.5,thickness=.3},
},supportObjects={support,unknown},regionArea=1})
assert(ok and result.observedContributors==1 and result.observedSupport.profileId=="test")
assert(result.rejected.outOfRegion==1 and result.rejected.malformed==1 and result.rejected.unclassifiedSupport==1)
assert(result.center.x==10 and result.radius==1)
ok,result=Runtime.build({center={x=10,y=10,z=0},radius=1,mode="COMMANDED",contributors={}})
assert(not ok,"observer must preserve explicit commanded-mode gate")
assert(not Runtime.build({center={x=0,y=0,z=0},radius=Runtime.MAX_RADIUS+1}),"radius must be bounded")
local tooMany={};for i=1,Runtime.MAX_SUPPORTS+1 do tooMany[i]=near end
assert(not Runtime.build({center={x=10,y=10,z=0},supportObjects=tooMany}),"support observations must be capped")
print("M.O.R.T.I.S. bounded local pile observation checks passed")
