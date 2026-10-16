# M.O.R.T.I.S. Weapon Compatibility Policy

## Production rule

Weapon trauma compatibility has four distinct states.

### CORE VERIFIED

Vanilla weapon classifications reviewed by the M.O.R.T.I.S. project and shipped
inside core.

Provider: `Mortis.Vanilla`

These classifications are authoritative.

### PATCH VERIFIED

A third-party weapon mod has a dedicated M.O.R.T.I.S. compatibility sub-mod.
The patch registers a verified provider and explicit item-full-type entries.

These classifications are authoritative only when the patch is loaded.

### DISCOVERED / REVIEW

The runtime scanner found a modded weapon and generated a recommendation from
its script metadata.

This is a **development aid only**. The suggestion does not silently become
official trauma compatibility.

### UNKNOWN

The weapon was discovered but did not provide enough recognized metadata for a
meaningful recommendation.

It uses the conservative runtime fallback until somebody verifies it.

## Dependency-gated compatibility patches

Every official compatibility patch is a separate Build 42 mod with its own
`mod.info`.

Example:

```text
require=ProjectMORTIS,TARGET_MOD_ID
loadModAfter=ProjectMORTIS,TARGET_MOD_ID
```

Build 42's `require=` field lists mod IDs that must be present for the patch to
load. `loadModAfter=` ensures the data patch loads after both dependencies.

This keeps compatibility optional and prevents a target-specific patch from
being enabled meaningfully without both M.O.R.T.I.S. and the supported mod.

A complete template is included under:

`compatibility-template/`

## Why patches are data-first

Compatibility patches should normally contain only:

- provider metadata;
- full item type;
- trauma channel;
- magnitude/sever/crush multipliers;
- verification notes.

They should avoid behavior hooks unless the target mod truly requires custom
runtime semantics.

That makes each patch tiny, reviewable, and easy to maintain when the supported
weapon mod updates.

## Workflow for adding a new weapon mod

1. Install/enable the target weapon mod alongside M.O.R.T.I.S.
2. Let `Mortis.WeaponCatalog` scan the final ScriptManager registry.
3. Export/read `Mortis.WeaponCatalog.formatReviewReport()`.
4. Review every target-mod weapon.
5. Confirm chop/cut/pierce/crush/ballistic behavior and relevant multipliers.
6. Create a compatibility patch from the included template.
7. Set `require=` to `ProjectMORTIS` and the exact target mod `id=`.
8. Register every verified item explicitly.
9. Test the patch with both mods in SP and MP.
10. Ship the patch as a separate optional sub-mod.

## Vanilla

Vanilla is not treated as an automatically discovered compatibility provider.
Verified vanilla definitions live in:

`Mortis/Definitions/VerifiedVanillaWeapons.lua`

The table is explicit and auditable. It should grow only through review. A
runtime catalog report can identify vanilla weapons not yet covered by the
verified table so they can be added deliberately.

## Runtime classification priority

1. exact custom runtime classifier;
2. verified core/compatibility provider;
3. explicit development override;
4. conservative generic runtime fallback.

Discovery recommendations are attached as informational metadata at step 4 but
do not replace the fallback.

This guarantees that "M.O.R.T.I.S. compatible" means somebody actually reviewed
the weapon.
