local WeaponCatalog = require "Mortis/Runtime/WeaponCatalog"
local Diagnostics = require "Mortis/Core/Diagnostics"
local Identity = require "Mortis/Runtime/Identity"
local Authority = require "Mortis/Runtime/Authority"
local State = require "Mortis/Runtime/Adapters/StateAdapter"
local Anatomy = require "Mortis/Runtime/AnatomyRuntime"
local Types = require "Mortis/API/Types"
local Traits = require "Mortis/API/Traits"
local Behaviors = require "Mortis/API/Behaviors"
local LocomotionProfiles = require "Mortis/API/LocomotionProfiles"
local DurabilityProfiles = require "Mortis/API/DurabilityProfiles"
local AppearanceProfiles = require "Mortis/API/AppearanceProfiles"
local CollisionProfiles = require "Mortis/API/CollisionProfiles"
local BalanceProfiles = require "Mortis/API/BalanceProfiles"
local Species = require "Mortis/API/Species"
local TraumaChannels = require "Mortis/API/TraumaChannels"

local Reports = {}

local function write(name, contents)
    if type(getFileWriter) ~= "function" then return false, "getFileWriter unavailable" end
    local ok, result = pcall(function()
        local writer = getFileWriter(name, true, false)
        if not writer then error("writer unavailable") end
        writer:write(tostring(contents or ""))
        writer:close()
        return name
    end)
    if not ok then return false, result end
    return true, result
end

local function flatten(lines, prefix, value)
    if type(value) ~= "table" then
        lines[#lines+1] = tostring(prefix) .. "=" .. tostring(value)
        return
    end
    local keys = {}
    for key in pairs(value) do keys[#keys+1] = key end
    table.sort(keys, function(a,b) return tostring(a) < tostring(b) end)
    for _, key in ipairs(keys) do
        local nextPrefix = prefix == "" and tostring(key) or prefix .. "." .. tostring(key)
        flatten(lines, nextPrefix, value[key])
    end
end

function Reports.exportWeaponReview(filename)
    return write(filename or "MORTIS_WeaponReview.txt", WeaponCatalog.formatReviewReport())
end

function Reports.exportDiagnostics(filename)
    local lines = { "MORTIS Diagnostics" }
    flatten(lines, "", Diagnostics.snapshot())
    return write(filename or "MORTIS_Diagnostics.txt", table.concat(lines, "\n"))
end

function Reports.registrySnapshot()
    return {
        types=Types.all(),traits=Traits.all(),behaviors=Behaviors.all(),
        locomotionProfiles=LocomotionProfiles.all(),durabilityProfiles=DurabilityProfiles.all(),
        appearanceProfiles=AppearanceProfiles.all(),collisionProfiles=CollisionProfiles.all(),
        balanceProfiles=BalanceProfiles.all(),species=Species.all(),traumaChannels=TraumaChannels.all(),
    }
end

function Reports.exportRegistries(filename)
    local lines={"MORTIS Registry Dump"}
    flatten(lines,"",Reports.registrySnapshot())
    return write(filename or "MORTIS_Registries.txt",table.concat(lines,"\n"))
end

local function call(object,method)
    if not object then return nil end
    local ok,value=pcall(function()
        local fn=object[method]
        return type(fn)=="function" and fn(object) or nil
    end)
    return ok and value or nil
end

function Reports.inspectEntity(entity)
    if not entity then return nil,"entity required" end
    local typeId=Identity.getTypeId(entity)
    local definition=typeId and Identity.getType(entity) or nil
    local native=State.snapshot(entity)
    local target=call(entity,"getTarget")
    local result={
        stableId=Identity.getStableId(entity),
        typeId=typeId,
        displayName=definition and definition.displayName or nil,
        authority=Authority.mode(),
        onlineId=call(entity,"getOnlineID"),
        position={x=call(entity,"getX"),y=call(entity,"getY"),z=call(entity,"getZ")},
        health=call(entity,"getHealth"),
        target={onlineId=call(target,"getOnlineID"),x=call(target,"getX"),y=call(target,"getY"),z=call(target,"getZ")},
        nativeState=native,
        anatomy=Anatomy.snapshot(entity),
    }
    return result
end

function Reports.formatEntityInspection(entity)
    local inspection,reason=Reports.inspectEntity(entity)
    if not inspection then return nil,reason end
    local lines={"MORTIS Entity Inspection"}
    flatten(lines,"",inspection)
    return table.concat(lines,"\n"),inspection
end

function Reports.exportEntityInspection(entity,filename)
    local contents,reason=Reports.formatEntityInspection(entity)
    if not contents then return false,reason end
    return write(filename or "MORTIS_EntityInspection.txt",contents)
end

return Reports
