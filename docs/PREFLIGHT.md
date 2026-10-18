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

## Optional Nightfall source

Add `--nightfall <exact-Nightfall-source-root>` to either command. The default
manifest pins merged 0.30.1-dev.1 / 5690021; `--nightfall-evidence <reviewed-json>`
is available for a deliberately reviewed alternative. Supplying evidence without
selecting Nightfall is an error. Omitted Nightfall is explicitly NOT SELECTED.

The optional check verifies all selected bytes, VERSION/Mod ID/requirements and
reviewed MORTIS API 1.6, food transaction v1 and recovery-record-v1 source contracts.
It never executes the consumer tests or loads Lua. Source markers are not native
capability observations. SPXTRM, Power and Health Care installations are explicitly
NOT CHECKED; this command cannot certify the whole family. Guarded Knowledge MP
storage and native gates remain blocked even when Nightfall source checks pass.
Run the separate combined regression command in NIGHTFALL_INTEGRATION_CLOSURE.md
for scoped actual-module host coverage. Preserve old source manifests as history.

The dev.6 [installed API audit](ACTIVE_HOURS_API_AUDIT.md) separately fingerprints
additional differing loose GameTime/IsoZombie/IsoObject classes. The older
preflight baseline is preserved as historical evidence; its selected checks
are not an exhaustive clean-install audit. Establish the effective clean
client/server baseline through human review before native acceptance.

Nightfall now defaults to the true committed-byte `nightfall-5690021-git-lf.json`
manifest. The older misleadingly named `git-bytes` CRLF fixture remains historical;
see NIGHTFALL_INTEGRATION_CLOSURE.md. Default checks intentionally reject it.
