# Transactional food providers — M-05

Current contract: API 1.6.0, `Mortis.FoodSources.TRANSACTION_VERSION == 1`. Project iteration: 0.25.0-dev.4. The old automatic path called destructive `consume` before `Hunger.feed` verified the native hunger setter. A rejected/ignored setter could therefore remove food without feeding the zombie. MORTIS now refuses that unsafe one-step automatic path.

## Provider registration and migration

Keep the existing provider ID, source IDs, `findNearby`, priorities, source classes and position/pathing conventions. Add all of these fields together:

```lua
transactionVersion = 1,
reserve = reservePortion,
commit = commitPortion,
rollback = rollbackPortion,
```

Each callback receives `(zombie, candidate, context)`. MORTIS creates a fresh private `context` table for that synchronous attempt and passes the same object to all phases, including compensation after a failed reserve. Store the source handle, claim identity, expected revision, before-image and commit status needed for safe compensation in that context. It is not a persisted operation ID or network payload.

| Callback | Required behavior and result |
|---|---|
| `reserve` | Validate current source identity/revision, ownership, availability and eligibility; exclusively reserve the quoted portion without irreversible removal or external notifications. Return `{reserved=true, foodValue=<finite positive number>}`. A refusal may return `{reserved=false}`. The quote, not candidate estimates or a post-consumption result, determines hunger relief. |
| `commit` | Verify this exact reservation/revision, remove the quoted portion, finish provider-owned source bookkeeping and return exactly `true`. Do not yield or emit external effects that compensation cannot reverse. False/nil/exception triggers rollback even if some source mutation occurred. |
| `rollback` | Idempotently release this attempt's reservation and undo any partial/full source mutation or bookkeeping. Return exactly `true` only when that is confirmed. It must also handle an empty/partially populated context after reserve refusal/exception, without releasing another attempt's lease. Never overwrite a newer unrelated source revision; refuse compensation if provenance is uncertain. |

Provider code owns source-specific validation, locks, revision/claim bindings, persistence and restoration. The framework cannot infer how to restore an arbitrary effigy, inventory or tissue transaction. Test the real provider's failure paths, including a competing zombie and save/restart behavior; do not merely rename `consume` to `commit` without reservation and undo support. The host fixture in `tests/test_food_source_transactions.lua` exercises the actual registration/coordinator with a bounded shared source.

Existing consume-only providers still register and can be discovered/path toward. At consumption range they return `food-source-transaction-required` without calling `consume`, with one bounded upgrade warning per provider. Providers implementing the new contract may retain an old `consume` member for their own compatibility; MORTIS will not call it. Find-only attraction providers continue their existing pathing behavior. Incomplete/unknown transaction declarations fail at registration.

Concrete consumer: Nightfall 0.29.1-dev.1 now implements this contract for ProjectNightfall.effigies. The separate consumer branch preserves IDs, reactions and nutrition, uses an exclusive revision-bound lease, stages tissue/claim/tombstone writes reversibly, and removes native objects only after successful ZombieFed. Failure can restore before-images; foreign revisions refuse uncertain compensation. Consumed tombstones cannot be re-registered. Actual MORTIS coordinator/model/event-bus host integration passes with native boundaries mocked. Native persistence/removal/replication and crash recovery remain unverified; see [runtime handoff](RUNTIME_AUDIT_HANDOFF.md). This MORTIS documentation checkpoint changes no provider runtime.

## Framework sequence and authority

1. Server/SP authority advances hunger successfully, checks hunger/vanilla-target policy, finds a nearby registered source and validates distance. Failed advancement stops before reservation. Existing sandbox hunger enablement, thresholds, search radius and food multiplier remain authoritative.
2. Require the transaction contract and a finite positive multiplier. Snapshot the current hunger component, then call `reserve`. Validate the finite positive quoted amount and scaled result before hunger writes. Zero/nonfinite values never cause source consumption.
3. Write provisional native hunger with readback when using the existing vanilla backend; stage the component cache. Call `commit` only after those operations succeed.
4. On success, clear the pending guard and emit the existing source-tagged `ZombieFed` event exactly once for this attempt. Observer failures cannot convert a committed transaction into failure. Existing callback metadata remains unchanged.
5. On any failed phase, always attempt provider rollback, native hunger readback/restoration and cache restoration as applicable. Emit no feeding event. Normal verified compensation returns the failure reason and permits a fresh attempt.

