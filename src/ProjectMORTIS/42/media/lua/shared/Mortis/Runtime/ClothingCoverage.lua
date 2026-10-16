-- Read-only native coverage snapshot. Clothing policy belongs to the consumer.
local Game=require "Mortis/Runtime/Adapters/GameAdapter"
local Species=require "Mortis/API/Species"
local Coverage={MAX_LAYERS=64,MAX_PARTS=32}

local function unit(v)
    return type(v)=="number" and v==v and v>=0 and v<=1
end
local function size(list,maximum)
    local ok,n=Game.call(list,"size")
    if not ok or type(n)~="number" or n<0 or n>maximum or n%1~=0 then return nil end
    return n
end

function Coverage.snapshot(entity,speciesId)
    local species=Species.get(speciesId)
    if not species then return nil,"unknown species" end
    local blood=rawget(_G,"BloodBodyPartType")
    local clothing=rawget(_G,"BloodClothingType")
    if not blood or not clothing then return nil,"native coverage API unavailable" end
    -- IsoZombie.getItemVisuals() selects visual-only versus worn inventory state.
    local ok,visuals=Game.call(entity,"getItemVisuals")
    local count=ok and size(visuals,Coverage.MAX_LAYERS)
    if not count then return nil,"clothing collection unavailable or over budget" end
    local success,result=pcall(function()
        local _,partCount=Game.call(blood.MAX,"index")
        if type(partCount)~="number" or partCount<1 or partCount>Coverage.MAX_PARTS
            or partCount%1~=0 then error("invalid native body-part count") end
        local snapshot={parts={},layers={}}
        for i=0,partCount-1 do
            local part=blood.FromIndex(i)
            local name=tostring(part)
            local region=Species.resolveRegion(species,name)
            if not region then error("unmapped native body part: "..name) end
            snapshot.parts[name]={region=region}
        end
        for i=0,count-1 do
            local got,visual=Game.call(visuals,"get",i)
            if not got or not visual then error("missing clothing visual") end
            local found,item=Game.call(visual,"getScriptItem")
            if not found or not item then error("unresolved clothing script") end
            local typed,itemType=Game.call(visual,"getItemType")
            local covered,types=Game.call(item,"getBloodClothingType")
            if not typed or type(itemType)~="string" or not covered then error("invalid clothing metadata") end
            local fabricRead,fabric=Game.call(item,"getFabricType")
            if not fabricRead or (fabric~=nil and type(fabric)~="string") then
                error("invalid clothing fabric metadata")
            end
            local layer={itemType=itemType,fabricType=fabric,parts={}}
            if types then
                local parts=clothing.getCoveredParts(types)
                local n=size(parts,Coverage.MAX_PARTS)
                if not n then error("invalid clothing coverage list") end
                for j=0,n-1 do
                    local valid,part=Game.call(parts,"get",j)
                    local name=tostring(part)
                    if not valid or not snapshot.parts[name] then error("unknown clothing body part") end
                    local read,hole=Game.call(visual,"getHole",part)
                    if not read or not unit(hole) then error("invalid localized clothing hole") end
                    layer.parts[name]={hole=hole}
                end
            end
            snapshot.layers[#snapshot.layers+1]=layer
        end
        return snapshot
    end)
    if not success then return nil,tostring(result) end
    return result
end

-- Resolve the intact transmission per layer/part in consumer policy. Local holes
-- expose only that part; intact underlying layers still protect it. Weights let
-- the consumer model area/direction without replacing the canonical anatomy.
function Coverage.transmission(snapshot,resolve,weights)
    if type(snapshot)~="table" or type(resolve)~="function" then return nil,"invalid coverage input" end
    local ok,result=pcall(function()
        local regions,parts={},{}
        for name,part in pairs(snapshot.parts) do
            local product=1
            for _,layer in ipairs(snapshot.layers) do
                local localPart=layer.parts[name]
                if localPart then
                    local intact=resolve(layer.itemType,name,layer.fabricType)
                    if not unit(intact) or not unit(localPart.hole) then error("unresolved clothing transmission") end
                    product=product*(intact+(1-intact)*localPart.hole)
                end
            end
            local weight=weights and weights[name] or 1
            if type(weight)~="number" or weight~=weight or weight<=0 or weight==math.huge then
                error("invalid regional coverage weight")
            end
            local r=regions[part.region] or {sum=0,weight=0}
            r.sum,r.weight=r.sum+product*weight,r.weight+weight
            if r.sum==math.huge or r.weight==math.huge then error("coverage weight overflow") end
            regions[part.region]=r
            parts[name]=product
        end
        for id,r in pairs(regions) do regions[id]=r.sum/r.weight end
        return {regions=regions,parts=parts}
    end)
    if not ok then return nil,tostring(result) end
    return result
end

-- Anatomical access is distinct from optical transmission: even a torn layer
-- remains clothing over the region and is not automatically surgical access.
-- Returns neutral garment facts, never native inventory handles or mutations.
function Coverage.region(entity,speciesId,regionId)
    local species=Species.get(speciesId)
    if not species then return nil,"unknown species" end
    local canonical=Species.resolveRegion(species,regionId)
    if not canonical then return nil,"unknown anatomical region" end
    local snapshot,err=Coverage.snapshot(entity,speciesId)
    if not snapshot then return nil,err end
    local result={region=canonical,covered=false,layers={},parts={}}
    local mapped=false
    for name,part in pairs(snapshot.parts) do
        if part.region==canonical then result.parts[name]=true;mapped=true end
    end
    if not mapped then return nil,"anatomical region has no native clothing mapping" end
    for index,layer in ipairs(snapshot.layers) do
        local entry={layerIndex=index,itemType=layer.itemType,fabricType=layer.fabricType,parts={}}
        local overlaps=false
        for name,part in pairs(layer.parts) do
            if result.parts[name] then entry.parts[name]={hole=part.hole};overlaps=true end
        end
        if overlaps then result.layers[#result.layers+1]=entry;result.covered=true end
    end
    return result
end

return Coverage
