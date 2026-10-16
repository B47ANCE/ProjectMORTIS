-- Development-only in-game harness; host tests omit the engine predicate.
if type(isDebugEnabled)=="function" and isDebugEnabled()~=true then return {} end

local Mortis=require "Mortis/init"
local Archive=require "B47ANCEDKnowledgeAndWisdom/API"
local Harness={}
local FILE="theWorks Test Results - ProjectMORTIS.txt"
local KEY="ProjectMORTIS.TestSession.V1"
local TOKEN=tostring({})
local steps={
 {id="startup",feature="Canonical load, dependency, API, and result export",instruction="Run mortisTestAuto()."},
 {id="untyped",feature="Untyped vanilla zombie behavior",instruction="Confirm ordinary zombies retain vanilla movement and targeting without recurring errors."},
 {id="inspection",feature="Live identity and anatomy inspection",instruction="Stand near a loaded zombie and run mortisTestInspect()."},
 {id="combat",feature="Combat, shove, stomp, and balance hooks",instruction="Fight several zombies and confirm natural hits, shoves, stomps, trips, and recovery."},
 {id="separation",feature="Wall-safe collision and pile behavior",instruction="Observe a dense group near walls, stairs, and low obstacles; confirm no displacement or trip cascade."},
 {id="persistence",feature="Identity save/reload persistence",instruction="Save/quit/reload after inspection, approach the same zombie, then run mortisTestPersistence()."},
 {id="research",feature="B47ANCEDKnowledgeAndWisdom research prerequisites",instruction="Run mortisTestResearch() and follow its simple console instructions until the harness verifies the locked and unlocked states."},
 {id="sandbox",feature="M.O.R.T.I.S. sandbox controls",instruction="Run mortisTestSandbox() and follow its instructions to change and verify one safe temporary setting."},
 {id="multiplayer",feature="Hosted and dedicated authority/replication",instruction="Verify state as remote client, after reconnect, and on late join; BLOCKED until available."},
}
local function safe(v)return tostring(v or ""):gsub("[\r\n]+"," "):sub(1,500)end
local function now()
 local library=rawget(_G,"os");if type(library)=="table"and type(library.date)=="function"then local ok,v=pcall(library.date,"!%Y-%m-%dT%H:%M:%SZ");if ok and v then return tostring(v)end end
 return"timestamp unavailable"
end
local function age()
 local f=rawget(_G,"getGameTime");if type(f)~="function"then return 0 end;local ok,t=pcall(f);if not ok or not t then return 0 end
 local read,v=pcall(function()return t:getWorldAgeHours()end);return read and tonumber(v)or 0
end
local function pzVersion()
 local f=rawget(_G,"getCore");if type(f)~="function"then return"unavailable"end;local ok,c=pcall(f);if not ok or not c then return"unavailable"end
 for _,name in ipairs({"getVersionNumber","getVersion"})do if type(c[name])=="function"then local read,v=pcall(c[name],c);if read and v~=nil then return tostring(v)end end end;return"unavailable"
end
local function player()
 local f=rawget(_G,"getSpecificPlayer");if type(f)=="function"then local ok,v=pcall(f,0);if ok and v then return v end end
 f=rawget(_G,"getPlayer");if type(f)=="function"then local ok,v=pcall(f);if ok then return v end end
end
local function data(v)
 if not v or type(v.getModData)~="function"then return nil end;local ok,d=pcall(v.getModData,v);return ok and type(d)=="table"and d or nil
end
local function session(create)
 local character=player();local d=data(character);if not d then return nil,nil,"local player ModData unavailable"end
 if create and type(d[KEY])~="table"then d[KEY]={schemaVersion=1,sessionId=string.format("MORTIS-%s-%.3f",safe(now()),age()),startedAt=now(),pzVersion=pzVersion(),modId="ProjectMORTIS",modVersion=Mortis.VERSION,apiVersion=Mortis.API_VERSION,results={},commands={}}end
 return d[KEY],character
