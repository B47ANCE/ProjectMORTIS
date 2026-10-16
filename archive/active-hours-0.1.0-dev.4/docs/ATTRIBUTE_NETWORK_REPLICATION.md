> CURRENT SCOPE — Lua-only custom behavior profiles supersede native activity control. Retained source evidence is historical and does not prove normal Lua invocation or dedicated multiplayer behavior. See LUA_ONLY_API_AUDIT.md and LUA_MULTIPLAYER_AUTHORITY.md; no runtime gate has passed.

# Attribute replication evidence

2026-10-08; source-only Build 42.21. Paths relative to research/jar-source.

`zombie/characters/NetworkZombieAI.java:set(ZombiePacket)` :211–227 writes boolean variables, health, speedMod and walkType. `parse(ZombiePacket)` :270–311 applies speedMod, flag mapping and walkType to remote zombies and derives speedType. A health field being serialized does not prove complete authoritative damage/toughness handling; parse here does not establish an injury-preserving profile policy.

`zombie/network/packets/character/ZombiePacket.java` declares serialized fields. `zombie/characters/NetworkZombieVariables.java` has no inactivity, strength, cognition, sight, hearing, memory or under-vehicle-crawl flag. The crawling/canWalk flags are different from canCrawlUnderVehicle. These are [VERIFIED] observations limited to the inspected mapping, not proof that no secondary protocol exists.

`zombie/popman/ZombieStateFlags.java:intFromZombie` records under-vehicle eligibility. This supports the population boundary, not automatic live client synchronization of that property. Constructor/load/reuse still perform native stat initialization. No custom profile values have a demonstrated native serialization path through virtualization or server restart.

Authority must remain server-owned even when zombie simulation is assigned to a client. A native bridge needs consistent activity and supported profile decisions on owner and observers, lifecycle-generation protection, join snapshots and coordinated fallback. Client commands must not set authoritative attributes. Do not replace this missing design with repeated client field writes.

[UNKNOWN] Full ownership-handoff and packet dispatch ordering; special health packets; complete relevant-client selection; native allocator durability; attribute recalculation after remote parse; supported custom transport. None is marked PASS. G7 BLOCKED / NOT TESTED.

## Follow-up native ordering

NATIVE_OWNERSHIP_ORDERING.md now traces the server owner-connection check, owner feedback, initial/request synchronization, observer relevance filter, client authorization and owner early-return path. NetworkZombiePacker.applyZombie :255 explicitly writes packet health; :256 writes speedMod and :274–276 restores flags/walkType/derived type. Thus the previous health-parsing uncertainty is narrowed: owner-to-server health writes are verified, but injury-preserving toughness profiles remain unresolved.

Native Lua command addressing and connection-derived client-command identity are now verified entry points. Cross-stream ordering/reliability and an ownership-readiness barrier remain UNKNOWN. The new proof design limits itself to two already prepared/relevant clients and a continuously loaded object. No production packet protocol or attribute synchronization has been implemented.
