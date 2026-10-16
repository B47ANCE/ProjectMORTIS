# Project M.O.R.T.I.S. in-game validation

Project M.O.R.T.I.S. is stage 2 of the progressive Nightfall dependency test and
requires only `B47ANCEDKnowledgeAndWisdom`. Begin only after the returned B47ANCEDKnowledgeAndWisdom
stage-1 report is reviewed as PASS. Enable only `B47ANCEDKnowledgeAndWisdom` and
`ProjectMORTIS` on a disposable test save.

## Commands

| Command | Purpose |
| --- | --- |
| `mortisTestStart(true)` | Reset the local session, validate startup, and write the first report. |
| `mortisTestAuto()` | Recheck canonical identity, API negotiation, B47ANCEDKnowledgeAndWisdom research registration, core definitions, diagnostics, and report writing. |
| `mortisTestInspect()` | Tag and inspect the nearest loaded zombie, recording stable identity and anatomy. |
| `mortisTestPersistence()` | After save/quit/reload, find the tagged nearby zombie and verify stable identity in a new Lua runtime. |
| `mortisTestResearch()` | Supply the real research files and guide the tester while automatically checking premature rejection, proper unlock, and completion of all three advanced branches. |
| `mortisTestSandbox()` | Guide and verify a temporary change to a safe setting on the M.O.R.T.I.S. Systems page. |
| `mortisTestPass("note")` | Mark the next pending manual observation PASS. |
| `mortisTestFail("issue")` | Mark the next pending observation FAIL. |
| `mortisTestBlocked("reason")` | Mark the next pending observation BLOCKED by an unavailable prerequisite. |
| `mortisTestReport()` | Print and rewrite the complete report. |
| `mortisTestWhere()` | Print the Windows result location. |

Every command rewrites `%USERPROFILE%\Zomboid\Lua\theWorks Test Results - ProjectMORTIS.txt`.
A clean command is not proof of visual, engine-lifecycle, persistence, or
multiplayer behavior. PASS requires the described in-game observation. Use FAIL
for wrong behavior and BLOCKED only for a genuinely unavailable environment.

The guided sequence covers the canonical API and dependency, ordinary untyped
zombies, identity/anatomy inspection, combat and balance hooks, wall-safe pile
behavior, persistence, B47ANCEDKnowledgeAndWisdom-backed research, sandbox controls, and
hosted/dedicated authority.
