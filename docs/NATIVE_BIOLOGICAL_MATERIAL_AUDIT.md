# Build 42.20 Native Biological-Material Audit

This audit records the engine surfaces that Project M.O.R.T.I.S., medWorks,
foodWorks, experienceWorks, and Project Nightfall may safely integrate with.
It is based on the installed Build 42.20 game JAR and installed game data. It
does not treat decompiled implementation as redistributable source.

## Ownership conclusion

- Project M.O.R.T.I.S. must own canonical anatomy topology, localized tissue,
  nutrition, trauma/pathology metadata, decomposition, detached anatomy, and
  conservation transactions.
- medWorks may inspect those records and request authoritative procedures. It
  must not maintain a second anatomy or tissue ledger.
- foodWorks may turn authorized tissue withdrawals into food items and expose
  preparation/consumption behavior. It must not invent tissue yield.
- experienceWorks may register and query generic character traits. Consumer
  mods own their trait definitions and effects.
- Project Nightfall may configure Feral biology and apply UV damage through
  M.O.R.T.I.S. transactions. It must not own parallel tissue state.

## Corpse lifecycle and persistence

Verified in `zombie.iso.objects.IsoDeadBody`:

- corpse creation copies the source moving object's `modData` table;
- the original entity is subsequently removed;
- corpse reanimation copies corpse `modData` back to the new zombie;
- corpses already persist worn items, attached items, inventory, death time,
  reanimation time, burn state, rot age, skeleton state, and animal rot stage;
- burning can ultimately remove/replace a corpse;
- add/remove-corpse packets are native multiplayer boundaries.

Consequences:

- the canonical biological record can survive entity-to-corpse-to-zombie
  transitions in `modData` if it is frozen before removal and validated after
  each transition;
- native corpse removal/burning is a terminal ownership boundary and must not
  silently duplicate detached material;
- carrying, streaming, save/load, reanimation, and dedicated-server timing
  still require in-game validation.

## Native zombie corpse feeding

Verified in `IsoZombie` and `ZombieEatBodyState`:

- idle zombies search nearby squares for an eligible `IsoDeadBody`;
- skeleton, animal, and animal-skeleton corpses are excluded by that search;
- native selection rejects blocked lines and caps eaters at three per target;
- `setEatBodyTarget` maintains the target's eating-zombie collection;
- the native eat state supplies facing, animation/state duration, target
  retention, blood/giblet presentation, and client target synchronization;
- the native state does **not** decrement corpse mass, tissue, calories, or any
  other nutritional resource.

Consequences:

- M.O.R.T.I.S. may observe a validated native eating target and perform bounded,
  authoritative tissue withdrawals without replacing base pathfinding or the
  native animation state;
- any custom edible source needs an explicit provider and cannot be assumed to
  participate in the native corpse search;
- visual eating is not evidence that nutrition was conserved.

## Localized injuries and network synchronization

Verified in `BodyDamage` and `BodyPart`:

- vanilla player anatomy has 17 concrete body parts: hands, forearms, upper
  arms, upper/lower torso, head, neck, groin, upper/lower legs, and feet;
- each body part owns health plus cut, scratch, bite, deep-wound, bleeding,
  fracture, burn, bullet, infection, bandage, stitch, and pain state;
- damage mechanisms use distinct setters and timers rather than one universal
  wound flag;
- `BodyPart` exposes field-level delta serialization, while player damage paths
  call native damage/visual synchronization methods;
- vanilla does not expose a persistent removed-limb topology or a material
  conservation ledger through these injury fields.

Consequences:

- M.O.R.T.I.S. trauma adapters should read mechanism-specific native evidence
  but keep irreversible tissue loss and subtree detachment in its own canonical
  record;
- medWorks procedures must use native injury APIs only through capability-
  checked adapters and must separately transact M.O.R.T.I.S. tissue state;
- direct client writes to either native wounds or M.O.R.T.I.S. tissue are not an
  authoritative multiplayer implementation.

## Food and decomposition surfaces

Verified in `zombie.inventory.types.Food`:

- food items persist calories, carbohydrates, lipids, proteins, age, freshness,
  rotten age, frozen state, and related item state;
- nutrition values can be scaled when portions are divided;
- food supports age inheritance/copying and explicit rotten checks;
- food aging is container- and world-time-aware.

Consequences:

- foodWorks can materialize an authorized M.O.R.T.I.S. withdrawal as a vanilla
  `Food` item with derived macronutrients and provenance;
- item aging is useful presentation and consumption infrastructure, but it is
  not the canonical corpse/detached-part decomposition ledger;
- dividing food must conserve the source nutrition transaction rather than
  recalculating yield from item display values.

## Traits

Verified in `CharacterTrait`, `CharacterTraitDefinition`,
`CharacterTraitDefinitionScript`, and `CharacterTraits`:

- Build 42 uses namespaced registered character-trait resources;
- definitions support UI name/description, cost, profession status, multiplayer
  disablement, texture, recipes, granted traits, XP boosts, and exclusions;
- per-character trait collections support add/remove/query plus save/load and
  network serialization by registered resource identifier.

Consequences:

- experienceWorks should wrap registration and safe queries rather than keep a
  parallel trait list;
- registration must occur before character trait state is constructed or
  loaded;
- foodWorks may define a Cannibal trait through that API, but tissue safety and
  disease rules must remain independent of psychological tolerance.

## Work surfaces

Verified in `PropertyContainer` and `IsoObject`:

- tile/object properties expose `Surface`, table/table-top semantics, surface
  offset, and sloped-surface metadata;
- `IsoObject` calculates a surface offset from properties plus render/item
  offsets;
- these properties do not universally encode usable corpse length, width,
  clearance, access sides, load rating, or sterilizable work area.

Consequences:

- medWorks should use property-first surface detection with registered verified
  profiles/providers for missing semantics;
- unknown objects must fail closed without breaking the context menu;
- no sprite-name substring matching or global object scans are justified.

## Gore and dismemberment boundary

Native blood, holes, giblets, hit reactions, and visual synchronization are
presentation surfaces. The inspected Build 42 classes do not provide the
hierarchical, persistent, divisible detached-anatomy object required by the
Works design. Project M.O.R.T.I.S. must therefore own that logical object while
adapters request only verified native presentation effects.

## Required invariants for implementation

1. Canonical material is stored once per anatomy region.
2. Remaining, viable, and edible tissue are bounded by capacity; derived
   nutrition cannot exceed edible tissue times registered density.
3. Detaching a region transfers its entire present descendant subtree from the
   source record to exactly one detached record.
4. Missing descendants remain missing and cannot be recreated by validation.
5. Further division transfers material; it never copies it.
6. UV, injury, decomposition, harvesting, and feeding use idempotent,
   authority-owned transactions with stale-state guards.
7. Entity, corpse, detached-part, and produced-food totals reconcile through a
   transaction ledger within numeric tolerance.
8. Unknown native capabilities and unsupported objects fail closed.

## Remaining runtime validation gates

- source-to-corpse modData timing for every supported character type;
- corpse carry/drop, chunk unload/reload, save/load, reanimation, fire, and
  removal;
- hosted and dedicated-server request ordering, duplicate delivery, rollback,
  and reconnect;
- native visual synchronization for each trauma mechanism;
- native eating-state observation under latency and multiple eaters;
- generic surface interaction with rotated/multi-tile furniture;
- vanilla food creation, splitting, cooking, rotting, and consumption after
  provenance attachment.

Until those gates pass, the audited surfaces are implementation evidence, not a
claim of multiplayer compatibility.
