# Current validation

Current development version: 0.23.3-dev.1

Environment: Windows offline Lupa 2.6; Lua 5.1 for runtime source and host cases, Lua 5.4 only for the existing `package.searchpath`-based exclusion test. PZ/Kahlua/native transport is NOT TESTED. Local Steam manifest build 25485521 is installation evidence, not an executed game-version claim.

Commands from the repository root (use the verified Python interpreter on each machine):

```powershell
python -m pip install -r scripts/requirements.txt
python scripts/check_versions.py
python scripts/validate.py --experience-works <experienceWorks-repository-root>
python scripts/check_public.py --staged
git diff --cached --check
```

On this machine Python is `C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe`; bare `python` reaches a Windows Store alias. The exact local dependency argument is `..\experienceWorks`. Do not commit interpreter settings or copy dependency source into this repository.

[TESTED offline] The four initial focused regressions failed against imported runtime code: client hunger default initialization; missing clear-record path; unrestricted online-ID request lookup; obsolete online-ID retention. After correction, all 120 runtime Lua files compile and all 49 host cases pass (48 Lua 5.1, one Lua 5.4). New client ordering/lifecycle cases additionally cover pending clears, reassign/stale ordering, cache failure/retry, supported baseline restoration, native-ID checks, and no replication echo. The real local experienceWorks dependency was used for the research integration case; its broader runtime correctness is not certified.

CI runs `python scripts/check_public.py` and `python scripts/validate.py --unit-only` on Linux. It explicitly marks the research dependency integration NOT TESTED because experienceWorks does not yet have a declared public checkout here. The 48 remaining cases are host tests, not a Linux dedicated-server run. Action commits are pinned; token permission is contents:read, checkout credentials are not persisted, and there are no deploy/publish/remote-server steps.

Canonical versions pass across all declared current mirrors. `python scripts/check_versions.py --release` is expected to FAIL: this is a prerelease and no current package exists. Historical 0.23.2 ZIP and stale Contents remain classified historical, not regenerated. Version/static success does not override G7/G8.

G7: BLOCKED / NOT TESTED. Stable-release G8: BLOCKED. No current human SP, hosted, or dedicated proof exists for this iteration. The old partial experienceWorks 0.8.0 report is IN_PROGRESS and is not current dependency stage-1 approval. Follow AUTHORITY_REPLICATION.md and TESTER_HANDOFF.md after current dependency validation and separate game/server authorization.

Open limitations: food-provider consumption transaction (M-05), uncaptured locomotion baseline restoration, missing tooltips/real translations, native state/transport behavior, and high-population/failure stress evidence. No stable tag, package, deployment, Workshop upload, main merge, or game/server launch was performed.
