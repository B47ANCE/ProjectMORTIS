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
