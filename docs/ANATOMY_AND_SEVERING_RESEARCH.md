# Project M.O.R.T.I.S. Anatomy and Severing Research

Target: Project Zomboid 42.20.3

This document defines the verified engine surface and the ownership boundary
between Project M.O.R.T.I.S., medWorks, and Project Nightfall. Project
M.O.R.T.I.S. does not add player amputation, zombie dismemberment actions, or
detached limb items. It provides the authoritative, reusable API those systems
consume.

## Ownership

### Project M.O.R.T.I.S.

- anatomy profiles, hierarchy, aliases, and entity-profile resolution;
- authoritative attached/absent/disabled/destroyed anatomy state;
- validated sever-state transitions and descendant propagation;
- neutral sever events and consequence-provider hooks;
- persistence, replication, idempotence, and compatibility adapters;
- neutral detached-part provenance schema and validation;
- safe wrappers around supported engine rendering primitives.

### medWorks

- tools and medical capability rules;
- context menus and timed amputation/dismemberment actions;
- treatment, pain, bleeding, infection, operation quality, and recovery;
- detached limb items, models, decay, condition, and world spawning;
- writing validated detached-part provenance after an authoritative operation.
- learned-procedure content: magazines for non-obvious field first aid and
  medical books for complex surgery, with medWorks validating that knowledge
  before requesting an authoritative anatomical operation.

Project M.O.R.T.I.S. does not inspect publications, learned recipes, First Aid
skill, or medical procedure progression.

## Topology-owned attachment sockets

Attachment sockets belong to registered anatomical topology from entity
creation. Severing or removing a natural region does not create a new container
or alter the species schema; it changes whether the existing socket is
available. Socket definitions are content-neutral and may be consumed by
prosthetics, braces, creature equipment, mutations, or other extensions.

The current implementation adds authoritative installed-attachment state, immediate modData
persistence/transmission, bounded operation replay protection, and neutral
transition events. Capability aggregation, explicit network request handlers,
late-join verification, and medical procedures remain separate milestones.

### Project Nightfall

- effigy recipes and construction;
- interpretation of limb region, condition, and source human-type provenance;
- data-driven effigy effects on Nightfall zombies;
- Nightfall-specific balance, AI reactions, and presentation.

Nightfall must not infer source type from item names. medWorks must not encode
Nightfall effects. Both consume neutral Project M.O.R.T.I.S. contracts.

## Verified 42.20.3 engine facts

The following facts were checked against the installed 42.20.3
`projectzomboid.jar`, not inferred from older documentation.

### `IsoGameCharacter.amputations`

- `IsoGameCharacter` declares `public final ArrayList<String> amputations`.
- `IsoPlayer` and `IsoZombie` inherit it.
- The only Java classes in the installed jar whose constant pools reference the
  field are `IsoGameCharacter` and `ModelInstance`.
- `ModelInstance.Update()` clears the animation player's dismember list, looks
  up every stored string in `SkinningData.boneIndices`, and passes the resulting
  integer to `AnimationPlayer.dismember(int)`.
- The strings are therefore skinning-bone names, not `BodyPartType`,
  `BloodBodyPartType`, or `CharacterMask.Part` identifiers.
- The lookup is used without a null check. An unknown bone name can fail while
  the model is updating. Project M.O.R.T.I.S. must never forward unvalidated
  third-party strings to this list.
- No save/load code in `IsoGameCharacter` consumes the field, and no other Java
  class references it for persistence or networking. It is not an authoritative
  saved anatomy system.
- The list feeds rendering/animation model state. No code was found that applies
  gameplay restrictions, body damage, bleeding, detached-item creation, or
  medical consequences from it.
- The update path only applies the list when the character's distance to the
  local player is greater than zero. Self-view behavior therefore requires an
  in-game experiment and must not be assumed.

### Animation and ragdoll support

- `AnimationPlayer` exposes a public integer `dismembered` list and a
  `dismember(int bone)` method.
- Ragdoll code contains joint-detachment and animation-dismember calls, but the
  inspected 42.20.3 paths are guarded by constant-false conditions. This is
  dormant/incomplete infrastructure, not a production severing API.
