# Project M.O.R.T.I.S. 0.24.0-dev.2 playtester handoff

Begin only after the B47ANCEDKnowledgeAndWisdom stage-1 report is reviewed as PASS. Enable
only `B47ANCEDKnowledgeAndWisdom` and `ProjectMORTIS` on a disposable single-player save,
open the Lua debug console, and run `mortisTestStart(true)`.

1. Observe ordinary untyped zombies; record whether vanilla movement and targeting remain normal.
2. Stand near a loaded zombie and run `mortisTestInspect()`. Keep that zombie nearby.
3. Fight several zombies; check hits, shoves, stomps, prone recovery, and uncommon trips.
4. Observe a dense group near walls, stairs, and low obstacles; check for displacement or group-wide trip cascades.
5. Save/quit, reload, approach the tagged zombie, and run `mortisTestPersistence()`.
6. Run `mortisTestResearch()` and follow its on-screen instructions. Confirm research stays locked when it should and becomes available when instructed.
7. Run `mortisTestSandbox()` and follow its instructions. Confirm the M.O.R.T.I.S. settings appear and that the requested test setting actually changes.
8. Mark hosted/dedicated testing BLOCKED until it is actually performed; do not infer it from single-player.
9. Run `mortisTestReport()`.

Return `%USERPROFILE%\Zomboid\Lua\theWorks Test Results - ProjectMORTIS.txt`,
`console.txt`, and screenshots for visual failures. Do not add medWorks or later
Nightfall dependencies until this stage is reviewed.


Active Hours is now a MORTIS subsystem in development. Its separate opt-in one-zombie/two-client experiment is in [docs/ACTIVE_HOURS.md](docs/ACTIVE_HOURS.md). Do not start it during the general stage-2 sequence above or enable either historical standalone proof. Native client/server activation and locomotion remain NOT TESTED.
