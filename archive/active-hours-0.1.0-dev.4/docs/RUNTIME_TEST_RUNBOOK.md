Project Version: 0.1.0-dev.3

# Human-operated Build 42.21 experiment

Preparation only; no live result is recorded here. G2 production architecture BLOCKED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. G2 does not prohibit this isolated experiment. Use [the blank evidence form](RUNTIME_EVIDENCE_TEMPLATE.md) for actual observations, and [the existing proof specification](ISOLATED_SPEED_PROOF.md) for implementation/evidence detail.

## Final static readiness assessment

| Surface | Current assessment | Still requires live evidence |
|---|---|---|
| common/ and 42/ layout, mod.info, Mod ID | STATIC PASS: B47ANCEDActiveHoursSpeedProof, not Core/Night/Day | Build 42.21 loader accepts local mod |
| shared/client/server placement and require case | STATIC PASS; shared B47AHProof required by both sides | Actual Kahlua load order |
| Lua syntax | 36 mock tests PASS in each Lua 5.1 and 5.4 engine | Kahlua/native conversion behavior |
| events, reload guards, left Ctrl+Shift keys | Source-supported / offline PASS | Native key delivery and callbacks |
| getters, setter signatures, category mapping | Source-supported: 3 Shambler, 2 Fast Shambler, 1 Sprinter | Actual movement, animation and pursuit |
| admin, payload, operator/session/intent/revision guards | Offline PASS, including empty native arguments | Native roles, route and command ordering |
| local-owner writes and observer nonmutation | Guard tests PASS, including stale/duplicate commands | Cross-stream revocation race remains unresolved |
| acknowledgment deadline and mutation stops | Offline PASS; expiry never retries | Real latency, delivery and native handoff |
| directly changed fields / one-shot rollback | Offline PASS | Connected behavioral restoration |
| bounded samples/results/counters | Offline PASS; request-only dumps | Correct interpretation in native traces |
| canonical version and current mirrors | PASS; no version bump for this handoff | Identical installed bytes on all peers |

No new demonstrated Lua defect was found in this final pass, so runtime source is unchanged. The existing three-peer preparation check is an operator prerequisite, not an implemented client-count/ready-ack protocol. Offline tests are not Kahlua, native packet or Linux-runtime proof. No Insane-population claim.

## 1. Establish a private disposable environment

All commands below are for a HUMAN to review and run later. Codex did not execute installation, cache creation or launch commands. Use an isolated host with unused game ports; do not stop, reconfigure or contend with a production server. Use separate client machines/accounts as required by the normal game; no split screen.

Use this repository, not the obsolete Desktop/Repositories location:

`C:\Users\willi\Desktop\Work\Project Zomboid\Mod Repositories\B47ANCEDActiveHours`

Read VERSION, record `git rev-parse HEAD`, and confirm every peer's game is exactly Build 42.21 through its actual startup/version output. Matching mod version alone does not prove matching source or engine. The inspected client and dedicated main JARs both hashed `E1A69EB743EDE60B213A0FE7F8B83D4FCAB773036D256CC4543A336F3B058A33`; previously observed client loose-class drift is still unresolved. Record classpath/patch provenance and use a vanilla, unmodified effective engine for the intended Lua-only evidence. A matching JAR does not exclude loose overrides or agents.

Known launcher hazards on this machine, from READ-ONLY inspection:

- Client installation ProjectZomboidServer.bat does not forward arguments. Do not pass a test profile to it and assume isolation.
- Dedicated StartServer64.bat includes a Java-agent option and forwards only two argument tokens. Do not use that invocation for this experiment.
- Dedicated StartServer64_nosteam.bat does not forward arguments. Do not assume it selects a disposable profile/cache.

No launcher or installed file was changed. Do not edit them to make this test work. A clean installation/verified vanilla launch environment is a setup prerequisite. No external agent code was analyzed or adopted.

In a NEW operator PowerShell window, the following creates a unique private cache/profile location OUTSIDE the repository. Review paths first. This new cache owns its own server configuration, database and world; never copy an existing multiplayer world into it.

```powershell
$testLabel = 'AH_dev3_' + (Get-Date -Format 'yyyyMMdd_HHmmss')
$privateRun = Join-Path $env:USERPROFILE ('ZomboidProofRuns\' + $testLabel)
if (Test-Path -LiteralPath $privateRun) { throw 'Choose a new empty run directory.' }
New-Item -ItemType Directory -Path $privateRun -ErrorAction Stop | Out-Null
$serverCache = Join-Path $privateRun 'server-cache'
New-Item -ItemType Directory -Path $serverCache -ErrorAction Stop | Out-Null
```

