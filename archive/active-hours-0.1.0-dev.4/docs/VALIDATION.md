Project Version: 0.1.0-dev.4

## Nightfall/MORTIS alternative — 2026-10-16

### Verified Workshop test distribution

Same-item retry succeeded: SteamCMD exit 0 with native Committing update...Success. for 3820693462. The earlier success parser expected the new-item phrase Published File Id; reviewing the native commit-success result, exit code and exact VDF identity corrected the verification record without another upload. Public Steam API returned result 1, App ID 108600, public visibility, title B47ANCE'd Active Hours, nonempty 55,670-byte content and the exact complete canonical test description. The public page was unavailable to the web reader; public metadata/description verification succeeded independently through Steam's read-only API. Subscription/download and actual game/server execution remain NOT TESTED.

Uploaded payload source: eda9c865a39d9c8c3f8a784108957a96056b629c on feature/mortis-speed-proof, version 0.1.0-dev.4. Seven-file package SHA-256 remains 80579f3f44325e1d09c937b02bb0aaceb8af64ace6dc2ba62e6dc8cf2abcc89e. JPEG preview SHA-256 02aeaab02b03a929eb60dc37080744f0d482032e052548a9926039eae2fba57d; original project PNG unchanged. The old source/staging and failed-attempt evidence were preserved. Complete sanitized publication provenance is docs/publications/0.1.0-dev.4-workshop-3820693462.json; raw Steam authentication/output logs remain private, not committed.

After verified success, the running Steam desktop executable was discovered at E:/program files (x86)/steam/steam.exe, gracefully stopped and restarted from that same path with a hidden launch window; client process restart verified. No forced process termination, game/server launch, local mod installation, player-save or remote-server modification. Steam restart is not download or MP evidence. G2 BLOCKED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED unchanged.

Distribution preflight: source commit 848d49cd8142c080fd7ca7397794bb00c2a5734a pushed/verified in PR #11; deterministic seven-file ZIP SHA-256 80579f3f44325e1d09c937b02bb0aaceb8af64ace6dc2ba62e6dc8cf2abcc89e. Generated with python scripts/build_mortis_test_package.py --output dist/current; scripts/check_versions.py --root . --release PASS for filename/embedded version checks only; ZIP CRC, exact member inventory, case collisions, traversal and source/stage hashes PASS. The canonical Workshop description renderer and --check PASS. No old proof/dependency source or Java enters the payload.

The user-authorized new Steam item was assigned 3820693462. First SteamCMD update returned exit 9 / Limit exceeded, not success. No Steam restart occurred after failure. Raw uploader output remains private outside the repository. A VDF UTF-8 handling error had already been corrected before SteamCMD was first invoked; the failed attempt and item identity are preserved for retry, not discarded or recreated. New Workshop-only JPEG delivery export validates at 1254x1254/199,723 bytes with original PNG unchanged. Retry/public verification outcome remains pending until explicitly recorded below.

User requested Nightfall's UV slow mechanism while new Workshop item creation remains authorized. Read-only inspection identified team-owned Nightfall 0.27.3 -> MORTIS 0.23.2/API 1.5.0 -> canonical server overrides. TEAM_API_RESEARCH.md records references/fingerprints/limits. No dependency implementation/assets were copied or changed. New source: proof/B47ANCEDActiveHoursMortisProof/. Original dev.3 proof and original spec/runbook/form are byte-for-byte unchanged and historical. Dependencies: ProjectMORTIS/experienceWorks; no Java/runtime Python.

[TESTED offline] Fourteen new consumer tests PASS per Lua 5.1/5.4 engine via existing lupa; nine version tests PASS, including historical preservation; original 36-test suite PASS on preserved dev.3 code under Lua 5.1. Prior original Lua 5.4 results remain historical. Existing MORTIS test_locomotion_overrides.lua and test_locomotion_adapter_numbers.lua ran directly/read-only under both engines with their native mocks: all four script executions PASS. None is Kahlua/native movement/replication proof.

Exact repository commands (the bundled Python executable recorded below was used):

```powershell
python scripts/check_versions.py --root .
python scripts/test_check_versions.py
python scripts/test_mortis_speed_proof.py
$env:B47_PROOF_LUA='54'
python scripts/test_mortis_speed_proof.py
Remove-Item Env:\B47_PROOF_LUA
python scripts/test_speed_proof.py
git diff --exit-code -- proof/B47ANCEDActiveHoursSpeedProof docs/ISOLATED_SPEED_PROOF.md docs/RUNTIME_TEST_RUNBOOK.md docs/RUNTIME_EVIDENCE_TEMPLATE.md
git diff --check
```

Current headers/runtime mirrors use dev.4; frozen proof/instructions deliberately retain dev.3. Only server calls MORTIS acquire/release; clients have no native setter or Apply handler. No whole-engine nonwrite claim. Release does not provide original scalar/full-state restoration. Native overwrite, effective owner behavior, observer motion and actual restored behavior remain NOT TESTED. G2 production BLOCKED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED.

