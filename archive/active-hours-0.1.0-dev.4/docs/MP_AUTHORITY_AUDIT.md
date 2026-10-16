> CURRENT SCOPE — Lua-only custom behavior profiles supersede native activity control. Retained source evidence is historical and does not prove normal Lua invocation or dedicated multiplayer behavior. See LUA_ONLY_API_AUDIT.md and LUA_MULTIPLAYER_AUTHORITY.md; no runtime gate has passed.

# Multiplayer authority audit

2026-10-08. B47ANCE'd Active Hours / B47ANCEDActiveHours. Target 42.21; project version unassigned. Source inspection only.

## Required authority

Server owns configuration, solar progression, per-zombie threshold/state decisions and persistence. Clients may present synchronized results; client-reported activity cannot become authoritative. Native synchronization is preferred only where its complete semantics are verified.

## Evidence

- [VERIFIED] `research/jar-source/zombie/popman/NetworkZombieManager.java:getZombieAuth` and ownership-management paths use GameServer, player connections and zombie owners (:93 onward, :174 onward). Vanilla simulation ownership can be assigned to clients. A server Lua assignment alone does not establish end-to-end authority.
- [VERIFIED] `IsoZombie.updateInternal` applies the global activity decision before the client remote branch. Clients would independently overwrite custom inactivity with the vanilla global phase.
- [VERIFIED] `NetworkZombieAI.set` (:211) serializes `NetworkZombieVariables.getBooleanVariables`; `parse` (:270, :298) applies its inverse. `NetworkZombieVariables.java:getBooleanVariables/setBooleanVariables` includes running, crawling, useless and other flags, but no inactive flag.
- [VERIFIED] Inspected `network/packets/character/ZombiePacket.java` carries walkType, speedMod and booleanVariables, with no explicit inactive field. Movement presentation replication does not prove activity/memory semantics replication.
- [UNKNOWN] All secondary packets, ownership handoff/reconstruction paths and any native alternative capable of carrying an independent inactivity decision. Absence from this packet is not proof that no alternative exists anywhere.
- [VERIFIED] Native constructor/load/reuse resets inactivity to global time. [UNKNOWN] Stable threshold identity through virtual population lifecycle, save/restart and reconnect; no persistent ID hashing is yet justified.

## Decision and failure behavior

BLOCKED: no safe authority model for the requested Lua-only native adapter has been established. No shared gameplay code, client intent packets or custom replication were added. Current failure behavior is vanilla because there is no runnable mod.

[INFERRED] A future native bridge may need a server-owned activity state conveyed to simulation owners and observers, plus interception preventing their vanilla overwrite. It must validate build/capability and fail to vanilla rather than partially changing gameplay. It must avoid trusting client-calculated state and avoid respawn/reuse identity duplication. The exact bridge and network design remain unresolved.

## Human-operated runtime gates

Phase B is BLOCKED pending the source/authority design. Afterwards, record actual installed build and binary hashes for server and both clients. Observe one zombie through inactive/active restoration, native updates, both vanilla modes, speed/stats and ownership changes. Record separate SP and dedicated results.

Full G7 matrix remains NOT TESTED: Night/Day dusk and dawn; Both unchanged; mid-transition spawn; unload/reload; two observers; join/reconnect; restart; high population; randomized sprinters; seasons; storms/indoors; performance/network traffic. Check flicker, disagreement and threshold continuity. No runtime test instructions authorize launching or deploying.

G6: NOT TESTED. G7: BLOCKED / NOT TESTED. G8: BLOCKED. Offline source inspection cannot satisfy any of these gates.
