local methods = {}
local mocks = {
    ["Mortis/Runtime/Adapters/GameAdapter"] = {
        call=function(object, method, ...)
            local fn=object and object[method]
            if type(fn)~="function" then return false,"unavailable" end
            local ok,value=pcall(fn,object,...)
            return ok, value
        end,
    },
}
local realRequire=require
require=function(name)return mocks[name] or realRequire(name)end
local Profiles=dofile(arg[1])

local props={}
function props:Is(name)return name=="solid"end
local container={}
function container:getType()return "dumpster"end
local object={}
function object:getContainer()return container end
function object:getSurfaceOffsetNoTable()return 46 end
function object:isTableSurface()return false end
function object:getProperties()return props end

Profiles.register({id="broken",priority=200,classify=function()error("isolated")end})
Profiles.register({id="dumpster",priority=100,classify=function(facts)
    assert(facts.spriteName==nil,"adapter must not depend on sprite names")
    if facts.containerType=="dumpster" and facts.solid then return {
        supported=true,kind="static-container",height=facts.surfaceHeight,
        stability=.85,footprintArea=1,loadCapacity=300,evidence="verified"
    } end
end})
local ok,result=Profiles.classify(object)
assert(ok and result.profileId=="dumpster","property-first profile must classify")
assert(math.abs(result.height-46/96)<.0001 and result.loadCapacity==300)
local facts=Profiles.describe(object)
assert(facts.containerType=="dumpster" and facts.object==nil,"descriptions must not leak native objects")

local unknown={getSurfaceOffsetNoTable=function()return 0 end}
ok,result=Profiles.classify(unknown)
assert(not ok and result=="no verified support profile","unknown supports must fail closed")
local duplicate=pcall(Profiles.register,{id="dumpster",classify=function()end})
assert(not duplicate,"duplicate ownership must be rejected")
for i=1,Profiles.MAX_PROFILES-2 do
    Profiles.register({id="filler"..i,classify=function()end})
end
assert(not pcall(Profiles.register,{id="overflow",classify=function()end}),"registry must be hard-capped")
print("M.O.R.T.I.S. property-first pile support profile checks passed")
