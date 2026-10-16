-- Internal observed-field snapshot. This does not reconstruct private native
-- animation/lunge bookkeeping changed by the legacy speed initializers.
local Game=require "Mortis/Runtime/Adapters/GameAdapter"
local Authority=require "Mortis/Runtime/Authority"
local Baseline={}
local fields={walkType="getWalkType",speedType="getSpeedType",speedMod="getSpeedMod",
    crawler="isCrawling",crawlerType="getCrawlerType"}
local setters={"setWalkType","setSpeedTypeFromWalkType","setSpeedMod","setCrawler","setCrawlerType"}

local function finite(v) return type(v)=="number" and v==v and math.abs(v)~=math.huge end
local function valid(b)
    return type(b)=="table" and b.version==1 and type(b.walkType)=="string" and b.walkType~=""
        and (b.speedType==1 or b.speedType==2 or b.speedType==3)
        and finite(b.speedMod) and b.speedMod>=0 and type(b.crawler)=="boolean"
        and finite(b.crawlerType) and b.crawlerType==math.floor(b.crawlerType)
        and b.crawlerType>=-2147483648 and b.crawlerType<=2147483647
end
local function canWrite(z)
    if not Authority.canWriteCanonicalState(z) then return false,"non-authority" end
    for _,method in ipairs(setters) do
        local ok,fn=pcall(function()return z and z[method]end)
        if not ok or type(fn)~="function" then return false,"baseline inverse unavailable: "..method end
    end
    return true
end
local function read(z)
    local result={version=1}
    for field,method in pairs(fields) do
        local ok,value=Game.call(z,method)
        if not ok then return nil,"baseline read unavailable: "..method end
        result[field]=value
    end
    if not valid(result) then return nil,"invalid or uninitialized locomotion observations" end
    return result
end
local function classFor(walkType)
    -- The inspected native method is static; never pass a zombie as self.
    local ok,value=pcall(function()return IsoZombie.getSpeedTypeFromWalkType(walkType)end)
    if not ok then return nil,"walk classification unavailable" end
    return value
end
local function equal(a,b)
    return a.walkType==b.walkType and a.speedType==b.speedType and a.crawler==b.crawler
        and a.crawlerType==b.crawlerType and math.abs(a.speedMod-b.speedMod)<=0.000001*math.max(1,math.abs(b.speedMod))
end

function Baseline.capture(z)
    local allowed,err=canWrite(z)
    if not allowed then return nil,err end
    local result,readError=read(z)
    if not result then return nil,readError end
    local projected,projectionError=classFor(result.walkType)
    if projected~=result.speedType then return nil,projectionError or "walk/class baseline cannot be restored without guessing" end
    return result
end

function Baseline.restore(z,record)
    local allowed,err=canWrite(z)
    if not allowed then return false,err end
    if not valid(record) then return false,"invalid saved locomotion baseline" end
    if classFor(record.walkType)~=record.speedType then return false,"saved walk/class baseline is not reconstructible" end
    local current,readError=read(z)
    if not current then return false,readError end
    if equal(current,record) then return true,"already restored" end
    local operations={}
    if current.walkType~=record.walkType or current.speedType~=record.speedType then
        operations[#operations+1]={"setWalkType",record.walkType}
        operations[#operations+1]={"setSpeedTypeFromWalkType"}
    end
    if current.speedMod~=record.speedMod then operations[#operations+1]={"setSpeedMod",record.speedMod} end
    if current.crawler~=record.crawler then operations[#operations+1]={"setCrawler",record.crawler} end
    if current.crawlerType~=record.crawlerType then operations[#operations+1]={"setCrawlerType",record.crawlerType} end
    for _,operation in ipairs(operations) do
        local ok,reason
        if operation[2]==nil then ok,reason=Game.call(z,operation[1])
        else ok,reason=Game.call(z,operation[1],operation[2]) end
        if not ok then return false,reason end
    end
    local actual=read(z)
    if not actual or not equal(actual,record) then return false,"locomotion restore readback failed" end
    return true,"restored observed locomotion fields"
end
return Baseline
