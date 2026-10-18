# Current validation

Current development version: 0.26.0-dev.7

Artwork-only source checkpoint based on merged PR #12 / 436f8c0.
The user-supplied 1254x1254 PNG is preserved byte for byte in assets/branding/;
preview.png and src/ProjectMORTIS/thumbnail.png are the same 512x512 PNG export.
The small icon is unchanged. Visual review confirms the complete composition is
retained without cropping/redrawing. PNG decode, dimensions, export/source hashes,
preview size and version/overview/input consistency are checked offline.

[TESTED - offline Windows CPython 3.12 / Lupa 2.6] Full host validation PASS:
66 Lua test files, 32 Python cases, 26 diagnostic cases, 130 runtime Lua syntax
checks, 15 version mirrors and 87 catalogs. The selected 120-file Knowledge
input is verified. Both 512x512 exports are 431,429 bytes and identical; the
original hash matches the supplied attachment. No new tests mirror this simple
asset replacement; existing checks and direct image inspection cover the change.

Runtime code differences are version mirrors only; API 1.6.0 and runtime/save/
network schemas are unchanged. No new package, deployment or Workshop upload.
Native menu/thumbnail display remains HUMAN / NOT TESTED. Existing gameplay G7
BLOCKED / NOT TESTED; stable G8 BLOCKED. Prior publication and test evidence
below retains its original version/environment and is historical.

Commands: python -B scripts/check_versions.py; python -B scripts/check_overview.py;
python -B scripts/validate.py --knowledge-and-wisdom ../.mortis-merge-fixtures/knowledge-6ba66c0 --dependency-evidence docs/evidence/knowledge-dependency-6ba66c0-git-bytes.json.
PNG structure/hash/dimension and image-export inspection uses standard offline
byte checks and Windows System.Drawing, with results in assets/branding/README.md.

---

## Historical dev.6 validation and publication (unchanged)

# Current validation

Current development version: 0.26.0-dev.6

## Publication preparation for dev.6

[VERIFIED - distribution only] Source e96b56ee50ad6aae46d10d98cc8662f5a34fb215
was uploaded to existing item 3788592827: SteamCMD exit 0 plus committed-update
success marker. Public API result 1, App ID 108600, public visibility and exact
canonical description were verified afterward. Both CI jobs passed for push
and PR before upload. The user declined restart; Steam stayed unchanged.
Package SHA-256 is `626a9e8762c26fe3b64d9285f1b2c0f82b2772ef0bf02e8920812bb493703d76`.
See publications/0.26.0-dev.6-workshop-3788592827.json for hashes/provenance.
No subscription/download, game/server or native acceptance result is implied.

The explicit publish request authorizes a labelled test distribution, not stable
G8. Runtime source/input remains identical to merged d5cfb21; changes are authoring
metadata, offline packaging/checking and documentation. Four disposable ZIP/VDF
regressions verify source/inventory/CRC, duplicate/case/path rejection, MP-test
text and existing-item/visibility preservation. The full local host suite now
includes 32 Python tests; other host counts below are unchanged. Exact commands:

```text
python -B -m unittest discover -s tests -p test_workshop_package.py
python -B scripts/prepare_workshop.py --output dist/workshop-mp-test/<selected-version-commit>
python -B scripts/prepare_workshop.py --output dist/workshop-mp-test/<selected-version-commit> --verify
```

Source/staging/ZIP hashes, safe paths, unique case, CRC, Lua-only payload and
current version are required for this test distribution. Stable `--release`
still rejects the prerelease; no stable PASS is claimed. The anonymous Steam
metadata API returns result 9 for 3788592827; the user reconfirmed that exact URL.
Title/visibility/tags are omitted from the VDF, and the existing ID is fixed.
Package creation grants no upload or native proof; record SteamCMD's actual
result separately. All runtime tests remain human-operated.

[TESTED - offline Windows CPython 3.12.14 / Lupa 2.6, 2026-10-17]
Based on merged PR #10, 21051190c36b187cc6f594df4ecbfd99fd426845.
Final Git identity and CI results belong to this iteration PR. Runtime source
diff is exactly three version mirrors; API 1.6.0 and runtime/save/network schemas
are unchanged. No game, server, native UI or real save was opened or changed.

