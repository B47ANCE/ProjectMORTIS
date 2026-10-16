# Version inventory

At dev.4, runtime mirrors are proof/B47ANCEDActiveHoursMortisProof/42/mod.info and its shared B47AHMortisProof.lua version, plus MORTIS_SPEED_PROOF.md and TEAM_API_RESEARCH.md headers. Original dev.3 proof and ISOLATED_SPEED_PROOF/RUNTIME_TEST_RUNBOOK/RUNTIME_EVIDENCE_TEMPLATE are explicitly historical/unchanged, removed from current mirrors. Older inventory paragraphs below describe their recorded checkpoints, not the selected current payload.

Project Version: 0.1.0-dev.4

Root VERSION is the sole authority; version-inventory.json declares exact mirrors and selectors. Current mirrors must exist and contain one matching Project Version header:

- README.md
- docs/LUA_ONLY_API_AUDIT.md
- docs/LUA_SPEED_CONTROL.md
- docs/LUA_PROFILE_ARCHITECTURE.md
- docs/LUA_MULTIPLAYER_AUTHORITY.md
- docs/SOLAR_TRANSITION_DESIGN.md
- docs/LUA_ONE_ZOMBIE_POC.md
- docs/CONFIGURATION_GUIDE.md
- docs/PERFORMANCE_DESIGN.md
- docs/TEST_PLAN.md
- docs/RELEASE_BLOCKERS.md
- docs/VERSION_POLICY.md
- docs/VERSION_INVENTORY.md
- docs/REPOSITORY_GOVERNANCE.md
- docs/VALIDATION.md

CHANGELOG.md must have a nonempty newest entry matching VERSION. The inventory stores selectors, not a duplicate canonical value. Checker and tests read VERSION or use explicitly synthetic fixture versions, so no hardcoded project constant is required.

The isolated proof now has inventoried mod.info and Lua version mirrors; production modules still have no mod.info/constants. No Java component, package manifest, Workshop version text or generated staging exists. These are incomplete future mirrors, not silently validated or fabricated now. Add each exact source/generator/output selector when those files are authorized and created; all three module modversion fields will need the canonical full value. No live/staging files may be edited automatically.

Future release ZIP filename rule: dist/current/B47ANCEDActiveHours-{version}.zip. Missing archives are deferred in development and fail --release; no package is created. Embedded metadata and any additional artifacts must be inventoried before packaging/G8. The present rule does not prove future package contents.

Game builds, Java/tool/dependency versions, framework provenance and inventory schema are independent categories in other_versions. Historical audit documents and research artifacts retain original values, hashes and unassigned-version references. Current headers on mixed current/historical documents identify documentation applicability, not new evidence. Historical validation stays verbatim below the new milestone record.

Current documentation mirrors are complete. Absent future executable/release mirrors are separately deferred; this milestone does not advance G2, G6, G7 or G8.

Current isolated proof mirrors: docs/ISOLATED_SPEED_PROOF.md header, proof/B47ANCEDActiveHoursSpeedProof/42/mod.info modversion, and its shared B47AHProof.lua P.Version. Game minimum 42.21 is a game version, not a project mirror.

2026-10-14 readiness checkpoint: canonical/current mirror headers advance to 0.1.0-dev.3. Dated readiness/validation/version-decision entries that name dev.2/dev.3 record the actual evidence iteration and are historical, not extra canonical mirrors. Fixed helper examples and synthetic test versions remain independent. Current procedure references the header/root version.

Final runtime preparation adds current-version headers in docs/RUNTIME_TEST_RUNBOOK.md and docs/RUNTIME_EVIDENCE_TEMPLATE.md to the machine inventory. Filled evidence belongs outside the repository and retains its actually tested version. Canonical version remains unchanged for documentation-only preparation.

Custom thumbnail selection adds docs/BRANDING.md's exact Project Version header as a current mirror. Its preserved fallback authoring record retains 0.1.0-dev.2 as historical artwork provenance. Image bytes have SHA-256 provenance, not an independent project version. This artwork-only edit stays within the unreleased current checkpoint.
