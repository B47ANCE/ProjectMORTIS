local function square(x,y,inside,building,occupancy)
    return {x=x,y=y,z=0,inside=inside,building=building,occupancy=occupancy or 0}
end

local house={}
local current=square(0,0,true,house,0)
local entry=square(0,0,true,house,0)
local crowded=square(4,0,true,house,3)
local openDeep=square(3,2,true,house,0)
local outside=square(5,0,false,nil,0)
local grid={['0,0']=current,['4,0']=crowded,['3,2']=openDeep,['5,0']=outside}
local entity={square=current}
local pathTarget=nil

local adapter={
    square=function(e) return e.square end,
    position=function(s) return s.x,s.y,s.z end,
    cell=function() return grid end,
    gridSquare=function(cell,x,y) return cell[tostring(x)..','..tostring(y)] end,
    isInterior=function(s) return s.inside end,
    canStand=function() return true end,
    building=function(s) return s.building end,
    occupancy=function(s) return s.occupancy end,
}
local navigation={pathToLocation=function(_,x,y,z) pathTarget={x=x,y=y,z=z}; return true end}
local realRequire=require
require=function(name)
    if name=='Mortis/Runtime/Adapters/CrowdFlowAdapter' then return adapter end
    if name=='Mortis/Runtime/Adapters/NavigationAdapter' then return navigation end
    return realRequire(name)
end

local CrowdFlow=dofile(arg[1])
local chosen=assert(CrowdFlow.findDeeperInterior(entity,{entrySquare=entry,radius=6,maximumOccupancy=1}))
assert(chosen==openDeep,'flow must prefer an open deeper square over a crowded doorway lane')
local ok=assert(CrowdFlow.pathDeeperInterior(entity,{entrySquare=entry,radius=6,maximumOccupancy=1}))
assert(ok and pathTarget and pathTarget.x==3.5 and pathTarget.y==2.5,'flow must path through the MORTIS navigation boundary')
print('MORTIS deeper-interior crowd-flow checks passed')
