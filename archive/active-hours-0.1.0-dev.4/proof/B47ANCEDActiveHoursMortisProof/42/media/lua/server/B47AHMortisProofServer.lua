require "B47AHMortisProof"
if not isServer() then return end
local P=B47AHMortisProof
if P.Server then return end
local s=P.state("server")
P.Server=s
s.session="AHM-"..tostring({}) -- Opaque server-run token; no connection/player identity.
local loaded=pcall(require,"Mortis/init")
local M=rawget(_G,"Mortis")
local ready=false
if loaded and type(M)=="table" and type(M.negotiateAPI)=="function" then
    local ok,compatible=pcall(M.negotiateAPI,{consumer=P.Owner,minimum="1.5.0",maximumExclusive="2.0.0",
        required={["LocomotionOverrides.acquire"]="function",["LocomotionOverrides.release"]="function",
            ["Authority.canWriteCanonicalState"]="function"}})
    ready=ok and compatible==true
end
local function reject(reason)
    s.counts.rejected=s.counts.rejected+1;P.record(s,"REJECTED",reason)
end
local function admin(player)
    local ok,result=pcall(function() return string.lower(player:getAccessLevel())=="admin" end)
    return ok and result
end
local function selected()
    local ok=pcall(sendServerCommand,P.Module,"Selected",{id=s.id,session=s.session})
    if not ok then s.counts.errors=s.counts.errors+1;P.stop(s,"selection-send-error") end
end
local function command(module,cmd,player,args)
    if module~=P.Module then return end
    if not player or not admin(player) or type(args)~="table" then reject("unauthorized-or-payload");return end
    if cmd=="Dump" then P.dump(s);return end
    if cmd=="Select" then
        if s.id~=nil or s.invalid or not P.integer(args.id,0,32767) then reject("selection");return end
        s.id=args.id;s.operator=player;selected();return
    end
    if cmd~="Set" and cmd~="Release" then reject("unknown-command");return end
    s.counts.requests=s.counts.requests+1
    if args.session~=s.session or args.id~=s.id or player~=s.operator
        or not P.integer(args.intent,1,2147483647) or args.intent<=s.seq then reject("stale-or-operator");return end
    s.seq=args.intent -- Consume once, including rejected requests; never retry automatically.
    if s.invalid or not s.z or not P.usable(s.z,s.id) or s.tick-s.last>300 then reject("not-ready");return end
    if not (SandboxVars and SandboxVars.ZombieLore and SandboxVars.ZombieLore.ActiveOnly==1) then
        reject("active-only-must-be-both");return
    end
    if not ready then reject("mortis-api-unavailable");return end
    local ok,authoritative=pcall(M.Authority.canWriteCanonicalState,s.z)
    if not ok or authoritative~=true then P.stop(s,"mortis-authority-unavailable");reject("non-authority");return end
    local before=P.snapshot(s.z)
    if not before or before.scalar>=10 then reject("unusable-baseline");return end
    if cmd=="Set" then
        if type(args.tier)~="string" or not P.Tiers[args.tier] then reject("invalid-tier");return end
        if not s.baseline then s.baseline=before end
        s.requested=args.tier
        ok,authoritative=pcall(M.LocomotionOverrides.acquire,s.z,P.Owner,{tier=args.tier,priority=20})
        if ok and authoritative==true then
            s.active=true;s.expectedCategory=P.Tiers[args.tier]
            s.counts.apiAccepted=s.counts.apiAccepted+1
            P.record(s,"API_ACCEPTED","native-motion-not-verified")
        else s.counts.errors=s.counts.errors+1;P.stop(s,"mortis-acquire-failed") end
    else
        s.counts.releaseAttempts=s.counts.releaseAttempts+1
        if not s.active then reject("no-active-override");return end
        ok,authoritative=pcall(M.LocomotionOverrides.release,s.z,P.Owner)
        if ok and authoritative==true then
            s.active=false;s.requested="release";s.expectedCategory=s.baseline.category
            s.counts.releaseAccepted=s.counts.releaseAccepted+1
            P.record(s,"RELEASE_ACCEPTED","walk-type-release-not-full-restoration")
        else s.counts.errors=s.counts.errors+1;P.stop(s,"mortis-release-failed") end
    end
end
Events.OnClientCommand.Add(command)
Events.OnZombieUpdate.Add(function(z)
    if not P.bind(s,z) then return end
    local ok,owner=pcall(function() return z:getOwnerPlayer() end)
    if not ok then P.stop(s,"owner-observation-unavailable");return end
    if s.owner~=owner then s.owner=owner;s.counts.ownerChanges=s.counts.ownerChanges+1 end
    P.sample(s,z)
end)
Events.OnTick.Add(function() P.advance(s) end)
