> CURRENT SCOPE — Lua-only custom behavior profiles supersede native activity control. Retained source evidence is historical and does not prove normal Lua invocation or dedicated multiplayer behavior. See LUA_ONLY_API_AUDIT.md and LUA_MULTIPLAYER_AUTHORITY.md; no runtime gate has passed.

# Native activity call graph

2026-10-08; Build 42.21 JAR inspection, not runtime evidence. Project version unassigned.

All paths relative to `research/jar-source`.

```text
IsoZombie constructor / load / reuse
  -> GameTime.isZombieInactivityPhase()
  -> inactive initialization and native stats initialization

IsoZombie.update() :2806
  -> updateInternal() :2817
    -> updateActiveState() :2829 (before client remote branch)
      -> GameTime.isZombieInactivityPhase() [GameTime :1294]
        -> !isZombieActivityPhase() :1290
          -> SandboxOptions.lore.activeOnly
          -> isNight()/isDay() -> season dawn/dusk
      -> makeInactive(boolean) :4486
        -> entering: slow walk, running=false, speedType=3, doZombieSpeed()
        -> leaving: speedType=-1, DoZombieStats() -> doZombieSpeed()
          -> determineZombieSpeed() :4952
             -> randomized sprinter selection when speed=4
    -> remote-client branch :2865
    -> OnZombieUpdate :2900 (too late to replace earlier decision)

ClimateValues.update internal calculation :242 onward
  -> currentDay.season.getDawn()/getDusk()
  -> ClimateManager.getTimeLerpHours(time, dusk, dawn, true)
  -> clamp(lerpNight * 2) -> nightStrength
```

[VERIFIED] No guard providing a mod opt-out appears around updateActiveState. [VERIFIED] A Lua callback after this point cannot prevent next update's global overwrite. [UNKNOWN] Any safe pre-decision interception mechanism; no hook was assumed. Decompiled helper local-variable ordering is imperfect; inspect bytecode before reimplementing interpolation.
