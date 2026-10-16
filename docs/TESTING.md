# Project M.O.R.T.I.S. Testing

The native assumptions behind biological-material work are recorded in
`NATIVE_BIOLOGICAL_MATERIAL_AUDIT.md`. Its runtime validation gates are release
tests, not claims inferred from source inspection.

Component/command-memory tests preserve explicit false values, distinguish them
from absent observations, and ensure a false component is not replaced by its
schema's true default. Command changes mark component state dirty for later
persistence; API acceptance is not synchronous disk-write confirmation.

The component round-trip regression exercises real runtime persistence and
replication with a mocked native modData boundary. Whole-component false values
survive flush/load, migration, serialization, snapshot application, and mirrored
client reload. Nested false flags also survive; authoritative removal remains
distinct from false and permits schema defaults on subsequent access. Receiving
snapshots does not mark state dirty or transmit an echo. Native save files and
multiplayer transport still require in-game verification.

Component flushes preflight all registered persistent values before publishing
writes or deletions. A serializer exception or missing top-level payload returns
failure, retains the previous component snapshot, and leaves dirty state for
the engine's existing update retry path. Unknown saved components remain intact.
Outgoing replication likewise rejects an incomplete snapshot; the server only
clears replication-dirty state after a successful build and send. Regression
coverage injects serializer exceptions and nil results, then verifies a successful
retry. This is a component-snapshot boundary, not an atomic identity/native-file
save or a multiplayer transport guarantee. Repeated callback failures still use
the existing fault-isolation disable/reset policy.

Incoming snapshots preflight component-container shape, nonempty identity,
finite nonnegative integer revision, component records/versions, migration and
deserialization before committing component changes. A rejected component update
does not change live values, cached records, or its accepted revision; a corrected
update with the same revision remains eligible. Decoders receive copies so a
mutating failed decoder cannot corrupt the wire payload used by retries or
cache persistence. Tests cover malformed containers, missing payloads, future
versions, invalid revisions, decoder exceptions/nil results and successful retry.
Unknown third-party schemas are still ignored. Identity validation and mirrored
cache access now complete before live component publication. An injected native
cache-access failure preserves live components, prior cached records, and the
accepted revision; recovery permits retrying the same snapshot. This tests the
adapter failure contract, not disk durability or engine serialization.

Round-trip tests now use the real identity runtime. Unknown or malformed explicit
types are rejected before either identity component changes, including when a
snapshot supplies a different stable ID. The rejected identity does not consume
a replication revision. Stable-ID-only bootstrap for untyped vanilla zombies is
preserved: a nil type can restore the ID but returns false to avoid attaching a
typed lifecycle. This is distinct from rejection of an explicit invalid type.

Species registration tests reject self/multi-region parent cycles, missing
parents, and chains beyond the shared 32-ancestor limit before registry mutation.
They also reject invalid/nonfinite/nonpositive integrity and invalid/nonfinite
negative disable/destroy thresholds. Omitted defaults and numeric strings remain
supported. Progressive capability traversal retains defensive runtime checks.

Progressive capability tests cover distal function constrained by supporting
anatomy: parent impairment limits child contribution, disabled parents block it,
and prosthetic contributions respect their supporting chain. Cycles/missing
parents fail closed with a 32-ancestor traversal bound. Legacy binary snapshots
retain their prior contract. Clothing-access tests also run with `next=nil`.

Clothing-access tests distinguish an actually uncovered native region from a
canonical region lacking native clothing mappings. The latter returns an
unavailable result; medWorks must reject exposed-region procedures rather than
assuming bare skin. Third-party anatomy needs an explicit mapping before using
this clothing-access query.

Host wound-repair coverage rejects stage zero while residual wound magnitude
remains. Partial wounds require integer stages of at least one, matching anatomy
restore validation; complete repairs remove the wound. The regression checks
unchanged integrity, magnitude, replay metadata, and survival across anatomy
reload after rejection.

Test on Project Zomboid Build 42.20.3 and inspect `console.txt` afterward.

For the dependency-ordered human gate, use the guided commands and report format
in [IN_GAME_TESTING.md](IN_GAME_TESTING.md). Mocked host execution verifies the
harness contract but is not an in-game PASS.

1. Confirm the root `VERSION` value, B47ANCEDKnowledgeAndWisdom dependency, both sandbox pages, and error-free load with untyped vanilla zombies.

