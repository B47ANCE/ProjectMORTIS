# Observed locomotion baseline restoration

This compatible correction saves an original baseline before the first MORTIS type-profile movement write. It restores observed walk type, derived speed class, inherited speed modifier, crawling flag, and crawler variant when the profile is removed or assignment is cleared. It is not a complete reconstruction of all native locomotion/animation internals.

## Authority, capture, and persistence

Only SP/server authority captures or restores. A client returns before reading/creating profile defaults or writing native movement. The internal `LocomotionBaseline` service checks inverse-method availability, observes primitive values through engine getters, and requires a walk type whose engine-derived class matches the captured class. It rejects unavailable getters, uninitialized/inconsistent observations, nonfinite values, malformed records, and absent inverses before profile changes. It never reads/writes native fields directly or introduces Java code.

The record is additive under the existing saved `Mortis.ProfileState.locomotion.baseline`, with an internal baseline format version of 1. The profile component schema remains version 1 and replication protocol remains 2; current public API is 1.6.0 (the original profile correction used 1.5.0). The baseline and attempted-write marker are flushed into native modData before profile setters run. A serializer/cache failure refuses the movement write. This checkpoint is not proof of native disk durability.

Repeated reconciliation retains the original baseline. Transitioning to a different profile first restores the observed original fields, so omitted fields do not inherit the previous temporary profile. Restoring uses direct setter pairs and readback; it does not rerun randomized tier/speed initializers. Matching fields do not receive repeated writes. A failed or ignored setter retains the original record for retry, without claiming rollback of earlier successful native writes.

`clearAssignment` restores before clearing identity. A busy transition, missing legacy baseline, cache failure, or native restore failure returns false and retains the assignment at that boundary. The checkpoint remains through behavior-detach callbacks so a consumer's owner release cannot replace the original baseline with an intermediate one. After detach, a second idempotent restore completes cleanup. If a callback/native failure interrupts that second restoration, the saved pending flag survives, and untyped entities retry through their existing scheduled update path. No global scan is added. Repeated successful clears do not replay detach.

## Legacy and capability limits

An already-applied old profile has no original baseline. Its current modified values are not relabeled as original. Applying/restoring that legacy record fails explicitly; the original values require independent provenance or a disposable fresh fixture. No real save is rewritten, reset, or used for destructive testing. Downgrade compatibility for added internal records is unverified; retain save backups.

Native tier setters and `DoZombieSpeeds` also alter walk-variant/lunge/animation bookkeeping. The bounded class inspection found no verified complete getter/setter pairs for those fields. They are not reconstructed, guessed, or accessed through native fields/reflection. Thus readback success covers the five observed fields only. Full native visual/behavioral restoration is still a runtime/API gate. A Lua-only alternative for temporary effects is to limit them to directly observable/invertible movement fields, or keep explicit consumer ownership of a verified native transition. The original profile slice left `LocomotionOverrides` separate; dev.3 now uses the same observed-field service with a dedicated recovery journal, described in LOCOMOTION_OVERRIDES.md. Live owner leases are still transient.

No gameplay rates or preferences were added. Baseline format, validation tolerances, checkpoint flags, and retry cadence are implementation safety details, not sandbox gameplay options. Existing server-authoritative sandbox settings remain unchanged.

## Installed API evidence

Steam manifest build: 25485521. Full executed game version: UNKNOWN. Packaged and loose classes were inspected read-only, never loaded/executed; their bytes differ, and classloader/other installed transformations are not certified. Portable fingerprints are in `evidence/locomotion-native-25485521.json`.

- IsoZombie: public `getWalkType():String`, `setWalkType(String)`, `getSpeedType():int`, `setSpeedTypeFromWalkType()`, `isCrawling():boolean`, `setCrawler(boolean)`, `getCrawlerType():int`, and `setCrawlerType(int)`.
- `IsoZombie.getSpeedTypeFromWalkType(String):int` is static. It must not receive a zombie self argument. Class/global and function availability are checked by a read-only call; failure refuses capture/restoration.
- Inherited IsoGameCharacter: public `getSpeedMod():float` and `setSpeedMod(float)` reference the same inherited modifier used by the inspected zombie initializers. Their selected getter/setter bodies are simple field access; this is native inspection, not proof of engine invocation or synchronization.
- The existing curated source exposure trace for build 25485521 verifies the public instance/static export route. New signatures were also recorded as local draft research with runtime NOT_TESTED, not promoted to engine execution PASS.

## Validation and next runtime steps

[TESTED offline] New regressions failed before implementation, then passed for capture/readback, false crawler values, malformed/unavailable native fields, setter rejection, retry-input preservation, authority, persisted-table reload, non-recapturing reconciliation, busy deferral, failed pre-write checkpoints, retained baselines through detach, legacy rejection, canonical clear failure/retry, and scheduled post-detach recovery. These host mocks do not certify PZ behavior.

Use disposable fixtures with a newly captured baseline, an old profile without a baseline, and an interrupted/pending restore. In separately authorized SP and dedicated sessions, compare all observed values before assignment and after clear, profile replacement, native wrapper streaming, save/reload, reconnect, and server restart. Include a non-default native speed modifier and original crawler, plus concurrent consumer overrides and native busy transitions. Observe animation/lunge behavior separately; do not mark full restoration PASS from matching five-field readback. Require G7 dedicated evidence before stable G8.

The dependency blocker observed during 0.23.3-dev.2 is historical. In 0.24.0-dev.1, metadata/imports migrate to B47ANCEDKnowledgeAndWisdom and actual-source archive/history integration passes offline against 0.13.0. Native dependency and locomotion runtime gates remain open; see DEPENDENCY_MIGRATION.md.

## Active Hours consolidation

The Active Hours diagnostic now uses the shared observed-field service through `LocomotionOverrides`; last-owner release restores five captured fields and retains a persistent journal until verified cleanup. Higher-priority consumers/ceilings still determine the effective request. Type-profile locomotion writes wait while that journal owns movement; coordinate release before profile/assignment clearing. Forced profile application also refuses known busy native states. See LOCOMOTION_OVERRIDES.md and ACTIVE_HOURS.md; actual native animation/lunge/MP restoration remains gated.
