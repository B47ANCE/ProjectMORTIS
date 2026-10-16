Project Version: 0.1.0-dev.4

# Nightfall-style server-side speed experiment

Source: proof/B47ANCEDActiveHoursMortisProof/. Mod ID: B47ANCEDActiveHoursMortisProof. Requires ProjectMORTIS and experienceWorks; MORTIS API >=1.5.0/<2.0.0 plus typed acquire/release/authority functions. No Nightfall dependency or UV gameplay. The original proof/B47ANCEDActiveHoursSpeedProof/ and its instructions remain frozen at dev.3; do not enable both.

Admin intent selects exactly one living, standing zombie. The server binds its object and validates operator, server-run token, monotonic intent, getters, callback freshness and vanilla Active Only=Both before calling MORTIS acquire at priority 20. Release removes this diagnostic's request. Clients have no native setter, owner Apply or acknowledgment path. This removes that particular stale-client application path from this variant, without proving native propagation/overwrite or production safety.

No scans, spawning, retargeting, continuous correction, native activity toggle or sandbox write. Samples/results are bounded to 16 each, sampled every 60 selected callbacks and printed only by F11. Callback gaps, replacement and API/authority/framework errors stop future mutations without retry. No unload/reconnect/restart/persistence recovery or population claim. Helpers can randomize native derived state; no guaranteed emergency rollback is invented.

## Human-only procedure

1. Use a new disposable dedicated profile/cache/world, private stopped-world backup and verified vanilla Build 42.21 on S/A/B. The frozen original runbook's vanilla launch method and installed BAT argument/agent warnings still apply; its original mod selection/controls semantics are superseded here.
2. Manually copy the complete B47ANCEDActiveHoursMortisProof folder into each peer's verified mods directory, preserving common/ and 42/. Install/enable matching ProjectMORTIS and experienceWorks dependencies normally. Enable only this diagnostic and its dependencies, not Nightfall, the old proof or production Core/Night/Day. Compare source manifests; record dependency versions. Set Active Only=Both; record and leave vanilla Speed unchanged.
3. Connect A/B before selection; A is server admin. Hold LEFT Ctrl+LEFT Shift: F11 on both, F6 once on A, then F11 after samples. F6 selects the next eligible callback, not nearest. Require the intended outdoor standing continuously loaded zombie, matching ID, usable fields/motion and zero apiAccepted/clientWrites. Nonadmin B's server Dump rejection is expected. Stop for errors, STOP, scalar anomalies or wrong target.
4. Only after passive success and a genuine Shambler baseline, use F7 fastShambler, F8 sprinter and F9 shambler once each. Observe each for at least 60 real seconds without reapplying; F11 approximately every 10 seconds. Measure S/A/B movement, pursuit/pathfinding/lunge and animation, not category alone. Client Lua revision may remain zero; it is not a native packet revision.
5. F10 releases the MORTIS override once. Compare original/released walk, category, scalar and actual behavior. RELEASE_ACCEPTED means API acceptance only: MORTIS does not capture the original scalar or all helper state. Failed behavioral restoration remains FAILED; replacement/restart is not restoration.
6. Use a separate disposable session for idle native ownership transfer and one new server request. Require zero client writes; record actual owner/observer motion and overwrites. No compensating observer writes or reapply loops. Stop mutations on uncertainty/errors and preserve redacted logs.

## Evidence and validation

Privately record source commit/manifests, project/dependency/API versions, actual S/A/B builds, settings, selected ID, server session/intent, requested tier, F11 before/after/~10-second dumps, displacement/time, animation/pursuit, native owner transition, overwrite timing and release field/behavior results. Raw logs stay outside GitHub; share redacted S/A/B records only, without private connection/player identifiers.

API_ACCEPTED/RELEASE_ACCEPTED are not multiplayer success or native write counts. nativeMismatch is sampled category disagreement; clientWrites=0 covers this diagnostic, not native engine/dependency writes. Override signatures deduplicate API requests; they do not repair native overwrites. The old delayed-revocation test still documents the preserved dev.3 protocol, not a client handler in this variant.

Offline: python scripts/check_versions.py --root .; python scripts/test_check_versions.py; python scripts/test_mortis_speed_proof.py. Repeat the last with B47_PROOF_LUA=54. Development-only lupa; no Python at game runtime. scripts/test_speed_proof.py still tests the unchanged historical proof.

G2 BLOCKED (production); G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. No gate advances from these mocks or distribution. Publication still requires its own preflight.
