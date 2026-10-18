# Changelog

## 0.26.0-dev.9 - bounded hunger population work, 2026-10-17

- Replace per-zombie direct hunger/food searches with a deduplicated authority-local FIFO, drained by the existing global tick under server HungerWorkPerTick (default 32, 1–512). Keep staggered admission and elapsed-time catch-up; starvation, nutrition and transaction schemas are unchanged.
- Weak actor ownership, constant-time cancellation, bounded stale inspection, re-entry/invalid-config protection and accurate queue/work/error diagnostics. Persist worker changes outside the per-zombie update. Native/dedicated population performance remains NOT TESTED; G7/stable G8 BLOCKED. No build/deploy/upload.

## 0.26.0-dev.8 - branded thumbnail revision, 2026-10-17

- Replace the project/mod thumbnail and Workshop preview authoring assets with the newly supplied artwork carrying the B47ANCE's heading. Preserve both full-size originals and the dev.7 publication receipt.
- Export the complete image at 512x512 without cropping or redrawing; leave the small UI icon and gameplay/API/save/network behavior unchanged.
- Compatible asset checkpoint within the unreleased 0.26.0 target. Offline asset/source checks only; no packaging, deployment, merge or Workshop upload. Native testing remains human-operated; G7/stable G8 remain blocked.

## 0.26.0-dev.7 - supplied project thumbnail, 2026-10-17

- Use the owner-supplied artwork for the 512x512 project/mod thumbnail and Workshop preview; preserve the original 1254x1254 PNG as an authoring source.
- Keep the small UI icon, gameplay, public API and runtime/save/network schemas unchanged. Update current version/input/overview mirrors; retain prior publication/package evidence.
- Published the explicitly authorized MP test update from 3122532 to existing Workshop item 3788592827. SteamCMD success, canonical public description and exact thumbnail bytes verified; prior packages preserved. No deployment or native tests; G7/stable G8 remain blocked. See the versioned publication receipt.

## 0.26.0-dev.6 - offline CI, API audit and recovery safeguards, 2026-10-17

- Publication preparation for this version adds the required MP-test label, explicit native/dependency limits, public source link and isolated package/provenance checks. Runtime source and canonical version are unchanged; upload status is recorded separately, never inferred from preparation.
- Published the explicitly authorized MP test distribution from e96b56e to existing Workshop item 3788592827; SteamCMD success and public description verified. Steam restart declined; native tests and G7/stable G8 remain blocked. See the versioned publication receipt.

- Run exact pinned Knowledge integrations and Nightfall regressions in a separate read-only CI job.
- Correct the older Nightfall CRLF fixture's Git-byte attribution after strict Linux CI rejection; preserve historical evidence and select a new true-Git manifest without weakening byte checks.
- Validate private human-result records for case coverage, candidate identities and contradictions; never grant runtime gates automatically.
- Audit installed seasonal API callers, life-identity candidates and persistence boundaries; record additional differing loose classes without modifying the game.
- Fix isolated ownership checkpoint admission and outcome sequence headroom, with failing-before/fixed-after regressions and crash-cutpoint coverage.
- Runtime changes are version mirrors only; API 1.6.0 and runtime/save/network schemas unchanged. Runtime testing remains human-operated; G7/stable G8 BLOCKED.

## 0.26.0-dev.5 - integration closure and ownership model, 2026-10-17

- Verify the exact merged MORTIS/Nightfall/Knowledge combination with pinned consumer regressions; preserve the original failing audit and add separate source-closure evidence.
- Reconcile current roadmap, overview and human handoff with all four Nightfall source fixes; native acceptance remains unverified.
- Extend read-only preflight with optional exact Nightfall input, loader/API/food/recovery contracts and explicit unverified remaining dependencies. It executes no Lua, launches no process and writes no report.
- Add an isolated Active Hours ownership/reconfiguration reducer and failure/replay/lifecycle regressions outside runtime roots; no production policy, storage or controller is installed.
- Compatible 0.26.0 development checkpoint; runtime changes are version mirrors only, API 1.6.0 unchanged. All native tests remain human-operated; G7/stable G8 BLOCKED.

