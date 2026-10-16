Project Version: 0.1.0-dev.4

# Lua speed control feasibility

## Current Nightfall/MORTIS experiment — 2026-10-16

User selected the team-owned Nightfall UV slow mechanism: MORTIS LocomotionOverrides.acquire/release calls native tier helpers on the server. New source/procedure: MORTIS_SPEED_PROOF.md; API/provenance: TEAM_API_RESEARCH.md. This differs from the original narrow-setter experiment retained below. Helpers reroll derived values and release restores only walk/category, so full restoration remains open. No Java, native activity refresh, sandbox mutation or continuous override. Movement, overwrite and observer outcomes remain NOT TESTED; G2/G6/G7/G8 unchanged.

Status: [VERIFIED source-supported candidates], [UNKNOWN runtime safety], [BLOCKED gameplay adapter]. References are retained `research/jar-source/` lines; no speed call has run in PZ.

| Method | Native effects | Limit |
|---|---|---|
| IsoZombie.doZombieSpeed(int), `zombie/characters/IsoZombie.java:4854` | Calls selector `:4858`; handles crawling and selects categories. | Global Speed=3 forces Shambler; global Speed=1/2 also participates. Explicit input alone does not isolate profile. |
| doSprinter(), `:4880` | Sets lunger, random speedMod, walk variant, animation frame speed and category; helper `:4938` sets sprint walkType and turnDelta. | Each call rerolls derived speed. Must not invoke each update. |
| doFastShambler(), `:4891` | Random speedMod, walk variant, animation rate, category and slow walkType. | Does not restore all sprinter-derived state. |
| doShambler(), `:4920` | Random speedMod, walk variant, animation rate, category and slow walkType. | Does not reset lunger or prior sprinter turnDelta. Reversible profile behavior not proven. |
| getSpeedType(), `:4930`; getWalkType(), `:5055` | Read category/walk type. | Category agreement alone does not prove movement/animation correctness. |
| IsoGameCharacter.setSpeedMod(), `zombie/characters/IsoGameCharacter.java:3775` | Sets a scalar. | Does not establish a full category adapter. |

[VERIFIED source] Direct category methods do not call DoZombieStats or makeInactive. Their own random speed/animation writes still occur. `DoZombieStats` (`IsoZombie:3327`, speed call `:3367`) can overwrite a profile at construction, load, reuse, crawl changes and native reconstruction. Existing ATTRIBUTE_READ_WRITE_CALL_GRAPH.md preserves exact caller evidence. ActiveOnly=Both avoids intentional native daily inactivity transitions; it does not prevent other stats resets.

[VERIFIED source] Locomotion still reads global Speed: IsoZombie `:3154` walking speed and `:3172` lunge; `zombie/pathfind/PathFindBehavior2.java:906`, `:985`, `:1015` path movement. Thus the required ActiveOnly=Both prerequisite is insufficient to establish category control under every vanilla Speed option. Test all options; a candidate Random baseline is [INFERRED], not an approved prerequisite or automatic configuration change.

[VERIFIED source] `zombie/characters/NetworkZombieAI.java:211` serializes speedMod/walkType; `:270` parses remote state. `zombie/popman/NetworkZombiePacker.java:240` applies owner data on server, including speedMod `:256` and walkType/derived category `:274`. A server-only mutation may be overwritten. Owner-side mutation has a native observer propagation path, but actual propagation, running flags and animation agreement are [UNKNOWN].

Ten proof questions remain: normal Lua invocation; actual movement; animation/walk type; native overwrite timing; network overwrite timing; observer propagation; ownership transfer; virtualization/reconstruction; faithful disable restoration without extra rerolls; bounded application cost. No category-only observation can close these questions.

Smallest candidate: one standing, continuously loaded zombie, fixed Sprinter/Shambler decisions from server, applied once per accepted decision by its verified simulation owner. Observe ordinary native propagation. No crawler, solar, weighted sampling or additional attribute logic in that first experiment. Connected disable restoration is mandatory and currently [BLOCKED]: restoring only an old category invokes randomization and misses derived state. Do not promise exact restoration or reapply every frame to conceal overwrites.

## Focused follow-up — 2026-10-14

[VERIFIED source] PathFindBehavior2.java:905-907, :985 and :1014-1016 writes running solely from global Speed=1. IsoZombie.java:3164-3166 walking and :3173 lunge also consider speedType=1. Therefore the same category can have different running behavior by movement state. [INFERRED] Random global Speed may permit a Sprinter category in pursuit yet lose its running flag during pathfinding. It is not an approved universal baseline; measure actual movement and animation in each state.

[CORRECTED source finding 2026-10-14] IsoGameCharacter.java:12474-12485 selects sprinting/running/normal values, but IsoZombie.java:4444-4445 overrides getTurnDelta to return turnDeltaNormal. Its inherited setTurnDelta writes that same normal field. The prior inherited-getter warning did not account for dispatch on IsoZombie. Normal turnDelta snapshot/restoration is now a source-supported Lua candidate; full category/animation/lunger restoration remains unresolved. No native activity refresh or DoZombieStats reset is permitted as a workaround.

