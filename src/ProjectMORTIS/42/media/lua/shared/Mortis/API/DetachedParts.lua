local Registry=require "Mortis/Core/Registry"
local Util=require "Mortis/Core/Util"
local Anatomy=require "Mortis/Runtime/AnatomyRuntime"
local Identity=require "Mortis/Runtime/Identity"
local Entity=require "Mortis/Runtime/Adapters/EntityAdapter"
local Authority=require "Mortis/Runtime/Authority"
local MaterialModel=require "Mortis/Runtime/DetachedMaterialModel"

local Detached={registry=Registry.new("detached-part classifier")}
local KEY="MortisDetachedPart"
local SCHEMA=1
local DEATH_KEY="MortisDeathProvenance"

local function captureTissue(region)
    local capacity,remaining=region.tissueCapacity,region.remainingTissue
    if type(capacity)~="number" or capacity~=capacity or capacity<=0 or capacity==math.huge
        or type(remaining)~="number" or remaining~=remaining or remaining<0 or remaining>capacity then return nil end
    return {capacity=capacity,remaining=remaining}
end

local function hasEntries(value)
    if type(value)~="table" then return false end
    for _ in pairs(value) do return true end
    return false
end

local function isCorpse(source)
    local ok,name=pcall(function() return source:getObjectName() end)
    return ok and name=="DeadBody"
end

function Detached.registerClassifier(definition)
    if type(definition)~="table" then error("detached-part classifier must be a table",2) end
    local normalized=Util.deepCopy(definition)
    normalized.id=Util.assertString(normalized.id,"detached-part classifier id")
    if type(normalized.classify)~="function" then error("detached-part classifier classify must be a function",2) end
    return Detached.registry:register(normalized.id,normalized)
end

function Detached.capture(source,regionId,metadata)
    if not source then return nil,"source required" end
    if isCorpse(source) then return Detached.captureCorpse(source,regionId,metadata) end
    local anatomy,err=Anatomy.get(source)
    if not anatomy then return nil,err end
    local regionState,regionDefinition,resolved=Anatomy.getRegion(source,regionId)
    if not regionState then return nil,regionDefinition end
    local subtree,subtreeErr
    if regionState.attached==true and type(Anatomy.subtreeSnapshot)=="function" then
        subtree,subtreeErr=Anatomy.subtreeSnapshot(source,resolved)
        if not subtree then return nil,subtreeErr end
    end
    local record={
        schemaVersion=SCHEMA,
        speciesId=anatomy.speciesId,
        speciesVersion=anatomy.speciesVersion,
        regionId=resolved,
        sourceStableId=Identity.ensureStableId(source),
        sourceTypeId=Identity.getTypeId(source),
        capturedWorldAgeHours=nil,
        classifications={},
        tissue=captureTissue(regionState),
        subtree=subtree and Util.deepCopy(subtree) or nil,
        metadata=type(metadata)=="table" and Util.deepCopy(metadata) or {},
    }
    if type(getGameTime)=="function" then
        local ok,age=pcall(function() return getGameTime():getWorldAgeHours() end)
        if ok then record.capturedWorldAgeHours=tonumber(age) end
    end
    for id,classifier in pairs(Detached.registry:all()) do
        local ok,value=pcall(classifier.classify,source,Util.deepCopy(record),regionDefinition)
        if ok and value~=nil then record.classifications[id]=Util.deepCopy(value) end
    end
    return record
end

-- Freeze classifiers while the original entity identity still exists. Vanilla
-- copies ModData into IsoDeadBody; no nearest-entity lookup is needed.
function Detached.snapshotDeath(source)
    if not Authority.canWriteCanonicalState(source) then return nil,"non-authority" end
    if not source or isCorpse(source) then return nil,"original entity required" end
    local data=Entity.getModData(source)
    if not data then return nil,"source ModData unavailable" end
    local previous=data[DEATH_KEY]
    if previous~=nil and (type(previous)~="table" or previous.schemaVersion~=SCHEMA
        or not hasEntries(previous.regions)) then
        return nil,"unsupported death provenance"
    end
    -- Repeated callbacks can arrive before or after identity cleanup. Preserve
    -- the frozen record when the current stable ID is absent or still matches;
    -- only a genuinely new (reanimated) identity may refresh classifiers.
    if previous then
        local currentStableId=Identity.getStableId(source)
        local frozenStableId
        for _,record in pairs(previous.regions)do
            if type(record)=="table"and type(record.sourceStableId)=="string"then frozenStableId=record.sourceStableId;break end
        end
        if not currentStableId or currentStableId==frozenStableId then return Util.deepCopy(previous) end
    end
    local anatomy,err=Anatomy.get(source)
    if not anatomy then return nil,err end
    local records={}
    for regionId in pairs(anatomy.regions or {}) do
        local record,reason=Detached.capture(source,regionId,{sourceLifecycle="death"})
        if not record then return nil,reason end
        records[regionId]=record
    end
    if not hasEntries(records) then return nil,"source has no anatomy regions" end
    local saved,saveError=Anatomy.flush(source,false)
    if not saved then return nil,saveError end
    local snapshot={schemaVersion=SCHEMA,regions=records}
    data[DEATH_KEY]=snapshot
    return Util.deepCopy(snapshot)
