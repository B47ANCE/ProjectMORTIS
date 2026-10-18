# Hunger population scaling — 0.26.0-dev.9

[VERIFIED: source] Automatic hunger/food seeking is now admission plus a global
authority-local worker. The previous Engine performed food searches directly in
every zombie's staggered 300-tick callback. Staggering distributed work but imposed
no global ceiling. A 10,000-actor regression records 34 immediate searches in the
old code; the revised Engine queues that wave and does zero direct searches.

`HungerScheduler` owns a deduplicated FIFO of weak actor references. Each accepted
actor retains its position despite repeated callbacks; an in-flight actor cannot
enqueue itself and nested drains cannot multiply work. The existing Bootstrap
OnTick advances Scheduler then drains hunger under its shared `zombie-hunger`
budget. Repeated drains in the same scheduler frame share the limit. Each popped
node, including stale/dead/collected nodes, consumes a work unit. No global zombie
scan, sorting, array shifting or full-queue compaction is used. Enqueue, dequeue
and explicit death cancellation are constant-time. Clients neither admit nor
execute canonical work; worker eligibility is checked again at execution.

| Server sandbox setting | Default | Bounds | Existing saves |
| --- | --- | --- | --- |
| MORTISSystems.HungerWorkPerTick | 32 | Integer 1–512 | Missing uses 32; explicit valid value retained |

Names/tooltips have key parity in all existing language files with English fallback;
no new human translation is claimed. Invalid/nonfinite/out-of-range values defer
automatic work and log a bounded diagnostic. Disabled hunger drains pending nodes
incrementally without feeding or clearing earned state. If the global tick is
unavailable, automatic work is disabled and reported; it never falls back to
unbounded per-zombie searches. Existing trusted on-demand hunger queries remain.

The unchanged 300-tick admission cadence is an internal scheduling interval; the
server work budget is the meaningful performance control. FIFO metadata has a
technical 131,072-node safety ceiling. Overflow preserves all accepted work and
rejects new admissions until room exists; rejected actors may retry on their next
staggered callback. Fairness is proved for admitted actors, not arbitrary loads
beyond that ceiling. It is not a population limit or unbounded capacity promise.
Weak references do not keep zombie objects alive; missing-square, dead and collected
actors are skipped. Native stream-out lifecycle behavior still needs observation.

## Time, feeding and persistence

Hunger advances from elapsed world age, not the number of queue visits. A delayed
visit catches up in one calculation. Admission records a shared per-frame world-
age observation, so a previously uninitialized actor can also account for its
known queue delay at its first visit. This adds at most one observation-clock
query per admission frame, not one per actor; unknown/future anchors never
manufacture elapsed time. Ordinary polls keep the existing hourly
write batching; no per-tick rewrite of every actor is added. Before either direct
feeding or a transactional source meal, `advance(zombie, true)` settles the entire
pre-meal interval, including a partial hour. This fixes stale direct feeding and
pre-meal time being charged again after relief. Failed advancement refuses feeding.
Existing callers of `advance(zombie)` keep the hourly batching behavior.

The original failing direct-feed regression expected hunger 0.75 after catching
up 84 hours from 0.75, reaching full hunger and applying 0.25 relief; old code
instead returned 0.50 from its stale snapshot. The corrected test verifies the
clock checkpoint, fractional-hour accounting and subsequent seven-day starvation.
Feeding still resets continuous starvation; pending transactions, compensation,
quarantine, native Stats ownership and irreversible desiccation remain intact.

The worker stages dirty components through the existing Persistence service after
processing, outside Engine.update. This does not prove native disk durability or
cross-file atomicity. Queue metadata is transient; reload reconstructs requests
through normal zombie callbacks. Saved hunger clocks, schemas, public API 1.6.0,
replication protocol and food transaction version are unchanged. The Engine's new
diagnostic/worker helpers are additive internal scheduling surfaces, not a new
food or gameplay protocol.

## Diagnostics and evidence

`Mortis.Engine.getHungerSchedulingDiagnostics()` returns a detached authority-local
summary: queue depth/peak, configured budget, clock/authority flags, admissions,
deduplication, overflow, nodes inspected, attempts, nonthrowing checks, actual fed/
seeking results, skips/cancellations/errors and oldest/maximum queue wait in ticks.
A check returning no source is not counted as a successful feed. Exceptions are
counted and rate-limited with bounded error text. Client-local counters do not
describe the dedicated server queue. No new diagnostic networking is added.

[TESTED: offline Windows / Python 3.12.14 / Lupa 2.6 Lua 5.1] A 100,000-actor FIFO
test visits all admitted actors exactly once in 3,125 ticks at 32 units/tick.
Additional tests cover stable update order, repeated/nested drains, cancellation,
weak-reference collection, dead actors, client refusal, invalid budgets and worker
errors. The real Engine test measures 10,000 update callbacks, zero immediate
searches, 32 worker calls/staging operations in its first tick and bounded remainder.
These are operation-count assertions, not native FPS, Kahlua or MP benchmarks.

Run exact commands in VALIDATION.md. Before a stable release humans must test a
disposable dedicated server at Insane population with the exact paired Nightfall
build: server tick/frame time, peak/steady queue delay, streamed/dead actors,
feeding contention, time acceleration, seven-day qualification, save/reload,
rejoin and restart. Tune the server budget from observed headroom; reducing work
increases search latency, never discards elapsed hunger time. Third-party provider
callback cost remains the provider's responsibility. Nightfall bounds its own
legacy and reusable-frame queries. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.
No game/server launch, live deployment, packaging or Workshop upload.
