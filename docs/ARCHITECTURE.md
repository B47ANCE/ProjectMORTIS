# Project M.O.R.T.I.S. Architecture and API

Project M.O.R.T.I.S. wraps vanilla `IsoZombie` objects and exposes reusable systems to extension mods. It adds no zombie archetypes itself.

Load the API with:

```lua
local Mortis = require "Mortis/init"
```

## Public surfaces

- Definitions: `Types`, `Traits`, `Behaviors`, `ComponentSchemas`, `Species`.
- Profiles: locomotion, durability, appearance, collision, and balance.
- State: `Identity`, `Components`, `Persistence`, `Replication`, `Authority`.
- Entity services: target, navigation, locomotion, combat, animation, appearance, state, sound, groups, spawn, and environment adapters.
- Damage systems: anatomy, trauma channels, hit trauma, weapon catalog, and consequence providers.
- Anatomy attachments: latent topology-owned sockets, protected attachment definitions, fail-closed compatibility queries, and authoritative persistent install/remove state.
- Biological resources: persistent zombie hunger plus registered, bounded custom
  food-source providers that preserve active vanilla targets.
- Native biological-material boundary: corpse persistence, feeding, localized
  injuries, food aging/nutrition, traits, work surfaces, gore, and multiplayer
  assumptions are verified in `NATIVE_BIOLOGICAL_MATERIAL_AUDIT.md` before the
  canonical tissue schema is expanded.
- Physical systems: collision, balance, canonical native trips, shove, stomp,
  separation, crowd flow, and bounded geometry-based pile evaluation.
- Development: capabilities, bounded rejection diagnostics, fault isolation,
  scheduler, deterministic random, profiler, and reports.

Version 0.11.8 centralizes rejected and capability-gated action evidence in
`Mortis.ActionDiagnostics`. It retains at most 128 distinct aggregates and 64
first-occurrence records, bounds text and scalar context, returns deep snapshots,
and never logs routine refusals. Repeated reasons increment counters without
growing memory. Capability probes report unavailable checks automatically;
stand and trip adapters add action-specific rejection reasons. The standard
diagnostics export includes the resulting snapshot.

Version 0.11.9 advances an irreversible desiccation fraction only for time spent
continuously at maximum canonical hunger. The interval is sandbox-configurable
from 1–100 years and defaults to five pending gameplay review. Reaching one emits
`ZombieTerminalWithering` exactly once with neutral resource data. When terminal
withering is enabled, the combat adapter writes zero health and verifies readback
before persisting completion. The version-3 hunger component allow-lists terminal
flags and migrates version 2 without resetting valid starvation progress.

Version 0.11.10 loads the M.O.R.T.I.S.-owned research archive during bootstrap
and supplies four physical literature items. The archive dependency (formerly
experienceWorks, now B47ANCEDKnowledgeAndWisdom) remains the sole
owner of document registration, prerequisite evaluation, completion-based
knowledge, and loot insertion; M.O.R.T.I.S. owns only its infected-science
definitions and content. The chain exposes separate knowledge for foundation,
anatomy, starvation/desiccation, and physical failure modes.

Version 0.12.0 adds `Mortis.AnatomyCapabilities`, a deterministic entity-level
view of numeric contributions from functional natural regions and registered
attachments. Disabled, destroyed, and missing natural regions do not contribute;
installed attachments contribute independently with inspectable provenance.
This surface is deliberately separate from `Mortis.Capabilities`, which probes
whether Build 42 engine methods are available. That milestone used API `1.5.0`; the current API is `1.6.0`.

Version 0.12.1 binds the generic `OnCharacterDeath` lifecycle event for player
sources only and freezes their anatomy/classifier provenance before corpse
creation. Same-stable-ID duplicate callbacks return the existing snapshot;
reanimated entities with a genuinely new stable ID may refresh it. The existing
`OnZombieDead` engine path remains authoritative for infected deaths. Native
player-corpse copying, carry/save/reload, and multiplayer timing remain in-game
validation gates rather than claimed compatibility.

Version 0.12.2 adds protected cumulative scheduler diagnostics. Each scheduling
class reports considered, executed, and deferred evaluations; named work budgets
report requested, accepted, and deferred calls and units alongside current-frame
use. Metrics are passive counters, add no entity scans, and reset through the
existing scheduler reset boundary. Consumers obtain copies through
`Mortis.Scheduler.getDiagnostics()` and cannot mutate canonical counters.

