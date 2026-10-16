Project Version: 0.1.0-dev.4

# Lua multiplayer authority feasibility

## Current MORTIS variant — 2026-10-16

The new variant follows Nightfall's canonical server API: admin intent is validated on server, which alone calls MORTIS acquire/release; clients sample only. No owner-targeted Apply, client native write or acknowledgment. Original dev.3 delayed-revocation evidence remains valid for that preserved protocol. The MORTIS override table is ephemeral and is not itself in component snapshots; native owners may overwrite server helper results. See TEAM_API_RESEARCH.md and MORTIS_SPEED_PROOF.md. Production authority/replication G2 remains BLOCKED; dedicated behavior NOT TESTED.

All references below are retained CFR files under `research/jar-source/`. [VERIFIED source] means source inspection only. Full native ordering evidence remains in NATIVE_OWNERSHIP_ORDERING.md and MULTIPLAYER_AUTHORITY.md; their interception proposals are superseded.

1. `zombie/VirtualZombieManager.java:249` fires OnZombieCreate before online ID assignment `:257`, map insertion `:265` and persistent registration `:267`. Do not dispatch a decision from this callback assuming usable network identity.
2. `zombie/popman/NetworkZombieManager.java:87` evaluates authority; moveZombie `:165` changes owner associations. `zombie/popman/NetworkZombiePacker.java:142` postupdate invokes authority processing `:184` before per-peer authorization and synchronization. Transport ID allocation wraps (`zombie/network/IsoObjectID.java:61`); it is not a permanent zombie key.
3. `zombie/network/packets/character/ZombieListPacket.java:34` updates authorization lists. `zombie/popman/NetworkZombieSimulator.java:154` becomes local, `:162` becomes remote. parseZombie `:194` may reconstruct a missing zombie; `:288` returns for an authorized owner before remote-state application. Ownership is not inferred merely from object existence.
4. `zombie/popman/NetworkZombiePacker.java:100` validates incoming sender against current owner `:111`; applyZombie `:240` accepts owner locomotion. Thus server writes alone cannot establish lasting authoritative speed. `zombie/characters/NetworkZombieAI.java:211` serializes locomotion and `:270` applies it on remote peers.
5. Lua transport entry points exist: `zombie/Lua/LuaManager$GlobalObject.java:5180` targeted sendServerCommand; `zombie/network/GameServer.java:3530` resolves player connection. Client reception `zombie/network/GameClient.java:1141` fires OnServerCommand. Client commands `GameClient:1891` are bound to the sending connection/player by `GameServer:2351`. These establish supported transport, not ordering with native authorization packets.

[UNKNOWN / BLOCKED] Command event timing relative to native owner changes; safe pending-decision resolution after registration; normal Lua owner method/connection usability; stale decision rejection across ID reuse; retries/acknowledgment without duplicate rerolls; server-side ownership; join/reconnect snapshots; persistent identity across virtualization/restart. No packet schema is invented while these remain unresolved.

[INFERRED conditional route] Server chooses fixed category, addresses current owner through verified player-targeted Lua commands, and owner checks current native authority immediately before one application. Server confirms owner-produced native state; observer receives normal locomotion packet. A future decision must be invalidated by owner/identity changes, but a reliable generation model has not been proven. Clients cannot submit category choices or self-assign thresholds. Server rejects mismatched sender/identity/authority intent.

First proof is deliberately one continuously loaded zombie with two clients. Handoff is still required, followed by join/reconnect, relevancy loss, virtualization, reconstruction, reuse and restart before general gameplay approval. No server/client has been launched; dedicated multiplayer correctness is NOT TESTED.

## Owner observation refinement — 2026-10-14

[VERIFIED source] IsoZombie.java:635 delegates isRemoteZombie to inherited isRemote. IsoGameCharacter.java:13640 has a false fallback if no NetworkComponent is present; component/NetworkZombieComponent.java:25-26 reports remote when authOwner is null. Simulator becomeLocal sets connection/player, while becomeRemote clears them (NetworkZombieSimulator.java:154-174). Therefore not-isRemote alone is insufficient evidence of fully initialized, current ownership. Server-null ownership must not be interpreted using a client-local predicate.

[UNKNOWN] Supported Lua combination that proves current owner, registered identity and post-authorization readiness. getOwnerPlayer returns an exposed IsoPlayer candidate, but routing/split-screen/transfer semantics need observation. Do not change native ownership. Owner changes between command receipt and application require rejection/defer behavior; no command format or generation protocol is approved here.

[VERIFIED source] LuaManager$GlobalObject.java:4637-4658 getZombieInfo dereferences zombie.getOwner at :4656 without a null-owner guard and sets networkAi.debugInterfaceActive=true at :4657. It is not passive null-safe telemetry and is excluded from the first proof. Public getOnlineID, getSpeedType, getWalkType, getSpeedMod, isRunning, getActionStateName and getAnimationStateName are narrower observation candidates (IsoGameCharacter.java:3771, :12366, :13255, :13259); actual normal-Lua execution remains UNKNOWN. Read owner player only with nil checks; do not log usernames, connection contents or private player data.

## Replication scope refinement — 2026-10-14