## 0.26.0-dev.4 - offline configuration, overview and preflight, 2026-10-17

- Normalize the proposed Active Hours configuration in an isolated experiment. Encode selected probabilities as reduced rational keys; equivalent distributions, ignored fields and phase/enablement changes retain choices. No production validator, options, RNG, persistence or controller is installed.
- Adopt the reviewed mortis feature descriptor with version/source binding and normal validation. Preserve source/foundation/planned/blocked distinctions and the historical-layout review limitation.
- Add the read-only local preflight command: verify exact MORTIS/dependency input hashes, overview binding, launcher/environment overrides, selected engine classes and explicit Steam metadata. Emit redacted JSON only; never launch, deploy, fetch, write or claim native PASS.
- Audit pinned Nightfall 0.30.0 against current MORTIS/Knowledge source: reproduce three P1 state/cleanup defects and an API-presence diagnostics coverage gap in a bounded host probe. Keep consumer production source unchanged and record exact evidence and fixes required.
- Compatible 0.26.0 development checkpoint; public API 1.6.0 and world/network schemas unchanged. All runtime testing stays human-operated; G7/stable G8 BLOCKED.

## 0.26.0-dev.3 - human native-test preflight, 2026-10-16

- Keep tests that require opening PZ/server human-operated, as clarified by the user. Prepare the current test order, result matrix and concrete setup blockers; no game/server was opened or mod deployed.
- Freeze Knowledge & Wisdom 0.16.0 at public candidate 6ba66c0d8f246d438f2e2f3c974fee9f77fdb426 with exact committed-byte verification. Preserve prior 0.15.0 evidence as historical.
- Correct both consumer host fixtures to establish explicit SP authority, and verify unknown/client/guarded-server refusal without changing the dependency or bypassing MULTIPLAYER_STORAGE_UNAVAILABLE.
- Record contaminated launcher/loose-class provenance and distinguish the saved 42.21.0 version marker from current executed-build proof. Native UI/storage, stage-1 review, locomotion and dedicated G7/stable G8 remain unverified/blocked.
- Compatible development checkpoint; public API 1.6.0 and runtime gameplay/schemas unchanged.

## 0.26.0-dev.2 - creator export fixture and offline roadmap, 2026-10-16

- Add a reviewed repository-only creator export with a golden-output regression through real registries: missing trait/behavior providers fail before registration, successful content keeps neutral defaults, and duplicate installation preserves the original.
- Remove obsolete feeding-migration TODOs and prepare current test inputs, creator acceptance and the pre-runtime execution queue.
- Document proposed server sandbox settings, phase boundaries, independent life identity, selection revision/persistence and standalone parity acceptance. Add isolated supplied-roll retention and phase-window experiments; no production options, solar adapter, RNG, world schema or controller is installed.
- Preserve historical dependency fingerprints and add an exact committed-byte inventory plus opt-in validation preflight. The old 0.15.0 record differs only by CRLF in 46 files; reports now separate verified input from passing integration tests.
- Compatible checkpoint within unreleased 0.26.0; public API 1.6.0 remains unchanged. Native creator UI/storage, authority/restoration and dedicated lifecycle remain NOT TESTED; G7 and stable G8 remain BLOCKED.

## 0.26.0-dev.1 - main-menu zombie creator, 2026-10-16

- Add a release-mode main-menu Zombie Creator: identity, movement/durability, appearance and trait/behavior references, local draft management and read-only Lua preview/export.
- Preserve local drafts with alternating checksummed checkpoints, expected revisions, readback and future/corrupt-data refusal. Quote export strings and reject duplicate registered IDs/missing providers at manual installation. No live registration, spawning, network command or world mutation.
- Add three actual-module host regressions and 29 UI catalogs with explicit English fallback. Native menu/controller/file behavior remains NOT TESTED; public API 1.6.0 and existing gameplay gates are unchanged.

## 0.25.0-dev.4 - runtime audit handoff and consumer checkpoint, 2026-10-16

