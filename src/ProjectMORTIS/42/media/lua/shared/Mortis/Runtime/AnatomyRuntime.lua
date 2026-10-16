local Species = require "Mortis/API/Species"
local Resolvers = require "Mortis/API/EntityResolvers"
local Entity = require "Mortis/Runtime/Adapters/EntityAdapter"
local Authority = require "Mortis/Runtime/Authority"
local Util = require "Mortis/Core/Util"
local Tissue = require "Mortis/Runtime/TissueModel"

local Anatomy = {}
local KEY = "MORTIS_LIVING"
local stateByEntity = setmetatable({}, { __mode = "k" })
local SCHEMA=2

local function finite(value)
    return type(value)=="number" and value==value and value~=math.huge and value~=-math.huge
end

local function materialFrom(definition,stored)
    if type(stored)=="table" and type(stored.material)=="table" then
        local material=Util.deepCopy(stored.material)
        if Tissue.validate(material) then return material end
        return nil,"invalid persisted biological material"
    end
    local capacity=type(stored)=="table" and stored.tissueCapacity or nil
    local remaining=type(stored)=="table" and stored.remainingTissue or nil
    if finite(capacity) and capacity>0 and finite(remaining) and remaining>=0 and remaining<=capacity then
        -- Schema-1 had no viability/edibility distinction. Preserve its known
        -- material exactly; decomposition will subsequently refine these axes.
        return Tissue.new(capacity,{remaining=remaining,viable=remaining,edible=remaining,
            nutritionDensity=definition.tissueNutritionDensity})
    end
    return nil,"biological material unavailable"
end

local function projectCompatibility(region)
    if type(region.material)=="table" and Tissue.validate(region.material) then
        region.tissueCapacity=region.material.capacity
        region.remainingTissue=region.material.remaining
    else
        region.tissueCapacity=nil;region.remainingTissue=nil
    end
end

local function isCorpse(entity)
    local ok,name=pcall(function() return entity:getObjectName() end)
    return ok and name=="DeadBody"
end

local function storedAnatomy(entity)
    local data=Entity.getModData(entity)
    local root=data and data[KEY]
    if root~=nil and type(root)~="table" then return nil,"malformed anatomy storage root" end
    local stored=root and root.anatomy
    if stored~=nil and type(stored)~="table" then return nil,"malformed stored anatomy" end
    return stored
end

-- Corpses are historical state, not newly spawned living entities. Never fill
-- missing regions with fresh limbs, including after species-definition changes.
local function validateCorpseAnatomy(species,stored)
    if not stored or (stored.schemaVersion~=1 and stored.schemaVersion~=SCHEMA) or stored.speciesId~=species.id
        or stored.speciesVersion~=species.version or type(stored.regions)~="table" then
        return false,"corpse has no compatible persisted anatomy"
    end
    for id in pairs(species.regions) do
        local region=stored.regions[id]
        if type(region)~="table" or type(region.attached)~="boolean"
            or type(region.disabled)~="boolean" or type(region.destroyed)~="boolean"
            or type(region.integrity)~="number" or region.integrity~=region.integrity then
            return false,"corpse anatomy region unavailable: "..id
        end
    end
    return true
end

local function fresh(species)
    local state = { schemaVersion=SCHEMA, speciesId=species.id, speciesVersion=species.version, regions={}, metadata={} }
    for id, def in pairs(species.regions) do
        local material=def.tissueCapacity and assert(Tissue.new(def.tissueCapacity,{nutritionDensity=def.tissueNutritionDensity})) or nil
        state.regions[id] = {
            integrity=def.integrity, maxIntegrity=def.integrity,
            material=material,tissueCapacity=def.tissueCapacity, remainingTissue=def.tissueCapacity,
            attached=true, disabled=false, destroyed=false, trauma={}, wounds={}
        }
    end
    return state
end

