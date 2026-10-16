local Capabilities = require "Mortis/API/Capabilities"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local Response = {}

function Response.plan(context, massA, massB)
    if type(context) ~= "table" then return nil end
    local penetration = tonumber(context.penetration) or 0
    if penetration <= 0 then return nil end

    massA = math.max(0.05, tonumber(massA) or 1)
    massB = math.max(0.05, tonumber(massB) or 1)
    local total = massA + massB

    return {
        ax = -(tonumber(context.normalX) or 0) * penetration * (massB / total),
        ay = -(tonumber(context.normalY) or 0) * penetration * (massB / total),
        bx =  (tonumber(context.normalX) or 0) * penetration * (massA / total),
        by =  (tonumber(context.normalY) or 0) * penetration * (massA / total),
        penetration = penetration,
    }
end

-- Intentionally disabled unless a runtime-verified caller explicitly opts in.
-- We keep physical separation behind this adapter so the public collision API
-- will not change when safe B42 movement ownership is verified.
function Response.apply(entity, dx, dy, options)
    options = options or {}
    if options.runtimeVerified ~= true then
        return false, "physical separation not runtime-verified"
    end

    if not (Capabilities.has("zombie.getX") and Capabilities.has("zombie.getY")) then
        return false, "position capability unavailable"
    end

    local okX, x = GameAdapter.call(entity, "getX")
    local okY, y = GameAdapter.call(entity, "getY")
    if not (okX and okY) then return false, "position read failed" end

    -- Coordinate mutation remains capability-gated and is never called by the
    -- default runtime in this development pass.
    local okSetX = GameAdapter.call(entity, "setX", tonumber(x) + (tonumber(dx) or 0))
    local okSetY = GameAdapter.call(entity, "setY", tonumber(y) + (tonumber(dy) or 0))
    return okSetX and okSetY, "coordinate-fallback"
end

return Response
