-- Generalized infected critical-trauma consequence, invoked explicitly by policy
-- owners. No UV, hunger, zombie-type or automatic death-event registration here.
local Authority=require "Mortis/Runtime/Authority"
local Species=require "Mortis/API/Species"
local Entity=require "Mortis/Runtime/Adapters/EntityAdapter"
local Combat=require "Mortis/Runtime/Adapters/CombatAdapter"
local Systemic={}

function Systemic.resolveCriticalFailure(entity,policy)
    if not Authority.canWriteCanonicalState(entity) then return false,"non-authority" end
    if type(policy)~="table" or policy.allowDeath~=true then return false,"lethal consequence not authorized" end
    if Entity.kind(entity)~="infected" then return false,"infected adapter only" end
    -- Read committed anatomy, never partially mutated runtime trauma state.
    local data=Entity.getModData(entity)
    local root=data and data.MORTIS_LIVING
    local anatomy=type(root)=="table" and root.anatomy
    if type(anatomy)~="table" or (anatomy.schemaVersion~=1 and anatomy.schemaVersion~=2)
        or type(anatomy.regions)~="table" then
        return false,"committed anatomy required"
    end
    local species=Species.get(anatomy.speciesId)
    if not species then return false,"known anatomy species required" end
    local critical={}
    for id,definition in pairs(species.regions) do
        local region=anatomy.regions[id]
        if definition.critical and type(region)=="table"
            and (region.destroyed==true or region.attached==false) then critical[#critical+1]=id end
    end
    if #critical==0 then return true,{unchanged=true,criticalRegions={}} end
    table.sort(critical)
    local health,err=Combat.getHealth(entity)
    if type(health)~="number" or health~=health or math.abs(health)==math.huge then return false,err or "invalid native health" end
    if health<=0 then return true,{unchanged=true,criticalRegions=critical,healthZero=true} end
    local ok,reason=Combat.setHealth(entity,0)
    if not ok then return false,reason end
    local after=Combat.getHealth(entity)
    if type(after)~="number" or after~=after or after>0 or after==-math.huge then
        return false,"native critical-failure transition unconfirmed"
    end
    return true,{criticalRegions=critical,healthZero=true,healthBefore=health}
end
return Systemic
