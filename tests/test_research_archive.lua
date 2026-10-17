package.loaded["B47ANCEDKnowledgeAndWisdom/API"]=nil;package.loaded["Mortis/Content/ResearchArchive"]=nil;_G.B47ANCEDKnowledgeAndWisdom=nil
local Archive=require "Mortis/Content/ResearchArchive"
-- Dependency version is provenance, not an exact compatibility pin. Exercise
-- the real selected API and persistent-content contract below.
assert(Archive==rawget(_G,"B47ANCEDKnowledgeAndWisdom"))
assert(type(Archive.VERSION)=="string" and Archive.VERSION~="")
assert(rawget(_G,"experienceWorks")==nil,"no legacy public alias is needed")
assert(Archive.getDocument("MORTIS-93-001").project=="Project M.O.R.T.I.S.")
assert(Archive.getDocumentForItem("ProjectMORTIS.Research_MORTIS_ANAT_012").id=="MORTIS-ANAT-012")
local character={modData={}};function character:getModData()return self.modData end
local admitted,why=Archive.learn(character,"MORTIS-93-001",{worldAgeHours=1})
assert(admitted==false and why=="REALM_UNAVAILABLE" and next(character.modData)==nil)
-- Explicit modeled SP role; the repaired dependency refuses an unknown realm.
isClient=function()return false end;isServer=function()return false end
assert(not Archive.learn(character,"MORTIS-ANAT-012"));assert(Archive.learn(character,"MORTIS-93-001",{worldAgeHours=1}));assert(Archive.learn(character,"MORTIS-ANAT-012",{worldAgeHours=2}));assert(Archive.learn(character,"MORTIS-MET-021",{worldAgeHours=3}));assert(Archive.learn(character,"MORTIS-MECH-008",{worldAgeHours=4}))
assert(Archive.hasKnowledge(character,"Mortis.AnatomicalFunction")and Archive.hasKnowledge(character,"Mortis.StarvationDesiccation")and Archive.hasKnowledge(character,"Mortis.PhysicalFailureModes"))
local distributions={list={LaboratoryBooks={items={}},TestingLab={items={}},ArmyStorageMedical={items={}},MedicalOfficeBooks={items={}}}}
assert(Archive.applyDistributions(distributions)==13);assert(Archive.applyDistributions(distributions)==0)
-- Existing MORTIS knowledge is retained under the dependency's immutable key.
assert(Archive.ROOT_KEY=="EXPERIENCE_WORKS_KNOWLEDGE_V1")
local saved={schemaVersion=1,documents={["MORTIS-93-001"]={learnedAtWorldAgeHours=7}},
 knowledge={["Mortis.BasicInfectedPhysiology"]={sourceDocument="MORTIS-93-001",owner="Project M.O.R.T.I.S.",learnedAtWorldAgeHours=7}}}
local prior={modData={[Archive.ROOT_KEY]=saved}};function prior:getModData()return self.modData end
assert(Archive.hasRead(prior,"MORTIS-93-001") and Archive.canLearn(prior,"MORTIS-ANAT-012"))
local learned,result=Archive.learn(prior,"MORTIS-93-001");assert(learned and result.duplicate==true)
assert(prior.modData[Archive.ROOT_KEY]==saved and saved.documents["MORTIS-93-001"].learnedAtWorldAgeHours==7)
package.loaded["Mortis/Content/ResearchArchive"]=nil
assert(require("Mortis/Content/ResearchArchive")==Archive,"reload must reuse the canonical registry")
local documents=0;for _ in pairs(Archive.allDocuments())do documents=documents+1 end;assert(documents==4)
isClient=function()return true end;isServer=function()return false end
local denied,reason=Archive.learn(prior,"MORTIS-ANAT-012")
assert(denied==false and reason=="non-authority" and saved.documents["MORTIS-ANAT-012"]==nil)
isClient=function()return false end;isServer=function()return true end
denied,reason=Archive.learn(prior,"MORTIS-ANAT-012")
assert(denied==false and reason=="MULTIPLAYER_STORAGE_UNAVAILABLE")
assert(saved.documents["MORTIS-ANAT-012"]==nil and prior.modData[Archive.ROOT_KEY]==saved)
assert(rawget(_G,"experienceWorks")==nil)
print("MORTIS SP archive integration and unknown/client/server refusal contract passed offline")