[INFERRED alternative] If reversible categories cannot pass, limit a future Lua-only capability proposal to verified supported subsets/settings, or neutral Core with diagnostics. Such an alternative needs user scope approval and cannot be advertised as complete Active/Inactive profile control. No fallback to Java or global sandbox mutation.

## Native replication refinement — 2026-10-14

All paths below are retained research/jar-source references, not runtime evidence.

| State | [VERIFIED source] transport/application | Remaining limitation |
|---|---|---|
| lunger and running | NetworkZombieVariables.java:20-21 encodes flags; :42-43 restores them. | Native movement may rewrite flags after application; direct Shambler does not clear lunger. |
| walk type/category | NetworkZombieAI.java:227 reads getVariableString("zombieWalkType"); IsoZombie.java:986 registers lowercase "zombiewalktype" callback from walkType; remote AI :299-300 derives category from packet walk type. | Case normalization and animation callback readiness need dedicated proof. Do not add a speculative capitalization workaround. |
| speed scalar | NetworkZombieAI.java:224 encodes short(speedMod * 1000); ZombiePacket.java:88 reads short, :94 defaults 1000; server NetworkZombiePacker.java:256 divides by 1000. | Remote NetworkZombieAI.java:296 passes packet.speedMod directly to setSpeedMod; IsoGameCharacter.java:3775 assigns unchanged. Source shows asymmetric units. Runtime impact and effective client code remain UNKNOWN. |
| normal turn delta | IsoZombie.java:4444 getter; inherited setter :12484; category helper IsoZombie.java:4946 changes normal field. | No explicit turnDelta field in inspected ZombiePacket payload. Do not assume owner correction reaches observer. |
| animation/variant | Category methods mutate def animation rate and walkVariant. | Inspected packet does not serialize those fields explicitly. Animator-derived equivalence is UNKNOWN. |

[UNKNOWN / RUNTIME GATE] Scalar-unit asymmetry must be investigated before calling native observer replication safe. It may be an effective-engine issue; no game patch, observer-side compensating writer or extra custom packet is authorized. Source inspection alone cannot establish a live bug or whether another path compensates. Measure each peer's native getter and actual displacement; never require exact scalar equality when known quantization is present. Normal owner encode has sub-0.001 truncation error for positive in-range values; receiving a raw short would be a distinct scale mismatch, not quantization.

[INFERRED bounded candidate] Capture normal turnDelta through the zombie override and preserve it locally at a verified owner boundary, using its matching setter for that field only. This narrows one restoration gap; lunger, animation, running/walk type, native resets and cross-owner snapshots still block a complete adapter. No attribute or runtime gate is approved by this refinement.

## Packet-builder ordering and optional speed — 2026-10-14

[VERIFIED source; independently checked offline bytecode] ZombiePacket.java:228-235 invokes NetworkZombieAI.set and then replaces packet.walkType using chr.getWalkType(). The inner animation-variable lookup is not the final walk-type source on this outgoing builder path. Its capitalization does not establish an outgoing category blocker here. Other construction paths and actual enum round-trip remain separate questions.

[VERIFIED source] ZombiePacket.java:246-247 sets update bit 4 only when predictionType != 0. Serialization :141-146 includes speedMod only with that bit. Parse :87-96 sets speedMod=1000 when the block is absent, rather than retaining prior speed. Walk type remains unconditional (:74, :128). Therefore a category-only update can carry a walk type while reconstructing default scalar units; the proof must compare idle/no-prediction and moving/prediction states, not assume every packet carries the chosen scalar. Packet-copy :192-199 repeats the same default.

[TESTED offline / main-JAR bytecode] Remote NetworkZombieAI.parse has getfield ZombiePacket.speedMod:S at byte offset 215, i2f at 218 and invokevirtual IsoZombie.setSpeedMod(F)V at 219: no divide in that argument sequence. This strengthens the source-level unit-discrepancy finding; it is not executed engine evidence or proof of observable harm. IsoZombie.getTurnDelta has getfield turnDeltaNormal:F at offset 1 and freturn at 4. ZombiePacket.set(IsoZombie) invokes getWalkType at offset 53 and writes packet.walkType at 59. Exact method code hashes are recorded in VALIDATION.md. No parser or installed class was modified.

[UNKNOWN / RUNTIME GATE] Which prediction modes occur for the controlled baseline, when bit 4 changes, actual peer scalar/movement outcomes, enum round-trip, effective peer classes and alternative compensation remain untested. No native override, observer writer, packet modification or global sandbox workaround is proposed.

## Passive observation limits

