local calls = {}
local posture={isCanWalk=true,isCrawling=false,isOnFloor=false}
local capabilities = {
    ["zombie.setKnockedDown"] = true,
    ["zombie.setFallOnFront"] = true,
    ["zombie.setCrawler"] = true,
    ["zombie.setCanWalk"] = true,
    ["zombie.changeState"] = true,
    ["zombie.setOnFloor"] = true,
    ["zombie.isCanWalk"] = true,
}

local mocks = {
    ["Mortis/API/Capabilities"] = { has=function(name) return capabilities[name] == true end },
    ["Mortis/Runtime/Adapters/GameAdapter"] = {
        call=function(object, method, value)
            if posture[method]~=nil then return true,posture[method] end
            calls[#calls+1] = { method=method, value=value }
            local getters={setCanWalk="isCanWalk",setCrawler="isCrawling",setOnFloor="isOnFloor"}
            if getters[method] then posture[getters[method]]=value end
            return true
        end,
    },
}
local realRequire = require
require = function(name) return mocks[name] or realRequire(name) end
ZombieGetUpState = { instance=function() return "GET_UP" end }
ZombieIdleState = { instance=function() return "IDLE" end }
FakeDeadZombieState = { instance=function() return "FAKE_DEAD" end }

local State = dofile(arg[1])
local zombie = {}
local ok, mode = State.requestStand(zombie)
assert(ok == true and mode == "get-up-state", "expected direct zombie get-up transition")
assert(calls[#calls].method == "changeState", "expected changeState on zombie adapter")
assert(calls[#calls].value == "GET_UP", "expected ZombieGetUpState instance")
for _, call in ipairs(calls) do
    assert(call.method ~= "getStateMachine", "must never access Java StateMachine")
end


calls={}
ok,mode=State.requestFakeDead(zombie)
assert(ok==true and mode=="fake-dead-state","expected direct living fake-dead transition")
assert(#calls==1 and calls[1].method=="changeState" and calls[1].value=="FAKE_DEAD",
    "fake-dead entry must be one atomic state transition without loose flags")

calls={}
ok,mode=State.requestCrawlerWake(zombie)
assert(ok and mode=="crawler-idle-state")
assert(calls[1].method=="setCanWalk" and calls[1].value==false)
assert(calls[2].method=="setCrawler" and calls[2].value==true)
assert(calls[#calls].method=="changeState" and calls[#calls].value=="IDLE")
capabilities["zombie.setCrawler"]=false
calls={}
assert(not State.requestCrawlerWake(zombie) and #calls==0,"preflight must precede native mutation")
capabilities["zombie.setCrawler"]=true
capabilities["zombie.changeState"] = false
assert(not State.requestCrawlerWake(zombie) and #calls==0)
calls = {}
ok, mode = State.requestStand(zombie)
assert(ok == true and mode == "released-to-vanilla-ai", "expected flag-only fallback")
assert(State.requestFakeDead(zombie)==false,"fake-dead entry must fail closed without changeState")

calls={}
posture={isCanWalk=true,isCrawling=false,isOnFloor=false}
assert(State.maintainCrawler(zombie))
assert(#calls==3 and posture.isCanWalk==false and posture.isCrawling and posture.isOnFloor)
for _,call in ipairs(calls) do assert(call.method~="changeState","active posture must not interrupt AI state") end
calls={}
assert(State.maintainCrawler(zombie) and #calls==0,"correct posture must not repeat native writes")
capabilities["zombie.setOnFloor"]=false
assert(not State.maintainCrawler(zombie) and #calls==0)
assert(State.getCanWalk(zombie)==false)
assert(State.setWalkingAllowed(zombie,true))
assert(#calls==1 and calls[1].method=="setCanWalk" and calls[1].value==true)
calls={}
assert(State.setWalkingAllowed(zombie,true) and #calls==0)
assert(not State.setWalkingAllowed(zombie,"true") and #calls==0)
print("MORTIS stand request regression checks passed")
