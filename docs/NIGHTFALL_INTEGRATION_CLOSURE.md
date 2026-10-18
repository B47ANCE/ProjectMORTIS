# Nightfall integration source closure

NF-M01 through NF-M04 are **SOURCE FIXED / OFFLINE REGRESSIONS PASS** in merged
[Nightfall PR #6](https://github.com/B47ANCE/ProjectNightfall/pull/6).
Native acceptance is still HUMAN / NOT TESTED. The original
[0.30.0 failing audit](NIGHTFALL_INTEGRATION_AUDIT.md), its input manifest and
reproduction script remain historical evidence; their old findings describe that
exact input and are not silently relabelled as passing.

| Finding | Corrected source contract | Evidence |
| --- | --- | --- |
| NF-M01 | Release only Nightfall movement requests/ceiling, verify canonical clear, then commit NORMAL; preserve foreign owners | Real MORTIS own/foreign/busy cleanup and production disabled-feral fragment |
| NF-M02 | Keep UV-release tracking on refusal and defer hibernation before knockdown; serialize the flag | Real busy release, serialized state and production transition fragment |
| NF-M03 | Check assignment compensation/readback; retain pending/uncertain recovery, block replacement and avoid projecting pending target phase | Real initial/typed compensation, reload, future/corrupt/conflicting state, readback failure and client refusal; production caller gates |
| NF-M04 | Require API 1.6/food v1 and report capability readiness separately from API presence | Real Knowledge guard SP/server/client/unknown cases and reported MP block |

[TESTED — offline Lua 5.1] The exact merged combination passes the three selected
Nightfall regression files: `test_mortis_recovery.lua`,
`test_mortis_lifecycle_recovery.lua`, `test_dependency_diagnostics.lua`.
MORTIS and Knowledge modules are real; zombie/native methods are modeled and
identified UV functions execute as source fragments. The full UV bootstrap,
other family providers and native storage/network execution are not certified.

Frozen merged inputs:

- MORTIS 0.26.0-dev.4: `f4ca76c99122f9d652325c5cda49bc14cfc2c02a`.
- Nightfall 0.30.1-dev.1: `5690021f6d6f5b87ba86e8c9964c527de6d168aa`.
- Knowledge 0.16.0: `6ba66c0d8f246d438f2e2f3c974fee9f77fdb426`.

The portable result is [nightfall-closure-merged-inputs.json](evidence/nightfall-closure-merged-inputs.json).
Its manifests pin 224 MORTIS runtime/authoring files, 159 Nightfall source/selected
test inputs and 120 Knowledge source/metadata files. Git-archive bytes are
intentional: line-ending differences fail exact verification. This is not an
installed mod list or a claim that a PR merge deployed content.

From this MORTIS checkout, reproduce the frozen result:

```text
python -B scripts/check_nightfall_integration.py --mortis <merged-MORTIS-snapshot> --mortis-evidence docs/evidence/mortis-f4ca76c-runtime.json --knowledge-and-wisdom <exact-Knowledge-snapshot> --nightfall <exact-Nightfall-snapshot>
```

Omit `--mortis` and `--mortis-evidence` to check the current development runtime
input instead. This executes pinned first-party Lua tests in isolated host VMs;
it is separate from [preflight](PREFLIGHT.md), which never executes Lua.
The dev.6 integration CI job runs this checker against exact pinned first-party
inputs as well as the full MORTIS suite; unit-only remains a separate job.
Exit 0 = scoped offline PASS; 1 = regression FAIL; 2 = input/tool ERROR.
Native file access in the selected fragment test is supplied by a read-only
string fixture for its one reviewed source file; no game or save is opened.

Source closure does not close Knowledge's intentional MP-storage implementation
block, native observer/owner/restoration, disk ordering, late join/reconnect,
save/reload/restart or whole-family startup gates. Follow Nightfall's
[recovery acceptance cases](https://github.com/B47ANCE/ProjectNightfall/blob/5690021f6d6f5b87ba86e8c9964c527de6d168aa/docs/MORTIS_RECOVERY.md)
only after the human clean-baseline and scoped dependency review. Keep Nightfall
excluded from creator/dependency baseline and isolated locomotion suites.
G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. No deployment/package/upload.
