require "B47AHProof"
if not isClient() then return end
local P = B47AHProof
if P.ClientState then return end
local s = P.newState()
s.side="client"
P.ClientState = s
local function request(command,args)
    local player=getSpecificPlayer(0)
    args=args or {}
    args.epoch=s.epoch -- Native transport omits empty tables; also binds admin intent to session.
    if command == "Select" or command == "Set" or command == "Restore" then
        s.intentSeq=(s.intentSeq or 0)+1; args.intent=s.intentSeq
    end
    if not player then P.reject(s,"player-unavailable",command); return end
    local ok=pcall(sendClientCommand,player,P.Module,command,args)
    if not ok then s.counts.errors=s.counts.errors+1; P.freeze(s,"client-send-error") end
end
function P.select(id) request("Select",{id=id}) end
function P.captureNext() if not s.id then s.capture=true end end
function P.set(speed) request("Set",{speed=speed}) end
function P.restore() request("Restore",{}) end
function P.dump() P.dumpState(s); request("Dump",{}) end
local function receive(module, cmd, args)
    if module ~= P.Module or type(args) ~= "table" then return end
    if cmd == "Arm" then
        if s.id or not P.integer(args.id,0,32767) or not P.integer(args.epoch,1,2147483647) then return end
        s.id=args.id; s.epoch=args.epoch
        return
    end
    if cmd ~= "Apply" then return end
    s.counts.requests=s.counts.requests+1
    if args.kind == "Set" then s.counts.speedRequests=s.counts.speedRequests+1 end
    if args.kind == "Restore" then s.counts.restorationAttempts=s.counts.restorationAttempts+1 end
    local value=P.unpackSnapshot(args,"value")
    local expected=P.unpackSnapshot(args,"expected")
    if args.epoch ~= s.epoch or args.id ~= s.id then P.reject(s,"stale",args.kind); return end
    if P.integer(args.seq,1,2147483647) and args.seq <= s.seq then
        P.reject(s,args.seq == s.seq and "duplicate" or "stale",args.kind); return
    end
    if not P.integer(args.seq,1,2147483647) or args.epoch ~= s.epoch or args.id ~= s.id
        or args.seq <= s.seq or s.invalid or not P.both() or not s.z
        or s.tick-s.last > P.GapTicks or not P.usable(s.z,s.id)
        or not P.valid(value) or not P.valid(expected)
        or (args.kind ~= "Set" and args.kind ~= "Restore") then
        P.reject(s,"not-ready",args.kind); return
    end
    if not P.owner(s.z) then P.freeze(s,"owner-not-local"); P.reject(s,"owner-not-local",args.kind); return end
    s.seq=args.seq -- Consume once even on mismatch/error; no automatic retry.
    local before=P.snapshot(s.z)
    if not before then s.counts.apiErrors=s.counts.apiErrors+1 end
    if not P.matches(before,expected) then
        P.reject(s,"snapshot-mismatch",args.kind,before)
        request("Ack",{epoch=s.epoch,seq=s.seq,ok=false})
        return
    end
    -- Recheck native local authority immediately before the synchronous setter batch.
    if not P.owner(s.z) then P.freeze(s,"owner-not-local"); P.reject(s,"owner-not-local",args.kind); return end
    s.requested=value
    s.counts.accepted=s.counts.accepted+1
    local ok=pcall(P.write,s.z,value)
    local after=P.snapshot(s.z)
    if not after then s.counts.apiErrors=s.counts.apiErrors+1 end
    if not ok or not P.matches(after,value) then
        s.counts.errors=s.counts.errors+1
        -- Single controlled rollback of precisely the fields this batch writes.
        local restored=pcall(P.write,s.z,before)
        P.freeze(s,"setter-failure")
        s.rollbackOK=restored and P.matches(P.snapshot(s.z),before) or false
        if args.kind == "Restore" then s.counts.restorationFailures=s.counts.restorationFailures+1 end
        P.record(s,s.rollbackOK and "ROLLBACK_FIELDS" or "ROLLBACK_FAILED","setter-failure",P.snapshot(s.z))
    else
        s.expected=value
        s.counts.writes=s.counts.writes+1
        s.counts.ownerWrites=s.counts.ownerWrites+1
        if args.kind == "Restore" then s.counts.restores=s.counts.restores+1 end
        P.record(s,"FIELDS_APPLIED",args.kind,after)
    end
    request("Ack",{epoch=s.epoch,seq=s.seq,ok=ok and not s.invalid,
        resultWalk=after and after.walk,resultCategory=after and after.category,resultScalar=after and after.scalar})
end
Events.OnZombieUpdate.Add(function(z)
    if s.capture and not s.id then
        local ok,id=pcall(function() return z:getOnlineID() end)
        if ok and P.integer(id,0,32767) and P.usable(z,id) then
            s.capture=false; P.select(id)
            print("B47AHSpeedProof candidate id="..id.."; confirm selection with dump before any Set")
        end
    end
    if P.bind(s,z) then
        local localOwner=P.owner(z)
        if s.localOwner ~= nil and s.localOwner ~= localOwner then
            s.counts.ownerChanges=s.counts.ownerChanges+1
            if s.localOwner then P.freeze(s,"owner-revoked") end
            P.record(s,"OWNER","local-authority-changed")
        end
        s.localOwner=localOwner
        P.sample(s,z)
    end
end)
Events.OnTick.Add(function() P.advance(s) end)
Events.OnServerCommand.Add(receive)
-- Isolated operator controls; no production UI or persistent keybinding settings.
Events.OnKeyPressed.Add(function(key)
    if not Keyboard or not isKeyDown(Keyboard.KEY_LCONTROL) or not isKeyDown(Keyboard.KEY_LSHIFT) then return end
    if key == Keyboard.KEY_F11 then P.dump(); return end
    local player=getSpecificPlayer(0)
    local ok,isAdmin=pcall(function() return string.lower(player:getAccessLevel()) == "admin" end)
    if not ok or not isAdmin then return end
    if key == Keyboard.KEY_F6 then P.captureNext()
    elseif key == Keyboard.KEY_F7 then P.set("FastShambler")
    elseif key == Keyboard.KEY_F8 then P.set("Sprinter")
    elseif key == Keyboard.KEY_F9 then P.set("Shambler")
    elseif key == Keyboard.KEY_F10 then P.restore() end
end)
