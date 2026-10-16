local Adapter = require "Mortis/Runtime/Adapters/CrowdFlowAdapter"
local Navigation = require "Mortis/Runtime/Adapters/NavigationAdapter"

local CrowdFlow = {}

local function distanceSq(ax,ay,bx,by)
    local dx,dy=ax-bx,ay-by
    return dx*dx+dy*dy
end

-- Finds a low-occupancy square deeper inside the entity's current building.
-- This is deliberately a bounded loaded-square query; callers own the reason
-- for movement (UV sheltering, panic flow, scripted evacuation, and so on).
function CrowdFlow.findDeeperInterior(entity,options)
    options=type(options)=="table" and options or {}
    if not entity then return nil,"missing entity" end
    local current=Adapter.square(entity)
    if not current or not Adapter.isInterior(current) then return nil,"entity is not inside" end
    local cx,cy,cz=Adapter.position(current)
    if not cx then return nil,"square position unavailable" end

    local entry=options.entrySquare or current
    local ex,ey,ez=Adapter.position(entry)
    if not ex or ez~=cz then ex,ey,ez=cx,cy,cz end
    local cell=Adapter.cell(current)
    if not cell then return nil,"cell unavailable" end
    local building=options.building or Adapter.building(current)
    local radius=math.max(1,math.floor(tonumber(options.radius) or 6))
    local minimumDepthGain=math.max(0,tonumber(options.minimumDepthGain) or 1.5)
    local maximumOccupancy=math.max(0,math.floor(tonumber(options.maximumOccupancy) or 1))
    local currentDepth=math.sqrt(distanceSq(cx,cy,ex,ey))
    local best,bestScore=nil,-math.huge

    for dy=-radius,radius do
        for dx=-radius,radius do
            if dx*dx+dy*dy<=radius*radius then
                local square=Adapter.gridSquare(cell,math.floor(cx)+dx,math.floor(cy)+dy,math.floor(cz))
                if square and Adapter.isInterior(square) and Adapter.canStand(square)~=false then
                    local candidateBuilding=Adapter.building(square)
                    local sameBuilding=(not building) or candidateBuilding==building
                    if sameBuilding then
                        local sx,sy=Adapter.position(square)
                        local depth=sx and math.sqrt(distanceSq(sx,sy,ex,ey)) or 0
                        local occupancy=Adapter.occupancy(square,entity)
                        if depth>=currentDepth+minimumDepthGain and occupancy<=maximumOccupancy then
                            local travel=math.sqrt(distanceSq(sx,sy,cx,cy))
                            local score=(depth*5.0)-(travel*0.75)-(occupancy*12.0)
                            if score>bestScore then best,bestScore=square,score end
                        end
                    end
                end
            end
        end
    end
    return best,best and nil or "no deeper interior square"
end

function CrowdFlow.pathDeeperInterior(entity,options)
    local square,reason=CrowdFlow.findDeeperInterior(entity,options)
    if not square then return false,reason end
    local x,y,z=Adapter.position(square)
    local ok,why=Navigation.pathToLocation(entity,x+0.5,y+0.5,z)
    return ok,why,square
end

return CrowdFlow