- Prepare the requested exact staged runtime handoff: current dependency review, SP baseline, one-zombie/two-client locomotion proof, release/owner-loss/profile cases, migrated Nightfall feeding and per-case evidence forms.
- Record Nightfall 0.29.1-dev.1 transaction adapter and actual MORTIS host integration as implemented offline; preserve native durability/replication and full restoration gates.
- Documentation/metadata checkpoint only; API 1.6.0, schemas, protocol and gameplay unchanged. No automatic controller, recovery, package, deployment, launch or upload. G7/stable G8 BLOCKED.

## 0.25.0-dev.3 - observed override recovery, 2026-10-16

- Restore all five observed locomotion fields on last-owner/ceiling release and explicit clear; verify requested walk/class instead of treating native method acceptance as success.
- Checkpoint a dedicated internal version-1 baseline component before movement writes, retain failures, and refuse owner re-enrollment after stack loss until coordinated clear. No consumer leases or policy are replayed automatically.
- Refuse busy/unknown native states and missing inverse observations. Preserve priority/ceiling composition and unchanged-request deduplication, including passive ceilings.
- Prevent type-profile reconciliation/clearing from overwriting movement while an override journal owns it; callers must coordinate owner release before retrying profile or assignment changes.
- Add actual-component/persistence regression coverage and update the Active Hours real-stack fixture. Public API remains 1.6.0; native disk/MP/full animation restoration is NOT TESTED. G7/stable G8 remain blocked.

## 0.25.0-dev.2 - feeding hardening and roadmap groundwork, 2026-10-16

- Isolate malformed provider/native coordinates, reject nonfinite priorities and consumption distances, preserve vanilla targeting when observation fails, and skip quarantined providers during discovery. Equal scores resolve deterministically by provider ID.
- Reject nonnumeric/no-effect food quotes, including native rounding that leaves hunger unchanged, before consuming stock. Validate plain quote/candidate fields without invoking lazy getters that could bypass compensation. Preserve verified compensation and pending guards.
- Complete all 37 English sandbox option tooltips (27 additions) and validate JSON/catalog integrity; non-English review and native fallback remain untested.
- Start an offline weighted-range/CDF experiment outside runtime/package inputs; no production controller, settings, RNG or native writes.
- Align current documentation with the retained standalone Active Hours policy from PR #4; MORTIS takes precedence when co-enabled. Public API remains 1.6.0, save schemas unchanged; native G7/stable G8 remain blocked.

## 0.25.0-dev.1 - transactional feeding (M-05), 2026-10-16

- New provider transaction contract, API 1.6.0: reserve a quoted portion, verify provisional hunger/cache state, then commit food removal. Abort invokes idempotent source compensation and restores hunger before returning failure.
- Unsafe consume-only providers remain registered/discoverable but automatic consumption fails closed until migrated; Nightfall effigies require that consumer update. Existing provider implementations are not rewritten here.
- Reject invalid quotes/multipliers and failed hunger advancement; guard callback reentrancy and defer ZombieFed until commit. Rollback failures quarantine the provider/entity instead of silently retrying.
- Save schema and server authority remain unchanged. This is a synchronous Lua callback boundary, not durable cross-resource/crash atomicity; dedicated G7 and stable G8 remain BLOCKED.

## 0.24.0-dev.3 - audit corrections, 2026-10-16

- Documentation clarification 2026-10-16: Active Hours remains maintained standalone while all features are included in MORTIS. When both are enabled, standalone execution is disabled; MORTIS wins. No MORTIS runtime/version/API/save change or upload.

- Compatible corrections within the unreleased 0.24.0 target; public API 1.5.0, saved schemas, provider identities and archived Active Hours bytes are unchanged.
- Replace the exact 0.13.0 dependency test pin with identity/version-presence and behavioral contract checks; actual-source research/history tests now pass against Knowledge & Wisdom 0.14.0. Preserve earlier fingerprints as historical inputs.
- End the diagnostic category comparison after owner release while retaining raw samples; other consumer requests/ceilings must not be mislabeled as native overwrite.
- Reject Set/Release during getting-up, on-floor or busy native states, and when required observations are missing or fail. Consume rejected intents without auto-retry; a new standing intent may proceed.
- Add real-StateAdapter regressions and higher-priority owner composition checks. Offline only; G7 BLOCKED / NOT TESTED and stable G8 BLOCKED.

