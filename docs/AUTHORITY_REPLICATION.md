# Authority and replication correction

Current development iteration: 0.26.0-dev.7. Public API 1.6.0, replication protocol 2, and existing component schemas remain separate. All peers must run this same mod build: old clients do not implement assignment-clear messages. There is no rolling mixed-build compatibility claim.

## State ownership and transitions

The server/SP authority initializes hunger and performs native writes. Client hunger observations inspect an existing component bucket without initializing defaults, drawing random values, migrating state, writing native stats, or dirtying persistent state. Returned client records are detached copies. Native HUNGER may be observed directly; starvation/desiccation metadata is not newly synchronized by this change. When no cached metadata exists, conservative defaults are observations of unavailable state, not proof of zero progression.

Assignments use the existing stable ID and component snapshot. `clearAssignment` first writes `ProjectMORTIS.assignmentClear = {stableId=oldId}` into native modData, then clears live identity, flushes components, detaches the prior behavior lifecycle, and emits `ThreatCleared`. A failed cache write leaves live identity unchanged. The server emits `ThreatClear` with protocol, server epoch, entity revision, old stable ID, and current usable native online ID. Clients finish their local cache write before clearing live identity. They neither transmit an echo nor dirty canonical components. Appearance and durability use the existing baseline-restoration paths. No new native API is assumed.

Clear records remain available after save/load or wrapper replacement, and after a subsequent assignment as historical identity evidence; only untyped entities can build a clear message. A repeat `clearAssignment` is a no-op. Reconciliation of an untyped entity with a saved clear returns that clear rather than trying to serialize a nonexistent type. A truly vanilla, never-assigned entity needs no typed-state response.

Server revisions are stored in `ProjectMORTIS.replicationRevision = {epoch,revision}` before sending. This additive field prevents counters from restarting when a native wrapper streams out/in in the same server session. A failed cache write refuses the send. A new server epoch permits fresh state after restart. These root fields do not change component versions or overwrite unrelated modData; old saves with absent fields start from the existing baseline. Downgrade behavior is unverified; keep disposable-save backups.

Typed snapshots and clears share freshness ordering per native object, including across stable-ID changes. Clears additionally require compatible current stable identity. Old typed snapshots cannot undo a newer clear, and delayed clears cannot undo a newer assignment. Native online-ID indexes remember/remove previous keys and revalidate cache hits. Network requests use indexed lookup only, avoiding an attacker-controlled full tracked-entity scan. Clients verify an incoming native online ID against the resolved entity before application. Exact native ID reuse/streaming ordering is still a runtime gate.

If a client missed several complete assign/clear cycles, its cache can name an older identity than the latest tombstone. A direct reconciliation response may replace that cache only when it echoes a live, single-use request token bound to the same native object/online ID. A broadcast, unknown/consumed token, replacement wrapper, or expired request cannot authorize this exception. Revision validation still runs first, so a late reply cannot undo a newer assignment. Tokens are protocol correlation, not permission to mutate server gameplay.

Only a successful broadcast clears global replication dirtiness. A successful directed reply does not acknowledge delivery to other clients. Failed broadcasts, including assignment/clear messages, retain a bounded-per-tick retry path; serialization failures also retain the pending broadcast. A later assignment supersedes a pending clear using current authoritative state.

## Trust boundary and bounded work

Only known request commands with table payloads and bounded nonempty IDs / finite integer online IDs are considered. If both IDs are supplied they must resolve to the same tracked entity. Admission is bounded to 32 distinct requests per player per tick and 128 globally, with same-tick duplicate coalescing. Requests must resolve within 160 tiles using the existing exposed position getters; unavailable/nonfinite coordinates fail closed. No client-requested gameplay mutation is accepted.

The numeric values above are internal protocol/work safety limits, not gameplay tuning, so they are not sandbox options. Existing gameplay options remain in authoritative server sandbox configuration. The client retains at most 512 pending stable-ID records and 512 outstanding request records, expires them, and preserves the newer queued message for a native ID. Request/reconciliation budgets remain internal; a sweep is not restarted while its current queue is unfinished.

Automatic replication handlers require their multiplayer execution side. SP still loads shared core, presentation, and the existing test harness, but does not register client/server MP reconciliation polling.

