local Environment = require "Mortis/Runtime/Adapters/PhysicalEnvironmentAdapter"
local Entity = require "Mortis/Runtime/Adapters/EntityAdapter"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"
local Settings = require "Mortis/Runtime/PhysicalSettings"

local Observer = {}

local lastHit = setmetatable({}, { __mode = "k" })
local pendingAttack = setmetatable({}, { __mode = "k" })

local function emit(name, ...)
    local Mortis = rawget(_G, "Mortis")
    if Mortis and Mortis.Events then Mortis.Events:emit(name, ...) end
end

local function variable(player, name)
    local ok, value = GameAdapter.call(player, "getVariableString", name)
    if ok and value ~= nil then return tostring(value) end
    return nil
end

local function classifyPlayerAction(player, weapon)
    local pieces = {
        string.lower(tostring(variable(player, "AttackType") or "")),
        string.lower(tostring(variable(player, "WeaponType") or "")),
        string.lower(tostring(variable(player, "PlayerHitReaction") or "")),
    }
    local text = table.concat(pieces, " ")

    if text:find("stomp", 1, true) or text:find("floor", 1, true) then
        return "stomp", text
    end
    if text:find("shove", 1, true) or text:find("push", 1, true) then
        return "shove", text
    end

    -- Bare-hands attacks are ambiguous; do not guess. Keep as observed-unarmed.
    if weapon == nil then return "unarmed-unknown", text end
    return "weapon", text
end

function Observer.onHitZombie(zombie, attacker, bodyPart, weapon)
    if zombie == nil or attacker == nil then return end
    local action, evidence = classifyPlayerAction(attacker, weapon)
    lastHit[attacker] = {
        target=zombie,
        bodyPart=bodyPart,
        weapon=weapon,
        action=action,
        evidence=evidence,
    }

    if action == "stomp" or action == "shove" then
        emit("PhysicalAttackHitObserved", attacker, zombie, {
            action=action,
            bodyPart=bodyPart,
            evidence=evidence,
        })
    end
end

function Observer.onPlayerAttackFinished(player, weapon)
    if player == nil then return end
    local action, evidence = classifyPlayerAction(player, weapon)
    local hit = lastHit[player]
    lastHit[player] = nil

    if action == "stomp" and Settings.bool("EnableStompRepair") then
        local target = hit and hit.target or nil
        if target == nil then
            local Mortis = rawget(_G, "Mortis")
            if Mortis and Mortis.StompRuntime then
                target = Mortis.StompRuntime.acquireTarget(player, {
                    range=Settings.number("StompRepairRange")
                })
            end
        end

        local observation = {
            action="stomp",
            target=target,
            registeredHit=hit ~= nil,
            evidence=evidence,
            repairCandidate=hit == nil and target ~= nil,
        }
        pendingAttack[player] = observation
        emit("StompFinishedObserved", player, observation)
        return observation
    end

    if action == "shove" then
        local observation = {
            action="shove",
            target=hit and hit.target or nil,
            registeredHit=hit ~= nil,
            evidence=evidence,
        }
        pendingAttack[player] = observation
        emit("ShoveFinishedObserved", player, observation)
        return observation
    end

    return nil
end

function Observer.getPending(player)
    return pendingAttack[player]
end

function Observer.clear(player)
    pendingAttack[player] = nil
    lastHit[player] = nil
end

return Observer
