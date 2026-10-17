# Knowledge dependency migration

The initial MORTIS 0.24.0-dev.1 migration selected Mod ID `B47ANCEDKnowledgeAndWisdom`, tested offline against dependency 0.13.0. The old `experienceWorks` public global/imports are not aliases. MORTIS previously failed to load its research and history modules after that dependency rename; the actual-source history regression reproduced the old `experienceWorks/HistoryRecords` module-not-found failure before the fix.

## Consumer contract

`mod.info`, source inventory, current authoring metadata, research registration, history-evidence imports, the debug harness and current test instructions now select the same canonical identity. Imports are `B47ANCEDKnowledgeAndWisdom/API` and `B47ANCEDKnowledgeAndWisdom/HistoryRecords`; the harness checks the canonical global. The runner accepts `--knowledge-and-wisdom <repository-root>` and uses `src/B47ANCEDKnowledgeAndWisdom/42/media/lua/shared` with exact case. The former `--experience-works` developer option is removed.

This is a pre-1.0 MINOR dependency/configuration migration. MORTIS API 1.5.0, replication protocol 2 and component schemas are unchanged. The four `MORTIS-*` document IDs, `Mortis.*` knowledge definitions, `ProjectMORTIS.Research_*` item types, `Mortis.DeathProvenance` provider and `mortis-death:*` evidence bindings remain stable. MORTIS owns those identifiers and must not rename them to match the dependency's branding.

The dependency owns immutable storage keys and its private compatibility implementation. Existing `EXPERIENCE_WORKS_KNOWLEDGE_V1` ledgers and history operation bindings remain in place. No MORTIS migration clears or rewrites a ledger, creates a legacy public alias, adds a second registry, or bypasses dependency authority checks. No gameplay tuning or sandbox options change.

## Offline validation and provenance

Run `python scripts/validate.py --knowledge-and-wisdom '../B47ANCEDKnowledgeAndWisdom'` from the MORTIS root. Both actual-source integrations run in separate Lua 5.1 environments:

- Research: four original registrations and item lookup, prerequisite ordering, all knowledge grants, idempotent distribution insertion, retained synthetic saved knowledge, duplicate completion, registry reload and client write rejection.
- History: actual dependency provider registration with the MORTIS corpse adapter, evidence creation, exact replay, changed-request rejection, actor reauthentication, client rejection and reattachment of the saved store after module reload. Corpse extraction is mocked at the existing DetachedParts boundary; native corpse identity is not certified.

`--unit-only` explicitly omits these two integrations. Without the selected source/API the full runner reports BLOCKED and exits 1; a partial run cannot be reported as integration PASS. It never fetches, vendors, or silently substitutes another dependency.

Fingerprints for the exact local dependency source, metadata and canonical VERSION are in `evidence/knowledge-dependency-0.13.0.json`. At that initial migration, the sibling project had no Git metadata or configured public remote: the 0.13.0 hashes bind that historical local input, not a verified public commit or GitHub backup. Dependency files were inspected only. Historical MORTIS changelogs, audit records and preserved packages keep their old names and evidence status.

## Runtime migration gate

Back up a disposable test save. Replace the old dependency package and select only `B47ANCEDKnowledgeAndWisdom` plus `ProjectMORTIS`; update saved/server mod lists explicitly. Do not enable both old/new identities or mix peer versions. Neither Lua nor this source change updates those lists automatically. This task does not build or deploy packages.

Require a current dependency stage-1 human report before MORTIS stage 2. Start a fresh `mortisTestStart(true)` session; old harness results are historical. Verify native load order, four physical research files, locked/unlocked reading, retained knowledge and item lookup on a migrated fixture, history evidence/privacy/replay, save/reload, late join/rejoin and dedicated restart. The historical Workshop/package copies are not this development source.

[TESTED offline] Source/host integrations pass. [RUNTIME GATE] SP and dedicated MP NOT TESTED; G7 BLOCKED and stable G8 BLOCKED. No deployment, publication, game/server launch or main merge is included.

## Current dependency integration — 0.24.0-dev.3

The exact-version assertion introduced in the initial consumer test was a test defect: compatible dependency updates failed before any contract behavior was exercised. The test now checks canonical API identity, nonempty version provenance and the actual research/persistence contract, rather than requiring literal 0.13.0. Passing these behaviors does not claim compatibility with every future dependency version.

[TESTED offline] Full research/history integration now passes against 0.14.0, exact source commit `45cd856adeef45811d2c79b919494fd6f4754d29` on public repository [B47ANCE/B47ANCEDKnowledgeAndWisdom](https://github.com/B47ANCE/B47ANCEDKnowledgeAndWisdom). Its current feature-branch SHA was verified remotely and its working tree was clean. `evidence/knowledge-dependency-0.14.0.json` binds all selected current source/metadata bytes; the earlier 0.13.0 fingerprint remains historical. No dependency files or saved keys were edited. Native consumer load/save and dedicated gates remain NOT TESTED.

## Current dependency integration — 0.25.0-dev.2

[TESTED offline] Both actual-source consumer integrations pass against Knowledge & Wisdom 0.14.1, exact clean source commit `a8ba91c8454a0a4cac937392d227e1ba1aebcaa3`, verified against its public branch. `evidence/knowledge-dependency-0.14.1.json` binds 114 source/metadata inputs. The 0.13.0 and 0.14.0 records remain historical. This is a test-input update, not a new minimum dependency pin or a native load/save/MP claim; no dependency source was edited.
