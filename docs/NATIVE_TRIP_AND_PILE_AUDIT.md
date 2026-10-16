# Native Trip and Pile Audit

This audit records the Build 42.20 findings used by Project M.O.R.T.I.S. 0.18.0.
It is an implementation boundary, not a claim of completed in-game validation.

## Verified native trip path

Decompilation of the installed `IsoZombie` class confirms that
`knockDown(boolean hitFromBehind)` performs the complete native transition: it
sets knocked-down and stagger state, clears hit reaction, records attack
direction, sets hit force, and reports `wasHit`. `TripAdapter` therefore prefers
this method. If the method exists but throws, the adapter fails closed rather
than applying a second partial transition. The raw `setKnockedDown(true)` path is
retained only for compatible runtimes where `knockDown` is absent.

`NetworkZombieAI` serializes zombie boolean variables and animator state.
`NetworkZombieVariables` explicitly carries on-floor and fall-on-front state.
Native fall, on-ground, and get-up states remain responsible for animation and
recovery; M.O.R.T.I.S. does not implement a second state machine.

## Pile ownership and model

M.O.R.T.I.S. owns generic trip/collision interpretation, incidental local piles,
commanded pile execution, contributor/support semantics, compression, localized
crush consequences, and validated local traversal opportunities. Project
Nightfall may decide where and when Smart/Alpha Ferals order or use a pile, but
does not own its physical model. itjustWorks may expose configuration only.

`Mortis.Piles` currently implements the safe semantic foundation. Its input is a
bounded local observation supplied by an authoritative caller. Height is derived
from footprint, thickness, posture, region area, compression, and explicit
support geometry—not body count. Living mass reduces stability. Incidental and
commanded modes are distinct, and commanded state requires explicit order
authority. The model performs no world scan or engine mutation.

Version 0.17.0 adds a bounded caller-supplied local observer and property-first
support registry. The installed vanilla tile definitions verify dumpsters by
semantic container/solid/surface properties. The runtime does not identify them
by sprite name, and unknown objects are not treated as supports.

Version 0.18.0 adds non-executable local traversal proposals. They bound endpoint
geometry and require fresh height, stability, actor capability, endpoint, and
command-authority validation. They intentionally do not invoke an engine state.

## Runtime gates still open

- Observe native zombie-on-zombie contact and prone cascades under dense loads.
- Verify `knockDown` animation, recovery, save/load, late join, hosted authority,
  and dedicated-server replication.
- In-game verify property-first dumpster classification across orientations,
  moved furniture, destruction, save/load, and multiplayer replication.
- Validate corpse/living contributor snapshots, chunk invalidation, vehicles,
  windows, elevated traversal, roof transitions, and completion-time rechecks.
- Add localized crush application only after contributor contact and authority
  can be revalidated without global scans.
- Add commanded formation/execution only after a Nightfall consumer supplies a
  bounded explicit order; ordinary density never upgrades itself to strategy.

Until those gates pass, M.O.R.T.I.S. exposes calculation results but does not
teleport entities, invent wall health, or install custom global pathfinding.
