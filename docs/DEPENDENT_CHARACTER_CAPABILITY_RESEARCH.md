# EXT-31 — Dependent-character capability research

Status: research complete; implementation blocked on an approved, separately
owned content consumer and native multiplayer validation.

## Scope and clean-room evidence

EXT-31 approves a reusable lifecycle capability, not baby content. The inactive
`SaveTheBabies` 0.3.1 installation was inspected only as behavioral evidence. It
demonstrates that a dependent may have a durable server record, a portable
physical token, timed needs, care requests, loss transitions, migrations,
bounded client snapshots, and administrative recovery. No source, schema names,
values, content, assets, text, rewards, penalties, or implementation structure
from that mod are incorporated here.

First-party evidence comes from the existing M.O.R.T.I.S. component registry,
authority adapter, persistence/replication runtime, operation replay protection,
and the neutral provider boundary formerly used by EXT-29. Project Remnants is
explicitly unsupported; those systems are entity-oriented and do not yet
provide an authoritative record store for a dependent that may have no loaded
`IsoGameCharacter`. Reusing the weak-key runtime component table would therefore
lose state when a token or represented entity is unloaded.

## Ownership boundary

M.O.R.T.I.S. may define and validate a neutral capability contract. It must not
own dependent content, needs rules, decay rates, care effects, AI, items, world
objects, presentation, or narrative consequences.

The future content provider owns:

- stable dependent IDs and canonical records;
- persistence, migrations, lifecycle transitions, and duplicate reconciliation;
- physical entity/token binding and recovery policy;
- needs and stage definitions, rates, and consequences;
- authorization for custodians, carers, administrators, and supported actions;
- server-side mutation and the bounded snapshots it chooses to disclose.

M.O.R.T.I.S. owns only registration validation, protected discovery, detached
read-only views, capability negotiation, and fault isolation. medWorks may read a
declared patient capability or submit a provider-defined care request; it never
owns or directly mutates dependent state. experienceWorks may consume explicit
history/provenance events after its canonical source is restored.

## Proposed capability descriptor

This is a research schema, not a public API commitment. Names may change when a
real consumer is approved.

| Field | Required meaning | Constraint |
| --- | --- | --- |
| `providerId` | Canonical content owner | Nonempty, namespaced, versioned registration |
| `contractVersion` | Adapter contract compatibility | Strict semantic version |
| `dependentId` | Provider-owned durable identity | Nonempty, bounded, opaque to M.O.R.T.I.S. |
| `recordVersion` | Provider persistence schema | Positive integer; provider migrates it |
| `authorityOwner` | Writer of canonical state | Must name provider/server authority |
| `persistenceOwner` | Owner of save and recovery | Must name provider, never a UI consumer |
| `lifecycleState` | Coarse portable state | Provider-enumerated; unknown values fail closed |
| `binding` | Current representation | Kind plus bounded opaque reference; may be absent |
| `custody` | Current permissions fact | Detached IDs/roles only; no mutable player object |
| `needs` | Optional observations | Bounded list of provider-defined typed facts |
| `stage` | Optional progression observation | Opaque ID plus monotonic provider revision |
| `capabilities` | Supported read/request features | Explicit booleans or versioned capability IDs |
| `revision` | Snapshot ordering token | Monotonic provider-owned integer |

The minimum read-only snapshot should contain only provider ID/version,
dependent ID, record version, lifecycle state, binding kind, capability IDs, and
revision. Names, needs, custody details, location, medical observations, and
history are optional disclosures with independent capability and permission
checks. Registry returns must be deep copies.

## Proposed operations

Discovery should be explicit and bounded: inspect a supplied token/entity or
resolve a supplied provider-qualified ID. There must be no global inventory,
world, player, or entity scan.

Mutation, if later approved, remains a provider request rather than a M.O.R.T.I.S.
state change:

1. consumer submits provider ID, dependent ID, expected revision, action ID,
   operation ID, actor identity, and bounded arguments;
2. provider validates authority, permission, proximity/binding, current state,
   action capability, expected revision, and replay status;
