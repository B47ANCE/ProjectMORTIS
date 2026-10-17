# Current validation

Current development version: 0.26.0-dev.3

[TESTED: offline] Human-test preparation follow-up on c7aa102cf3c6da0f175890b4fb680b870eda5660.
PR #7 merged during preparation as 7ac2080b0210e7e52051ff91c7c76f7209df46dd;
its tree exactly matches c7aa102. Staged changes were preserved on the latest-main
feature branch feat/human-runtime-test-handoff before this follow-up commit.
No PZ/server launch, native UI action, deployment or real-save write was performed.
The user leaves testing requiring an open game to humans; see HUMAN_RUNTIME_TESTS.md.

Knowledge & Wisdom input: exact public 0.16.0 candidate
6ba66c0d8f246d438f2e2f3c974fee9f77fdb426, extracted with Git archive into an
isolated fixture. Dependency PR #1 merged during preparation as
0f20ad2c070941038e274c72bd91eb4db5b82ed3; the selected test input remains that
exact source head. All 120 source/metadata files pass the new
exact-byte manifest, inventory SHA-256
`83338349470cd8a9f194156dc9baffee29f947173d7e37bf5eb8db5e5e4813e0`.
Prior 0.15.0 fingerprints and results remain historical, not current MP proof.

The first full consumer run failed both dependency integrations with
REALM_UNAVAILABLE. Those fixtures omitted native role functions. They now model
SP explicitly, retain real source/provider/replay/reload checks and assert
unknown/client/guarded-server refusal without writes. The dependency's intentional
MULTIPLAYER_STORAGE_UNAVAILABLE is preserved, not bypassed. No production code
change was needed beyond version mirrors.

[TESTED: offline Windows Python 3.12.14 / Lupa 2.6] MORTIS passes all 63 Lua host
regressions, 26 Active Hours diagnostic cases and four Python verifier cases;
130 runtime Lua files compile; 13 current version mirrors and 87 JSON catalogs
pass, including 37 sandbox options and 29 creator UI fallback catalogs.
In the isolated dependency snapshot, its 34/34 Lua 5.1 regressions, 17 version
mirrors, 58 Lua parses, exact-case imports, 87 fallback catalogs and 38-item source
gate pass. Neither suite opens the game or proves native Kahlua/SP/MP behavior.

Exact commands from MORTIS root with the configured real Python:

```text
python scripts/check_versions.py
python scripts/validate.py --knowledge-and-wisdom ../.mortis-merge-fixtures/knowledge-6ba66c0 --dependency-evidence docs/evidence/knowledge-dependency-6ba66c0-git-bytes.json
python scripts/check_public.py --staged
git diff --cached --check
```

Exact dependency commands, run only in its isolated 6ba66c0 snapshot:

```text
python -B -X utf8 scripts/check_versions.py
python -B -X utf8 scripts/validate_source.py
python -B -X utf8 scripts/run_host_tests.py
```

The engine preflight is read-only, summarized in
`evidence/native-test-preflight-25485521.json`: Steam build 25485521; packaged jar
hash matches the dependency source audit; normal launcher includes a custom Java
agent/external mod JAR and prioritizes loose classes. Selected loose MainScreen
and IsoGameCharacter bytes differ. Existing version.txt says 42.21.0 4a0e9546ec,
but no current executed build or clean vanilla integrity is established.
No game/configuration/mod-set change was attempted. A human must establish a clean
client and isolated profile before native acceptance.

Native creator UI/storage/controller/Unicode, dependency stage-1 review, MORTIS
SP, ownership/animation/lunge restoration, source persistence, save/rejoin/restart
and dedicated locomotion remain NOT TESTED/BLOCKED. Affected Knowledge & Wisdom
MP persistence is implementation-blocked, independently of missing test evidence.
An isolated locomotion observation cannot certify its private storage or research/
history gameplay. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. No package, deployment,
game/server launch, Workshop upload or stable tag.