- `DoSwingCollisionBoneCheck` tests distance from one specified skinning bone to
  a character. It does not return the body region actually struck by an ordinary
  weapon swing.
- Ragdoll combat damage internally carries a `RagdollBodyPart`, but Lua event
  exposure and stable use for ordinary melee hit localization remain unverified.

### `CharacterMask.Part` granularity

The installed enum contains:

- `Head`
- `Torso`, subdivided into `Chest` and `Waist`
- `Pelvis`, subdivided into `Belt` and `Crotch`
- `LeftArm`, `LeftHand`, `RightArm`, `RightHand`
- `LeftLeg`, `LeftFoot`, `RightLeg`, `RightFoot`
- `Dress`

Its blood-region mapping combines:

- upper arm and forearm into one arm mask;
- upper leg and lower leg into one leg mask;
- hands and feet as separate masks.

Consequently, CharacterMask can isolate a hand or foot, but cannot independently
hide a forearm versus upper arm or a lower leg versus upper leg. It cannot meet
the complete logical anatomy granularity by itself.

### Visual masks

- `HumanVisual.GetMask(ItemVisuals)` starts with a character mask and combines
  masks from item visuals.
- `ItemVisual.getClothingItemCombinedMask(mask)` delegates to the associated
  `ClothingItem` asset.
- `HumanVisual` supports body visuals independently of ordinary worn inventory
  through `getBodyVisuals()`, `addBodyVisual...()`, and
  `removeBodyVisualFromItemType()`.
- Body visuals and item visuals have explicit save/load methods.

These APIs make a body-bound invisible mask visual plausible for the mask parts
listed above. They do not prove that an authored invisible item will hide every
body and clothing mesh, survive every model reset, or synchronize correctly.
Those are experimental questions.

## Inferences requiring an in-game experiment

- A validated skinning-bone name in `amputations` should affect the animated
  model, but the exact geometry removed, child-bone behavior, clothing behavior,
  first-person/local-player behavior, and model-reset behavior are unconfirmed.
- A body visual may persist more cleanly than wearable inventory and may apply a
  CharacterMask without being removable as equipment.
- Whole-limb native bone dismemberment may hide skinned clothing automatically;
  rigid or separately attached clothing models may still float.
- Server-authoritative Project M.O.R.T.I.S. state plus explicit replication can
  drive late-join reconstruction, but the vanilla `amputations` list cannot be
  relied upon to do so.

## Unsupported or unavailable as a complete solution

- treating `IsoGameCharacter.amputations` as saved/networked anatomy;
- passing `BodyPartType` names directly to the native list;
- obtaining forearm/upper-arm or lower-leg/upper-leg visual granularity from
  CharacterMask;
- assuming dormant ragdoll joint detachment is usable production functionality;
- claiming actual melee bone-hit resolution from `DoSwingCollisionBoneCheck`;
- claiming multiplayer compatibility before server/late-join experiments.

## Production architecture

Project M.O.R.T.I.S. logical anatomy remains authoritative even if a visual
adapter cannot represent a region perfectly. A sever transition should be:

1. requested by an authorized consumer such as medWorks;
2. validated against entity profile, current state, and server authority;
3. applied once to the selected region and all anatomical descendants;
4. persisted and assigned a monotonic transition/event identifier;
5. replicated to clients;
6. emitted as a neutral event;
7. rendered through the best registered visual adapter;
8. optionally converted by medWorks into a detached part carrying provenance.

The engine adapter must use a per-model allowlist mapping logical regions to
verified bone names. It must not accept arbitrary bone strings from consumers.
Mask-based and model-variant adapters remain registered fallbacks rather than
being embedded in anatomy state.

## Detached-part provenance contract

Project M.O.R.T.I.S. should validate a neutral serializable record with at least:

