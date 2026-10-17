-- Data-only local authoring. Never evaluates a draft or registers gameplay.
local Model={VERSION=1,MAX_DRAFT_BYTES=8192}
Model.fields={"id","displayName","tier","healthMultiplier","damageTakenMultiplier","outfit","hairModel","beardModel","traits","behaviors"}
local allowed={};for _,key in ipairs(Model.fields)do allowed[key]=true end
local tiers={inherit=true,shambler=true,fastShambler=true,sprinter=true}
local function trim(s)return s:match("^%s*(.-)%s*$")end
local function identifier(s)return #s<=96 and s:match("^[A-Za-z][A-Za-z0-9_]*%.[A-Za-z0-9_.]+$") and not s:find("..",1,true) and s:sub(-1)~="." end
local function clean(s,max)return type(s)=="string" and #s<=max and not s:find("[%z\1-\31\127]")end
local function errorFor(field)return nil,field end
function Model.new()
 return {id="MyZombies.CustomZombie",displayName="Custom Zombie",tier="inherit",healthMultiplier="1",damageTakenMultiplier="1",outfit="",hairModel="",beardModel="",traits="",behaviors=""}
end
function Model.copy(d)local c={};for _,k in ipairs(Model.fields)do c[k]=d[k]end;return c end
function Model.equal(a,b)for _,k in ipairs(Model.fields)do if a[k]~=b[k]then return false end end;return true end
local function references(s)
 local result,seen={},{}
 if s==""then return result end
 for part in (s..","):gmatch("(.-),")do
  local id=trim(part)
  if not identifier(id) or seen[id] or #result>=16 then return nil end
  seen[id]=true;result[#result+1]=id
 end
 return result
end
function Model.validate(raw)
 if type(raw)~="table" or getmetatable(raw)~=nil then return errorFor("document")end
 for k in pairs(raw)do if not allowed[k]then return errorFor("document")end end
 local d={}
 for _,k in ipairs(Model.fields)do
  if not clean(rawget(raw,k),1552)then return errorFor(k)end
  d[k]=trim(raw[k])
 end
 if not identifier(d.id) or d.id:match("^Mortis%.") or d.id:match("^ProjectMORTIS%.")then return errorFor("id")end
 if d.displayName=="" or #d.displayName>120 then return errorFor("displayName")end
 if not tiers[d.tier]then return errorFor("tier")end
 for _,k in ipairs({"healthMultiplier","damageTakenMultiplier"})do
  local n=tonumber(d[k]);if not n or n~=n or n<.01 or n>1000 then return errorFor(k)end
  d[k]=tostring(n)
 end
 for _,k in ipairs({"outfit","hairModel","beardModel"})do if #d[k]>120 then return errorFor(k)end end
 for _,k in ipairs({"traits","behaviors"})do if not references(d[k])then return errorFor(k)end end
 return d
end
function Model.serialize(raw)
 local d,e=Model.validate(raw);if not d then return nil,e end
 local lines={"MORTIS_CREATOR=1"}
 for _,k in ipairs(Model.fields)do lines[#lines+1]=k.."="..d[k]end
 local s=table.concat(lines,"\n").."\n"
 if #s>Model.MAX_DRAFT_BYTES then return nil,"document"end
 return s,d
end
function Model.deserialize(s)
 if type(s)~="string" or #s>Model.MAX_DRAFT_BYTES then return nil,"document"end
 local d={}
 local count=0
 for line in s:gmatch("([^\n]*)\n")do
  count=count+1
  if count==1 then if line~="MORTIS_CREATOR=1"then return nil,"document"end
  else
   local key,value=line:match("^([A-Za-z]+)=(.*)$")
   if not key or not allowed[key] or d[key]~=nil then return nil,"document"end
   d[key]=value
  end
 end
 if s:sub(-1)~="\n" or count~=#Model.fields+1 then return nil,"document"end
 return Model.validate(d)
end
local function quote(s)
 return '"'..s:gsub('[%z\1-\31\127\\"]',function(c)
  if c=='"'then return '\\"'elseif c=='\\'then return '\\\\'end
  return string.format("\\%03d",string.byte(c))
 end)..'"'
end
local function list(s)
 local parts={};for _,id in ipairs(references(s))do parts[#parts+1]=quote(id)end
 return "{"..table.concat(parts,", ").."}"
end
function Model.export(raw)
 local d,e=Model.validate(raw);if not d then return nil,e end
 local lines={"-- MORTIS creator definition. Review and install in a separate content mod.",
  "-- No spawning policy is supplied. Install matching content on server and clients.",
  'local Mortis = require "Mortis/init"',
  "assert(not Mortis.Types.has("..quote(d.id).."), \"Zombie type ID is already registered\")"}
 for _,key in ipairs({"traits","behaviors"})do
  local api=key=="traits" and "Traits" or "Behaviors"
  for _,id in ipairs(references(d[key]))do
   lines[#lines+1]="assert(Mortis."..api..".has("..quote(id).."), "..quote("Required "..key.." provider is missing: "..id)..")"
  end
 end
 local body={"Mortis.registerType({", "    id = "..quote(d.id)..",", "    displayName = "..quote(d.displayName)..",",
  "    locomotion = { tier = "..quote(d.tier).." },",
  "    durability = { healthMultiplier = "..d.healthMultiplier..", damageTakenMultiplier = "..d.damageTakenMultiplier.." },",
  "    appearance = {"}
 for _,line in ipairs(body)do lines[#lines+1]=line end
 for _,k in ipairs({"outfit","hairModel","beardModel"})do if d[k]~=""then lines[#lines+1]="        "..k.." = "..quote(d[k])..","end end
 lines[#lines+1]="    },";lines[#lines+1]="    traits = "..list(d.traits)..",";lines[#lines+1]="    behaviors = "..list(d.behaviors)..",";lines[#lines+1]="})"
 return table.concat(lines,"\n").."\n",d
end
function Model.checksum(s)local n=0;for i=1,#s do n=(n*33+s:byte(i))%2147483647 end;return n end
return Model