local function restore(species, stored)
    local state = fresh(species)
    if type(stored) ~= "table" then return state end
    local repairId=type(stored.metadata)=="table" and stored.metadata.lastRepairTransactionId
    if type(repairId)=="string" and #repairId>0 and #repairId<=128 then
        state.metadata.lastRepairTransactionId=repairId
    end
    for id, def in pairs(species.regions) do
        -- Saved anatomy predates tissue tracking unless both fields were saved.
        -- Never refill an old living region or corpse from a new species default.
        state.regions[id].material=nil
        state.regions[id].tissueCapacity=nil
        state.regions[id].remainingTissue=nil
        local src = stored.regions and stored.regions[id]
        if type(src) == "table" then
            local dst = state.regions[id]
            local material=materialFrom(def,src)
            if material then
                dst.material=material
                projectCompatibility(dst)
                local capacity,remaining=dst.tissueCapacity,dst.remainingTissue
                local receipt=src.lastTissueLoss
                if type(receipt)=="table" and type(receipt.id)=="string" and #receipt.id>0 and #receipt.id<=128
                    and type(receipt.before)=="number" and receipt.before>remaining and receipt.before<=capacity
                    and type(receipt.amount)=="number" and receipt.amount>0 and receipt.amount<=receipt.before
                    and receipt.after==remaining and receipt.before-receipt.amount==remaining then
                    dst.lastTissueLoss=Util.deepCopy(receipt)
                end
            end
            dst.integrity = math.max(0, math.min(def.integrity, tonumber(src.integrity) or def.integrity))
            dst.attached = src.attached ~= false
            dst.disabled = src.disabled == true
            dst.destroyed = src.destroyed == true
            dst.trauma = type(src.trauma) == "table" and Util.deepCopy(src.trauma) or {}
            if type(src.wounds)=="table" then
                for woundId,wound in pairs(src.wounds) do
                    if type(woundId)=="string" and type(wound)=="table"
                        and type(wound.stage)=="number" and wound.stage>=1
                        and wound.stage<math.huge and wound.stage%1==0
                        and type(wound.magnitude)=="number" and wound.magnitude>=0
                        and wound.magnitude<math.huge and type(wound.channel)=="string" then
                        dst.wounds[woundId]={stage=wound.stage,magnitude=wound.magnitude,channel=wound.channel}
                    end
                end
            end
        end
    end
    state.schemaVersion=SCHEMA
    return state
end

local function save(entity, state, transmit)
    local data = Entity.getModData(entity)
    if not data then return false, "entity has no modData" end
    if data[KEY]~=nil and type(data[KEY])~="table" then return false,"malformed anatomy storage root" end
    data[KEY] = data[KEY] or {}
    for _,region in pairs(state.regions or {}) do projectCompatibility(region) end
    data[KEY].anatomy = Util.deepCopy(state)
    if transmit then Entity.transmitModData(entity) end
    return true
end

function Anatomy.resolveSpecies(entity)
    local state = stateByEntity[entity]
    if state then return state.speciesId, "runtime" end
    local stored,err = storedAnatomy(entity)
    if err then return nil,err end
    if stored and stored.speciesId and Species.has(stored.speciesId) then return stored.speciesId, "modData" end
    if isCorpse(entity) then return nil,"corpse has no known persisted species" end
    return Resolvers.resolve(entity)
end

function Anatomy.attach(entity, speciesId, options)
    options = options or {}
    if not entity then return nil, "entity required" end
    if not Authority.canWriteCanonicalState(entity) and not options.localOnly then return nil, "non-authority" end
    local species = Species.get(speciesId)
    if not species then return nil, "unknown species: " .. tostring(speciesId) end
    local stored,err = storedAnatomy(entity)
    if err then return nil,err end
    if isCorpse(entity) then
        local valid,reason=validateCorpseAnatomy(species,stored)
        if not valid then return nil,reason end
    end
    local state = stored and stored.speciesId == speciesId and restore(species, stored) or fresh(species)
    stateByEntity[entity] = state
    if options.persist ~= false then save(entity, state, options.transmit == true) end
    return state
end

function Anatomy.ensure(entity)
    local state = stateByEntity[entity]
    if state then return state end
    local speciesId,reason = Anatomy.resolveSpecies(entity)
    if not speciesId then return nil, reason or "no species resolver matched entity" end
    return Anatomy.attach(entity, speciesId, { localOnly = not Authority.canWriteCanonicalState(entity), persist=false })
end

function Anatomy.get(entity) return stateByEntity[entity] or Anatomy.ensure(entity) end

function Anatomy.getRegion(entity, region)
    local state, err = Anatomy.get(entity)
    if not state then return nil, err end
    local species = Species.get(state.speciesId)
    if not species then return nil, "missing species definition" end
    local id = Species.resolveRegion(species, region or species.defaultRegion)
    if not id then return nil, "unknown region: " .. tostring(region) end
    return state.regions[id], species.regions[id], id
end

function Anatomy.flush(entity, transmit)
    local state = stateByEntity[entity]
    if not state then return false, "no anatomy state" end
    return save(entity, state, transmit == true)
end

function Anatomy.snapshot(entity)
    local state = Anatomy.get(entity)
    return state and Util.deepCopy(state) or nil
end

