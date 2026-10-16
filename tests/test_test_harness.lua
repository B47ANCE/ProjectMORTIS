package.loaded["Mortis/TestHarness"]=nil
local report={}
getFileWriter=function(name,create,append)
 assert(name=="theWorks Test Results - ProjectMORTIS.txt"and create==true and append==false);report={}
 return{writeln=function(_,line)report[#report+1]=line end,close=function()end}
end
getGameTime=function()return{getWorldAgeHours=function()return 12 end}end
getCore=function()return{getVersionNumber=function()return"42.20.3-test"end}end
local function newItem(fullType)local item={fullType=fullType};function item:getFullType()return self.fullType end;return item end
local inventory={items={}};function inventory:getItems()return self.items end;function inventory:AddItem(value)local item=type(value)=="string"and newItem(value)or value;self.items[#self.items+1]=item;return item end
local player={modData={},x=0,y=0};function player:getModData()return self.modData end;function player:getX()return self.x end;function player:getY()return self.y end;function player:getInventory()return inventory end
getSpecificPlayer=function(index)assert(index==0);return player end
local zombie={modData={},x=2,y=3};function zombie:getModData()return self.modData end;function zombie:getX()return self.x end;function zombie:getY()return self.y end
local zombies={size=function()return 1 end,get=function(_,index)assert(index==0);return zombie end};getCell=function()return{getZombieList=function()return zombies end}end
local Mortis={VERSION="0.22.0",API_VERSION="1.5.0",assign=function()end}
Mortis.ComponentSchemas={has=function(id)return id=="Mortis.RandomState"end};Mortis.Species={get=function(id)return id=="Mortis.Humanoid"and{id=id}or nil end}
Mortis.Diagnostics={snapshot=function()return{authority="singlePlayer"}end};Mortis.Identity={ensureStableId=function(entity)entity.stableId=entity.stableId or"MORTIS-test-zombie";return entity.stableId end,getStableId=function(entity)return entity.stableId end}
Mortis.Anatomy={snapshot=function()return{speciesId="Mortis.Infected",regions={}}end};Mortis.negotiateAPI=function()return true,{errors={}}end
package.loaded["Mortis/init"]=Mortis;_G.Mortis=Mortis
local read,known={},{}
B47ANCEDKnowledgeAndWisdom={hasDocument=function(id)return id=="MORTIS-93-001"end,hasRead=function(_,id)return read[id]==true end,hasKnowledge=function(_,id)return known[id]==true end,
 canLearn=function(_,id)return id=="MORTIS-93-001"or known["Mortis.BasicInfectedPhysiology"]==true end}
package.loaded["B47ANCEDKnowledgeAndWisdom/API"]=B47ANCEDKnowledgeAndWisdom
SandboxVars={MORTISSystems={EnableZombieHunger=true}}
local Harness=require"Mortis/TestHarness";assert(Harness.start(true)==true)
local session=player.modData["ProjectMORTIS.TestSession.V1"];assert(session.results.startup.status=="PASS");assert(Harness.inspect()==true and session.results.inspection.status=="PASS")
assert(zombie.modData.ProjectMORTISTestSession==session.sessionId);assert(Harness.persistence()==false and session.results.persistence==nil,"same runtime cannot certify reload")
assert(Harness.research()==false and session.results.research==nil,"initial research command should prove the locked state without completing the step");assert(#inventory.items==4)
read["MORTIS-93-001"]=true;known["Mortis.BasicInfectedPhysiology"]=true;assert(Harness.research()==false,"unlocked advanced files still need completion")
for _,pair in ipairs({{"MORTIS-ANAT-012","Mortis.AnatomicalFunction"},{"MORTIS-MET-021","Mortis.StarvationDesiccation"},{"MORTIS-MECH-008","Mortis.PhysicalFailureModes"}})do read[pair[1]]=true;known[pair[2]]=true end
assert(Harness.research()==true and session.results.research.status=="PASS");assert(#inventory.items==4,"research command must not duplicate files")
assert(Harness.sandbox()==false and session.results.sandbox==nil);SandboxVars.MORTISSystems.EnableZombieHunger=false;assert(Harness.sandbox()==true and session.results.sandbox.status=="PASS")
package.loaded["Mortis/TestHarness"]=nil;Harness=require"Mortis/TestHarness";assert(Harness.persistence()==true and session.results.persistence.status=="PASS")
for _=1,140 do Harness.auto()end;assert(#session.commands==128);assert(Harness.report()==true)
local joined=table.concat(report,"\n");assert(joined:find("Mod ID: ProjectMORTIS",1,true));assert(joined:find("Dependencies enabled for this stage: B47ANCEDKnowledgeAndWisdom",1,true))
print("Project M.O.R.T.I.S. in-game test harness/result-export checks passed")