Host test `test_api_compatibility.lua` covers semantic comparisons, inclusive
minimum/exclusive maximum negotiation, missing functions, type mismatches, and
malformed consumer requests.
2. Confirm physical separation defaults on for a new save and never pushes zombies through walls, floors, or unsupported squares.
3. Verify collision, prone, corpse, random, stair, lunge, and player-contact trips remain uncommon.
4. Verify dense piles share the group throttle and do not repeatedly trip an entire group.
5. Test shove domino chains, stomp observation, balance recovery, and capability-gated ragdoll fallback.
6. Exercise type assignment, persistence, profile application/restoration, anatomy, trauma, and consequence transitions.
7. Confirm untyped zombies receive persistent hunger state, retain vanilla
   player/animal targets, and only seek a registered custom food source while no
   vanilla target is active.
   Force a native hunger-setter rejection and confirm feeding/advancement returns
   a failure without changing hunger or its elapsed-time checkpoint. An observer
   error after successful feeding must not roll back or escape into gameplay.
7. Verify crowd flow selects deeper standable low-occupancy interior squares without global scans.
8. Run `MORTISInspect()`, `MORTISDumpRegistries()`, `MORTISExportWeaponReport()`, `MORTISExportDiagnostics()`, and profiler controls.
   Confirm the diagnostics export contains bounded `actionDiagnostics` counts
   after deliberately rejecting a trip/stand action, without recurring console spam.
9. Accelerate `DesiccationYearsToTerminal` only in a disposable test world.
   Confirm desiccation advances after hunger reaches 100%, feeding pauses but
   does not reverse it, the terminal event occurs once, and the enable/kill
   switches behave independently. Restore the five-year default afterward;
   approve or revise that human-facing default before release.
10. Find/read MORTIS-93-001, then the anatomy, metabolism, and biomechanics
    files. Confirm later files reject premature completion, knowledge persists
    after reload, and all four can spawn only in their configured secure/medical
    distributions without duplicate entries.
9. Confirm unknown weapons use conservative fallback; only reviewed exact providers are treated as verified.
10. Test single-player, hosted multiplayer, and dedicated server authority/replication separately.
11. Register a development anatomy attachment; verify protected registry views, missing-state availability, incompatibility rejection, exclusive mounts, persistence/restoration, attach/detach events, and replay rejection.

Do not claim multiplayer compatibility until hosted and dedicated tests pass.

## Revoked EXT-29 Project Remnants adapter removal

The exclusion regression proves that the retired registry and concrete adapter
cannot be loaded and that canonical initialization exposes no NPC-framework
registration entry point. Do not install, detect, inspect, or exercise a
Remnants NPC as a compatibility target.

## 0.11.3 hunger transaction boundary

The vanilla CharacterStat hunger adapter now verifies setter readback. Failed or
ignored native writes preserve the component value, starvation origin, and last
advance checkpoint so a later retry accounts for the same elapsed time. World
age and persisted hunger timestamps reject non-finite/future values, and optional
event listeners cannot turn a committed feed into a caller-visible failure.

## 0.11.4 hunger persistence schema

Zombie hunger component version 2 persists only its documented numeric state
and verified vanilla-backend marker. It rejects non-finite values, impossible
starvation/fed timestamps, and unknown injected fields while migrating version 1
saves through the same validator. Verify old saves retain legitimate hunger and
continuous-starvation progress after their first load and subsequent save.

## 0.11.5 bounded runtime scheduling

- Spawn more zombies than each runtime batch setting and verify collision,
  separation, corpse/stair/lunge balance checks eventually reach every group.
- Change collision and movement batch sizes, reload, and confirm the values are
  honored without callback errors or permanently skipped zombies.
- On a hosted server, dirty components across more than 24 zombies and confirm
  snapshots continue across ticks rather than repeatedly selecting the same set.

## Corpse provenance bridge

Host cases `test_death_provenance.lua` and `test_corpse_anatomy.lua` cover frozen
classifications, duplicate death callbacks, new reanimated identity, authority
denial, protected copies, persisted severed descendants, and missing/malformed/
future-schema corpse anatomy. These are not engine lifecycle tests.

In game, kill typed and untyped zombies, including one with a pre-severed region;
inspect their corpse provenance and confirm missing regions remain unavailable.
Repeat after dragging, carry/drop, save/reload and reanimation/second death.
Check final death-provider classification and verify failed capture logs at most
once per 30 seconds without interrupting death cleanup. Unsupported old corpses
must reject recovery rather than acquire fresh anatomy. Player corpses remain
outside the zombie death hook until a verified player lifecycle bridge exists.

Current host commands, exact coverage/environment, and untested runtime gates are in [VALIDATION.md](VALIDATION.md). Authority/replication native scenarios are in [AUTHORITY_REPLICATION.md](AUTHORITY_REPLICATION.md).
