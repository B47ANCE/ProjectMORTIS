# Historical Nightfall integration audit — 2026-10-17

This record describes the original 0.30.0 input. For corrected merged 0.30.1-dev.1
source and separate passing regressions, see [current closure](NIGHTFALL_INTEGRATION_CLOSURE.md).
Original observations and their source versions remain unchanged below.

[VERIFIED] First-party source audit against Nightfall 0.30.0 commit
`6988b57b81ff0dbb859857eb79aace81c2e65c8f`, Knowledge & Wisdom 0.16.0 commit
`6ba66c0d8f246d438f2e2f3c974fee9f77fdb426`, and MORTIS 0.26.0-dev.4.
Input manifests are in `docs/evidence/`; MORTIS runtime input is pinned separately
from this iteration's eventual Git commit. No Nightfall production file changed.

[TESTED — offline Lua 5.1] `scripts/audit_nightfall_integration.py` loads the real
MORTIS services, Nightfall integration/diagnostics and dependency authority guard.
Native zombie methods are modeled. Two identified original PN_ZombieUV branches
run as source fragments, not as the entire module. Other family providers in the
diagnostic probe are API-presence stubs. This is bounded integration evidence,
not whole-family startup, native persistence or multiplayer certification.

| Finding | Exact Nightfall source | Observed result / required correction |
| --- | --- | --- |
| NF-M01 / P1 | `src/ProjectNightfall/42/media/lua/shared/ProjectNightfall/PN_ZombieUV.lua:1536–1537,1606–1610`; `PN_MortisIntegration.lua:162–166` | Base-speed ownership prevents canonical clear, but the disabled-feral branch sets phase NORMAL anyway. Probe retains Feral identity with NORMAL phase. Coordinate only Nightfall's leases/ceilings, retain pending cleanup on refusal, and commit phase only after verified clear; preserve other owners. |
| NF-M02 / P1 | `PN_ZombieUV.lua:723–725`; `PN_MortisIntegration.lua:310–315` | On-floor release refuses with `native transition busy: isOnFloor` and retains the MORTIS baseline journal, but the consumer drops `uvSlowed`. Keep cleanup pending and retry after safe admission; clear the flag only after verified release. |
| NF-M03 / P1 | `PN_MortisIntegration.lua:153–159` | Initially untyped assignment succeeds, injected nutrition failure triggers compensation, and an existing base-speed owner makes compensating clear refuse. The function returns failure while SmartFeral identity remains. Check compensation results and retain explicit pending/quarantined state; restore prior identity without stealing owners. This reproduction concerns initial untyped assignment, not all typed rollback paths. |
| NF-M04 / P2 | `PN_DependencyDiagnostics.lua:24–54` | API-presence diagnostics admit the dependency surface while the real Knowledge guard refuses server MP storage with `MULTIPLAYER_STORAGE_UNAVAILABLE`. Presence itself is valid; it does not establish MP readiness. Report capability readiness separately, including food transaction version and the guarded dependency limitation. |

Positive controls: owner release followed by profile application succeeds;
refused busy release preserves its journal. Diagnostics distinguish MORTIS mod
version from API 1.6.0. The food adapter contains the reserve/commit/rollback
contract; existing coordinator host coverage is retained. The current Nightfall
dependency lock still names older MORTIS/Knowledge inputs and does not certify
this candidate. Research construction refuses unavailable knowledge; no guard
bypass was found. Persistent wound integration remains roadmap work.

Reproduce from the MORTIS root after installing `scripts/requirements.txt`:

```powershell
python -B scripts/audit_nightfall_integration.py --nightfall <exact-Nightfall-snapshot> --knowledge-and-wisdom <exact-Knowledge-snapshot>
```

Exit 1 means findings (expected four on these inputs); exit 2 means invalid input
or probe failure; exit 0 means no probe findings, never runtime PASS. Review each
probe if source changes; do not update manifests to conceal a changed contract.

[RUNTIME GATE] Humans must validate disable/clear under ownership, prone cleanup
and recovery, failed initial assignment, streaming/rejoin/save/restart, food
contention/compensation and server/client observations on disposable fixtures.
These source bugs require correction before affected Nightfall acceptance.
No game/server was opened, repository merged, package built or mod deployed.
G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.
