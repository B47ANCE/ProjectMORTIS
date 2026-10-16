local Util = require "Mortis/Core/Util"
local Species = require "Mortis/API/Species"
local Anatomy = require "Mortis/Runtime/AnatomyRuntime"
local Attachments = require "Mortis/API/AnatomyAttachments"

local Capabilities = {}

local function hasEntries(value)
    for _ in pairs(value or {}) do return true end
    return false
end

local function add(target, modifiers)
    for id, value in pairs(modifiers or {}) do
        target[id] = (target[id] or 0) + value
    end
end

local function sortedKeys(values)
    local result = {}
    for key in pairs(values or {}) do result[#result + 1] = key end
    table.sort(result)
    return result
end

-- This is entity anatomy, not an engine-method capability probe. The returned
-- values are deterministic additive contributions and are never cached.
function Capabilities.snapshot(entity, options)
    local anatomy, anatomyError = Anatomy.get(entity)
    if not anatomy then return nil, anatomyError end
    local species = Species.get(anatomy.speciesId)
    if not species then return nil, "unknown anatomy species: " .. tostring(anatomy.speciesId) end
    local attachmentState, attachmentError = Attachments.snapshot(entity)
    if not attachmentState then return nil, attachmentError end

    local progressive=type(options)=="table" and options.progressive==true
    -- Supporting anatomy limits distal function. Use a bounded traversal so
    -- malformed third-party hierarchies cannot recurse indefinitely.
    local function parentLimit(regionId)
        local factor,seen,count=1,{},0
        local definition=species.regions[regionId]
        if not definition then return nil,"unknown support region" end
        local parent=definition.parent
        while parent do
            count=count+1
            if seen[parent] or parent==regionId or count>(Species.MAX_PARENT_DEPTH or 32) then
                return nil,"invalid anatomy support hierarchy"
            end
            seen[parent]=true
            local def=species.regions[parent]
            local state=anatomy.regions and anatomy.regions[parent]
            if not def or not state then return nil,"missing supporting anatomy" end
            local integrity,maximum=state.integrity,def.integrity
            if type(integrity)~="number" or integrity~=integrity or integrity<0 or integrity==math.huge
                or type(maximum)~="number" or maximum~=maximum or maximum<=0 or maximum==math.huge then
                return nil,"invalid supporting integrity"
            end
            local support=math.min(1,integrity/maximum)
            if state.attached==false or state.disabled==true or state.destroyed==true then support=0 end
            factor=math.min(factor,support)
            parent=def.parent
        end
        return factor
    end
    local result = { speciesId=anatomy.speciesId, total={}, natural={}, attachments={},
        baseline={},regionFunction={},criticalDestroyed={} }
    for _, regionId in ipairs(sortedKeys(species.regions)) do
        local state = anatomy.regions and anatomy.regions[regionId]
        local definition = species.regions[regionId]
        add(result.baseline,definition.capabilityModifiers)
        local factor=1
        if progressive then
            local integrity=state and state.integrity
            local maximum=definition.integrity
            if type(integrity)~="number" or integrity~=integrity or integrity<0 or integrity==math.huge
                or type(maximum)~="number" or maximum~=maximum or maximum<=0 or maximum==math.huge then
                return nil,"invalid regional integrity: "..regionId
            end
            factor=math.min(1,integrity/maximum)
        end
        if not state or state.attached==false or state.disabled==true or state.destroyed==true then factor=0 end
        if progressive then
            local support,err=parentLimit(regionId)
            if support==nil then return nil,err end
            factor=math.min(factor,support)
        end
        result.regionFunction[regionId]=factor
        if definition.critical and state and (state.destroyed==true or state.attached==false) then
            result.criticalDestroyed[#result.criticalDestroyed+1]=regionId
        end
        if state and state.attached ~= false and state.disabled ~= true and state.destroyed ~= true then
            local contribution = Util.deepCopy(definition.capabilityModifiers or {})
            if progressive then
                for id,value in pairs(contribution) do contribution[id]=value*factor end
            end
            if hasEntries(contribution) then
                result.natural[regionId] = contribution
                add(result.total, contribution)
            end
        end
    end

    for _, mountId in ipairs(sortedKeys(attachmentState.mounts)) do
        local mount = attachmentState.mounts[mountId]
        local definition = mount and Attachments.get(mount.attachmentId)
        if definition then
            local contribution = Util.deepCopy(definition.capabilityModifiers or {})
            if progressive then
                local support,err=parentLimit(mount.regionId)
                if support==nil then return nil,err end
                for id,value in pairs(contribution) do contribution[id]=value*support end
            end
            if hasEntries(contribution) then
                result.attachments[mountId] = {
                    attachmentId=definition.id, regionId=mount.regionId,
                    socketId=mount.socketId, modifiers=contribution,
                }
                add(result.total, contribution)
            end
        end
    end
    return result
end

-- Continuous tissue impairment is opt-in; existing binary capability consumers
-- retain their previous behavior. No native movement, HP or AI is changed here.
function Capabilities.functionalSnapshot(entity)
    return Capabilities.snapshot(entity,{progressive=true})
end

function Capabilities.get(entity, capabilityId)
    if type(capabilityId) ~= "string" or capabilityId == "" then return nil, "capabilityId required" end
    local snapshot, err = Capabilities.snapshot(entity)
    if not snapshot then return nil, err end
    return snapshot.total[capabilityId] or 0, snapshot
end

return Capabilities
