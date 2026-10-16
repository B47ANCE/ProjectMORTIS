local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local Adapter = {}

local function call(object,method,...)
    if not object then return false,nil end
    return GameAdapter.call(object,method,...)
end

function Adapter.square(entity)
    local ok,value=call(entity,"getSquare")
    return ok and value or nil
end

function Adapter.position(square)
    local okX,x=call(square,"getX")
    local okY,y=call(square,"getY")
    local okZ,z=call(square,"getZ")
    if not (okX and okY and okZ) then return nil end
    return tonumber(x),tonumber(y),tonumber(z)
end

function Adapter.cell(square)
    local ok,value=call(square,"getCell")
    if ok and value then return value end
    local getter=rawget(_G,"getCell")
    if type(getter)~="function" then return nil end
    local success,cell=pcall(getter)
    return success and cell or nil
end

function Adapter.gridSquare(cell,x,y,z)
    local ok,value=call(cell,"getGridSquare",x,y,z)
    return ok and value or nil
end

function Adapter.isInterior(square)
    local okRoom,inRoom=call(square,"isInARoom")
    if okRoom and inRoom==true then return true end
    local okOutside,outside=call(square,"isOutside")
    return okOutside and outside==false
end

function Adapter.canStand(square)
    local ok,value=call(square,"canStand")
    if ok then return value==true end
    return nil
end

function Adapter.building(square)
    local ok,value=call(square,"getBuilding")
    if ok and value then return value end
    local okRoom,room=call(square,"getRoom")
    if not okRoom or not room then return nil end
    local okBuilding,building=call(room,"getBuilding")
    return okBuilding and building or nil
end

function Adapter.occupancy(square,entity)
    local ok,list=call(square,"getMovingObjects")
    if not ok or not list then return 0 end
    local okSize,size=call(list,"size")
    if not okSize then return 0 end
    local count=0
    for i=0,(tonumber(size) or 0)-1 do
        local okItem,item=call(list,"get",i)
        if okItem and item and item~=entity then count=count+1 end
    end
    return count
end

return Adapter
