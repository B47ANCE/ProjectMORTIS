local registered
B47ANCEDKnowledgeAndWisdom={HistoryRecords={registerEvidenceProvider=function(value)registered=value return value end}}
package.preload["B47ANCEDKnowledgeAndWisdom/HistoryRecords"]=function()return B47ANCEDKnowledgeAndWisdom.HistoryRecords end
local corpse={};local Mortis={DetachedParts={captureCorpse=function(value,region,metadata)
    assert(value==corpse and region=="torso"and metadata.historyEvidence)
    return {sourceStableId="MORTIS-dead-1",sourceTypeId="Test.Feral",regionId="torso",capturedWorldAgeHours=12}
end}}
package.preload["Mortis/init"]=function()return Mortis end
local adapter=dofile("src/ProjectMORTIS/42/media/lua/shared/Mortis/Integrations/HistoryEvidence.lua")
assert(registered.id=="Mortis.DeathProvenance")
local actor={getUsername=function()return "alice"end};assert(registered.getActorId(actor)=="getUsername:alice")
local oversized={getUsername=function()return string.rep("a",160)end};assert(registered.getActorId(oversized)==nil)
local evidenceId=adapter.evidenceId("MORTIS-dead-1","torso")
local ok,evidence=registered.validateEvidence(actor,"MORTIS-dead-1",evidenceId,{evidenceObject=corpse,regionId="torso"})
assert(ok and evidence.kind=="mortis-death"and evidence.sourceTypeId=="Test.Feral")
assert(not registered.validateEvidence(actor,"wrong",evidenceId,{evidenceObject=corpse,regionId="torso"}))
assert(not registered.validateEvidence(actor,"MORTIS-dead-1","wrong",{evidenceObject=corpse,regionId="torso"}))
print("M.O.R.T.I.S. history-evidence integration checks passed")