Full host suite PASS: 66 Lua test files, 28 Python tests, 26 Active Hours diagnostic
cases, 130 runtime Lua compilations, 15 version mirrors and 87 JSON catalogs.
Both real-source Knowledge integrations verify the pinned 120-file input first.
All three exact-input Nightfall regressions PASS against this candidate, the
159-file Nightfall 5690021 and Knowledge 6ba66c0 inputs. Native methods remain
modeled; no full family bootstrap or native behavior is certified.

CI now has a separate integration job: immutable first-party source checkouts,
exact manifests, full MORTIS host suite and selected Nightfall regressions.
Read-only token/actions, no secrets/deploy/game; source identities recorded in
job logs/summary. Unit-only stays separate. Actual remote outcomes are recorded
on the PR; workflow presence is not a check PASS or branch-protection change.

The first Linux integration run correctly rejected the older Nightfall fixture:
153/159 selected files used CRLF despite its Git-byte label. All selected content
matches committed blobs after newline normalization. Historical input/results
remain unchanged; current checks use the new true-Git manifest and continue to
reject newline drift. Current Nightfall inventory is
`83db444c78e73fbd1db882991c80d858c18bb79f2a62ed99d39476217b5af8d4`.

Human-result validator regressions cover every suite/status, missing/duplicate/
unknown/future records, wrong commits/versions/hashes, missing evidence/baseline/
roles, dependency MP contradictions, suite mod lists, private references,
duplicate/oversized/nonfinite JSON and redacted CLI error/incomplete exits.
VALID means structural coverage only; all gates stay blocked pending human review.

Ownership regressions reproduced AH-CR01 (uncheckpointed acknowledgement/retry)
and AH-CR02 (dispatch consumed the last sequence) before correction and PASS now.
Crash cutpoints retain issued/uncertain records and refuse every modeled new-
session transition; no replay/reset/CAS/storage adapter is installed. Record 1
remains experimental. See ACTIVE_HOURS_API_AUDIT.md and OWNERSHIP model guidance.

[VERIFIED - installed source/member metadata, NOT runtime]
Steam build 25485521 and packaged jar hash match the recorded baseline. Seasonal
Lua callers are identified; headless/seasonal behavior, durable life identity,
corpse continuity and disk/native atomicity remain UNKNOWN/RUNTIME GATE.
Additional differing loose GameTime/IsoZombie/IsoObject hashes are recorded in
active-hours-api-25485521.json. No engine/launcher file was altered.

[TESTED - read-only input preflight] Exact MORTIS/Knowledge/Nightfall inputs,
overview and packaged engine/build checks PASS. Overall BLOCKED as expected:
Knowledge's intentional MP guard, launcher overrides and two selected loose-class
mismatches; the separate API audit expands the differing-class inventory. Other
family installations remain NOT CHECKED. No bypass or runtime claim.

Current MORTIS input: 224 files, inventory SHA-256
`0a3545ffe6979dea7355a550b5df83657d6cc25815c29abc6182231091f3d7f8`.

Exact commands (configured Python; pinned scripts/requirements.txt):

```text
python -B scripts/check_versions.py
python -B scripts/check_overview.py
python -B scripts/validate.py --knowledge-and-wisdom ../.mortis-merge-fixtures/knowledge-6ba66c0 --dependency-evidence docs/evidence/knowledge-dependency-6ba66c0-git-bytes.json
python -B scripts/check_nightfall_integration.py --knowledge-and-wisdom ../.mortis-merge-fixtures/knowledge-6ba66c0 --nightfall ../.mortis-merge-fixtures/nightfall-5690021-git-lf
python -B scripts/audit_active_hours_api.py --game-root <verified-local-game-root> --steam-manifest <verified-appmanifest_108600.acf>
python -B scripts/preflight_runtime.py --knowledge-and-wisdom ../.mortis-merge-fixtures/knowledge-6ba66c0 --nightfall ../.mortis-merge-fixtures/nightfall-5690021-git-lf --game-root <verified-local-game-root> --steam-manifest <verified-appmanifest_108600.acf>
python -B scripts/check_public.py --staged
git diff --cached --check
```

All native tests remain HUMAN / NOT TESTED. Clean-client baseline, dependency
stage-1 review, creator UI/storage, server solar/life/storage and locomotion
owner/observer/restoration, join/reconnect/restart remain open. Production Active
Hours and affected Knowledge MP storage remain blocked. G7 BLOCKED / NOT TESTED;
stable G8 BLOCKED. No package, deploy, upload, game/server launch or stable tag.

---

## Historical dev.5 evidence (unchanged)

# Current validation

