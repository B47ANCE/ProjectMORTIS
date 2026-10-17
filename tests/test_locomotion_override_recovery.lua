-- Actual owner stack, baseline, components and persistence; native boundary mocked.
local authority=true
isServer=function()return authority end
isClient=function()return not authority end
package.loaded['Mortis/API/Capabilities']={has=function()return true end}
package.loaded['Mortis/Core/Logger']={rateLimited=function()end,once=function()end,warn=function()end}
package.loaded['Mortis/Core/Profiler']={measure=function(_,fn)return fn()end}
local Util=require 'Mortis/Core/Util'
local Schemas=require 'Mortis/API/Components'
local Components=require 'Mortis/Runtime/Components'
local Persistence=require 'Mortis/Runtime/Persistence'
local failSave=false
Schemas.register({id='Mortis.ProfileState',version=1,persistence='save',replication='none',defaults={},
 serialize=function(value)if failSave then error('checkpoint unavailable')end;return value end})
Schemas.register({id='Mortis.LocomotionOverrideBaseline',version=1,persistence='save',replication='none',
 serialize=function(value)if failSave then error('checkpoint unavailable')end;return value end})
local classes={slowModded=3,slow1=3,['1']=2,sprint1=1}
IsoZombie={getSpeedTypeFromWalkType=function(walk)return classes[walk]end}
local function fixture(data)
 local z={walk='slowModded',category=3,scalar=1.4,crawler=false,variant=7,writes=0,data=data or {}}
 function z:getModData()return self.data end
 function z:getWalkType()return self.walk end
 function z:getSpeedType()return self.category end
 function z:getSpeedMod()return self.scalar end
 function z:isCrawling()return self.crawler end
 function z:getCrawlerType()return self.variant end
 function z:isOnFloor()return self.onFloor or false end
 function z:isGettingUp()return self.gettingUp or false end
 function z:getCurrentState()return self.nativeState or 'ZombieWalkTowardState' end
 function z:setWalkType(v)self.walk=v;self.writes=self.writes+1 end
 function z:setSpeedTypeFromWalkType()self.category=classes[self.walk];self.writes=self.writes+1 end
 function z:setSpeedMod(v)
  if self.ignoreRestore then return end
  self.scalar=v;self.writes=self.writes+1
 end
 function z:setCrawler(v)self.crawler=v;self.writes=self.writes+1 end
 function z:setCrawlerType(v)self.variant=v;self.writes=self.writes+1 end
 local function tier(actor,walk)
  local persisted=actor.data.ProjectMORTIS and actor.data.ProjectMORTIS.components
  assert(persisted and ((persisted['Mortis.LocomotionOverrideBaseline'] and persisted['Mortis.LocomotionOverrideBaseline'].data.baseline)
   or (persisted['Mortis.ProfileState'] and persisted['Mortis.ProfileState'].data.locomotion.baseline)),
   'baseline checkpoint must precede the native tier write')
  if actor.ignoreTier then return end
  actor.walk=walk;actor.category=classes[walk];actor.scalar=.75;actor.variant=0;actor.writes=actor.writes+1
  if actor.failTier then error('tier helper failed after partial mutation')end
 end
 function z:doSprinter()tier(self,'sprint1')end
 function z:doFastShambler()tier(self,'1')end
 function z:doShambler()tier(self,'slow1')end
 return z
end
local Overrides=require 'Mortis/Runtime/LocomotionOverrides'
local z=fixture()
assert(Overrides.acquire(z,'UV',{tier='fastShambler',priority=20}))
assert(Overrides.acquire(z,'High',{tier='sprinter',priority=40}))
assert(Overrides.release(z,'UV') and z.category==1)
assert(Overrides.release(z,'High'))
assert(z.walk=='slowModded' and z.category==3 and z.scalar==1.4 and z.variant==7,
 'last release must restore every observed baseline field, not just walk/class')
local before=z.writes
assert(Overrides.clear(z) and z.writes==before,'repeated cleanup must not write')

