# Main-menu zombie creator

Development version 0.26.0-dev.1 adds a local definition editor to the main menu when ProjectMORTIS client Lua is loaded. It is available outside debug mode. The creator writes local drafts and Lua exports; it does not register a type, create an entity, choose spawn rates, send a command or change a running world. Public gameplay API remains 1.6.0.

## Create and save

1. Enable ProjectMORTIS and its required dependency in the active mod set, return to the main menu and select **Zombie Creator**. Per-save-only activation may not load a mod's client Lua at the main menu; confirm activation in the native test. The button sits above the main-menu legal/report buttons and is reachable through the controller focus list.
2. Choose **New** or select a saved ID and **Load**. Use the section selector for Identity, Movement and durability, Appearance, Traits and behaviors, or Lua preview.
3. Supply a unique namespaced ID such as MyZombies.CustomZombie and a display name. Core Mortis.* and ProjectMORTIS.* IDs are reserved. IDs use ASCII letters, digits, underscores and dots, with a letter-led namespace. Do not reuse another content mod's identity.
4. Movement offers inherit, shambler, fastShambler and sprinter through the existing locomotion profile API. Health and damage-taken multipliers accept finite values from 0.01 to 1000. These are content baselines, not a claim of native movement or toughness verification. Reserved/unimplemented speed, turn and lunge multipliers are not exposed.
5. Outfit, hair and beard names are optional exact asset references. Traits and behaviors are optional unique registered IDs separated by commas. Their provider mods must be loaded when installing the export. Asset presence, appearance and native rendering are not validated by this editor.
6. **Save draft** updates the local library. Replacing another saved ID prompts first. New, Load and Close ask before discarding unsaved edits. Delete prompts and keeps the editable form so it can be saved again under a new ID. Local deletion does not alter installed content or entities.

Controller navigation uses the existing panel, combo and text-entry controls; B returns when no control is being edited. Mouse, Tab through text fields, Escape, Ctrl+S (save) and Ctrl+E (export) are supported source paths. Actual controller/keyboard dispatch, focus, fonts and native visual behavior remain NOT TESTED. The form reflows on resolution changes; a viewport/scale too small for a section disables editing/export and displays a size message instead of overlapping fields.

## Preview and export

**Lua preview** displays generated source text, not a 3D zombie or live motion preview. **Export Lua** validates the same document and writes an owned basename in the vanilla Lua cache:

`Zomboid/Lua/MORTIS_ZombieCreator_<typeID>_<contentChecksum>.lua`

An identical export is reused without rewriting. A file with the expected name but different contents is preserved and reported as a conflict. No path chooser or arbitrary filename is accepted. Strings are quoted and escaped; numerical values and references are normalized. Opening the editor, saving a draft and exporting never evaluate Lua from disk.

Review the source, then manually place it in a separately owned content mod's authoritative shared Lua source, for example media/lua/shared/MyZombies/Definitions.lua. Give that mod an actual selected Mod ID and declare ProjectMORTIS plus referenced providers as dependencies; the editor does not invent a mod identity, package or Workshop item. Supply the same content and provider versions on the server and clients. The generated file refuses an already registered type ID and checks required trait/behavior providers before registration. No spawn/assignment policy is exported.

Content authors/server owners remain responsible for activation, authoritative assignment and meaningful gameplay sandbox configuration in their consumer. Draft fields do not override server sandbox values, install client-selected definitions on a server, or serve as hidden per-world settings. The editor needs no new gameplay sandbox option because it has no shared gameplay effect. Existing vanilla/MORTIS execution and multiplayer gates remain in force when a reviewed definition is used.

## Local storage and safety

The library has two fixed owned filenames: MORTIS_ZombieCreator_Drafts_A.txt and MORTIS_ZombieCreator_Drafts_B.txt, under the same local Lua cache. Each is a revisioned, checksummed data checkpoint. Drafts use explicit whitelisted key/value lines and record boundaries, never loadstring/dofile/evaluated Lua. No user-controlled paths, callbacks, unknown fields or arbitrary nested tables are accepted.

A save rereads the current revision, writes the alternate slot and verifies exact readback. It leaves the previous valid checkpoint in place. A truncated/corrupt slot can fall back to a valid peer. Stale revisions, unknown future formats, disagreeing same-revision files, unavailable readers/writers, failed readback or two invalid slots refuse mutation. Preserve files and investigate rather than blindly deleting/resetting them. Native atomic replacement, durable flush, crash recovery and Unicode round-trips are not proven by source inspection.

