Project Version: 0.1.0-dev.4

# Nightfall UV slowing / MORTIS API evidence

The user selected this mechanism on 2026-10-16. Read-only inspection used authoritative src/ trees, not Contents/ mirrors or dist/ backups. Both projects identify author B47ANCE. This is authorized team-owned public API use; no dependency implementation/assets are imported, and no third-party redistribution license is inferred. No Nightfall, MORTIS or Works files were modified.

| Project | Inspected version | Exact source references |
|---|---|---|
| Project Nightfall, ProjectNightfall | 0.27.3; Workshop 3788593239 | PN_ZombieUV.lua:275-282 transitions only when UV slow changes. PN_MortisIntegration.lua:310-315 acquires/releases shambler at priority 20; :317-339 also uses fastShambler/sprinter. |
| Project M.O.R.T.I.S., ProjectMORTIS | 0.23.2; API 1.5.0 | Mortis/Runtime/LocomotionOverrides.lua:41-65 composes/deduplicates requests; :67-107 guards acquire/release. Mortis/Runtime/Adapters/LocomotionAdapter.lua:6-16 maps tiers to doShambler/doFastShambler/doSprinter. Authority.lua:12-24 permits canonical server/SP writes, rejects clients. |

[VERIFIED source] GameAdapter.call directly invokes the native method on the supplied zombie; it does not route a client-owner Apply. Override state is a weak-key in-memory table, not a replicated component. General MORTIS component snapshots do not establish locomotion override replication. Native propagation and owner overwrite remain [UNKNOWN / RUNTIME GATE].

[VERIFIED source] Release restores captured walk type/derived category, not the original scalar, lunger, variant or animation rate. Tier helpers can reroll derived values. Acceptance/release is not connected behavioral restoration. The original exact-field proof remains unchanged at dev.3.

SHA-256 evidence fingerprints, local authoritative Lua files:

- Nightfall PN_MortisIntegration.lua: 5010898ab3019e2ec7926955b5df83b5049da8df88c593dff4ea9b78918e94d2.
- MORTIS LocomotionOverrides.lua: 7485d2ac5ae4bb1150572ac622cb06acc8f9de95aa08198a5b635b07fc4af496.
- MORTIS LocomotionAdapter.lua: 6c064f07abb21da1f48e5678272d684d5ad9c277abd48bedb64daf415c892e13.
- MORTIS Authority.lua: 1a207d80444b7b06bf59a64b4a9d6912f2065f3ffc0e029195c4c021b2dc6ec7.

Independent consumer contract: one selected loaded zombie, validated admin intent, server-only canonical acquisition/release, read-only clients, no UV controller or continuous correction. Dependencies: ProjectMORTIS and experienceWorks, not Nightfall's unrelated systems. API negotiation is >=1.5.0/<2.0.0 with typed required functions; missing APIs fail closed.

[TESTED offline] Fourteen consumer boundary tests per Lua 5.1/5.4 engine. Existing MORTIS locomotion override and numeric-boundary regression files also ran read-only with their own native mocks under both engines. These establish neither Kahlua invocation nor dedicated behavior. Review: no external-mod copying, no upstream edits, team identity verified from metadata; runtime claims remain unverified. Clean-room boundary is public API consumption, with zero imported dependency implementation/assets.
