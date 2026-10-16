> SUPERSEDED ARCHITECTURE — The 2026-10-08 Lua-only handoff forbids native interception, agents and class replacement. This document is preserved historical research, not an active implementation plan. Current proof design: LUA_ONE_ZOMBIE_POC.md. Source observations and historical test evidence remain unchanged.

# Native bridge investigation

2026-10-08 follow-up. Project version unassigned; design/research only. Supersedes no historical findings. No production adapter exists.

## Additional verified constraints

Evidence paths below are relative to `research/jar-source`.

- [VERIFIED] Installed `ProjectZomboid64.json` has classpath `.` before `projectzomboid.jar`. Installed `ProjectZomboidServer.bat` sets `PZ_CLASSPATH=./;projectzomboid.jar`. [INFERRED] Normal application class loading therefore selects an existing loose class first; actual runtime transforms remain [UNKNOWN]. The client JSON also configures an external Java agent. Its implementation was not inspected. No launcher or external mod was changed.
- [VERIFIED] `VirtualZombieManager.java:createRealZombieAlways`, :249, emits OnZombieCreate before server online-ID assignment (:257) and population registration (:267). An OnZombieCreate handler must not assume final identity exists.
- [VERIFIED] `ZombiePopulationManager.java:registerZombie`, :213, returns zero on clients; server registration delegates to native n_registerZombie and a real-zombie registry. Virtualization passes persistentId into n_addZombie (:443, :450, :475); reconstruction reads it (:582) and passes it to createRealZombieAlways (:659, :767).
- [INFERRED] Persistent ID is a plausible server-side threshold key across virtualization. [UNKNOWN] Native allocator reuse, restart durability, uniqueness scope, and serialization guarantees. The inspected Java boundary cannot prove these native behaviors. Client hashing of persistentId would collapse thresholds because registration returns zero.
- [VERIFIED] `VirtualZombieManager.java:reuseZombie`, :142, calls resetForReuse. `IsoZombie.java:resetForReuse` clears persistentId (:3725). Object-reference caches must expire on reuse; online IDs alone cannot establish lifelong identity.
- [VERIFIED] `NetworkZombieAI.java:parse`, :295–301, on remote zombies applies packet speedMod, boolean variables and walkType, then setSpeedTypeFromWalkType. Replicated locomotion can interact with native activity. Synchronizing a boolean alone is not proof that stat recalculation on every peer is safe.

## Smallest candidate interception

[INFERRED] Replace only the decision inside IsoZombie.updateActiveState, leaving the native makeInactive transition operation and the rest of AI untouched. Each native update may perform a constant-time lookup, but must call the transition operation only when necessary, as vanilla already does internally. Disabled/Both Active must delegate to vanilla. Missing capability must retain vanilla before enabling gameplay; mixed supported/unsupported peers must not partially activate the feature.

This is an interception requirement, not a verified loader hook. No base-game class replacement, installed-bytecode edit, reflection hack or repeated Lua override is proposed. A loader would have to transform the effective class at startup on server and clients and report successful exact target matching. Its public API, version, dedicated support, licensing, interoperability and no-match behavior must be verified before adoption. Merely finding an installed loader directory proves none of these capabilities. No dependency has been adopted or bundled.

## Candidate authority flow

1. Server reads vanilla ActiveOnly and server sandbox options and caches weather-independent solar progression.
2. After native registration, server establishes a validated identity/threshold. Threshold stays server-owned; clients do not assign it.
3. Server derives desired state and delivers it to the relevant simulation owner and observers, keyed by an identity plus lifecycle generation. Join/reconnect gets a snapshot; transitions send deltas. Ownership changes require a current state before client simulation resumes.
4. Native adapters use the delivered authoritative decision; unknown/stale identities cannot become client authority. Unload/reuse drops transient bindings. Restart reconstruction uses a proven durable identity or explicitly persisted server mapping.
5. Disable, missing peers and incompatible hooks require a coordinated return to vanilla; a local fallback on one client while the server continues custom activity is unacceptable.

Every step above is [INFERRED] design, not implemented or tested. A generic Lua command packet is insufficient until native zombie lifecycle, relevance and ownership ordering are verified. No packet protocol or network frequency constants are fixed yet.

## Native behavior contract

Retain vanilla makeInactive side effects, including memory and pursuit behavior. Preserve configured speed and sprinter probabilities without extra rolls caused by conflicting updates. Vanilla reactivation itself rerolls speed via DoZombieStats; preserving each zombie's previous speed would change that native behavior. Current interpretation is to preserve vanilla distribution semantics and avoid additional transitions, not to promise immutable individual speed. This interpretation must be explicit in the eventual implementation contract and observed in runtime tests.

Solar progression should use raw native solar data, with explicit endless-day/night handling and measured endpoints. The curve belongs in a bounded sandbox option; automatic dawn/dusk remain behavior, weather activation remains out of scope. Stable option IDs and translations are deferred until implementation is supportable.

## Unresolved prerequisites

| Prerequisite | Status / next evidence |
|---|---|
| Interception loader API and dedicated availability | [UNKNOWN] Verify documented public dependency interface and exact hook target |
| Effective modified-class compatibility | [UNKNOWN] Check transformation against both retained class variants offline, then actual runtime |
| Server decisions reaching owning/observing clients before simulation | [UNKNOWN] Trace native packet/lifecycle entry points and select supported transport |
| Persistent identity through native save/restart/reuse | [UNKNOWN] Native implementation evidence or human-operated lifecycle measurements |
| Native transition ordering versus network speed/stat application | [RUNTIME GATE] One-zombie dedicated proof under both modes, then ownership transfer |

G2 safe architecture remains BLOCKED; Phase B not started. G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. Further mock gameplay logic would not resolve these prerequisites. No project version was invented, no live mod was deployed, and no runtime was launched.
