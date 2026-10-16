local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"
local Supports = require "Mortis/API/PileSupportProfiles"
local Piles = require "Mortis/Runtime/PileModel"

local Runtime = { MAX_RADIUS=4, MAX_SUPPORTS=16 }

local function finite(value)
    value=tonumber(value)
    return value and value==value and value~=math.huge and value~=-math.huge and value or nil
end

local function position(object)
    if not object then return nil end
    local okX,x=GameAdapter.call(object,"getX")
    local okY,y=GameAdapter.call(object,"getY")
    local okZ,z=GameAdapter.call(object,"getZ")
    x,y,z=finite(x),finite(y),finite(z)
    if not(okX and okY and okZ and x and y and z)then return nil end
    return x,y,z
end

local function localTo(center,radius,object)
    local x,y,z=position(object)
    if not x then return false end
    return math.abs(z-center.z)<0.51 and math.abs(x-center.x)<=radius and math.abs(y-center.y)<=radius
end

function Runtime.build(request)
    if type(request)~="table"then return false,"request must be a table"end
    local center=request.center
    if type(center)~="table"then return false,"center must be a table"end
    center={x=finite(center.x),y=finite(center.y),z=finite(center.z)}
    if not(center.x and center.y and center.z)then return false,"center must contain finite coordinates"end
    local radius=finite(request.radius)or 1
    if radius<0 or radius>Runtime.MAX_RADIUS then return false,"radius out of bounds"end
    local candidates=request.contributors or {}
    local supportObjects=request.supportObjects or {}
    if type(candidates)~="table"or type(supportObjects)~="table"then return false,"candidate lists must be tables"end
    if #candidates>Piles.MAX_CONTRIBUTORS then return false,"contributor limit exceeded"end
    if #supportObjects>Runtime.MAX_SUPPORTS then return false,"support limit exceeded"end

    local contributors={}
    local rejected={malformed=0,outOfRegion=0,unclassifiedSupport=0}
    for _,candidate in ipairs(candidates)do
        if type(candidate)~="table"or candidate.entity==nil then
            rejected.malformed=rejected.malformed+1
        elseif not localTo(center,radius,candidate.entity)then
            rejected.outOfRegion=rejected.outOfRegion+1
        else
            local mass=finite(candidate.mass)
            local area=finite(candidate.footprintArea)
            local thickness=finite(candidate.thickness)
            if not mass or mass<=0 or not area or area<=0 or not thickness or thickness<=0 then
                rejected.malformed=rejected.malformed+1
            else
                contributors[#contributors+1]={
                    mass=mass,footprintArea=area,thickness=thickness,
                    posture=candidate.posture,living=candidate.living==true,
                }
            end
        end
    end

    local support=nil
    for _,object in ipairs(supportObjects)do
        if not localTo(center,radius,object)then
            rejected.outOfRegion=rejected.outOfRegion+1
        else
            local ok,profile=Supports.classify(object,{center=center,radius=radius})
            if ok then
                if not support or profile.height>support.height then support=profile end
            else rejected.unclassifiedSupport=rejected.unclassifiedSupport+1 end
        end
    end

    local observation={
        mode=request.mode,commanded=request.commanded,orderId=request.orderId,
        regionArea=request.regionArea,minimumStability=request.minimumStability,
        contributors=contributors,
        support=support and {height=support.height,stability=support.stability}or nil,
    }
    local ok,result=Piles.evaluate(observation)
    if not ok then return false,result end
    result.observedContributors=#contributors
    result.observedSupport=support
    result.rejected=rejected
    result.center=center
    result.radius=radius
    return true,result
end

return Runtime