local function descendantOf(species,id,rootId)
    local current,depth=id,0
    while current do
        if current==rootId then return true end
        local definition=species.regions[current]
        current=definition and definition.parent or nil
        depth=depth+1
        if depth>32 then return false end
    end
    return false
end

function Anatomy.subtreeSnapshot(entity,region)
    local state,err=Anatomy.get(entity);if not state then return nil,err end
    local species=Species.get(state.speciesId);if not species then return nil,"missing species definition" end
    local rootId=Species.resolveRegion(species,region or species.defaultRegion)
    local root=rootId and state.regions[rootId] or nil
    if not root then return nil,"unknown region: "..tostring(region) end
    if root.attached~=true then return nil,"subtree root detached" end
    local result={schemaVersion=1,speciesId=state.speciesId,speciesVersion=state.speciesVersion,
        rootRegionId=rootId,regions={},totals={capacity=0,remaining=0,viable=0,edible=0,
            nutrition={calories=0,carbohydrates=0,lipids=0,proteins=0}}}
    local count=0
    for id,part in pairs(state.regions) do
        if part.attached==true and descendantOf(species,id,rootId) then
            count=count+1;if count>32 then return nil,"anatomy subtree budget exceeded" end
            local material,materialErr=Tissue.snapshot(part.material)
            if not material then return nil,"subtree material unavailable: "..id..": "..tostring(materialErr) end
            result.regions[id]={regionId=id,parent=species.regions[id].parent,material=material,
                integrity=part.integrity,maxIntegrity=part.maxIntegrity,disabled=part.disabled==true,
                destroyed=part.destroyed==true,trauma=Util.deepCopy(part.trauma or {}),
                wounds=Util.deepCopy(part.wounds or {})}
            for _,key in ipairs({"capacity","remaining","viable","edible"}) do
                result.totals[key]=result.totals[key]+material[key]
            end
            for key,value in pairs(material.nutrition) do
                result.totals.nutrition[key]=result.totals.nutrition[key]+value
            end
        end
    end
    if not result.regions[rootId] then return nil,"subtree root material unavailable" end
    return result
end

-- Read-only tissue view for policy owners, including corpse disposal. Missing
-- regions contribute no on-body tissue; destroyed structure may still contain
-- soft tissue, so destroyed/integrity flags never substitute for tissue loss.
function Anatomy.tissueSnapshot(entity)
    local state,err=Anatomy.get(entity)
    if not state then return nil,err end
    local result={speciesId=state.speciesId,regions={},capacity=0,remaining=0}
    local count=0
    for id,region in pairs(state.regions) do
        count=count+1
        if count>32 then return nil,"tissue region budget exceeded" end
        if region.attached==false then
            result.regions[id]={attached=false}
        else
            local material=region.material
            if type(material)~="table" or not Tissue.validate(material) then
                return nil,"regional tissue unavailable: "..tostring(id)
            end
            local capacity,remaining=material.capacity,material.remaining
            result.regions[id]={attached=true,capacity=capacity,remaining=remaining,
                remainingFraction=remaining/capacity,weight=capacity,viable=material.viable,
                edible=material.edible,material=Tissue.snapshot(material)}
            result.capacity=result.capacity+capacity
            result.remaining=result.remaining+remaining
            if result.capacity==math.huge or result.remaining==math.huge then return nil,"tissue aggregate overflow" end
        end
    end
    result.remainingFraction=result.capacity>0 and result.remaining/result.capacity or 0
    return result
end

