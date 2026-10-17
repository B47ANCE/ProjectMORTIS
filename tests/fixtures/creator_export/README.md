# Reviewed creator export fixture

This repository-only fixture demonstrates the local creator's export contract.
It is excluded from authoritative runtime/package roots, has no Mod ID, and is
not an installable mod. Opening the creator never reads or installs these files.

- `draft.lua` is trusted test input with inherit movement, neutral durability,
  no appearance override and two deliberately missing provider references. Its
  quoted/backslash name exercises escaping. It is not the on-disk draft format.
- `Definitions.lua` is the reviewed, exact output of `Model.export(draft)`.
  It shows what an author would manually review and place under the shared Lua
  tree of a separately owned content mod. It is executable Lua: review before
  activation. Never place it in MORTIS itself or automatically evaluate exports.
- `test_creator_export_fixture.lua` compares output bytes, runs missing-trait,
  missing-behavior, successful registration and duplicate-load cases against
  real MORTIS registries/profile interpretation. Only the bootstrap is replaced.
  Provider markers exist only inside the test; they have no gameplay behavior.

Run from the repository root:

```text
python scripts/validate.py --test test_creator_export_fixture
```

When the export format intentionally changes, regenerate the golden file from
the real model, review its full diff, then run the regression. Do not weaken the
comparison to make an unexpected generator change pass.

For a later disposable native consumer test, an author must select a real Mod ID,
declare ProjectMORTIS and real referenced provider dependencies, substitute their
own namespaced identities, and install identical reviewed content on all peers.
The two example provider IDs are intentionally absent and must fail installation
until suitable separately owned providers are supplied. No spawn or assignment
policy is included. Native load order, appearance, authority, save/rejoin/restart
and multiplayer remain NOT TESTED; this fixture does not close those gates.
