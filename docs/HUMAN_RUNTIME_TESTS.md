# Human runtime test queue

Current candidate: 0.26.0-dev.5; API 1.6.0; replication protocol 2.
The user clarified that tests requiring an open game are human-operated.
Automated work here is offline/source preflight only. **No game/server was
opened, mod deployed, save modified or native result collected.**

Run the [read-only preflight](PREFLIGHT.md) before selecting a test scope. It
checks exact input bytes and optional engine files without opening the game.
A BLOCKED result identifies prerequisites; it is never native test evidence.
Nightfall has [source fixes and merged-combination regressions](NIGHTFALL_INTEGRATION_CLOSURE.md)
for all four findings. Its native consumer acceptance remains a separate human suite.

## Resolve the client baseline first

Read-only inspection found an external mod JAR/Java agent in the normal launcher
configuration, with loose classes searched before the packaged engine. Selected
loose MainScreen/IsoGameCharacter classes differ from packaged bytes. Disabling
Lua mods alone does not establish a vanilla baseline. A human must establish a
clean vanilla client and isolated disposable test profile before acceptance.
No existing launcher, engine file, mod set or save was changed by this preflight.

[Portable provenance](evidence/native-test-preflight-25485521.json) records
Steam build 25485521 and hashes. The existing version.txt says
`42.21.0 4a0e9546ec`; it is a saved marker, not proof of the next executed build.
Record the actual loaded client/server versions and effective clean launch
configuration. Jar hash equality with an earlier audit is not Steam integrity
verification or proof that differing loose classes are harmless.

Freeze these exact inputs; a source PR is not an installed/merged release:

| Input | Candidate | Status |
| --- | --- | --- |
| MORTIS | Selected 0.26.0-dev.5 commit on feat/integration-ownership-model; record its SHA and match mortis-runtime-input.json | Development source, native NOT TESTED |
| Knowledge & Wisdom | 0.16.0, source head 6ba66c0d8f246d438f2e2f3c974fee9f77fdb426, merged dependency PR #1 | Clean public source; affected multiplayer APIs intentionally blocked |
| Nightfall | Exclude from creator, dependency baseline, MORTIS baseline and isolated locomotion | Consumer feeding is a later separate suite |

The 120-file dependency inventory is
[knowledge-dependency-6ba66c0-git-bytes.json](evidence/knowledge-dependency-6ba66c0-git-bytes.json).
The old 0.15.0 input remains historical; do not downgrade to recover unsafe MP
store behavior. Older current-looking handoff headings do not establish proof.

## Execute and review in this order

1. **Creator, local presentation/storage:** enable only the two selected mods in
   a disposable menu profile, outside debug mode. Follow
   [creator acceptance](ZOMBIE_CREATOR.md#evidence-and-native-acceptance): one menu
   entry, repeated navigation, every section/action/modal, mouse/Tab/shortcuts,
   controller focus/B return, 800x600/larger/scaled/too-small layouts, Unicode,
   draft save/reopen/delete/client restart, preview/export equality and no world/
   network effect. Storage corruption/future/stale/write-fault cases use backed-up
   disposable files and a verified safe fault surface; otherwise BLOCKED. The
   reviewed export fixture is not an installed content mod or 3D preview.
2. **Knowledge & Wisdom stage 1, alone:** use its current IN_GAME_TESTING.md,
   VALIDATION_0_16_0.md, MP_AUTHORITY_PLAN.md and the reusable native procedure.
   On a new disposable SP debug character run
   `B47ANCEDKnowledgeAndWisdomTestStart(true)`, follow the Foundation/Advanced
   reading/prerequisite sequence, progression observation and journal save/reload
   cases, then `B47ANCEDKnowledgeAndWisdomTestReport()`. Record observed XP; an
   API return is not an award or exact raw-XP restoration proof. Review the scoped
   SP result before MORTIS stage 2. Missing old saves/unsupported action surfaces
   remain BLOCKED, not fabricated PASS.
3. **MORTIS SP baseline:** after that review, use only the two mods and follow
   TESTER_HANDOFF.md. Keep the Active Hours diagnostic stopped. Check ordinary
   movement, physical interactions, tagged identity, research/settings and
   save/reload; finish with `mortisTestReport()`.
4. **Dedicated one-zombie/two-client experiment:** a human supplies the disposable
   server, two clients, matching content and verified server Lua/native-owner
   observation surfaces. Follow [the detailed sequence](RUNTIME_AUDIT_HANDOFF.md#stage-3---one-zombie-dedicated-server-and-two-clients).
   Do not run it until the prerequisite reviews and isolated bootstrap are
   accepted. If an affected Knowledge & Wisdom MP API is needed, stop: 0.16.0
   returns `MULTIPLAYER_STORAGE_UNAVAILABLE`; it has no bypass. A locomotion-only
   observation cannot certify dependency MP gameplay/privacy. Missing server Lua,
   native owner evidence, clean baseline or safe fixture means BLOCKED.

The SFTP diagnostics configuration supplies read-only logs, not deployment,
server launch, a second client or a server Lua console. No remote operation was
performed. Never substitute client writes or an RCON text console for verified
server execution. Full locomotion animation/lunge restoration and live lease
recovery still need their own evidence; matching five fields alone is insufficient.

## Return one record per case

| Case group | Minimum records | Initial status |
| --- | --- | --- |
| Creator | CU-01 activation/navigation; CU-02 input/modal; CU-03 layout; CU-04 Unicode/export; CU-05 save/restart; CU-06 disposable failures | NOT TESTED; clean client prerequisite BLOCKED |
| Dependency | KW-01 startup/viewer; KW-02 reading/prerequisites; KW-03 observed progression; KW-04 journal/reload; KW-05 sandbox/legacy scope | NOT TESTED |
| MORTIS | MO-01 vanilla baseline; MO-02 physical interactions; MO-03 identity/reload; MO-04 research/settings | BLOCKED pending reviewed stage 1 |
| Dedicated | LO-01 passive; LO-02 fixed tiers; LO-03 release; LO-04 ownership; separate busy/profile/failure/stream/restart rows | BLOCKED pending prerequisite reviews/setup; affected dependency MP implementation separately BLOCKED |

For each record supply case ID, exact mod commits/source hashes, actual engine
builds, role/mod list/settings, disposable fixture identity, steps, expected and
observed result, PASS/FAIL/PARTIAL/BLOCKED/NOT TESTED, and redacted evidence.
The full copyable form is in RUNTIME_AUDIT_HANDOFF.md. Preserve raw logs and saves
privately; do not commit credentials, connection/player identifiers or journals.
Return the generated dependency and MORTIS reports when exercised, plus relevant
redacted console excerpts/screenshots. A harness summary needs human review and
does not upgrade other environments. G7 and stable G8 remain BLOCKED.
