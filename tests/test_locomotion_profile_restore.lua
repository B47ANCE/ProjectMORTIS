local Util=require 'Mortis/Core/Util'
local state={locomotion={},durability={},appearance={}}
local authority=true
local captured,restored,changes,flushes=0,0,0,0
local busy,failFlush,failRestore=false,false,false
local native={walk='original',speed=0.7}
package.loaded['Mortis/Runtime/Components']={get=function()return state end,set=function(_,_,v)state=v end,setRestored=function()error('client must not write movement state')end}
package.loaded['Mortis/Runtime/Authority']={canWriteCanonicalState=function()return authority end}
package.loaded['Mortis/Runtime/Adapters/StateAdapter']={isBusy=function()return busy end}
package.loaded['Mortis/Runtime/Persistence']={flushComponents=function()flushes=flushes+1;return not failFlush,'cache failure' end}
package.loaded['Mortis/Runtime/LocomotionBaseline']={
 capture=function()captured=captured+1;return{version=1,walk=native.walk,speed=native.speed}end,
 restore=function(_,b)restored=restored+1;if failRestore then return false,'native failure' end;native.walk=b.walk;native.speed=b.speed;return true end,
}
package.loaded['Mortis/Runtime/Adapters/LocomotionAdapter']={
 matches=function()return true end,
 setTier=function(_,tier)
  if tier=='shambler' then assert(native.walk=='original' and native.speed==0.7,'profile replacement must begin from original observed fields')end
  changes=changes+1;native.walk='changed';native.speed=2;return true
 end,
}
local Runtime=require 'Mortis/Runtime/ProfileRuntime'
local z={}
local profile={locomotion={tier='sprinter'}}
assert(Runtime.applyLocomotion(z,profile,true))
assert(captured==1 and flushes>=1 and native.speed==2)
assert(Runtime.applyLocomotion(z,{locomotion={tier='shambler'}},true))
assert(Runtime.applyLocomotion(z,profile,true))
assert(captured==1,'reconciliation must retain the original baseline')
-- Simulate serialized component reload into a fresh native wrapper.
state=Util.deepCopy(state)
assert(Runtime.applyLocomotion({},nil,true))
assert(native.walk=='original' and native.speed==0.7)
local before=restored
assert(Runtime.applyLocomotion(z,nil,true) and restored==before,'repeat clear is idempotent')
assert(Runtime.applyLocomotion(z,profile,true))
busy=true
assert(not Runtime.applyLocomotion(z,nil,true),'clear must defer during native transitions even when forced')
busy=false;failRestore=true
assert(not Runtime.applyLocomotion(z,nil,true))
assert(state.locomotion.baseline~=nil,'failed restore retains saved original state')
failRestore=false
assert(Runtime.applyLocomotion(z,nil,true))
assert(Runtime.applyLocomotion(z,profile,true))
assert(Runtime.applyLocomotion(z,nil,true,true))
native.walk='released-owner';native.speed=1.5
assert(Runtime.applyLocomotion(z,nil,true))
assert(native.walk=='original' and native.speed==0.7,'retain original through detach callbacks')
failFlush=true;before=changes
assert(not Runtime.applyLocomotion(z,profile,true))
assert(changes==before,'baseline checkpoint failure must precede native mutation')
local count=captured
failFlush=false
assert(Runtime.applyLocomotion(z,profile,true) and captured==count,'retry must not recapture a changed baseline')
authority=false;before=changes
assert(Runtime.applyLocomotion(z,nil,true) and changes==before)
authority=true
state={locomotion={signature='old-build-profile'},durability={},appearance={}}
assert(not Runtime.applyLocomotion(z,nil,true),'legacy baseline must not be guessed')
assert(not Runtime.applyLocomotion(z,profile,true),'legacy active profile cannot capture itself as original')
print('Profile baseline persistence, legacy rejection, authority, busy-state and retry tests passed')
