local Authority=require "Mortis/Runtime/Authority"
local Components=require "Mortis/Runtime/Components"

-- Generic, bounded memory for evidence associated with observed world
-- locations. Consumers define the evidence meaning and thresholds; M.O.R.T.I.S.
-- owns persistence, merging, caps, and authority.
local Memory={}
local COMPONENT="Mortis.LocationMemory"

local function finite(value)
    value=tonumber(value)
    return value and value==value and value~=math.huge and value~=-math.huge and value or nil
end

local function state(entity)
    local value=Components.get(entity,COMPONENT)
    if type(value)~="table" then value={} end
    value.records=type(value.records)=="table" and value.records or {}
    value.order=type(value.order)=="table" and value.order or {}
    return value
end

local function point(value)
    if type(value)~="table" then return nil end
    local x,y,z=finite(value.x),finite(value.y),finite(value.z) or 0
    if not x or not y then return nil end
    return{x=x,y=y,z=z}
end

local function keyFor(location,mergeRadius)
    local size=math.max(1,finite(mergeRadius)or 8)
    return table.concat({math.floor(location.x/size),math.floor(location.y/size),math.floor(location.z)},":")
end

function Memory.observe(entity,evidenceKind,location,strength,worldAgeHours,options)
    if not entity or not Authority.canWriteCanonicalState(entity) then return nil,"location memory requires server authority" end
    if type(evidenceKind)~="string" or evidenceKind=="" then return nil,"evidence kind is required" end
    location=point(location);strength=finite(strength);worldAgeHours=finite(worldAgeHours)
    if not location or not strength or strength<=0 then return nil,"invalid location evidence" end
    options=type(options)=="table" and options or {}
    local value=state(entity);local key=keyFor(location,options.mergeRadius)
    local record=value.records[key]
    if not record then
        record={key=key,x=location.x,y=location.y,z=location.z,score=0,observations=0,evidence={}}
        value.records[key]=record;value.order[#value.order+1]=key
    end
    record.score=math.max(0,(finite(record.score)or 0)+strength)
    record.observations=math.max(0,math.floor(finite(record.observations)or 0))+1
    record.lastObservedWorldAgeHours=worldAgeHours
    record.evidence=type(record.evidence)=="table" and record.evidence or {}
    local kind=evidenceKind:sub(1,64);record.evidence[kind]=(finite(record.evidence[kind])or 0)+strength
    -- Keep the point centered on the newest real observation. The bucket is
    -- only an index and never invents a structure coordinate.
    record.x,record.y,record.z=location.x,location.y,location.z
    local cap=math.max(1,math.floor(finite(options.maxRecords)or 32))
    while #value.order>cap do local removed=table.remove(value.order,1);value.records[removed]=nil end
    Components.set(entity,COMPONENT,value)
    return record
end

function Memory.list(entity,options)
    options=type(options)=="table" and options or {}
    local value=state(entity);local result={};local now=finite(options.worldAgeHours)
    local maxAge=finite(options.maxAgeHours)
    for _,key in ipairs(value.order) do
        local record=value.records[key]
        local age=record and now and finite(record.lastObservedWorldAgeHours) and now-record.lastObservedWorldAgeHours or 0
        if record and (not maxAge or not now or age<=maxAge) then result[#result+1]=record end
    end
    table.sort(result,function(a,b)
        if a.score~=b.score then return a.score>b.score end
        return tostring(a.key)<tostring(b.key)
    end)
    return result
end

function Memory.best(entity,minimumScore,options)
    local threshold=math.max(0,finite(minimumScore)or 0)
    for _,record in ipairs(Memory.list(entity,options)) do if (finite(record.score)or 0)>=threshold then return record end end
    return nil
end

function Memory.get(entity,key,options)
    if type(key)~="string" then return nil end
    options=type(options)=="table" and options or {}
    local record=state(entity).records[key]
    if not record then return nil end
    local now,maxAge=finite(options.worldAgeHours),finite(options.maxAgeHours)
    local observed=finite(record.lastObservedWorldAgeHours)
    if now and maxAge and observed and now-observed>maxAge then return nil end
    return record
end

Memory.COMPONENT=COMPONENT
return Memory
