require "Mortis/Diagnostics/ActiveHoursShared"
local P=MortisActiveHoursTest
function mortisActiveHoursTestStart(confirmed)
    if not isServer() then return false,"wrong multiplayer side" end
    local prepared,reason=P.prepare(confirmed)
    if not prepared then return false,reason end
    if P.Server then return not P.Server.invalid,"already started" end
    local s=P.state("server")
    P.Server=s
    s.session="AHM-"..tostring({}) -- Opaque server-run token; no connection/player identity.
    local loaded=pcall(require,"Mortis/init")
    local M=rawget(_G,"Mortis")
    local ready=false
    if loaded and type(M)=="table" and type(M.negotiateAPI)=="function" then
        local ok,compatible=pcall(M.negotiateAPI,{consumer=P.Owner,minimum="1.5.0",maximumExclusive="2.0.0",
            required={["LocomotionOverrides.acquire"]="function",["LocomotionOverrides.release"]="function",
                ["Authority.canWriteCanonicalState"]="function",
                ["State.getNativeStateKey"]="function",["State.isBusy"]="function"}})
        ready=ok and compatible==true
    end
    if not ready then
        P.Server=nil
        return false,"mortis-api-unavailable"
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
    local function mutationReady()
        -- Passive observations may continue during native transitions, but
        -- neither Set nor Release may run initializers while posture is busy.
        local ok,onFloor,gettingUp=pcall(function()
            return s.z:isOnFloor(),s.z:isGettingUp()
        end)
        if not ok or type(onFloor)~="boolean" or type(gettingUp)~="boolean" then
            return false,"native-posture-unavailable"
        end
        if onFloor or gettingUp then return false,"native-state-busy" end
        local observed,key=pcall(M.State.getNativeStateKey,s.z)
        if not observed or type(key)~="string" or key=="" or key=="unknown" then
            return false,"native-state-unavailable"
        end
        local classified,busy=pcall(M.State.isBusy,s.z)
        if not classified or type(busy)~="boolean" then return false,"native-state-unavailable" end
        if busy then return false,"native-state-busy" end
        return true
    end
    local function command(module,cmd,player,args)
        if module~=P.Module then return end
        if P.conflict() then P.stop(s,"standalone-diagnostic-conflict");reject("standalone-diagnostic-conflict");return end
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
        local safe,reason=mutationReady()
        if not safe then reject(reason);return end
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
                -- This owner no longer determines locomotion. Another request
                -- or ceiling may legitimately win; keep raw samples instead
                -- of treating a non-baseline category as a native overwrite.
                s.active=false;s.requested="release";s.expectedCategory=nil
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

    return true
end
