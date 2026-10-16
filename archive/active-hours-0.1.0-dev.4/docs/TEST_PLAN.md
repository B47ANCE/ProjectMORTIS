Project Version: 0.1.0-dev.4

# Current Lua-only validation plan

Current MORTIS variant: scripts/test_mortis_speed_proof.py under development lupa Lua 5.1/5.4 (B47_PROOF_LUA=54). Fourteen tests per engine cover server-only API routing, client nonwrites, limited release, admin/operator/session/replay checks, absent/incompatible API, authority/error stops, transfer, ignored observer Apply, no overwrite repair, bounded rings and event deduplication. The 36 original tests still exercise frozen dev.3 source, not this backend. Both suites are offline only. Current human procedure/evidence: MORTIS_SPEED_PROOF.md. The original runbook remains historical, not the new install target.

LUA_ONE_ZOMBIE_POC.md replaces the loader/native-toggle experiment described historically below. First validate fixed speed through normal Lua on one continuously loaded zombie, dedicated server and two clients: owner-only application, native observer replication, true movement/animation, reverse transition, restoration, all relevant global Speed settings, native stats resets and authority handoff. Record exact effective peer provenance and sequence timestamps. No solar or extra attributes in the first proof.

Then test registration delay, stale/reused online IDs, join/reconnect, relevance, virtualization/reconstruction/restart and server-only ownership before wider gameplay. Existing offline assertions remain historical source tests; no Lua profile implementation is tested. G2 BLOCKED; Phase B NOT STARTED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. No launch/deployment authorization is implied.

---
Historical test plan follows; interception and native transition experiments are superseded.

# Test plan

No runnable gameplay exists. G2 BLOCKED; Phase B NOT STARTED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. This plan does not authorize launch or deployment.

After supported loader/identity/transport proof, test one zombie on a dedicated 42.21 server with two clients: record baseline, server threshold, activate/deactivate under Night and Day, observe native updates and ownership transfer. Test one attribute at a time, then restoration, overwrite timing, damage semantics, reconstruction and network agreement. Native transition counters must show no duplicate toggles or extra DoZombieStats calls.

Before gameplay activation, offline configuration tests must cover Core only, each module, both modules, missing dependency, all vanilla ActiveOnly values, warning suppression with enforcement retained, malformed files, unknown enums, unsupported attributes, fixed/ranged precedence, one-category weights, proportional two-category 20/40, zero/zero, three-category 10/40 -> 10/50/40, reversed range, negative/over-100/nonfinite weights and tolerance-aware totals. No configuration implementation is yet under test.

Runtime matrix: early/mid/late dusk and dawn, endpoints, seasons, endless/degenerate solar modes, storms/indoors/artificial lights, mid-transition spawn, unload/reconstruction, restart, join/reconnect, reuse and ownership changes. Test Both policy with Active profile and coordinated disable/restoration. Verify no hidden client policy or attribute divergence.

Insane population acceptance requires PERFORMANCE_DESIGN.md measurements, stress tests and native/multiplayer correctness. Offline mocks cannot satisfy G6 or G7. Version must be assigned before implementation and recorded in each actual runtime test.

The foundational prototype entry sequence is now specified in ONE_ZOMBIE_POC_ARCHITECTURE.md. Offline evidence tooling checks bytecode instruction alignment and both retained activity seams, but no transform was executed. Future research-transform tests must include unknown/no-match descriptors, duplicate registration, later-agent changes, helper linkage, unchanged makeInactive and every unrelated method. First runtime pass remains inert, then connected disable/restoration, then one activity decision; attributes are separate later experiments. No current runtime gate is PASS.

## Isolated speed-source validation

Run python scripts/test_speed_proof.py (development lupa dependency). Sixteen actual-Lua mock tests cover command trust, nominal owner/observer behavior, category mapping, connected field restoration, transfer, duplicates, failures, anomalies, drift and hotkeys. Delayed-authority test intentionally demonstrates the unresolved old-owner local-write limitation. Dedicated Shambler -> Fast Shambler -> Sprinter -> Shambler, overwrite, handoff and behavioral restoration instructions are in ISOLATED_SPEED_PROOF.md. Mocks do not satisfy G2/G6/G7/G8.

## Readiness regression suite — 0.1.0-dev.3

Run the existing three project commands, with scripts/test_speed_proof.py defaulting to development lupa.lua51; repeat with B47_PROOF_LUA=54 for Lua 5.4. Thirty-six tests run per Lua engine. Added native empty-table omission, required walk/category, malformed apply before write, session payload, stale/duplicate admin intent, operator binding, missing-ack/restore deadlines, spoofed observer ack rejection, post-revocation read-only samples, bounded rings, nil API failures, failed restoration rollback, structured dump context, modifier guards and send exceptions. The retained delayed-authorization test intentionally demonstrates an old local write; a green test is not a race fix or dedicated PASS.

Current exact installation/human matrix is ISOLATED_SPEED_PROOF.md. Collect session/revision and counters plus actual displacement, animation and pursuit behavior for server/owner/observer. Use the seven-capability runtime classification table there; all runtime behaviors are NOT TESTED, with ownership safety BLOCKED for production. Thirty-six mocks, nine version tests and five decoder tests are offline only.

## Final run preparation — 2026-10-14

Runbook: RUNTIME_TEST_RUNBOOK.md. Blank form: RUNTIME_EVIDENCE_TEMPLATE.md. Required first stage is PASSIVE: F11 on both clients, A server-dump/admin route, one F6 candidate, getters/selected identity/owner consistency, zero mutation counters, no pending/STOP. Only after every prerequisite is actually met may the human perform fixed transitions and 60-second observation/connected restoration. Transfer and overlap faults use fresh disposable private runs; no ownership forcing or packet tools. Failure to obtain a handoff is NOT TESTED, not success.

Offline recheck at unchanged dev.3: nine version tests PASS, thirty-six proof tests PASS per Lua 5.1 and Lua 5.4 engine, five decoder tests PASS. Source and mocks are not Kahlua/native-network evidence. No code changes were needed. The operator must verify launcher argument delivery and absence of agent/override contamination before live setup.
