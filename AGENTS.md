# Project Zomboid Codex startup

<!-- PZ-CODEX-MANAGED-STARTUP -->
Read the current global rules at %USERPROFILE%/.codex/AGENTS.md before work.
Team skills are installed at %USERPROFILE%/.agents/skills.
Preserve project-specific identity, instructions, source, local settings and runtime evidence.
<!-- /PZ-CODEX-MANAGED-STARTUP -->

## MORTIS project guidance

- Read `README.md`, `docs/MASTER_ROADMAP.md`, and `TESTER_HANDOFF.md` before selecting work. MORTIS is a neutral framework; consumers own archetypes, gameplay policy, and content. Project Remnants integration is prohibited.
- Authoritative runtime source: `src/ProjectMORTIS/42/`. `Contents/mods/ProjectMORTIS/42/` is a preserved packaging copy. Preserve `dist/`, staging backups, Workshop metadata, artwork, and historical evidence. Do not synchronize or rebuild packages during an audit.
- Root `VERSION` is canonical; public API 1.6.0 is separate. Read `docs/VERSION_POLICY.md` and `SOURCE_INVENTORY.json`; run `scripts/check_versions.py` before/after edits. Preserve historical packages and audit evidence.
- The user authorized public B47ANCE/ProjectMORTIS onboarding, canonical versioning, and authority/replication fixes on 2026-10-16. Run the shared freshness check each session and before commit/push. Work on feature branches with PRs; no deployment, packaging, game/server launch, Workshop upload, or stable tag is authorized by this task.
- Use the canonical `%USERPROFILE%/.agents/skills` store directly. The legacy project `.agents` junction reaches an empty workspace skill directory; it is not the installed skill store. Preserve shared junctions and `.codex/config.toml`; do not run broad setup scripts to alter unrelated projects or global settings.
- Skill routing: `pz-repository-startup` for freshness; `pz-repository-governance` for legacy onboarding/version/provenance; `pz-repository-hygiene` for inventories; `pz-debug-root-cause` for defects; `pz-api-audit` for vanilla APIs; `pz-mp-audit` for authority and networking; `pz-persistence-and-migration` for save/schema changes; `pz-build42-compatibility` for game updates. Use asset, release, deploy, and publish skills only within their authorized scopes.
- Runtime remains Lua-only. Server authority owns shared state and server sandbox settings. Validate malformed/replayed/stale requests, ID reuse, late joins, reconnects, save/load, and dedicated restarts. Technical request limits stay internal; meaningful gameplay settings use sandbox options.
- One production writer. Scout/auditor/reviewer roles inspect only when delegation is explicitly requested; this file does not request automatic agents. Skills' `agents/openai.yaml` metadata remains in the global store.
- Existing host regressions are `tests/test_*.lua`; some require a source-file argument. The dated audit runner records its exact mappings and runtime. Host Lua tests do not prove Kahlua/native PZ behavior. Dependency stage 1 must be reviewed PASS before MORTIS stage 2; missing dedicated evidence means G7 BLOCKED / NOT TESTED and stable G8 BLOCKED.
- Current behavior and evidence: `docs/AUTHORITY_REPLICATION.md`, `docs/VALIDATION.md`, and `docs/ONBOARDING.md`. The dated local takeover audit remains historical under ignored `docs/audits/`; do not rerun it to overwrite baseline evidence or publish local diagnostic snapshots.


## Active Hours ownership exception

The user clarified on 2026-10-16 that Active Hours remains maintained standalone while MORTIS includes its complete feature scope (prototype, solar, profiles, weighted selection, configuration and performance requirements). The two implementations are incompatible: standalone Active Hours must disable its own execution whenever ProjectMORTIS is enabled, so MORTIS takes precedence. Neither implementation requires the other. Do not retire/freeze the standalone project or disable MORTIS in response to the independent Core Mod ID B47ANCEDActiveHours. Keep neutral defaults and no new archetypes. `docs/ACTIVE_HOURS.md` controls current scope: an explicitly started internal diagnostic only; production policy remains gated. `archive/active-hours-0.1.0-dev.4/` is immutable historical source, never active runtime, current version mirrors, packaging input or governing instructions. Preserve its 64-file import manifest and original native evidence in the source repository. Old standalone Workshop/repository identities remain unchanged; absorption does not authorize upload, deletion, deploy or launch.

## Main-menu creator boundary

The 0.26.0-dev.1 creator is client-only local content authoring; see docs/ZOMBIE_CREATOR.md. Never evaluate drafts, auto-load exported Lua, install packages, register live types, add a server import command or mutate a world from this UI. Preserve fixed local filenames, alternate/checksummed checkpoints, stale/future/corrupt-data refusal, exported string quoting and duplicate/provider checks. Editor fields are draft content baselines; consumer/server authority and sandbox rules still govern activated gameplay. Native menu/file/controller proof remains open.
