-- Real dependency provider registry, authority, replay and saved-store reload.
assert(rawget(_G,"experienceWorks")==nil)
local History=require "B47ANCEDKnowledgeAndWisdom/HistoryRecords"
local unknownStore={}
local admitted,why=History.attachStore(unknownStore)
assert(admitted==false and why=="REALM_UNAVAILABLE" and next(unknownStore)==nil)
-- Host authority must be explicit. A missing role is not SP or dedicated proof.
isClient=function()return false end;isServer=function()return false end
local corpse={};local captures=0
local Mortis={DetachedParts={captureCorpse=function(value,region,metadata)
    captures=captures+1
    assert(value==corpse and region=="torso" and metadata.historyEvidence==true)
    return {sourceStableId="MORTIS-dead-1",sourceTypeId="Test.Feral",regionId="torso",capturedWorldAgeHours=12}
end}}
package.loaded["Mortis/init"]=Mortis
local Adapter=require "Mortis/Integrations/HistoryEvidence"
assert(require("Mortis/Integrations/HistoryEvidence")==Adapter)
local store={};assert(History.attachStore(store))
local actor={getUsername=function()return "alice"end}
local request={schemaVersion=1,operationId="test:create:1",recordId="test:death:1",
    authorId="getUsername:alice",subjectId="MORTIS-dead-1",providerId="Mortis.DeathProvenance",
    evidenceId=Adapter.evidenceId("MORTIS-dead-1","torso"),evidenceObject=corpse,regionId="torso",
    visibility="private",text="Observed infected remains",worldAgeHours=12}
local ok,reason,record=History.create(actor,request)
assert(ok and reason=="CREATED" and record.evidence.sourceStableId=="MORTIS-dead-1")
assert(captures==1 and #store.order==1 and #store.operationOrder==1)
assert(History.create(actor,request)==true and captures==1,"replay must not recapture")
request.text="changed replay";assert(History.create(actor,request)==false);request.text="Observed infected remains"
assert(History.create({getUsername=function()return "mallory"end},request)==false)
isClient=function()return true end;isServer=function()return false end
local denied,why=History.create(actor,request);assert(denied==false and why=="NON_AUTHORITY")
isClient=function()return false end;isServer=function()return true end
local rejectedStore={}
local blocked,blockedReason=History.attachStore(rejectedStore)
assert(blocked==false and blockedReason=="MULTIPLAYER_STORAGE_UNAVAILABLE" and next(rejectedStore)==nil)
blocked,blockedReason=History.create(actor,request)
assert(blocked==false and blockedReason=="MULTIPLAYER_STORAGE_UNAVAILABLE")
local hidden,hiddenReason=History.list(actor)
assert(hidden==nil and hiddenReason=="MULTIPLAYER_STORAGE_UNAVAILABLE")
assert(captures==1 and #store.order==1 and #store.operationOrder==1)
isServer=function()return false end
package.loaded["B47ANCEDKnowledgeAndWisdom/HistoryRecords"]=nil
History=require "B47ANCEDKnowledgeAndWisdom/HistoryRecords"
Mortis.HistoryEvidenceRegistered=nil;package.loaded["Mortis/Integrations/HistoryEvidence"]=nil
assert(require("Mortis/Integrations/HistoryEvidence"));assert(History.attachStore(store))
assert(History.create(actor,request)==true and captures==1)
local listing=History.list(actor);assert(#listing.records==1 and listing.records[1].providerId=="Mortis.DeathProvenance")
assert(rawget(_G,"experienceWorks")==nil,"integration must not create a legacy public global")
print("MORTIS SP history integration and unknown/client/server refusal contract passed offline")
