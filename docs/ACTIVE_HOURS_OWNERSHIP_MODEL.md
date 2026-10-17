# Isolated Active Hours ownership and reconfiguration model

0.26.0-dev.5 adds `experiments/active-hours/ownership.lua`, a pure Lua data reducer
outside runtime/package roots. It returns detached records and command proposals.
It registers nothing and calls no native setter, RNG, disk, event or network API.
Native authority/restoration proof in ACTIVE_HOURS.md still gates production.

## Inputs and ownership

The authority supplies a verified durable life identity, server-session identity,
expected record sequence, checkpoint prerequisite and desired tier. IDs cannot be
inferred from online IDs, wrappers or an assignment ID. Their real allocation,
durability and reanimation boundary remain unresolved. `authority=true` and
`checkpointed=true` are explicit simulation declarations, never trusted client
fields or native proof. A future adapter must derive them from verified authority
and storage, not accept them over the wire.

`plan` also requires a valid detached life-choice record from `life_choices.lua`:
matching life, selection revision and exact configuration key. It does not draw
or replace rolls. A checkpointed choice revision may advance through intermediate
configurations and return to an earlier key while this own lease stays unchanged;
that history belongs to the choice ledger, not the lease record. The eventual authority derives the desired tier from accepted
configuration, phase and those rolls. This reducer checks the declared tier enum,
not native astronomy or the entire future configuration controller.

The proposed owner is fixed to `ProjectMORTIS.ActiveHours.Policy`. Commands can
acquire or release only that request; no global clear, foreign-owner key or
ceiling mutation is exposed. `applied` means the last confirmed **own lease**,
not the observed effective native movement category. Other priorities/ceilings
may legitimately govern movement; release never assumes a baseline category.

## Detached record and transition rules

Experimental record version 1 contains life/session IDs, monotonic sequence,
last accepted target, last confirmed own lease and at most one pending operation.
Pending data includes operation, desired target, status and issued-attempt sequence.
It is separate from project/API/world schemas and registers no save component.
Strict plain tables, known keys, bounded IDs/keys and finite safe integers refuse
malformed/future input; saved inputs are never mutated or silently reset.

| Operation / condition | Candidate result |
| --- | --- |
| `new(life,session)` | Neutral detached record; no lease or inferred new-life permission |
| `plan(record,context,target,choices)` | Validate choice context and monotonic selection revision; queue release before replacement acquire |
| Same target / repeated phase | Retain record and rolls; no new native command |
| No effective own-tier change | Accept configuration candidate without a movement command |
| Change/disable before issue or after verified refusal | Replace the one queued target; retain refused cleanup until explicit retry, or safely cancel if no own-tier change remains |
| Change/disable while issued or uncertain | Refuse replacement; do not discard unresolved ownership bookkeeping |
| `dispatch(record,context)` | Ready only: create issued candidate and one fixed-owner command with a new length-delimited life/session/attempt/operation token |
| Applied release receipt | Mark own lease absent; commit inherit/disabled, or create a separate acquire checkpoint |
| Applied acquire receipt | Commit desired own tier and accepted target |
| Verified refusal receipt | Retain last confirmed own lease and desired target; mark refused; no automatic retry |
| `retry(record,context)` | Refused only: create ready candidate; subsequent dispatch gets a new token |
| Unknown/partial outcome receipt | Freeze as uncertain; no replay, replacement, retry or guessed rollback |

All mutating proposals require the current record sequence. Receipt tokens must
match the issued attempt; duplicate/stale/wrong-life/session results refuse.
New-session contexts cannot replay even an apparently valid old record. Reusing
an online ID does not permit reusing another life record. Issued/uncertain state
survives plain-record validation/reload without manufacturing a new command.
Explicit coordinated recovery remains external and gated; no reset API is added.

## Checkpoints and evidence limits

The caller must verify saved state and choices, perform compare-and-set writes,
and checkpoint/read back **every returned record before its dependent action**.
In particular, persist the issued candidate before sending its returned command;
persist confirmed release before dispatching the queued acquire. The reducer is
stateless: a caller reusing old snapshots can duplicate proposals. It supplies no
serializer, CAS implementation, durable outbox, atomic disk/native transaction,
transport, or exactly-once guarantee. The context flag cannot enforce storage.

An `applied` receipt requires verified own-lease completion/readback. `refused`
requires verified zero native change, such as safe pre-write admission refusal.
A generic false API result can represent partial native writes and must not be
classified as safe refusal without evidence. Unknown or lost outcomes stay
blocked for human/adapter review. Source inspection cannot settle native callback,
owner handoff, animation, save/restart or observer behavior.

Owner IDs, token format, sequence bounds and record limits are internal safety
contracts, not gameplay tuning. Proposed meaningful gameplay settings remain in
ACTIVE_HOURS_DESIGN.md; no production sandbox options or catalogs are installed.
The standalone product remains independently maintained and yields when MORTIS is
enabled; this experiment supplies no standalone implementation or parity proof.

## Offline regression coverage

```text
python -B scripts/validate.py --test test_active_hours_ownership_design
```

The regression composes real configuration keys and life-choice records with
phase/reconfiguration intents; covers acquire, release-before-replacement,
disable during refused cleanup, safe pre-issue cancellation, explicit fresh-token
retry, stale/wrong/duplicate receipts, client/life/session refusal, unknown outcome
freeze/reload, queued revision protection, invalid/future records, detached inputs
and all three modeled outcomes in both acquire/release directions. It is a host
data simulation, not native persistence, authority, performance or network proof.

Production remains blocked on native authority/restoration, durable life identity,
solar evidence, concrete storage/lease recovery and bounded population scheduling.
All runtime testing stays human-operated. G2 BLOCKED; G6 NOT TESTED;
G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.
