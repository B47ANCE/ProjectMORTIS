# Project M.O.R.T.I.S. 0.26.0-dev.7 playtester handoff

Dev.6 adds [private result-record validation](docs/RUNTIME_RESULT_FORMAT.md),
exact-input offline integration CI and [API/crash-boundary findings](docs/ACTIVE_HOURS_API_AUDIT.md).
These do not grant runtime acceptance. Additional differing loose engine classes
reinforce the clean-baseline prerequisite. Humans operate and review every native case.

Human-operated native queue: [docs/HUMAN_RUNTIME_TESTS.md](docs/HUMAN_RUNTIME_TESTS.md).
Start with its clean vanilla-client prerequisite and exact Knowledge & Wisdom
0.16.0 input. The normal launcher has custom Java/loose-class contamination.
No game/server was opened or mod deployed during preparation. Affected dependency
MP APIs are intentionally blocked; never bypass or downgrade them for a test.

Begin only after the B47ANCEDKnowledgeAndWisdom stage-1 report is reviewed as PASS. Enable
only `B47ANCEDKnowledgeAndWisdom` and `ProjectMORTIS` on a disposable single-player save,
open the Lua debug console, and run `mortisTestStart(true)`.

1. Observe ordinary untyped zombies; record whether vanilla movement and targeting remain normal.
2. Stand near a loaded zombie and run `mortisTestInspect()`. Keep that zombie nearby.
3. Fight several zombies; check hits, shoves, stomps, prone recovery, and uncommon trips.
4. Observe a dense group near walls, stairs, and low obstacles; check for displacement or group-wide trip cascades.
5. Save/quit, reload, approach the tagged zombie, and run `mortisTestPersistence()`.
6. Run `mortisTestResearch()` and follow its on-screen instructions. Confirm research stays locked when it should and becomes available when instructed.
7. Run `mortisTestSandbox()` and follow its instructions. Confirm the M.O.R.T.I.S. settings appear and that the requested test setting actually changes.
8. Mark hosted/dedicated testing BLOCKED until it is actually performed; do not infer it from single-player.
9. Run `mortisTestReport()`.

Return `%USERPROFILE%\Zomboid\Lua\theWorks Test Results - ProjectMORTIS.txt`,
`console.txt`, and screenshots for visual failures. Do not add medWorks or later
Nightfall dependencies until this stage is reviewed.


Active Hours is now a MORTIS subsystem in development. Its separate opt-in one-zombie/two-client experiment is in [docs/ACTIVE_HOURS.md](docs/ACTIVE_HOURS.md). Do not start it during the general stage-2 sequence above or enable either historical standalone proof. Native client/server activation and locomotion remain NOT TESTED.

M-05 uses food-provider API 1.6.0. Nightfall 0.29.1-dev.1 now implements reserve/commit/rollback with actual-coordinator host coverage; native compensation and persistence remain unverified. Follow docs/FOOD_TRANSACTIONS.md on disposable fixtures only.

Dev.2 adds discovery/quarantine/no-effect safeguards. In a disposable migrated-provider fixture, an ignored/rounded native write or invalid quote must not remove stock; a quarantined provider must not hide a healthy source for another zombie. Confirm all 37 English sandbox option names/tooltips in the native settings UI; other-language fallback remains untested. The weighted-range experiment is offline only and supplies no new gameplay option.

Dev.3: follow docs/LOCOMOTION_OVERRIDES.md with a non-default original speed modifier. Confirm higher-priority owner/ceiling composition, last release restores all five observed fields, profile writes/assignment clear refuse while owned, and coordinated release permits a clean retry. For a disposable saved journal after owner loss, load components, verify individual re-enrollment/release refuse, then coordinate explicit server clear; do not promote this to automatic session recovery. Native animation/ownership/observer/restart behavior remains NOT TESTED.

Dev.4: use the [complete runtime audit handoff](docs/RUNTIME_AUDIT_HANDOFF.md) for exact build records, dependency stage-1 review, isolated SP stage 2, the dedicated two-client experiment, Nightfall feeding and per-case result forms. It prepares tests; no game/server launch, installation or deployment was performed or authorized.

For the local main-menu Zombie Creator, follow docs/ZOMBIE_CREATOR.md on disposable draft files. Verify release-mode entry/activation, repeated menu navigation, all fields, controller/keyboard/focus, scale/resize, save/load/delete, Unicode, preview/export, preservation on faults and no world/network effects. No 3D preview, spawning or automatic server import is included. Gameplay stage-1/stage-2 and dedicated gates remain separate.

0.26.0-dev.2 adds the reviewed repository-only creator export fixture and isolated
Active Hours life/revision/phase experiments. These are offline preparation,
not installed gameplay or runtime evidence. The current input table and separate
creator acceptance suite are in docs/RUNTIME_AUDIT_HANDOFF.md. Nightfall 0.29.1's
feeding migration is merged; remaining feeding work is native verification.
Proposed settings and the unresolved independent life-token/solar/owner contracts
are in docs/ACTIVE_HOURS_DESIGN.md. Preserve G7/stable G8 BLOCKED.

0.26.0-dev.4: run [the read-only preflight](docs/PREFLIGHT.md) and freeze its exact
source inventories before human testing. The original Nightfall 0.30.0 audit identified
three P1 state/cleanup defects plus a readiness diagnostics gap. The corrected
merged source has [separate passing closure evidence](docs/NIGHTFALL_INTEGRATION_CLOSURE.md);
native consumer acceptance remains separate.
The configuration/key experiment is offline only and installs no sandbox option.

0.26.0-dev.5: optional `--nightfall <exact-source-root>` checks source inputs and
reviewed contracts without loading Lua; other family installations stay NOT CHECKED.
Keep Nightfall excluded from creator and isolated baseline/locomotion suites.
The ownership/reconfiguration experiment is repository-only; do not load it into
PZ or treat its simulated context/receipt flags as native proof.
