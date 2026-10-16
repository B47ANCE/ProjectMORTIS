local mocks={
    ['Mortis/Runtime/WeaponCatalog']={formatReviewReport=function() return 'weapons' end},
    ['Mortis/Core/Diagnostics']={snapshot=function() return {errors=0} end},
    ['Mortis/Runtime/Identity']={
        getStableId=function() return 'MORTIS-TEST' end,
        getTypeId=function() return 'Test.Type' end,
        getType=function() return {displayName='Test Threat'} end,
    },
    ['Mortis/Runtime/Authority']={mode=function() return 'singleplayer' end},
    ['Mortis/Runtime/Adapters/StateAdapter']={snapshot=function() return {nativeState='walk'} end},
    ['Mortis/Runtime/AnatomyRuntime']={snapshot=function() return {speciesId='Mortis.Humanoid'} end},
}
for _,name in ipairs({
    'Mortis/API/Types','Mortis/API/Traits','Mortis/API/Behaviors',
    'Mortis/API/LocomotionProfiles','Mortis/API/DurabilityProfiles','Mortis/API/AppearanceProfiles',
    'Mortis/API/CollisionProfiles','Mortis/API/BalanceProfiles','Mortis/API/Species','Mortis/API/TraumaChannels',
}) do mocks[name]={all=function() return {['Test.Entry']={id='Test.Entry'}} end} end
local realRequire=require
require=function(name) return mocks[name] or realRequire(name) end
local written=''
getFileWriter=function()
    return {write=function(_,value) written=written..value end,close=function() end}
end

local Reports=dofile(arg[1])
local entity={
    getOnlineID=function() return 7 end,
    getX=function() return 10 end,getY=function() return 20 end,getZ=function() return 0 end,
    getHealth=function() return 0.75 end,getTarget=function() return nil end,
}
local formatted,inspection=Reports.formatEntityInspection(entity)
assert(inspection.stableId=='MORTIS-TEST' and inspection.typeId=='Test.Type')
assert(formatted:find('nativeState.nativeState=walk',1,true),'native state must be flattened')
local ok,name=Reports.exportEntityInspection(entity,'inspect.txt')
assert(ok and name=='inspect.txt' and written:find('MORTIS Entity Inspection',1,true))
written=''
local registryOk=Reports.exportRegistries('registries.txt')
assert(registryOk and written:find('types.Test.Entry.id=Test.Entry',1,true),'registry dump must include definitions')
print('MORTIS developer inspection/report checks passed')
