# Canonical tissue quantity

## Version 0.19 canonical material

Anatomy schema 2 stores a `material` record per present region. Capacity,
remaining, viable, and edible quantities obey
`capacity >= remaining >= viable >= edible >= 0`. Registered per-unit calorie,
protein, lipid, and carbohydrate densities derive nutrition from edible tissue;
derived totals are never stored as another mutable ledger. The older
`tissueCapacity` and `remainingTissue` keys remain compatibility projections.

Schema-1 records migrate only when their capacity and remaining quantity were
both valid. Their known quantity is preserved exactly and initially treated as
viable and edible; later decomposition policy may reduce those axes. Missing or
malformed historical quantities remain unavailable and are never replenished
from a newer species definition.

`Mortis.Anatomy.applyMaterialLoss` commits monotonic mechanism-specific losses
with a transaction ID and expected revision. `Mortis.TissueModel` also provides
pure proportional withdrawals. A successful sever captures every currently
present descendant, persists the source with those regions absent and their
material removed, and returns the transferred subtree. Already-missing
descendants are not recreated.

`Mortis.DetachedMaterialModel` validates those subtree records and provides pure
division, degradation, and withdrawal plans. Dividing a detached arm at its
hand moves the hand and all present descendants to the child record; it cannot
copy them or divide away the record's complete root. Inventory creation and the
two-item authoritative commit remain procedure-owner work.

Species regions may declare an optional positive finite `tissueCapacity` in
relative soft-tissue units. This quantity is independent of structural integrity,
UV score, injury severity and skeleton existence. No default conversion from
health/integrity is applied. New regions with an explicit capacity start with
matching `remainingTissue`; both values persist in canonical anatomy.

Saved anatomy only restores tissue when both capacity and remaining quantity
are valid. Unknown/malformed or pre-feature tissue data remains unavailable,
including on living entities: it is not silently replenished from newer species
defaults. Zero remaining tissue is valid. Historical capacity is retained on
reload rather than silently rescaling an existing body to a changed definition.

`Mortis.Anatomy.tissueSnapshot(entity)` (the AnatomyRuntime module method)
returns detached regions as absent and attached regions with capacity,
remaining, remainingFraction and weight. Weight is the persisted capacity.
Totals include attached regions only. Structural destruction does not imply
zero soft tissue. The returned tables do not alias canonical state. Inspection
does not persist changes; normal Anatomy.get/ensure may initialize an uncached
living entity's in-memory anatomy as elsewhere in this API.

The query rejects missing tissue facts and more than 32 regions instead of
guessing quantities. Existing species that omit tissueCapacity remain compatible
with other anatomy features but cannot supply a complete tissue snapshot.

## Validation and remaining integration

Version 0.20.0 exposes `Mortis.BiologicalMaterial` as the named transaction
surface for decomposition, feeding, harvesting, and bounded regeneration.
Version 0.21.0 adds `Mortis.DecompositionPolicies` and
`Mortis.DecompositionRuntime`. A consumer registers a rate/eligibility policy,
explicitly tracks a living entity or detached item with its last processed world
age and replay sequence, and requests bounded fair batches. Policy callbacks may
return at most 32 regional loss operations. Failed batches retain their replay
sequence; successful batches return the checkpoint the consumer must persist.
The runtime never discovers targets through world, corpse, zombie, or inventory
scans and does not own decomposition balance.
Attached anatomy commits through `AnatomyRuntime`; detached inventory parts
commit through `DetachedParts`. Both paths retain transaction IDs, expected
revisions, mechanism provenance, conservation, authority checks, and rollback
on persistence failure. Consumers continue to own rates, eligibility, medical
costs, nutrition application, and AI consequences.

First-party `Mortis.Humanoid` now defines 100 relative gameplay tissue units:
torso 32, pelvis 16, head 7, neck 2, each arm 5, each hand 1.5, each leg 13,
and each foot 2. These are provisional balancing quantities, not measured body
mass. Each region excludes descendants, so severing an arm removes its own 5
plus its hand's 1.5 from on-body totals. The default infected/player resolver
uses this species; no separate Nightfall-only anatomy definition is needed.
New anatomy receives these quantities; existing saved anatomy is not refilled.

`Mortis.Anatomy.consumeTissue(entity, region, amount, options)` commits a positive
loss on authority, for living or corpse anatomy. Options require a transactionId
(1–128 characters) and expectedRemaining. The amount must fit the expected
quantity; no implicit partial consumption occurs. Return data includes before,
after, amount, regionId and a replayed flag for the most recent matching receipt.

The per-region receipt survives reload. Reusing its ID with changed arguments
fails; older requests fail their expected-quantity check after later loss. This
is a monotonic loss-only contract, not a general unbounded transaction journal.
Callers must retain the original expected quantity when retrying. A future tissue
restoration API will need a revision/generation guard before quantities can rise.
Detached regions reject new losses; replay can acknowledge a previously committed
loss without modifying the now-detached region. Failed persistence restores both
quantity and receipt. Structural integrity, wounds, death and fire are untouched.
Native synchronization is separate and must be performed by the caller through
its verified authoritative transport; this API does not claim network delivery.

Host tests cover registration constraints, independent integrity/tissue values,
weighted totals, corpse persistence, preserved zero, absent parts, read-only
results and legacy records. This is not native save/multiplayer certification.

DetachedParts provenance now includes optional `tissue={capacity,remaining}` for
the captured region. Living capture samples current anatomy; corpse recovery
retains frozen death identity/classifications but resamples current tissue, so
postmortem loss is not undone by a stale death snapshot. Unknown current tissue
is omitted rather than copied from earlier intact evidence. Existing item
write/read deep copies retain the value for medWorks consumers. This describes
the named region only; descendant quantities and item-side tissue consumption
still need a composite-part contract.

Still required: live quantity calibration, explicit legacy migration policy,
transactional tissue restoration, composite detached-part quantities, and
synchronization. Consumers must not directly mutate the
canonical table to implement gameplay. Nightfall destruction/smoke integration
and medWorks item propagation are not enabled by this schema/query increment.