During a pending transaction, hunger queries expose a detached copy of the pre-transaction state. Direct feeding, advancement, test-state mutation, terminal-withering mutation and recursive food-seeking are refused for that zombie. Reservations protect a shared source from a second zombie; the provider must enforce that lease. This is independent of client trust: clients cannot run the canonical path or invoke these callbacks through a new command. No custom networking, sandbox setting or gameplay rate is added.

If any compensation cannot be confirmed, return `food-transaction-rollback-failed`, log a bounded error, quarantine the provider and retain the pending entity guard. Further automatic calls cannot retry the uncertain mutation. Preserve the failed fixture and diagnose/reconcile both resources; there is deliberately no blind reset or automatic retry. Provider rollback runs directly under protection and is never skipped by the callback circuit breaker.

## Persistence and limits

The existing hunger component schema/backend, starvation clock, desiccation and feed metadata remain unchanged. Successful component writes use existing persistence/replication dirty tracking. A failed transaction restores the post-advancement/pre-feed hunger state; ordinary elapsed-time advancement happened before the transaction and is not undone. Dirty flags may remain set after compensation so the corrected state can reconcile.

Reservations, guards and quarantine are transient Lua state. This is a synchronous reserve/commit/compensate boundary, **not crash-durable atomicity across arbitrary provider saves and native hunger storage**. Provider callbacks must not yield, publish irreversible side effects or silently claim rollback success. A process crash, native observer seeing a provisional value, permanently unavailable setter, failed compensation, provider contract violation and restart recovery require separate evidence/design. Do not represent a reload as proof that an uncertain transaction recovered safely. No real save is used for destructive tests.

## Evidence and required runtime tests

[TESTED offline] The regression uses actual FoodSources registration, FaultIsolation and hunger runtime with native boundaries mocked: ignored/partially throwing setters, failed hunger advancement, reserve and commit failures after partial mutations, invalid quotes/multiplier, cache failure before/after a write, dispatcher failure, callback-breaker-independent compensation, client/vanilla-target rejection, recursive mutators, two-zombie contention, observer exceptions, unsafe legacy consumption and failed-compensation quarantine. The new test failed before implementation.

[RUNTIME GATE] Validate a migrated real consumer in disposable SP and dedicated sessions. Check stock/tissue/claim identity plus hunger/starvation before and after success, rejected feed, partial commit and compensation; concurrent access; event count; observer/late-join state; native serialization; save/reload and dedicated restart. Record exact mod/API/dependency/game versions, commit and source/provider evidence. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. No deployment, packaging, launch or publication is authorized by this implementation.

## Discovery hardening in dev.2

Malformed/nonfinite coordinates, unavailable native coordinates and invalid priority scores are rejected without hiding other valid sources. Access to provider-owned position objects/getters is protected. Provider registration refuses nonfinite priorities, and invalid search radii use the established default. Equal scores resolve by provider ID instead of table iteration order. Quarantined providers are excluded before calling their discovery callback, so they cannot keep winning over a healthy source for another zombie; the unresolved original entity remains guarded.

A missing/throwing vanilla-target observation stops food seeking rather than overriding an unknown native target. Invalid consumption distances stop before reservation. Quotes must be actual finite positive numbers. A value that rounds to no hunger reduction, either in Lua subtraction or native storage readback, is compensated before stock commit. These are validation fixes, not new gameplay tuning or durable recovery guarantees.

Candidate and reservation-quote fields are plain table data, not lazy/metatable getters. A malformed lazy quote previously could throw after reservation outside callback protection; raw-field validation now rejects it and runs compensation. Native source-object position getters remain explicitly protected. The regression reproduces the former exception and verifies stock/lease/hunger restoration.
