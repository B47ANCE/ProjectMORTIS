local registered = {
    { id="low", priority=0, onSevered=function(_,result) return result.regionId end },
    { id="high", priority=10, typeId="Nightfall.Feral", onSevered=function() return "presented" end },
}
local mocks = {
    ["Mortis/API/AnatomyConsequenceProviders"]={allSorted=function() return registered end},
    ["Mortis/Runtime/Identity"]={getTypeId=function() return "Nightfall.Feral" end},
    ["Mortis/Core/FaultIsolation"]={call=function(_,_,fn,...) return true,fn(...) end},
}
local realRequire=require
require=function(name) return mocks[name] or realRequire(name) end
local Runtime=dofile(arg[1])
local responses=Runtime.dispatch("onSevered",{}, {regionId="arm",speciesId="human"})
assert(#responses==2,"expected both matching providers")
assert(responses[1].providerId=="low" or responses[1].providerId=="high","expected provider response")
print("MORTIS anatomy consequence provider regression checks passed")
