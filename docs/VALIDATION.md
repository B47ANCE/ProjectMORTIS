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