---

## Historical record - 0.26.0-dev.2 (unchanged original text)

# Current validation

Current development version: 0.26.0-dev.2

[TESTED: offline] Compatible preparation checkpoint on merged main baseline
19a5f1bac7d872008cb591259d12608d4be41e74. Windows bundled Python 3.12.14 / Lupa
2.6: 130 runtime Lua files compile; all 63 host Lua regressions, 26 Active Hours
diagnostic cases and four disposable Python input-verifier cases pass. All 13
version mirrors and 87 JSON catalogs pass, including 37 English sandbox options
and 29 creator UI fallback catalogs. No native PZ process was invoked.

New regressions verify reviewed creator output bytes through real registries and
profile interpretation, missing trait/behavior refusal, neutral registration and
duplicate preservation. The bootstrap is substituted; no native content load or
provider behavior is proved. Isolated Active Hours data experiments cover two
supplied rolls, repeat/module-snapshot retention, revision/life conflicts,
malformed/future records, CDF integration, dawn/dusk boundaries, synthetic short/
long/wrapped windows and explicit endless kinds. They do not supply RNG, actual
storage, networking, solar observations or population execution.

The pinned Knowledge & Wisdom input is 0.15.0 at exact committed source
ca5b724c63d49ab224f96b2daea3e17ad7498e44. All 118 source/metadata files were
compared to Git blobs and the isolated snapshot; the full command verifies the
new evidence manifest before integrations. Inventory SHA-256:
`c036b4d85f0667942b8d7b78ae6abbbf16428c3979e8068e1a151ebfa0bb820e`.
The earlier 0.15.0 manifest remains historical: 72 identical files and 46 CRLF-only
differences from the committed LF input, with no semantic difference found.
No dependency checkout was modified. The runner records verified input separately
from passing tests; omitting the optional evidence flag records false.

The negative CLI check with the historical manifest
(`python scripts/validate.py --knowledge-and-wisdom ../.mortis-merge-fixtures/knowledge-ca5b724 --dependency-evidence docs/evidence/knowledge-dependency-0.15.0.json`)
refuses its unsupported old format with exit 1. It replaces the prior result
with explicit failed preflight, zero syntax files and unverified input; a stale
PASS is not left behind. The full exact-input command was then rerun successfully.

Commands from this root with the configured real Python (not the Store alias):

```text
python scripts/check_versions.py
python scripts/validate.py --test test_creator_export_fixture
python scripts/validate.py --test test_active_hours_life_design
python scripts/validate.py --test test_active_hours_phase_design
python -B -m unittest discover -s tests -p test_dependency_input.py
python scripts/validate.py --knowledge-and-wisdom ../.mortis-merge-fixtures/knowledge-ca5b724 --dependency-evidence docs/evidence/knowledge-dependency-ca5b724-git-bytes.json
python scripts/check_public.py --staged
git diff --cached --check
```

CI retains --unit-only and omits the two dependency integrations. Disposable
verifier tests reject changed line endings, missing/extra source, unsafe paths,
unsupported/corrupt/duplicate-key manifests. The actual fixture absolute path is
local and not a portable dependency location; recreate the selected input at
that commit, or substitute its root argument. Historical evidence is preserved.

Runtime-source diff from baseline is exactly the three version mirrors; fixtures,
experiments and proposed settings remain outside runtime roots. Native creator
menu/focus/controller/file durability/Unicode, full locomotion restoration and
simulation ownership, solar/life-identity/consumer recovery contracts, feeding,
Linux, save/rejoin/restart and dedicated evidence remain open. Existing assignment
IDs can be cleared/regenerated and are not proven per-life tokens. See the
updated RUNTIME_AUDIT_HANDOFF.md and ACTIVE_HOURS_DESIGN.md. G7 BLOCKED / NOT TESTED;
stable G8 BLOCKED; production Active Hours G2/G6 unchanged. No package, deployment,
game/server launch, upload or stable tag.

