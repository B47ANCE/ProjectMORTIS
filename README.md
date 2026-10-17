# Project M.O.R.T.I.S.

**More Original Reanimated Threats Injection System**

Project M.O.R.T.I.S. is a public custom-zombie API and framework for Project Zomboid Build 42.

- Version: `0.26.0-dev.1`
- Mod ID: `ProjectMORTIS`
- Author: B47ANCE
- Minimum game version: `42.20.3`
- Required Mod ID: `B47ANCEDKnowledgeAndWisdom`

Project M.O.R.T.I.S. wraps vanilla `IsoZombie` instances. It does not replace the zombie class and does not add custom zombie types by itself. Extension mods own their types, spawning, presentation, and gameplay policy.

Version 0.23.0 adds the bounded `Mortis.DeathProvenance` evidence provider for
experienceWorks history records (now supplied through B47ANCEDKnowledgeAndWisdom). Callers must supply an explicit corpse, region,
stable subject identity, and matching evidence ID. MORTIS does not automatically
create memorials or decide history visibility or presentation.

## API services

- Types, traits, behaviors, components, species, and event dispatch.
- Persistent identity, authority boundaries, replication, and reconciliation.
- Authoritative assignment and clean return-to-vanilla identity for temporary extension lifecycles.
- Locomotion, durability, appearance, collision, and balance profiles.
- Anatomy, trauma channels, damage, and consequence providers.
- Canonical per-region biological material transactions plus fair, bounded,
  opt-in decomposition scheduling. Consumers own rates and target registration;
  Project M.O.R.T.I.S. never discovers targets through global scans.
- Topology-owned anatomical attachment sockets with authoritative install/remove state, persistence, replay protection, and neutral events.
- Persistent zombie hunger initialized deterministically between 0–75%, continuous starvation-duration tracking, tunable chase-drive queries, source-tagged feeding events, and extensible nearby food-source providers.
- Irreversible, years-scale desiccation advances only during full starvation,
  emits one neutral terminal event, and optionally applies verified terminal
  withering; enablement and the 1–100 year interval are sandbox configurable.
- Neutral, versioned detached-part provenance and authoritative anatomy-severing APIs for procedure mods such as medWorks.
- Weapon catalog classification and verified compatibility providers.
- Canonical native zombie knockdowns, trips, shove dominoes, stomp observation,
  pile throttling, wall-safe separation, and bounded geometry-based pile semantics.

Project Remnants is explicitly unsupported. MORTIS contains no detection,
adapter, registration, identity mapping, or compatibility path for it.
- Bounded same-floor pile observations and a property-first static-support
  registry with verified vanilla dumpster support and third-party extension API.
- Pure local pile traversal-link proposals with actor-capability and
  completion-time geometry/authority revalidation; no custom global pathfinder.
- Bounded local crowd-flow navigation.
- Server-authoritative logical groups with deterministic merge, leadership replacement, pruning, and consumer ownership.
- Capability probes, bounded rejection/capability aggregates, diagnostics
  exports, registry exports, and callback profiling without routine log spam.
- Fair, independently cursor-driven runtime batches for collision, movement
  balance, and dirty-state replication, with configurable per-pass budgets.
- Semantic API compatibility negotiation with consumer version ranges and
  required-surface type checks.
- Four physical, prerequisite-aware infected-research files registered through
  B47ANCEDKnowledgeAndWisdom cover foundational physiology, functional anatomy,
  starvation/desiccation, and physical failure modes. Project M.O.R.T.I.S. owns
  their science content while B47ANCEDKnowledgeAndWisdom owns archive/knowledge plumbing.

Physical zombie separation is enabled by default for new worlds and configurable on the `M.O.R.T.I.S. Physical Interactions` sandbox page.

## Documentation

- [Architecture and API](docs/ARCHITECTURE.md)
- [Testing](docs/TESTING.md)
- [Native trip and pile audit](docs/NATIVE_TRIP_AND_PILE_AUDIT.md)
- [Weapon compatibility](docs/WEAPON_COMPATIBILITY_POLICY.md)
- [Roadmap](docs/ROADMAP.md)