z=fixture();assert(Overrides.acquire(z,'Low',{tier='shambler'}))
before=z.writes;assert(Overrides.acquire(z,'Low',{tier='shambler'}));assert(z.writes==before)
assert(Overrides.setCeiling(z,'Cap','fastShambler'))
assert(Overrides.acquire(z,'High',{tier='sprinter',priority=40}) and z.category==2)
assert(Overrides.releaseCeiling(z,'Cap') and z.category==1)
assert(Overrides.clear(z) and z.scalar==1.4)

z=fixture();assert(Overrides.setCeiling(z,'Passive','fastShambler'))
assert(z.data.ProjectMORTIS.components['Mortis.LocomotionOverrideBaseline'],
 'passive ceilings retain a journal so profile writers know movement is owned')
assert(Overrides.acquire(z,'Later',{tier='sprinter'}) and z.category==2,
 'a previously passive ceiling must still checkpoint before its first effective write')
assert(Overrides.clear(z) and z.scalar==1.4)
z=fixture();assert(Overrides.setCeiling(z,'Passive','fastShambler'))
assert(Overrides.releaseCeiling(z,'Passive'))
assert(z.data.ProjectMORTIS.components['Mortis.LocomotionOverrideBaseline']==nil,
 'last passive release clears its journal despite an unchanged baseline signature')

for _,flag in ipairs({'onFloor','gettingUp','nativeState','missingState'})do
 z=fixture()
 if flag=='nativeState' then z.nativeState='ZombieAttackState'
 elseif flag=='missingState' then z.getCurrentState=function()return nil end
 else z[flag]=true end
 assert(not Overrides.acquire(z,'Busy',{tier='sprinter'}),'unsafe or unknown state must refuse mutation')
 assert(z.writes==0)
end
z=fixture();z.getSpeedMod=nil
assert(not Overrides.acquire(z,'Missing',{tier='sprinter'}) and z.writes==0)
z=fixture();failSave=true
assert(not Overrides.acquire(z,'SaveFailure',{tier='sprinter'}) and z.writes==0)
failSave=false;require('Mortis/Core/FaultIsolation').resetAll()
assert(Overrides.acquire(z,'SaveFailure',{tier='sprinter'}))
assert(Overrides.clear(z) and z.scalar==1.4)

z=fixture();z.ignoreTier=true
assert(not Overrides.acquire(z,'Ignored',{tier='sprinter'}),'native acceptance without changed category must fail')
z.ignoreTier=false;assert(Overrides.clear(z))
z=fixture();z.failTier=true
assert(not Overrides.acquire(z,'Partial',{tier='sprinter'}))
before=z.writes
assert(not Overrides.acquire(z,'Retry',{tier='shambler'}) and z.writes==before,
 'uncertain native failure requires explicit coordinated cleanup')
z.failTier=false;assert(Overrides.clear(z) and z.scalar==1.4)

z=fixture();assert(Overrides.acquire(z,'RestoreFailure',{tier='sprinter'}))
z.ignoreRestore=true;assert(not Overrides.release(z,'RestoreFailure'))
assert(Components.allFor(z)['Mortis.LocomotionOverrideBaseline']~=nil,'failed restore keeps journal')
z.ignoreRestore=false;assert(Overrides.clear(z) and z.scalar==1.4)

-- Disposable saved component + wrapper/module replacement, never a real save.
z=fixture();assert(Overrides.acquire(z,'Saved',{tier='sprinter'}))
local saved=Util.deepCopy(z.data)
local replacement=fixture(saved);replacement.walk=z.walk;replacement.category=z.category;replacement.scalar=z.scalar;replacement.variant=z.variant
package.loaded['Mortis/Runtime/LocomotionOverrides']=nil
Overrides=require 'Mortis/Runtime/LocomotionOverrides'
before=replacement.writes
assert(not Overrides.acquire(replacement,'BeforeLoad',{tier='shambler'}),'unloaded saved profile data must not be overwritten')
Persistence.loadComponents(replacement)
assert(not Overrides.acquire(replacement,'AfterLoad',{tier='shambler'}),'do not recapture modified native values after owner loss')
assert(not Overrides.release(replacement,'Saved'),'a lost owner stack cannot authenticate individual release')
authority=false
assert(not Overrides.clear(replacement) and replacement.writes==before)
authority=true
assert(Overrides.clear(replacement) and replacement.scalar==1.4 and replacement.walk=='slowModded')
assert(replacement.data.ProjectMORTIS.components['Mortis.LocomotionOverrideBaseline']==nil)
assert(Overrides.acquire(replacement,'Fresh',{tier='fastShambler'}));assert(Overrides.clear(replacement))