end
local function counts(s)
 local c={PASS=0,FAIL=0,BLOCKED=0,PENDING=0};for _,step in ipairs(steps)do local status=s.results[step.id]and s.results[step.id].status or"PENDING";c[status]=(c[status]or 0)+1 end;return c
end
local function overall(s)local c=counts(s);if c.FAIL>0 then return"FAIL"elseif c.PENDING>0 then return"IN_PROGRESS"elseif c.BLOCKED>0 then return"BLOCKED"end;return"PASS"end
local function lines(s)
 local out={"theWorks in-game test results","Mod: Project M.O.R.T.I.S.","Mod ID: ProjectMORTIS","Mod version: "..safe(s.modVersion),"API version: "..safe(s.apiVersion),"Project Zomboid version: "..safe(s.pzVersion),"Session: "..safe(s.sessionId),"Started: "..safe(s.startedAt),"Generated: "..now(),"Dependencies enabled for this stage: B47ANCEDKnowledgeAndWisdom","Overall session status: "..overall(s),"","FEATURE RESULTS"}
 for i,step in ipairs(steps)do local r=s.results[step.id]or{status="PENDING",note=""};out[#out+1]=string.format("%02d. [%s] %s | %s | %s",i,r.status,step.id,step.feature,safe(r.note))end
 out[#out+1]="";out[#out+1]="COMMAND LOG";for i,e in ipairs(s.commands)do out[#out+1]=string.format("%03d. %s | %s | %s | %s | %s",i,safe(e.at),safe(e.command),safe(e.feature),safe(e.outcome),safe(e.detail))end
 out[#out+1]="";out[#out+1]="Send this file plus console.txt and screenshots for failed visual checks to development.";return out
end
local function writeReport(s)
 local f=rawget(_G,"getFileWriter");if type(f)~="function"then return false,"getFileWriter unavailable"end
 local ok,err=pcall(function()local w=f(FILE,true,false);if not w then error("writer unavailable")end;for _,line in ipairs(lines(s))do if type(w.writeln)=="function"then w:writeln(line)elseif type(w.write)=="function"then w:write(line.."\n")else error("writer has no write method")end end;if type(w.close)=="function"then w:close()end end)
 return ok,ok and nil or safe(err)
end
local function say(v)print("[MORTIS][Test] "..v)end
local function record(s,id,status,note)s.results[id]={status=status,note=safe(note),recordedAt=now()}end
local function finish(s,command,feature,status,detail)
 s.commands[#s.commands+1]={at=now(),command=command,feature=feature,outcome=status,detail=safe(detail)};while #s.commands>128 do table.remove(s.commands,1)end
 local saved,err=writeReport(s);say(command..": "..status.." "..safe(detail));say(saved and("Results saved to Zomboid/Lua/"..FILE)or("Result export failed: "..safe(err)));return status=="PASS",detail
end
local function pending(s)for _,step in ipairs(steps)do if not s.results[step.id]then return step end end end
local function nearest(tag)
 local p=player();local getter=rawget(_G,"getCell");local cell=type(getter)=="function"and getter()or nil;if not p or not cell or type(cell.getZombieList)~="function"then return nil end
 local ok,list=pcall(cell.getZombieList,cell);if not ok or not list or type(list.size)~="function"or type(list.get)~="function"then return nil end;local sizeOk,n=pcall(list.size,list);if not sizeOk then return nil end
 local best,distance=nil,math.huge;for i=0,math.min(tonumber(n)or 0,512)-1 do local read,z=pcall(list.get,list,i);local d=data(z);if read and z and(not tag or(d and d.ProjectMORTISTestSession==tag))then local measured,value=pcall(function()local dx,dy=z:getX()-p:getX(),z:getY()-p:getY();return dx*dx+dy*dy end);if measured and value<distance then best,distance=z,value end end end;return best
end
local research={
 {document="MORTIS-93-001",knowledge="Mortis.BasicInfectedPhysiology",item="ProjectMORTIS.Research_MORTIS_93_001",label="Persistent Postmortem Activity"},
 {document="MORTIS-ANAT-012",knowledge="Mortis.AnatomicalFunction",item="ProjectMORTIS.Research_MORTIS_ANAT_012",label="Functional Anatomy After Death"},
 {document="MORTIS-MET-021",knowledge="Mortis.StarvationDesiccation",item="ProjectMORTIS.Research_MORTIS_MET_021",label="Starvation Persistence Study"},
 {document="MORTIS-MECH-008",knowledge="Mortis.PhysicalFailureModes",item="ProjectMORTIS.Research_MORTIS_MECH_008",label="Balance and Collision Failure"},
}
local function inventoryItems(inventory)
 local result={};if not inventory or type(inventory.getItems)~="function"then return result end;local ok,items=pcall(inventory.getItems,inventory);if not ok or not items then return result end
 if type(items.size)=="function"and type(items.get)=="function"then local sizeOk,n=pcall(items.size,items);if sizeOk then for i=0,math.min(tonumber(n)or 0,512)-1 do local read,item=pcall(items.get,items,i);if read then result[#result+1]=item end end end elseif type(items)=="table"then for _,item in ipairs(items)do result[#result+1]=item end end;return result
end
local function fullType(item)if not item or type(item.getFullType)~="function"then return nil end;local ok,value=pcall(item.getFullType,item);return ok and tostring(value)or nil end
local function giveResearch(character,current)
 if not character or type(character.getInventory)~="function"then return false,"player inventory unavailable"end;local ok,inventory=pcall(character.getInventory,character);if not ok or not inventory then return false,"player inventory unavailable"end
 if type(inventory.AddItem)~="function"then return false,"inventory AddItem unavailable"end
 local present={};for _,item in ipairs(inventoryItems(inventory))do present[fullType(item)]=true end
 for _,entry in ipairs(research)do if not present[entry.item]then
  local added,item=pcall(inventory.AddItem,inventory,entry.item)
  if not added or not item then return false,"could not create or add research test file: "..entry.item end
 end end;return true
end
function Harness.auto()
 local s,_,err=session(true);if not s then say(err);return false,err end;local archive=rawget(_G,"B47ANCEDKnowledgeAndWisdom")
 local dependency=type(archive)=="table"and type(archive.hasDocument)=="function"and archive.hasDocument("MORTIS-93-001")==true
 local canonical=rawget(_G,"Mortis")==Mortis and Mortis.VERSION==s.modVersion
 local compatible,report=Mortis.negotiateAPI({minimum="1.0.0",required={{path="assign",kind="function"},{path="Anatomy",kind="table"}}})
 local definitions=Mortis.ComponentSchemas.has("Mortis.RandomState")and Mortis.Species.get("Mortis.Humanoid")~=nil;local diagnosticsOk,snapshot=pcall(Mortis.Diagnostics.snapshot);local writerOk,writerError=writeReport(s)
 local pass=dependency and canonical and compatible==true and definitions and diagnosticsOk and type(snapshot)=="table"and writerOk
 local detail=string.format("canonical=%s dependency=%s compatible=%s definitions=%s diagnostics=%s writer=%s",tostring(canonical),tostring(dependency),tostring(compatible),tostring(definitions),tostring(diagnosticsOk),tostring(writerOk));if not pass and writerError then detail=detail.." error="..safe(writerError)elseif not pass and report and report.errors then detail=detail.." apiErrors="..safe(table.concat(report.errors,","))end
 record(s,"startup",pass and"PASS"or"FAIL",detail);return finish(s,"mortisTestAuto()","startup",pass and"PASS"or"FAIL",detail)
end
function Harness.start(reset)
 local s,p,err=session(true);if not s then say(err);return false,err end;if reset==true then data(p)[KEY]=nil;s=session(true)end;Harness.auto();local step=pending(s);say("Session started. Enable only B47ANCEDKnowledgeAndWisdom and ProjectMORTIS.");if step then say("NEXT ["..step.id.."] "..step.instruction)end;return true,s.sessionId
end
function Harness.inspect()
 local s=session(false);if not s then say("No session; run mortisTestStart(true)");return false end;local z=nearest();if not z then return finish(s,"mortisTestInspect()","inspection","BLOCKED","no loaded zombie found nearby")end
 local stable=Mortis.Identity.ensureStableId(z);local anatomy=Mortis.Anatomy.snapshot(z);local d=data(z);if d then d.ProjectMORTISTestSession=s.sessionId end;local pass=stable~=nil and type(anatomy)=="table"
 if pass then s.observedStableId=stable;s.observedRuntimeToken=TOKEN;record(s,"inspection","PASS","stableId="..safe(stable).." anatomy captured")end;return finish(s,"mortisTestInspect()","inspection",pass and"PASS"or"FAIL","stableId="..safe(stable).." anatomy="..tostring(type(anatomy)=="table"))
end
function Harness.persistence()
 local s=session(false);if not s then say("No session");return false end;if not s.observedStableId then return finish(s,"mortisTestPersistence()","persistence","BLOCKED","run mortisTestInspect() first")end
 local z=nearest(s.sessionId);if not z then return finish(s,"mortisTestPersistence()","persistence","BLOCKED","tagged zombie is not currently loaded nearby")end;local stable=Mortis.Identity.getStableId(z);local reloaded=s.observedRuntimeToken~=TOKEN;local same=stable==s.observedStableId
 if same and reloaded then record(s,"persistence","PASS","stable identity survived a new Lua runtime")elseif not same then record(s,"persistence","FAIL","stable identity changed after reload")end;local status=same and reloaded and"PASS"or(same and"BLOCKED"or"FAIL");return finish(s,"mortisTestPersistence()","persistence",status,same and(reloaded and"reload verified"or"save/quit/reload still required")or"stable identity mismatch")
end
function Harness.research()
 local current,character=session(false);if not current then say("No session; run mortisTestStart(true)");return false end;local given,giveError=giveResearch(character,current);if not given then return finish(current,"mortisTestResearch()","research","FAIL",giveError)end
 local foundation=research[1];local foundationRead=Archive.hasRead(character,foundation.document)==true;local foundationKnown=Archive.hasKnowledge(character,foundation.knowledge)==true
 local unlocked,completed=true,true;local states={}
 for index=2,#research do local entry=research[index];local allowed=Archive.canLearn(character,entry.document)==true;local read=Archive.hasRead(character,entry.document)==true;local known=Archive.hasKnowledge(character,entry.knowledge)==true;unlocked=unlocked and allowed;completed=completed and read and known;states[#states+1]=entry.label.." allowed="..tostring(allowed).." complete="..tostring(read and known)end
 if not foundationRead then
  current.researchInitiallyBlocked=not unlocked
  if unlocked then record(current,"research","FAIL","advanced research was available before the foundation unlock");return finish(current,"mortisTestResearch()","research","FAIL","locked research became available too early")end
  say("M.O.R.T.I.S. TEST — Research Progression");say("1. The three advanced research files in your inventory should remain locked.");say("2. Try one; confirm it cannot be completed.");say("3. Read Persistent Postmortem Activity, then run mortisTestResearch() again.")
  return finish(current,"mortisTestResearch()","research","BLOCKED","premature completion rejected; waiting for the prompted foundation read")
 end
 if not foundationKnown or not current.researchInitiallyBlocked then record(current,"research","FAIL","authoritative foundation knowledge or initial locked-state evidence missing");return finish(current,"mortisTestResearch()","research","FAIL","research gate evidence incomplete")end
 if not unlocked then record(current,"research","FAIL","one or more advanced files stayed locked after the foundation read");return finish(current,"mortisTestResearch()","research","FAIL",table.concat(states,"; "))end
 if not completed then say("M.O.R.T.I.S. TEST — Research Progression");say("The locked research is now available. Read all three advanced files, then run mortisTestResearch() once more.");return finish(current,"mortisTestResearch()","research","BLOCKED","proper unlock observed; waiting for advanced research completion")end
 record(current,"research","PASS","premature completion rejected; anatomy, metabolism, and biomechanics unlocked and completed after the authoritative foundation")
 return finish(current,"mortisTestResearch()","research","PASS",table.concat(states,"; "))
end
function Harness.sandbox()
 local current=session(false);if not current then say("No session; run mortisTestStart(true)");return false end;local root=rawget(_G,"SandboxVars");local systems=root and root.MORTISSystems;local value=systems and systems.EnableZombieHunger
 if type(value)~="boolean"then return finish(current,"mortisTestSandbox()","sandbox","FAIL","M.O.R.T.I.S. Systems page value is unavailable")end
 if current.sandboxOriginal==nil then current.sandboxOriginal=value;current.sandboxRequested=not value;say("M.O.R.T.I.S. TEST — Settings");say("1. Open Sandbox Options and find the M.O.R.T.I.S. Systems page.");say("2. Set Enable zombie hunger to "..(current.sandboxRequested and"ON"or"OFF")..".");say("3. Apply the setting, return to the game, and run mortisTestSandbox() again.");return finish(current,"mortisTestSandbox()","sandbox","BLOCKED","current="..tostring(value).." requested="..tostring(current.sandboxRequested))end
 if value~=current.sandboxRequested then return finish(current,"mortisTestSandbox()","sandbox","BLOCKED","setting has not changed yet; expected="..tostring(current.sandboxRequested).." observed="..tostring(value))end
 record(current,"sandbox","PASS","M.O.R.T.I.S. Systems page exposed the requested setting and runtime observed the changed value")
 say("Setting change verified. Restore Enable zombie hunger to "..(current.sandboxOriginal and"ON"or"OFF").." after this disposable test.");return finish(current,"mortisTestSandbox()","sandbox","PASS","original="..tostring(current.sandboxOriginal).." changed="..tostring(value))
end
function Harness.recordCurrent(status,note)
 local s=session(false);if not s then say("No session");return false end;local step=pending(s);if not step then say("All steps already recorded");return false end;record(s,step.id,status,note);finish(s,"mortisTest"..status:sub(1,1)..status:sub(2):lower().."()",step.id,status,note);local nextStep=pending(s);if nextStep then say("NEXT ["..nextStep.id.."] "..nextStep.instruction)else say("All steps recorded. Run mortisTestReport().")end;return true
end
function Harness.report()local s=session(false);if not s then say("No session");return false end;say("REPORT BEGIN");for _,line in ipairs(lines(s))do say(line)end;say("REPORT END");local ok,err=writeReport(s);say(ok and("Results saved to Zomboid/Lua/"..FILE)or("Result export failed: "..safe(err)));return ok,err end
function Harness.where()say("Windows result file: %USERPROFILE%\\Zomboid\\Lua\\"..FILE);return FILE end
mortisTestStart=function(reset)return Harness.start(reset)end;mortisTestAuto=function()return Harness.auto()end;mortisTestInspect=function()return Harness.inspect()end;mortisTestPersistence=function()return Harness.persistence()end
mortisTestResearch=function()return Harness.research()end;mortisTestSandbox=function()return Harness.sandbox()end
mortisTestPass=function(note)return Harness.recordCurrent("PASS",note)end;mortisTestFail=function(note)return Harness.recordCurrent("FAIL",note)end;mortisTestBlocked=function(note)return Harness.recordCurrent("BLOCKED",note)end;mortisTestReport=function()return Harness.report()end;mortisTestWhere=function()return Harness.where()end
Mortis.TestHarness=Harness;say("Ready: mortisTestStart(true); results export to Zomboid/Lua/"..FILE);return Harness
