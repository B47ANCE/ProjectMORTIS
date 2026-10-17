-- Pure offline reducer. No native calls, RNG, persistence, networking or registration.
local Choices=dofile('experiments/active-hours/life_choices.lua')
local OWNER='ProjectMORTIS.ActiveHours.Policy' -- proposed owner, not installed
local Model={OWNER=OWNER}
local MAX=9007199254740991
local tiers={shambler=true,fastShambler=true,sprinter=true,inherit=true}
local function plain(t)return type(t)=='table' and getmetatable(t)==nil end
local function exact(t,keys)
    if not plain(t) then return false end
    for k in pairs(t)do if not keys[k] then return false end end
    return true
end
local function integer(n,lo)return type(n)=='number' and n>=lo and n<=MAX and n%1==0 end
local function text(s,limit)return type(s)=='string' and #s>0 and #s<=limit and not s:find('[%z\1-\31\127]') end
local function desired(d)
    return exact(d,{revision=true,selectionKey=true,tier=true}) and integer(d.revision,1)
        and text(d.selectionKey,4096) and tiers[d.tier]==true
end
local function copyDesired(d)
    return {revision=d.revision,selectionKey=d.selectionKey,tier=d.tier}
end
local function compatible(d,prior)
    if prior==false then return true end
    if d.revision<prior.revision then return false,'stale-revision' end
    if d.revision==prior.revision and d.selectionKey~=prior.selectionKey then return false,'revision-key-conflict' end
    -- The checkpointed choice ledger may have advanced through intermediate
    -- configurations while this lease stayed unchanged. Its history belongs to
    -- Choices; a later valid revision can return to this lease's earlier key.
    return true
end
local function same(a,b)
    return a~=false and b~=false and a.revision==b.revision and a.selectionKey==b.selectionKey and a.tier==b.tier
end
local function clone(s)
    local c={version=1,lifeId=s.lifeId,sessionId=s.sessionId,sequence=s.sequence,
        accepted=s.accepted~=false and copyDesired(s.accepted) or false,applied=s.applied,pending=false}
    if s.pending~=false then
        local p=s.pending
        c.pending={kind=p.kind,status=p.status,attempt=p.attempt,desired=copyDesired(p.desired)}
    end
    return c
end
function Model.validate(s)
    if not exact(s,{version=true,lifeId=true,sessionId=true,sequence=true,accepted=true,applied=true,pending=true})
        or s.version~=1 or not text(s.lifeId,192) or not text(s.sessionId,192) or not integer(s.sequence,0)
        or (s.accepted~=false and not desired(s.accepted))
        or (s.applied~=false and (s.applied=='inherit' or not tiers[s.applied])) then return nil,'invalid-owner-record' end
    local p=s.pending
    if p~=false then
        if not exact(p,{kind=true,status=true,attempt=true,desired=true}) or not desired(p.desired)
            or (p.kind~='release' and p.kind~='acquire')
            or (p.status~='ready' and p.status~='issued' and p.status~='refused' and p.status~='uncertain')
            or not integer(p.attempt,0) or p.attempt>s.sequence then return nil,'invalid-pending-record' end
        if (p.status=='ready' or p.status=='refused')~= (p.attempt==0) then return nil,'invalid-attempt' end
        if p.kind=='release' and (s.applied==false or s.accepted==false or s.accepted.tier~=s.applied)
            or p.kind=='acquire' and (s.applied~=false or p.desired.tier=='inherit') then return nil,'invalid-owner-phase' end
        if not compatible(p.desired,s.accepted) then return nil,'invalid-pending-revision' end
    elseif s.accepted==false then
        if s.applied~=false then return nil,'unaccepted-ownership' end
    elseif (s.accepted.tier=='inherit' and s.applied~=false)
        or (s.accepted.tier~='inherit' and s.applied~=s.accepted.tier) then return nil,'unconfirmed-ownership' end
    return clone(s)
end
function Model.new(lifeId,sessionId)
    return Model.validate({version=1,lifeId=lifeId,sessionId=sessionId,sequence=0,accepted=false,applied=false,pending=false})
end
local function context(saved,ctx)
    local s,err=Model.validate(saved);if not s then return nil,err end
    if not exact(ctx,{lifeId=true,sessionId=true,sequence=true,authority=true,checkpointed=true})
        or ctx.authority~=true or (ctx.checkpointed~=nil and type(ctx.checkpointed)~='boolean') then return nil,'non-authority-context' end
    if ctx.lifeId~=s.lifeId then return nil,'life-mismatch' end
    if ctx.sessionId~=s.sessionId then return nil,'session-recovery-required' end
    if ctx.sequence~=s.sequence then return nil,'stale-sequence' end
    return s
