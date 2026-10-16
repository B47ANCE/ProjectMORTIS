local Mortis=require "Mortis/init"
local History=require "B47ANCEDKnowledgeAndWisdom/HistoryRecords"

local function actorId(actor)
    if not actor then return nil end
    for _,method in ipairs({"getUsername","getSteamID","getOnlineID"})do
        local ok,fn=pcall(function()return actor[method]end)
        if ok and type(fn)=="function"then
            local called,value=pcall(fn,actor);value=called and tostring(value or "")or""
            local candidate=method..":"..value
            if #candidate<=160 and candidate:match("^[%w_%.:%-]+$")then return candidate end
        end
    end
end

local function validateEvidence(_,subjectId,evidenceId,request)
    local corpse=type(request)=="table"and request.evidenceObject or nil
    local regionId=type(request)=="table"and request.regionId or nil
    if not corpse or type(regionId)~="string"or regionId==""then return false,"CORPSE_AND_REGION_REQUIRED"end
    local record,reason=Mortis.DetachedParts.captureCorpse(corpse,regionId,{historyEvidence=true})
    if not record then return false,reason end
    if tostring(record.sourceStableId or "")~=subjectId then return false,"SUBJECT_PROVENANCE_MISMATCH"end
    local expected="mortis-death:"..subjectId..":"..regionId
    if expected~=evidenceId then return false,"EVIDENCE_ID_MISMATCH"end
    return true,{schemaVersion=1,kind="mortis-death",sourceStableId=record.sourceStableId,
        sourceTypeId=record.sourceTypeId,regionId=record.regionId,capturedWorldAgeHours=record.capturedWorldAgeHours}
end

if not Mortis.HistoryEvidenceRegistered then
    History.registerEvidenceProvider{id="Mortis.DeathProvenance",getActorId=actorId,validateEvidence=validateEvidence}
    Mortis.HistoryEvidenceRegistered=true
end
Mortis.HistoryEvidence={actorId=actorId,validateEvidence=validateEvidence,
    evidenceId=function(subjectId,regionId)return "mortis-death:"..tostring(subjectId)..":"..tostring(regionId)end}
return Mortis.HistoryEvidence
