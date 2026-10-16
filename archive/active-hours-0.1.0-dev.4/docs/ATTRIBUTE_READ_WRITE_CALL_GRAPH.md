> CURRENT SCOPE — Lua-only custom behavior profiles supersede native activity control. Retained source evidence is historical and does not prove normal Lua invocation or dedicated multiplayer behavior. See LUA_ONLY_API_AUDIT.md and LUA_MULTIPLAYER_AUTHORITY.md; no runtime gate has passed.

# Attribute read/write call graph

2026-10-08; SOURCE-SUPPORTED Build 42.21; no runtime evidence. Paths relative to research/jar-source.

```text
IsoZombie.updateActiveState :2813
 -> makeInactive :4486
    entering -> speedType=3 -> doZombieSpeed
    leaving  -> speedType=-1 -> DoZombieStats :3327
      cognition sandbox conditional/random assignment
      strength sentinel initialization
      memory sentinel/random assignment
      sight and hearing unconditional assignment
      doZombieSpeed :4850
       -> determineZombieSpeed :4952
       -> crawler / shambler / fake-shambler / fast / sprinter branch
       -> speedMod + animation + walk variant/type + speedType
      initCanCrawlUnderVehicle :4158 -> randomized native eligibility

IsoZombie.resetForReuse
 -> clears identity, strength/cognition sentinels
 -> DoZombieStats
 -> separate sandbox toughness -> current health assignment :3801

IsoZombie.toggleCrawling :4222
 -> preserve canCrawlUnderVehicle
 -> DoZombieStats
 -> restore canCrawlUnderVehicle

Runtime readers (scoped, not exhaustive):
 strength -> IsoDoor.Thump :1070 + sandbox-strength branch :1071
 cognition -> IsoDoor.Thump :1053
 sight -> IsoZombie detection :1975/:2332; radius :4777/:4780
 hearing -> WorldSoundManager.getHearingMultiplier :419
 memory -> IsoZombie target expiry :2983
 sandbox memory + inactive -> getSandboxMemoryDuration :4534

NetworkZombieAI.parse :295
 -> remote speedMod, boolean flags, walkType
 -> setSpeedTypeFromWalkType

ZombieStateFlags.intFromZombie :34
 -> canCrawlUnderVehicle and other native state flags
 -> population virtualization / load
```

DoZombieStats has been fully traced within its method body and its two direct callees. External callers/readers and native population internals are not claimed exhaustive. No current-health reset is proposed as a toughness transition.

## Direct call graph closure for the inspected JAR

The retained whole-JAR bytecode census and ATTRIBUTE_DIRECT_REFERENCE_INDEX.md now enumerate direct selected references beyond the earlier scoped source map. Additional DoZombieStats callers include VirtualZombieManager.createZombieOutsideWorld, LuaManager$GlobalObject.addZombiesInOutfit, IsoDeadBody.reanimate, and ZombiePopulationManager.addZombieStanding/addZombieMoving. The machine index includes exact descriptors and offsets, so caller names are not inferred from text searches.

Complete direct DoZombieStats body: cognition assignments -> conditional strength assignments -> conditional/random memory assignments -> sight/hearing assignments -> doZombieSpeed -> initCanCrawlUnderVehicle. Native callees: speed branch reads sandbox and crawling, updates locomotion/animation/type; crawl eligibility samples sandbox chance and invokes setter. No health/toughness write in this body. Construction, load, reanimation, reuse, crawling changes and activity reactivation are separate pathways requiring reconciliation.

Direct cognition field reader closure in JAR: IsoDoor/Thumpable/Window.Thump. Direct memory field reader closure: IsoZombie.updateInternal. getSandboxMemoryDuration has no direct Java invocation in the census; its reachability is UNKNOWN. Strength also affects barricade and vehicle/window damage, but player defense/drag-down uses global strength. Toughness affects player critical chance globally and several spawn-health paths. Direct speed references include attacks, hit reactions, animation/audio, pathfinding and network prediction; consult the appendix rather than treating speedMod as the whole system.

Limits: direct JVM instructions only; native bodies, reflection, bootstrap method handles, mods and agents excluded. These excluded pathways are unresolved blockers, not an assertion that they do not exist.
