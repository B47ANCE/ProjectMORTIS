# Project M.O.R.T.I.S. Roadmap

> Consolidated status: [MASTER_ROADMAP.md](MASTER_ROADMAP.md).

## Canonical biological material

- [x] Audit Build 42.20 corpse lifecycle, zombie corpse feeding, localized
  wounds, Food nutrition/aging, registered traits, work-surface properties,
  gore presentation, and native synchronization boundaries.
- [x] Migrate localized anatomy tissue to capacity/remaining/viable/edible and
  nutrition-density state without refilling unknown legacy corpses.
- [x] Transfer complete present descendant subtrees into divisible detached
  anatomy records with an auditable conservation ledger.
- [x] Add authority-owned tissue loss, decomposition, feeding, harvesting, and
  regeneration transactions with replay and stale-state protection.
- [x] Add fair bounded decomposition scheduling for explicitly tracked living
  or detached targets. Consumers own rates, eligibility, registration, and
  persisted scheduling checkpoints; Project M.O.R.T.I.S. performs no global scan.

## Current validation goals

- Integrate the repository-only [persistent wound promotion API](PERSISTENT_WOUNDS.md)
  with Nightfall's regional UV dose coordinator; native clothing/wound capability
  verification and multiplayer transport validation remain open.

- Confirm Nightfall's dependency report records Project M.O.R.T.I.S. mod version
  from root `VERSION` separately from public API version `1.5.0` in each tested session.

- Tune physical separation and trip probabilities under dense populations.
- Verify shove, stomp, corpse, stair, lunge, and ragdoll capability paths.
- Validate canonical `IsoZombie.knockDown(boolean)` trips and incidental pile
  observations in single-player, hosted, and dedicated-server sessions.
- In-game validate the implemented bounded local observer and property-first
  vanilla-dumpster support profile and non-executable local traversal-link
  proposals. Do not enable engine traversal, commanded formation, or composite
  traversal until each native transition passes the gates in
  `NATIVE_TRIP_AND_PILE_AUDIT.md`.
- Validate persistence, authority, replication, and reconciliation in multiplayer.
- Validate lazy reconstruction of persistent logical-group membership and leader
  replacement after save/load, chunk unload/reload, and dedicated-server restart.
- Validate bounded persistent location evidence across save/load, expiry,
  replication, and dedicated-server authority with a real extension consumer.
- In-game validate bounded rejection/capability diagnostics and exported counts.
- Validate the 0.11.3 verified CharacterStat hunger-write boundary across save,
  reload, hosted authority, and dedicated-server replication.
- Validate the 0.11.4 hunger component-v2 migration against pre-0.11.4 saves;
  malformed fields must be discarded without resetting valid starvation time.
- Validate the 0.11.9 hunger component-v3 migration, five-year default, terminal
  event, and verified health consequence across save/reload and multiplayer.
- Tune the 0.11.5 bounded collision and movement defaults under very-high and
  insane populations; verify fair dirty replication on hosted/dedicated servers.

## Planned development

- Validate physical research-file spawning, reading completion, prerequisite
  ordering, and save persistence in single-player and multiplayer.

- Expand the implemented public API negotiation contract only when a real
  consumer needs additional capability semantics.
- Expand verified weapon compatibility providers.
- Refine anatomy, trauma, balance, locomotion, and crowd-flow services.
- Validate installed anatomical attachment modData transmission, late join, and reconciliation on hosted and dedicated servers.
- In-game validate deterministic entity capability contributions after severing,
  disabling, attaching, save/reload, and multiplayer reconciliation.
- Validate hierarchical sever-state transitions and frozen corpse provenance
  in the engine: drag/carry/drop, save/reload, reanimation, and concurrent actions.
  Validate the implemented player-death capture and human-source medWorks part
  path against native corpse creation, carry/save/reload, and multiplayer.
- Tune the implemented years-scale desiccation default only from long-duration
  simulation and gameplay feedback. Target selection and game-specific feeding
  applications remain consumer-owned.
- Prove the native 42.20.3 dismember render hook with one medWorks-owned left-hand
  experiment before expanding visual removal to other regions.
- Add only engine features confirmed through Build 42 runtime testing.

Zombie archetypes and game-specific AI remain the responsibility of extension mods such as Project Nightfall.

## Approved external-research additions

- **EXT-01/02 support:** expose only the entity/anatomy capabilities animalWorks
  needs; animal identity, AI, ownership, and commands remain animal/provider-owned.
- **Project Remnants removal:** completed in version 0.23.0. The read-only
  adapter, generic registry, initialization registration, public entry point,
  positive test, and compatibility document were removed. Do not restore a
  generic or indirect integration path.
- **EXT-31 — Dependent-character capability:** research stable dependent identity,
  custodian binding, needs observations, care requests, stage/loss lifecycle, and
  bounded synchronization. The neutral ownership/schema research is complete in
  `DEPENDENT_CHARACTER_CAPABILITY_RESEARCH.md`; runtime implementation remains
  blocked until an approved, separately owned content consumer supplies concrete
  identity, persistence, permission, action, and synchronization requirements.
  Specific dependent content remains separately owned.
- **EXT-27/32 support:** provide registered entity/anatomy and death/corpse
  provenance facts to Nightfall conditions and B47ANCEDKnowledgeAndWisdom history records;
  MORTIS does not own their rules or presentation.
  Version 0.23.0 implements the EXT-32 `Mortis.DeathProvenance` evidence provider
  with explicit corpse, region, stable-subject, and evidence-ID validation.
  Native corpse lifecycle and multiplayer proof remain open.

These are post-release research allocations unless directly required to validate
the current Nightfall 1.0 dependency closure.

## Active Hours

The entire Active Hours project is consolidated here. Follow [ACTIVE_HOURS.md](ACTIVE_HOURS.md): validate the dormant one-zombie diagnostic first; then develop optional solar, profile and weighted-range behavior with authoritative sandbox settings after the affected native gates. No standalone Core/Night/Day product remains planned.

## Transactional feeding follow-up

M-05 coordination is implemented; [FOOD_TRANSACTIONS.md](FOOD_TRANSACTIONS.md) defines the API 1.6.0 provider contract. The next consumer work is migrating Nightfall effigies from one-step consumption and verifying tissue/claim compensation. Preserve source IDs and authoritative sandbox rates. Actual native durability, contention, late join and restart remain G7 gates.
