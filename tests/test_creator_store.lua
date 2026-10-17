local Store=require 'Mortis/Creator/Store'
local Model=require 'Mortis/Creator/Model'
local files,writes={},0
local failWrite=false
local io={read=function(name)return files[name],files[name]==nil and 'Missing' or nil end,
 write=function(name,text)
  writes=writes+1
  if failWrite then files[name]=text:sub(1,23);return false,'WriteFailed'end
  files[name]=text;return true
 end}
local store=Store.new(io)
local initial=assert(store:load());assert(initial.revision==0)
local d=Model.new();local records={[d.id]=d}
local first=assert(store:save(records,0));assert(first.revision==1)
local a=files['MORTIS_ZombieCreator_Drafts_A.txt']
failWrite=true;d.displayName='Changed'
assert(not store:save(records,1))
assert(files['MORTIS_ZombieCreator_Drafts_A.txt']==a)
assert(store:load().records[d.id].displayName=='Custom Zombie')
failWrite=false
local second=assert(store:save(records,1));assert(second.revision==2)
local count=writes;assert(not store:save(records,1) and writes==count,'stale save must not write')
local name=assert(store:export(d));assert(name:match('^MORTIS_ZombieCreator_MyZombies%.CustomZombie_%d+%.lua$'))
count=writes;assert(store:export(d)==name and writes==count,'identical export is read-only')
files[name]='foreign contents';assert(not store:export(d) and files[name]=='foreign contents')
files['MORTIS_ZombieCreator_Drafts_A.txt']='MORTIS_CREATOR_LIBRARY=2\nrevision=3\nchecksum=0\n'
assert(not store:load(),'future checkpoint must not be overwritten using an older slot')
local corrupted=Store.new({read=function()return 'broken' end,write=function()error('must not write')end})
assert(not corrupted:load() and not corrupted:save(records,0))
local oldReader,oldWriter=getFileReader,getFileWriter
getFileReader=nil;getFileWriter=nil
assert(not Store.new():load() and not Store.new():save(records,0))
local closed=false
getFileReader=function(_,create)
 assert(create==false,'reading must not create a file')
 return {readLine=function()error('read fault')end,close=function()closed=true end}
end
assert(not Store.new():load() and closed,'reader must close even when reading fails')
getFileReader=oldReader;getFileWriter=oldWriter
print('Alternating draft checkpoints, stale writes, export preservation and native boundary failures pass')