---

## Historical record - 0.26.0-dev.1 (unchanged original text)

# Current validation

Current development version: 0.26.0-dev.1

[TESTED: offline] Main-menu creator development MINOR on main a3238a31f909cec63aeb12c7b7666562c94e34fe. Windows bundled Python 3.12.14 / Lupa 2.6: 130 runtime Lua files compile, all 60 host cases pass plus 26 Active Hours cases. Unit mode passes 58 host cases plus those diagnostics and explicitly omits two dependency integrations. Current 13 version mirrors and 87 JSON catalogs pass; all 29 creator UI catalogs have fallback key parity. No native PZ runtime was invoked.

The three new regressions use actual creator modules. They cover bounded pure-data parsing, malformed/future/unknown fields, invalid/infinite/injected values, quoted/generated Lua through actual Types/Profile APIs, duplicate/provider refusal, exclusive fixed file names, alternating checkpoint fallback, stale/corrupt/future records, write/readback failures, export preservation, release-mode menu registration, existing UI delegation, controller entry, save/export/discard/delete flow and bounded small-viewport layout. Modeled widgets/files are not native UI/storage evidence.

Commands from this root (use the configured real Python, not the Windows Store alias):

```text
python scripts/check_versions.py
python scripts/validate.py --test test_creator_model
python scripts/validate.py --test test_creator_store
python scripts/validate.py --test test_creator_ui
python scripts/validate.py --knowledge-and-wisdom <clean fixture at ca5b724c63d49ab224f96b2daea3e17ad7498e44>
python scripts/validate.py --unit-only
python scripts/check_public.py --staged
git diff --cached --check
```

The full dependency input is the previously recorded clean 0.15.0 Knowledge & Wisdom commit ca5b724c63d49ab224f96b2daea3e17ad7498e44, extracted from that exact Git commit into an isolated read-only test fixture; no dirty live sibling input is used. Existing evidence fingerprints remain valid for that snapshot. Installed vanilla source observations are tied to Steam build 25485521 in evidence/creator-ui-25485521.json; full executed version remains UNKNOWN. Source/editor behavior does not prove native file durability, Unicode, focus, load order or menu visibility.

The creator has no gameplay writer, network endpoint, spawn policy, registered custom type, 3D renderer, world persistence or automatic export activation. See ZOMBIE_CREATOR.md for ownership/format/limits and exact native acceptance. Overall G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. No package, deployment, game/server launch, upload, stable tag or main merge.

---

## Historical record - 0.25.0-dev.4

# Current validation

Current development version: 0.25.0-dev.4

Documentation/metadata checkpoint on clean baseline 2f9b03a376aaecc751e6c10ffcf399916f444400, fix/locomotion-override-recovery, matching upstream and ahead 3/behind 0 of origin/main. The requested [runtime audit handoff](RUNTIME_AUDIT_HANDOFF.md) is prepared. API 1.6.0, schemas, protocol and gameplay are unchanged. The previous source correction and results are preserved below as historical evidence.

[TESTED: offline] Current full command: `python scripts/validate.py --knowledge-and-wisdom '../B47ANCEDKnowledgeAndWisdom'`; environment Windows, bundled Python 3.12.14/Lupa 2.6. PASS: 125 runtime Lua files compile, 57/57 host cases pass and 26/26 Active Hours cases pass. Catalog integrity passes for 58 JSON files and all 37 English option names/tooltips. `python scripts/check_versions.py` checks 13 current mirrors. No host check proves PZ Kahlua or dedicated behavior.

