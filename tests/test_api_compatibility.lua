local Compatibility=require "Mortis/API/Compatibility"
local surface={Engine={takeTrackedBatch=function() end},Anatomy={sever=function() end}}

assert(Compatibility.compare("1.0.0","1.0.0")==0)
assert(Compatibility.compare("1.5.0","1.4.9")==1)
assert(Compatibility.compare("0.9.9","1.0.0")==-1)
assert(Compatibility.compare("1.0", "1.0.0")==nil)

local ok,report=Compatibility.negotiate(surface,{
    consumer="Nightfall",minimum="1.0.0",maximumExclusive="2.0.0",
    required={ ["Engine.takeTrackedBatch"]="function", ["Anatomy.sever"]="function" },
})
assert(ok and report.compatible and report.consumer=="Nightfall")
assert(#report.missing==0 and #report.mismatched==0 and #report.errors==0)

local low,lowReport=Compatibility.negotiate(surface,{minimum="1.5.1"})
assert(not low and #lowReport.errors==1)
local high,highReport=Compatibility.negotiate(surface,{maximumExclusive="1.5.0"})
assert(not high and #highReport.errors==1)

local missing,missingReport=Compatibility.negotiate(surface,{
    required={"Replication.buildSnapshot","Engine.takeTrackedBatch"},
})
assert(not missing and #missingReport.missing==1 and missingReport.missing[1]=="Replication.buildSnapshot")

local mismatch,mismatchReport=Compatibility.negotiate(surface,{
    required={ ["Engine"]="function" },
})
assert(not mismatch and mismatchReport.mismatched[1].actual=="table")

local malformed,badReport=Compatibility.negotiate(surface,{minimum="latest",required="bad"})
assert(not malformed and #badReport.errors==2)

print("Project M.O.R.T.I.S. API compatibility negotiation checks passed")
