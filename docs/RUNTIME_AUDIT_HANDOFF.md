# Audit runtime test handoff - 2026-10-16

Prepared at the user's request. **No test below has run.** This document does not authorize installation, packaging, deployment, game/server launch or publication. A human must arrange each environment separately. Use disposable backed-up saves and private raw logs. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. Production Active Hours remains stopped at its native authority/restoration gate.

The user's current instruction leaves tests requiring an open game to humans.
Start with [HUMAN_RUNTIME_TESTS.md](HUMAN_RUNTIME_TESTS.md): it records the current
clean-client blocker, 0.16.0 dependency guard, exact source inputs and case queue.
Automation has not opened PZ/server or collected native UI/storage evidence.

## Freeze the build set and record the environment

Before testing, fetch/check each chosen branch without changing source, reconcile unrelated dirty work, record exact commit and source/package SHA-256, then put identical bytes on every participant. Pending PRs are source branches, not merged main or uploaded Workshop builds. Never use the historical Contents trees or published old Active Hours proof as the new build.

| Input | Prepared source | Required evidence |
| --- | --- | --- |
| Knowledge & Wisdom | 0.16.0, source head 6ba66c0d8f246d438f2e2f3c974fee9f77fdb426, merged dependency PR #1 | Reviewed current scoped SP stage-1 result; exact input in evidence/knowledge-dependency-6ba66c0-git-bytes.json. Affected MP APIs refuse storage; no guard bypass or downgrade |
| MORTIS | 0.26.0-dev.5 candidate, API 1.6.0, protocol 2 | Record selected feat/integration-ownership-model head and current mortis-runtime-input.json hashes; frozen merged dev.4 closure uses f4ca76c99122f9d652325c5cda49bc14cfc2c02a. Runtime diff since the creator baseline remains version mirrors only |
| Nightfall, only in the later consumer suite | 0.30.1-dev.1, merged PR #6 | 5690021f6d6f5b87ba86e8c9964c527de6d168aa; source closure/regressions in NIGHTFALL_INTEGRATION_CLOSURE.md; native acceptance remains open |
| Later Nightfall dependencies | B47ANCEDSPXTRM, B47ANCEDPower, B47ANCEDHealthCare, B47ANCEDKnowledgeAndWisdom, ProjectMORTIS | Freeze exact inputs and loader contracts. Optional Nightfall preflight verifies MORTIS/Knowledge pairing only; the other three installations remain NOT CHECKED. Historical dirty snapshots are not current proof |
| Engine | Locally inspected Steam build 25485521; executed SemVer UNKNOWN | Record actual full client and server versions/build IDs, OS and selected class/source provenance; stop on mismatch |

Record server profile/world ID (redacted), disposable save lineage, enabled Mod IDs/load order, full sandbox settings, client A/B roles and verified native simulation-owner observation method. A native owner must be observed through an established surface; proximity or MORTIS canonical authority is not proof of ownership. A text/RCON console is not assumed to evaluate Lua. If server Lua execution or native-owner observation is unavailable, mark the affected case BLOCKED and report the missing surface. Do not add Java, an injection agent, guessed commands or client setters.

## Stage 1 - Knowledge & Wisdom alone

Use its current docs/IN_GAME_TESTING.md, docs/VALIDATION_0_16_0.md and
docs/MP_AUTHORITY_PLAN.md with TESTER_HANDOFF.md and the reusable
docs/RUNTIME_VALIDATION_0_14_0.md procedure. Results must identify 0.16.0 and
the frozen current bytes. On a disposable SP debug character,
`B47ANCEDKnowledgeAndWisdomTestStart(true)` starts the existing kit; finish with
`B47ANCEDKnowledgeAndWisdomTestReport()`.

Capture prerequisite denial before/after learning, viewer/redaction, one-time progression, journal save/reload and disabled inspection behavior. Add current 0.15.0 cases: malformed/unknown prerequisites deny, rejected journal operations preserve data, missing/corrupt journals do not expose actions, split-screen viewport/scroll/buttons and keyboard/controller. Native authoritative writing/capture, exact raw XP restoration and recipe/media capabilities remain separately blocked unless an actual supported path exists; do not invent a successful action to complete a row.

Return the generated Knowledge & Wisdom report plus redacted errors/screenshots. Have it reviewed as PASS for the selected stage-1 scope before MORTIS stage 2. A scoped SP PASS does not close the dependency's dedicated/privacy/late-join/restart gates. If a prerequisite fails, stop dependent testing and retain the failed fixture.

0.16.0 intentionally refuses affected multiplayer APIs with
`MULTIPLAYER_STORAGE_UNAVAILABLE`. Missing server-private persistence is an
implementation blocker, not merely missing test evidence. An isolated MORTIS
locomotion experiment may proceed only after prerequisite review establishes
that its setup needs no affected API; otherwise stop. Never infer dependency MP
gameplay/privacy PASS from locomotion observations or restore unsafe 0.15.0 behavior.

