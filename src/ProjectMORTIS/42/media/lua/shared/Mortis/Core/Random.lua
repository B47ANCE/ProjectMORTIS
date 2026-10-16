local Components = require "Mortis/Runtime/Components"

local Random = {}
local KEY = "Mortis.RandomState"
local MOD = 2147483647
local MUL = 48271

local function hashString(value)
    local text = tostring(value or "Mortis")
    local hash = 5381
    for i = 1, #text do
        hash = (hash * 33 + string.byte(text, i)) % MOD
    end
    if hash <= 0 then hash = 1 end
    return hash
end

local function deriveSeed(zombie)
    if zombie ~= nil then
        local ok, fn = pcall(function() return zombie.getOnlineID end)
        if ok and type(fn) == "function" then
            local okId, id = pcall(fn, zombie)
            if okId and type(id) == "number" and id >= 0 then
                return hashString("online:" .. tostring(id))
            end
        end
    end
    return hashString(zombie)
end

function Random.seed(zombie, seed)
    assert(zombie ~= nil, "zombie is required")
    seed = math.floor(tonumber(seed) or 1) % MOD
    if seed <= 0 then seed = 1 end
    Components.set(zombie, KEY, seed)
    return seed
end

function Random.getState(zombie)
    local state = Components.get(zombie, KEY)
    if type(state) ~= "number" or state <= 0 then state = Random.seed(zombie, deriveSeed(zombie)) end
    return state
end

function Random.next(zombie)
    local state = Random.getState(zombie)
    state = (state * MUL) % MOD
    Components.set(zombie, KEY, state)
    return state / MOD
end

function Random.integer(zombie, minValue, maxValue)
    minValue = math.floor(tonumber(minValue) or 0)
    maxValue = math.floor(tonumber(maxValue) or minValue)
    if maxValue < minValue then minValue, maxValue = maxValue, minValue end
    local span = maxValue - minValue + 1
    return minValue + math.floor(Random.next(zombie) * span)
end

function Random.chance(zombie, probability)
    probability = tonumber(probability) or 0
    if probability <= 0 then return false end
    if probability >= 1 then return true end
    return Random.next(zombie) < probability
end

return Random