The authoritative mod source is `src/ProjectMORTIS/42/`. `Contents/mods` is a preserved packaging copy. Versions use `MAJOR.MINOR.PATCH`.

## Development validation

Root `VERSION` is canonical; see [version policy](docs/VERSION_POLICY.md) and [source inventory](SOURCE_INVENTORY.json). `Contents/` and existing `dist/` are historical local artifacts, preserved and excluded from Git.

Install Python development dependencies with `python -m pip install -r scripts/requirements.txt`, then run `python scripts/check_versions.py` and `python scripts/validate.py --knowledge-and-wisdom <B47ANCEDKnowledgeAndWisdom-repository-root>`. CI runs `--unit-only` and explicitly omits both actual-source dependency integrations; run the full command locally. Host tests are not PZ runtime evidence: G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.

The authority/replication fixes and remaining limitations are described in [AUTHORITY_REPLICATION.md](docs/AUTHORITY_REPLICATION.md), with [current validation](docs/VALIDATION.md) and [GitHub onboarding provenance](docs/ONBOARDING.md). Client hunger reads no longer author state; assignment clears synchronize with stale-message protection; directed replies preserve pending broadcasts. All multiplayer peers must use the same build.

Profile removal and assignment clearing now restore saved observable locomotion fields; see [capture, legacy limits and native gates](docs/LOCOMOTION_RESTORATION.md). Dependency imports and metadata use B47ANCEDKnowledgeAndWisdom; current actual-source integration is tested against 0.15.0; see [migration and offline integration evidence](docs/DEPENDENCY_MIGRATION.md). Existing saves/server mod lists must select the new Mod ID, with only one dependency identity enabled.

## Active Hours features and standalone compatibility

B47ANCE'd Active Hours remains maintained as a standalone mod; M.O.R.T.I.S. includes its complete feature scope. The implementations are incompatible: when ProjectMORTIS is enabled, standalone Active Hours disables its own execution and MORTIS takes precedence. Neither requires the other. Included features still in design are not claimed as completed. The integrated diagnostic is dormant until explicitly started; no production day/night behavior is enabled. See [scope, preserved evidence, blockers and manual experiment](docs/ACTIVE_HOURS.md). Do not enable the old standalone proofs alongside it. G2/G6/G7/G8 retain their existing blocked/untested statuses.

Food providers now use the API 1.6.0 [transaction contract](docs/FOOD_TRANSACTIONS.md). Unsafe consume-only callbacks are never called automatically; Nightfall 0.29.1-dev.1 implements the migrated effigy adapter with actual-coordinator host tests; native consumption, persistence and replication still require validation.

Development checkpoint dev.2 hardens discovery/quarantine and rejects food values that produce no hunger relief. All 37 sandbox options now have English tooltips, checked with JSON catalog integrity by the normal offline runner; non-English fluency and native fallback remain unverified. Roadmap work has begun on an [offline weighted-range/CDF experiment](experiments/active-hours/README.md), outside the runtime/package source. See the [execution queue and remaining gates](docs/MASTER_ROADMAP.md#current-execution-queue).

Development checkpoint dev.3 extends [observed restoration to the owner stack](docs/LOCOMOTION_OVERRIDES.md): saved five-field baselines, verified cleanup, busy-state refusal and explicit recovery after owner loss. Profile writers wait while an override owns movement; release/clear owners before retrying profile or assignment changes. Full native animation/lunge restoration and MP remain unverified. See the [current audit and roadmap gates](docs/AUDIT_2026-10-16.md).

Dev.4 prepares the [runtime audit test handoff](docs/RUNTIME_AUDIT_HANDOFF.md), including dependency review, exact build records, isolated speed/owner/release proof, consumer feeding and failure/lifecycle result forms. Source work cannot close native authority/restoration gates.

## Main-menu zombie creator

The local Zombie Creator authors reusable definitions with identity, movement tier, durability, appearance and registered trait/behavior references. Save/load/delete drafts, inspect generated Lua and export a reviewed definition for a separate content mod. It works outside debug mode and does not spawn, assign or install gameplay content. [Creator guide and native test cases](docs/ZOMBIE_CREATOR.md). Native menu, focus and file behavior remain NOT TESTED.