[VERIFIED source] Native boolean mapping carries lunger and running. Speed scalar is encoded as thousandths by owner and divided on server; retained remote AI parser instead passes the short directly to the scalar setter. This is a source-level unit discrepancy, not verified runtime behavior. The first proof must establish observer baseline units and actual motion before mutation; do not add independent observer writers. Packet fields do not explicitly carry normal turnDelta, walkVariant or animation-rate state. Vanilla replication offers a candidate path, not complete profile synchronization proof. See LUA_SPEED_CONTROL.md for exact references and limitations.

## Native owner versus observer parse — 2026-10-14

[VERIFIED source] NetworkZombieSimulator.java:288-291 returns before remote NetworkZombieAI.parse when the transport ID is locally authorized. Otherwise :293-299 clears owner references and invokes remote parser (with a vehicle-hit-state condition). Thus observer scalar application and future owner handoff should be assessed as distinct stages; an owner may retain state instead of receiving an observer correction. Lua command/authorization interleaving remains UNKNOWN. Packet builder uses final getWalkType after its inner AI call, and speed payload is conditional on prediction update bit; see speed audit. Native synchronization remains conditional evidence, not a safe adapter approval.

## Command routing and observation boundaries

[VERIFIED source] LuaManager$GlobalObject.java:5180-5184 exposes player-targeted sendServerCommand and executes it only on server. GameServer.java:3530-3539 silently returns if the player lacks PlayerToAddressMap registration or if the active connection lookup is null. Its signature supplies no delivery acknowledgment. Owner-player presence alone does not guarantee a live route. Never replace failed targeted delivery with broadcast or treat a send call as applied state.

[INFERRED] Current owner player is a narrow routing candidate on server, subject to verified current identity/owner and native connection association. Pending intent must remain unapplied during null/disconnected route or ownership uncertainty. Completion needs observable owner/native state evidence, but no acknowledgment schema or retry protocol is approved until command/authorization ordering is measured. Clients cannot choose categories or thresholds.

[VERIFIED source] OnZombieUpdate can reach observers; native activity update precedes the event. No event implies server authority or post-network readiness. A read-only event filter may observe the selected zombie; profile application still requires a separate verified owner boundary and transition-only dispatch. Missing event coverage must be reported, not filled with unsupported global scans or per-frame writes.

## Isolated command experiment prepared

The user authorized diagnostic flat Lua commands and a one-object epoch/revision model, not a persistent packet protocol. Server admin intent routes to current owner player; client validates native local ownership immediately before the synchronous setter batch; server rejects stale-owner acknowledgments. Mocks show a delayed native revocation can still permit a former local owner write. Native server sender checks should reject its data, but dedicated verification is missing. G2 remains BLOCKED. Observer is never commanded to write. No late-join/restart/reconnect support; invalidation freezes the test. See ISOLATED_SPEED_PROOF.md for precise restrictions.

## Ownership sequence and readiness guards — 0.1.0-dev.3

[VERIFIED retained source] Server NetworkZombieManager.java:188-210 updates old/new connection associations, native owner/player, speed limiter and extra-update scheduling. NetworkZombiePacker.java:142-184 updates authorization before per-peer synchronization. ZombieListPacket.java:34-41 replaces the client's authorization list; NetworkZombieSimulator.java:130-174 calls becomeLocal/becomeRemote to set/clear native owner/player and restore the path target. No dedicated Lua ownership-transition event was established: this prototype observes current native information at OnZombieUpdate/command receipt, not an atomic handoff callback. Exact dispatch timing relative to Lua command streams remains UNKNOWN.

[VERIFIED source] NetworkZombiePacker.java:100-117 rejects an owner input if the sender connection differs from the server's current native owner. This supports a stale-packet rejection hypothesis, not runtime evidence. Whether late local fields affect an observer, survive a later transfer back, or alter native simulation remains UNKNOWN until dedicated traces. Never infer no harm from an acknowledgment rejection.

Readiness fixes: server binds mutation control to the selecting admin, session and monotonic intent IDs; clients accept monotonic apply revisions and native local-owner checks. Empty native tables are omitted (GameClient.java:1897, GameServer.java:2357), so nonempty session payloads are required even for Restore/Dump. Duplicate admin intents cannot dispatch again. Outstanding-command owner change, unobserved/null owner at dispatch, owner change at acknowledgment, missing-ack deadline or API/send errors stop future server mutations. A former owner becomes permanently mutation-disabled after observed local revocation but can continue read-only samples. Idle, observed A->B transfer remains experimentally testable; no automatic retry, replay or hand-back recovery.

[TESTED offline] Delayed native revocation STILL allows an old locally authorized peer to write; server rejects its stale acknowledgment and halts further dispatch. Deadline/STOP cannot recall an in-flight command. These limitations are preserved and exposed, not described as resolved. No client-supplied owner identity is trusted. Late joins/reconnects/restarts and persistent identity remain unsupported for this bounded experiment.

## Human evidence handoff — 2026-10-14

Final review preserves existing local-owner/session/operator/intent/revision guards and explicit pending-transfer/deadline stops. No client-count/ready-ack barrier is implemented: one server and two prepared clients is a checked human precondition. Observer Lua revision can remain zero because Apply is owner-targeted; compare native observations, not equality of every peer Lua revision. Source/mocks cannot establish native rejection or absence of later stale-field propagation. RUNTIME_TEST_RUNBOOK.md separates idle transfer from pending-transfer faults; RUNTIME_EVIDENCE_TEMPLATE.md distinguishes owner report, server/observer evidence and unknowns. No ownership race resolved or gate advanced.
