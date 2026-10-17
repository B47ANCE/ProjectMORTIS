# Active Hours offline design experiments

This starts the weighted-selection roadmap as offline Lua mathematics. It is
outside `src/`, absent from packaging inputs, unregistered and not a public API.
It does not implement Active Hours gameplay or advance G2/G6/G7/G8. The archived
design deferred the final validator until speed proof; this experiment explores
that contract without installing a validator/controller in the mod.

`weighted_ranges.lua` compiles an inclusive ordered range of `shambler`,
`fastShambler`, `sprinter` into probabilities and a cumulative distribution once.
Both endpoint weights must be finite numbers in [0,100], including ignored
one-category inputs. A single category receives 100%; its endpoint total is
ignored. Two categories normalize their endpoint weights; 20/40 becomes 1/3,
2/3, and zero/zero is rejected. Three categories allocate the remainder to the
middle; 10/40 gives 10/50/40. Endpoint totals above 100 are rejected for multi-
category ranges, with a 1e-9 arithmetic tolerance; roundoff above 100 normalizes
the endpoints and leaves the middle at zero. Invalid input returns nil/reason,
never another preset. These are proposed math semantics, not sandbox IDs/defaults.

Sampling accepts a supplied roll in [0,1). Intervals are lower-inclusive and
upper-exclusive; zero-probability buckets cannot win. Reusing a roll is
deterministic, and the module owns no RNG. Tests exercise exact boundaries and
a deterministic 1,000-point distribution, not merely random frequencies.

Before any runtime integration: prove native speed/ownership/restoration; agree
and localize authoritative sandbox options and ignored-input behavior; define
stable zombie-life identity, separate Active/Inactive rolls and configuration
revision/persistence; test replay, save/reload, reconnect and restart without
rerolling on updates. Add bounded population scheduling only after those gates.
The maintained standalone project needs its own parity acceptance evidence;
this file neither changes that repository nor supplies its implementation.

`life_choices.lua` adds a detached candidate/retained-record experiment with
supplied independent active/inactive rolls. Same life/revision/key retains both;
stale revisions, mismatched lives, changed keys without a revision, unknown or
future records and replacement rolls on retention refuse. It does not draw RNG,
serialize/checkpoint, allocate identity, replay leases or mutate saved inputs.
Tests model record/module reload only, not native persistence or networking.

`phase_window.lua` classifies supplied normal/endless windows with dawn-inclusive,
dusk-exclusive daylight, wrapped intervals and complementary Day/Night modes.
Both needs no solar input. Synthetic short/long windows are not seasonal engine
evidence. There is no climate reader, population callback or native writer.

The [configuration/lifecycle proposal](../../docs/ACTIVE_HOURS_DESIGN.md) records
proposed options, ignored inputs, per-life identity and parity acceptance.
Assignment IDs can be cleared/regenerated; a durable life token and coordinated
production ownership remain unresolved integration requirements. The isolated
`configuration.lua` now normalizes all proposed fields and produces exact `AHC1`
selection keys using reduced rational probabilities. Unknown/metatable-bearing
inputs, bad primitive bounds and invalid selected ranges refuse. Equivalent
distributions and fixed point ranges share keys; ignored fields and Mode/Enabled
do not reroll choices. Outputs are detached; revision and supplied-roll admission
stay in `life_choices.lua`. There is no sandbox reader, RNG or persistence. None of these
experiments is a final production validator/controller or registered schema.

Run from the MORTIS root:

```powershell
python scripts/validate.py --test test_active_hours_weighted_design
python scripts/validate.py --test test_active_hours_life_design
python scripts/validate.py --test test_active_hours_phase_design
python scripts/validate.py --test test_active_hours_config_design
```

Host Lua evidence is offline only. The runtime syntax inventory excludes these
experiments; their regressions explicitly load/compile them. The normal full and
unit-only runners discover all four regressions.
