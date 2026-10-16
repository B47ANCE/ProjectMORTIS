B47AHMortisProof = B47AHMortisProof or {}
local P = B47AHMortisProof
P.Version = "0.1.0-dev.4"
P.Module = "B47AHMortisProof"
P.Owner = "B47ANCEDActiveHoursMortisProof.Speed"
-- Fixed experiment inputs and technical bounds; not production balance settings.
P.Tiers = {shambler=3, fastShambler=2, sprinter=1}
function P.integer(value,low,high)
    return type(value)=="number" and value==value and value>=low and value<=high
        and value==math.floor(value)
end
function P.usable(z,id)
    local ok,result=pcall(function()
        return z:getOnlineID()==id and not z:isDead() and not z:isCrawling()
    end)
    return ok and result
end
function P.snapshot(z)
    local ok,value=pcall(function()
        return {walk=z:getWalkType(),category=z:getSpeedType(),scalar=z:getSpeedMod(),
            x=z:getX(),y=z:getY(),remote=z:isRemoteZombie(),running=z:isRunning(),
            action=z:getActionStateName(),animation=z:getAnimationStateName()}
    end)
    if not ok or type(value.walk)~="string" or not P.integer(value.category,1,3)
        or type(value.scalar)~="number" or value.scalar~=value.scalar
        or value.scalar<=0 or value.scalar==math.huge then return nil end
    return value
end
function P.state(side)
    return {side=side,tick=0,last=0,seq=0,samples={},results={},counts={
        requests=0,rejected=0,apiAccepted=0,releaseAttempts=0,releaseAccepted=0,
        errors=0,updates=0,samples=0,nativeMismatch=0,ownerChanges=0,clientWrites=0}}
end
function P.record(s,result,reason)
    local value=s.z and P.snapshot(s.z) or nil
    s.results[#s.results+1]={tick=s.tick,seq=s.seq,result=result,reason=reason,value=value}
    if #s.results>16 then table.remove(s.results,1) end
end
function P.stop(s,reason)
    if not s.invalid then s.invalid=true;s.reason=reason;P.record(s,"STOP",reason) end
end
function P.bind(s,z)
    if s.id==nil then return false end
    local ok,id=pcall(function() return z:getOnlineID() end)
    if not ok or id~=s.id then return false end
    if s.z and s.z~=z then P.stop(s,"object-replaced");return false end
    if not P.usable(z,s.id) then P.stop(s,"object-unusable");return false end
    s.z=z;s.last=s.tick
    return true
end
function P.sample(s,z)
    s.counts.updates=s.counts.updates+1
    if s.counts.updates%60~=0 then return end
    local value=P.snapshot(z)
    if not value then s.counts.errors=s.counts.errors+1;P.stop(s,"snapshot-unavailable");return end
    value.tick=s.tick
    s.samples[#s.samples+1]=value;s.counts.samples=s.counts.samples+1
    if #s.samples>16 then table.remove(s.samples,1) end
    if s.expectedCategory and value.category~=s.expectedCategory then
        s.counts.nativeMismatch=s.counts.nativeMismatch+1
    end
end
function P.advance(s)
    s.tick=s.tick+1
    if s.z and s.tick-s.last>300 then P.stop(s,"callback-gap") end
end
function P.dump(s)
    print("B47AHMortisProof "..P.Version.." side="..s.side.." session="..tostring(s.session)
        .." id="..tostring(s.id).." revision="..s.seq.." invalid="..tostring(s.invalid)
        .." requested="..tostring(s.requested).." reason="..tostring(s.reason))
    for key,value in pairs(s.counts) do print("counter "..key.."="..value) end
    for _,v in ipairs(s.samples) do
        print("sample tick="..v.tick.." walk="..v.walk.." category="..v.category
            .." scalar="..v.scalar.." remote="..tostring(v.remote).." running="..tostring(v.running)
            .." x="..tostring(v.x).." y="..tostring(v.y).." action="..tostring(v.action)
            .." animation="..tostring(v.animation))
    end
    for _,r in ipairs(s.results) do
        local v=r.value or {}
        print("result tick="..r.tick.." revision="..r.seq.." result="..r.result
            .." reason="..tostring(r.reason).." walk="..tostring(v.walk)
            .." category="..tostring(v.category).." scalar="..tostring(v.scalar))
    end
end