Loaded zombies are indexed once and exposed to recurring systems through
independent round-robin cursors. Collision and movement-balance passes therefore
have configurable hard batch limits, while dirty replication scans at most four
times its send budget. Weak streamed-out entries are compacted only when a
bounded pass observes substantial fragmentation. Full tracked snapshots remain
available for compatibility and save-boundary work, but are not used by these
high-frequency schedulers.

Register extension content through `Mortis.registerType`, `registerTrait`, `registerBehavior`, profile registration functions, consequence providers, or verified compatibility providers. Assign a registered type with `Mortis.assign` only on canonical authority.

`Mortis.Piles.evaluate(observation)` is a pure semantic boundary. It accepts at
most 64 explicitly observed local contributors and composes mass, footprint,
thickness, posture, living instability, compression, and optional static-support
height/stability. It does not scan, move, damage, path, persist, or replicate
entities. `COMMANDED` mode requires both `commanded=true` and a non-empty
`orderId`; crowd density can therefore produce only an `INCIDENTAL` result.

`Mortis.PileObservations.build(request)` accepts only caller-supplied candidates,
limits observations to a four-tile same-floor region, and requires explicit mass,
footprint, and thickness. It records malformed, out-of-region, and unclassified
support counts without retaining native objects. It never enumerates a square,
cell, chunk, or world collection.

`Mortis.PileSupportProfiles` is a 64-entry, priority-ordered, callback-isolated
support registry. Its adapter reads object/container/surface properties without
using sprite names. The bundled vanilla dumpster profile is supported by the
installed Build 42.20 tile contract (`container=dumpster`, `solid`, 300 pickup
weight, and a 46/96-tile surface where exposed). Unknown objects fail closed.

`Mortis.PileTraversalLinks.propose(request)` creates a local, non-executable
link only when pile height/stability and bounded endpoint geometry qualify.
`revalidate(...)` requires an explicit actor capability and fresh pile geometry,
checks endpoint drift, and preserves commanded order identity. The returned
record deliberately has `executable=false`; M.O.R.T.I.S. does not teleport an
actor or replace vanilla global pathfinding.

Consumers call `Mortis.negotiateAPI` with an inclusive `minimum`, optional
exclusive upper bound, and required dotted API paths. The returned structured
report distinguishes malformed ranges, missing paths, and type mismatches.
Project M.O.R.T.I.S. API version `1.6.0` is independent from the mod release
version so compatible implementation patches do not force consumer rewrites.

Version 0.22.0 briefly contained a now-revoked EXT-29 NPC-framework boundary.
Version 0.23.0 removes that registry, its concrete Project Remnants adapter, and
the related public entry points. Project Remnants is explicitly unsupported and
must not be detected or reached indirectly through a generic adapter. A future
entity-provider contract requires its own approved consumer and ownership proof.

### Persistent location evidence

`Mortis.LocationMemory` is a generic server-authoritative store for bounded
world-location evidence. It merges nearby observations into capped persistent
records, preserves evidence categories and scores, and provides age-limited
queries without scanning the map. Consumers own the meaning of evidence and all
gameplay thresholds; Project Nightfall uses it for observed probable survivor
locations without teaching M.O.R.T.I.S. about bases or Alpha Ferals.

## Boundaries

Adapters isolate direct Build 42 Java/Lua calls. Unsupported capabilities fail closed. Server authority owns canonical assignments and replicated state. Public registries return protected definitions rather than mutable internal tables.

Extension mods own their zombies, spawn policy, visuals, and game-specific AI. Project Nightfall therefore owns its Transforming, Feral, and Smart Feral definitions and merely consumes this API.

Project M.O.R.T.I.S. also does not add amputation actions or detached limbs.
It owns neutral anatomy profiles, authoritative sever-state transitions,
persistence/replication, events, and safe engine adapters. medWorks owns medical
actions, dismemberment, treatment, and detached-part items. Project Nightfall may
consume medWorks-created parts and their Project M.O.R.T.I.S. provenance for
effigies without either foundational mod depending on Nightfall. See
`ANATOMY_AND_SEVERING_RESEARCH.md` for the verified 42.20.3 engine limits and
integration contract.

