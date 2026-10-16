# Clothing coverage adapter

Status: repository-only API; not yet consumed by live Nightfall UV damage.

`Mortis.ClothingCoverage.snapshot(zombie, speciesId)` reads the zombie's selected
item-visual collection, resolves script clothing coverage and records per-part
holes. It never generates clothing inventory, edits garments or changes appearance.
Native body-part names resolve through the species registry; humanoid `Back` now
aliases canonical `torso`. Species with unmapped parts reject rather than silently
omitting protection. The returned plain snapshot contains native parts mapped to
canonical regions, and layers with item types and localized holes.

`Mortis.ClothingCoverage.transmission(snapshot, resolver, weights)` takes a
consumer-supplied `resolver(itemType, nativePartName, fabricType)` returning intact transmission
in [0,1]. Each layer transmits `intact + (1-intact)*hole`. Layers multiply at the
native-part level before weighted regional averaging. No global zombie resistance
is calculated. Default equal subregion weights are provisional; explicit positive
weights support more accurate surface-area/directional policy later.

A torn forearm sleeve does not expose the upper arm, opposite sleeve or underlying
shirt. Diagnostics retain native-part transmission as well as canonical-region
averages. Consumer policy owns material/item overrides; unresolved policy returns
an error instead of assigning an invented protection value.

Collection reads are capped at 64 layers and 32 native parts per list. Overflow,
missing scripts, invalid hole data and unavailable APIs reject the snapshot.
Do not interpret that rejection as a naked zombie. No global scans or per-frame
hooks are installed. The eventual coordinator must stagger sampling and invalidate
any cache after clothing damage, equipment changes and fake-dead transitions.

## Evidence

- Local installed `IsoZombie.getItemVisuals()` selects worn inventory visuals or
  visual-only clothing according to native zombie state.
- Installed `ISWashClothing.lua` uses `BloodClothingType.getCoveredParts`;
  `ISInventoryPaneContextMenu.lua` reads localized holes;
  `ISGarmentUI.lua` enumerates `BloodBodyPartType.MAX:index()` / `FromIndex`.
- Official [ItemVisual API](https://projectzomboid.com/modding/zombie/core/skinnedmodel/visual/ItemVisual.html)
  documents script item lookup and body-part hole access.
- Official [BloodBodyPartType API](https://projectzomboid.com/modding/zombie/characterTextures/BloodBodyPartType.html)
  and [BloodClothingType API](https://projectzomboid.com/modding/zombie/characterTextures/BloodClothingType.html)
  document coverage identifiers and lookup. Online signatures are evidence,
  not proof of the installed build's Lua bindings or multiplayer behavior.

Host tests exercise layer composition, local damage, exposed parts, resampling,
invalid mod metadata, bounded reads and unresolved policy. Actual visual-only and
worn/fake-dead zombie equivalence, localized armor damage and server execution
still require in-game verification.