end

-- Player deaths use the generic character-death hook. Keep this separate from
-- the zombie engine cleanup path so animals/NPCs cannot be mistaken for human
-- sources and duplicate zombie events remain harmless.
function Detached.snapshotPlayerDeath(source)
    if Entity.kind(source)~="player" then return nil,"player source required" end
    return Detached.snapshotDeath(source)
end

function Detached.captureCorpse(corpse,regionId,metadata)
    if not isCorpse(corpse) then return nil,"corpse object required" end
    local data=Entity.getModData(corpse)
    local snapshot=data and data[DEATH_KEY]
    if type(snapshot)~="table" or snapshot.schemaVersion~=SCHEMA or type(snapshot.regions)~="table" then
        return nil,"corpse has no supported death provenance"
    end
    local region,definition,resolved=Anatomy.getRegion(corpse,regionId)
    if not region then return nil,definition end
    local record=snapshot.regions[resolved]
    if type(record)~="table" or record.schemaVersion~=SCHEMA or record.regionId~=resolved
        or type(record.sourceStableId)~="string" or type(record.classifications)~="table" then
        return nil,"corpse region provenance unavailable"
    end
    record=Util.deepCopy(record)
    -- Identity/classification are frozen at death; tissue is sampled at recovery
    -- because postmortem UV may have consumed it since that snapshot.
    record.tissue=captureTissue(region)
    if type(Anatomy.subtreeSnapshot)=="function" then
        local subtree,subtreeErr=Anatomy.subtreeSnapshot(corpse,resolved)
        if not subtree then return nil,subtreeErr end
        record.subtree=Util.deepCopy(subtree)
    end
    record.metadata=type(metadata)=="table" and Util.deepCopy(metadata) or {}
    record.metadata.sourceLifecycle="corpse"
    return record
end

function Detached.write(item,record)
    if not item or not item.getModData then return false,"item has no modData" end
    if type(record)~="table" or tonumber(record.schemaVersion)~=SCHEMA then return false,"invalid provenance" end
    item:getModData()[KEY]=Util.deepCopy(record)
    return true
end

function Detached.read(item)
    if not item or not item.getModData then return nil,"item has no modData" end
    local record=item:getModData()[KEY]
    if type(record)~="table" then return nil,"missing provenance" end
    if tonumber(record.schemaVersion)~=SCHEMA then return nil,"unsupported provenance schema" end
    return Util.deepCopy(record)
end

local function commitRecord(item,record)
    local prior,readErr=Detached.read(item);if not prior then return nil,readErr end
    local written,writeErr=Detached.write(item,record)
    if not written then Detached.write(item,prior);return nil,writeErr end
    return true
end

function Detached.applyMaterialLoss(item,regionId,request)
    if not Authority.canWriteCanonicalState(item) then return nil,"non-authority" end
    local record,err=Detached.read(item);if not record then return nil,err end
    local nextRecord,receipt=MaterialModel.applyLoss(record,regionId,request)
    if not nextRecord then return nil,receipt end
    local committed,commitErr=commitRecord(item,nextRecord);if not committed then return nil,commitErr end
    return receipt
end

function Detached.applyMaterialGain(item,regionId,request)
    if not Authority.canWriteCanonicalState(item) then return nil,"non-authority" end
    local record,err=Detached.read(item);if not record then return nil,err end
    local nextRecord,receipt=MaterialModel.applyGain(record,regionId,request)
    if not nextRecord then return nil,receipt end
    local committed,commitErr=commitRecord(item,nextRecord);if not committed then return nil,commitErr end
    return receipt
end

function Detached.withdrawMaterial(item,regionId,amount,request)
    if not Authority.canWriteCanonicalState(item) then return nil,"non-authority" end
    local record,err=Detached.read(item);if not record then return nil,err end
    local nextRecord,material,receipt=MaterialModel.withdraw(record,regionId,amount,request)
    if not nextRecord then return nil,material end
    local committed,commitErr=commitRecord(item,nextRecord);if not committed then return nil,commitErr end
    return material,receipt
end

Detached.KEY=KEY
Detached.DEATH_KEY=DEATH_KEY
Detached.SCHEMA_VERSION=SCHEMA
return Detached
