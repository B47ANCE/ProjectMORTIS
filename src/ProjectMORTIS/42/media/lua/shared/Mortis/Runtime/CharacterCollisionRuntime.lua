local Balance = require "Mortis/Runtime/BalanceRuntime"
local Collision = require "Mortis/Runtime/Adapters/CollisionAdapter"
local Entity = require "Mortis/Runtime/Adapters/EntityAdapter"
local Environment = require "Mortis/Runtime/Adapters/PhysicalEnvironmentAdapter"
local Settings = require "Mortis/Runtime/PhysicalSettings"
local Authority = require "Mortis/Runtime/Authority"

local Runtime = {}

local recent = setmetatable({}, { __mode = "k" })

local function key(a, b)
    return tostring(a) .. "|" .. tostring(b)
end

local function speed(entity)
    local x, y = Collision.position(entity)
    if x == nil then return 0 end
    local old = recent[entity]
    recent[entity] = { x=x, y=y }
    if not old then return 0 end
    local dx, dy = x-old.x, y-old.y
    return math.sqrt(dx*dx + dy*dy)
end

function Runtime.onCharacterCollide(character, collidedCharacter)
    if not Settings.bool("EnablePlayerCollisionTrips") then return false, "disabled" end
    if character == nil or collidedCharacter == nil then return false, "missing character" end

    -- Current Lua docs define OnCharacterCollide for a non-zombie character
    -- colliding with another character. The main framework use is a player
    -- running into a zombie.
    local sourceKind = Entity.kind(character)
    local targetKind = Entity.kind(collidedCharacter)
    if sourceKind ~= "player" or targetKind ~= "infected" then
        return false, "unsupported collision pair"
    end
    if not Authority.canWriteCanonicalState(collidedCharacter) then
        return false, "non-authority"
    end

    local playerSpeed = speed(character)
    local zombieSpeed = speed(collidedCharacter)
    local relativeSpeed = playerSpeed + zombieSpeed

    local chance = Settings.number("PlayerCollisionTripChance")
    local ok, result = Balance.attempt(collidedCharacter, Balance.Causes.PLAYER_COLLISION, {
        chanceOverride = chance,
        impact = relativeSpeed,
        relativeSpeed = relativeSpeed,
        sourceEntity = character,
        fallOnFront = true,
    })

    local Mortis = rawget(_G, "Mortis")
    if Mortis and Mortis.Events then
        Mortis.Events:emit("CharacterCollisionObserved", character, collidedCharacter, {
            sourceKind=sourceKind,
            targetKind=targetKind,
            relativeSpeed=relativeSpeed,
            tripAttempted=true,
            tripped=ok,
            balance=result,
        })
    end
    return ok, result
end

return Runtime
