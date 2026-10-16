# Version policy

Root `VERSION` is the only canonical project version. Legacy onboarding on 2026-10-16 adopted the existing 0.23.2 source version; it did not relabel old tests or packages. The user authorized GitHub onboarding and the subsequent authority/replication fix iteration.

Use SemVer: PATCH for compatible fixes, MINOR for additive public capability or provider contracts, MAJOR for incompatible contracts. Development iterations use a prerelease suffix. Public API 1.5.0, replication protocol, save/component schemas, game builds, and dependency versions are separate contracts and never substituted for the mod version.

Current mirrors checked by `scripts/check_versions.py`: source `mod.info` modversion; source `Mortis/init.lua` VERSION; source `info.txt` Version field; README Version field; master-roadmap canonical-version field; tester-handoff title; current changelog entry; AUTHORITY_REPLICATION development-iteration field; VALIDATION current-development-version field; the first Mod Version field in each Workshop description (`workshop.txt`, `WORKSHOP_DESCRIPTION.txt`, `docs/STEAM_WORKSHOP_DESCRIPTION.txt`); and the first Version heading in `WORKSHOP_CHANGE_NOTE.txt`.

`Contents/` is classified as a preserved stale 0.23.0 packaging copy, not a current version mirror. `dist/ProjectMORTIS-0.23.2-workshop-ready.zip` is immutable historical distribution, SHA-256 `59f966d82a46eeb618b10bcdf0dff1857f8c8c206e0cf25ee236d2dd3a915052`. Local staging backups, dated audit records, the historical checksum ledger, old changelog entries, and narrative descriptions of earlier features retain their original versions. They are not current runtime proof. No source or artifact is moved/deleted by this classification. No development package is current until explicitly built and inventoried.

Run `python scripts/check_versions.py` before/after every iteration. `--release` additionally requires a current-version ZIP, exact source hashes, CRC/path/duplicate/case checks, and stable version metadata. A static release check never grants G7/G8 PASS: dedicated gameplay G7 PASS and explicit stable release approval are still required for stable G8. Packaging, deploy, and Workshop publish need their own authorization.

Use feature branches and PRs after the imported baseline. Every intentional iteration includes docs, tests, targeted secret-reviewed staging, commit, push, and remote-SHA verification. No stable tags for unverified gameplay. Downgrading new persisted assignment-clear metadata is not certified; retain save backups and use disposable validation saves.

The 0.24.0-dev.1 pre-1.0 MINOR iteration changes the required dependency identity and load configuration. It intentionally replaces the old dependency contract while retaining MORTIS public API 1.5.0 and persisted/content identifiers. It is not a drop-in package for old mod lists.

The 0.24.0-dev.2 checkpoint adds an opt-in development diagnostic and consolidates Active Hours ownership within the unreleased 0.24.0 target. Existing gameplay/configuration/save/public API contracts are unchanged. The dormant harness is not an enabled production capability. The historical archive keeps its own frozen 0.1.0-dev.4 version and is never a MORTIS version mirror.
