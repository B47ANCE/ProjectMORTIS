# Version policy

Root `VERSION` is the only canonical project version. Legacy onboarding on 2026-10-16 adopted the existing 0.23.2 source version; it did not relabel old tests or packages. The user authorized GitHub onboarding and the subsequent authority/replication fix iteration.

Use SemVer: PATCH for compatible fixes, MINOR for additive public capability or provider contracts, MAJOR for incompatible contracts. Development iterations use a prerelease suffix. Public API 1.6.0, replication protocol, save/component schemas, game builds, and dependency versions are separate contracts and never substituted for the mod version.

Current mirrors checked by `scripts/check_versions.py`: source `mod.info` modversion; source `Mortis/init.lua` VERSION; source `info.txt` Version field; README Version field; master-roadmap canonical-version field; tester-handoff title; current changelog entry; AUTHORITY_REPLICATION development-iteration field; VALIDATION current-development-version field; the first Mod Version field in each Workshop description (`workshop.txt`, `WORKSHOP_DESCRIPTION.txt`, `docs/STEAM_WORKSHOP_DESCRIPTION.txt`); the first Version heading in `WORKSHOP_CHANGE_NOTE.txt`; and the version fields in
`docs/MOD_OVERVIEW.json` and `docs/evidence/mortis-runtime-input.json` (15 mirrors).

`Contents/` is classified as a preserved stale 0.23.0 packaging copy, not a current version mirror. `dist/ProjectMORTIS-0.23.2-workshop-ready.zip` is immutable historical distribution, SHA-256 `59f966d82a46eeb618b10bcdf0dff1857f8c8c206e0cf25ee236d2dd3a915052`. Local staging backups, dated audit records, the historical checksum ledger, old changelog entries, and narrative descriptions of earlier features retain their original versions. They are not current runtime proof. No source or artifact is moved/deleted by this classification. No development package is current until explicitly built and inventoried.

Run `python scripts/check_versions.py` before/after every iteration. `--release` additionally requires a current-version ZIP, exact source hashes, CRC/path/duplicate/case checks, and stable version metadata. A static release check never grants G7/G8 PASS: dedicated gameplay G7 PASS and explicit stable release approval are still required for stable G8. Packaging, deploy, and Workshop publish need their own authorization.

Use feature branches and PRs after the imported baseline. Every intentional iteration includes docs, tests, targeted secret-reviewed staging, commit, push, and remote-SHA verification. No stable tags for unverified gameplay. Downgrading new persisted assignment-clear metadata is not certified; retain save backups and use disposable validation saves.

The 0.24.0-dev.1 pre-1.0 MINOR iteration changes the required dependency identity and load configuration. It intentionally replaces the old dependency contract while retaining MORTIS public API 1.5.0 and persisted/content identifiers. It is not a drop-in package for old mod lists.

The 0.24.0-dev.2 checkpoint adds an opt-in development diagnostic and consolidates Active Hours ownership within the unreleased 0.24.0 target. Existing gameplay/configuration/save/public API contracts are unchanged. The dormant harness is not an enabled production capability. The historical archive keeps its own frozen 0.1.0-dev.4 version and is never a MORTIS version mirror.

The 0.25.0-dev.1 MINOR iteration adds the API 1.6.0 transactional provider contract. Registration/discovery of legacy providers remains available, but unsafe one-step automatic consumption is refused until migration. This compatibility limitation is deliberate and documented; public capability negotiation can require FoodSources.TRANSACTION_VERSION. Historical API/version records remain unchanged.

The later 2026-10-16 clarification in PR #4 supersedes exclusive Active Hours ownership: the standalone mod remains maintained and yields execution when MORTIS is enabled. The 0.25.0-dev.2 checkpoint preserves that policy while applying compatible feeding/input corrections, English tooltips and an offline-only design experiment within the unreleased 0.25.0 target. Public API remains 1.6.0. The experiment is not a final runtime validator, new setting, persisted schema or production capability.

The 0.25.0-dev.3 compatible fix checkpoint remains within the unreleased 0.25.0 target. API 1.6.0 stays unchanged. The additive internal Mortis.LocomotionOverrideBaseline save component uses schema/record version 1; existing component schemas and replication protocol do not change. Unsafe/unobservable overrides now refuse, and lost owner stacks require coordinated clear rather than implicit re-enrollment. Native disk compatibility, downgrade and full restoration are unverified; historical active overrides have no recoverable original journal.

