# Current validation

Current development version: 0.23.3-dev.2

Environment: Windows offline Lupa 2.6; Lua 5.1 for runtime source and most host cases, Lua 5.4 only for the existing package.searchpath-based exclusion test. PZ/Kahlua/native transport is NOT TESTED. Steam manifest build 25485521 and read-only native metadata are installation/source evidence; full executed game version remains UNKNOWN.

Commands from the repository root:

```powershell
python scripts/check_versions.py
python scripts/validate.py --unit-only
python scripts/validate.py --experience-works '..\experienceWorks'
python scripts/check_public.py --staged
git diff --cached --check
```

The exact verified interpreter here is `C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe`; bare python reaches the Store alias. Development requirements remain in scripts/requirements.txt.

[TESTED offline] All 121 runtime Lua files compile. Unit mode passes 51 cases (50 Lua 5.1 and one Lua 5.4), explicitly marking the research integration NOT TESTED. New locomotion regressions cover pre-write baseline checkpoints, readback and ignored setters, nil/nonfinite/missing inverse rejection, crawler false values, authority, component-table reload, preservation across reconciliation, retained originals through detach callbacks, failed checkpoint/restore retries, native busy deferral, old profiles without originals, canonical clear failure/retry, and scheduled post-detach recovery. The focused profile test failed before implementation; the internal snapshot service did not previously exist.

The full dependency command is BLOCKED, exit 1: the former local experienceWorks root/API is absent. The current B47ANCEDKnowledgeAndWisdom identity explicitly has no old global/import aliases, while MORTIS still declares/imports experienceWorks. This is a separate consumer migration requirement, not a passing integration test. The runner now reports the missing declared source as BLOCKED instead of producing a misleading generic module-not-found stack. It does not invent aliases or silently redirect the test.

Historical development iteration 0.23.3-dev.1 compiled 120 files and passed all 49 host cases against the then-present experienceWorks source. That result remains tied to that earlier environment and is not current dependency proof.

CI runs `python scripts/check_public.py` and `python scripts/validate.py --unit-only` on Linux with pinned actions, read-only permissions, and no retained checkout credential. Its 51 passing host cases and explicit integration omission do not prove Linux dedicated behavior. No pipeline deploys, publishes, launches a game/server, or changes remote servers.

Canonical versions must pass all 13 current mirrors. `python scripts/check_versions.py --release` remains expected FAIL: development prerelease, no current package. Historical ZIP/Contents are preserved. Staged whitespace and bounded public-file secret/artifact checks are required before push.

G7 BLOCKED / NOT TESTED. Stable G8 BLOCKED. No current human SP/hosted/dedicated proof exists. See LOCOMOTION_RESTORATION.md for source hashes, observed-field scope, legacy handling, native/API uncertainties, and disposable fixture/reconnect/restart scenarios. Unobserved animation/lunge bookkeeping, external consumer override-stack persistence, food transactions, translations, and dependency migration remain open. No main merge, stable tag, packaging, deployment, publication, or game/server launch is part of this iteration.
