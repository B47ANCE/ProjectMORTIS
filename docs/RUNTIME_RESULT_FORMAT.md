# Human result record validation

`scripts/check_runtime_results.py` checks privately prepared JSON records without
opening PZ, a server, saves, logs or evidence attachments. It validates structure,
case coverage, independently selected MORTIS commit, version/inventory identities,
role/mod-list declarations and contradictions. It cannot authenticate evidence,
observe behavior, review results or grant stage-1, G7 or stable G8 acceptance.

```text
python -B scripts/check_runtime_results.py human-runtime-results.json --suite creator --mortis-commit <reviewed-full-commit-SHA>
```

Use the exact candidate SHA selected independently from the submitted result.
Its runtime bytes must first match `mortis-runtime-input.json` through preflight.
The checker compares the declaration with the selected SHA; it does not fetch
Git, prove commit ancestry or establish that those bytes were installed/executed.
Use one file per suite. Exit 0 = valid structure with all cases represented,
1 = valid structure but missing cases, 2 = invalid/unavailable input. A valid file
may consist entirely of BLOCKED/NOT TESTED cases. All outputs retain G7/stable G8
BLOCKED and HUMAN REVIEW REQUIRED, even when every case declares PASS.

Schema 1 is a strict JSON object with exactly these fields:

| Field | Required data |
| --- | --- |
| `schema` | Integer 1; future formats refuse |
| `suite` | `creator`, `dependency`, `mortis`, `locomotion` or `nightfall` |
| `inputs` | Objects named `mortis`, `knowledge`, plus `nightfall` only in that suite; each has `version`, full `commit`, `inventory_sha256` matching the reviewed manifests |
| `environment` | `steam_build`, executed `client_version`, executed `server_version` (N/A for local/SP), Boolean `clean_baseline`, and `mod_ids` array |
| `cases` | Array of the case objects below, unique IDs; missing IDs report INCOMPLETE |

Knowledge-only stage 1 still records the MORTIS candidate it would unblock, but
its enabled mod list contains only `B47ANCEDKnowledgeAndWisdom`. Creator, MORTIS
SP baseline and locomotion enable only Knowledge plus MORTIS. Nightfall must
explicitly list its required family Mod IDs too; their versions/source evidence
need separate human review and are not verified by this tool.

Each case has exactly `id`, `status`, `roles`, `settings`, `fixture`, `steps`,
`expected`, `observed`, `reason`, `evidence`, `affected_knowledge_mp_api`.
All narrative fields are nonempty strings. For untested cases use a candid
NOT TESTED/BLOCKED description; do not fabricate an observation. Status is PASS,
FAIL, PARTIAL, BLOCKED or NOT TESTED. `roles` is an array: `local-client` for
creator, `sp-authority` for baseline SP cases, all of `server`, `client-1`,
`client-2` for dedicated locomotion. Nightfall accepts explicit SP or dedicated
roles. Record settings, disposable fixture labels and actual observed differences
per case, including the exact scope of bundled subcases; one PASS must not hide
untested fault surfaces or other environments.

`evidence` contains objects with `reference` (portable redacted label, no path or
URL) and `sha256` (64 lowercase hex digits). Observed PASS/FAIL/PARTIAL requires
evidence, a declared clean baseline and actual build declarations. References
are never opened; content and truthfulness are human-reviewed. Preserve raw logs,
saves, player data and connection details privately. The tool prints only status,
missing case IDs and counts, never submitted text or private paths. Duplicate
JSON fields, NaN/Infinity, oversized files, linked files, extra fields and unknown
cases refuse. `human-runtime-results.json` is ignored, not a public evidence store.

`affected_knowledge_mp_api` is Boolean. With the selected guarded Knowledge 0.16.0
input, PASS with this flag true is contradictory and refused. This declaration
does not discover API use or prove that false is accurate; humans must review it.

Required case sets:

- Creator: CU-01 through CU-06, as detailed in ZOMBIE_CREATOR.md.
- Dependency: KW-01 through KW-05, as detailed in HUMAN_RUNTIME_TESTS.md.
- MORTIS: MO-01 through MO-04, as detailed in HUMAN_RUNTIME_TESTS.md.
- Locomotion: LO-01 through LO-04 plus LO-BUSY, LO-PROFILE, LO-FAILURE, LO-STREAM,
  LO-RESTART; these are labels for the existing separate busy/profile/failure/
  streaming/restart rows in RUNTIME_AUDIT_HANDOFF.md, not new runtime APIs.
- Nightfall: NF-M01 through NF-M04; perform the applicable recovery/cleanup and
  readiness subcases from NIGHTFALL_INTEGRATION_CLOSURE.md and Nightfall's recovery
  handoff. A PASS here does not certify the whole family or transactional feeding.

`tests/test_runtime_results.py` contains synthetic declarations for schema
regressions only, never actual results. No initial native PASS record is supplied.
