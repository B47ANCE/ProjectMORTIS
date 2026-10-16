Project Version: 0.1.0-dev.3

# Blank runtime evidence form — NOT EXECUTED

Copy this form to a PRIVATE evidence location outside the repository before filling it. It contains no runtime test results. Do not commit raw logs, world data, credentials, IP/hostnames, player names/IDs or private connection details. Use S/A/B labels. See RUNTIME_TEST_RUNBOOK.md for the operator sequence.

## Run provenance

- Run ID and variant (baseline/fixed-speed, idle-transfer or pending-transfer fault): NOT RECORDED
- Human start/end wall time with timezone: NOT RECORDED
- Tested source commit: NOT RECORDED
- Installed version observed on S / A / B: NOT RECORDED
- Relative file/SHA-256 manifests equal on S/A/B: NOT TESTED (attach sanitized manifest)
- PZ build actually observed on S / A / B: NOT RECORDED
- Main JAR hashes, effective classpath/override/agent provenance: NOT RECORDED
- Host OS / technical runtime flags (no private host identity): NOT RECORDED
- Fresh private cache/profile and NEW disposable world verified: NOT TESTED
- Private backup completed while stopped: NOT TESTED (do not include backup contents)
- Only diagnostic Mod ID enabled / Core-Night-Day disabled: NOT TESTED
- Vanilla Active Only value / vanilla Speed value: NOT RECORDED
- Both clients connected before selection / one player each / A admin: NOT TESTED
- No engine/launcher/save changes by diagnostic code: NOT TESTED

## Passive smoke — do not issue speed requests until complete

| Check | S | A | B | Evidence/time or stop reason |
|---|---|---|---|---|
| Module versioned dump / side handler initialized | NOT TESTED | NOT TESTED | NOT TESTED | — |
| Keys / F11 output / A's authorized server dump | NOT TESTED | NOT TESTED | NOT TESTED | — |
| One intended existing zombie, same transient ID | NOT TESTED | NOT TESTED | NOT TESTED | — |
| Living/standing/outdoor/continuously loaded | NOT TESTED | NOT TESTED | NOT TESTED | — |
| Usable getter samples / no API errors | NOT TESTED | NOT TESTED | NOT TESTED | — |
| Native owner presence/localOwner/remote are explainable | NOT TESTED | NOT TESTED | NOT TESTED | — |
| Zero mutation requests/accepted writes before Set | NOT TESTED | NOT TESTED | NOT TESTED | — |
| Baseline scalar/walk/category and actual movement agree | NOT TESTED | NOT TESTED | NOT TESTED | — |
| No server/current-owner STOP or pending request | NOT TESTED | NOT TESTED | NOT TESTED | — |

Passive prerequisite outcome: NOT TESTED. Mutation permitted by operator checklist: NO (until actual checks complete). B's local F11 can work while its nonadmin server Dump is rejected; identify that expected rejection rather than fabricating unauthorized mutation success.

## State and behavioral measurements

Add rows per stage/peer/time. Observer Lua revision can remain zero; it is not the native packet revision. Do not compare ticks from different peers as synchronized wall time.

| Stage + wall time | Peer | Session / Lua revision / local tick | Native ID | Owner presence / localOwner / remote | Requested category / walk / scalar | Observed category / walk / scalar | Position + displacement/time | Animation / pursuit / pathfinding / lunge | Result |
|---|---|---|---|---|---|---|---|---|---|
| Passive baseline | S/A/B separately | — | — | — | none | — | — | — | NOT TESTED |
| Shambler -> Fast Shambler | S/A/B separately | — | — | — | — | — | — | — | NOT TESTED |
| Fast Shambler -> Sprinter | S/A/B separately | — | — | — | — | — | — | — | NOT TESTED |
| Sprinter -> Shambler | S/A/B separately | — | — | — | — | — | — | — | NOT TESTED |
| Connected restoration | S/A/B separately | — | — | — | original captured fields | — | — | — | NOT TESTED |

- Initial captured fields and baseline motion/animation reference: NOT RECORDED
- Each selected speed held at least 60 real-world seconds without another Set: NOT TESTED
- F11 preservation intervals / sanitized files or video references: NOT RECORDED
- Immediate owner acknowledgment versus later native S/B evidence: NOT RECORDED
- Field restoration outcome: NOT TESTED
- Behavioral restoration outcome (matching fields alone is insufficient): NOT TESTED
- Partial setter failure / rollback / restored pre-command state, if any: NOT OBSERVED

## Counter deltas — module observations only

Record per-peer before/after deltas, not just lifetime totals. ownerWrites is successful local-owner batches, observerWrites must stay zero for this module; it does not measure all native engine writes. Restoration failure counts include rejected/failed/timed-out requests, not a measured movement verdict.

| Counter | S before/after | A before/after | B before/after | Explanation |
|---|---|---|---|---|
| requests / speedRequests / accepted / rejected | — | — | — | — |
| ownerWrites / writes / observerWrites / observerRejected | — | — | — | — |
| drift / nativeMatches / nativeMismatch | — | — | — | — |
| restorationAttempts / restores / restorationFailures | — | — | — | — |
| ownerChanges / staleCommands / duplicates | — | — | — | — |
| missingAcks / errors / apiErrors / gaps | — | — | — | — |

## Ownership fault chronology (separate run)

| Wall-time reference | Peer + local tick / revision | What was actually observed | Evidence | Inference/unknown kept separate |
|---|---|---|---|---|
| — | S | Native owner change / pending state | — | — |
| — | A | Previous owner's last write and first observed revocation | — | — |
| — | B | First observed local authorization / first accepted write | — | — |
| — | S | Lua acknowledgment accepted/rejected / STOP | — | — |
| — | S/B | Actual native stale-input rejection or effects | — | UNKNOWN until observable |

- Idle-transfer result: NOT TESTED
- Pending-transfer overlap actually reproduced: NOT TESTED
- Any stale local write, subsequent replication effect or unexpected observer mutation: NOT OBSERVED (not proof of absence)
- Native packet rejection observed independently of Lua ack: NOT TESTED
- In-flight command after STOP/deadline, if any: NOT OBSERVED
- Missing ack / explicit stop reason / point further mutations ceased: NOT RECORDED
- No bypass, blind retry, retarget, unload/replacement or restart counted as restoration: NOT TESTED

## Capability conclusions

| Capability | Source/offline context | Runtime classification | Actual evidence or blocker |
|---|---|---|---|
| Fixed movement-speed switching / actual sprint | Existing source/mocks only | NOT TESTED | — |
| Persistence without native overwrite | No continuous reapply in source | NOT TESTED | — |
| Owner-only application | Local guards; known delayed revocation race | NOT TESTED | — |
| Native observer locomotion replication | Source path; scalar discrepancy unresolved | NOT TESTED | — |
| Safe ownership transfer | Production blocker retained | BLOCKED | Runtime fault evidence pending |
| Connected behavioral restoration | Field restoration/rollback mocked | NOT TESTED | — |
| Build 42.21 / Kahlua execution | Standard Lua 5.1/5.4 offline tests only | NOT TESTED | — |

Use VERIFIED / PARTIALLY VERIFIED / FAILED / BLOCKED / NOT TESTED only with the corresponding actual evidence. State which peer, engine, version and stage were tested; one successful stage is not a complete proof.

Gate recommendation pending evidence review: G2 BLOCKED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. Do not silently change this from a filled template.

Operator summary, sanitized errors, limitations, evidence gaps and next action: NOT RECORDED.
