-- Internal baseline journal only. Consumer leases are deliberately not resumed.
local Components=require 'Mortis/Runtime/Components'
local Persistence=require 'Mortis/Runtime/Persistence'
local Adapter=require 'Mortis/Runtime/Adapters/PersistenceAdapter'
local Schemas=require 'Mortis/API/Components'
local Util=require 'Mortis/Core/Util'
local Authority=require 'Mortis/Runtime/Authority'
local Store={}
local component='Mortis.LocomotionOverrideBaseline'

local function current(zombie)
    if not Schemas.isPersistent(component) then return nil,'override snapshot schema unavailable' end
    local bucket=Components.allFor(zombie)
    -- Refuse early callers before onCreated has loaded saved components. A
    -- flush must not discard known saved entries absent from the live bucket.
    local data,reason=Adapter.getModData(zombie)
    if not data then return nil,reason end
    local root=data.ProjectMORTIS
    if root~=nil and type(root)~='table' then return nil,'invalid saved MORTIS root' end
    if root and root.components~=nil then
        if type(root.components)~='table' then return nil,'invalid saved components' end
        for id in pairs(root.components) do
            if Schemas.isPersistent(id) and (not bucket or bucket[id]==nil) then
                return nil,'load saved components before override mutation'
            end
        end
    end
    return bucket and bucket[component]
end

function Store.read(zombie)
    return current(zombie)
end

local function flush(zombie)
    local ok,saved,reason=pcall(Persistence.flushComponents,zombie,false)
    if not ok then return false,'override checkpoint exception: '..tostring(saved) end
    return saved==true,reason
end

function Store.write(zombie,baseline)
    if not Authority.canWriteCanonicalState(zombie) then return false,'non-authority' end
    local _,reason=current(zombie)
    if reason then return false,reason end
    local updated={version=1,baseline=Util.deepCopy(baseline)}
    local called,result=pcall(Components.set,zombie,component,updated)
    if not called or result~=updated then return false,'override component checkpoint failed' end
    return flush(zombie)
end

function Store.clear(zombie)
    if not Authority.canWriteCanonicalState(zombie) then return false,'non-authority' end
    local original,reason=current(zombie)
    if reason then return false,reason end
    local removed=pcall(Components.remove,zombie,component)
    if not removed then return false,'override checkpoint removal failed' end
    local ok,err=flush(zombie)
    if not ok then pcall(Components.set,zombie,component,original) end
    return ok,err
end

return Store
