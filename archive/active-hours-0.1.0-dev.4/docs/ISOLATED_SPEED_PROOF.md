Project Version: 0.1.0-dev.3

# Isolated Lua speed experiment

Prepared source only. Actual PZ invocation, loader compatibility and dedicated multiplayer are NOT TESTED. G2 BLOCKED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. No automatic installation, launch or Workshop upload.

Authoritative source: `proof/B47ANCEDActiveHoursSpeedProof/`. The diagnostic Mod ID `B47ANCEDActiveHoursSpeedProof` deliberately differs from production Core `B47ANCEDActiveHours`; do not enable Night/Day/Core production modules for this experiment. No Java/JAR dependency. Target is 42.21. Current readiness checkpoint is recorded in VERSION within the existing 0.1.0 prerelease scope, not a stable release.

## What this actually changes

[VERIFIED source] IsoZombie setters change walk type, derive native category and set the movement scalar. Mapping is Sprinter=1, Fast Shambler=2, Shambler=3 (`research/jar-source/zombie/characters/IsoZombie.java:3371-3389`). Use `sprint1`, `1`, `slow1` respectively. Scalar getter/setter: IsoGameCharacter.java:3771-3776. Full helpers doSprinter/doFastShambler/doShambler remain audited alternatives but are NOT called: they reroll scalar/animation state and can change lunger/turn delta.

The proof uses fixed nominal scalar targets 0.90/0.90/0.60 and a fixed recognized walk variant within each category. These are internal experiment inputs, not production balance options; they lie within native helper random ranges. They do not promise full native helper equivalence. Native running/lunge/pathfinding can still behave differently; a Sprinter category may trigger native walking speed behavior independent of scalar. No solar/distributions/other attributes, sprite mutation, direct instance-field access, native activity call or sandbox write. Future configurable gameplay needs server sandbox options and localization; this operator-only diagnostic has no production settings/UI.

Restoration captures the server's original scalar/walk/category before the first request, validates agreement with the owner immediately before writing, and restores those same fields using the matching setters. A partial setter failure attempts one rollback to the owner's pre-command snapshot and freezes the experiment. No category reroll. This is controlled field restoration, not verified recovery of every subsequent native running/animation side effect. Connected behavior restoration must be tested and must fail if pursuit/animation/movement diverges despite matching fields.

## Authority and ordering

The admin client submits Select/Set/Restore intent. The server validates admin role, ActiveOnly=Both, one bound zombie, scalar/category, current owner player and pending state. Native Lua player-targeted server commands carry flat primitive arguments. Only enrollment Arm is broadcast; observer clients never receive a mutation command. Local owner checks require a bound object, matching ID/session/revision, fresh native update, alive/noncrawler, nonremote state, and a nonnil native owner player whose isLocalPlayer is true. Server accepts an acknowledgment only from its current owner player and pending revision. No server speed write, custom packet or observer correction.

[VERIFIED source] Server send wrapper: LuaManager$GlobalObject.java:5180-5184; missing routes silently return at GameServer.java:3530-3539. Server native packet sender validation: NetworkZombiePacker.java:100-111. Observer receives native fields through NetworkZombieAI.java:295-301; source scalar-unit discrepancy remains unresolved. Ack is an owner report, not native propagation proof. Server nativeMatches/nativeMismatch samples are separate evidence.

[UNKNOWN / RUNTIME GATE] Independent command and authorization streams are not globally atomic. A delayed revocation can leave a former client locally authorized long enough to write before it learns the new owner. An offline fault test reproduces this local write while the server rejects its stale acknowledgment. Native sender checks should reject its shared locomotion input, but dedicated observation is required. Do not call handoff safe from the mocks. This is isolated experimental code, not an approved production authority architecture.

Each peer binds one object from OnZombieUpdate, not a population scan. Reference replacement, death/crawling or callback gap >300 OnTick calls invalidates that peer. The prototype accepts only nonnegative short IDs; negative native IDs are deliberately out of this bounded test. A local reference plus epoch/revision is not persistent identity. No retarget, reconnect, restart, save persistence or late-join recovery; all peers must connect before selection and stay loaded. A missing route/ack leaves the server pending; after 300 server OnTick calls its missingAcks counter increments once and the server freezes future mutation dispatch. The deadline does not recall an already in-flight command; do not blindly retry or reset to bypass it. An invalidated experiment may refuse restoration: record failure and stop the isolated session, not a restoration PASS.