Nightfall 0.29.1-dev.1, commit 9a681a1f62df87a7eccf946b9796cee92ff8a798, [consumer PR #2](https://github.com/B47ANCE/ProjectNightfall/pull/2), implements the real consumer migration with actual MORTIS coordinator/model/event-bus integration and mocked native boundaries: all 63 Lua and 19 Python tests pass. Its dependency snapshot identifies MORTIS 0.25.0-dev.3 at the exact baseline above and Knowledge & Wisdom 0.15.0 at ca5b724c63d49ab224f96b2daea3e17ad7498e44. Spectrum has unrelated local changes; the recorded source-tree hash identifies that input, not its commit alone. No sibling source except the authorized Nightfall adapter was changed.

Pre-push checks: `python scripts/check_public.py --staged` and `git diff --cached --check`. Protected takeover-ledger comparison PASS: Contents 128, dist 8811, compatibility-template 2 and examples 6 files are byte-identical. The runtime/source diff is exactly three declared version mirrors, with no gameplay changes. The new handoff records prerequisites, exact existing command/hotkey surfaces, native observation/fault-injection blockers and per-case result forms. No new runtime test harness, writer or recovery policy is introduced.

[RUNTIME GATE] Current dependency stage-1 review, native ownership/observer/animation/restoration, source persistence/replication, save/rejoin/restart, non-English fluency/fallback and Linux execution remain unverified. Production Active Hours G2 BLOCKED, G6 NOT TESTED, G7 BLOCKED / NOT TESTED and stable G8 BLOCKED. No package, deployment, publication, game/server launch, stable tag or main merge.

---

## Historical record - 0.25.0-dev.3 (unchanged original text)

# Current validation

Current development version: 0.25.0-dev.3

[TESTED offline] Windows bundled Python / Lupa 2.6: 125 runtime Lua files compile; all 57 host cases pass (56 Lua 5.1, one Lua 5.4) plus all 26 Active Hours diagnostic cases. Unit mode passes 55 host cases and explicitly omits two dependency integrations. All 26 diagnostics additionally pass under Lua 5.4, as do the actual-service override recovery and profile restoration cases. These results are host/native mocks, not PZ execution.

The new regression reproduced missing pre-write checkpoints on the audit baseline. Separate cases reproduced profile overwrite and forced-busy bypass before those corrections. Coverage includes five-field restoration/readback, priorities/ceilings, passive leases, unchanged-request deduplication, failed serialization/deletion, ignored/partially throwing setters, unavailable/busy state, preserved unrelated components, client refusal, corrupt/newer records, and saved component/wrapper/module replacement. Consumer leases are not persisted or inferred; recovery requires explicit coordination.

Actual-source dependency input: Knowledge & Wisdom 0.15.0, clean public commit `ca5b724c63d49ab224f96b2daea3e17ad7498e44`, 118 files pinned in `evidence/knowledge-dependency-0.15.0.json`. Earlier fingerprints remain historical. Installed Steam build remains 25485521; selected JAR/packaged/loose class bytes match the prior observation evidence, API helper SOURCE_HASH_MATCH / runtime NOT_TESTED. Full executed game version remains UNKNOWN.

Commands from this root with the bundled interpreter `C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe`:

```powershell
python scripts/check_versions.py
python scripts/validate.py --test test_locomotion_override_recovery
python scripts/validate.py --test test_locomotion_profile_restore
python scripts/validate.py --knowledge-and-wisdom '../B47ANCEDKnowledgeAndWisdom'
python scripts/validate.py --unit-only
$env:B47_PROOF_LUA='54'
python scripts/test_active_hours.py
Remove-Item Env:B47_PROOF_LUA
python scripts/check_public.py --staged
git diff --cached --check
```

The two additional Lua 5.4 cases explicitly execute their test files with current shared/client/server package paths. Catalog checks validate 58 JSON files and English names/tooltips for all 37 sandbox options; non-English fluency/native fallback remain unverified. The 13 current version mirrors pass. Archive/source boundary and protected-artifact SHA-256 checks are recorded with this iteration; none was packaged or deployed. Baseline audit input: clean branch fix/transactional-feeding, commit b3cd73f43526d1399bb6c4810b461cb3b774ef84, ahead 0 / behind 0 of its upstream and ahead 2 / behind 0 of origin/main. This feature branch is stacked on that pending work, not a main merge. Source, offline and native evidence remain separate.

The source correction adds internal Mortis.LocomotionOverrideBaseline version 1, preserving public API 1.6.0, existing component schemas and replication protocol. It does not persist/replay consumer policy or certify native disk durability. See LOCOMOTION_OVERRIDES.md and AUDIT_2026-10-16.md for scope and open gates. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED; Active Hours G2/G6 unchanged.

---

## Historical record — 0.25.0-dev.2 (unchanged original text)

# Current validation

Current development version: 0.25.0-dev.2

[TESTED offline] Windows bundled Python / Lupa 2.6: 124 runtime Lua files compile; all 56 host cases pass (55 Lua 5.1, one Lua 5.4), plus all 26 Active Hours diagnostic cases. Unit mode passes 54 host cases plus those diagnostics and explicitly omits two dependency integrations. Food discovery, transaction and weighted-design cases additionally pass under Lua 5.4. New discovery and transaction edge-case regressions failed on dev.1 before their fixes. An additional malformed lazy-quote regression reproduced an exception after reservation before raw-field validation was added; it now verifies compensation. The catalog check found 27 missing tooltips before additions and now passes: 58 JSON catalogs, English page/name/tooltip coverage for all 37 sandbox options. No native PZ runtime evidence was produced.

Full integration input: Knowledge & Wisdom 0.14.1, clean commit `a8ba91c8454a0a4cac937392d227e1ba1aebcaa3`, matching its public branch; 114 inputs are pinned in `evidence/knowledge-dependency-0.14.1.json`. The earlier 0.14.0 and 0.13.0 records remain historical.

Commands from this root, using `C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe` in place of the Store alias:

```powershell
python scripts/check_versions.py
python scripts/check_localization.py
python scripts/validate.py --test test_food_source_discovery
python scripts/validate.py --test test_food_source_transactions
python scripts/validate.py --test test_active_hours_weighted_design
python scripts/validate.py --knowledge-and-wisdom '../B47ANCEDKnowledgeAndWisdom'
python scripts/validate.py --unit-only
python scripts/check_public.py --staged
git diff --cached --check
```

The three additional Lua 5.4 checks explicitly execute their test files with the same shared/client/server package paths. SHA-256 verification matches all 64 imported archive files and the exact archive inventory. A read-only comparison against the retained local takeover ledger matches Contents (128), dist (8811), compatibility-template (2) and examples (6) files. The 506 literal MORTIS requires resolve against the actual case-sensitive source inventory; no Java/JAR exists in source. Static case checks are not Linux runtime proof. All 13 current version mirrors pass.

This checkpoint preserves API 1.6.0, replication protocol and saved component schemas. It aligns current scope with the standalone-retention policy documented in PR #4 without merging either PR. The 64-file archive and existing distribution artifacts remain historical. No runtime controller, gameplay settings, package, deployment, publication or game/server launch is introduced.

G7 BLOCKED / NOT TESTED; stable G8 BLOCKED; Active Hours G2/G6 gates unchanged. Nightfall provider migration, native compensation/durability and complete locomotion/override restoration remain open. Non-English fluency and native fallback are unverified.

---

## Historical record — 0.25.0-dev.1 (unchanged original text)

# Current validation

Current development version: 0.25.0-dev.1

[TESTED offline] Windows bundled Python / Lupa 2.6. Full mode compiles 124 runtime Lua files and passes 54 Lua host cases (53 Lua 5.1, one Lua 5.4), plus the 26-case Active Hours suite under Lua 5.1. Unit mode omits two dependency integrations; native PZ/SP/dedicated behavior remains NOT TESTED. Public API is now 1.6.0; replication and saved schemas are unchanged.

Exact commands from the MORTIS root:

```powershell
python scripts/check_versions.py
python scripts/validate.py --test test_food_source_transactions
python scripts/validate.py --knowledge-and-wisdom '../B47ANCEDKnowledgeAndWisdom'
python scripts/validate.py --unit-only
python scripts/check_public.py --staged
git diff --cached --check
```

The exact interpreter remains `C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe`. Bare python is the Store alias. CI runs unit mode; its two omitted dependency integrations are not passing integration proof. Full local mode includes actual Knowledge & Wisdom source, separately from mocked native boundaries.

M-05: actual FoodSources registration, FaultIsolation and Hunger runtime are exercised by the new regression. It covers ignored/partially throwing native setters; failed advancement before source callbacks; reserve/commit exceptions and partial source changes; invalid values/zero multiplier; component failure before/after writes; dispatcher failure; direct rollback despite circuit-breaker disablement; client/target preservation; recursive mutator rejection; two-zombie source contention; post-commit observer isolation; unsafe legacy callback refusal; native/source compensation failure and quarantine. The test failed before the fix. See FOOD_TRANSACTIONS.md for exact callback ownership, ordering, contract restrictions and runtime cases.

All 13 current project mirrors pass. Legacy consume-only providers remain registered/discoverable but automatic consumption returns a migration requirement without calling them. Nightfall effigies are the known concrete consumer requiring a separate provider change; no consumer source was edited. No source rollback guarantee is manufactured for a nonconforming provider, irreversible external effects, permanent setter failure or process crash. Transient guards/quarantine are not a durable cross-resource journal.

The 64-file Active Hours archive and prior MORTIS packages/evidence retain their original bytes and versions. No package was generated. G7 BLOCKED / NOT TESTED and stable G8 BLOCKED; Active Hours G2/G6 gates are unchanged. Verify migrated real-provider stock/tissue/claim and hunger conservation, observer state, native save/load, competing access, late join/rejoin and dedicated restart before runtime claims. No merge, deployment, publication or game/server launch is part of this iteration.

---

## Historical record — 0.24.0-dev.3 (unchanged original text)

# Current validation

Current development version: 0.24.0-dev.3

Documentation-only relationship correction (2026-10-16): Active Hours remains maintained standalone and disables its own execution when ProjectMORTIS is enabled. MORTIS includes the same feature scope. No MORTIS runtime/API/schema/version or archived import bytes change; no new runtime result is claimed. Version/whitespace/public-file checks apply to this follow-up; prior test records retain their actual versions. G2/G6/G7/G8 are unchanged.

[TESTED offline] Windows, bundled Python 3.12.14 / Lupa 2.6. Full mode compiles 124 runtime Lua files and passes all 53 Lua host cases (52 Lua 5.1; one Lua 5.4), plus the 26-case Active Hours Python/Lua 5.1 suite. The diagnostic separately passes 26 cases under Lua 5.4. Unit-only mode passes 51 Lua cases plus that diagnostic suite and explicitly omits two actual-source integrations. CI uses unit mode; its results are not current dependency integration or native dedicated proof.

Exact commands from the MORTIS root:

```powershell
python scripts/check_versions.py
python scripts/validate.py --knowledge-and-wisdom '../B47ANCEDKnowledgeAndWisdom'
python scripts/validate.py --unit-only
$env:B47_PROOF_LUA='54'
python scripts/test_active_hours.py
Remove-Item Env:B47_PROOF_LUA
python scripts/check_public.py --staged
git diff --cached --check
```

The verified interpreter is `C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe`; bare python reaches the Store alias. The full integration selects Knowledge & Wisdom 0.14.0, commit `45cd856adeef45811d2c79b919494fd6f4754d29`, with clean source and matching public feature-branch SHA. `evidence/knowledge-dependency-0.14.0.json` binds the exact tested source/metadata. The prior 0.13.0 fingerprint is historical, not current proof. No dependency files are changed.

The three audit findings are corrected:

- The exact 0.13.0 assertion failed on actual 0.14.0 before correction. Identity, nonempty version provenance and real research/persistence behavior are now checked without an arbitrary exact-version pin; both actual-source integrations pass.
- Successful diagnostic release clears only this owner's expected category. Raw fields/results/baseline remain available; a surviving higher-priority consumer or ceiling is not automatically counted as a native mismatch. Active diagnostic requests still observe mismatches without automatic repairs. A real owner-stack regression previously counted two false mismatches, and now counts zero while preserving the other owner's tier.
- Both Set and Release refuse on-floor/getting-up and recognized busy states or unavailable observations. Tests use the real StateAdapter under native mocks, covering nil/missing/throwing getters, attack/climb/fall/get-up, consumed rejected intents and a fresh standing intent. New guards register no work until explicit diagnostic start. Before implementation these regressions accepted two forbidden API calls per state case. The real Compatibility API also verifies required State surface negotiation.

All 13 current version mirrors pass. Public API 1.5.0, replication protocol 2 and saved schemas/content IDs are unchanged. The immutable 64-file Active Hours import and original MORTIS historical artifacts remain protected; no current package is generated. G2 BLOCKED (production Active Hours), G6 NOT TESTED, G7 BLOCKED / NOT TESTED and stable G8 BLOCKED. No game/server launch, deployment, publication or PR merge. Native API availability, state classification, owner/observer behavior, full restoration, streaming/reconnect/restart and population performance require actual human runtime evidence.

---

## Historical record — 0.24.0-dev.2 (unchanged original text)

# Current validation

Current development version: 0.24.0-dev.2

[TESTED offline] 2026-10-16, Windows, bundled Python 3.12.14 / Lupa 2.6. Full validation compiles 124 current runtime Lua files and passes all 53 existing Lua host cases (52 Lua 5.1, one Lua 5.4) plus the new 22-case Python/Lua 5.1 diagnostic suite. Full mode includes both actual-source B47ANCEDKnowledgeAndWisdom research/history integrations. The diagnostic separately passes all 22 cases in Lua 5.4. The imported snapshot's 64 exact files match every pinned SHA-256. Kahlua/native PZ/SP/dedicated execution remains NOT TESTED.

Exact commands, from the MORTIS root:

```powershell
python scripts/check_versions.py
python scripts/test_active_hours.py
$env:B47_PROOF_LUA='54'
python scripts/test_active_hours.py
Remove-Item Env:B47_PROOF_LUA
python scripts/validate.py --knowledge-and-wisdom '../B47ANCEDKnowledgeAndWisdom'
python scripts/validate.py --unit-only
python scripts/check_public.py --staged
git diff --cached --check
```

The exact local interpreter is `C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe`; bare python reaches the Windows Store alias. Unit-only mode explicitly excludes the two dependency integrations; it is not full integration proof. CI uses that mode. The runner writes ignored `validation-results.json`; source evidence and current results are recorded here without private logs.

The active source now contains one canonical runtime VERSION assignment, replacing a later legacy 0.23.2 overwrite. The checker validates every runtime assignment while preserving historical changelog/note entries. A temporary-fixture regression proves a valid first assignment followed by a stale one fails. All 13 current mirrors pass; the frozen Active Hours archive has its own historical version and is excluded. No current package was built; stable `--release` remains blocked by the development prerelease and absent current package.

The transferred diagnostic is dormant until a human explicitly starts it, registers once, rejects old namespaces and loaded standalone diagnostics, retains admin/session/revision validation, calls existing MORTIS locomotion only on the server and never continuously repairs native mismatches. Real MORTIS owner-stack/adapter/authority composition is tested against native mocks, including another higher-priority consumer and release without scalar restoration. These tests do not demonstrate native simulation-owner safety, engine propagation, actual sprinting/animation or faithful release.

G2 BLOCKED (production Active Hours architecture), G6 NOT TESTED, G7 BLOCKED / NOT TESTED, G8 BLOCKED. The dependency stage-1 human review, full executed Build 42.21, a verified dedicated-host Lua activation surface, native locomotion/ownership/observer/restoration, streaming/reconnect/restart and population performance remain gates. Absorption does not bypass other MORTIS blockers. No install, game/server launch, package, upload, main merge or runtime gate change occurred. See ACTIVE_HOURS.md for transferred scope and the human procedure.

---

## Historical record — 0.24.0-dev.1 (unchanged original text)

# Current validation

Current development version: 0.24.0-dev.1

Environment: Windows offline Lupa 2.6; Lua 5.1 for runtime source and most host cases, Lua 5.4 only for the existing package.searchpath-based exclusion test. PZ/Kahlua/native transport is NOT TESTED. Steam manifest build 25485521 and read-only native metadata are installation/source evidence; full executed game version remains UNKNOWN.

Commands from the repository root:

```powershell
python scripts/check_versions.py
python scripts/validate.py --knowledge-and-wisdom '../B47ANCEDKnowledgeAndWisdom'
python scripts/validate.py --unit-only
python scripts/validate.py
python scripts/check_public.py --staged
git diff --cached --check
```

The exact verified interpreter here is `C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe`; bare python reaches the Store alias. Development requirements remain in scripts/requirements.txt.

[TESTED offline] All 121 runtime Lua files compile. Full mode with the explicitly selected B47ANCEDKnowledgeAndWisdom 0.13.0 source passes all 53 cases (52 Lua 5.1 and one Lua 5.4), exit 0. Both actual-source integrations pass: research prerequisites/grants/item lookup/distribution, retained synthetic knowledge and registration reload; history provider evidence, authenticated replay and conflict rejection, authority rejection and saved-store reload. The history test failed before the import fix with `experienceWorks/HistoryRecords` not found. See DEPENDENCY_MIGRATION.md and its source fingerprint record.

[TESTED offline] Unit mode passes 51 cases and explicitly marks both actual-source dependency integrations NOT TESTED, exit 0. Omitting the dependency selection in full mode passes those 51 cases but reports two integrations BLOCKED, exit 1, as intended. The runner does not silently fetch or redirect source. CI uses unit mode with pinned actions, read-only permissions and no retained checkout credential; CI does not certify the local dependency input or native Linux dedicated behavior.

Existing locomotion coverage includes pre-write baseline checkpoints, readback/ignored setters, malformed/unavailable observations, authority, component-table reload, retained originals through detach, failure retries, native busy deferral, legacy rejection, canonical clear failure and scheduled recovery. Host mocks do not certify native invocation or full animation/lunge restoration.

Historical 0.23.3-dev.2 compiled 121 files and passed 51 unit cases, with its full dependency integration BLOCKED by the rename. Historical 0.23.3-dev.1 compiled 120 files and passed 49 host cases against the then-present experienceWorks source. These results retain their original version/environment; neither is current runtime proof.

Canonical versions pass all 13 current mirrors. `python scripts/check_versions.py --release` remains expected FAIL: development prerelease, no current package. Historical ZIP/Contents are preserved. Staged whitespace and bounded public-file secret/artifact checks are required before push.

G7 BLOCKED / NOT TESTED. Stable G8 BLOCKED. No current human SP/hosted/dedicated proof exists. The renamed dependency itself has no Git metadata/public remote; local source hashes are not a GitHub backup. Native mod-list migration, physical research reading, old-save loading, history evidence/privacy/replay, reconnect and restart require disposable runtime fixtures after dependency stage-1 review. Unobserved animation/lunge bookkeeping, external consumer override-stack persistence, food transactions and translations remain open. No main merge, stable tag, packaging, deployment, publication or game/server launch is part of this iteration.
