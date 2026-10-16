local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local Environment = {}

local function call(obj, method, ...)
    if obj == nil then return false, nil end
    return GameAdapter.call(obj, method, ...)
end

local function position(entity)
    local okX, x = call(entity, "getX")
    local okY, y = call(entity, "getY")
    local okZ, z = call(entity, "getZ")
    if not (okX and okY and okZ) then return nil end
    return tonumber(x), tonumber(y), tonumber(z)
end

function Environment.square(entity)
    local ok, square = call(entity, "getSquare")
    return ok and square or nil
end

function Environment.isProne(entity)
    local probes = {
        "isOnFloor",
        "isKnockedDown",
        "isCrawling",
    }
    for _, method in ipairs(probes) do
        local ok, value = call(entity, method)
        if ok and value == true then return true, method end
    end
    return false
end

function Environment.hasSupport(square)
    if square == nil then return false end

    -- Prefer explicit solid-floor APIs when present.
    for _, method in ipairs({ "TreatAsSolidFloor", "hasFloor", "isSolidFloor" }) do
        local ok, value = call(square, method)
        if ok then return value == true, method end
    end

    -- Conservative fallback: if a square object exists at the current Z, treat
    -- support as unknown/likely rather than inventing an unsupported fall.
    return nil, "unverified"
end

function Environment.adjacentSquare(entity, dx, dy)
    local square = Environment.square(entity)
    if not square then return nil end
    local okX, x = call(square, "getX")
    local okY, y = call(square, "getY")
    local okZ, z = call(square, "getZ")
    if not (okX and okY and okZ) then return nil end

    local cell = nil
    local okCell, value = call(square, "getCell")
    if okCell then cell = value end
    if not cell then
        local globalCell = rawget(_G, "getCell")
        if type(globalCell) == "function" then
            local ok, c = pcall(globalCell)
            if ok then cell = c end
        end
    end
    if not cell then return nil end

    local okSq, target = call(cell, "getGridSquare",
        math.floor(tonumber(x) + dx),
        math.floor(tonumber(y) + dy),
        math.floor(tonumber(z)))
    return okSq and target or nil
end

-- Low-wall/fence detection is capability-oriented. We report only what the
-- square/object APIs confidently expose and leave uncertain geometry alone.
function Environment.inspectLowObstacleBetween(fromSquare, toSquare)
    if not fromSquare or not toSquare then return { known=false } end

    local probes = {
        { "isBlockedTo", toSquare },
        { "isSomethingTo", toSquare },
        { "isWallTo", toSquare },
        { "isWindowTo", toSquare },
        { "isDoorTo", toSquare },
    }

    local result = { known=false, blocked=nil, wall=nil, window=nil, door=nil }

    for _, probe in ipairs(probes) do
        local method, arg = probe[1], probe[2]
        local ok, value = call(fromSquare, method, arg)
        if ok then
            result.known = true
            if method == "isBlockedTo" or method == "isSomethingTo" then result.blocked = value == true end
            if method == "isWallTo" then result.wall = value == true end
            if method == "isWindowTo" then result.window = value == true end
            if method == "isDoorTo" then result.door = value == true end
        end
    end

    return result
end


function Environment.isOnStairs(entity)
    local square = Environment.square(entity)
    if not square then return false, "no-square" end

    for _, method in ipairs({ "HasStairs", "hasStairs", "isStairs", "isOnStairs" }) do
        local ok, value = call(square, method)
        if ok then return value == true, method end
    end

    local okProps, props = call(square, "getProperties")
    if okProps and props then
        for _, token in ipairs({ "stairs", "Stairs", "stairsTN", "stairsTW", "stairsBN", "stairsBW" }) do
            local ok, value = call(props, "Is", token)
            if ok and value == true then return true, "properties:" .. token end
        end
    end
    return false, "unverified"
end

function Environment.position(entity)
    return position(entity)
end

return Environment
