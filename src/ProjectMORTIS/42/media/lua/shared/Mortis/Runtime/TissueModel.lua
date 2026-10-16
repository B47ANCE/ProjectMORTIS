local Util=require "Mortis/Core/Util"

local Tissue={SCHEMA_VERSION=1,MAX_TRANSACTION_ID=128}
local NUTRIENTS={"calories","carbohydrates","lipids","proteins"}

local function finite(value)
    return type(value)=="number" and value==value and value~=math.huge and value~=-math.huge
end

local function quantity(value,label)
    if not finite(value) or value<0 then return nil,label.." must be nonnegative and finite" end
    return value
end

local function density(value)
    if value==nil then return {calories=0,carbohydrates=0,lipids=0,proteins=0} end
    if type(value)~="table" then return nil,"nutrition density must be a table" end
    local result={}
    for _,key in ipairs(NUTRIENTS) do
        local number=value[key] or 0
        if not finite(number) or number<0 then return nil,"nutrition density "..key.." must be nonnegative and finite" end
        result[key]=number
    end
    return result
end

function Tissue.validate(state)
    if type(state)~="table" or state.schemaVersion~=Tissue.SCHEMA_VERSION then
        return false,"unsupported tissue schema"
    end
    local capacity,err=quantity(state.capacity,"capacity");if not capacity or capacity<=0 then return false,err or "capacity must be positive" end
    local remaining;remaining,err=quantity(state.remaining,"remaining");if remaining==nil then return false,err end
    local viable;viable,err=quantity(state.viable,"viable");if viable==nil then return false,err end
    local edible;edible,err=quantity(state.edible,"edible");if edible==nil then return false,err end
    if remaining>capacity then return false,"remaining exceeds capacity" end
    if viable>remaining then return false,"viable exceeds remaining" end
    if edible>viable then return false,"edible exceeds viable" end
    if not finite(state.revision) or state.revision<0 or state.revision%1~=0 then return false,"invalid tissue revision" end
    local normalizedDensity,densityErr=density(state.nutritionDensity)
    if not normalizedDensity then return false,densityErr end
    return true
end

function Tissue.new(capacity,options)
    options=type(options)=="table" and options or {}
    local value,err=quantity(capacity,"capacity")
    if not value or value<=0 then return nil,err or "capacity must be positive" end
    local remaining=options.remaining==nil and value or options.remaining
    local viable=options.viable==nil and remaining or options.viable
    local edible=options.edible==nil and viable or options.edible
    local nutrition,nutritionErr=density(options.nutritionDensity)
    if not nutrition then return nil,nutritionErr end
    local state={schemaVersion=Tissue.SCHEMA_VERSION,capacity=value,remaining=remaining,
        viable=viable,edible=edible,nutritionDensity=nutrition,revision=options.revision or 0}
    local ok,reason=Tissue.validate(state);if not ok then return nil,reason end
    return state
end

function Tissue.snapshot(state)
    local ok,err=Tissue.validate(state);if not ok then return nil,err end
    local result=Util.deepCopy(state)
    result.remainingFraction=state.remaining/state.capacity
    result.viableFraction=state.viable/state.capacity
    result.edibleFraction=state.edible/state.capacity
    result.nutrition={}
    for _,key in ipairs(NUTRIENTS) do result.nutrition[key]=state.edible*state.nutritionDensity[key] end
    return result
end

local function requestLoss(value,label)
    if value==nil then return 0 end
    return quantity(value,label)
end

-- Pure monotonic transition. The caller owns authority and persistence. Total
-- material loss, loss of viability and loss of edibility are deliberately
-- independent, but the resulting hierarchy must remain physically valid.
function Tissue.applyLoss(state,request)
    local valid,err=Tissue.validate(state);if not valid then return nil,err end
    if type(request)~="table" or type(request.transactionId)~="string"
        or #request.transactionId==0 or #request.transactionId>Tissue.MAX_TRANSACTION_ID then
        return nil,"tissue transaction ID required"
    end
    if type(state.lastTransaction)=="table" and state.lastTransaction.id==request.transactionId then
        local replay=Util.deepCopy(state.lastTransaction)
        if replay.expectedRevision~=request.expectedRevision
            or replay.remainingLoss~=(request.remainingLoss or 0)
            or replay.viableLoss~=(request.viableLoss or 0)
            or replay.edibleLoss~=(request.edibleLoss or 0) then
            return nil,"tissue transaction conflict"
        end
        replay.replayed=true
        return Util.deepCopy(state),replay
    end
    if request.expectedRevision~=state.revision then return nil,"stale tissue revision" end
    local remainingLoss,lossErr=requestLoss(request.remainingLoss,"remaining loss");if remainingLoss==nil then return nil,lossErr end
    local viableLoss;viableLoss,lossErr=requestLoss(request.viableLoss,"viable loss");if viableLoss==nil then return nil,lossErr end
    local edibleLoss;edibleLoss,lossErr=requestLoss(request.edibleLoss,"edible loss");if edibleLoss==nil then return nil,lossErr end
    if remainingLoss==0 and viableLoss==0 and edibleLoss==0 then return nil,"empty tissue loss transaction" end
    local nextState=Util.deepCopy(state)
    nextState.remaining=state.remaining-remainingLoss
    nextState.viable=state.viable-viableLoss
    nextState.edible=state.edible-edibleLoss
    nextState.revision=state.revision+1
    nextState.lastTransaction={id=request.transactionId,expectedRevision=state.revision,
        remainingLoss=remainingLoss,viableLoss=viableLoss,edibleLoss=edibleLoss,
        before={remaining=state.remaining,viable=state.viable,edible=state.edible},
        after={remaining=nextState.remaining,viable=nextState.viable,edible=nextState.edible},
        mechanism=type(request.mechanism)=="string" and request.mechanism or "unspecified"}
    valid,err=Tissue.validate(nextState);if not valid then return nil,err end
    return nextState,Util.deepCopy(nextState.lastTransaction)
