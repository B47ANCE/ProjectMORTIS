-- Bootstrap on clients too; canonical writes remain authority-gated.
require "Mortis/Bootstrap"
require "Mortis/ReplicationClient"
require "Mortis/TestHarness"

-- Everything below is an operator/developer console surface. Core client
-- bootstrap and replication above remain active in normal play.
if type(isDebugEnabled)=="function" and isDebugEnabled()~=true then return end

function MORTISExportWeaponReport(filename)
    local Mortis = require "Mortis/init"
    local ok, result = Mortis.DeveloperReports.exportWeaponReview(filename)
    print("[MORTIS][REPORT] " .. (ok and "wrote " or "failed: ") .. tostring(result))
    return ok, result
end

function MORTISExportDiagnostics(filename)
    local Mortis = require "Mortis/init"
    local ok, result = Mortis.DeveloperReports.exportDiagnostics(filename)
    print("[MORTIS][REPORT] " .. (ok and "wrote " or "failed: ") .. tostring(result))
    return ok, result
end

function MORTISDumpRegistries(filename)
    local Mortis=require "Mortis/init"
    local ok,result=Mortis.DeveloperReports.exportRegistries(filename)
    print("[MORTIS][REGISTRY] "..(ok and "wrote " or "failed: ")..tostring(result))
    return ok,result
end

local function nearestLoadedZombie()
    local player=getSpecificPlayer and getSpecificPlayer(0) or nil
    local cell=getCell and getCell() or nil
    if not player or not cell then return nil end
    local ok,list=pcall(function() return cell:getZombieList() end)
    if not ok or not list then return nil end
    local best,bestDistance=nil,math.huge
    local okSize,size=pcall(function() return list:size() end)
    if not okSize then return nil end
    for i=0,(tonumber(size) or 0)-1 do
        local okZombie,zombie=pcall(function() return list:get(i) end)
        if okZombie and zombie then
            local okDistance,distance=pcall(function()
                local dx,dy=zombie:getX()-player:getX(),zombie:getY()-player:getY()
                return dx*dx+dy*dy
            end)
            if okDistance and distance<bestDistance then best,bestDistance=zombie,distance end
        end
    end
    return best
end

function MORTISInspect(entity,filename)
    local Mortis=require "Mortis/init"
    entity=entity or nearestLoadedZombie()
    if not entity then print("[MORTIS][INSPECT] no loaded zombie found"); return false,"no loaded zombie" end
    local contents,inspection=Mortis.DeveloperReports.formatEntityInspection(entity)
    if not contents then print("[MORTIS][INSPECT] failed: "..tostring(inspection)); return false,inspection end
    print(contents)
    if filename then return Mortis.DeveloperReports.exportEntityInspection(entity,filename) end
    return true,inspection
end

function MORTISProfiler(enabled,reset)
    local Mortis=require "Mortis/init"
    if reset==true then Mortis.Profiler.reset() end
    Mortis.Profiler.setEnabled(enabled==true)
    print("[MORTIS][PROFILE] "..(enabled==true and "enabled" or "disabled"))
    return Mortis.Profiler.snapshot()
end