## Manual installation

Use a disposable dedicated test profile/save and record backups yourself. Do not use an active player world. On this machine the verified local client mod directory is `C:\Users\willi\Zomboid\mods`; teammates/server operators must verify their own paths.

1. Manually copy the entire source folder `proof/B47ANCEDActiveHoursSpeedProof` into each client's and the dedicated server's verified local `Zomboid/mods` directory. Preserve both `common/` and `42/`; resulting path ends `mods/B47ANCEDActiveHoursSpeedProof/42/mod.info`. This is source installation, not a packaged release. No copy was performed by Codex.
2. Enable only this diagnostic Mod ID in the disposable server profile's Mods setting. No Workshop ID is assigned; no WorkshopItems addition or publication. All three peers need the same files/version. Build-42 local-mod layout/load remains a runtime gate; if it does not load, stop and supply the actual logs instead of changing game files.
3. Set vanilla Zombie Lore Active Only to Both through the server's normal configuration before launch. Read-only check expects `SandboxVars.ZombieLore.ActiveOnly == 1` (GameTime.java:1291). Keep this unchanged throughout restoration. Record vanilla Speed option; do not silently change it to make a failing test pass.
4. Human operator launches server and two clients. One player per client, no split screen. Client A has admin role; B may be a normal player. Keep both present/relevant. Use one existing, outdoor, standing zombie that remains loaded and alive. No spawning/replacing/culling is implemented by this module.
5. Startup should define `B47AHProof` on each side. If getters/events/admin access do not work, stop and record NOT TESTED/FAIL with source version and logs. Diagnostics remain technical English console records; no production menu/translation set is shipped.

## Operator controls and selection

Hold **left Ctrl + left Shift**, then:

| Key | Action |
|---|---|
| F6 | Admin A captures the next usable native zombie-update candidate, once; no mutation. |
| F7 | Admin requests FastShambler. |
| F8 | Admin requests Sprinter. |
| F9 | Admin requests Shambler. |
| F10 | Admin requests restoration of the original captured fields. |
| F11 | Prints bounded local samples/counters; admin also requests server dump. B prints only local dump. |

These diagnostic keys do not require a Lua console. Keyboard is exposed (`LuaManager$Exposer.java:2636`); vanilla uses OnKeyPressed and isKeyDown. Actual hotkey handling remains NOT TESTED. Where an existing operator Lua executor is available, equivalent functions are `B47AHProof.captureNext()`, `select(id)`, `set("FastShambler")`, `set("Sprinter")`, `set("Shambler")`, `restore()`, `dump()`.

F6 does not find a zombie by screen position: it consumes the next usable update. Establish an environment where that is the intended single zombie, then confirm candidate ID and sampled coordinates/behavior on all peers before any Set. If another zombie was selected, stop this session; no live retargeting. Wait for at least 60 selected callbacks and dump each side. ID, category, walk/scalar, remote/owner status and motion must be explainable before mutation. Scalar 1000-like anomalies are recorded, but mutation rejects snapshots outside (0,10). Do not compensate for native packet asymmetry with observer writes.

## Required dedicated matrix

Perform each step only with complete baseline records and no pending/invalid state. Dump every peer and server before/after; observer B writes must remain zero. Counters are accumulated without per-frame logging; samples every 60 selected callbacks, ring capacity 16. Dump approximately every 10 seconds while observing to preserve coverage. Record actual elapsed time separately; OnTick is not synchronized wall time. Read-only samples continue after a mutation freeze so the operator can preserve evidence.

