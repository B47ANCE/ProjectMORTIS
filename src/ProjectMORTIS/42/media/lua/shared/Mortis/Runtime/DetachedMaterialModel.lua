local Util=require "Mortis/Core/Util"
local Tissue=require "Mortis/Runtime/TissueModel"

local Model={MAX_REGIONS=32,MAX_TRANSACTION_ID=128}
local NUTRIENTS={"calories","carbohydrates","lipids","proteins"}

local function descendant(regions,id,root)
    local current,seen=id,{}
    for _=1,Model.MAX_REGIONS do
        if current==root then return true end
        if seen[current] then return false end;seen[current]=true
        local entry=regions[current];current=entry and entry.parent or nil
        if not current then return false end
    end
    return false
end

local function totals(regions)
    local result={capacity=0,remaining=0,viable=0,edible=0,
        nutrition={calories=0,carbohydrates=0,lipids=0,proteins=0}}
    local count=0
    for id,entry in pairs(regions or {}) do
        count=count+1;if count>Model.MAX_REGIONS then return nil,"detached subtree budget exceeded" end
        if type(id)~="string" or type(entry)~="table" or entry.regionId~=id then return nil,"invalid detached region" end
        local snapshot,err=Tissue.snapshot(entry.material);if not snapshot then return nil,err end
        for _,key in ipairs({"capacity","remaining","viable","edible"}) do result[key]=result[key]+snapshot[key] end
        for _,key in ipairs(NUTRIENTS) do result.nutrition[key]=result.nutrition[key]+snapshot.nutrition[key] end
    end
    if count==0 then return nil,"empty detached subtree" end
    return result
end

function Model.validate(record)
    if type(record)~="table" or type(record.subtree)~="table" then return false,"detached subtree required" end
    local tree=record.subtree
    if tree.schemaVersion~=1 or type(tree.rootRegionId)~="string" or type(tree.regions)~="table"
        or not tree.regions[tree.rootRegionId] then return false,"invalid detached subtree" end
    local computed,err=totals(tree.regions);if not computed then return false,err end
    return true,computed
end

local function refresh(record)
    local computed,err=totals(record.subtree.regions);if not computed then return nil,err end
    record.subtree.totals=computed
    local root=record.subtree.regions[record.subtree.rootRegionId]
    if root then record.tissue={capacity=root.material.capacity,remaining=root.material.remaining} end
    return record
end

function Model.applyLoss(record,regionId,request)
    local valid,err=Model.validate(record);if not valid then return nil,err end
    local result=Util.deepCopy(record)
    local region=result.subtree.regions[regionId]
    if not region then return nil,"detached region unavailable" end
    local material,receipt=Tissue.applyLoss(region.material,request)
    if not material then return nil,receipt end
    region.material=material
    local refreshed,refreshErr=refresh(result);if not refreshed then return nil,refreshErr end
    receipt.regionId=regionId
    return result,receipt
end

function Model.applyGain(record,regionId,request)
    local valid,err=Model.validate(record);if not valid then return nil,err end
    local result=Util.deepCopy(record)
    local region=result.subtree.regions[regionId]
    if not region then return nil,"detached region unavailable" end
    local material,receipt=Tissue.applyGain(region.material,request)
    if not material then return nil,receipt end
    region.material=material
    local refreshed,refreshErr=refresh(result);if not refreshed then return nil,refreshErr end
    receipt.regionId=regionId
    return result,receipt
end

function Model.withdraw(record,regionId,amount,request)
    local valid,err=Model.validate(record);if not valid then return nil,err end
    local result=Util.deepCopy(record)
    local region=result.subtree.regions[regionId]
    if not region then return nil,"detached region unavailable" end
    local material,withdrawn,receipt=Tissue.withdraw(region.material,amount,request)
    if not material then return nil,withdrawn end
    region.material=material
    local refreshed,refreshErr=refresh(result);if not refreshed then return nil,refreshErr end
    receipt.regionId=regionId
    return result,withdrawn,receipt
end

-- Pure plan for further anatomical division. The caller stages item creation
-- and persists both returned records; this function never mutates its input.
function Model.divide(record,regionId,transactionId)
    local valid,err=Model.validate(record);if not valid then return nil,err end
    if type(transactionId)~="string" or #transactionId==0 or #transactionId>Model.MAX_TRANSACTION_ID then
        return nil,"division transaction ID required"
    end
    if regionId==record.subtree.rootRegionId then return nil,"cannot divide the complete detached root" end
    if not record.subtree.regions[regionId] then return nil,"division region unavailable" end
    local source,child=Util.deepCopy(record),Util.deepCopy(record)
    source.metadata=type(source.metadata)=="table" and source.metadata or {}
    child.metadata=type(child.metadata)=="table" and child.metadata or {}
    local moved={}
    for id in pairs(record.subtree.regions) do
        if descendant(record.subtree.regions,id,regionId) then moved[id]=true end
    end
    for id in pairs(source.subtree.regions) do if moved[id] then source.subtree.regions[id]=nil end end
    for id in pairs(child.subtree.regions) do if not moved[id] then child.subtree.regions[id]=nil end end
    child.regionId=regionId;child.subtree.rootRegionId=regionId
    source.metadata.lastDivision={id=transactionId,regionId=regionId,role="source"}
    child.metadata.lastDivision={id=transactionId,regionId=regionId,role="child"}
    local sourceResult,sourceErr=refresh(source);if not sourceResult then return nil,sourceErr end
    local childResult,childErr=refresh(child);if not childResult then return nil,childErr end
    return sourceResult,childResult,{id=transactionId,regionId=regionId}
end

return Model