Publication inputs: docs/WORKSHOP_DESCRIPTION.md and docs/WORKSHOP_CHANGELOG.md, labeled MP testing build - dedicated multiplayer NOT TESTED. Packaging writes only a fresh ignored dist directory, verifies explicit source inventory/ZIP integrity/hashes and records source commit; it never deletes, uploads, installs or launches. Package/upload results must be recorded after execution; no Workshop ID or upload success is invented here. Fallback icon/poster are exact byte copies; selected thumbnail unchanged.

## Versioning initialization — 2026-10-08

User-approved initial version. Development-only checks recorded below; historical validation body remains verbatim. Prior offline source checks remain applicable as retained observations, not runtime proof for this version. No gameplay or research finding changed.

G2 BLOCKED; Phase B NOT STARTED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED.

[TESTED offline / Python 3.12 bundled development runtime] From the project root, exact commands:

```powershell
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/test_check_versions.py
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/check_versions.py --root . --json
```

Results: nine integration tests PASS, covering matching, missing canonical, missing mirror, malformed canonical/prerelease, malformed mirror, inconsistent mirror, duplicate selector, missing release artifact and SHA-256 preservation of research/historical audit files. Development checker exits 0 with no errors for canonical 0.1.0-dev.1, fourteen declared current documentation mirrors and newest changelog entry. The missing dist/current/*.zip is reported as deferred, not validated. Temporary fixture --release exits 1 as expected; no archive was generated.

Framework checker copied unchanged from project-template/scripts/check_versions.py; local policy adopts the framework with project-specific version/compatibility decisions. Missing future mod.info/version constants, generated staging and release metadata remain deferred and must enter the inventory before their implementation/packaging. Current documentation mirrors have no inconsistency. Historical unassigned-version statements below remain historical facts; no old evidence was relabeled as runtime validation of this prerelease.

---
Historical validation follows unchanged.

## Lua-only follow-up — 2026-10-08

[TESTED offline] Exact commands from workspace root:

```powershell
& '.\B47ANCE''d Active Hours\research\Check-AuditEvidence.ps1'
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' '.\B47ANCE''d Active Hours\research\test_bytecode_index.py'
Get-FileHash -LiteralPath 'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\projectzomboid.jar' -Algorithm SHA256
```

Eight existing source assertions plus document presence PASS; five bytecode parser tests PASS. JAR hash remains E1A69EB743EDE60B213A0FE7F8B83D4FCAB773036D256CC4543A336F3B058A33. These validate retained native research, not executable Lua behavior.

Additional inline Python source assertions PASS: Java-style public method exposure exists; each direct category method contains native randomization/helper calls and no DoZombieStats/makeInactive call; six current Lua/solar design documents exist. Source references were checked against retained file paths. No Lua profile code or configuration validator was executed. G2 BLOCKED; Phase B NOT STARTED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. No runtime, deployment or packaging occurred; project remains unversioned research.

> CURRENT SCOPE — Lua-only custom behavior profiles supersede native activity control. Retained source evidence is historical and does not prove normal Lua invocation or dedicated multiplayer behavior. See LUA_ONLY_API_AUDIT.md and LUA_MULTIPLAYER_AUTHORITY.md; no runtime gate has passed.

# Audit validation record

2026-10-08, Windows PowerShell, audit-only project with unassigned version.

[TESTED] Offline: CFR extraction/decompilation commands exited 0. These establish inspectable evidence, not engine execution or Lua accessibility. Source review found the overwrite blocker. Decompiled output includes missing-class warnings and is not compilable production code.

Exact decompiler command pattern executed for each extracted class:

```powershell
& 'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\jre64\bin\java.exe' -jar '.tmp-nightfall-decompile\cfr-0.152.jar' $dest --outputdir 'True Active Hours\research\jar-source' --silent true
```

The original audit directory was subsequently renamed to `B47ANCE'd Active Hours` following the user's naming instruction. `$dest` was the corresponding class under `True Active Hours\research\jar-classes`; inspected entries are listed by the retained directory inventory and SHA256.json. Extraction used .NET `ZipFile.OpenRead`, `GetEntry` and `ZipFileExtensions.ExtractToFile` against the main game JAR. No base files were modified.

Exact hash verification command executed:

```powershell
Get-FileHash 'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\projectzomboid.jar','E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\zombie\characters\IsoZombie.class' -Algorithm SHA256 | Format-List
```

[TESTED] Offline document check, PASS (four nonempty files):

```powershell
$required=@('README.md','docs\API_AUDIT.md','docs\NATIVE_ACTIVITY_CALL_GRAPH.md','docs\MP_AUTHORITY_AUDIT.md')
foreach($file in $required){
    $p=Join-Path "B47ANCE'd Active Hours" $file
    if(!(Test-Path -LiteralPath $p)){throw "Missing $file"}
    if((Get-Item -LiteralPath $p).Length -eq 0){throw "Empty $file"}
}
```

`Get-ChildItem "B47ANCE'd Active Hours" -Recurse -Filter 'mod.info'` returned no files, consistent with an audit-only result. No gameplay tests were written or executed. `scripts/check_versions.py` is absent in this new audit directory; version validation is BLOCKED pending an established project version and inventory, not PASS. No --release check or packaging occurred.

[RUNTIME GATE] Phase B / G6 client proof: BLOCKED by source architecture. Dedicated multiplayer G7: BLOCKED / NOT TESTED. G8: BLOCKED. Neither PZ nor its server was launched; no live deployment was made.

Before edits, this project directory did not exist. All additions are confined to this directory; SHA256.json records local engine evidence files after extraction. There is no Git baseline in this workspace. No existing project or immutable validation record was rewritten.

## Follow-up investigation, 2026-10-08

[TESTED] Offline source-evidence assertions: exit 0, six assertions and document-presence check passed. Exact command from workspace root:

```powershell
& ".\B47ANCE'd Active Hours\research\Check-AuditEvidence.ps1"
```

These checks verify retained decompiled evidence for build identity, global overwrite, reactivation stats, client registration zero, spawn-event ordering and absence of inactivity in the inspected boolean mapping. They are research consistency checks, not gameplay regression tests or bytecode/runtime verification.

Additional JAR entries extracted and decompiled using the same CFR command with the renamed output directory: zombie/characters/IsoGameCharacter.class, zombie/popman/ZombiePopulationManager.class, zombie/VirtualZombieManager.class. Requested zombie/network/packets/character/ZombieSimulation.class was absent; no conclusion was drawn from that missing guessed path. Additional evidence hashes are recorded separately in research/SHA256-followup.json; the earlier manifest is preserved.

Read-only launcher inspection confirmed configured classpath ordering; launchers were not executed. See NATIVE_BRIDGE_DESIGN.md for the candidate interception and remaining authority/identity/loader prerequisites. No gameplay implementation, native hook verification, Lua invocation, client or dedicated test occurred. G2 remains BLOCKED, G6 NOT TESTED, G7 BLOCKED / NOT TESTED, G8 BLOCKED. Version checker remains blocked pending assigned project SemVer and inventory.

## Expanded handoff attribute audit, 2026-10-08

Baseline JAR SHA256 rechecked unchanged. Additional scoped entries were extracted/decompiled with CFR 0.152: WorldSoundManager, ThumpState, ZombieStateFlags, AttackState, AttackNetworkState, FakeDeadAttackState, animals/AnimalAttackState, ZombieThumpManager, pathfind/PathFindBehavior2, IsoDoor, IsoThumpable and ZombieSimulationPacket. Guessed ZombieAttackState/ZombieAttackNetworkState and vehicles/PathFindBehavior2 entries were absent; enumeration established their actual paths. Missing guessed paths are not evidence of missing capabilities. Additional extracted-class/source hashes are in research/SHA256-attributes.json; earlier manifests retained.

[TESTED] Offline: `& ".\B47ANCE'd Active Hours\research\Check-AuditEvidence.ps1"` exited 0: eight source assertions and document presence passed. The script now checks the full retained DoZombieStats region's observed assignment/call set, absence of toughness initialization there, and door strength/cognition readers. It checks decompiled text, not actual runtime writability or multiplayer correctness.

[TESTED] Offline documentation presence check exited 0 for the ten requested docs. Exact check:

```powershell
$requiredDocs=@('API_AUDIT.md','NATIVE_BRIDGE_FEASIBILITY.md','DYNAMIC_ATTRIBUTES_API_AUDIT.md','ATTRIBUTE_READ_WRITE_CALL_GRAPH.md','ATTRIBUTE_NETWORK_REPLICATION.md','MULTIPLAYER_AUTHORITY.md','PERFORMANCE_DESIGN.md','CONFIGURATION_GUIDE.md','TEST_PLAN.md','RELEASE_BLOCKERS.md')
foreach($doc in $requiredDocs){
    if((Get-Item -LiteralPath (Join-Path "B47ANCE'd Active Hours\docs" $doc)).Length -eq 0){throw "Empty $doc"}
}
```

No production code, config or unsupported option was enabled. Initial version remains unassigned as required by the updated handoff; version checks blocked before implementation. Phase B NOT STARTED; G2 BLOCKED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. Runtime proof and Insane performance remain unmeasured. Public loader discovery did not establish the required API, so no loader was adopted. No installed binaries/launchers or external mods were changed.

## Foundational blocker investigation — 2026-10-08

[TESTED offline, Python] Five focused instruction-decoder tests PASS. Whole-JAR selected direct-reference census: 23,829 class files, 247 references, zero parse errors. Both retained updateActiveState variants have identical resolved instructions; raw Code hashes are not compared as semantics because constant-pool indices differ. Source-helper reachability check found no direct getSandboxMemoryDuration invocation. Exact commands from workspace root:

```powershell
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' ".\B47ANCE'd Active Hours\research\test_bytecode_index.py"
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' ".\B47ANCE'd Active Hours\research\index_attribute_bytecode.py" --jar 'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\projectzomboid.jar' --loose-zombie 'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\zombie\characters\IsoZombie.class' --output ".\B47ANCE'd Active Hours\research\attribute-bytecode-index.json"
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' ".\B47ANCE'd Active Hours\research\summarize_attribute_index.py"
```

These tests verify research tooling/static evidence, not bytecode transformation or PZ execution. Newly identified JAR references were independently decompiled using the earlier CFR command; no third-party gameplay source used. Follow-up includes owner packer/list, command entry points, ECS network component, online-ID allocator, additional attribute readers and reanimation. The indexed appendix gives descriptors/offsets for exact direct references. Reflective/native/bootstrap/mod/agent references remain outside the census.

[VERIFIED documentation] Upstream v2.3.4 documentation/license/API pinned to 9a08a542cfb55f7c8f4973a545639430b3c601ee; no binary downloaded/adopted. Java platform documentation establishes instrumentation/classfile API contracts; installed runtime reports Azul Java 25.0.1 and java.instrument. API module java.compiler is present but compiler module jdk.compiler is absent. No research agent compiled or executed. Earlier statements about missing documented loaders are narrowed by new evidence, not retroactively marked runtime PASS.

No installed binary, launcher or external mod changed; no transformed game class output, production gameplay source, deployment or package created. Project remains unversioned research. G2 BLOCKED; executable Phase B NOT STARTED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. ONE_ZOMBIE_POC_ARCHITECTURE.md is conditional research design, not a completed prototype.

Final provenance clarification: “no installed binary changed” above means no installed-file writes by this task. Final read-only hashing detected external loose-class drift from historical A25DFE... to AA340922464B04A9EF12116C0CEBCD9EA5E5DAA33E1B9617A12822BDA839633F. Source/timing UNKNOWN; no assumption of pristine runtime or compatibility. New input bytes were copied only into the research directory under their full SHA256 filename; old source research/manifests remain unchanged. A re-run against the immutable snapshot again parsed 23,829 classes/247 references with zero errors and passed exact seam comparison. Installed class still matched that snapshot on the final read.

Exact final census command uses the snapshot rather than an unstable live input:

```powershell
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' ".\B47ANCE'd Active Hours\research\index_attribute_bytecode.py" --jar 'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\projectzomboid.jar' --loose-zombie ".\B47ANCE'd Active Hours\research\effective-snapshots\aa340922464b04a9ef12116c0cebcd9ea5e5daa33e1b9617a12822bda839633f.class" --output ".\B47ANCE'd Active Hours\research\attribute-bytecode-index.json"
```

Eight earlier PowerShell source assertions also passed in this turn. SHA256-foundations.json records newly retained JAR classes/decompiler sources; the hash-named index records the effective snapshot. No JVM game class was executed, and no bytecode transform or runtime proof is claimed.

## Repository onboarding and resumed audit — 2026-10-14

Project canonical version remains 0.1.0-dev.1. Documentation-only refinement within the existing development checkpoint; no public gameplay/API/config/save compatibility change and no version bump. Initial public main commit: ebc2b69808ccf185a6b7ef90f9d27b21b6c1197e, verified equal to origin/main; repository visibility PUBLIC. Research/ and linked local tool/config directories are ignored, not uploaded. Local preserved evidence remains available; public checkout has no engine sources. No CI/branch protection or runtime verification is claimed.

Exact development commands from repository root:

```powershell
& C:\Users\willi\.codex\b47anced-team\tools\Test-PZRepositoryFreshness.ps1 -Repository .
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/check_versions.py --root .
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/test_check_versions.py
git diff --cached --check
git ls-remote origin refs/heads/main
```

[TESTED offline] Imported main freshness PASS: clean, 0 ahead/behind upstream/default; canonical version/mirrors PASS; nine integration tests PASS with local research present. Historical audit/source hashes preserved. Public-clone preservation intentionally omits unavailable ignored research, while still validating historical tracked documents; this omission is not a source evidence PASS. Before each push staged/tracked surfaces were reviewed for secrets and accidental binaries/diagnostics.

[VERIFIED source inspection] Resumed audit inspects retained 42.21 decompiled output, not actual Lua calls. Installed JAR SHA256 remains E1A69EB743EDE60B213A0FE7F8B83D4FCAB773036D256CC4543A336F3B058A33; previously documented loose-class drift is unresolved. No game/server, Java component, prototype, deployment or package created. G2 BLOCKED; Phase B NOT STARTED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED.

## PR #1 review/merge and next source slice — 2026-10-14

PR #1 merge commit a911425a3df0569bb4f23d64c2552494a9a7b7a3 is verified on origin/main. GitHub showed MERGEABLE/CLEAN, no status-check rollup, unprotected main and no repository rulesets. These are absent checks, not CI PASS. Offline version checker, nine integration tests and diff whitespace checks passed. One UTF-8 range punctuation error was corrected in commit c64146e before merge. No runtime gate was advanced.

New branch research/lua-speed-replication-proof starts at verified origin/main: freshness PASS, clean, zero ahead/behind upstream/default. Documentation-only refinement remains 0.1.0-dev.1 with no gameplay compatibility change. Source findings: actual IsoZombie turnDelta override corrects the previous inherited-getter assumption; native flags encode lunger/running; remote/server scalar paths show different units; packet fields do not explicitly carry turnDelta/animation-rate/variant. These are retained decompiled-source observations, not live correctness claims. An inline parser read returned method code hashes only, not decoded instructions for these methods; it does not independently verify their semantics.

Exact validation commands: `python scripts/check_versions.py --root .`, `python scripts/test_check_versions.py`, `git diff --check`, and shared Test-PZRepositoryFreshness.ps1 -Repository . (bundled Python executable as recorded above). No gameplay/runtime test was run. G2 BLOCKED; Phase B NOT STARTED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. Historical local research is unchanged.

## PR #2 review/merge and packet audit — 2026-10-14

PR #2 merged as 3eabc862acb75ff3fdebbfa10e238315ee50cfe4 after version checker, nine offline tests and diff review. GitHub showed CLEAN/MERGEABLE, no status checks, unprotected main and no rulesets; absence is not CI PASS. New research/lua-packet-ordering-proof started at fetched origin/main with clean freshness PASS and zero ahead/behind. Version stays 0.1.0-dev.1; documentation-only slice, no gameplay/config/save compatibility change.

[TESTED offline] A read-only inline Python audit used the retained research/index_attribute_bytecode.py in memory, replacing its resolved-instruction output filter with unconditional resolved output. Its on-disk source remained unchanged. It read the installed main JAR with zipfile, decoded method instructions and printed selected reference windows; no game class or JVM executed. Exact reproducing algorithm: read parser as UTF-8, replace `resolved if name == 'updateActiveState' else []` with `resolved`, exec under a non-main name; call parse on JAR entries NetworkZombieAI.class, IsoZombie.class and network/packets/character/ZombiePacket.class; select methods parse, getTurnDelta, and set(IsoZombie); inspect speedMod/setSpeedMod/turnDeltaNormal/getWalkType/walkType reference windows.

| Method | Code SHA-256 | Relevant offsets |
|---|---|---|
| NetworkZombieAI.parse(ZombiePacket) | 9a66fe060a5efab45bc0f0ddd410fd1e1024d42b397a8b1acbb1b96c0982b242 | 215 short field read, 218 i2f, 219 scalar setter |
| IsoZombie.getTurnDelta()F | d95ec7ed640ce7dbad63744844153e7f7af923d6e57d97390fe7a52508b72a55 | 1 normal field read, 4 freturn |
| ZombiePacket.set(IsoZombie) | d31007771802ab40df723af9010d82e46296becbf2c030a0d6a79fecfa17e030 | 53 getWalkType, 59 packet walkType write |

Source/bytecode findings are static only. Optional speed and owner/observer ordering were source-inspected, not runtime tested. Exact routine commands: bundled Python `scripts/check_versions.py --root .`, `scripts/test_check_versions.py`; `git diff --check`; shared `Test-PZRepositoryFreshness.ps1 -Repository .`. Version/mirrors and nine tests PASS; preserved research/historical document hashes still match. No launch, prototype, Java component, deployment or package. G2 BLOCKED; Phase B NOT STARTED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED.

## PR #3 review/merge and Lua observation slice — 2026-10-14

PR #3 merged as 1c70ff335153f4e047e50014747fc5b5c63d79c1. Review: CLEAN/MERGEABLE, no status-check rollup, unprotected main, no rulesets; no required CI was bypassed or claimed PASS. Offline version checker, nine tests and diff check PASS. New research/lua-observation-event-proof starts at fetched origin/main; freshness PASS, clean, zero ahead/behind default/upstream before edits.

[VERIFIED source] Retained IsoZombie event ordering/early returns, shouldSprint callback side effect, Lua global targeted-send wrapper and server missing-route returns inspected. A targeted installed media/lua search returned no OnZombieUpdate/OnZombieCreate examples; this absence is not proof of unavailable events. IsoCell implementation was absent from the retained source paths inspected, so no list/lookup guarantee was established. No additional engine extraction or runtime execution occurred.

Documentation-only refinement remains 0.1.0-dev.1 with no gameplay compatibility change. Exact validation commands from root: bundled Python executable recorded above with `scripts/check_versions.py --root .` and `scripts/test_check_versions.py`; `git diff --check`; shared `Test-PZRepositoryFreshness.ps1 -Repository .`. Current version/mirrors PASS; nine offline tests PASS, including unchanged local research/historical hashes. No executable probe, Java, launch, deployment or package. G2 BLOCKED; Phase B NOT STARTED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED.

## PR #4 review/merge and restoration-surface audit — 2026-10-14

PR #4 merged as 25b45c72d0d7e75f6c0b557090c13c2d2276d8f3 after version checker, nine tests, diff/source review. GitHub showed CLEAN/MERGEABLE, no status checks, unprotected main and no rulesets. No required CI was bypassed; absence is not CI PASS. New research/lua-restoration-surface-audit started clean at fetched origin/main with freshness PASS and zero ahead/behind upstream/default.

[TESTED offline] Read-only inline Python reused the retained class parser in memory, retaining each method's access flags and all resolved instructions without changing its disk source. Inspected main-JAR IsoSpriteInstance, IsoZombie and IsoGameCharacter public concrete methods. Output confirmed sprite getFrame()F, setFrameSpeedPerFrame(F)V and no declared matching rate getter; targeted lunger/walkVariant accessor pairs were not found. Setter bytecode: multiplier read offset 2, fmul 5, animFrameIncrease write 6. The census omits non-Code methods and does not establish exhaustive cross-class semantics or actual Lua exposure/invocation. Source inspection establishes allocating getSpriteDef and conditional isRunning. No engine classes executed or extracted for distribution.

Exact routine commands from root: bundled Python executable recorded above with `scripts/check_versions.py --root .`, `scripts/test_check_versions.py`, and `research/test_bytecode_index.py`; `git diff --check`; shared `Test-PZRepositoryFreshness.ps1 -Repository .`. Current version/mirrors PASS; nine version tests and five retained decoder tests PASS offline. Historical local engine source/hash evidence unchanged. Documentation-only refinement stays 0.1.0-dev.1; no gameplay compatibility change. G2 BLOCKED; Phase B NOT STARTED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. No executable probe, Java, launch, deployment or package.

## Isolated proof preparation — 2026-10-14

Version remains the user-specified 0.1.0-dev.1. New experimental capability fits the existing initial 0.1.0 development target; no stable/production contract or save migration. Feature branch feature/isolated-lua-speed-proof starts at 638d796ac1f6447dc0ec5515d1e33c518a57f56b on pending PR #5, which is not merged by this request. Initial freshness PASS, clean, matching branch upstream, one commit ahead/zero behind main. Proof runtime files, mod.info, Lua constant and new instructions are inventoried.

[TESTED offline] Actual Lua sources executed through development lupa 2.6 in three independent mocked runtimes (server/A/B). Sixteen tests PASS: requested fixed transitions, nominal scalar/walk restoration, observer/server nonwrites, admin/invalid request rejection, Both conflict, duplicate/stale intent, transfer restoration, partial setter rollback, anomaly detection, no reapply during native drift, object reuse/gap, malformed ack/flat wire, missing owner, idempotent registrations, hotkeys. Fault injection with server-only ownership change demonstrates former-owner local write under delayed native revocation and server acknowledgment rejection; that test passing is NOT safe-handoff evidence. Native replication is nominally mocked, not the actual engine packet arithmetic.

Exact commands from repository root:

```powershell
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/check_versions.py --root .
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/test_check_versions.py
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/test_speed_proof.py
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' research/test_bytecode_index.py
git diff --check
```

Version consistency PASS; nine version tests PASS; sixteen Lua mock tests PASS; five decoder tests PASS. Static source restrictions and case-correct require path checked. Lua engine calls, local mod loader, operator controls and dedicated behavior NOT TESTED. Lupa is development-only; no shipped Python/Java runtime dependency. Source references: exposed method rules retained in LUA_ONLY_API_AUDIT; category setters IsoZombie:3371-3389; scalar methods IsoGameCharacter:3771-3776; owner player/local tests IsoZombie:647 and IsoPlayer:6288; admin getAccessLevel IsoPlayer:7187 (deprecated native API, actual role formatting needs test); Both GameTime:1291; Keyboard exposure LuaManager$Exposer:2636; installed vanilla OnKeyPressed/isKeyDown examples. No unsupported method invented.

Server state is session-only for a continuously loaded object. No persistent identity/late joins/reconnects; restart or invalidation requires ending the test, not claiming restoration. G2 BLOCKED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. Phase B source prepared, native execution NOT STARTED. No game/server, deployment, Workshop publication, game file modification or release package. Historical research/hashes and earlier evidence remain unchanged.

Mock execution engine is Lua 5.4 via lupa, not PZ Kahlua. A read-only static check rejected forbidden activity/helper/scan calls and sandbox assignments, verified exact shared require paths, no proof Java/JAR files and no case-colliding proof filenames. Static PASS does not prove Linux/PZ loading. Runtime category labels use strict known slow1-3, sprint1-5 and 1-5 patterns; unknown variants block the experiment.

Git bookkeeping: pre-first-push freshness helper returned UNKNOWN because the new feature branch had no upstream. The parent had been verified, but this was not a branch freshness PASS. After establishing its tracking branch, fresh fetch/check returned PASS: a07163a29d1862c87246b879132a531788f36a09 equals remote head, clean, zero ahead/behind feature upstream and two ahead/zero behind main. No reconciliation or history rewriting occurred. PR preparation is stacked on unmerged PR #5; it does not merge that research automatically.

## Prototype readiness fixes — 2026-10-14 / 0.1.0-dev.3

Starting source: clean feature/isolated-lua-speed-proof at 085aba615122b8de62339d221c63ad12a2ed2622, equal to its public upstream, six ahead/zero behind main; freshness PASS. Actual canonical version was 0.1.0-dev.2, matching the new handoff. Its old Desktop/Repositories path does not exist; existing Desktop/Work/Project Zomboid/Mod Repositories/B47ANCEDActiveHours retained as source of truth. The new fix/lua-proof-readiness branch tracks the verified feature upstream until first push. PR #5/#6 are not merged by this work. Existing fallback artwork and historical research were preserved.

[TESTED offline baseline] Before edits, version consistency PASS, nine version tests PASS and sixteen Lua mock tests PASS. Those mocks preserved empty Lua tables across transport and missed a native compatibility defect. Reproduction updated the mock to omit empty tables (GameClient.java:1897; GameServer.java:2357). Before source fixes, the eighteen-test suite had five failures: three restoration/control paths plus nonempty-session payload and malformed snapshot validation. This is a deterministic offline reproduction, not a PZ runtime observation.

Root causes and fixes: nil walk/category could compare equal and be accepted; now both are explicitly required with recognized mapping. Empty Restore/Dump tables arrive nil natively; all client requests now carry epoch, mutation intents add monotonic IDs and are bound to the selecting admin. Added one-shot acknowledgment deadline and explicit stop on pending/unobserved ownership change; no retry or speed reapply. Read-only evidence remains available after freeze. API/send/rollback failures now have bounded result records and counters. Owner-reported fields are labeled separately from native server samples. No distributed-atomicity claim: delayed revocation still permits an old local write in the retained fault test.

Exact validation commands from the verified repository root:

```powershell
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/check_versions.py --root .
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/test_check_versions.py
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/test_speed_proof.py
$env:B47_PROOF_LUA='54'
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/test_speed_proof.py
Remove-Item Env:\B47_PROOF_LUA
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' research/test_bytecode_index.py
git diff --check
```

Results after fixes: version consistency PASS; nine version tests PASS; thirty-six Lua proof tests PASS in each of Lua 5.1 and Lua 5.4 via existing lupa 2.6; five retained decoder tests PASS. No new dependency or Kahlua execution. All three actual Lua files are parsed/executed in the mock harness with both engines; this is not native API/network proof. Static layout/Mod ID/common+42/shared-client-server placement, case-correct require and no case collision/forbidden-call/sandbox-write/Java-JAR checks PASS. Existing archival source/hash preservation test PASS; source research unchanged. No packaging check is claimed: --release artifacts remain absent and G8 blocked.

Readiness assessment and exact manual install/operator/failure procedure: ISOLATED_SPEED_PROOF.md. Next milestone is human load/API/role/key smoke validation and passive baseline on one disposable dedicated server/two clients, then fixed transition/60-second overwrite/restoration, and separate ownership-fault sessions. No actual runtime results or current logs exist for this new source, so prior logs were not substituted as evidence and no server/SFTP/save files were accessed. G2 BLOCKED (production), G6 NOT TESTED, G7 BLOCKED / NOT TESTED, G8 BLOCKED. Safe isolated research/testing is allowed. No installation, launch, deployment, save edit, Workshop publication or release package.

Final review also covers enrollment-broadcast send exceptions: the prototype records enrollment-send-error and stops without retry or mutation; regression included in the thirty-six-test count.

## Final runtime handoff preparation — 2026-10-14 / existing 0.1.0-dev.3

Authoritative checkout unchanged: Desktop/Work/Project Zomboid/Mod Repositories/B47ANCEDActiveHours. Started clean on fix/lua-proof-readiness at 24d682a2494afc145ebcb22f6f095fe5267a1766, matching public upstream, eight ahead/zero behind main; freshness PASS. New docs/dev3-runtime-test-handoff tracks that verified source branch until its own push. No merges, migrations or additional checkout. This handoff is documentation-only, not a new version/compatibility iteration; canonical version and Lua source remain unchanged.

[VERIFIED source / STATIC PASS] Re-read all three Lua files and mod.info plus source evidence for native mapping/getter/setter exposure, role/routing, nil args, event placement, loader-side guards, session/intent/revision checks, duplicate/stale input, owner-only batch path, passive observer, deadline, restoration/rollback and bounded counters. No new demonstrated defect. Static require case/layout/common+42 and no forbidden Java/activity/sandbox-write/population-scan calls remain covered by the existing test. No new speculative architecture or runtime dependency.

[VERIFIED read-only environment] Local client cache mods/Server/Saves directories exist; contents/secrets were not read. Installed client server BAT omits argument forwarding; dedicated Steam StartServer64 includes an agent option and only two forwarded tokens; non-Steam StartServer64 omits forwarding. These launchers were neither executed nor modified. Dedicated built-in JRE exists; three targeted loose zombie/AI/simulator overrides were absent there, which is NOT a full integrity audit. Client and dedicated main JAR SHA256 match E1A69EB743EDE60B213A0FE7F8B83D4FCAB773036D256CC4543A336F3B058A33. Previously documented client loose-class drift remains unresolved. No agent implementation was inspected/adopted. Runbook uses human-reviewed vanilla GameServer arguments supported in retained GameServer.java:644-645 and :808-820 and private profile filenames from SandboxOptions.java:685-691; actual launch/cache/loader remains NOT TESTED.

Offline commands (repository root, bundled Python):

```powershell
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/check_versions.py --root .
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/test_check_versions.py
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/test_speed_proof.py
$env:B47_PROOF_LUA='54'
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/test_speed_proof.py
Remove-Item Env:\B47_PROOF_LUA
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' research/test_bytecode_index.py
git diff --check
```

[TESTED offline] Version consistency PASS; nine version tests PASS; thirty-six proof tests PASS with each of Lua 5.1 and Lua 5.4 via existing lupa; five decoder tests PASS. Kahlua/Build 42.21/native calls/Steam connections were not executed. Warning: dist/current/*.zip absent/deferred and checker covers only declared mirrors; no package/release check claimed. Git line-ending notices, if emitted, are metadata conversion notices, not gameplay evidence. Historical preservation tests PASS. No runtime success inferred.

Changed surfaces: new RUNTIME_TEST_RUNBOOK.md and RUNTIME_EVIDENCE_TEMPLATE.md, their current-header version inventory entries, and links/dated preparation notes in README, CHANGELOG, ISOLATED_SPEED_PROOF, LUA_SPEED_CONTROL, LUA_MULTIPLAYER_AUTHORITY, LUA_ONE_ZOMBIE_POC, TEST_PLAN, RELEASE_BLOCKERS, VALIDATION and VERSION_INVENTORY. Lua/mod.info/game files, existing artwork, research, historical validation sections and root VERSION are unchanged. The evidence template is blank/NOT EXECUTED; filled logs/backups belong privately outside the repository.

G2 production architecture BLOCKED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. Human passive smoke is the next milestone, not expanded gameplay. No directory/cache creation, installation, game/server launch, save access/modification, launcher editing, deployment, Workshop action or package creation was performed.

## User-selected project thumbnail — 2026-10-15 / existing 0.1.0-dev.3

Artwork-only edit on artwork/custom-project-thumbnail, based on the verified merged research/lua-restoration-surface-audit branch at 8c07eced04acb30e901889979f5f1572ffd0f02e. The supplied custom Active Hours PNG is retained as assets/branding/ActiveHoursThumbnail.png and copied byte-for-byte to root thumbnail.png. README now displays the project thumbnail; docs/BRANDING.md records current selection and preserved fallback authoring provenance. No gameplay/configuration/API/save contract change, so this small edit stays within the current unreleased checkpoint rather than inventing a new version.

[TESTED offline / artwork] Both selected copies: PNG, 1254x1254, 1,538,317 bytes, SHA-256 04cc30dd9d6a0bb5ecb404853df9756aff6f8c344b2ef3d7775ab83c6fba7849, exactly matching the supplied file. A one-off Python stdin check used hashlib and PIL.Image.verify() for both files; all checks PASS. Visual inspection of the copied thumbnail matches the selected clock/zombie artwork. No resize, crop or regeneration. All three existing B47 fallback PNG hashes remain unchanged.

Exact repository validation commands (bundled Python):

```powershell
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/check_versions.py --root .
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' scripts/test_check_versions.py
git diff --exit-code -- proof scripts VERSION research
git diff --check
```

Version consistency PASS before/after; nine version tests PASS, including historical evidence preservation. An initial fixture failure exposed that the test assumes README is the first inventory mirror; the new branding mirror was appended to preserve existing inventory ordering, then all nine passed without changing tests/checker. New current branding header and historical fallback record are classified separately. Missing dist/current/*.zip remains a deferred packaging note; no artifact check claimed. Git CRLF conversion notices are metadata-only. Existing proof tests were not repeated for an artwork-only edit; prior Lua mock evidence remains tied to its recorded source. No PZ/Kahlua/SP/dedicated runtime result is added.

Changed files: thumbnail.png, assets/branding/ActiveHoursThumbnail.png, README.md, CHANGELOG.md, docs/BRANDING.md, docs/VERSION_INVENTORY.md, version-inventory.json and this validation record. Source Lua, tests, root VERSION, fallback assets and historical research remain unchanged. No installation, launch, packaging, deployment or publication. G2 BLOCKED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED.
