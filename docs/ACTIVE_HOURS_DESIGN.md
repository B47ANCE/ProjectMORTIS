# Active Hours configuration and lifecycle proposal

Prepared for 0.26.0-dev.2. **Design and offline experiments only.** No option,
controller, solar adapter, persistence component or public API below is installed.
Native authority/restoration proof in [ACTIVE_HOURS.md](ACTIVE_HOURS.md) remains
the prerequisite for affected production work. This document records decisions
to review against that evidence, not a substitute for it.

## Proposed server sandbox contract

Reserve namespace/page `MORTISActiveHours` for MORTIS. The standalone project must
own different identifiers and yields execution when MORTIS is enabled. No mod
edits another mod's settings. Missing settings in existing saves mean disabled;
future readers must interpret authoritative server settings, never client prefs.
These proposed identifiers are not added to `sandbox-options.txt` yet.

| Identifier suffix | Proposed type/default/bounds | English name | English tooltip |
| --- | --- | --- | --- |
| Enabled | boolean, false | Enable Active Hours | Apply MORTIS activity profiles after native capability checks pass. Disabled preserves normal movement and releases only this subsystem's requests through verified cleanup. |
| Mode | enum: Night=1, Day=2, Both=3; default 1 | Active period | Choose when the active profile applies. Day includes dawn and excludes dusk; Night is its complement. Both always selects the active profile. This does not change vanilla inactivity. |
| ActiveSelection | enum: Fixed=1, Weighted=2; default 1 | Active selection | Use one movement tier or a weighted inclusive range during the active period. |
| ActiveFixedTier | enum: Inherit=1, Shambler=2, FastShambler=3, Sprinter=4; default 1 | Active movement tier | Inherit adds no tier request. Other choices require verified native movement and restoration support. |
| ActiveRangeMin | enum: Shambler=1, FastShambler=2, Sprinter=3; default 1 | Active range minimum | Lowest tier in the inclusive active weighted range; must not exceed the maximum. |
| ActiveRangeMax | same three-value enum; default 3 | Active range maximum | Highest tier in the inclusive active weighted range. |
| ActiveMinWeight | integer 0..100, step 1; default 25 | Active minimum weight | Allocate weight to the first tier. Two tiers normalize endpoint weights; three tiers give the remainder to the middle. |
| ActiveMaxWeight | integer 0..100, step 1; default 25 | Active maximum weight | Allocate weight to the last tier. Multi-tier endpoint totals must not exceed 100; two-tier zero/zero is invalid. |
| InactiveSelection | same selection enum; default 1 | Inactive selection | Choose fixed or weighted movement outside the active period. This is a custom profile, not native inactivity. |
| InactiveFixedTier | same four-value tier enum; default 1 | Inactive movement tier | Inherit adds no tier request outside the active period. |
| InactiveRangeMin | same three-value range enum; default 1 | Inactive range minimum | Lowest tier in the inclusive inactive weighted range. |
| InactiveRangeMax | same three-value range enum; default 3 | Inactive range maximum | Highest tier in the inclusive inactive weighted range; must not be below the minimum. |
| InactiveMinWeight | integer 0..100, step 1; default 25 | Inactive minimum weight | Allocate weight to the first inactive tier using the same weighted-range rules. |
| InactiveMaxWeight | integer 0..100, step 1; default 25 | Inactive maximum weight | Allocate weight to the last inactive tier using the same weighted-range rules. |

Neutral defaults are disabled plus inherit/inherit. Weighted defaults are an
explicit proposed 25/50/25 distribution when weighted selection is chosen;
they are not adopted balance tuning. Group controls by enablement, active and
inactive profiles. Proposed keys are `Sandbox_MORTISActiveHours`,
`Sandbox_MORTISActiveHours_<suffix>` and matching `_tooltip` keys. Native enum
translation syntax, layout and fallback require the installed-source audit and
native test before adding production catalogs; this table is English copy only.

Validate the entire candidate once on the server before accepting it. Reject
nonfinite/wrong-type/out-of-bounds values, invalid enums, reversed ranges and
invalid selected weights; do not coerce strings or silently select another tier.
Inactive/ignored fields still need valid primitive bounds. Fixed mode ignores
range relationships, and weighted mode ignores the well-formed fixed tier.
For a one-tier weighted range both weights must be valid but their allocation is
ignored: that tier has probability 1. Never hide ignored-input behavior.

On invalid reconfiguration, retain the last accepted configuration and report a
bounded diagnostic; on first load with invalid configured data, enroll no new
targets. Disabling or changing to inherit requires verified release of this
owner, not dropping its bookkeeping. Failed/busy cleanup stays pending and
blocks replacement writes; another owner's state is never cleared for success.

No configurable RNG seed, owner key/priority, revision, request token, scan rate
or protocol limit is proposed. These are implementation/safety concerns.
Transition behavior is one target request after an eligible safe callback, with
deduplication; no interpolation, repeated native correction or per-tick reroll.
Additional attributes and arbitrary profile multipliers remain excluded until
each has verified readers, writers, inverse behavior and consumer requirements.

## Solar input and phase boundaries