[VERIFIED source] shouldSprint callback (IsoZombie.java:845-854) can clear a target during evaluation and reflects target/sound intent rather than speed category. It is excluded from passive telemetry and restoration snapshots. OnZombieUpdate :2900 occurs after native updateActiveState :2829; using it does not bypass native ordering or make profile writes durable. No event-only per-frame speed adapter is approved. Actual supported getter/event calls remain a runtime gate.

## Restoration API surface — 2026-10-14

[VERIFIED source] Category helpers mutate more than category: scalar, walkVariant, def.animFrameIncrease and sometimes lunger/normal turnDelta. Public getter/setter exposure is required for every captured state item; Java public instance fields do not qualify.

| State | Source-supported ordinary-method candidate | Restoration verdict |
|---|---|---|
| speedMod | IsoGameCharacter.java:3771 getSpeedMod / :3775 setSpeedMod | Matching scalar pair only; no category/animation guarantee. |
| walkType/category | IsoZombie.java:5055 getWalkType / :3371 setWalkType / :3388 setSpeedTypeFromWalkType | Can restore category derived from a recognized walk type without category reroll; enum/packet and full behavior remain runtime gates. |
| normal turnDelta | IsoZombie.java:4444 getter / inherited IsoGameCharacter.java:12484 setter | Matching normal-field pair; native peer propagation is not proven. |
| running | IsoGameCharacter.java:12366 isRunning / :12373 setRunning | Getter can mask the raw flag when endurance moodle >=3; not an unconditional raw snapshot pair. Applicability of that branch to a zombie is UNKNOWN. |
| lunger / walkVariant | Fields/helper writes in IsoZombie | No corresponding named public concrete getter/setter found in the targeted IsoZombie/IsoGameCharacter method census. Complete restoration unresolved. |
| animation rate | IsoSpriteInstance.setFrameSpeedPerFrame(F)V is public; IsoGameCharacter.getSpriteDef :6378 exposed object accessor | Setter multiplies input by static multiplier before assigning animFrameIncrease. No public rate getter found in IsoSpriteInstance concrete-method census; getFrame() is frame position, not frame rate. Direct instance-field access is not approved. |

[TESTED offline bytecode] Main-JAR IsoSpriteInstance.setFrameSpeedPerFrame reads multiplier at offset 2, fmul at 5, writes animFrameIncrease at 6. Setting a guessed constant is not restoration. IsoSpriteInstance is registered for Lua exposure (LuaManager$Exposer.java:2278), but exposure does not supply missing methods or verify actual invocation. getSpriteDef creates a sprite instance when def is null (:6379-6381), so omit it from the first passive baseline. No reflection, setter-only guess, native stats reroll or temporary object replacement is an acceptable recovery mechanism.

[INFERRED alternative for future approval] A scalar-only getSpeedMod/setSpeedMod experiment would avoid calling category helpers and their extra randomization, but changes feature scope, retains native overwrite/network-unit/global-sprint issues, and is not an approved adapter. Do not silently substitute it for fixed Sprinter/Shambler profiles. The current category proof remains conditional; only read-only baseline design can progress independently of complete rollback.

## Prepared narrow-setter experiment

ISOLATED_SPEED_PROOF.md now implements reversible walkType/category/scalar changes, deliberately omitting full category helpers, sprite/lunger/turnDelta writes and continuous overrides. This is a test of movement-speed feasibility, not full native preset equivalence. Scalars 0.60/0.90 are fixed experiment inputs. Controlled restoration covers directly written fields; actual motion/animation recovery is a runtime test. Source mapping is Sprinter=1, FastShambler=2, Shambler=3. No runtime gate advances.

## Readiness correction — 0.1.0-dev.3 / 2026-10-14

Isolated development continues while G2 blocks production approval. Existing walk/category/scalar architecture is preserved. Corrected ordinary-Lua validation so absent walk/category cannot pass nil equality; the snapshot path likewise rejects malformed native reads without crashing sample output. Fixed empty native command arguments by adding session metadata to every request, so controlled restoration and server dump no longer depend on an empty table surviving transport. Direct-field restoration and failed-setter rollback pass Lua 5.1 and 5.4 mocks; actual movement, animation and native overwrite outcomes remain NOT TESTED. No native activity, full category helper, sprite or additional attribute writes were added. See ISOLATED_SPEED_PROOF.md for the exact human procedure.

## Final runtime preparation — 2026-10-14

No new demonstrated Lua defect in the final static/source review; speed source remains unchanged. Mapping, narrow setters, no continuous correction and bounded restoration behavior remain as previously audited. Current runbook RUNTIME_TEST_RUNBOOK.md requires passive native/API/owner/scalar agreement before any speed request, then actual motion/animation/pursuit/pathfinding and 60-second overwrite measurements. Original restoration fields come from the first server DISPATCH observation, not an assumed nominal preset. Quantization tolerance does not excuse a 1000-like scalar anomaly or changed behavior. No new runtime evidence.