Technical bounds are internal: 32 drafts, 16 unique IDs in each reference list, 96-byte IDs, 120-byte names/asset references, 8192-byte serialized drafts and a bounded library read. These protect parsing/storage and are not gameplay tuning. Checksums detect ordinary corruption; they do not authenticate content. This is a local authoring tool, not a trusted server import channel.

## Authority and compatibility

All new runtime modules are client-only. They register menu/resolution/game-start presentation callbacks and chain existing MainScreen methods. There are no new zombie callbacks, tick scans, gameplay settings, network commands, server file reads, world persistence or automatic content-loader paths. No Java/JAR/bridge, injected classes or game-source changes are required.

The editor chains the menu update/focus/UI-list methods without replacing vanilla files. Other mods replacing those methods later, Lua load order and different main-menu layouts require native compatibility testing. The game-start callback closes only this editor/modal. Existing MORTIS gameplay bootstrap is unchanged apart from requiring the editor before its developer-only console gate.

English UI text and fallback are authored in 29 UI.json catalogs with identical keys; non-English values intentionally remain English fallback. JSON/key parity is checked offline. Fluent translations, native glyphs, game fallback and actual menu activation remain unverified.

## Evidence and native acceptance

The user leaves tests requiring an open game to humans. Before native testing,
follow [HUMAN_RUNTIME_TESTS.md](HUMAN_RUNTIME_TESTS.md) for the clean vanilla-client
and isolated profile prerequisite. The normal launcher contains a custom Java
agent/external mod JAR and differing loose classes; no native test was run with
it. Current automated consumer input is Knowledge & Wisdom 0.16.0; this changes
neither the editor's local-only ownership nor its unverified native UI/storage.

The repository-only [reviewed export fixture](../tests/fixtures/creator_export/README.md)
contains a trusted draft input and exact generated `Definitions.lua`. Run
`python scripts/validate.py --test test_creator_export_fixture` to compare the
generator and exercise missing-trait, missing-behavior, neutral registration and
duplicate refusal through real registries/profile interpretation. The bootstrap
is substituted; no native module load or world action is tested. These example
provider references are deliberately absent, and no installable Mod ID, real
provider behavior, package, spawn policy or automatic import is supplied.

[VERIFIED: installed Lua source] Steam build 25485521; full executed game version UNKNOWN. MainScreen event/focus methods, ISUI child/controller lifecycle, text/combobox/button/modal controls and vanilla preset file call forms were inspected. [Portable fingerprints](evidence/creator-ui-25485521.json) record the source inputs. No game code was copied or executed; four precise call-form observations were recorded in the local API draft.

[TESTED: offline Lua 5.1] Model/export, alternating library storage and modeled UI/native boundaries are covered by test_creator_model.lua, test_creator_store.lua and test_creator_ui.lua. These exercise actual editor modules and generated code against actual Types/Profile APIs. Widget/file mocks do not prove engine UI or disk behavior.

Native acceptance on disposable local data:

- Enable the mod in the main-menu active set in release mode; verify one entry, repeated menu returns, Mods/Options navigation, Lua reset and coexistence with another menu mod. No pause-menu creator or in-world activation should appear.
- Exercise every section, mouse/Tab/Escape/shortcuts, controller entry/text/combo focus/B return, modal yes/no and cancellation. Repeat at 800x600 and larger resolutions/UI scales and a too-small effective viewport. Confirm no overlap or trapped focus.
- Create, edit, duplicate IDs, save/reopen, delete/recover form and restart the client. Verify Unicode and quoted names, invalid numbers/IDs, absent providers, preview/export equality and file locations. Simulate faults only through a verified disposable test surface; do not damage real libraries.
- Verify A/B fallback, failed write/readback, stale revisions, future/corrupt files and existing export preservation with backed-up disposable files. Keep raw local paths/files private.
- Confirm the action has no world registry, assignment, spawn, networking or sandbox effect. Test manual activation in a separate content fixture with missing providers/duplicate IDs and matching server/client content. Gameplay uses still require their own SP/dedicated evidence.

Native UI/storage NOT TESTED. Overall G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. No package, installation, deployment, game/server launch or publication is authorized or performed by this development slice.