-- Canonical structural mutation used by procedure owners such as medWorks.
-- Descendants are detached with their parent so anatomy cannot retain an
-- attached hand below a severed arm. The mutation is rolled back if persistence
-- fails; item creation and medical consequences remain the caller's property.
function Anatomy.sever(entity, region, options)
    options=options or {}
    if not Authority.canWriteCanonicalState(entity) then return nil,"non-authority" end
    local state,err=Anatomy.get(entity)
    if not state then return nil,err end
    local species=Species.get(state.speciesId)
    local regionId=Species.resolveRegion(species,region)
    local definition=regionId and species.regions[regionId] or nil
    local regionState=regionId and state.regions[regionId] or nil
    if not definition or not regionState then return nil,"unknown region" end
    if definition.severable~=true then return nil,"region is not severable" end
    if regionState.attached==false then return nil,"region already detached" end
    local subtree,subtreeErr=Anatomy.subtreeSnapshot(entity,regionId)
    if not subtree then return nil,subtreeErr end
    local changed,previous={},{}
    for id,value in pairs(state.regions) do
        if descendantOf(species,id,regionId) then
            previous[id]={attached=value.attached,disabled=value.disabled,material=value.material,
                tissueCapacity=value.tissueCapacity,remainingTissue=value.remainingTissue}
            value.attached=false
            value.disabled=true
            value.material=nil
            projectCompatibility(value)
            changed[#changed+1]=id
        end
    end
    table.sort(changed)
    local ok,saveErr=save(entity,state,options.transmit==true)
    if not ok then
        for id,prior in pairs(previous) do
            state.regions[id].attached=prior.attached
            state.regions[id].disabled=prior.disabled
            state.regions[id].material=prior.material
            state.regions[id].tissueCapacity=prior.tissueCapacity
            state.regions[id].remainingTissue=prior.remainingTissue
        end
        return nil,saveErr
    end
    return {speciesId=state.speciesId,regionId=regionId,detachedRegions=changed,subtree=subtree}
end

function Anatomy.detach(entity) stateByEntity[entity] = nil end

-- Loss only: no implicit regeneration, structural damage, fire or death policy.
-- Expected remaining quantity provides stale-write protection even after the
-- last per-region receipt is superseded. Callers must retain it when retrying.
function Anatomy.consumeTissue(entity,region,amount,options)
    if not Authority.canWriteCanonicalState(entity) then return nil,"non-authority" end
    if type(options)~="table" or type(options.transactionId)~="string"
        or #options.transactionId==0 or #options.transactionId>128 then return nil,"tissue transaction ID required" end
    local expected=options.expectedRemaining
    if type(amount)~="number" or amount~=amount or amount<=0 or amount==math.huge
        or type(expected)~="number" or expected~=expected or expected<=0 or expected==math.huge
        or amount>expected then return nil,"invalid tissue loss request" end
    local state,err=Anatomy.get(entity)
    if not state then return nil,err end
    local part,definition,id=Anatomy.getRegion(entity,region)
    if not part then return nil,definition end
    local receipt=part.lastTissueLoss
    if type(receipt)=="table" and receipt.id==options.transactionId then
        if receipt.before~=expected or receipt.amount~=amount then return nil,"tissue transaction conflict" end
        local replay=Util.deepCopy(receipt);replay.replayed=true;replay.regionId=id
        return replay
    end
    if part.attached~=true then return nil,"tissue region detached" end
    local material=part.material
    if type(material)~="table" or not Tissue.validate(material) then
        return nil,"regional tissue unavailable"
    end
    local capacity,remaining=material.capacity,material.remaining
    if remaining~=expected then return nil,"stale tissue quantity" end
    local after=remaining-amount
    if after<0 or after>=remaining then return nil,"unrepresentable tissue loss" end
    local ratio=remaining>0 and amount/remaining or 0
    local nextMaterial,materialReceipt=Tissue.applyLoss(material,{transactionId=options.transactionId,
        expectedRevision=material.revision,remainingLoss=amount,viableLoss=material.viable*ratio,
        edibleLoss=material.edible*ratio,mechanism=options.mechanism or "legacy-consume"})
    if not nextMaterial then return nil,materialReceipt end
    local nextReceipt={id=options.transactionId,before=remaining,after=after,amount=amount}
    part.material=nextMaterial;projectCompatibility(part);part.lastTissueLoss=nextReceipt
    -- Persist first; synchronization is a separate boundary owned by the caller.
    local saved,saveError=save(entity,state,false)
    if not saved then
        part.material=material;projectCompatibility(part);part.lastTissueLoss=receipt
        return nil,saveError
    end
    local result=Util.deepCopy(nextReceipt);result.regionId=id
    return result
end

function Anatomy.materialSnapshot(entity,region)
    local part,definition,id=Anatomy.getRegion(entity,region)
    if not part then return nil,definition end
    if part.attached~=true then return nil,"tissue region detached" end
    local snapshot,err=Tissue.snapshot(part.material)
    if not snapshot then return nil,err end
    snapshot.regionId=id
    return snapshot
end

-- General monotonic biological transition. Authority/persistence stay here;
-- mechanism policy remains with consumers such as Nightfall and medWorks.
function Anatomy.applyMaterialLoss(entity,region,request,options)
    options=type(options)=="table" and options or {}
    if not Authority.canWriteCanonicalState(entity) then return nil,"non-authority" end
    local state,err=Anatomy.get(entity);if not state then return nil,err end
    local part,definition,id=Anatomy.getRegion(entity,region);if not part then return nil,definition end
    if part.attached~=true then return nil,"tissue region detached" end
    local previous=part.material
    local nextMaterial,receipt=Tissue.applyLoss(previous,request)
    if not nextMaterial then return nil,receipt end
    part.material=nextMaterial;projectCompatibility(part)
    local saved,saveErr=save(entity,state,options.transmit==true)
    if not saved then part.material=previous;projectCompatibility(part);return nil,saveErr end
    receipt.regionId=id
    return receipt
end

function Anatomy.applyMaterialGain(entity,region,request,options)
    options=type(options)=="table" and options or {}
    if not Authority.canWriteCanonicalState(entity) then return nil,"non-authority" end
    local state,err=Anatomy.get(entity);if not state then return nil,err end
    local part,definition,id=Anatomy.getRegion(entity,region);if not part then return nil,definition end
    if part.attached~=true then return nil,"tissue region detached" end
    local previous=part.material
    local nextMaterial,receipt=Tissue.applyGain(previous,request)
    if not nextMaterial then return nil,receipt end
    part.material=nextMaterial;projectCompatibility(part)
    local saved,saveErr=save(entity,state,options.transmit==true)
    if not saved then part.material=previous;projectCompatibility(part);return nil,saveErr end
    receipt.regionId=id
    return receipt
end

function Anatomy.withdrawMaterial(entity,region,amount,request,options)
    options=type(options)=="table" and options or {}
    if not Authority.canWriteCanonicalState(entity) then return nil,"non-authority" end
    local state,err=Anatomy.get(entity);if not state then return nil,err end
    local part,definition,id=Anatomy.getRegion(entity,region);if not part then return nil,definition end
    if part.attached~=true then return nil,"tissue region detached" end
    local previous=part.material
    local nextMaterial,withdrawn,receipt=Tissue.withdraw(previous,amount,request)
    if not nextMaterial then return nil,withdrawn end
    part.material=nextMaterial;projectCompatibility(part)
    local saved,saveErr=save(entity,state,options.transmit==true)
    if not saved then part.material=previous;projectCompatibility(part);return nil,saveErr end
    receipt.regionId=id
    return withdrawn,receipt
end

local NUTRIENT_KEYS={"calories","carbohydrates","lipids","proteins"}
function Anatomy.applyNutritionProfile(entity,profileId,multiplier,options)
    options=type(options)=="table" and options or {}
    if not Authority.canWriteCanonicalState(entity) then return nil,"non-authority" end
    if type(profileId)~="string" or #profileId==0 or #profileId>128 then return nil,"nutrition profile ID required" end
    if not finite(multiplier) or multiplier<0 or multiplier>100 then return nil,"invalid nutrition multiplier" end
    local state,err=Anatomy.get(entity);if not state then return nil,err end
    local previousProfile=state.metadata and state.metadata.nutritionProfile
    if type(previousProfile)=="table" and previousProfile.id==profileId and previousProfile.multiplier==multiplier then
        local replay=Util.deepCopy(previousProfile);replay.replayed=true;return replay
    end
    local species=Species.get(state.speciesId);if not species then return nil,"missing species definition" end
    local previous={}
    for id,region in pairs(state.regions) do
        if region.attached==true then
            if type(region.material)~="table" or not Tissue.validate(region.material) then
                for restoreId,value in pairs(previous) do
                    state.regions[restoreId].material=value
                    projectCompatibility(state.regions[restoreId])
                end
                return nil,"regional material unavailable: "..id
            end
            previous[id]=region.material
            local material=Util.deepCopy(region.material)
            local baseline=species.regions[id].tissueNutritionDensity or {}
            material.nutritionDensity={}
            for _,key in ipairs(NUTRIENT_KEYS) do material.nutritionDensity[key]=(tonumber(baseline[key]) or 0)*multiplier end
            material.revision=material.revision+1
            material.lastNutritionProfile={id=profileId,multiplier=multiplier}
            if not Tissue.validate(material) then
                for restoreId,value in pairs(previous) do state.regions[restoreId].material=value end
                return nil,"nutrition profile produced invalid material"
            end
            region.material=material;projectCompatibility(region)
        end
    end
    state.metadata=type(state.metadata)=="table" and state.metadata or {}
    local priorMetadata=state.metadata.nutritionProfile
    local receipt={id=profileId,multiplier=multiplier}
    state.metadata.nutritionProfile=receipt
    local saved,saveErr=save(entity,state,options.transmit==true)
    if not saved then
        for id,value in pairs(previous) do state.regions[id].material=value;projectCompatibility(state.regions[id]) end
        state.metadata.nutritionProfile=priorMetadata
        return nil,saveErr
    end
    return Util.deepCopy(receipt)
end
return Anatomy
