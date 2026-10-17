# Active Hours features in M.O.R.T.I.S.; standalone mod retained

The user's clarification on 2026-10-16 supersedes the earlier retirement interpretation: B47ANCE'd Active Hours remains maintained standalone, and MORTIS includes all of its features within this mod. The implementations are incompatible. When ProjectMORTIS is enabled, Active Hours disables its own execution; MORTIS takes precedence. Neither mod requires the other. MORTIS owns its included implementation, while the independent project owns its standalone implementation. Both cover the same solar/profile/weighted/configuration/performance scope, retaining neutral defaults and no new archetypes. This is a product/compatibility requirement, not a claim that planned gameplay is complete.

## Compatibility precedence

Independent source `src/B47ANCEDActiveHours/42/` now begins with a read-only activated-mod-list guard. Exact ProjectMORTIS presence disables standalone execution before any future controller registration/write, independent of MORTIS Lua load order; missing/malformed/not-ready detection remains inactive. This guard currently supplies no speed/solar controller. It adds no MORTIS dependency, no mod-list edits, no client override or automatic save/config migration. Dedicated startup behavior remains NOT TESTED. See the [standalone compatibility contract](https://github.com/B47ANCE/B47ANCEDActiveHours/blob/fix/standalone-mortis-precedence/docs/MORTIS_COMPATIBILITY.md).

MORTIS continues normally when that independent Core ID is selected; its present diagnostic conflict check concerns the old `B47AHProof`/`B47AHMortisProof` globals, which the new independent bootstrap never creates. Those old experimental packages are excluded from co-enabled tests. The currently published Active Hours dev.4 item is still the MORTIS-dependent diagnostic, not an automatically converted standalone build. No item is retired, uploaded, deleted or unlisted. No duplicate standalone/MORTIS gameplay effect may run.

Future server-authoritative sandbox namespaces, settings and persisted state remain owned by each implementation. There is no automatic mapping or parity approval: every implemented feature needs matching behavioral acceptance coverage and actual runtime evidence in both products before compatibility claims. Missing production authority remains a blocker, not permission to copy an unsafe writer.

## What is transferred

- The current server-side fixed-speed diagnostic is ported to authoritative `src/ProjectMORTIS/42/media/lua/{shared,server,client}/Mortis/Diagnostics/ActiveHours*.lua`. It uses the same public `LocomotionOverrides.acquire/release` mechanism as Nightfall's UV slow effect, not UV gameplay. Its owner key is now `ProjectMORTIS.ActiveHoursTest.Speed`, and command namespace `MortisActiveHoursTest` deliberately does not accept old proof messages.
- `archive/active-hours-0.1.0-dev.4/` preserves 64 original tracked files byte for byte: both prototypes, all research/design/runbook documents, tests/tooling, version inventory, artwork, Workshop identity and publication record. The exact source commit and every SHA-256 are in [ACTIVE_HOURS_IMPORT.json](ACTIVE_HOURS_IMPORT.json). These are historical records, not runtime source or current MORTIS version mirrors. Do not package, autoload or run their old builders as part of MORTIS.
- The source repository remains maintained independently; the historical import is anchored at [pinned dev.4](https://github.com/B47ANCE/B47ANCEDActiveHours/tree/a8a600b8e0d4c7d4e1dd960378bc88ac17ad6fa6). Its repository governance files were deliberately not installed as nested instructions. Ignored native decompilations/classes/local evidence remain at the original local `B47ANCEDActiveHours/research/`; they were never backed up by that Git commit and are not redistributed. Historical relative `research/` references resolve there; their availability on another machine is UNKNOWN. Existing manifests and documents retain original evidence labels and build references.
- The custom Active Hours artwork is preserved in the archive for this subsystem; it does not replace MORTIS branding. Neither Workshop item changes identity. MORTIS remains Mod ID `ProjectMORTIS`, Workshop `3788592827`; the standalone experimental item `3820693462` remains a historical dev.4 distribution. No deletion, unlisting, upload, repository archival or subscriber migration is performed.

## Current implementation and authority

[VERIFIED source] Loading these three internal diagnostic files defines functions only: no new event handlers, network requests, zombie registry, selection or native movement writes occur until a human explicitly calls `mortisActiveHoursTestStart(true)` on that multiplayer peer. SP is refused. Repeated starts are idempotent. This is an internal developer diagnostic, not an API contract or gameplay option; the explicit true acknowledges a disposable experiment and is not a remote privilege token.

After start, admin A submits intent. The server validates admin status, a single bound operator and native object/online ID, server-session token, monotonically increasing intent, live standing status, callback freshness, Active Only=Both, usable observations and MORTIS canonical authority. Only the server calls acquire/release. Before either mutation it requires boolean on-floor/getting-up observations, an available nonempty native-state key and the existing MORTIS State busy classifier. On-floor, getting-up, attack, fall, climb and other recognized busy transitions reject the request without a native write. Missing/failed observations also reject; passive sampling can continue. A rejected intent is consumed, so a human must send a new intent after recovery; it never replays automatically. Client A and observer B sample fields without setters; no owner-targeted Apply or acknowledgment route exists. Old diagnostic globals block start; if discovered later, the affected request path freezes. This is an additional guard, not a native mod-load-order guarantee: never enable either old diagnostic with the integrated one.

One object is selected through its next eligible callback, never a population scan. Rings contain at most 16 samples/results, with one sample per 60 selected callbacks. Prints occur on explicit dump. There is no climate calculation, continuous correction, native activity toggle, global sandbox mutation or additional attribute writer. Session tokens, priority 20, sampling cadence, ring sizes and safety bounds are internal experiment controls, not hidden production tuning. No production sandbox options are introduced by this transfer.

[VERIFIED source] `Authority.canWriteCanonicalState` establishes MORTIS server/SP authority, not native client simulation ownership. `LocomotionOverrides` invokes the existing native helper adapter on the server. Its general identity/component replication does not serialize this override stack. [UNKNOWN / RUNTIME GATE] Native owner preservation, locomotion replication, actual sprinting, animation, persistence, ownership transfer, native overwrite and headless event behavior require actual Build 42.21 execution. API acceptance is not proof of a native write or remote movement. There is no client-authority fallback.

Release removes only this diagnostic's owner request. Existing higher-priority requests/ceilings remain authoritative within the stack. In dev.3, last-owner release uses the shared five-field observed baseline service and its dedicated persistent journal; it verifies the inherited speed modifier as well as walk/class/crawler fields. Live owner leases are not persisted: owner loss requires coordinated explicit clear, and failures retain the journal. Full helper animation/lunge internals remain unrestored. See [override recovery](LOCOMOTION_OVERRIDES.md). Do not relabel RELEASE_ACCEPTED as restored behavior. Successful release ends this diagnostic owner's expected-category comparison; raw fields, baseline and result samples remain available for human comparison. A remaining higher-priority request or ceiling is not an asserted native overwrite. Active requests still retain the existing category-mismatch observation; no raw getter readback is promoted to restoration PASS. Errors/gaps/replacement freeze further mutations, including release; recovery then requires preserving the failed fixture, not an invented rollback or automatic retry.

No persistent Active Hours policy or session state is added. The shared override service now persists an original-field recovery journal, not this diagnostic session or owner leases. Wrapper replacement, streaming gaps, disconnect/reconnect, server restart and selection re-enrollment have no recovery guarantee. A fresh disposable session is required after a stopped session. The old stale-client race remains evidence for the historical owner-routed prototype; moving to server calls does not prove native ownership safety.

## Included feature scope, also maintained standalone

| Capability | Status / next requirement |
|---|---|
| Fixed tier switching diagnostic | IMPLEMENTED; offline tested, native behavior NOT TESTED |
| Native persistence, owner handoff, observer locomotion, behavioral release | GATED; one-zombie/two-client experiment first |
| Seasonal solar progression | DESIGN ONLY; verify weather-independent dawn/dusk progression and native Lua calls across seasons/endless modes |
| Optional Night / Day / Both activity policy | DESIGN ONLY; future built-in MORTIS subsystem, disabled by default; independent Active Hours Mod IDs remain owned by that project |
| Active/inactive fixed profiles | DESIGN ONLY; terms mean custom profiles, never native inactivity |
| Inclusive weighted ranges, stable per-life choices | OFFLINE EXPERIMENT for proposed validation/CDF only, outside runtime roots; final server configuration, durable identity/revision and persisted choices remain unimplemented; no per-update rerolls |
| Additional attributes | BLOCKED per original reader/writer audit; health is not toughness |
| Save/load, late join/reconnect/restart | NOT TESTED; define lifecycle/persistence before population implementation |
| Insane population performance | NOT MEASURED; cached shared solar values, bounded scheduling, event-driven writes, no per-frame population scans |

Future meaningful enablement, mode, profiles, range endpoints/weights and transition behavior belong in localized, server-authoritative MORTIS sandbox settings. Stable setting IDs/defaults/bounds and existing-save behavior need an implementation decision; historical editable-Lua configuration is superseded. No production options are functional merely because archived designs describe them. Preserve existing consumer owner keys/priorities and deliberate coexistence with Nightfall. Full native restoration and safe authority are prerequisites for affected production writers.

The next milestone is manual passive loading/sampling of this integrated harness, then fixed-speed/ownership/release evidence. Solar/weighted controllers and further dynamic attributes remain deferred. G2 BLOCKED (production), G6 NOT TESTED, G7 BLOCKED / NOT TESTED, G8 BLOCKED. Absorption advances none of them.

The [dev.2 weighted-range experiment](../experiments/active-hours/README.md) starts offline design work without adding a runtime validator or bypassing the archived speed-proof prerequisite. It has no hooks, RNG, gameplay settings, native writes or persisted state; its test explicitly loads it from outside `src/`. It does not establish standalone parity or complete per-life choice semantics.

0.26.0-dev.2 extends isolated design with supplied life/revision choices and
normal/endless phase intervals. [ACTIVE_HOURS_DESIGN.md](ACTIVE_HOURS_DESIGN.md)
records proposed localized sandbox copy, existing-save/refusal behavior, identity
and revision requirements and a parity acceptance matrix. No settings or
controller are installed. Canonical assignment IDs are not proven lifetime IDs;
the experiment requires an externally supplied life token, not an assumed native
identity. Actual solar evidence, persistent lifecycle and native gates remain open.

## Human-operated dedicated experiment

Stop before installation/launch in this development task. The following is preparation, not a claim it ran.

1. Require a reviewed B47ANCEDKnowledgeAndWisdom stage-1 PASS first. A human prepares a disposable dedicated world/profile plus two clients with matching exact source builds of `B47ANCEDKnowledgeAndWisdom` and `ProjectMORTIS`. Do not enable Nightfall, either old Active Hours diagnostic or other gameplay consumers. The published Active Hours item is the old harness, not this source. Set vanilla Active Only=Both, record vanilla Speed unchanged, use exactly one continuously loaded standing zombie. Record actual full builds; target 42.21, minimum metadata 42.20.3 is not runtime proof.
2. Through an already verified Lua execution/debug surface on S, A and B, load the appropriate `Mortis/Diagnostics/ActiveHoursServer` (S) or `Mortis/Diagnostics/ActiveHoursClient` (A/B) module if not already loaded, then call `mortisActiveHoursTestStart(true)`. Require a true return. Dedicated host Lua-console access is [UNKNOWN / RUNTIME GATE]; a text/RCON server console is not assumed to evaluate Lua. If no verified server Lua surface exists, stop and report BLOCKED; do not add a launcher agent, auto-enable bridge or invent a server command. Client local debug availability likewise requires native verification.
3. A is server admin, B an observer. Hold LEFT Ctrl+LEFT Shift: F11 on both; F6 once on A; allow samples, then F11. Select next eligible callback (not nearest). Require matching intended ID on S/A/B, zero API acceptance and zero diagnostic client writes. Nonadmin B's server Dump rejection is expected. Stop for wrong target, STOP/error, gap, replacement or unusable scalar.
4. Only after passive success and a genuine Shambler baseline: F7 Fast Shambler, F8 Sprinter, F9 Shambler, once each. Observe each for at least 60 real seconds without reapplication. F11 roughly every 10 seconds. Record walk/category/modifier, timed displacement, pursuit/pathfinding, lunge/animation and owner/observer agreement. A changed category alone is insufficient.
5. F10 releases once. Record original/released fields and actual behavior on S/A/B; matching fields alone is not successful restoration. Native mismatches are observation, never automatically repaired.
6. In a separate fresh session, observe native ownership transfer, then one new server intent. Record previous/new owner and any delayed or overwritten motion, zero diagnostic client writes, and API/result samples. Stop on uncertainty; no compensating observer setters. Reconnect/restart/streaming remain separate NOT TESTED cases, not recovery instructions.

Keep raw logs private; share redacted session/revision/build/settings/native-owner observations, before/after samples, elapsed distance and behavior, including failures. Do not expose account/connection details. Human results must distinguish VERIFIED, PARTIALLY VERIFIED, FAILED, BLOCKED and NOT TESTED for each capability. No MP success is recorded here.

## Development validation

From the MORTIS root:

```powershell
python scripts/check_versions.py
python scripts/test_active_hours.py
$env:B47_PROOF_LUA='54'
python scripts/test_active_hours.py
Remove-Item Env:B47_PROOF_LUA
python scripts/validate.py --knowledge-and-wisdom '../B47ANCEDKnowledgeAndWisdom'
```

The 26 diagnostic host tests include the ported 14 cases, dormant/explicit/idempotent starts, old-protocol rejection, legacy conflict freeze, canonical version diagnostics, the 64-file hash inventory, conflicting runtime-version rejection and actual MORTIS override/adapter composition with mocked native methods. Regressions cover both Set/Release while busy or unavailable (including getting up, on-floor, attack, climb, fall, missing/nil/throwing getters), consumed-rejection replay, a fresh standing intent, real API state-surface negotiation, and higher-priority-owner release without false mismatch counts or lost raw samples. Neither host Lua version is Kahlua or native MP evidence. Archived tests retain their original paths/versions and are not silently substituted for these tests.

The dev.4 [consolidated runtime handoff](RUNTIME_AUDIT_HANDOFF.md) records the requested build/review sequence and extends the result matrix to owner-loss journals, non-default scalars, profile exclusion, streaming/restart and migrated consumer feeding. It does not change this dormant diagnostic or close any native gate.
