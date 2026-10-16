local state={integrity=10,disabled=false,destroyed=false,attached=true,trauma={}}
local definition={integrity=10,critical=true,severable=false,disableThreshold=0,destroyThreshold=0,channelMultipliers={}}
local callbacks={}
local mocks={
    ['Mortis/Runtime/AnatomyRuntime']={
        ensure=function() return {speciesId='Test.Species'} end,
        getRegion=function() return state,definition,'head' end,
        flush=function() return true end,
    },
    ['Mortis/Runtime/AnatomyConsequenceRuntime']={dispatch=function(name) callbacks[name]=(callbacks[name] or 0)+1 end},
    ['Mortis/API/TraumaChannels']={get=function() return {structuralMultiplier=1,bleedMultiplier=0,severMultiplier=0,crushMultiplier=0} end},
    ['Mortis/API/Species']={get=function() return {id='Test.Species',defaultRegion='head'} end},
    ['Mortis/Runtime/Authority']={canWriteCanonicalState=function() return true end},
    ['Mortis/Core/Util']={deepCopy=function(v) return v end},
}
local realRequire=require
require=function(name) return mocks[name] or realRequire(name) end
local Trauma=dofile(arg[1])
assert(Trauma.apply({}, {region='head',channel='impact',magnitude=10}))
assert(callbacks.onDestroyed==1 and callbacks.onCriticalDestroyed==1,'initial destruction must dispatch once')
assert(Trauma.apply({}, {region='head',channel='impact',magnitude=1}))
assert(callbacks.onDestroyed==1 and callbacks.onCriticalDestroyed==1,'later hits must not repeat transition callbacks')
print('MORTIS trauma transition-event checks passed')
