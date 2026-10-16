local Anatomy=require "Mortis/Runtime/AnatomyRuntime"
local Detached=require "Mortis/API/DetachedParts"

local Material={}

local function request(value,mechanism)
    if type(value)~="table" then return nil,"material transaction request required" end
    local result={}
    for key,item in pairs(value) do result[key]=item end
    result.mechanism=mechanism
    return result
end

function Material.decomposeEntity(entity,regionId,value,options)
    local normalized,err=request(value,"decomposition");if not normalized then return nil,err end
    return Anatomy.applyMaterialLoss(entity,regionId,normalized,options)
end

function Material.harvestEntity(entity,regionId,amount,value,options)
    local normalized,err=request(value,"harvesting");if not normalized then return nil,err end
    return Anatomy.withdrawMaterial(entity,regionId,amount,normalized,options)
end

function Material.feedFromEntity(entity,regionId,amount,value,options)
    local normalized,err=request(value,"feeding");if not normalized then return nil,err end
    return Anatomy.withdrawMaterial(entity,regionId,amount,normalized,options)
end

function Material.regenerateEntity(entity,regionId,value,options)
    local normalized,err=request(value,"regeneration");if not normalized then return nil,err end
    return Anatomy.applyMaterialGain(entity,regionId,normalized,options)
end

function Material.decomposeDetached(item,regionId,value)
    local normalized,err=request(value,"decomposition");if not normalized then return nil,err end
    return Detached.applyMaterialLoss(item,regionId,normalized)
end

function Material.harvestDetached(item,regionId,amount,value)
    local normalized,err=request(value,"harvesting");if not normalized then return nil,err end
    return Detached.withdrawMaterial(item,regionId,amount,normalized)
end

function Material.feedFromDetached(item,regionId,amount,value)
    local normalized,err=request(value,"feeding");if not normalized then return nil,err end
    return Detached.withdrawMaterial(item,regionId,amount,normalized)
end

function Material.regenerateDetached(item,regionId,value)
    local normalized,err=request(value,"regeneration");if not normalized then return nil,err end
    return Detached.applyMaterialGain(item,regionId,normalized)
end

return Material
