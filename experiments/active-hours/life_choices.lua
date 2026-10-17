-- Offline proposal only. Never loaded by the mod. No RNG, disk or native APIs.
local Choices = {}
local keys = {version=true, lifeId=true, revision=true, selectionKey=true, activeRoll=true, inactiveRoll=true}
local function plain(value) return type(value)=='table' and getmetatable(value)==nil end
local function text(value, limit)
    return type(value)=='string' and #value>0 and #value<=limit and not value:find('[%z\1-\31\127]')
end
local function revision(value)
    return type(value)=='number' and value>=1 and value<=9007199254740991 and value%1==0
end
local function roll(value) return type(value)=='number' and value==value and value>=0 and value<1 end
local function copy(record)
    local result={}; for key in pairs(keys) do result[key]=record[key] end; return result
end
function Choices.validate(record)
    if not plain(record) then return nil,'invalid-record' end
    for key in pairs(record) do if not keys[key] then return nil,'unknown-field' end end
    if record.version~=1 then return nil,'unsupported-version' end
    if not text(record.lifeId,192) or not revision(record.revision) or not text(record.selectionKey,4096)
        or not roll(record.activeRoll) or not roll(record.inactiveRoll) then return nil,'invalid-record' end
    return copy(record)
end

-- Caller supplies two authority-drawn rolls only for creation/a new revision.
-- Return a detached candidate; caller must persist it before any gameplay use.
-- A missing record is NOT permission to create: runtime must distinguish new
-- life from unavailable/corrupt persistence. That integration remains blocked.
function Choices.reconcile(saved, lifeId, targetRevision, selectionKey, supplied)
    if not text(lifeId,192) or not revision(targetRevision) or not text(selectionKey,4096) then
        return nil,'invalid-context'
    end
    if saved~=nil then
        local record, err=Choices.validate(saved)
        if not record then return nil,err end
        if record.lifeId~=lifeId then return nil,'life-mismatch' end
        if targetRevision<record.revision then return nil,'stale-revision' end
        if targetRevision==record.revision then
            if selectionKey~=record.selectionKey then return nil,'revision-key-conflict' end
            if supplied~=nil then return nil,'unexpected-rolls' end
            return record,'retained'
        end
        if selectionKey==record.selectionKey then return nil,'unchanged-selection' end
    end
    if not plain(supplied) then return nil,'rolls-required' end
    for key in pairs(supplied) do if key~='active' and key~='inactive' then return nil,'unknown-roll-field' end end
    if not roll(supplied.active) or not roll(supplied.inactive) then return nil,'invalid-rolls' end
    return {version=1,lifeId=lifeId,revision=targetRevision,selectionKey=selectionKey,
        activeRoll=supplied.active,inactiveRoll=supplied.inactive},'candidate'
end
return Choices