-- Type-profile reconciliation must not act as a second locomotion writer.
local Profiles=require 'Mortis/Runtime/ProfileRuntime'
z=fixture()
local typeDef={locomotion={tier='fastShambler'}}
assert(Profiles.applyLocomotion(z,typeDef,true) and z.category==2)
assert(Overrides.acquire(z,'Temporary',{tier='sprinter'}) and z.category==1)
before=z.writes
require('Mortis/Core/Scheduler').frame=1000
assert(not Profiles.reconcile(z,typeDef) and z.writes==before and z.category==1,
 'periodic type-profile reconciliation must not overwrite an active override')
assert(not Profiles.applyLocomotion(z,nil,true,true) and z.writes==before,
 'assignment clear must wait for coordinated owner release')
assert(Overrides.release(z,'Temporary') and z.category==2)
assert(Profiles.applyLocomotion(z,nil,true) and z.category==3 and z.scalar==1.4)
z=fixture();assert(Overrides.setCeiling(z,'Passive','fastShambler'));before=z.writes
assert(not Profiles.applyLocomotion(z,typeDef,true) and z.writes==before,'passive constraints also exclude profile writers')
assert(Overrides.releaseCeiling(z,'Passive'))
assert(Profiles.applyLocomotion(z,typeDef,true));assert(Profiles.applyLocomotion(z,nil,true))

z=fixture();Components.set(z,'Mortis.ProfileState',{other='retained'})
assert(Overrides.acquire(z,'DeleteFailure',{tier='sprinter'}))
failSave=true;assert(not Overrides.release(z,'DeleteFailure'))
assert(Components.allFor(z)['Mortis.LocomotionOverrideBaseline']~=nil,'failed journal deletion retains recovery state')
failSave=false;require('Mortis/Core/FaultIsolation').resetAll()
assert(Overrides.clear(z) and z.scalar==1.4)
for _,invalid in ipairs({false,{version=2,baseline={}},{version=1,baseline={walkType='guessed'}}})do
 z=fixture();Components.set(z,'Mortis.LocomotionOverrideBaseline',invalid)
 assert(not Overrides.acquire(z,'Corrupt',{tier='sprinter'}))
 assert(not Overrides.clear(z) and z.writes==0,'malformed/newer journals must not be silently reset')
end
z=fixture();Components.set(z,'Mortis.ProfileState',{other={retained=42}})
assert(Overrides.acquire(z,'Preserve',{tier='sprinter'}));assert(Overrides.clear(z))
assert(Components.allFor(z)['Mortis.ProfileState'].other.retained==42,'unrelated profile state must survive checkpoints')
authority=false;before=z.writes
assert(not Overrides.acquire(z,'Client',{tier='sprinter'}))
assert(not Overrides.setCeiling(z,'Client','shambler'))
assert(not Overrides.release(z,'Client') and not Overrides.releaseCeiling(z,'Client'))
assert(not require('Mortis/Runtime/LocomotionOverrideStore').write(z,{}))
assert(z.writes==before)
authority=true
z=fixture({ProjectMORTIS={components={['Mortis.ProfileState']={version=1,data={other={retained=99}}}}}})
assert(not Overrides.acquire(z,'Early',{tier='sprinter'}) and z.writes==0)
assert(z.data.ProjectMORTIS.components['Mortis.ProfileState'].data.other.retained==99)
Persistence.loadComponents(z)
assert(Overrides.acquire(z,'Loaded',{tier='sprinter'}));assert(Overrides.clear(z))
assert(Components.allFor(z)['Mortis.ProfileState'].other.retained==99)
print('Override checkpoints, observed restoration, readback, busy admission and owner-loss recovery pass offline')