## 0.24.0-dev.2 - Active Hours absorption, 2026-10-16

- Consolidate Active Hours research, prototype, and future development ownership in MORTIS. Preserve the standalone dev.4 source as a hashed historical snapshot.
- Add an explicitly started, dormant-by-default one-zombie dedicated diagnostic using existing server locomotion overrides; no production solar/profile controller or new public API.
- Remove a second init.lua VERSION assignment that overwrote the current version with legacy 0.23.2; require all declared runtime assignments to match canonical.
- Offline validation only; G2 BLOCKED, G6 NOT TESTED, G7 BLOCKED / NOT TESTED and G8 BLOCKED. No installation, launch or upload.

## 0.24.0-dev.1 - knowledge dependency migration, 2026-10-16

- Pre-1.0 MINOR migration: required Mod ID, imports and harness global now use B47ANCEDKnowledgeAndWisdom. Existing load lists must change; public MORTIS API 1.5.0, research/item/knowledge/evidence IDs and saved-state schemas remain unchanged.
- Migrated the validation runner to --knowledge-and-wisdom and added actual-source archive/history regressions for existing knowledge, registration reload, provider evidence, replay binding, authority rejection and store reload. No legacy public alias is introduced.
- Offline results and exact dependency fingerprints are recorded in docs/DEPENDENCY_MIGRATION.md and docs/VALIDATION.md. PZ runtime and dedicated G7 remain NOT TESTED / BLOCKED; stable G8 BLOCKED.

## 0.23.3-dev.2 - locomotion restoration development, 2026-10-16

- Target: compatible profile baseline capture/restoration fix. Public API and component schema versions remain separate; legacy baselines are not invented.
- Captures an observed movement baseline and checkpoints it before profile writes; restores walk/class/modifier/crawler fields with readback on profile removal/clear, preserving originals across reconciliation and detach callbacks.
- Refuses unavailable/legacy baselines and failed checkpoints; retries pending post-detach restoration through scheduled updates. Internal native animation/lunge bookkeeping remains unverified.
- [TESTED offline] 121 Lua files compile; 51 host cases PASS in unit mode, one dependency integration NOT TESTED. The full integration run is BLOCKED because experienceWorks was renamed to B47ANCEDKnowledgeAndWisdom without old aliases. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.

## 0.23.3-dev.1 - authority and replication development, 2026-10-16

- Target: compatible authority/replication bug fixes, preserving public API 1.5.0 and existing save components. Assignment-clear records are additive; peers must run the same mod build.
- Fixed client hunger writes, missing clear replication, directed-reply dirty acknowledgement, obsolete online-ID indexes, request admission, and revision continuity across wrapper replacement.
- Added persisted clear records, retries, lifecycle cleanup, and client pending-message ordering. All peers must use the same mod build.
- [TESTED offline] 120 source syntax checks and all 49 host cases pass (48 Lua 5.1, one Lua 5.4), including the local experienceWorks integration. CI explicitly excludes that dependency integration. G7 BLOCKED / NOT TESTED and stable G8 BLOCKED.
- Food-provider transaction changes and complete locomotion-baseline restoration remain open; see docs/AUTHORITY_REPLICATION.md.

## 0.23.2 — imported baseline, 2026-10-16

- Established canonical root VERSION from existing authoritative source metadata, runtime constant, README, tester handoff, and matching preserved ZIP.
- Added source/package classification and reproducible offline validation. Existing runtime code is unchanged in this baseline.
- [TESTED offline] Syntax and host regressions only. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. Historical partial experienceWorks runtime evidence is not current validation.

Earlier release notes remain in WORKSHOP_CHANGE_NOTE.txt and existing design documents; importing source does not certify prior releases.
