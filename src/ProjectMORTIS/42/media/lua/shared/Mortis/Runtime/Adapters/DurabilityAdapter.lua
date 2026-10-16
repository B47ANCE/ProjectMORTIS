local Combat = require "Mortis/Runtime/Adapters/CombatAdapter"

local DurabilityAdapter = {}

function DurabilityAdapter.getHealth(zombie) return Combat.getHealth(zombie) end
function DurabilityAdapter.setHealth(zombie, value) return Combat.setHealth(zombie, value) end
function DurabilityAdapter.isDead(zombie) return Combat.isDead(zombie) end

function DurabilityAdapter.scaleHealth(zombie, fromScale, toScale)
    fromScale = tonumber(fromScale) or 1.0
    toScale = tonumber(toScale) or 1.0
    if fromScale <= 0 or toScale <= 0 then return false, "health scales must be > 0" end
    local health, err = DurabilityAdapter.getHealth(zombie)
    if health == nil then return false, err end
    local target = math.max(0, (health / fromScale) * toScale)
    return DurabilityAdapter.setHealth(zombie, target)
end

function DurabilityAdapter.damage(zombie, amount)
    amount = tonumber(amount)
    if not amount or amount < 0 then return false, "damage amount must be >= 0" end
    local health, err = DurabilityAdapter.getHealth(zombie)
    if health == nil then return false, err end
    return DurabilityAdapter.setHealth(zombie, math.max(0, health - amount))
end

function DurabilityAdapter.heal(zombie, amount)
    amount = tonumber(amount)
    if not amount or amount < 0 then return false, "heal amount must be >= 0" end
    local health, err = DurabilityAdapter.getHealth(zombie)
    if health == nil then return false, err end
    return DurabilityAdapter.setHealth(zombie, health + amount)
end

return DurabilityAdapter