## Anatomy attachment foundation

### Death and corpse provenance

`Mortis.DetachedParts.snapshotDeath(entity)` freezes neutral source identity and
provider classifications per anatomy region into `MortisDeathProvenance` ModData.
The authoritative zombie death handler invokes it after death providers finish
and before runtime identity cleanup. Failed capture cannot prevent cleanup;
diagnostics are protected and rate-limited. Clients cannot write death snapshots.

`Mortis.DetachedParts.captureCorpse(corpse, region, metadata)` reads that frozen
record; `capture` routes native `DeadBody` objects to it automatically. Corpse
classification never runs against a fabricated live identity. Repeated death
callbacks after identity cleanup retain the frozen snapshot; a reanimated entity
with a new runtime identity refreshes classifications on its next death.

Corpse anatomy must already be persisted with the supported schema, registered
species/version, and complete region state. Missing or incompatible state fails
closed; it never creates fresh limbs. Severing persists attached/disabled state
for the selected region and descendants. This is an API bridge, not a harvesting
action or a rendered limb-removal feature. medWorks owns those procedures.
Player-death capture and inventory-corpse round trips are not yet implemented or
verified by this zombie hook. Native transfer/save/reanimation requires in-game
validation; host tests simulate the ModData transfer.

Species regions may declare `attachmentSockets`. A socket belongs permanently to
the registered topology; losing anatomy only changes whether the socket is
available. `Mortis.registerAnatomyAttachment` registers content-neutral
attachment definitions, while `Mortis.AnatomyAttachments` exposes protected
definition and socket views plus compatibility checks. Installed attachment
state is stored separately from natural anatomy, versioned, written only by
canonical authority, and protected from duplicate/replayed operation IDs.

Consumer mods own their content and procedure authorization. medWorks therefore
owns prosthetic items, fitting actions, skill checks, and learned knowledge from
medical magazines or books. Project M.O.R.T.I.S. knows only the registered
attachment definition and anatomical compatibility.

`Mortis.AnatomyAttachments.attach` and `detach` require a unique consumer-owned
`operationId`. Successful transitions persist immediately and emit neutral
`AttachmentInstalled`, `AttachmentRemoved`, and `AttachmentChanged` events.
Rejected compatibility/state requests emit `AttachmentRejected`. Consumer mods
remain responsible for inventory, distance, tools, skill, learned knowledge,
procedure timing, and medical consequences before invoking these operations.

## Authority and replication correction

See [AUTHORITY_REPLICATION.md](AUTHORITY_REPLICATION.md) for the current server-owned hunger observations, persisted assignment-clear/revision fields, ordered typed/clear messages, delivery accounting, request bounds, lifecycle cleanup, and compatibility limitations. Native save, restart, late-join, and transport proof remain separate runtime gates.

The internal [locomotion baseline service](LOCOMOTION_RESTORATION.md) uses the existing saved ProfileState component, checkpoints before mutation, and retains pending originals across clear/detach failures. No new gameplay sandbox option or client-owned state is introduced.

Dependency identity migration and retained provider/storage identifiers are documented in [DEPENDENCY_MIGRATION.md](DEPENDENCY_MIGRATION.md).

## Internal Active Hours diagnostic and future subsystem

The user-approved Active Hours consolidation is described in [ACTIVE_HOURS.md](ACTIVE_HOURS.md). Three `Mortis/Diagnostics/ActiveHours*` modules define an explicitly started internal harness; they are not exported as a new public API and do not register events on load. It invokes the existing owner-stack service on the server, with read-only clients and a separate command namespace. It does not route through typed component replication or claim native ownership safety. Future opt-in built-in policy belongs to MORTIS without adding zombie types or changing neutral defaults; no such policy/controller is implemented yet.

## Transactional food-provider boundary

API 1.6.0 adds `FoodSources.TRANSACTION_VERSION=1` and reserve/commit/rollback provider hooks. The server stages verified hunger/cache state before committing a reserved portion, compensates failures, isolates pre-commit queries/reentrant mutators, and emits feeding events only after success. Consume-only automatic feeding fails closed; see [FOOD_TRANSACTIONS.md](FOOD_TRANSACTIONS.md) for provider migration, quarantine and native/crash limitations. No saved schema or custom network protocol is added.
