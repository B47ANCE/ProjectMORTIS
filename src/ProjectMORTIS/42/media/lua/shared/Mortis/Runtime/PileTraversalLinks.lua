local Links = { MAX_HORIZONTAL_GAP=2, MAX_VERTICAL_DELTA=2 }

local function finite(value)
    value=tonumber(value)
    return value and value==value and value~=math.huge and value~=-math.huge and value or nil
end

local function point(value)
    if type(value)~="table"then return nil end
    local x,y,z=finite(value.x),finite(value.y),finite(value.z)
    if not(x and y and z)then return nil end
    return{x=x,y=y,z=z}
end

local function distance2d(a,b)
    local dx,dy=b.x-a.x,b.y-a.y
    return math.sqrt(dx*dx+dy*dy)
end

local function checkGeometry(pile,from,to,requirements)
    if type(pile)~="table"or pile.traversable~=true then return false,"pile is not traversable"end
    local horizontal=distance2d(from,to)
    local vertical=to.z-from.z
    local maxHorizontal=math.min(Links.MAX_HORIZONTAL_GAP,finite(requirements.maxHorizontalGap)or 1.5)
    local maxVertical=math.min(Links.MAX_VERTICAL_DELTA,finite(requirements.maxVerticalDelta)or 1)
    if horizontal<=0 or horizontal>maxHorizontal then return false,"horizontal gap out of bounds"end
    if vertical<0 or vertical>maxVertical then return false,"vertical delta out of bounds"end
    local minimumStability=finite(requirements.minimumStability)or .35
    if (finite(pile.stability)or 0)<minimumStability then return false,"pile stability too low"end
    local requiredHeight=math.max(0,vertical-(finite(requirements.actorReach)or 0))
    if (finite(pile.effectiveHeight)or 0)<requiredHeight then return false,"pile height insufficient"end
    return true,{horizontalGap=horizontal,verticalDelta=vertical,requiredHeight=requiredHeight}
end

function Links.propose(request)
    if type(request)~="table"then return false,"request must be a table"end
    local id=request.id
    if type(id)~="string"or id==""or #id>96 then return false,"link requires bounded id"end
    local from,to=point(request.from),point(request.to)
    if not(from and to)then return false,"link endpoints must contain finite coordinates"end
    local requirements=type(request.requirements)=="table"and request.requirements or {}
    local ok,geometry=checkGeometry(request.pile,from,to,requirements)
    if not ok then return false,geometry end
    return true,{
        schemaVersion=1,id=id,from=from,to=to,
        pileMode=request.pile.mode,pileOrderId=request.pile.orderId,
        minimumStability=finite(requirements.minimumStability)or .35,
        maxHorizontalGap=math.min(Links.MAX_HORIZONTAL_GAP,finite(requirements.maxHorizontalGap)or 1.5),
        maxVerticalDelta=math.min(Links.MAX_VERTICAL_DELTA,finite(requirements.maxVerticalDelta)or 1),
        actorReach=math.max(0,finite(requirements.actorReach)or 0),
        requiredCapability=type(requirements.requiredCapability)=="string"and requirements.requiredCapability or "pile-traverse",
        geometry=geometry,
        executable=false,
    }
end

-- Revalidation is intentionally pure. Callers must supply the freshly observed
-- pile and an explicit capability set at action completion.
function Links.revalidate(link,currentPile,capabilities,currentFrom,currentTo)
    if type(link)~="table"or link.schemaVersion~=1 then return false,"invalid traversal link"end
    if type(capabilities)~="table"or capabilities[link.requiredCapability]~=true then
        return false,"actor capability unavailable"
    end
    local from=point(currentFrom)or link.from
    local to=point(currentTo)or link.to
    if distance2d(from,link.from)>.25 or math.abs(from.z-link.from.z)>.01 then return false,"entry endpoint changed"end
    if distance2d(to,link.to)>.25 or math.abs(to.z-link.to.z)>.01 then return false,"exit endpoint changed"end
    if link.pileMode=="COMMANDED"and(currentPile.orderId~=link.pileOrderId or currentPile.mode~="COMMANDED")then
        return false,"commanded pile authority changed"
    end
    return checkGeometry(currentPile,from,to,{
        minimumStability=link.minimumStability,maxHorizontalGap=link.maxHorizontalGap,
        maxVerticalDelta=link.maxVerticalDelta,actorReach=link.actorReach,
    })
end

return Links
