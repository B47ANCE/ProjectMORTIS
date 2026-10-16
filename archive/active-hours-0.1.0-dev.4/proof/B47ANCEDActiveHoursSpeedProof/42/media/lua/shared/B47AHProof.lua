B47AHProof = B47AHProof or {}
local P = B47AHProof
P.Version = "0.1.0-dev.3"
P.Module = "B47AHSpeedProof"
-- Technical experiment targets, not production balance/configuration.
P.Fixed = { Shambler = {walk="slow1", category=3, scalar=0.60},
    FastShambler = {walk="1", category=2, scalar=0.90},
    Sprinter = {walk="sprint1", category=1, scalar=0.90} }
P.GapTicks = 300 -- Invalidation limit, not a gameplay option or reapply interval.
P.AckTicks = 300 -- Bounded diagnostic deadline; expiry never retries or writes.
function P.finite(v)
    return type(v) == "number" and v == v and v > -math.huge and v < math.huge
end
function P.integer(v, low, high)
    return P.finite(v) and v == math.floor(v) and v >= low and v <= high
end
function P.both()
    return SandboxVars and SandboxVars.ZombieLore and SandboxVars.ZombieLore.ActiveOnly == 1
end
function P.category(walk)
    if type(walk) ~= "string" or #walk == 0 or #walk > 20 then return nil end
    if string.match(walk,"^sprint[1-5]$") then return 1 end
    if string.match(walk,"^slow[1-3]$") then return 3 end
    if string.match(walk,"^[1-5]$") then return 2 end
    return nil -- Reject unknown native/mod walk variants rather than guessing a baseline.
end
function P.valid(s)
    if type(s) ~= "table" then return false end
    local category=P.category(s.walk)
    return category ~= nil and category == s.category
        and P.finite(s.scalar) and s.scalar > 0 and s.scalar < 10
end
function P.unpackSnapshot(args, prefix)
    return {walk=args[prefix.."Walk"],category=args[prefix.."Category"],scalar=args[prefix.."Scalar"]}
end
function P.snapshot(z)
    local ok, s = pcall(function()
        return {walk=z:getWalkType(), category=z:getSpeedType(), scalar=z:getSpeedMod(),
            running=z:isRunning(), action=z:getActionStateName(), animation=z:getAnimationStateName(),
            x=z:getX(), y=z:getY(), remote=z:isRemoteZombie()}
    end)
    -- Observation retains finite anomalous scalars; mutation validation stays stricter.
    if ok then
        local category=P.category(s.walk)
        if category ~= nil and category == s.category and P.finite(s.scalar) then return s end
    end
    return nil
end
function P.usable(z, id)
    local ok, result = pcall(function()
        return z:getOnlineID() == id and not z:isDead() and not z:isCrawling()
    end)
    return ok and result
end
function P.owner(z)
    local ok, result = pcall(function()
        local player = z:getOwnerPlayer()
        return not z:isRemoteZombie() and player ~= nil and player:isLocalPlayer()
    end)
    return ok and result
end
function P.write(z, s)
    -- Only these reversible fields are written. No category helpers or sprite access.
    z:setWalkType(s.walk)
    z:setSpeedTypeFromWalkType()
    z:setSpeedMod(s.scalar)
end
function P.matches(a,b)
    return P.valid(a) and P.valid(b) and a.walk == b.walk and a.category == b.category
        and math.abs(a.scalar-b.scalar) <= 0.002 -- Native positive scalar quantization tolerance.
end
function P.nativeOwner(z)
    local ok, owner = pcall(function() return z:getOwnerPlayer() end)
    if ok then return owner end
    return nil
end
function P.newState()
    return {tick=0, last=0, epoch=0, seq=0, counts={updates=0,samples=0,rejected=0,
        writes=0,restores=0,drift=0,errors=0,gaps=0,ownerChanges=0,
        requests=0,speedRequests=0,accepted=0,ownerWrites=0,observerWrites=0,observerRejected=0,
        restorationAttempts=0,restorationFailures=0,staleCommands=0,duplicates=0,
        missingAcks=0,nativeMatches=0,nativeMismatch=0,apiErrors=0}, samples={},results={}}
