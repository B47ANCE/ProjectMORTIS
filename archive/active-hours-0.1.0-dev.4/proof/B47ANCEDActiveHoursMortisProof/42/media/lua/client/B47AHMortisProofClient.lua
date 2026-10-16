require "B47AHMortisProof"
if not isClient() then return end
local P=B47AHMortisProof
if P.Client then return end
local s=P.state("client")
P.Client=s
function P.request(cmd,value)
    if s.invalid and (cmd=="Set" or cmd=="Release") then return false end
    local player=getSpecificPlayer(0)
    if not player then return false end
    s.intent=(s.intent or 0)+1
    local args={session=s.session or "",id=s.id,intent=s.intent,tier=value}
    if cmd=="Select" then args.id=value;args.tier=nil end
    local ok=pcall(sendClientCommand,player,P.Module,cmd,args)
    if not ok then s.counts.errors=s.counts.errors+1;P.stop(s,"client-send-error") end
    return ok
end
Events.OnServerCommand.Add(function(module,cmd,args)
    if module~=P.Module or cmd~="Selected" or type(args)~="table" then return end
    if s.id~=nil or not P.integer(args.id,0,32767) or type(args.session)~="string" or #args.session==0 then return end
    s.id=args.id;s.session=args.session
    -- Enrollment only. Clients never apply native locomotion mutations.
end)
Events.OnZombieUpdate.Add(function(z)
    if s.capture and s.id==nil then
        local ok,id=pcall(function() return z:getOnlineID() end)
        if ok and P.integer(id,0,32767) and P.usable(z,id) then
            s.capture=false;P.request("Select",id)
        end
    end
    if P.bind(s,z) then P.sample(s,z) end
end)
Events.OnTick.Add(function() P.advance(s) end)
Events.OnKeyPressed.Add(function(key)
    if not Keyboard or not isKeyDown(Keyboard.KEY_LCONTROL) or not isKeyDown(Keyboard.KEY_LSHIFT) then return end
    if key==Keyboard.KEY_F11 then P.dump(s);P.request("Dump");return end
    local player=getSpecificPlayer(0)
    local ok,allowed=pcall(function() return string.lower(player:getAccessLevel())=="admin" end)
    if not ok or not allowed then return end
    if key==Keyboard.KEY_F6 and s.id==nil then s.capture=true
    elseif key==Keyboard.KEY_F7 then P.request("Set","fastShambler")
    elseif key==Keyboard.KEY_F8 then P.request("Set","sprinter")
    elseif key==Keyboard.KEY_F9 then P.request("Set","shambler")
    elseif key==Keyboard.KEY_F10 then P.request("Release") end
end)
