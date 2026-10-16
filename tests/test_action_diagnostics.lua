package.loaded["Mortis/Core/ActionDiagnostics"]=nil
local diagnostics=require "Mortis/Core/ActionDiagnostics"
diagnostics.clear();local ok,reason=diagnostics.record("rejection","trip.canTrip","crawler",{source="test",ignored={}});assert(ok==false and reason=="crawler")
diagnostics.record("rejection","trip.canTrip","crawler",{source="later"});local state=diagnostics.snapshot();assert(state.total==2 and state.distinct==1 and state.aggregates[1].count==2 and state.aggregates[1].context.source=="test")
state.aggregates[1].count=999;assert(diagnostics.snapshot().aggregates[1].count==2)
for i=1,140 do diagnostics.record("rejection","action"..i,"reason"..i,{index=i})end
state=diagnostics.snapshot();assert(state.distinct==diagnostics.MAX_AGGREGATES and #state.recent==diagnostics.MAX_RECENT and state.total==142)
Events={};package.loaded["Mortis/API/Capabilities"]=nil;local capabilities=require "Mortis/API/Capabilities";capabilities.values={missing=false};capabilities.probed=true
assert(not capabilities.has("missing"));state=diagnostics.snapshot();assert(state.total==143 and state.aggregates[#state.aggregates].kind=="capability")
diagnostics.clear();state=diagnostics.snapshot();assert(state.total==0 and state.distinct==0 and #state.recent==0)
print("M.O.R.T.I.S. bounded rejection/capability diagnostics checks passed")