3. provider commits or rejects atomically;
4. provider persists before acknowledging success and emits a new revision;
5. clients receive a permission-filtered snapshot, never the canonical record.

Required operation properties are server authority, idempotent operation IDs,
stale-revision rejection, bounded payloads, bounded replay history, deterministic
failure reasons, and provider-owned rollback/recovery. A care request must not be
modeled as a generic component setter.

## Lifecycle and binding model

A dependent record and its representation are distinct. A record may be active
while its token or entity is unloaded. Conversely, a token without a resolvable
record is an orphan and cannot authorize care.

Minimum lifecycle facts are `active`, `lost`, and `terminal`, with any richer
states provider-defined. Binding kinds should begin with `none`, `item`,
`worldItem`, or `entity`; adding a kind requires a provider version change.
Transitions must preserve a monotonic revision and provenance. Terminal state is
irreversible unless the provider declares a separate, auditable recovery
operation. Token replacement, duplication, deletion, transfer, and streamed
unload must not create or destroy the canonical record implicitly.

Reconciliation must fail closed:

- one record with several live bindings is quarantined for provider recovery;
- a binding with no record is read-only/unavailable until explicitly recovered;
- stale snapshots cannot resurrect an earlier lifecycle or custodian;
- unknown future record versions are retained by the provider and not rewritten;
- provider absence leaves its data untouched and exposes no actions;
- M.O.R.T.I.S. unload must not delete provider records or bindings.

## Synchronization envelope

Snapshots require provider ID, dependent ID, record version, revision, lifecycle,
capability set, and only permission-appropriate observations. A full snapshot is
used for first visibility/late join; later updates may be bounded deltas carrying
the base and result revisions. Missing bases, revision gaps, unknown schemas, and
oversized collections request a fresh provider snapshot or fail closed.

The provider must define visibility recipients and rate limits. Nearby status,
custodian status, medical access, and administrator access are separate reasons;
M.O.R.T.I.S. must not broadcast every dependent record. Disconnect, reconnect,
late join, ownership transfer, token movement, save/reload, and dedicated restart
remain native test gates.

## Evidence matrix

| Capability | Status | Evidence / required proof |
| --- | --- | --- |
| Neutral ownership boundary | CONFIRMED | Existing registry/provider conventions support protected descriptors |
| Detached read-only snapshots | CONFIRMED | The neutral registry supports bounded, copied provider observations; the prohibited Project Remnants adapter must be removed |
| Entity-bound component persistence | CONFIRMED BUT NOT SUITABLE | Existing M.O.R.T.I.S. runtime is keyed by loaded entities |
| Unloaded dependent record persistence | POSSIBLE / UNPROVEN | Requires a real provider-owned record store and native save/restart test |
| Item/world/entity binding | POSSIBLE / UNPROVEN | Reference behavior exists; first-party provider and Build 42 proof absent |
| Server-authoritative care requests | POSSIBLE / UNPROVEN | Build 42 commands are available, but no approved first-party action exists |
| Bounded snapshot/delta sync | POSSIBLE / UNPROVEN | Contract can require it; recipient and late-join behavior need a consumer |
| medWorks patient observation | BLOCKED | No approved dependent provider or patient schema exists |
| experienceWorks history emission | BLOCKED | Checkout 0.8.0 is restored, but no approved dependent-character history contract/consumer exists |
| Shippable dependent content | BLOCKED | EXT-31 explicitly requires a separate content proposal and owner |

## Implementation gate

Do not add a runtime registry merely to embody this document. Implementation may
begin only when an approved content provider supplies:

1. stable identity and record persistence semantics;
2. one concrete read use-case and, separately, one concrete requested action;
3. authority, permission, binding, recovery, and visibility policies;
4. schema-version migration fixtures and duplicate/orphan fixtures;
5. SP, hosted, late-join, dedicated, save/reload, unload/reload, and reconnect
   test plans.

The first code slice should then expose one provider, read one dependent snapshot,
reject one unsupported action, and prove record survival independently of its
physical binding. It must not add generic content or a global discovery scan.
