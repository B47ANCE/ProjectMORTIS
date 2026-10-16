local allow=false
local attempts,detaches=0,0
local Profiles={
 applyLocomotion=function(_,_,_,retain)
  attempts=attempts+1
  if attempts==1 then assert(retain==true)end
  return allow,'restore unavailable'
 end,
}
package.loaded['Mortis/Runtime/ProfileRuntime']=Profiles
local Mortis=require 'Mortis/init'
Mortis.Types.register({id='Test.ClearMovement'})
local z={modData={}}
function z:getModData()return self.modData end
Mortis.Capabilities.observeZombie(z)
assert(Mortis.Identity.restore(z,'movement-clear','Test.ClearMovement'))
assert(Mortis.Persistence.writeIdentity(z,'movement-clear','Test.ClearMovement',false))
Mortis.Engine.onAssigned=function(entity,previous)
 assert(previous=='Test.ClearMovement' and Mortis.getTypeId(entity)==nil)
 detaches=detaches+1
 assert(Profiles.applyLocomotion(entity,nil,true))
end
local ok,reason=Mortis.clearAssignment(z)
assert(not ok and reason=='restore unavailable')
assert(Mortis.getTypeId(z)=='Test.ClearMovement' and detaches==0)
assert(z.modData.ProjectMORTIS.identity.typeId=='Test.ClearMovement')
assert(z.modData.ProjectMORTIS.assignmentClear==nil)
allow=true
assert(Mortis.clearAssignment(z))
assert(Mortis.getTypeId(z)==nil and detaches==1 and attempts==3)
assert(Mortis.clearAssignment(z) and detaches==1,'repeat clear must not replay detach/restoration')
print('Canonical clear preserves identity on restoration failure and completes on retry')
