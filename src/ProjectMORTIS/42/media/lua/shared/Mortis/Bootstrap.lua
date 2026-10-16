local Mortis = require "Mortis/init"
require "Mortis/Content/ResearchArchive"
require "Mortis/Definitions/CoreAnatomy"
require "Mortis/Definitions/VerifiedVanillaWeapons"
require "Mortis/Definitions/CorePhysicalInteractions"
require "Mortis/Definitions/CorePileSupports"
require "Mortis/Integrations/HistoryEvidence"
local Lifecycle = require "Mortis/Runtime/Adapters/LifecycleAdapter"
local GameAdapter = require "Mortis/Runtime/Adapters/GameAdapter"

local capabilities = Mortis.Capabilities.probe()
Mortis.Log.info("Project M.O.R.T.I.S. " .. Mortis.VERSION .. " booting; PZ runtime=" .. GameAdapter.getVersion() .. "; authority=" .. Mortis.Authority.mode())

local function logCapabilities(values, prefix)
    local names = {}
    for name in pairs(values) do names[#names + 1] = name end
    table.sort(names)
    for _, name in ipairs(names) do
        Mortis.Log.info(string.format("%s%-34s %s", prefix or "Capability ", name, values[name] and "YES" or "NO"))
    end
end

logCapabilities(capabilities)

local function bind(name, fn)
    local ok, reason = Lifecycle.bind(name, fn)
    if ok then Mortis.Log.info("Bound Events." .. name) else Mortis.Log.warn("Skipped Events." .. name .. ": " .. tostring(reason)) end
    return ok
end

local onTickBound = bind("OnTick", function()
    Mortis.Scheduler.advance()
    if Mortis.Scheduler.frame % 2 == 0 then
        Mortis.CollisionRuntime.update(Mortis.Engine.takeTrackedBatch(
            "collision", Mortis.SystemSettings.number("CollisionRuntimeBatchSize")))
    end

    -- Centralized movement balance checks are intentionally slower than
    -- collision checks. Shared BalanceRuntime cooldowns prevent independent
    -- causes from multiplying trip frequency.
    if Mortis.Scheduler.frame % 10 == 0 then
        for _, zombie in ipairs(Mortis.Engine.takeTrackedBatch(
            "movement-balance", Mortis.SystemSettings.number("MovementRuntimeBatchSize"))) do
            Mortis.MovementBalance.update(zombie)
        end
    end
end)
Mortis.Scheduler.useExternalClock(onTickBound)

local observedZombieCapabilities = false
bind("OnZombieCreate", function(zombie)
    Mortis.Engine.onCreated(zombie)
    if not observedZombieCapabilities then
        observedZombieCapabilities = true
        Mortis.Log.info("Observed first IsoZombie instance; refreshing zombie capabilities")
        logCapabilities(Mortis.Capabilities.all(), "Observed ")
    end
end)

bind("OnZombieUpdate", function(zombie) Mortis.Engine.update(zombie) end)
bind("OnZombieDead", function(zombie) Mortis.Engine.onDead(zombie) end)
bind("OnCharacterDeath", function(character)
    if Mortis.Entity.kind(character)~="player" then return end
    local ok,record,reason=pcall(Mortis.DetachedParts.snapshotPlayerDeath,character)
    if not ok or not record then
        pcall(Mortis.Log.rateLimited,"player-death-provenance",30,"WARN",
            "Player death provenance unavailable: "..tostring(ok and reason or record),"Anatomy")
    end
end)

-- OnHitZombie supplies attacker/body-part/weapon metadata; B42's
-- OnPlayerGetDamage supplies numeric zombie weapon damage on the authoritative
-- server path. M.O.R.T.I.S. uses the latter only to apply the configured
-- post-vanilla durability delta.
bind("OnCharacterCollide", function(character, collidedCharacter)
    Mortis.CharacterCollision.onCharacterCollide(character, collidedCharacter)
end)

bind("OnHitZombie", function(zombie, attacker, bodyPart, weapon)
    Mortis.PhysicalAttackObserver.onHitZombie(zombie, attacker, bodyPart, weapon)
    Mortis.Engine.onHitZombie(zombie, attacker, bodyPart, weapon)
end)

bind("OnPlayerAttackFinished", function(player, weapon)
    Mortis.PhysicalAttackObserver.onPlayerAttackFinished(player, weapon)
end)

bind("OnWeaponHitCharacter", function(attacker, target, weapon, damage)
    Mortis.Engine.onWeaponHitCharacter(attacker, target, weapon, damage)
end)

bind("OnPlayerGetDamage", function(character, damageType, damage)
    Mortis.Engine.onDamageEvent(character, damageType, damage)
end)


local function buildWeaponCatalog(reason)
    local ok, result = Mortis.WeaponCatalog.build(reason)
    if ok then
        local summary = Mortis.WeaponCatalog.summary()
        Mortis.Log.info(string.format(
            "Weapon catalog built: %d weapons; coreVerified=%d; patchVerified=%d; LongSharp=%d; ShortSharp=%d; review=%d; unknown=%d; devManual=%d",
            summary.total, summary.coreVerified, summary.patchVerified,
            summary.longSharp, summary.shortSharp, summary.review,
            summary.unknown, summary.manualUnverified))
    else
        Mortis.Log.warn("Weapon catalog build deferred: " .. tostring(result))
    end
end

bind("OnGameStart", function() buildWeaponCatalog("OnGameStart") end)
bind("OnServerStarted", function() buildWeaponCatalog("OnServerStarted") end)

-- Persistent components are normally staged into zombie modData as soon as
-- they become dirty. Save hooks are a final consistency flush for typed zombies.
bind("OnServerStartSaving", function()
    local count = Mortis.Engine.flushTracked(false)
    Mortis.Log.info("Phase B pre-save flush: " .. tostring(count) .. " typed zombies")
end)

bind("OnPostSave", function()
    Mortis.Engine.flushTracked(false)
end)

if not onTickBound then
    Mortis.Log.warn("Events.OnTick unavailable; scheduler using per-zombie fallback counters")
end

return Mortis