The 0.25.0-dev.4 documentation/metadata checkpoint prepares the user-requested native test handoff and records the separately implemented Nightfall transaction adapter. It preserves the unreleased 0.25.0 target, API 1.6.0, saved schemas, replication protocol and gameplay. Earlier validation blocks remain historical; no native result is promoted.

0.26.0-dev.1 is an additive development MINOR for the main-menu local zombie-definition editor. Public gameplay API remains 1.6.0; world/component/network schemas and runtime policy are unchanged. Creator draft/library version 1 is a separate local authoring format, never a world migration. Existing packages and validation records remain historical.

0.26.0-dev.2 is a compatible authoring/test/documentation checkpoint within the unreleased 0.26.0 target. Runtime changes are version mirrors only; API 1.6.0, creator draft format 1, world/component/network schemas and gameplay are unchanged. Life-choice version 1 is an isolated experimental record, not a registered persistence schema. Fixtures and experiments remain outside runtime/package roots.

0.26.0-dev.3 is a compatible human-test preflight and consumer-fixture checkpoint.
The selected test dependency is 0.16.0; its intentional MP refusal is not bypassed
and its version is separate from MORTIS. Runtime changes remain version mirrors
only; public API 1.6.0, creator format and world/component/network schemas are
unchanged. New source-only engine fingerprints do not establish runtime evidence.

0.26.0-dev.4 is a compatible tooling/design checkpoint within unreleased 0.26.0.
Runtime differences remain version mirrors only; API 1.6.0 and all runtime/save/
network schemas are unchanged. The offline AHC1 selection-key format is not a
production contract. Reviewed overview and exact runtime-input evidence become
current mirrors; historical records retain their original versions.

0.26.0-dev.5 is a compatible integration/tooling/design checkpoint within the
unreleased 0.26.0 target. Runtime source differences are version mirrors only;
API 1.6.0, creator/world/network schemas are unchanged. Ownership-model record
version 1 is experimental and unregistered. Frozen merged MORTIS dev.4 input,
Nightfall manifests and combined closure records are historical scoped evidence,
not current MORTIS version mirrors or native proof.

0.26.0-dev.6 is a compatible tooling/audit/model-fix checkpoint within the
unreleased 0.26.0 target. Runtime changes remain three version mirrors only;
API 1.6.0, creator/world/network schemas and experimental ownership format 1
are unchanged. Human-result JSON schema 1 is an offline review format, not a
runtime save schema or automated acceptance contract. Prior validation remains
historical; the API audit grants no runtime evidence.

0.26.0-dev.7 is a compatible artwork-only checkpoint within unreleased 0.26.0.
The owner-supplied thumbnail replaces the current authoring PNGs; previous Git
artwork and immutable packages/publication records retain their original bytes.
Runtime changes are version mirrors only; public API and save/network schemas
are unchanged. The initial dev.7 asset checkpoint declared no package/upload;
its subsequent publication is recorded separately in the immutable receipt.

0.26.0-dev.8 is a compatible supplied-artwork revision within the unreleased
0.26.0 target. Only branding exports, version mirrors and their evidence change;
API 1.6.0, local creator format and world/network schemas stay unchanged. The
dev.7 publication receipt remains historical and exact. New upload requires a
separate publish request; this asset change grants no native acceptance.

0.26.0-dev.9 is a compatible hunger scheduling/time-accounting fix within the existing MINOR prerelease. Additive server budget and internal Engine diagnostics; public gameplay API 1.6.0, food transaction version, component schemas and replication protocol stay unchanged. The optional settleForFeeding argument to hunger advance is used by trusted meal paths; existing calls retain hourly batching. No stable tag or artifact rebuild.

The authorized 0.26.0-dev.9 MP-test publication preparation keeps the existing version because no runtime/schema changes or immutable package for this iteration precede it. Current metadata mirrors remain synchronized; historical artifacts are not rewritten. Packaging/metadata changes and exact upload evidence are recorded separately. No stable tag or G7/G8 PASS is implied.