Current development version: 0.26.0-dev.5

[TESTED — offline Windows CPython 3.12.14 / Lupa 2.6, 2026-10-17]
Based on merged MORTIS PR #9, f4ca76c99122f9d652325c5cda49bc14cfc2c02a.
Final Git identity/CI results belong to the iteration PR. Runtime source differs
only in three version mirrors; API 1.6.0 and world/creator/network schemas are
unchanged. The ownership reducer and all new tooling stay outside runtime roots.

Full local validation PASS: 65 Lua host files, 26 Active Hours diagnostic cases,
19 Python cases, 130 runtime Lua compilations, 15 version mirrors and 87 JSON
catalogs. The 120-file exact Knowledge input is verified before both actual-source
consumer integrations. Unit-only CI excludes those two integrations; it does not
run the separate optional Nightfall checker. Non-English fluency/native fallback
and all native test cases remain unverified.

[TESTED — combined host regression] All three selected Nightfall regression files
PASS against both frozen merged MORTIS dev.4 and this dev.5 input, with real
MORTIS/Knowledge modules, modeled native methods and identified production UV
fragments. The full UV bootstrap and other family providers are not certified.
Merged source closure is NF-M01–NF-M04 SOURCE FIXED / OFFLINE PASS; native consumer
acceptance remains open. The original failing 0.30.0 audit is retained as history.
See NIGHTFALL_INTEGRATION_CLOSURE.md and its portable merged-input report.

Current MORTIS runtime/authoring inventory: 224 files, SHA-256
`eb6511e3471e89796ad0c5973ba99bd0c28186abea302fe34d7e490532bb8601`.
Frozen Nightfall 0.30.1-dev.1 / 5690021f6d6f5b87ba86e8c9964c527de6d168aa:
159 source/selected-test inputs, inventory
`13d990e03efee25eb52e750698f0f2a290a283f62a920fffdd44c0d878a62181`.
Knowledge remains 0.16.0 / 6ba66c0d8f246d438f2e2f3c974fee9f77fdb426.
The reviewed overview digest/schema matches the installed shared hub algorithm.
Different historical Contents layouts safely require review; no copy is rebuilt.

[TESTED — pure ownership model] Pending targets, release-before-acquire,
checkpoint declarations, safe cancellation, fresh-token explicit retry, stale/
duplicate/wrong-context receipts, uncertain-result freeze/reload, life/session
refusal, queued/reverted/skipped selection revisions, invalid/future records and
detached inputs pass. Review caught a queued-selection reversion validity defect;
the new regression failed before its correction and passes now. The model uses
caller-supplied context/receipt declarations and implements no actual checkpoint,
CAS, lifetime identity, native adapter, storage, transport or population policy.

[TESTED — read-only local preflight] MORTIS/Knowledge/Nightfall exact inputs,
reviewed contracts and overview PASS. Other Nightfall family installations are
NOT CHECKED. Optional engine file inspection still returns BLOCKED (exit 2):
custom launcher/classpath and two differing loose classes; packaged engine hash
and explicit Steam build 25485521 match the selected baseline. The intentional
Knowledge MP-storage implementation block remains. No clean effective next launch
or runtime PASS is inferred. Malformed/changed/unsupported inputs refuse with
redacted errors; native class data is inspected as bytes, never executed.

Exact commands from MORTIS root using the configured Python and pinned requirements:

```text
python -B scripts/check_versions.py
python -B scripts/check_overview.py
python -B scripts/validate.py --knowledge-and-wisdom ../.mortis-merge-fixtures/knowledge-6ba66c0 --dependency-evidence docs/evidence/knowledge-dependency-6ba66c0-git-bytes.json
python -B scripts/check_nightfall_integration.py --mortis ../.mortis-merge-fixtures/mortis-f4ca76c --mortis-evidence docs/evidence/mortis-f4ca76c-runtime.json --knowledge-and-wisdom ../.mortis-merge-fixtures/knowledge-6ba66c0 --nightfall ../.mortis-merge-fixtures/nightfall-5690021
python -B scripts/check_nightfall_integration.py --knowledge-and-wisdom ../.mortis-merge-fixtures/knowledge-6ba66c0 --nightfall ../.mortis-merge-fixtures/nightfall-5690021
python -B scripts/preflight_runtime.py --knowledge-and-wisdom ../.mortis-merge-fixtures/knowledge-6ba66c0 --nightfall ../.mortis-merge-fixtures/nightfall-5690021 --game-root <explicit-local-game-root> --steam-manifest <explicit-local-appmanifest_108600.acf>
python -B scripts/check_public.py --staged
git diff --cached --check
```