end
function P.record(s,result,reason,observed)
    local row={tick=s.tick,epoch=s.epoch,seq=s.seq,id=s.id,result=result,reason=reason,
        requested=s.requested,observed=observed}
    s.results[#s.results+1]=row
    if #s.results > 16 then table.remove(s.results,1) end
end
function P.reject(s,reason,kind,observed)
    s.counts.rejected=s.counts.rejected+1
    if reason == "stale" then s.counts.staleCommands=s.counts.staleCommands+1 end
    if reason == "duplicate" then s.counts.duplicates=s.counts.duplicates+1 end
    if reason == "owner-not-local" then s.counts.observerRejected=s.counts.observerRejected+1 end
    if kind == "Restore" then s.counts.restorationFailures=s.counts.restorationFailures+1 end
    P.record(s,"REJECTED",reason,observed)
end
function P.freeze(s,reason)
    s.invalid=true; s.reason=reason
    P.record(s,"STOP",reason)
end
function P.sample(s,z)
    s.counts.updates = s.counts.updates + 1
    if s.counts.updates % 60 ~= 0 then return end
    local value = P.snapshot(z)
    s.counts.samples = s.counts.samples + 1
    if not value then
        s.counts.errors=s.counts.errors+1; s.counts.apiErrors=s.counts.apiErrors+1
        P.record(s,"ERROR","snapshot-unavailable"); return
    end
    if s.expected and P.owner(z) and not P.matches(value,s.expected) then
        s.counts.drift = s.counts.drift + 1
    end
    value.tick = s.tick
    value.seq=s.seq; value.epoch=s.epoch
    value.localOwner=P.owner(z); value.ownerPresent=P.nativeOwner(z)~=nil
    s.samples[#s.samples+1] = value
    if #s.samples > 16 then table.remove(s.samples,1) end
end
function P.advance(s)
    s.tick = s.tick + 1
    if s.pending and not s.pending.timedOut and s.tick-s.pending.tick > P.AckTicks then
        s.pending.timedOut=true; s.counts.missingAcks=s.counts.missingAcks+1
        if s.pending.kind == "Restore" then s.counts.restorationFailures=s.counts.restorationFailures+1 end
        P.freeze(s,"ack-timeout")
    end
    if s.z and s.tick-s.last > P.GapTicks and not s.invalid then
        s.counts.gaps = s.counts.gaps + 1; P.freeze(s,"callback-gap")
    end
end
function P.bind(s,z)
    if not s.id then return false end -- Continue read-only evidence after mutation is frozen.
    local ok, id = pcall(function() return z:getOnlineID() end)
    if not ok or id ~= s.id then return false end
    if s.z and s.z ~= z then
        if not s.invalid then P.freeze(s,"object-replaced") end
        return false
    end
    if not P.usable(z,s.id) then
        if not s.invalid then P.freeze(s,"object-unusable") end
        return false
    end
    s.z=z; s.last=s.tick
    return true
end
function P.dumpState(s)
    print("B47AHSpeedProof "..P.Version.." side="..tostring(s.side).." session="..s.epoch
        .." id="..tostring(s.id).." seq="..s.seq.." invalid="..tostring(s.invalid)
        .." pending="..tostring(s.pending~=nil).." reason="..tostring(s.reason))
    for key,value in pairs(s.counts) do print("counter "..key.."="..value) end
    for _,v in ipairs(s.samples) do
        print("sample session="..v.epoch.." seq="..v.seq.." tick="..v.tick.." category="..v.category.." scalar="..v.scalar
            .." walk="..v.walk.." remote="..tostring(v.remote).." running="..tostring(v.running)
            .." localOwner="..tostring(v.localOwner).." ownerPresent="..tostring(v.ownerPresent)
            .." x="..tostring(v.x).." y="..tostring(v.y).." action="..tostring(v.action)
            .." animation="..tostring(v.animation))
    end
    for _,r in ipairs(s.results) do
        local requested=r.requested or {}; local observed=r.observed or {}
        print("result session="..r.epoch.." seq="..r.seq.." tick="..r.tick.." result="..r.result
            .." reason="..r.reason.." requestedCategory="..tostring(requested.category)
            .." requestedScalar="..tostring(requested.scalar).." requestedWalk="..tostring(requested.walk)
            .." observedCategory="..tostring(observed.category).." observedScalar="..tostring(observed.scalar)
            .." observedWalk="..tostring(observed.walk))
    end
end
