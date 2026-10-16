local Authority = require "Mortis/Runtime/Authority"
local Components = require "Mortis/Runtime/Components"
local Identity = require "Mortis/Runtime/Identity"

-- Semantic infected communication. Audible presentation/world attraction is
-- deliberately owned by the consumer because hearing a call and understanding
-- it are different concepts.
local Signals = { MAX_ACTIVE = 256 }
local COMPONENT = "Mortis.SignalMemory"
local active, head, sequence = {}, 1, 0

local function finite(v)
    v=tonumber(v); return v and v==v and v~=math.huge and v~=-math.huge and v or nil
end

local function pointOf(def)
    local p=type(def.position)=="table" and def.position or def
    local x,y,z=finite(p.x),finite(p.y),finite(p.z) or 0
    if not x or not y then return nil end
    return {x=x,y=y,z=z}
end

function Signals.emit(def)
    if type(def)~="table" or not def.source then return nil,"signal source is required" end
    if not Authority.canWriteCanonicalState(def.source) then return nil,"infected signal requires server authority" end
    if type(def.type)~="string" or def.type=="" then return nil,"signal type is required" end
    local point=pointOf(def); if not point then return nil,"signal position is invalid" end
    sequence=sequence+1
    local signal={
        id=string.format("SIG-%08d",sequence), type=def.type:sub(1,96),
        sourceId=Identity.getStableId(def.source) or Identity.ensureStableId(def.source),
        position=point, radius=math.max(0,finite(def.radius) or 0),
        createdWorldAgeHours=finite(def.worldAgeHours),
        expiresWorldAgeHours=finite(def.expiresWorldAgeHours),
        payload=type(def.payload)=="table" and def.payload or nil,
    }
    active[#active+1]=signal
    while #active-head+1>Signals.MAX_ACTIVE do active[head]=nil;head=head+1 end
    if def.persistOnSource==true then Components.set(def.source,COMPONENT,{lastSignal=signal}) end
    return signal
end

function Signals.query(x,y,z,radius,nowHours,predicate,limit)
    x,y,z,radius=finite(x),finite(y),finite(z) or 0,math.max(0,finite(radius) or 0)
    if not x or not y then return {} end
    limit=math.max(1,math.min(256,math.floor(tonumber(limit) or 64)))
    local out,r2={},radius*radius
    for i=head,#active do
        local s=active[i]
        if s and (not nowHours or not s.expiresWorldAgeHours or s.expiresWorldAgeHours>=nowHours) then
            local dx,dy,dz=s.position.x-x,s.position.y-y,math.abs(s.position.z-z)
            local inRange=dz<=0.5 and dx*dx+dy*dy<=math.min(r2,s.radius*s.radius)
            local accepted=true
            if inRange and type(predicate)=="function" then local ok,v=pcall(predicate,s);accepted=ok and v==true end
            if inRange and accepted then out[#out+1]=s;if #out>=limit then break end end
        end
    end
    return out
end

function Signals.getLastPersistent(entity)
    local state=Components.get(entity,COMPONENT)
    return type(state)=="table" and state.lastSignal or nil
end

Signals.COMPONENT=COMPONENT
return Signals