All tests requiring an open game/server stay human-operated. Native creator
UI/storage, dependency stage-1 review, full locomotion/animation/restoration,
independent life identity, real lease/storage recovery, solar samples, observer/
join/reconnect/restart, Linux dedicated and whole-family startup remain NOT TESTED.
Production Active Hours and affected Knowledge MP persistence remain blocked.
G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. No production package, deployment,
game/server launch, Workshop upload, engine change or stable tag.

---

## Historical 0.26.0-dev.4 validation

# Current validation

Current development version: 0.26.0-dev.4

[TESTED — offline Windows Python 3.12.14 / Lupa 2.6, 2026-10-17]
Based on merged PR #8 commit 6af5d141a2342179233db9131e749ee7b819383e.
This iteration changes runtime version mirrors only; the new configuration
experiment, probes and preflight are outside runtime/package roots. Final Git
identity is recorded by the iteration PR, not invented inside a self-hashed file.
No native test was performed; all tests requiring an open game remain human-operated.

Full validation PASS: 64 Lua host regressions, 26 Active Hours diagnostic cases,
12 Python tests, 130 runtime Lua compilations, 15 current version mirrors and
87 JSON catalogs (37 sandbox option names/tooltips). Non-English fluency/native
fallback is unverified. Both actual-source dependency integrations ran against
Knowledge 0.16.0 / 6ba66c0d8f246d438f2e2f3c974fee9f77fdb426, with all 120 input
files verified. Its intentional multiplayer guard is retained. Unit-only CI
excludes those two integrations and cannot replace the full local run.

MORTIS exact input: 224 runtime/authoring files, inventory SHA-256
`6d760166c91b228750374af1ed247852827665f62d82402233f1ab3e8e080903`.
The reviewed descriptor digest matches the installed shared hub fingerprint
algorithm and passes its descriptor validator. Another preserved Contents layout
requires review; no historical packaging copy was deleted or synchronized.

[TESTED — bounded offline audit] The pinned Nightfall 0.30.0 / 6988b57 probe
reproduces NF-M01, NF-M02, NF-M03 (P1 state/cleanup defects) and NF-M04 (P2 readiness
coverage gap). Audit exit 1 is expected findings, not a passing consumer audit.
See NIGHTFALL_INTEGRATION_AUDIT.md for exact lines, observations and limitations.
Nightfall production was not changed; all four findings remain OPEN.

[TESTED — read-only local file preflight] Exact MORTIS/Knowledge inputs and
reviewed overview PASS. Packaged engine hash and explicit Steam build 25485521
match the selected baseline. Overall BLOCKED (exit 2): custom launcher agent/
classpath, two selected loose-class mismatches and the dependency MP contract.
No Java injection environment variable is nonempty. This is a selected-file
comparison, not whole-install integrity or proof of the next effective launch.
No raw launcher arguments, local logs, credentials or player data are published.

Exact commands from MORTIS root, using Python with scripts/requirements.txt:

```text
python -B scripts/validate.py --knowledge-and-wisdom ../.mortis-merge-fixtures/knowledge-6ba66c0 --dependency-evidence docs/evidence/knowledge-dependency-6ba66c0-git-bytes.json
python -B scripts/check_versions.py
python -B scripts/check_overview.py
python -B scripts/audit_nightfall_integration.py --nightfall ../.mortis-merge-fixtures/nightfall-6988b57 --knowledge-and-wisdom ../.mortis-merge-fixtures/knowledge-6ba66c0
python -B scripts/preflight_runtime.py --knowledge-and-wisdom ../.mortis-merge-fixtures/knowledge-6ba66c0 --game-root <explicit-local-game-root> --steam-manifest <explicit-local-appmanifest_108600.acf>
python -B scripts/check_public.py --staged
git diff --cached --check
```

Native creator UI/storage/controller, dependency stage-1 review, MORTIS SP,
full animation/lunge restoration, actual authority/replication, Linux,
save/rejoin/restart and dedicated lifecycle remain NOT TESTED/BLOCKED. Affected
Knowledge MP storage is implementation-blocked independently of missing evidence.
Production Active Hours remains gated. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.
No package, deploy, game/server launch, Workshop upload or stable tag.

---

## Historical 0.26.0-dev.3 validation

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