Keep these variables in that operator window. Do not reuse a production cache path or existing server name/cache pair. Backups and eventual diagnostic logs stay in this private directory, never GitHub.

## 2. Vanilla server bootstrap, performed by the human

Choose a verified vanilla Build 42.21 installation. The existing dedicated root on this machine is shown below; the operator must first resolve the agent/override environment hazards above or use a separately verified clean installation. Do not point at an unknown installation.

The one-off command below invokes only the game's EXISTING vanilla JRE/GameServer. It neither implements custom Java nor creates/changes a launcher, class or JAR. It avoids the inspected launcher files and carries both cache and profile arguments directly. Heap values are technical example limits; choose supported values for the disposable host and record them. No additional runtime library is required.

```powershell
$serverRoot = 'E:\Program Files (x86)\Steam\steamapps\common\Project Zomboid Dedicated Server'
if (!(Test-Path -LiteralPath (Join-Path $serverRoot 'jre64\bin\java.exe'))) { throw 'Verify server installation.' }
if (!(Test-Path -LiteralPath (Join-Path $serverRoot 'java\projectzomboid.jar'))) { throw 'Verify server JAR.' }
foreach ($optionName in @('_JAVA_OPTIONS','JAVA_TOOL_OPTIONS','JDK_JAVA_OPTIONS')) {
    if ([Environment]::GetEnvironmentVariable($optionName, 'Process')) {
        throw 'Review inherited JVM options in a separate clean environment; do not silently clear them.'
    }
}
# HUMAN LAUNCH ONLY, after the vanilla environment has been verified:
Push-Location -LiteralPath $serverRoot
try {
    & '.\jre64\bin\java.exe' '--enable-native-access=ALL-UNNAMED' `
        '--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED' `
        '-Djava.awt.headless=true' '-Dzomboid.steam=1' '-Dzomboid.znetlog=1' `
        '-XX:+UseZGC' '-Xms1g' '-Xmx4g' '-Djava.library.path=natives/' `
        '-cp' 'java/;java/projectzomboid.jar' 'zombie.network.GameServer' `
        '-servername' $testLabel "-cachedir=$serverCache"
} finally { Pop-Location }
```

Retained GameServer.java:644-645 parses cachedir; :808-820 parses servername. Actual invocation is NOT TESTED. At first startup verify the printed profile/cache/save locations belong ONLY to the new private run. Stop before anyone joins if arguments were ignored, the build differs, an agent/override loads, ports collide or any existing world is referenced. Supply any initial credentials only through the normal private interactive process; never command arguments, this repository or the evidence form.

This first bootstrap is vanilla, with no diagnostic or player joined. Gracefully stop it using its normal server console quit command and verify exit. Confirm it generated `Server/<testLabel>.ini` and `Server/<testLabel>_SandboxVars.lua` beneath the new cache; verify actual generated save/database paths there. Filename evidence: SandboxOptions.java:685-691. If paths differ, STOP and inspect the actual output; do not guess or edit another profile.

With the test server STOPPED, back up only this new private cache before installing the proof:

```powershell
$baselineBackup = Join-Path $privateRun 'baseline-cache-backup'
if (Test-Path -LiteralPath $baselineBackup) { throw 'Preserve existing backup; choose a fresh name.' }
Copy-Item -LiteralPath $serverCache -Destination $baselineBackup -Recurse -ErrorAction Stop
```

This backup may contain credentials; protect it locally. No deletes, cleanup or production-save migration are part of this procedure. Use fresh private caches for later ownership/fault sessions as well.

## 3. Install identical source manually

Stop both test clients before installing. This machine's verified client mod root is `C:\Users\willi\Zomboid\mods`; each operator must verify their own location. Never overwrite an ambiguous existing diagnostic folder. If it exists, back it up privately and compare source first; matching bytes need no replacement, mismatching/extra files require operator review. Do not alter any other mod.

For an EMPTY selected slot, human-only copy example:

```powershell
$sourceMod = 'C:\Users\willi\Desktop\Work\Project Zomboid\Mod Repositories\B47ANCEDActiveHours\proof\B47ANCEDActiveHoursSpeedProof'
$serverMod = Join-Path $serverCache 'mods\B47ANCEDActiveHoursSpeedProof'
if (Test-Path -LiteralPath $serverMod) { throw 'Review existing test mod; do not overlay.' }
New-Item -ItemType Directory -Path (Split-Path $serverMod -Parent) -Force | Out-Null
Copy-Item -LiteralPath $sourceMod -Destination $serverMod -Recurse -ErrorAction Stop
# On EACH client, using that client's verified mod root and a local source copy:
$clientMod = Join-Path $env:USERPROFILE 'Zomboid\mods\B47ANCEDActiveHoursSpeedProof'
if (Test-Path -LiteralPath $clientMod) { throw 'Back up and verify existing diagnostic slot first.' }
Copy-Item -LiteralPath $sourceMod -Destination $clientMod -Recurse -ErrorAction Stop
```

Preserve `common/` and `42/`; exact installed leaf is `B47ANCEDActiveHoursSpeedProof/42/mod.info`. No archive or Workshop item. Only this Mod ID is enabled. Production `B47ANCEDActiveHours`, Night and Day remain disabled, as do other gameplay/modification experiments. Do not clear another server profile's settings.

Compare relative paths and SHA-256 for every source/installed file on server/A/B, including mod.info and all three Lua files. Review any extra installed files. Example manifest helper (read-only):

```powershell
function Get-ProofManifest([string] $Root) {
    $base = (Resolve-Path -LiteralPath $Root).Path.TrimEnd('\')
    Get-ChildItem -LiteralPath $base -File -Recurse -Force | Sort-Object FullName | ForEach-Object {
        [pscustomobject]@{
            RelativePath = $_.FullName.Substring($base.Length + 1).Replace('\','/')
            SHA256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
        }
    }
}
$expected = Get-ProofManifest $sourceMod
$actual = Get-ProofManifest $serverMod # Repeat independently on client A/B.
Compare-Object $expected $actual -Property RelativePath,SHA256
```

No differences is the required source-byte check, not runtime success. Record the source commit and manifests privately.

In the STOPPED disposable server profile set `Mods=B47ANCEDActiveHoursSpeedProof`; do not add WorkshopItems for this proof. In its generated sandbox configuration set Zombie Lore Active Only to Both (`ZombieLore.ActiveOnly=1`). Record the vanilla Speed option; choose a genuine native Shambler baseline for the first transition, without runtime sandbox changes or a forced Set. Preserve the generated configuration format. If unable to identify these settings, stop rather than writing guessed schema. Keep this configuration unchanged through restoration.

The human now restarts the same disposable server with the same explicit arguments and starts/connects A and B normally. A must have native server admin role; B may be nonadmin. No player joins any production world. No split screen, reconnect, late join or server restart within a measured session. Loader errors stop the test.

## 4. Passive smoke checklist — no speed keys yet

Hold LEFT Ctrl + LEFT Shift for all controls. F6 selects; F11 dumps. Do not press F7/F8/F9/F10 during this stage.

1. On A and B press F11 before selection. Require a client-side diagnostic header at the current version. On A require a corresponding server-side dump; this exercises admin routing without a mutation. B's server Dump request is expected to be rejected while its LOCAL dump still works. Server reject counts can therefore rise without a speed failure. If nothing prints, stop for loader/key/role diagnosis.
2. Record that the shared table and side handlers initialized, inferred from their functioning versioned dumps. If an already available vanilla operator Lua evaluator is used, record that separately; do not add a debugger dependency or require one.
3. Prepare one EXISTING outdoor, standing, living zombie and keep it continuously loaded/relevant to both clients. Arrange that the next eligible update is the intended candidate; F6 is not a nearest-zombie selector. Press F6 once on admin A. Wait for native updates; no Set request.
4. Dump A, B and server after at least 60 selected callbacks. Require the same transient selected ID and explainable positions/category/walk/scalar. `speedRequests`, `accepted`, `writes`/`ownerWrites` and `observerWrites` must still be zero. A server ownerChanges value for initial assignment is expected. Negative IDs, death/crawl, wrong target, lost callbacks or missing samples end this attempt; never retarget a live session.
5. Require usable getters and one current native local owner: one client sample has localOwner=true/remote=false and the other is remote, with server owner presence consistent. Native observer scalar anomalies (for example 1000-like units) are NOT a reason to compensate with writes. Record them and stop mutation testing.
6. Verify no API errors, missing ack or server/current-owner STOP, no pending command, correct admin selection and no source/version mismatch. Keep baseline displacement/time, pursuit, pathfinding/lunge and animation evidence. If any prerequisite fails, preserve sanitized logs and mark subsequent stages NOT TESTED.

Exactly three prepared peers is a human precondition; the module does not implement a ready-count barrier. Do not mistake server initialization/acknowledgment for proof B is loaded and observing. Native state observations are not atomic across peers.

## 5. Fixed-speed, overwrite and restoration sequence

Record a wall-clock stage marker in the evidence form; ticks are local, not synchronized time. Lua revision on observer B may remain zero because only the simulation owner receives Apply. That alone is not stale replication: compare native fields/motion and stage timing, not observer Lua revision equality.

For EACH stage collect A/B/server dumps before, immediately after, then roughly every 10 seconds for at least 60 real-world seconds. Do not repeat Set to hold a value. Each dump preserves at most 16 samples and 16 result records.

| Stage | A's one action | Required observations on server, owner and observer |
|---|---|---|
| A: genuine Shambler -> Fast Shambler | F7 | Category 3 -> 2, requested walk/scalar, actual displacement/time, pursuit/pathfinding/lunge and coherent animation/remote movement |
| B: Fast Shambler -> Sprinter | F8 | Category 2 -> 1 AND actual sprinting; category/scalar alone is insufficient |
| C: Sprinter -> Shambler | F9 | Category 1 -> 3 AND walking recovery, no lingering sprint animation/abnormal pursuit |
| D: overwrite observation | No further Set during each 60-second interval | Drift/nativeMismatch and behavior over time; no continuous correction, independently assess observer discrepancies |
| E: connected restoration | F10 once | Original captured walk/category/scalar on owner/server/B AND original movement/animation/pursuit behavior |

OWNER_REPORTED means client acknowledgment, not native observer success. FIELDS_APPLIED means direct setter batch matched immediate getters, not measured sprinting. Compare nativeMatches/nativeMismatch and the actual trace. A successful field restore with altered movement is restoration FAILED. A rollback after a failed Restore returns to the pre-Restore state, not necessarily the original baseline. Never count replacement, restart, unload or disposal as restoration.

If server/current owner reports STOP, a pending/ack timeout, unusable API, unexpected mutation or divergent behavior, end further speed commands. Continue only F11/read-only collection. Do not clear flags, retry blindly or edit Lua to bypass a stop. Preserve the disposable cache/save after graceful exit; no automatic cleanup.

## 6. Ownership tests — separate private runs

Use a fresh disposable profile/cache for each ownership variant; use the same unchanged source/settings and passive checklist.

- **Idle transfer:** finish any prior command, confirm pending=false, then move A away/B nearer while retaining relevance/continuous loading. No new Set during the transition. Record server ownerChanges and A/B localOwner/remote/ownerPresent observations. A's owner-revoked guard may become invalid while it continues READ-ONLY sampling; that is expected. Server must remain valid and new B locally authorized. A may then issue one speed intent and one Restore, routed to B; only B's ownerWrites may increase. A remains the admin operator even when no longer owner. Do not hand back to A in this session.
- **Pending-transfer fault:** in another run, an operator deliberately overlaps one speed intent with transfer, without spamming or delaying native packets through external tools. Preserve the actual observed order; inability to produce overlap is NOT TESTED. Expect server owner-changed-pending/ack-owner-uncertain STOP if uncertainty is seen. A former client may still write locally before revocation arrives; the known race remains. No further mutations after STOP. Capture whether native server rejection and observer behavior prevent or propagate effects. Do not infer rejection solely from a rejected Lua acknowledgment.
- **Late acknowledgment / route failure:** only if naturally observed, record pending revision, deadline and missingAcks count. No blind resend or artificial server/network modification. Timeout stops later dispatch but cannot recall an in-flight command.

Lua does not expose a proven packet rejection counter here. If actual native rejection cannot be observed without unsupported instrumentation, mark it UNKNOWN/BLOCKED and keep the production race open. No Java helper or native interception. Do not invent a result from source inspection.

## 7. Evidence and interpretation

Use the blank form for every run; keep raw logs/backups/private addresses, credentials and player identifiers OUTSIDE the repository. Share only sanitized module records and relevant redacted engine errors. Vanilla command logs can contain personal/connection information even though module output does not. Label peers S/A/B, not usernames.

Runtime classifications are VERIFIED, PARTIALLY VERIFIED, FAILED, BLOCKED or NOT TESTED, supported by actual observations. Blank/incomplete stages remain NOT TESTED. Populate source/offline/runtime columns separately. Gates stay G2 BLOCKED, G6 NOT TESTED, G7 BLOCKED / NOT TESTED and G8 BLOCKED until corresponding evidence is reviewed. No gate advances from this runbook, source hashes, matching fields or green mocks.
