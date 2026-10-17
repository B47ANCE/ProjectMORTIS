local Model=require "Mortis/Creator/Model"
local Store={MAX_ENTRIES=32,MAX_BYTES=530000}
local names={"MORTIS_ZombieCreator_Drafts_A.txt","MORTIS_ZombieCreator_Drafts_B.txt"}
local MAX_LINES=Store.MAX_ENTRIES*(#Model.fields+2)+3
-- Fixed owned basenames in the vanilla Lua cache; no user-selected paths.
local Native={}
function Native.read(name,limit,lines)
 if type(getFileReader)~="function"then return nil,"StorageUnavailable"end
 local reader
 local ok,result=pcall(function()
  reader=getFileReader(name,false)
  if not reader then return nil end
  local out,size={},0
  while true do
   local line=reader:readLine();if line==nil then break end
   size=size+#line+1
   if size>limit or #out>=lines then error("read limit")end
   out[#out+1]=line
  end
  return table.concat(out,"\n")..(#out>0 and "\n" or "")
 end)
 if reader then local closed=pcall(function()reader:close()end);ok=ok and closed end
 if not ok then return nil,"ReadFailed"end
 return result,result==nil and "Missing" or nil
end
function Native.write(name,text)
 if type(getFileWriter)~="function"then return false,"StorageUnavailable"end
 local writer
 local ok=pcall(function()
  writer=getFileWriter(name,true,false);if not writer then error("writer unavailable")end
  writer:write(text)
 end)
 if writer then local closed=pcall(function()writer:close()end);ok=ok and closed end
 return ok,not ok and "WriteFailed" or nil
end
local function pack(records,revision)
 local ids={};for id in pairs(records)do ids[#ids+1]=id end;table.sort(ids)
 if #ids>Store.MAX_ENTRIES then return nil,"LibraryFull"end
 local lines={}
 for _,id in ipairs(ids)do
  local text,draft=Model.serialize(records[id])
  if not text or draft.id~=id then return nil,"CorruptLibrary"end
  lines[#lines+1]="entry\n"..text
 end
 local body=table.concat(lines,"")
 return "MORTIS_CREATOR_LIBRARY=1\nrevision="..revision.."\nchecksum="..Model.checksum(body).."\n"..body
end
local function unpackLibrary(raw)
 if type(raw)~="string" or #raw>Store.MAX_BYTES then return nil,"CorruptLibrary"end
 local header,revision,checksum,body=raw:match("^([^\n]+)\nrevision=(%d+)\nchecksum=(%d+)\n(.*)$")
 if not header then return nil,"CorruptLibrary"end
 if header~="MORTIS_CREATOR_LIBRARY=1"then return nil,"FutureLibrary"end
 revision=tonumber(revision)
 if not revision or revision<1 or revision>2147483647 or tonumber(checksum)~=Model.checksum(body)then return nil,"CorruptLibrary"end
 local records,count,current={},0,nil
 local function finish()
  if not current then return true end
  local text=table.concat(current,"\n").."\n"
  if text:match("^MORTIS_CREATOR=(%d+)")~="1"then return false,"FutureLibrary"end
  local d=Model.deserialize(text)
  if not d or records[d.id]then return false,"CorruptLibrary"end
  records[d.id]=d;return true
 end
 for line in body:gmatch("([^\n]*)\n")do
  if line=="entry"then
   local ok,err=finish();if not ok then return nil,err end
   count=count+1;if count>Store.MAX_ENTRIES then return nil,"CorruptLibrary"end
   current={}
  else
   if not current or #current>=#Model.fields+1 then return nil,"CorruptLibrary"end
   current[#current+1]=line
  end
 end
 local ok,err=finish();if not ok then return nil,err end
 if body~="" and body:sub(-1)~="\n"then return nil,"CorruptLibrary"end
 return {records=records,revision=revision,raw=raw}
end
function Store.new(io)
 local self={io=io or Native}
 function self:load()
  local slots,missing={},0
  for i,name in ipairs(names)do
   local raw,err=self.io.read(name,Store.MAX_BYTES,MAX_LINES)
   if raw==nil then
    if err~="Missing"then return nil,err or "ReadFailed"end
    missing=missing+1
   else
    local value,reason=unpackLibrary(raw)
    if reason=="FutureLibrary"then return nil,reason end
    if value then value.slot=i;slots[#slots+1]=value end
   end
  end
  if #slots==0 then
   if missing==2 then return {records={},revision=0}end
   return nil,"CorruptLibrary"
  end
  if #slots==2 and slots[1].revision==slots[2].revision and slots[1].raw~=slots[2].raw then return nil,"ConflictingLibrary"end
  local result=slots[1]
  if slots[2] and slots[2].revision>result.revision then result=slots[2]end
  return result
 end
 function self:save(records,expectedRevision)
  local prior,err=self:load();if not prior then return nil,err end
  if prior.revision~=expectedRevision then return nil,"StaleLibrary"end
  if prior.revision>=2147483647 then return nil,"LibraryFull"end
  local raw,reason=pack(records,prior.revision+1);if not raw then return nil,reason end
  if #raw>Store.MAX_BYTES then return nil,"LibraryFull"end
  local slot=prior.slot==1 and 2 or 1
  local wrote,writeError=self.io.write(names[slot],raw)
  if not wrote then return nil,writeError or "WriteFailed"end
  local actual=self.io.read(names[slot],Store.MAX_BYTES,MAX_LINES)
  if actual~=raw then return nil,"WriteFailed"end
  local checked=unpackLibrary(actual);if not checked then return nil,"WriteFailed"end
  checked.slot=slot;return checked
 end
 function self:export(draft)
  local code,d=Model.export(draft);if not code then return nil,"InvalidDefinition",d end
  local name="MORTIS_ZombieCreator_"..d.id.."_"..tostring(Model.checksum(code))..".lua"
  local prior,err=self.io.read(name,32768,128)
  if prior==code then return name end
  if prior~=nil then return nil,"ExportConflict"end
  if err~="Missing"then return nil,err or "ReadFailed"end
  local ok,reason=self.io.write(name,code);if not ok then return nil,reason or "WriteFailed"end
  if self.io.read(name,32768,128)~=code then return nil,"WriteFailed"end
  return name
 end
 return self
end
return Store
