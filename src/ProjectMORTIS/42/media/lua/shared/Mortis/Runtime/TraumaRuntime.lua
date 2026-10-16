local Anatomy = require "Mortis/Runtime/AnatomyRuntime"
local Consequences = require "Mortis/Runtime/AnatomyConsequenceRuntime"
local Channels = require "Mortis/API/TraumaChannels"
local Species = require "Mortis/API/Species"
local Authority = require "Mortis/Runtime/Authority"
local Util = require "Mortis/Core/Util"

local Trauma = {}

local function emit(name, ...)
    local Mortis = rawget(_G, "Mortis")
    if Mortis and Mortis.Events then Mortis.Events:emit(name, ...) end
end

local function finiteNonnegative(value)
    return type(value)=="number" and value==value and value>=0 and value<math.huge
end

local function apply(entity, ctx, wound)
    if not Authority.canWriteCanonicalState(entity) then return false, "non-authority" end
    if type(ctx) ~= "table" then return false, "trauma context must be a table" end

    local anatomy, err = Anatomy.ensure(entity)
    if not anatomy then return false, err end
    local species = Species.get(anatomy.speciesId)
    local channelId = tostring(ctx.channel or "impact")
    local channel = Channels.get(channelId)
    if not channel then return false, "unknown trauma channel: " .. channelId end

    local regionState, regionDef, regionId = Anatomy.getRegion(entity, ctx.region or ctx.bodyPart or species.defaultRegion)
    if not regionState then return false, regionDef end

    local magnitude = tonumber(ctx.magnitude) or tonumber(ctx.damage) or 0
    if not finiteNonnegative(magnitude) then return false, "magnitude must be finite and >= 0" end

    local localMult = tonumber((regionDef.channelMultipliers or {})[channelId]) or 1
    local structural = magnitude * (tonumber(channel.structuralMultiplier) or 1) * localMult
    local traumaTotal=(tonumber(regionState.trauma[channelId]) or 0)+magnitude
    if not finiteNonnegative(structural) or not finiteNonnegative(traumaTotal) then
        return false,"trauma overflow or invalid multiplier"
    end
    local before=Util.deepCopy(regionState)
    local pending={}
    local function notify(event,callback)
        pending[#pending+1]={event=event,callback=callback}
    end
    local result = {
        entity=entity, speciesId=species.id, region=regionId, channel=channelId,
        magnitude=magnitude, structuralDamage=structural,
        integrityBefore=regionState.integrity, attacker=ctx.attacker,
        source=ctx.source, weapon=ctx.weapon, flags=ctx.flags or {}, outcomes={}
    }

    regionState.trauma[channelId] = traumaTotal
    regionState.integrity = math.max(0, regionState.integrity - structural)

    if not regionState.disabled and
       (regionState.integrity <= (tonumber(regionDef.disableThreshold) or 0) or ctx.forceDisable) then
        regionState.disabled = true
        result.outcomes[#result.outcomes+1] = "disabled"
        notify("RegionDisabled","onDisabled")
    end

    local becameDestroyed = false
    local severPower = tonumber(ctx.severPower)
    if severPower == nil then severPower = magnitude * (tonumber(channel.severMultiplier) or 0) end
    local severThreshold = tonumber(ctx.severThreshold) or regionDef.integrity

    if regionDef.severable and regionState.attached and
       (ctx.forceSever or severPower >= severThreshold or
        (regionState.integrity <= 0 and (tonumber(channel.severMultiplier) or 0) > 0)) then
        regionState.attached, regionState.disabled, regionState.destroyed, regionState.integrity = false, true, true, 0
        becameDestroyed = true
        result.outcomes[#result.outcomes+1] = "severed"
        notify("RegionSevered","onSevered")
    else
        local crushPower = tonumber(ctx.crushPower)
        if crushPower == nil then crushPower = magnitude * (tonumber(channel.crushMultiplier) or 0) end
        local crushThreshold = tonumber(ctx.crushThreshold) or regionDef.integrity * 1.25
        if not regionState.destroyed and
           (ctx.forceDestroy or regionState.integrity <= (tonumber(regionDef.destroyThreshold) or 0) or crushPower >= crushThreshold) then
            regionState.destroyed, regionState.disabled, regionState.integrity = true, true, 0
            becameDestroyed = true
            result.outcomes[#result.outcomes+1] = "destroyed"
            notify("RegionDestroyed","onDestroyed")
        end
    end

    if regionDef.critical and becameDestroyed then
        result.outcomes[#result.outcomes+1] = "critical-destroyed"
        notify("CriticalRegionDestroyed","onCriticalDestroyed")
    end

    local bleeding = magnitude * (tonumber(channel.bleedMultiplier) or 0)
    if bleeding > 0 then
        result.bleeding = bleeding
        notify("BleedingStarted","onBleeding")
    end

    result.integrityAfter = regionState.integrity
    if wound then
        regionState.wounds=regionState.wounds or {}
        regionState.wounds[wound.id]={stage=wound.stage,magnitude=wound.magnitude,channel=channelId}
        result.woundId,result.woundStage=wound.id,wound.stage
    end
    local saved,saveErr=Anatomy.flush(entity, ctx.transmit == true)
    if not saved then
        for key in pairs(regionState) do regionState[key]=nil end
        for key,value in pairs(before) do regionState[key]=value end
        return false,saveErr or "trauma persistence failed"
    end
    for _,notification in ipairs(pending) do
        emit(notification.event,entity,regionId,result)
        Consequences.dispatch(notification.callback,entity,result)
    end
    emit("TraumaApplied", entity, result)
    Consequences.dispatch("onTrauma", entity, result)
    return true, result
end

function Trauma.apply(entity,ctx) return apply(entity,ctx) end

-- Magnitude is the cumulative trauma target, not damage per call. Replaying a
-- committed stage after streaming/reconnect must never damage the region again.
function Trauma.promote(entity,ctx)
    if not Authority.canWriteCanonicalState(entity) then return false,"non-authority" end
    if type(ctx)~="table" or type(ctx.woundId)~="string" or ctx.woundId==""
        or not finiteNonnegative(ctx.stage) or ctx.stage<1 or ctx.stage%1~=0
        or not finiteNonnegative(ctx.magnitude) then return false,"invalid wound promotion" end
    local region,err=Anatomy.getRegion(entity,ctx.region or ctx.bodyPart)
    if not region then return false,err end
    local previous=region.wounds and region.wounds[ctx.woundId]
    local channel=tostring(ctx.channel or "burn")
    if previous then
        if previous.channel~=channel then return false,"wound channel cannot change" end
        if ctx.stage<=previous.stage then return true,{unchanged=true,woundStage=previous.stage} end
        if ctx.magnitude<previous.magnitude then return false,"wound magnitude cannot decrease" end
    end
    local request=Util.deepCopy(ctx)
    request.channel=channel
    request.magnitude=ctx.magnitude-(previous and previous.magnitude or 0)
    return apply(entity,request,{id=ctx.woundId,stage=ctx.stage,magnitude=ctx.magnitude})
end

-- Authority-owned repair of an existing named wound. `magnitude` is biological
-- work applied this transaction, while `stage` is the caller-owned resulting
-- presentation stage. Repair cannot recreate detached/destroyed anatomy and
-- cannot silently change wound channels. The mutation is rolled back if the
-- anatomy snapshot cannot be persisted.
function Trauma.repair(entity,ctx)
    if not Authority.canWriteCanonicalState(entity) then return false,"non-authority" end
    if type(ctx)~="table" or type(ctx.woundId)~="string" or ctx.woundId==""
        or not finiteNonnegative(ctx.magnitude) then return false,"invalid wound repair" end
    local transactionId=ctx.transactionId
    if transactionId~=nil and (type(transactionId)~="string" or transactionId=="" or #transactionId>128) then
        return false,"invalid repair transaction id"
    end
    local anatomy,anatomyErr=Anatomy.get(entity)
    if not anatomy then return false,anatomyErr end
    if transactionId and anatomy.metadata.lastRepairTransactionId==transactionId then
        return true,{unchanged=true,replayed=true,repaired=0}
    end
    local region,definition,regionId=Anatomy.getRegion(entity,ctx.region or ctx.bodyPart)
    if not region then return false,definition end
    if region.attached==false or region.destroyed==true then return false,"region cannot regenerate" end
    local wound=region.wounds and region.wounds[ctx.woundId]
    if not wound then return true,{unchanged=true,region=regionId,repaired=0} end
    local channel=tostring(ctx.channel or wound.channel)
    if wound.channel~=channel then return false,"wound channel cannot change" end
    local requested=ctx.magnitude
    local repaired=math.min(requested,tonumber(wound.magnitude) or 0)
    if repaired<=0 then return true,{unchanged=true,region=regionId,repaired=0} end
    local channelDef=Channels.get(channel)
    if not channelDef then return false,"unknown trauma channel: "..channel end
    local localMult=tonumber((definition.channelMultipliers or {})[channel]) or 1
    local structural=repaired*(tonumber(channelDef.structuralMultiplier) or 1)*localMult
    if not finiteNonnegative(structural) then return false,"repair overflow or invalid multiplier" end
    local before=Util.deepCopy(region)
    local remaining=math.max(0,wound.magnitude-repaired)
    local resultingStage=tonumber(ctx.stage)
    if remaining>0 and (not finiteNonnegative(resultingStage) or resultingStage<1 or resultingStage%1~=0
        or resultingStage>wound.stage) then return false,"invalid resulting wound stage" end
    region.integrity=math.min(tonumber(region.maxIntegrity) or definition.integrity,region.integrity+structural)
    region.trauma[channel]=math.max(0,(tonumber(region.trauma[channel]) or 0)-repaired)
    if remaining<=0 then
        region.wounds[ctx.woundId]=nil
    else
        wound.magnitude=remaining
        wound.stage=resultingStage
    end
    if region.disabled and region.integrity>(tonumber(definition.disableThreshold) or 0) then
        region.disabled=false
    end
    local previousRepairId=anatomy.metadata.lastRepairTransactionId
    anatomy.metadata.lastRepairTransactionId=transactionId
    local saved,saveErr=Anatomy.flush(entity,ctx.transmit==true)
    if not saved then
        anatomy.metadata.lastRepairTransactionId=previousRepairId
        for key in pairs(region) do region[key]=nil end
        for key,value in pairs(before) do region[key]=value end
        return false,saveErr or "trauma repair persistence failed"
    end
    local result={entity=entity,region=regionId,channel=channel,woundId=ctx.woundId,
        requested=requested,repaired=repaired,remaining=remaining,structuralRepair=structural,
        integrityBefore=before.integrity,integrityAfter=region.integrity,woundStage=remaining>0 and wound.stage or 0}
    emit("TraumaRepaired",entity,result)
    return true,result
end

function Trauma.sever(entity, region, ctx)
    ctx = Util.deepCopy(ctx or {}); ctx.region=region; ctx.channel=ctx.channel or "chop"; ctx.forceSever=true
    return Trauma.apply(entity, ctx)
end

function Trauma.destroy(entity, region, ctx)
    ctx = Util.deepCopy(ctx or {}); ctx.region=region; ctx.channel=ctx.channel or "crush"; ctx.forceDestroy=true
    return Trauma.apply(entity, ctx)
end
return Trauma
