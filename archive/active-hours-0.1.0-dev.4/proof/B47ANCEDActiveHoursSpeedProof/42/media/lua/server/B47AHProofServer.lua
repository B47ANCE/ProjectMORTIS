require "B47AHProof"
if not isServer() then return end
local P = B47AHProof
if P.ServerState then return end
local s = P.newState()
s.side="server"
P.ServerState = s
local function reject(reason,kind) P.reject(s,reason or "invalid-request",kind) end
local function admin(player)
    local ok, result = pcall(function() return string.lower(player:getAccessLevel()) == "admin" end)
    return ok and result
end
local function reply(player, command, args) sendServerCommand(player,P.Module,command,args) end
local function observe(z)
    if not P.bind(s,z) then return end
    local ok, owner = pcall(function() return z:getOwnerPlayer() end)
    if not ok then s.counts.apiErrors=s.counts.apiErrors+1; P.freeze(s,"owner-api"); return end
    if s.owner ~= owner then
        if s.pending then
            if s.pending.kind == "Restore" then s.counts.restorationFailures=s.counts.restorationFailures+1 end
            P.freeze(s,"owner-changed-pending")
        end
        s.owner=owner; s.pending=nil; s.seq=s.seq+1
        s.counts.ownerChanges=s.counts.ownerChanges+1
        P.record(s,"OWNER","owner-changed")
    end
    P.sample(s,z)
    if s.expected and s.counts.updates % 60 == 0 then
        if P.matches(P.snapshot(z),s.expected) then
            s.counts.nativeMatches=(s.counts.nativeMatches or 0)+1
        else s.counts.nativeMismatch=(s.counts.nativeMismatch or 0)+1 end
    end
end
local function command(module, cmd, player, args)
    if module ~= P.Module then return end
    if cmd == "Set" or cmd == "Restore" then
        s.counts.requests=s.counts.requests+1
        if cmd == "Set" then s.counts.speedRequests=s.counts.speedRequests+1 end
        if cmd == "Restore" then s.counts.restorationAttempts=s.counts.restorationAttempts+1 end
    end
    if type(args) ~= "table" or not player then reject(); return end
    if cmd == "Ack" then
        if not s.z or s.invalid or not s.pending or args.epoch ~= s.epoch or args.seq ~= s.seq then
            reject(args.epoch == s.epoch and args.seq == s.lastAckSeq and "duplicate" or "stale"); return
        end
        if s.pending.owner ~= player then reject("stale"); return end
        if not P.usable(s.z,s.id) or P.nativeOwner(s.z) ~= player then
            P.freeze(s,"ack-owner-uncertain"); reject("stale"); return
        end
        if args.ok == true and P.matches(P.unpackSnapshot(args,"result"),s.pending.value) then
            s.applied=s.pending.kind ~= "Restore"; s.expected=s.pending.value
            if s.pending.kind == "Restore" then s.counts.restores=s.counts.restores+1 end
            P.record(s,"OWNER_REPORTED","ack-not-native-proof",P.unpackSnapshot(args,"result"))
        else
            s.counts.errors=s.counts.errors+1
            if s.pending.kind == "Restore" then s.counts.restorationFailures=s.counts.restorationFailures+1 end
            P.freeze(s,"owner-reported-failure")
        end
        s.lastAckSeq=s.seq
        s.pending=nil
        return
    end
    if not admin(player) then reject("unauthorized",cmd); return end
    if cmd == "Dump" then P.dumpState(s); return end
    if not P.both() then reject("active-only-conflict",cmd); return end
    if cmd == "Select" then
        -- Never replace an existing test target, including an unacknowledged write.
        if not P.integer(args.intent,1,2147483647) then reject("invalid-intent"); return end
        if s.operator == player and args.intent <= s.lastIntent then reject("duplicate"); return end
        if s.id or not P.integer(args.id,0,32767) then reject(); return end
        s.operator=player; s.lastIntent=args.intent
        s.id=args.id; s.epoch=s.epoch+1
        -- Enrollment only; no mutation broadcast. Failure is diagnostic, never a retry.
        local sent=pcall(sendServerCommand,P.Module,"Arm",{id=s.id,epoch=s.epoch})
        if not sent then s.counts.errors=s.counts.errors+1; P.freeze(s,"enrollment-send-error") end
        return
    end
    if cmd ~= "Set" and cmd ~= "Restore" then reject(); return end
    if args.epoch ~= s.epoch or s.epoch == 0 then reject("stale",cmd); return end
    if s.operator ~= player then reject("unauthorized-operator",cmd); return end
    if not P.integer(args.intent,1,2147483647) then reject("invalid-intent",cmd); return end
    if args.intent <= s.lastIntent then reject("duplicate",cmd); return end
    s.lastIntent=args.intent -- Consume rejected intents too; never replay on a later state.
    if s.invalid or not s.z or not P.usable(s.z,s.id) or s.tick-s.last > P.GapTicks or s.pending then
        reject("not-ready",cmd); return
    end
    local owner=P.nativeOwner(s.z)
    if not owner or owner ~= s.owner then
        P.freeze(s,"owner-unobserved"); reject("owner-uncertain",cmd); return
    end -- No owner route; never fall back to broadcast/server writes.
    local now=P.snapshot(s.z)
    if not P.valid(now) then reject("invalid-snapshot",cmd); return end
    local value
    if cmd == "Set" then
        value=P.Fixed[args.speed]
        if not value then reject("invalid-speed",cmd); return end
        if not s.baseline then s.baseline={walk=now.walk,category=now.category,scalar=now.scalar} end
    else
        value=s.baseline
        if not value then reject("no-baseline",cmd); return end
    end
    s.seq=s.seq+1
    s.requested=value
    s.counts.accepted=s.counts.accepted+1
    s.pending={owner=owner,value=value,kind=cmd,tick=s.tick}
    P.record(s,"DISPATCH","await-owner",now)
    local sent=pcall(reply,owner,"Apply",{id=s.id,epoch=s.epoch,seq=s.seq,kind=cmd,
        valueWalk=value.walk,valueCategory=value.category,valueScalar=value.scalar,
        expectedWalk=now.walk,expectedCategory=now.category,expectedScalar=now.scalar})
    if not sent then s.counts.errors=s.counts.errors+1; P.freeze(s,"server-send-error") end
end
Events.OnZombieUpdate.Add(observe)
Events.OnTick.Add(function() P.advance(s) end)
Events.OnClientCommand.Add(command)
