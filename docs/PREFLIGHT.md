# Read-only human-test preflight

Run from this checkout with Python; the command needs no game process or Lua VM:

```powershell
python -B scripts/preflight_runtime.py --knowledge-and-wisdom <exact-Knowledge-source-root>
```

Optionally inspect an explicitly selected installation and Steam manifest:

```powershell
python -B scripts/preflight_runtime.py --knowledge-and-wisdom <exact-Knowledge-source-root> --game-root <ProjectZomboid-directory> --steam-manifest <appmanifest_108600.acf>
```

The command prints JSON to stdout. It reads files and environment variable names;
it does not write reports, fetch Git, contact a server, modify launch settings,
load native code, deploy content or start a process. It suppresses bytecode cache
writes. Keep launcher details and raw diagnostics private. Optional alternate
`--mortis-evidence`, `--dependency-evidence` and `--engine-evidence` inputs must be
deliberately reviewed; a changed manifest is not validation of changed behavior.

It checks exact MORTIS runtime and Knowledge source inventories, versions and
Mod IDs; the reviewed overview/source binding; injected Java environment names;
selected launcher/classpath flags; packaged engine hash and selected loose-class
differences; and an explicitly supplied Steam App ID/build. No game root means
engine inputs UNKNOWN. Input hash equality is neither whole-install integrity
nor the actual effective launched configuration. It does not inspect every
possible launcher/wrapper/native library or claim a clean environment from a
small selected-class sample. Git freshness is explicitly NOT CHECKED; run the
team freshness helper separately before edits/commit/deploy/publish.

Exit codes: 0 = INPUT_CHECKS_PASS only; 1 = ERROR (bad/missing/stale inputs);
2 = BLOCKED (known limitation, unsafe baseline or missing required input).
Knowledge 0.16.0's affected MP implementation is intentionally BLOCKED even when
its bytes match. No bypass/downgrade is provided. Check individual rows: local
creator testing and dependency SP review have different scope from MP gameplay.
A human still establishes the clean baseline and records actual loaded builds.

The MORTIS manifest covers all authoritative runtime files plus root VERSION and
source info/artwork; it does not pin experiments or tools. The overview digest
follows the shared hub algorithm over source/README/VERSION, including historical
`Contents/mods` if present. A checkout with a different preserved packaging layout
therefore requires review; never delete historical files to force a pass.

Follow [the human queue](HUMAN_RUNTIME_TESTS.md) after reviewing results. All native
cases remain HUMAN / NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.