1. **Baseline:** standing/idle, unobstructed pursuit, obstacle/pathfinding and lunge. Compare category/scalar/walk, animation and displacement/time. No mutation yet. Scalar discrepancies or getter errors stop mutation.
2. **Shambler -> Fast Shambler:** require initial native category 3. F7, wait for acknowledgment AND native server/observer evidence, then repeat all movement states. If initial category is not Shambler, do not force it to fabricate this baseline; start a separate suitable test session.
3. **Fast Shambler -> Sprinter:** F8, observe the same states. Category 1 alone is insufficient: verify movement and animation, including global-Speed pathfinding conflicts.
4. **Sprinter -> Shambler:** F9. Confirm category 3 and slower actual pursuit. Observe whether running/lunge behavior recovers naturally. Do not use native activity toggles as a refresh.
5. **Overwrite observation:** leave each requested speed for at least 60 human-measured seconds; trigger no repeated Set. Owner drift and server nativeMismatch counters can rise; source code never repairs them. Compare walk/scalar/category and motion. Native observer differences are not automatically owner overwrites; correlate sides and timestamps.
6. **Ownership transfer:** finish any pending command first. Move A away and B nearer while retaining both clients' relevance and the zombie's loaded state. Wait for native owner change records and local authorization to agree. A requests the next speed; only B may increment writes. A must stop writing. After observed revocation its local mutation guard remains frozen (reason owner-revoked), while it can still collect observer samples and submit admin intent to the server for B. Do not hand ownership back to A within this session. Test delayed pending intent separately and fail if stale application/acceptance or divergent motion occurs. A server-side owner-changed-pending or ack-owner-uncertain stop ends all further mutations; do not try to resume by pressing a new speed key. The offline delayed-revocation finding makes this an explicit G2 blocker, not an assumed success.
7. **Connected restoration:** keep all three peers connected and the same object loaded. F10 from admin A (route goes to current owner, including B after transfer). Owner restores original scalar/walk/category; compare immediate snapshot, native server and observer after propagation, then pursuit/pathfinding/lunge behavior. Record both field restoration and behavioral recovery. A matching category with altered animation/movement is FAIL. Shutdown, zombie disposal or replacement is not restoration evidence.

Record version/commit/file hashes, exact peer game builds/effective environment, vanilla settings, initial/after/restored samples, counters, ownership sequence, elapsed times, movement videos/measurements and errors. Never log usernames or connection contents. A server/current-owner missing ack, reference/gap invalidation, API exception, uncertain owner, unexpected speed or recovery failure ends mutation testing; preserve evidence rather than bypass guards.

## Offline evidence

From repository root:

```powershell
python scripts/check_versions.py --root .
python scripts/test_check_versions.py
python scripts/test_speed_proof.py
```

Development-only `lupa` is required for the third command; it is not a runtime mod dependency. The bundled Python used here has lupa 2.6. The default harness uses its Lua 5.1 engine; set B47_PROOF_LUA=54 for a second Lua 5.4 pass. Thirty-six tests execute the actual Lua sources in three independent mocked Lua environments: fixed transitions, restore, observer nonwrites, owner transfer, stale/duplicate commands, nonadmin/malformed input, Both conflict, setter failure rollback, scalar anomaly, native drift without reapply, object reuse/gap, flat payloads, duplicate registration and operator controls. The delayed-authorization test explicitly records a former owner's possible local write; the test passing does NOT mean handoff safe. Lua 5.1/5.4 parser/mocks are not Kahlua/PZ or native network validation. No multiplayer result is claimed.

## Readiness fixes and result collection

[TESTED offline] The transport mock now reproduces native empty-table omission. Old Restore/Dump commands could arrive as nil and be rejected; all client requests now include session epoch. Mutation intents also carry monotonic operator intent IDs, and only the selecting admin can issue them. The server consumes each intent once and sends monotonic apply revisions; clients reject duplicate/stale revisions. A malformed walk/category pair can no longer pass nil equality. No new runtime dependency.

[VERIFIED source] Empty-table omission: retained GameClient.java:1897; receiveClientCommand initializes args to null at GameServer.java:2357 and only loads a table when hasArgs. Kahlua itself has not executed this fix.

| Readiness item | Assessment before human launch |
|---|---|
| Build 42 structure, Lua placement, Mod ID, require case | STATIC PASS: common/ and 42/mod.info, shared/client/server Lua; actual loader NOT TESTED. |
| Lua syntax / Kahlua | Lua 5.1 and 5.4 offline PASS; Kahlua NOT TESTED. |
| Events / keyboard / exposed native calls | Source-supported; mocked registration, modifier guards and reload deduplication PASS; PZ invocation NOT TESTED. |
| Server validation / client handling / ownership guards | Offline PASS, including session/intent/revision and native-style nil args. Distributed authority race remains BLOCKED for production. |
| Restoration / error handling | Direct fields and one-shot rollback PASS offline; failed restore stays stopped. Behavioral restoration NOT TESTED. |
| Version consistency | PASS at the header version; all peers must install identical source. |

