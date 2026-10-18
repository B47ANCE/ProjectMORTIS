# Active Hours API and crash-boundary audit — 2026-10-17

Scope: MORTIS 0.26.0-dev.6 based on merged PR #10 (`21051190c36b187cc6f594df4ecbfd99fd426845`),
installed Steam build 25485521. The saved version marker says 42.21.0 4a0e9546ec;
the version actually executed is UNKNOWN / NOT TESTED. No engine was executed.
The [portable evidence](evidence/active-hours-api-25485521.json) records SHA-256,
Lua ranges and selected packaged class member descriptors, without copied game
source or private paths. Catalog search had no dawn/dusk observation; new scoped
observations are recorded in the unmanaged local API draft, not promoted as
approved shared facts. This audit does not authorize a production adapter.

## Solar inputs

[VERIFIED — installed source] `media/lua/shared/Foraging/forageSystem.lua:1944–1951`
obtains `getClimateManager():getSeason()`, then calls `season:getDawn()` and
`season:getDusk()` and compares the results with `getGameTime():getTimeOfDay()`.
The client `Foraging/ISZoneDisplay.lua:713–723` reads the same values separately
from cloud/fog/daylight-strength values. Its lines 273–285 and 310–321 call
`self.gameTime:isEndlessNight()` / `isEndlessDay()` in moon/sun presentation.
These prove observed Lua call forms; they do not prove server availability,
weather independence, seasonal update timing, endless-mode precedence or units
under every sandbox setup. Foraging uses a strict `time > dusk` night boundary;
MORTIS's proposed `[dawn,dusk)` interval remains an explicit design choice.

[VERIFIED — packaged metadata only] ClimateManager.getSeason returns
ErosionSeason; its getDawn/getDusk descriptors return float. GameTime exposes
public Boolean endless-day/night members and float time-of-day; ErosionSeason
declares setDay(III). No setter is invoked or proposed. Member presence and Lua
callers do not certify seasonal calculation behavior or dedicated execution.

[INFERRED] The season object is the best current Lua-only input candidate.
[RUNTIME GATE] A human must record actual dawn/dusk for differing seasons,
Day/Night boundaries, Both without solar, endless modes, clock/date changes and
invalid/missing samples on the authoritative server. Keep separate owner cleanup
acceptance for clock jumps/sample loss. Do not substitute light strength or
assume client debug/UI availability on a headless server.

## Life identity and corpse boundary

[VERIFIED — framework source] `Runtime/Identity.lua:43–47` can regenerate
StableId, while clear/clearReplicated at lines 99–107 remove it. It cannot
identify an entire life independently of assignment. The create routine uses
an in-memory sequence plus wrapper/online/position observations; it is not a
durable world allocation service. Do not reuse it as the Active Hours life token.

[VERIFIED — packaged metadata only] IsoZombie.getOnlineID returns short and
stores onlineId as a short; this bounded namespace alone cannot guarantee
world-lifetime uniqueness. IsoGameCharacter has public getPersistentOutfitID
and mutable setPersistentOutfitID overloads backed by an integer outfit field.
Its name and persistence-related members do not establish a unique life token.
IsoDeadBody declares reanimate returning IsoGameCharacter and has outfit/online
identity fields, but this audit does not inspect or claim transfer semantics.
The shared grab-corpse action accesses corpse ModData for last-player provenance;
that caller does not prove zombie-to-corpse-to-reanimated token continuity.

[UNKNOWN] Allocation uniqueness, untyped-zombie enrollment, save durability,
virtualization/streaming and corpse/reanimation lifecycle are unresolved.
[INFERRED — Lua-only design candidate] A separate server-owned world namespace
plus monotonic life ledger and an independently named entity marker may be
investigated after native gates; allocation and entity checkpoint must not be
assumed atomic. Missing records are not proof of a new life. Preserve uncertain
state and require explicit reconciliation; do not install this proposal now.

## Storage, leases and crash ordering

[VERIFIED — source] Server `Foraging/forageServer.lua:26–49` uses
`ModData.getOrCreate(name)` and `ModData.transmit(name)`. This is an observed
server table/synchronization route, not a disk flush, compare-and-set, private
storage guarantee or transaction with entity state. Selected ModData member
declarations contain get/getOrCreate/add/request/transmit; there is no selected
save declaration. This bounded search does not establish that no other route
exists. IsoObject.getModData/transmitModData members likewise prove neither
Lua-side durability nor cross-store ordering.

[VERIFIED — framework source] `Runtime/Persistence.lua:186–216`
serializes components into the entity ModData table, marks the live bucket clean
and optionally transmits it. Returning true is not proof of disk completion.
`LocomotionOverrideStore.lua` checkpoints only the baseline; owner requests and
ceilings are in-memory. Its comments and override admission deliberately refuse
automatic lease resumption after owner loss. A successful component write cannot
substantiate the isolated reducer's durable-checkpoint declaration.

Concrete isolated-model findings and corrections:

| Finding | Trigger before correction | Resolution / evidence |
| --- | --- | --- |
| AH-CR01 | `acknowledge` accepted `checkpointed=false`, permitting an uncheckpointed issued candidate to become a confirmed lease; `retry` accepted an uncheckpointed refusal | Require the same checkpoint declaration on both, with a regression that failed before the fix |
| AH-CR02 | Dispatch from sequence MAX-1 produced issued MAX, leaving no sequence for applied/refused/unknown outcome | Refuse issuance without an outcome slot; boundary regression failed before the fix; the final permitted issue can still freeze unknown |

[TESTED — offline data simulation] Crash-cutpoint regressions retain pre-issue,
issued, refusal, acquired, release-pending, issued-release, release-confirmed and
uncertain snapshots. Every new-session transition refuses; lost outcome
checkpoint leaves issued state nondispatchable. Release must checkpoint before
acquire. No automatic replay, owner clear, disk CAS, session allocation or native
compensation is added. MAX is an internal serialization bound, not a setting.

[RUNTIME GATE] Atomicity between durable records and native movement is still
unproven. Even persisted-issued-before-call leaves an ambiguous crash window;
never resend merely because the outcome is absent. A torn/stale checkpoint after
native change requires external coordinated recovery. The reducer trusts caller
declarations and cannot prevent stale-snapshot reuse. A concrete storage adapter
and consumer owner-readback contract must be reviewed before production; no
finite set of mocks closes this gate. Existing experimental record version 1 is
unchanged; no runtime/world schema is registered and no rollback promise is added.

## Clean baseline and next gate

[VERIFIED — file hashes] Additional differing loose classes were found for
GameTime, IsoZombie and IsoObject; IsoGameCharacter also differs as previously
recorded. The evidence records both hashes. These observations expand the earlier
contaminated-client finding, without attributing behavior or modifying files.
Humans must establish a clean Lua-only launch and disposable profile. Jar hash
matching does not validate the effective loose-class runtime.

Reproduce the read-only fingerprint with:

```text
python -B scripts/audit_active_hours_api.py --game-root <verified-game-root> --steam-manifest <verified-appmanifest_108600.acf>
python -B scripts/validate.py --test test_active_hours_crash_design
```

Production remains gated by native authority/restoration, seasonal server proof,
independent durable identity and storage/owner recovery. Do not implement a
population controller or enable production options from this source evidence.
All runtime testing stays human-operated. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.