- schema and schema version;
- unique sever-event identifier for duplicate prevention;
- anatomy profile/species identifier and region identifier;
- side and included descendant regions;
- source stable identifier when permitted;
- source classification snapshot expressed as registered traits/components;
- condition, freshness/decay timestamp, contamination, and treatment metadata;
- cause/source/actor identifiers where available;
- creator mod identifier (`medWorks` for medWorks operations).

Nightfall may interpret registered source classifications and part combinations
for effigies, but Nightfall-only effect data does not belong in this record.

## Required first experiment (medWorks-owned)

The first experiment should sever only the left hand and expose explicit stages:

1. write the Project M.O.R.T.I.S. logical transition;
2. add one allowlisted left-hand bone to the native render list;
3. force a supported model refresh;
4. verify local player, remote player, zombie, corpse, clothing, save/reload, and
   late-join behavior;
5. create one medWorks detached-hand test item with validated provenance;
6. verify that repeating the same event neither severs nor spawns twice.

No forearm, full-arm, leg, or head implementation should be expanded until this
experiment establishes which visual adapter is viable.

## Zombie hunger and desiccation

The installed 42.20.3 classes were also checked before adding a Project
M.O.R.T.I.S. hunger concept.

### Verified vanilla behavior

- `IsoZombie` inherits the generic `IsoGameCharacter` stats container, which
  includes `CharacterStat.HUNGER`.
- `IsoZombie.calculateStats()` overrides the shared implementation with an empty
  method. Vanilla therefore does not advance inherited hunger for zombies.
- Player nutrition is constructed, updated, saved, and loaded by `IsoPlayer`;
  no equivalent zombie nutrition object exists.
- `ZombieEatBodyState` chooses an eating duration and maintains an eating target.
  It neither checks hunger nor replenishes a hunger or nutrition resource.
- Vanilla zombie save/load does not establish a hunger-driven desiccation or
  withering lifecycle.

Project M.O.R.T.I.S. may therefore provide a separate generic zombie biological
resource without duplicating functional vanilla behavior. It must not reuse the
player hunger stat: doing so would couple zombie biology to player moodles,
nutrition tuning, and update assumptions.

### Planned neutral resource

The resource will be server-authoritative, persistent, and exposed independently
of Nightfall. It will track at least satiety/hunger, irreversible desiccation,
last evaluated world age, and terminal-withering state. Consumers can register
food values and feeding policies; vanilla corpse eating can be observed through
an adapter without replacing its animation/state machine.

Elapsed time is calculated from in-game world age, including bounded catch-up
when a zombie streams back in. Desiccation progresses slowly under sustained
hunger and reaches terminal withering only after a sandbox-configurable period
measured in in-game years. Feeding can reduce hunger and slow or stop additional
desiccation, but does not magically restore tissue already lost.

Project M.O.R.T.I.S. owns the meter, persistence, transitions, and neutral
events. Nightfall may use hunger to decide whether a zombie eats a human-part
effigy. It does not own the meter.

### Vanilla target reuse and first implementation scope

Installed 42.20.3 code confirms that `IsoAnimal` extends `IsoPlayer`. The normal
`IsoZombie.spotted()` path accepts a living animal as an `IsoGameCharacter`, can
select it as the zombie target, and drives the ordinary pursuit/pathing logic.
Project M.O.R.T.I.S. must not duplicate that player/animal detection or chase.

The inspected vanilla `AttackState` clears an `IsoAnimal` target before applying
the player body-damage reaction, so successful animal biting/killing was not
established by this code review. That does not justify replacing the confirmed
vanilla chase path; it remains a separate runtime-test question.

The first M.O.R.T.I.S. hunger implementation stays deliberately small:

- zombies have a persistent hunger/desiccation resource and are conceptually
  always interested in food;
- vanilla continues to discover and chase players and living animals;
- a registry accepts local food-source providers for objects vanilla cannot
  target, such as Nightfall effigies;
- providers are queried only for a bounded nearby candidate when the zombie is
  eligible to reconsider its current action;
- the behavior never performs a global source scan and never steals a higher
  priority active vanilla target;
- arrival/consumption is claimed authoritatively and reports a food value back
  to the hunger API.

This adds behavior around nearby registered sources without replacing base
zombie AI.