## Stage 2 - MORTIS SP baseline

Enable only B47ANCEDKnowledgeAndWisdom and ProjectMORTIS, then follow TESTER_HANDOFF.md: `mortisTestStart(true)`, `mortisTestInspect()`, `mortisTestPersistence()`, `mortisTestResearch()`, `mortisTestSandbox()` and `mortisTestReport()`. Check ordinary movement/targeting, hits/shoves/stomps/prone recovery, crowd obstacles/trips, tagged identity save/reload, research gating and a real sandbox change. Keep the Active Hours diagnostic stopped during this suite.

Return `Zomboid/Lua/theWorks Test Results - ProjectMORTIS.txt`, redacted console excerpts and screenshots. Check all 37 English sandbox names/tooltips in the actual UI; repeat a non-English locale for fallback/rendering and identify missing/unreadable text. Catalog checks are not fluent translation review. Linux path-case execution is its own environment row.

## Stage 3 - one zombie, dedicated server and two clients

The controlling detailed runbook is [ACTIVE_HOURS.md](ACTIVE_HOURS.md#human-operated-dedicated-experiment). Use only the two stage-2 mods, one continuously loaded standing zombie and vanilla Active Only=Both. A is an admin; B observes. Exclude Nightfall, standalone Active Hours and both historical proof packages. Record vanilla speed unchanged. Require a genuine reconstructible Shambler original and a non-default inherited speed modifier; if that fixture cannot be verified, mark the scalar-restoration row BLOCKED rather than setting random values on a client.

1. Through verified Lua surfaces, load Mortis/Diagnostics/ActiveHoursServer on S and Mortis/Diagnostics/ActiveHoursClient on A/B if needed. Call `mortisActiveHoursTestStart(true)` on each, requiring true. SP must refuse. No handlers or writes should exist before explicit start.
2. Hold LEFT Ctrl+LEFT Shift: F11 on A/B dumps; F6 once on A selects the next eligible callback, not the nearest zombie. Require the same intended online/native identity on S/A/B and zero diagnostic client writes. Record at least a passive window before mutation. B's nonadmin server Dump rejection is expected.
3. F7 requests fastShambler, F8 sprinter, F9 shambler, once each after the previous observation. Observe each for at least 60 real seconds without reapplication; dump roughly every 10 seconds. Record requests/results, state, walk/class/modifier, crawler fields, timed displacement, pursuit/pathfinding, lunge/animation and owner/observer behavior. Acceptance or matching getters alone is not a behavioral PASS.
4. F10 releases exactly this diagnostic owner. Compare every original field and motion/animation/lunge on all peers. Remaining higher-priority owner/ceiling effects are legitimate; do not mistake them for a lost release. No corrective observer setters.
5. In a fresh session, observe a real native ownership transfer, then send one new server intent. Record old/new owner, latency, observer agreement and delayed overwrites. STOP on wrong identity, error, gap, replacement or uncertain owner; preserve the fixture. Do not keep pressing keys to erase a failure.

Use separate disposable sessions for the following rows. The harness freezes on replacement/gap; it does not implement automatic recovery. Do not circumvent that freeze to complete persistence cases.

| Case | Required result/observation |
| --- | --- |
| Busy/on-floor/getting-up/attack/climb/fall | Set and Release refuse native mutation while unsafe; no forced bypass. A fresh safe intent may be tested after recovery, never replay an old rejected intent |
| Multiple owners + ceiling | Using a verified server fixture, acquire separate test owners/priorities and a ceiling through Mortis.LocomotionOverrides; preserve unrelated owners; last release restores all five original observations |
| Profile/assignment exclusion | While owned, profile application and assignment clear refuse. Release only the fixture's own leases/ceilings, then retry. If another consumer still owns movement, remain blocked; never clear it just to obtain success |
| Ignored/partial setter or failed serialization | Only inject faults through a verified disposable fixture. Expect retained journal and explicit failure; no false restored result. No verified injection surface means BLOCKED, not PASS |
| Saved owner loss | Load saved components first. Acquire/individual release must refuse a journal lacking a live owner stack. Coordinate all consumers before explicit server Mortis.LocomotionOverrides.clear(zombie); verify restored observations and journal deletion before re-enrollment |
| Streaming/reconnect/late join | Preserve before/after identity, journal and observer evidence. A frozen diagnostic is an observed limitation, not proof of production recovery. No capture of modified fields as new originals |
| Dedicated save/restart | Record disk/save boundary and exact restart inputs. Originals persist; live requests are not replayed. Unknown/corrupt/newer components fail closed. Native durability and behavior must be observed |

Full animation/lunge/private-helper restoration has no verified complete inverse. Report any discrepancy as FAILED/PARTIAL, even with five matching fields. Safe production authority and restoration must be established before solar/day/night population writers are implemented.

## Stage 4 - migrated Nightfall feeding

Only after prerequisite reviews, use a separate disposable full-family world with the frozen Nightfall fix and current dependencies. Follow Nightfall docs/EFFIGIES.md, docs/MORTIS_RECOVERY.md and docs/VALIDATION_0.30.1-dev.1.md (older provider/audit reports remain historical). Do not mix this consumer suite into the isolated speed proof.

Record source ID/status/revision, source parts/calories/edible material, exact actor identity, native hunger/component hunger/starvation and event count before/after. Check canonical and material-less legacy sources, all source-signature reactions and the research requirement. A 600-calorie source at the default 2000 calories/full feed quotes .3 before the existing server multiplier and hunger clamp; elapsed advancement is separate. Attraction/avoidance/destruction must not grant feeding.

| Case | Acceptance |
| --- | --- |
| Success | Hunger changes once by the validated quote; tissue is consumed once, tombstone committed, ZombieFed once, then world removal observed by A/B |
| Two actors / competing destruction | Exclusive source lease; no double food relief or duplicate material loss |
| Ignored hunger setter / source-save failure / abort after commit | With a verified fault fixture, no success event/removal; original tissue, claim, persisted state and post-advancement hunger restored |
| Newer/foreign source during compensation | Refuse uncertain overwrite; MORTIS provider/entity quarantine retained for diagnosis; no blind reset |
| Native cleanup failure | Feed remains committed; inert consumed record cannot feed or re-register; bounded diagnostic. Observe any residual visible object |
| Range/floor/client/unloaded/stale identity | Refuse source mutation, not a client-authority fallback |
| Save/reload, late join/rejoin, streaming and dedicated restart | Record source/tombstone, absence of duplicate stock/reward and hunger consistency on all peers; cross-resource crash atomicity is not implemented or certified |

Fault injection/native inspection without a supported surface is BLOCKED. Offline tests already simulate these faults; they do not close the native rows. No real player saves or automatic repair scripts.

## Separate creator acceptance suite

Use [ZOMBIE_CREATOR.md](ZOMBIE_CREATOR.md#evidence-and-native-acceptance) for the
local presentation/storage suite, separate from gameplay stage ordering. Record
the selected MORTIS/dependency/engine commits and builds just as above. Cover
release-mode entry, repeated navigation and another menu mod; every section,
mouse/keyboard/controller/modal paths; 800x600/larger/scaled/too-small layouts;
Unicode, save/reopen/delete/restart; disposable A/B corruption/future/stale/write
failures; preview/export equality and existing-file preservation. Verify no
world registration, assignment, spawning or network effect.

The reviewed repository fixture tests generator/registry contracts offline; it
does not prove main-menu loading or native file durability. A separately owned
manual content fixture needs actual chosen dependencies and matching peer bytes;
its in-world behavior retains the gameplay gates. Missing native observation or
safe fault-injection surfaces are BLOCKED, not simulated PASS.

## Result record - copy once per case

```text
Case ID / environment (SP, hosted, dedicated, Linux):
Date / tester / reviewer (public aliases only):
Mod versions, API/protocol, commits, source/package hashes:
Actual server and both client engine versions/build IDs:
Mod list/load order and sandbox settings:
Disposable save / initial identity / source ID/revision:
Verified server Lua and native-owner observation surfaces:
Before observations / expected result:
Exact action, peer and elapsed time:
After observations (S/A/B separately), event/write counts:
Save/rejoin/restart boundary, if exercised:
Outcome: VERIFIED / PARTIALLY VERIFIED / FAILED / BLOCKED / NOT TESTED
Private evidence location, redacted excerpt/screenshot:
Reviewer decision / unresolved limitations:
```

Keep credentials, connection/account/player identifiers and raw diagnostic saves/logs out of public Git. A source inspection is [VERIFIED: source]; a host result is [TESTED: offline]; only actual recorded execution establishes runtime evidence. Leave missing rows NOT TESTED. G7 requires reviewed dedicated acceptance, including failure/lifecycle cases, and does not follow merely from stage-1 SP or the speed experiment. G8 also needs all version/package/provenance/release gates and explicit release authorization.

## Remaining implementation after evidence

Once native blockers are resolved, implement server-localized enablement/mode/profile settings, verified seasonal solar sampling, durable separate per-life/config-revision weighted choices, bounded event-driven population lifecycle and independent standalone parity. Durable consumer-lease recovery requires a concrete coordinated ownership contract; no automatic replay or population reset is implied. Fluency review, Linux/native UI, anatomy/rendering, source conservation and full-family behavior retain their documented separate gates.
