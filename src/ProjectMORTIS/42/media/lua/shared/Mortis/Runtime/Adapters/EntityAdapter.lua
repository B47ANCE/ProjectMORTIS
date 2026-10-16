local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"
local Entity = {}

local function yes(entity, method)
    local ok, value = GameAdapter.call(entity, method)
    return ok and value == true
end

function Entity.kind(entity)
    if not entity then return "unknown" end
    if yes(entity, "isZombie") then return "infected" end
    if yes(entity, "isPlayer") then return "player" end
    if yes(entity, "isAnimal") then return "animal" end
    local ok, name = GameAdapter.call(entity, "getObjectName")
    if ok and name and string.find(string.lower(tostring(name)), "animal", 1, true) then return "animal" end
    return "living"
end

function Entity.getModData(entity)
    local ok, data = GameAdapter.call(entity, "getModData")
    return ok and type(data) == "table" and data or nil
end

function Entity.transmitModData(entity)
    return GameAdapter.call(entity, "transmitModData")
end

function Entity.isDead(entity)
    local ok, value = GameAdapter.call(entity, "isDead")
    return ok and value == true
end
return Entity
