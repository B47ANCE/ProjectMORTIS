package.loaded["experienceWorks/API"]=nil;package.loaded["Mortis/Content/ResearchArchive"]=nil;_G.experienceWorks=nil
local Archive=require "Mortis/Content/ResearchArchive"
assert(Archive.getDocument("MORTIS-93-001").project=="Project M.O.R.T.I.S.")
assert(Archive.getDocumentForItem("ProjectMORTIS.Research_MORTIS_ANAT_012").id=="MORTIS-ANAT-012")
local character={modData={}};function character:getModData()return self.modData end
assert(not Archive.learn(character,"MORTIS-ANAT-012"));assert(Archive.learn(character,"MORTIS-93-001",{worldAgeHours=1}));assert(Archive.learn(character,"MORTIS-ANAT-012",{worldAgeHours=2}));assert(Archive.learn(character,"MORTIS-MET-021",{worldAgeHours=3}));assert(Archive.learn(character,"MORTIS-MECH-008",{worldAgeHours=4}))
assert(Archive.hasKnowledge(character,"Mortis.AnatomicalFunction")and Archive.hasKnowledge(character,"Mortis.StarvationDesiccation")and Archive.hasKnowledge(character,"Mortis.PhysicalFailureModes"))
local distributions={list={LaboratoryBooks={items={}},TestingLab={items={}},ArmyStorageMedical={items={}},MedicalOfficeBooks={items={}}}}
assert(Archive.applyDistributions(distributions)==13);assert(Archive.applyDistributions(distributions)==0)
print("Project M.O.R.T.I.S. infected-research archive checks passed")
