-- Authority-local FIFO. Weak actor references never retain unloaded zombies.
local Authority=require "Mortis/Runtime/Authority"
local Settings=require "Mortis/Runtime/SystemSettings"
local Scheduler=require "Mortis/Core/Scheduler"
local Logger=require "Mortis/Core/Logger"
local Work={}
local head,tail,count=nil,nil,0
local pending=setmetatable({},{__mode="k"})
local working=false
-- Metadata safety ceiling, not population/balance tuning. Rejected requests can
-- return on the next staggered poll; accepted work is never evicted or reordered.
local MAX_QUEUED=131072
local stats={enqueued=0,duplicates=0,overflow=0,inspected=0,attempted=0,checked=0,
    fed=0,seeking=0,skipped=0,errors=0,cancelled=0,peakQueued=0,invalidBudget=0,maximumWaitTicks=0}
local function unlink(node)
    if not node.queued then return end
    if node.previous then node.previous.next=node.next else head=node.next end
    if node.next then node.next.previous=node.previous else tail=node.previous end
    node.previous=nil;node.next=nil;node.queued=false;count=count-1
end
function Work.enqueue(actor)
    if not actor or not Scheduler.externalClock or not Settings.bool("EnableZombieHunger")
        or not Authority.canRunCanonicalAI(actor) then return false end
    if pending[actor] then stats.duplicates=stats.duplicates+1;return true end
    if count>=MAX_QUEUED then stats.overflow=stats.overflow+1;return false end
    local node={actor=setmetatable({actor},{__mode="v"}),previous=tail,queued=true,enqueuedFrame=Scheduler.frame}
    if tail then tail.next=node else head=node end
    tail=node;pending[actor]=node;count=count+1
    stats.enqueued=stats.enqueued+1;stats.peakQueued=math.max(stats.peakQueued,count)
    return true
end
function Work.release(actor)
    local node=actor and pending[actor]
    if not node then return false end
    unlink(node);pending[actor]=nil;stats.cancelled=stats.cancelled+1
    return true
end
local function live(actor)
    return actor and actor.getSquare and actor:getSquare()~=nil and actor.isDead
        and not actor:isDead() and Authority.canRunCanonicalAI(actor)
end
function Work.update(process)
    if working or not Scheduler.externalClock or not Authority.canRunCanonicalAI(nil) then return 0 end
    local limit=tonumber(Settings.get("HungerWorkPerTick"))
    if not limit or limit~=limit or limit%1~=0 or limit<1 or limit>512 then
        stats.invalidBudget=stats.invalidBudget+1
        Logger.rateLimited("hunger-budget-invalid",30,"WARN","Invalid HungerWorkPerTick; automatic hunger work deferred","Hunger")
        return 0
    end
    Scheduler.configureBudget("zombie-hunger",limit)
    local attempted=0;working=true
    while head and Scheduler.consumeBudget("zombie-hunger",1) do
        local node=head;unlink(node)
        local actor=node.actor[1];stats.inspected=stats.inspected+1
        stats.maximumWaitTicks=math.max(stats.maximumWaitTicks,Scheduler.frame-node.enqueuedFrame)
        -- Keep pending through callbacks so re-entry cannot enqueue this actor.
        local observed,eligible=pcall(live,actor)
        if Settings.bool("EnableZombieHunger") and observed and eligible then
            attempted=attempted+1;stats.attempted=stats.attempted+1
            local called,ok,result=pcall(process,actor)
            if called then
                stats.checked=stats.checked+1
                if ok==true and result=="seeking" then stats.seeking=stats.seeking+1
                elseif ok==true and type(result)=="table" then stats.fed=stats.fed+1 end
            else
                stats.errors=stats.errors+1
                Logger.rateLimited("hunger-budget-worker",5,"ERROR",
                    "Automatic hunger worker failed: "..tostring(ok):sub(1,256),"Hunger")
            end
        else stats.skipped=stats.skipped+1 end
        if actor and pending[actor]==node then pending[actor]=nil end
    end
    working=false;return attempted
end
function Work.getDiagnostics()
    local result={queued=count,maximumQueued=MAX_QUEUED,clockAvailable=Scheduler.externalClock==true,
        authoritative=Authority.canRunCanonicalAI(nil)==true,
        configuredBudget=Settings.get("HungerWorkPerTick"),oldestWaitTicks=head and Scheduler.frame-head.enqueuedFrame or 0}
    for name,value in pairs(stats)do result[name]=value end
    return result
end
return Work
