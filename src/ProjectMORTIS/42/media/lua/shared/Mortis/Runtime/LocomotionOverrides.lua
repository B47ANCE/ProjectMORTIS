local Locomotion = require "Mortis/Runtime/Adapters/LocomotionAdapter"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"
local Authority = require "Mortis/Runtime/Authority"

local Overrides = {}
local state = setmetatable({}, { __mode="k" })
local rank={shambler=1,fastShambler=2,sprinter=3}
local tiers={"shambler","fastShambler","sprinter"}

local function capture(zombie)
    local ok, value = GameAdapter.call(zombie, "getWalkType")
    return ok and value ~= nil and tostring(value) or nil
end

local function newRecord(zombie)
    local ok,value=GameAdapter.call(zombie,"getSpeedType")
    local tier=ok and ({[1]="sprinter",[2]="fastShambler",[3]="shambler"})[value] or nil
    return {baselineWalkType=capture(zombie),baselineTier=tier,requests={},ceilings={}}
end

local function ceiling(record)
    local limit
    for _,tier in pairs(record.ceilings or {}) do
        if not limit or rank[tier]<limit then limit=rank[tier] end
    end
    return limit
end

local function effective(record)
    local bestOwner,best
    for owner, request in pairs(record.requests) do
        if not best or request.priority > best.priority
            or (request.priority == best.priority and owner < bestOwner) then
            bestOwner,best=owner,request
        end
    end
    return bestOwner,best
end

local function apply(zombie, record)
    local owner, request = effective(record)
    local limit=ceiling(record)
    if limit then
        if request and request.walkType then return false,"cannot safely cap custom walk type" end
        local tier=request and request.tier or record.baselineTier
        if not rank[tier] then return false,"baseline tier unavailable for ceiling" end
        if rank[tier]>limit then owner,request="ceiling",{tier=tiers[limit]} end
    end
    local signature = request and (owner..":"..tostring(request.tier)..":"..tostring(request.walkType)) or "baseline"
    if record.signature == signature then return true,"unchanged" end
    local ok, reason
    if request then
        if request.walkType then ok,reason=Locomotion.setWalkType(zombie,request.walkType)
        else ok,reason=Locomotion.setTier(zombie,request.tier) end
    elseif record.baselineWalkType then
        ok,reason=Locomotion.setWalkType(zombie,record.baselineWalkType)
    else
        return false,"baseline walk type unavailable"
    end
    if ok then record.signature=signature end
    return ok,reason
end

function Overrides.acquire(zombie, owner, definition)
    if not Authority.canWriteCanonicalState(zombie) then return false,"non-authority" end
    if not zombie then return false,"zombie required" end
    if type(owner)~="string" or owner=="" then return false,"owner required" end
    definition=definition or {}
    if type(definition)~="table" then return false,"override definition must be a table" end
    if definition.tier==nil and definition.walkType==nil then return false,"tier or walkType required" end
    local priority=definition.priority==nil and 0 or tonumber(definition.priority)
    if not priority or priority~=priority or math.abs(priority)==math.huge then return false,"finite priority required" end
    local record=state[zombie]
    if not record then
        record=newRecord(zombie)
        state[zombie]=record
    end
    local previous=record.requests[owner]
    record.requests[owner]={tier=definition.tier,walkType=definition.walkType,priority=priority}
    local ok,reason=apply(zombie,record)
    if not ok then record.requests[owner]=previous end
    return ok,reason
end

function Overrides.release(zombie, owner)
    if not Authority.canWriteCanonicalState(zombie) then return false,"non-authority" end
    if not zombie then return false,"zombie required" end
    if type(owner)~="string" or owner=="" then return false,"owner required" end
    local record=state[zombie]
    if not record then return true,"not active" end
    local previous=record.requests[owner]
    record.requests[owner]=nil
    local ok,reason=apply(zombie,record)
    if not ok then record.requests[owner]=previous end
    -- Kahlua's release environment does not consistently expose Lua's global
    -- next(). Reuse the resolver so cleanup has no dependency on that global.
    local remainingOwner=effective(record)
    if remainingOwner==nil and not ceiling(record) and ok then state[zombie]=nil end
    return ok,reason
end

function Overrides.clear(zombie)
    if not Authority.canWriteCanonicalState(zombie) then return false,"non-authority" end
    if not zombie then return false,"zombie required" end
    local record=state[zombie]
    if not record then return true,"not active" end
    local requests,ceilings=record.requests,record.ceilings
    record.requests={}; record.ceilings={}
    local ok,reason=apply(zombie,record)
    if ok then state[zombie]=nil end
    if not ok then record.requests,record.ceilings=requests,ceilings end
    return ok,reason
end

function Overrides.setCeiling(zombie,owner,tier)
    if not Authority.canWriteCanonicalState(zombie) then return false,"non-authority" end
    if not zombie or type(owner)~="string" or owner=="" then return false,"zombie and owner required" end
    if not rank[tier] then return false,"known ceiling tier required" end
    local record=state[zombie] or newRecord(zombie)
    local previous=record.ceilings[owner]
    record.ceilings[owner]=tier
    local ok,reason=apply(zombie,record)
    if ok then state[zombie]=record else record.ceilings[owner]=previous end
    return ok,reason
end

function Overrides.releaseCeiling(zombie,owner)
    if not Authority.canWriteCanonicalState(zombie) then return false,"non-authority" end
    if not zombie or type(owner)~="string" or owner=="" then return false,"zombie and owner required" end
    local record=state[zombie]
    if not record then return true,"not active" end
    local previous=record.ceilings[owner]
    record.ceilings[owner]=nil
    local ok,reason=apply(zombie,record)
    if not ok then record.ceilings[owner]=previous end
    if ok and not effective(record) and not ceiling(record) then state[zombie]=nil end
    return ok,reason
end

return Overrides