## Evidence and limitations

[TESTED offline] Regression coverage includes read-only client hunger, detached return values, clear/replay/stale snapshots, cache failure with same-revision retry, persisted revision continuity, two-recipient broadcast accounting, malformed/mismatched/far-away requests, request coalescing, failed clear/assignment retry, index replacement, pending-message ordering, lifecycle detach, and supported profile restoration. These are Lua host tests with native boundaries mocked, not SP or dedicated evidence.

Resolved from the takeover audit at the source/offline level: M-01, M-02, M-03, M-04, M-06. Remaining items:

- M-05 is corrected at the framework/offline boundary with the API 1.6.0 reserve/commit/rollback contract; see [FOOD_TRANSACTIONS.md](FOOD_TRANSACTIONS.md). Consume-only providers fail closed at consumption range; Nightfall 0.29.1 includes the merged effigy adapter. Native durability/compensation and dedicated evidence remain gated.
- Observable locomotion fields are now captured, checkpointed, and restored as described in [LOCOMOTION_RESTORATION.md](LOCOMOTION_RESTORATION.md). Missing legacy originals are refused. Dev.3 also journals/restores the override service's five observed fields and excludes competing profile writes; live owner leases, unobserved native animation/lunge bookkeeping and native durability remain open. See LOCOMOTION_OVERRIDES.md.
- Dependency metadata, imports and harness now use B47ANCEDKnowledgeAndWisdom. Actual-source research/history integration passes offline against 0.16.0 in explicit SP plus unknown/client/guarded-server refusal cases. Affected dependency MP stores are implementation-blocked; native load/save/MP remains NOT TESTED. See DEPENDENCY_MIGRATION.md and HUMAN_RUNTIME_TESTS.md.
- English names/tooltips now cover all 37 sandbox options and are catalog-checked offline. Actual non-English translation quality and native fallback remain unverified. The historical `Contents/` copy remains stale; no current package was generated.
- Native hunger/stat synchronization, corpse/save serialization, streaming/online-ID reuse, command relevance/rate behavior at high populations, headless execution, and restart/reconnect remain [RUNTIME GATE]. Fair progress under repeated permanent serializer/native failures also needs stress evidence; an unavailable provider does not become a PASS through retries.

G7 BLOCKED / NOT TESTED. Stable-release G8 BLOCKED. No packaging, deployment, Workshop upload, game/server launch, or stable tag was performed.

## Dedicated test sequence

After a current B47ANCEDKnowledgeAndWisdom stage-1 PASS, follow the MORTIS stage-2 disposable SP sequence, then run a separately authorized dedicated session with two clients on this exact mod build. Observe assignment, clear, reassign, late join, streaming out/in, reconnect, delayed/duplicate messages, server save/restart, and native online-ID reuse. Confirm both clients leave the typed lifecycle, a directed request never suppresses the other client's update, and client queries cannot write hunger. Test request bursts and far/unknown IDs without unbounded scans, then repeat with dense populations and induced send/cache failures. Record exact game/Steam build, dependency/mod/API versions, source commit, and native logs; offline results do not substitute for this sequence.

## Absorbed Active Hours boundary

The explicitly started diagnostic uses admin intent and server-only `LocomotionOverrides` calls. Its client path never applies native speed; legacy namespaces are ignored and loaded legacy diagnostics block/freeze requests. This removes the old diagnostic's client Apply route, not the engine's ownership race/overwrite uncertainty. Framework authority is not native simulation ownership, and live owner leases are not in component snapshots. The dedicated original-field journal is saved but never used to infer/replay an owner policy. See [ACTIVE_HOURS.md](ACTIVE_HOURS.md) for exact limits and dedicated tests. G2 BLOCKED, G6 NOT TESTED, G7 BLOCKED / NOT TESTED, G8 BLOCKED.

Active Hours diagnostic corrections: Set/Release require observed standing/non-busy native state; unavailable reads reject without replay. After owner release, the diagnostic retains raw samples but ends its own category assertion so other owners/ceilings are not falsely labeled native overwrite. No authority, public API, protocol or persistent schema changes are introduced.
