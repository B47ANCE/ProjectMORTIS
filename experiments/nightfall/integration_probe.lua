-- Actual first-party modules in a host VM; native zombie methods are modeled.
isClient=function()return false end
isServer=function()return false end
getGameTime=function()return {getWorldAgeHours=function()return 100 end}end
local M=require 'Mortis/init'
local Integration=require 'ProjectNightfall/PN_MortisIntegration'
local Profiles=require 'Mortis/Runtime/ProfileRuntime'
local classes={slowModded=3,slow1=3,['1']=2,sprint1=1}
IsoZombie={getSpeedTypeFromWalkType=function(walk)return classes[walk]end}
local function fixture(id,untyped)
    local z={data={},walk='slowModded',category=3,scalar=1.4,crawler=false,variant=7}
    function z:getModData()return self.data end
    function z:getWalkType()return self.walk end
    function z:getSpeedType()return self.category end
    function z:getSpeedMod()return self.scalar end
    function z:isCrawling()return self.crawler end
    function z:getCrawlerType()return self.variant end
    function z:isOnFloor()return self.onFloor==true end
    function z:isGettingUp()return false end
    function z:getCurrentState()return 'ZombieWalkTowardState' end
    function z:setWalkType(v)self.walk=v end
    function z:setSpeedTypeFromWalkType()self.category=classes[self.walk]end
    function z:setSpeedMod(v)self.scalar=v end
    function z:setCrawler(v)self.crawler=v end
    function z:setCrawlerType(v)self.variant=v end
    function z:doShambler()self.walk='slow1';self.category=3;self.scalar=.75 end
    function z:doFastShambler()self.walk='1';self.category=2;self.scalar=.75 end
    function z:doSprinter()self.walk='sprint1';self.category=1;self.scalar=.75 end
    M.Capabilities.observeZombie(z)
    if untyped then M.Identity.ensureStableId(z)
    else
        assert(M.Identity.restore(z,id,Integration.TYPE_FERAL))
        assert(M.Persistence.writeIdentity(z,id,Integration.TYPE_FERAL,false))
    end
    return z
end
local z=fixture('audit-lease')
assert(Integration.setNightfallBaseSpeed(z,'fastShambler'))
local clear,clearReason=Integration.clear(z)
local ownedType=M.getTypeId(z)
local released,releaseReason=Integration.setNightfallBaseSpeed(z,nil)
local profileAfterRelease=Profiles.applyLocomotion(z,nil,true,true)
local busy=fixture('audit-busy')
assert(Integration.setUVSlowed(busy,true))
busy.onFloor=true
local busyRelease,busyReason=Integration.setUVSlowed(busy,false)
local busyJournal=M.Components.allFor(busy)['Mortis.LocomotionOverrideBaseline']~=nil
local disable=fixture('audit-disable')
assert(Integration.setNightfallBaseSpeed(disable,'fastShambler'))
local disableState={phase='FERAL',smartFeral=true}
local disableBranch=assert(loadstring('return function(z,s,MortisIntegration,setSprint) '.._auditDisableBody..' end'))()
disableBranch(disable,disableState,Integration,function()end)
local slowState={uvSlowed=true}
local slowBranch=assert(loadstring('return function(z,s,MortisIntegration) '.._auditSlowBody..' end'))()
slowBranch(busy,slowState,Integration)
local failed=fixture('audit-compensation',true)
-- Assignment may commit identity before the consumer's nutrition step fails.
-- Inject only that downstream provider failure; use real MORTIS assignment/clear.
assert(Integration.setNightfallBaseSpeed(failed,'fastShambler'))
local nutrition=M.Anatomy.applyNutritionProfile
M.Anatomy.applyNutritionProfile=function()return nil,'audit nutrition refusal'end
local assigned,assignmentReason=Integration.assign(failed,Integration.TYPE_SMART_FERAL)
M.Anatomy.applyNutritionProfile=nutrition
local afterFailure=M.getTypeId(failed)
local Diagnostics=require 'ProjectNightfall/PN_DependencyDiagnostics'
local Knowledge=require 'B47ANCEDKnowledgeAndWisdom/API'
isServer=function()return true end
local ready,missing,versions=Diagnostics.inspect(
    {registerBulb=function()end,UV={getSunlightExposure=function()end,getArtificialExposure=function()end}},
    {registerLoad=function()end},M,
    {getDetachedPartProvenance=function()end,performProcedure=function()end},Knowledge)
local permitted,guardReason=require('B47ANCEDKnowledgeAndWisdom/AuthorityGuard').write()
return {
    clear_while_owned=clear,clear_reason=clearReason,retained_type=ownedType,
    release_after_clear=released,release_reason=releaseReason,profile_after_release=profileAfterRelease,
    busy_release=busyRelease,busy_reason=busyReason,busy_journal_retained=busyJournal,
    phase_after_failed_clear=disableState.phase,type_after_failed_clear=M.getTypeId(disable),
    slow_flag_after_failed_release=slowState.uvSlowed,
    failed_assignment=assigned,assignment_reason=assignmentReason,type_after_failed_assignment=afterFailure,
    prior_type='vanilla/untyped',requested_type=Integration.TYPE_SMART_FERAL,
    diagnostic_admitted=ready,missing_count=#missing,mortis_version=versions.ProjectMORTIS,
    mortis_api=versions.MortisAPI,knowledge_version=versions.B47ANCEDKnowledgeAndWisdom,
    dependency_mp_permitted=permitted,dependency_mp_reason=guardReason,
}