end
local function advance(s)
    if s.sequence>=MAX then return false end
    s.sequence=s.sequence+1;return true
end
local function token(s,p)
    return 'AHO1:'..#s.lifeId..':'..s.lifeId..':'..#s.sessionId..':'..s.sessionId..':'
        ..string.format('%.0f',p.attempt)..':'..p.kind
end

-- The caller supplies an already checkpointed life-choice record. The boolean
-- declaration models a prerequisite; this reducer cannot verify native storage.
function Model.plan(saved,ctx,target,choices)
    local s,err=context(saved,ctx);if not s then return nil,err end
    if ctx.checkpointed~=true then return nil,'checkpoint-required' end
    if not desired(target) then return nil,'invalid-target' end
    local choice;choice,err=Choices.validate(choices);if not choice then return nil,err end
    if choice.lifeId~=s.lifeId or choice.revision~=target.revision or choice.selectionKey~=target.selectionKey then
        return nil,'choice-context-mismatch'
    end
    local reference=s.pending~=false and s.pending.desired or s.accepted
    local ok;ok,err=compatible(target,reference);if not ok then return nil,err end
    if s.pending~=false then
        if same(target,s.pending.desired) then return s,'pending' end
        if s.pending.status=='issued' or s.pending.status=='uncertain' then return nil,'outcome-pending' end
    elseif same(target,s.accepted) then return s,'unchanged' end
    if not advance(s) then return nil,'sequence-exhausted' end
    if (s.applied==false and target.tier=='inherit') or s.applied==target.tier then
        -- Only never-issued or confirmed-no-change requests can be cancelled.
        s.accepted=copyDesired(target);s.pending=false
        return s,'no-native-change'
    end
    local status=s.pending~=false and s.pending.status or 'ready'
    s.pending={kind=s.applied~=false and 'release' or 'acquire',status=status,
        attempt=0,desired=copyDesired(target)}
    return s,'candidate'
end

-- Persist/verify the returned issued record with compare-and-set BEFORE sending
-- the command. Reusing an older saved snapshot is not safe storage concurrency.
function Model.dispatch(saved,ctx)
    local s,err=context(saved,ctx);if not s then return nil,err end
    if ctx.checkpointed~=true then return nil,'checkpoint-required' end
    if s.pending==false or s.pending.status~='ready' then return nil,'not-dispatchable' end
    if not advance(s) then return nil,'sequence-exhausted' end
    local p=s.pending;p.status='issued';p.attempt=s.sequence
    local command={owner=OWNER,operation=p.kind,token=token(s,p)}
    if p.kind=='acquire' then command.tier=p.desired.tier end
    return s,'issued',command
end

-- "refused" means VERIFIED zero native change, not every false API return.
-- A partially applied/unknown failure must be classified "unknown" and frozen.
function Model.acknowledge(saved,ctx,receipt)
    local s,err=context(saved,ctx);if not s then return nil,err end
    local p=s.pending
    if p==false or p.status~='issued' then return nil,'no-confirmable-operation' end
    if not exact(receipt,{token=true,outcome=true}) or receipt.token~=token(s,p)
        or (receipt.outcome~='applied' and receipt.outcome~='refused' and receipt.outcome~='unknown') then
        return nil,'invalid-receipt'
    end
    if not advance(s) then return nil,'sequence-exhausted' end
    if receipt.outcome=='unknown' then p.status='uncertain';return s,'review-required' end
    if receipt.outcome=='refused' then p.status='refused';p.attempt=0;return s,'retry-required' end
    if p.kind=='release' then
        s.applied=false
        if p.desired.tier~='inherit' then
            p.kind='acquire';p.status='ready';p.attempt=0
            return s,'release-confirmed'
        end
    else s.applied=p.desired.tier end
    s.accepted=copyDesired(p.desired);s.pending=false
    return s,'committed'
end
function Model.retry(saved,ctx)
    local s,err=context(saved,ctx);if not s then return nil,err end
    if s.pending==false or s.pending.status~='refused' then return nil,'retry-not-safe' end
    if not advance(s) then return nil,'sequence-exhausted' end
    s.pending.status='ready'
    return s,'retry-candidate'
end
return Model
