local Links=dofile(arg[1])
local pile={mode="INCIDENTAL",effectiveHeight=.8,stability=.7,traversable=true}
local ok,link=Links.propose({id="local:1",from={x=1,y=1,z=0},to={x=2,y=1,z=1},pile=pile,
 requirements={actorReach=.3,requiredCapability="climb-pile"}})
assert(ok and link.executable==false,"links must be proposals, never engine actions")
assert(link.geometry.requiredHeight==.7)
ok=Links.revalidate(link,pile,{["climb-pile"]=true},{x=1,y=1,z=0},{x=2,y=1,z=1})
assert(ok,"unchanged capable traversal should validate")
assert(not Links.revalidate(link,pile,{},nil,nil),"capability is required")
local unstable={mode="INCIDENTAL",effectiveHeight=.8,stability=.1,traversable=true}
assert(not Links.revalidate(link,unstable,{["climb-pile"]=true}),"completion must recheck stability")
local collapsed={mode="INCIDENTAL",effectiveHeight=.1,stability=.7,traversable=true}
assert(not Links.revalidate(link,collapsed,{["climb-pile"]=true}),"completion must recheck height")
assert(not Links.revalidate(link,pile,{["climb-pile"]=true},{x=1.5,y=1,z=0}),"changed entry must invalidate")
assert(not Links.propose({id="far",from={x=0,y=0,z=0},to={x=3,y=0,z=0},pile=pile}),"links must stay local")
assert(not Links.propose({id="up",from={x=0,y=0,z=0},to={x=1,y=0,z=3},pile=pile}),"vertical transitions must be capped")
local commanded={mode="COMMANDED",orderId="alpha:1",effectiveHeight=1,stability=.8,traversable=true}
ok,link=Links.propose({id="cmd",from={x=0,y=0,z=0},to={x=1,y=0,z=1},pile=commanded})
assert(ok)
local changed={mode="COMMANDED",orderId="alpha:2",effectiveHeight=1,stability=.8,traversable=true}
assert(not Links.revalidate(link,changed,{["pile-traverse"]=true}),"command authority must be revalidated")
print("M.O.R.T.I.S. local pile traversal-link checks passed")