end

local function requestGain(value,label)
    if value==nil then return 0 end
    return quantity(value,label)
end

-- Pure bounded regeneration. Regeneration may restore material only up to the
-- original capacity and must preserve remaining >= viable >= edible. Policy
-- (healing rate, resource cost, and eligibility) belongs to the consumer.
function Tissue.applyGain(state,request)
    local valid,err=Tissue.validate(state);if not valid then return nil,err end
    if type(request)~="table" or type(request.transactionId)~="string"
        or #request.transactionId==0 or #request.transactionId>Tissue.MAX_TRANSACTION_ID then
        return nil,"tissue transaction ID required"
    end
    if type(state.lastTransaction)=="table" and state.lastTransaction.id==request.transactionId then
        local replay=Util.deepCopy(state.lastTransaction)
        if replay.kind~="gain" or replay.expectedRevision~=request.expectedRevision
            or replay.remainingGain~=(request.remainingGain or 0)
            or replay.viableGain~=(request.viableGain or 0)
            or replay.edibleGain~=(request.edibleGain or 0) then
            return nil,"tissue transaction conflict"
        end
        replay.replayed=true
        return Util.deepCopy(state),replay
    end
    if request.expectedRevision~=state.revision then return nil,"stale tissue revision" end
    local remainingGain,gainErr=requestGain(request.remainingGain,"remaining gain");if remainingGain==nil then return nil,gainErr end
    local viableGain;viableGain,gainErr=requestGain(request.viableGain,"viable gain");if viableGain==nil then return nil,gainErr end
    local edibleGain;edibleGain,gainErr=requestGain(request.edibleGain,"edible gain");if edibleGain==nil then return nil,gainErr end
    if remainingGain==0 and viableGain==0 and edibleGain==0 then return nil,"empty tissue gain transaction" end
    local nextState=Util.deepCopy(state)
    nextState.remaining=state.remaining+remainingGain
    nextState.viable=state.viable+viableGain
    nextState.edible=state.edible+edibleGain
    nextState.revision=state.revision+1
    nextState.lastTransaction={id=request.transactionId,kind="gain",expectedRevision=state.revision,
        remainingGain=remainingGain,viableGain=viableGain,edibleGain=edibleGain,
        before={remaining=state.remaining,viable=state.viable,edible=state.edible},
        after={remaining=nextState.remaining,viable=nextState.viable,edible=nextState.edible},
        mechanism=type(request.mechanism)=="string" and request.mechanism or "regeneration"}
    valid,err=Tissue.validate(nextState);if not valid then return nil,err end
    return nextState,Util.deepCopy(nextState.lastTransaction)
end

-- Transfer an unbiased portion out of this record. Returned material is a new
-- state whose quantities plus the source's quantities exactly equal the input.
function Tissue.withdraw(state,amount,request)
    local valid,err=Tissue.validate(state);if not valid then return nil,err end
    if not finite(amount) or amount<=0 or amount>state.remaining then return nil,"invalid tissue withdrawal" end
    local viableLoss=amount*(state.viable/state.remaining)
    local edibleLoss=amount*(state.edible/state.remaining)
    local nextState,receipt=Tissue.applyLoss(state,{transactionId=request and request.transactionId,
        expectedRevision=request and request.expectedRevision,remainingLoss=amount,
        viableLoss=viableLoss,edibleLoss=edibleLoss,mechanism=request and request.mechanism or "withdrawal"})
    if not nextState then return nil,receipt end
    local transferred,newErr=Tissue.new(amount,{remaining=amount,viable=viableLoss,edible=edibleLoss,
        nutritionDensity=state.nutritionDensity})
    if not transferred then return nil,newErr end
    return nextState,transferred,receipt
end

return Tissue
