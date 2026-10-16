local calls={}
local authority=true
local zombie={}
local native={walkType='sneakWalk',speedType=3,speedMod=.7,crawler=false,crawlerType=0,version=1}
local journal
local mocks={
    ["Mortis/Runtime/Adapters/LocomotionAdapter"]={
        setTier=function(_,tier) calls[#calls+1]="tier:"..tier;native.speedType=({sprinter=1,fastShambler=2,shambler=3})[tier];native.walkType=tier;return true end,
        setWalkType=function(_,walk) calls[#calls+1]="walk:"..walk;native.walkType=walk;return true end,
    },
    ["Mortis/Runtime/Adapters/GameAdapter"]={
        call=function(_,method) if method=="isOnFloor" or method=="isGettingUp" then return true,false end return false end,
    },
    ["Mortis/Runtime/Authority"]={canWriteCanonicalState=function() return authority end},
    ["Mortis/Runtime/Adapters/StateAdapter"]={getNativeStateKey=function()return 'Walk' end,isBusy=function()return false end},
    ["Mortis/Runtime/LocomotionBaseline"]={
        capture=function(z)if z~=zombie then return nil,'unknown baseline' end;local copy={};for k,v in pairs(native)do copy[k]=v end;return copy end,
        restore=function(_,baseline)
            if native.walkType~=baseline.walkType then calls[#calls+1]='walk:'..baseline.walkType end
            for k,v in pairs(baseline)do native[k]=v end;return true
        end,
    },
    ["Mortis/Runtime/LocomotionOverrideStore"]={read=function()return journal end,
        write=function(_,baseline)journal={version=1,baseline=baseline};return true end,clear=function()journal=nil;return true end},
}
local realRequire=require
require=function(name) return mocks[name] or realRequire(name) end
local Overrides=dofile(arg[1])
assert(Overrides.acquire(zombie,"uv",{tier="shambler",priority=20}))
assert(calls[#calls]=="tier:shambler","expected UV slow")
assert(Overrides.acquire(zombie,"sprint",{tier="sprinter",priority=40}))
assert(calls[#calls]=="tier:sprinter","expected higher-priority sprint")
authority=false
local before=#calls
assert(not Overrides.release(zombie,"sprint"))
assert(not Overrides.clear(zombie))
assert(not Overrides.acquire(zombie,"injury",{tier="shambler",priority=60}))
assert(#calls==before,"client cannot apply or restore native locomotion")
authority=true
assert(not Overrides.acquire(zombie,"invalid",{tier="shambler",priority=0/0}))
assert(not Overrides.acquire(zombie,"invalid",{tier="shambler",priority=math.huge}))
assert(not Overrides.acquire(nil,"invalid",{tier="shambler"}))
assert(not Overrides.acquire(zombie,"invalid",42))
assert(not Overrides.release(zombie,nil))
assert(#calls==before,"invalid requests must not alter the owner stack")
local realNext=next
next=nil -- Match the restricted Kahlua release environment seen in Build 42.20.3.
assert(Overrides.release(zombie,"sprint"))
assert(calls[#calls]=="tier:shambler","expected UV slow restored after sprint")
assert(Overrides.release(zombie,"uv"))
assert(calls[#calls]=="walk:sneakWalk","expected captured modded/vanilla walk type restored")
next=realNext
print("MORTIS locomotion override regression checks passed")

assert(Overrides.acquire(zombie,"base",{tier="shambler",priority=10}))
local priorCalls=#calls
assert(Overrides.setCeiling(zombie,"injury","fastShambler"))
assert(#calls==priorCalls,"ceiling must not speed up an existing slow owner")
assert(Overrides.acquire(zombie,"sprint",{tier="sprinter",priority=40}))
assert(calls[#calls]=="tier:fastShambler")
priorCalls=#calls
assert(Overrides.setCeiling(zombie,"injury","fastShambler") and #calls==priorCalls,
    "unchanged ceilings must not randomize native speed each update")
assert(Overrides.setCeiling(zombie,"severe","shambler"))
assert(calls[#calls]=="tier:shambler")
assert(Overrides.releaseCeiling(zombie,"severe"))
assert(calls[#calls]=="tier:fastShambler")
assert(not Overrides.acquire(zombie,"custom",{walkType="modded",priority=100}))
assert(Overrides.releaseCeiling(zombie,"injury"))
assert(calls[#calls]=="tier:sprinter","removing ceiling restores the pending owner's tier")
assert(Overrides.clear(zombie))
assert(not Overrides.setCeiling({},"injury","shambler"),"unknown native baseline must not be guessed")
authority=false
assert(not Overrides.setCeiling(zombie,"injury","shambler"))
assert(not Overrides.releaseCeiling(zombie,"injury"))
print("MORTIS movement ceiling composition, authority and native-call deduplication checks passed")