Keep the exact manual installation steps above. Use this machine's verified repository path `C:\Users\willi\Desktop\Work\Project Zomboid\Mod Repositories\B47ANCEDActiveHours` as source; the older `Desktop\Repositories` handoff path is absent. Do not create a second checkout or overwrite an old install automatically. The human copies the entire diagnostic folder only, preserving common/ and 42/. Keep production modules, other experiments and custom game patches out of the disposable test. Verify exact Build 42.21 on server and both clients and record effective-class provenance; the local earlier loose-class drift means the inspected main JAR alone is not pristine runtime proof. Existing artwork is preserved.

Use a NEW disposable server profile, not an existing production profile: Mods=B47ANCEDActiveHoursSpeedProof; no new WorkshopItems value, no publication. The operator verifies each machine's actual Zomboid/mods location, copies source manually and launches manually. No scripts here copy, launch or alter saves. Connect A and B before F6. Grant A its server admin role; B need not be admin. If F6/hotkeys or native methods fail, dump logs and stop; do not weaken the server role or owner checks.

Counters have these meanings: requests counts received Set/Restore intents, speedRequests counts Set only, accepted counts validated dispatch/application attempts, ownerWrites/writes counts successful local-owner setter batches, observerWrites is this module's observer write count (must remain zero), observerRejected counts guard refusals, drift counts owner snapshots differing from expected fields, nativeMatches/nativeMismatch are server samples versus owner-reported intent. restorationAttempts/failures include rejected, failed and timed-out restore requests. ownerChanges, staleCommands, duplicates, missingAcks, apiErrors and errors provide failure coverage. None measures native DoZombieStats invocation count; no unsupported hook is invented. Values describe module observations, not total engine/mod behavior.

F11 emits a header plus up to 16 samples and 16 result records, only on operator request. Each record labels local session/revision/tick, request/observation and result such as DISPATCH, OWNER_REPORTED, FIELDS_APPLIED, REJECTED or STOP. OWNER_REPORTED is not observer replication evidence. Raw exception/connection contents are not emitted. Vanilla server command logging may separately contain player/connection identifiers; redact those before sharing any logs.

For each fixed transition run the existing pursuit/pathfinding/lunge checks, wait 60 human-measured seconds WITHOUT repeated Set, and dump at approximately 10-second intervals to preserve the bounded ring. Record a video/position-time measurement; a category or scalar difference alone does not prove sprinting. Restore at the end while continuously loaded and connected; if field restoration succeeds but movement/animation fails, mark restoration FAILED. No attempt to force activity, respawn the target or restart the session counts as recovery.

For ownership tests use a separate disposable session after baseline speed tests. First transfer only with pending=false and no new request. Wait for server ownerChanges and A/B native localOwner/remote observations; old A remains read-only, new B must be locally authorized, server must not be invalid. Then A may submit one speed/restore intent routed to B. A transfer with a request in flight is a separate fault test: expect server STOP, no further dispatch and possible delayed old-owner local write. Native packet rejection/observer effects must be recorded, not assumed. An acknowledgment deadline similarly cannot revoke a command already delivered or in flight.

| Capability | Runtime classification before this experiment |
|---|---|
| Fixed speed switching / actual sprinting | NOT TESTED |
| Native persistence without overwrite | NOT TESTED |
| Owner-only application | NOT TESTED; guards pass mocks, delayed native revocation remains a known limitation |
| Observer locomotion replication | NOT TESTED |
| Ownership transfer safety | BLOCKED for production; experimental investigation allowed |
| Connected behavioral restoration | NOT TESTED |
| Successful Build 42.21 / Kahlua execution | NOT TESTED |

Next milestone: human-operated load/API/admin/hotkey and passive-baseline smoke test on all three peers, followed only if that passes by the fixed transitions and 60-second overwrite/restoration matrix. Keep the separate ownership fault experiment and production G2 decision pending real evidence. G2/G6/G7/G8 remain unchanged.

## Final operator handoff

Use RUNTIME_TEST_RUNBOOK.md for the complete disposable setup/backup/passive-first sequence and launcher hazards; use RUNTIME_EVIDENCE_TEMPLATE.md privately for observations. These supplement this existing experiment, without source or version changes. No test has been executed by the handoff.
