local Locomotion = require "Mortis/Runtime/Adapters/LocomotionAdapter"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"
local Authority = require "Mortis/Runtime/Authority"
local State = require "Mortis/Runtime/Adapters/StateAdapter"
local Baseline = require "Mortis/Runtime/LocomotionBaseline"
local Store = require "Mortis/Runtime/LocomotionOverrideStore"

local Overrides = {}
local state = setmetatable({}, { __mode="k" })
local rank={shambler=1,fastShambler=2,sprinter=3}
local tiers={"shambler","fastShambler","sprinter"}

local categories={sprinter=1,fastShambler=2,shambler=3}
local admitted
local function recordFor(zombie,recovery)
    local record=state[zombie]
    if record then
        if record.failed and not recovery then return nil,"override recovery required; coordinated clear needed" end
        return record
    end
    local saved,err=Store.read(zombie)
    if err then return nil,err end
    if saved~=nil then
        if not recovery then return nil,"override owner stack lost; coordinated clear needed" end
        if type(saved)~="table" or saved.version~=1 then return nil,"invalid saved override journal" end
        record={baseline=saved.baseline,requests={},ceilings={},checkpointed=true,failed=true}
    else
        if recovery then return nil end
        local allowed,admissionError=admitted(zombie)
        if not allowed then return nil,admissionError end
        local original,reason=Baseline.capture(zombie)
        if not original then return nil,reason end
        record={baseline=original,requests={},ceilings={}}
    end
    state[zombie]=record
    return record
end

admitted=function(zombie)
    local key=State.getNativeStateKey(zombie)
    if type(key)~="string" or key=="" then return false,"native state unavailable" end
    for _,name in ipairs({"isOnFloor","isGettingUp"}) do
        local ok,value=GameAdapter.call(zombie,name)
        if not ok or type(value)~="boolean" then return false,"native observation unavailable: "..name end
        if value then return false,"native transition busy: "..name end
    end
    local busy,reason=State.isBusy(zombie)
    if busy~=false then return false,"native state busy: "..tostring(reason) end
    return true
end

local function failed(record,reason)
    record.signature=nil;record.failed=true
    return false,reason
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
        local tier=request and request.tier or ({[1]="sprinter",[2]="fastShambler",[3]="shambler"})[record.baseline.speedType]
        if not rank[tier] then return false,"baseline tier unavailable for ceiling" end
        if rank[tier]>limit then owner,request="ceiling",{tier=tiers[limit]} end
    end
    local signature = request and (owner..":"..tostring(request.tier)..":"..tostring(request.walkType)) or "baseline"
    local finalRelease=request==nil and limit==nil
    if record.signature == signature and not record.failed and not finalRelease then return true,"unchanged" end
    local allowed,reason=admitted(zombie)
    if not allowed then return false,reason end
    if not record.checkpointed then
        local saved,err=Store.write(zombie,record.baseline)
        if not saved then return false,err end
        record.checkpointed=true
    end
    -- Do not inherit a previous tier helper's random scalar in a custom walk.
    local restored,err=Baseline.restore(zombie,record.baseline)
    if not restored then return failed(record,err) end
    if request then
        local ok,result
        if request.walkType then ok,result=Locomotion.setWalkType(zombie,request.walkType)
        else ok,result=Locomotion.setTier(zombie,request.tier) end
        if not ok then return failed(record,result) end
        local observed,readError=Baseline.capture(zombie)
        if not observed then return failed(record,readError) end
        if (request.walkType and observed.walkType~=request.walkType)
            or (request.tier and observed.speedType~=categories[request.tier]) then
            return failed(record,"override native readback failed")
        end
    elseif finalRelease then
        local cleared,clearError=Store.clear(zombie)
        if not cleared then return failed(record,clearError) end
        record.checkpointed=false
    end
    record.signature=signature;record.failed=false
    return true,request and "override applied" or "restored observed locomotion fields"
end

function Overrides.acquire(zombie, owner, definition)
    if not Authority.canWriteCanonicalState(zombie) then return false,"non-authority" end
    if not zombie then return false,"zombie required" end
    if type(owner)~="string" or owner=="" then return false,"owner required" end
    definition=definition or {}
    if type(definition)~="table" then return false,"override definition must be a table" end
    if definition.walkType~=nil then
        if type(definition.walkType)~="string" or definition.walkType=="" then return false,"valid walkType required" end
    elseif not rank[definition.tier] then return false,"known tier or walkType required" end
    local priority=definition.priority==nil and 0 or tonumber(definition.priority)
    if not priority or priority~=priority or math.abs(priority)==math.huge then return false,"finite priority required" end
    local record,err=recordFor(zombie)
    if not record then return false,err end
    local previous=record.requests[owner]
    record.requests[owner]={tier=definition.walkType==nil and definition.tier or nil,walkType=definition.walkType,priority=priority}
    local ok,reason=apply(zombie,record)
    if not ok then record.requests[owner]=previous end
    return ok,reason
end

function Overrides.release(zombie, owner)
    if not Authority.canWriteCanonicalState(zombie) then return false,"non-authority" end
    if not zombie then return false,"zombie required" end
    if type(owner)~="string" or owner=="" then return false,"owner required" end
    local record=state[zombie]
    if not record then
        local saved,err=Store.read(zombie)
        if err or saved~=nil then return false,err or "override owner stack lost; coordinated clear needed" end
        return true,"not active"
    end
    if record.failed then return false,"override recovery required; coordinated clear needed" end
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
    local record,err=recordFor(zombie,true)
    if not record then return err==nil,err or "not active" end
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
    local record,err=recordFor(zombie)
    if not record then return false,err end
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
    if not record then return Overrides.release(zombie,owner) end
    if record.failed then return false,"override recovery required; coordinated clear needed" end
    local previous=record.ceilings[owner]
    record.ceilings[owner]=nil
    local ok,reason=apply(zombie,record)
    if not ok then record.ceilings[owner]=previous end
    if ok and not effective(record) and not ceiling(record) then state[zombie]=nil end
    return ok,reason
end

return Overrides