The offline interval model accepts supplied `normal {dawn,dusk}` decimal hours
in [0,24), or explicit `endlessDay`/`endlessNight`. Normal daylight is
`[dawn,dusk)` including a wrapped interval across midnight. Equal endpoints are
ambiguous and rejected rather than guessed as an endless mode. Night is the
complement; Both requires no solar sample. Endless kinds cannot also carry
endpoints. There is no weather/darkness/light-level heuristic.

Fixtures use synthetic short/long/wrapped windows, not measured seasonal data.
The eventual adapter must prove weather-independent seasonal dawn/dusk and
endless-mode semantics against exact installed Lua evidence and actual runtime.
No exact native API is asserted here. Missing/invalid samples must not trigger a
guessed transition. Cache one authority-owned sample per relevant clock/date/
configuration change, keep bounded diagnostics, and use bounded existing target
callbacks rather than rescanning the population. Handling a clock jump and a
failed sample while an owner is active remains part of the native cleanup gate.

## Identity, choices and persistence

Source finding: `Mortis/Runtime/Identity.lua` stores `Mortis.Identity.StableId`
for framework identity, but `clear`/`clearReplicated` remove it and
`regenerateStableId` can replace it. It is therefore **not proven to identify an
entire zombie life** across assignment/clear/reanimation. Online IDs, wrapper
addresses and coordinates are likewise unsuitable as a life token by themselves.
Do not silently bind durable choices to any of these observations.

The proposal needs a server-issued, durable life token independent of type
assignment. Its allocation/uniqueness, vanilla-untyped storage, corpse/reanimation
boundary and restart persistence are unresolved integration requirements. No new
component or world schema is registered by this iteration. A new life requires
an explicit verified lifecycle decision; missing data is not automatically new.

`experiments/active-hours/life_choices.lua` explores this data record:
`{version=1, lifeId, revision, selectionKey, activeRoll, inactiveRoll}`. Version 1
is an experimental format, separate from project/API/world schema versions.
The authority would draw two independent rolls in [0,1), including when the
draws happen to match; clients never supply or redraw them. Normalize the two
selected profile definitions into a deterministic, exact `selectionKey` before
use. Its canonical encoding is not implemented by this experiment.

- First confirmed new life: construct a candidate with two supplied rolls;
  checkpoint/verify before native use. Merely returning a candidate is not a
  commit. No RNG or persistence implementation is included.
- Same life, revision and key: retain both rolls and return a detached copy.
  Reject supplied replacements. Phase changes, callback repeats, streaming,
  reconnect and reload do not themselves reroll.
- A changed selected-profile configuration: monotonic authority revision and a
  different key; create a candidate pair only with explicit new supplied rolls.
  Both rolls change at this boundary. Mode/enablement or ignored-field changes
  do not change the selection key/revision and do not reroll. All peers would
  observe the accepted authoritative result, never their own RNG.
- Reject older revisions, same-revision/different-key conflicts, lifetime
  mismatch, incomplete/corrupt/future/unknown-field records and missing rolls.
  Preserve the existing record. No blind reset, rollback or automatic replay.
- Preserve the new record before switching native targets; journal/consumer
  lease recovery remains a separate coordinated transaction. The experiment
  cannot guarantee atomicity between disk and native writes.

Life-ID 192-byte and key 4096-byte bounds, finite safe-integer revisions and
strict plain tables are internal serialization safety limits, not gameplay
settings. No serializer, migration of player saves, downgrade promise, native
storage durability, lease replay, custom packet or authority claim is supplied.

## Parity and lifecycle acceptance

Both MORTIS and the independently maintained standalone product need their own
implementation and evidence. The following is a shared behavior target, not
proof of standalone parity or permission to edit its repository in this slice.

| Case | Offline preparation / eventual acceptance |
| --- | --- |
| Disabled existing/new save | No enrollment/write; existing own leases require safe release; unrelated owners preserved |
| Day/Night/Both | Exact dawn/dusk boundaries; complementary Day/Night; Both independent of solar availability |
| Seasonal/endless/clock jump | Synthetic interval coverage now; actual engine samples, seasonal progression, jumps and failure behavior later |
| Fixed/inherit/weighted | Same inclusive categories and CDF boundaries; no hidden fallback; inherit removes only own request |
| New life / config change | Separate supplied rolls; one accepted selection revision; verified persistence before application |
| Update / phase / reload / rejoin | Same record retains rolls; no callback or reconnect RNG; peers observe server results |
| Stale/corrupt/newer record / reused online ID | Refusal and preserved evidence; no new identity or stock reset guessed from unavailable state |
| Assignment clear / corpse / reanimation | Explicit life-token policy and verified native evidence required; no assumption that assignment ID is lifetime ID |
| Consumer coexistence / owner loss | Respect priorities and ceilings; busy cleanup retained; no blind acquire/clear/replay |
| Large population / restart | Bounded fair scheduling and cached solar input; actual throughput, persistence and headless events measured later |
| Both mods enabled | Standalone inactive before registration/writes; no duplicate MORTIS effect; runtime load-order proof still required |

Run the three experiments through `scripts/validate.py` with test stems
`test_active_hours_weighted_design`, `test_active_hours_life_design` and
`test_active_hours_phase_design`. Host tests execute proposed data semantics;
they are not the final server validator/controller, native save/restart tests or
G2/G6/G7/G8 PASS. Integrate only after the controlling native proof and the open
identity, solar, configuration and ownership contracts are resolved.
