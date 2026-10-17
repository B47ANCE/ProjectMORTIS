# Observed override restoration and recovery

Current development iteration 0.25.0-dev.4 retains public API 1.6.0. The existing
`Mortis.LocomotionOverrides` methods still compose owner priorities and tier
ceilings. The dev.3 correction changed their safety and restoration behavior; it
does not implement production Active Hours or complete native movement recovery.

## Authority and admission

Only canonical SP/server authority may mutate, checkpoint or clear. A native
write requires a nonempty state key, available boolean floor/getting-up
observations, both false, and the existing busy classifier to return false.
Unchanged effective requests make no native calls. Unknown, busy, on-floor or
getting-up states refuse mutation; there is no forced bypass or client fallback.

Before the first owner/ceiling, the existing `LocomotionBaseline` service captures
walk type, derived speed class, inherited speed modifier, crawling flag and
crawler variant, with verified available inverses and a reconstructible class.
All primitives must be valid; modified values from an old unjournaled session
cannot be certified as original. Use a fresh disposable pre-effect fixture when
upgrading an active legacy override.

## Checkpoint and composition

New internal component `Mortis.LocomotionOverrideBaseline`, schema version 1,
stores `{version=1, baseline=<five-field snapshot>}` through existing component
persistence. It is not replicated. Existing component schemas and replication
protocol remain unchanged. The native modData checkpoint precedes movement
setters; cache/serializer failures refuse those writes. This is not proof of
native disk durability. The dedicated component prevents type-profile saves
from overwriting the journal. Other component/profile data remains intact.

The original snapshot survives effective owner changes. Each new effective
request restores the observed original before its tier/walk setter, so a custom
walk does not inherit another helper's randomized scalar. The requested walk or
speed class is then read back. Ignored/throwing setters, invalid readback and
failed restoration retain the journal, invalidate deduplication and require a
coordinated `clear`; they are never reported as successful recovery.

Passive ceilings also retain a journal while they hold movement ownership.
Type-profile locomotion writes, including periodic reconciliation and the first
phase of assignment clearing, return false while that component exists. Release
all relevant owners/ceilings first, or coordinate a full clear, then retry the
profile/assignment operation. Handle the refusal; do not discard another owner's
lease or assume an onDetach callback can run before a blocked assignment clear.
Durability/appearance services retain their existing independent behavior.

Last-owner/last-ceiling release or explicit clear restores all five observed
fields and removes the journal only after successful persistence. A failed
journal-removal flush retains its recovery record. No native tier helper runs
merely to restore the baseline. Repeated successful cleanup is idempotent.

## Owner loss and persistence limits

The journal persists originals, **not consumer requests, priorities, ceiling
leases or policy**. A reloaded/wrapped entity with a saved journal and no live
owner stack refuses acquire and individual release. It does not infer which
consumer is still active or capture the modified native values as originals.
After loading components through the existing lifecycle, canonical authority
may explicitly clear only after coordinating all consumers. Then callers may
re-enroll their intended policy. Early calls before known saved components are
loaded refuse mutation, preventing a partial component flush from deleting them.
Malformed/newer journals remain blocked; there is no blind reset.

No automatic replay, recovery event handler, population scan or new networking
is added. Join/reconnect/server restart and actual native serialization remain
runtime gates. No new sandbox balance setting is appropriate: journal format,
admission/readback and recovery refusal are implementation safety rules, not
gameplay preferences. Future Active Hours enablement/profiles/rates still require
localized server-authoritative sandbox settings.

## Evidence and limits

[VERIFIED source] The installed Steam manifest remains build 25485521. The game
JAR and selected packaged/loose classes match
`evidence/locomotion-native-25485521.json`; the existing API draft reports source
hash match, invocation NOT TESTED. Full executed game version remains UNKNOWN.
No game class was executed or changed.

[TESTED offline] `test_locomotion_override_recovery.lua` uses actual MORTIS
baseline, component and persistence code with native methods mocked. It covers
checkpoint ordering/failure, five-field readback, multiple owners/ceilings,
passive leases, unchanged requests, unavailable/busy states, ignored/partially
throwing setters, failed cleanup, corrupt journals, unrelated state preservation,
profile-writer exclusion, client refusal and disposable saved-component/module
replacement. The regression failed before the correction. The existing Active
Hours real-stack case now expects the captured scalar as well as walk/class.

[RUNTIME GATE] Native helper animation/lunge/private variant bookkeeping has no
verified complete inverse. Matching observed fields does not prove behavior,
simulation ownership, synchronization or full restoration. Run the existing
one-zombie/two-client experiment, plus non-default scalar, owner handoff,
consumer release-before-clear, streaming, reconnect, save/reload and dedicated
restart fixtures. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED; Active Hours G2/G6
remain blocked/untested. Production solar/profile controllers remain deferred.
