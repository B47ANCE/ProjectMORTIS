# Native zombie UV wound capability audit

Inspected 2026-08-31 from the locally installed `projectzomboid.jar`, not a
remembered API or another mod's implementation. Extracted classes and generated
Java stay in the workspace's private `.tmp-nightfall-decompile` research directory;
they are not mod/package content. This document records findings, not copied code.

## Decision: MORTIS authoritative wounds, no native BodyDamage bridge

The inspected `IsoGameCharacter` constructor assigns BodyDamage to players and
animals; ordinary zombies receive null. `getBodyDamage()` returns that field.
The character update only ticks BodyDamage when non-null. Character save and load
explicitly skip BodyDamage for zombies. `getBodyDamageRemote()` can lazily construct
a separate object, but that does not establish a canonical zombie health state,
update path or persistence path. It is not an acceptable workaround.

Consequently Nightfall must not call player burn/BodyPart mutators on ordinary
zombies. MORTIS anatomy and named wounds are authoritative. Nightfall computes
regional exposure and threshold policy; generalized MORTIS consequences translate
severe structural injury into function/systemic failure. Native HP changes, if
needed for death, must be consequences of committed trauma, not exposure damage.

## Verified clothing facts

- `IsoZombie.getItemVisuals()` chooses native visual-only or worn-inventory data
  according to zombie state (including previously fake-dead/reanimated states).
- `ItemVisual.getScriptItem()` resolves item script metadata without requiring
  generation of worn inventory items.
- `Item.getBloodClothingType()` supplies script coverage identifiers.
- `Item.getFabricType()` supplies the fabric string, which may be absent.
- `ItemVisual.getHole(BloodBodyPartType)` returns normalized [0,1] localized
  visual-hole data; absent hole storage yields zero. This is not a measured
  percentage of exposed skin. Treating it as linear transmission is an explicit
  provisional model, not a claim about physical surface area.

The coverage adapter now passes native fabric metadata to consumer protection
policy. Item-specific armor overrides still take precedence in the eventual
policy; missing fabric must not imply that helmets or armor are naked skin.

## Reproducible installed-class fingerprints (SHA-256)

- IsoGameCharacter: `3844A8542A1AF7EF8C5D6ADFD8136807BFB42E1721860348E4AC7B8B41F2D85A`
- ItemVisual: `78AF8897986C28C5948D7AD80DBF8CF372C52BD5A32DFB720586F3716E472DE6`
- Item: `6537D2EDE0A9D4670B6452482A168A3A1C6574E8BAA9E44434650EDF5C33B565`
- BloodBodyPartType: `7EA703493BC95A11C4F6E710A23C3A5CF036BC59C6399010812C279EBAD5BB7D`

Inspection used [CFR 0.152](https://www.benf.org/other/cfr/); its downloaded binary
matched the publisher's listed MD5 `8a85ada8cec494121246805a5562b82b`.

## Still unproven

Native Lua binding execution for these overloads, zombie visual persistence under
streaming, modData network transport, local burn visuals and real population cost
need runtime validation. This audit does not certify multiplayer support or the
replacement UV pipeline. No new damage path is deployed by this research pass.
