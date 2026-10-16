> CURRENT SCOPE — Lua-only custom behavior profiles supersede native activity control. Retained source evidence is historical and does not prove normal Lua invocation or dedicated multiplayer behavior. See LUA_ONLY_API_AUDIT.md and LUA_MULTIPLAYER_AUTHORITY.md; no runtime gate has passed.

# Dynamic attribute evidence matrix

2026-10-08. Build 42.21, unchanged JAR SHA256 E1A69EB743EDE60B213A0FE7F8B83D4FCAB773036D256CC4543A336F3B058A33. Project version unassigned. All source paths below are relative to research/jar-source. SOURCE-SUPPORTED means [VERIFIED] source inspection, never VERIFIED RUNTIME. No attribute is runtime-approved.

## Complete DoZombieStats trace

`zombie/characters/IsoZombie.java:3327`, public void DoZombieStats():

1. Cognition: assigns 1 when sandbox cognition=1; when =4 samples doorOpeningPercentage to assign 1 or 0. Other values do not assign in this method.
2. Strength: only initializes when strength=-1. Sandbox 1/2/3 map to 5/3/1; random setting 4 uses Rand.Next(1,5). Do not reinterpret the upper bound without verifying Rand semantics.
3. Memory: random sandbox 5 samples four categories, 6 samples three excluding category zero. Fixed categories assign only at memory=-1; random-category branches may reassign an existing value. Assigned native values are 1250/800/500/25.
4. Sight: unconditionally assigns sandbox category or random category (4: Next(3)+1; 5: Next(2)+2).
5. Hearing: same category/random structure as sight.
6. Calls doZombieSpeed() (:4850), then initCanCrawlUnderVehicle() (:4158). Both contain random decisions and derived writes.

There are no other calls or assignments in this method. Toughness/health, decomposition and environmental-attack configuration are not recalculated here. Constructor (:605), load (:1162), crawler-load branch (:1182), reuse (:3787), toggleCrawling (:4230/:4234), and reactivation (:4500) are observed callers; this is not a claim that no uninspected external caller exists.

Entering inactivity (:4486) calls only doZombieSpeed after setting inactive=true, speedType=3, running=false and slow walkType. Leaving sets speedType=-1/inactive=false and calls the entire DoZombieStats method. Never force an activity toggle merely to refresh profiles.

## Evidence matrix

| Attribute | Native writes/readers | Recalculation and lifecycle | Classification / blocker |
|---|---|---|---|
| Speed | public doZombieSpeed(int), getSpeedType; speedType 1 sprinter, 2 fast shambler, 3 shambler; :4854–4964 | Writes speedMod, lunger, walkVariant, walkType, animation increments and sometimes turn delta. Crawlers have a separate branch. Global sandbox speed also participates after explicit category selection. Network parse derives speedType from walkType. | SOURCE-SUPPORTED categories; BLOCKED safe profiles. Calling doZombieSpeed(int) alone is not an independent category override under all sandbox settings. |
| Strength | public int strength (:465); DoZombieStats initializes; IsoDoor.Thump :1070 reads it | Reuse resets to -1. IsoDoor :1071 also reads sandbox strength; IsoGameCharacter :12508/:12511 consults global strength for defense. | SOURCE-SUPPORTED partial field; BLOCKED complete attack-strength semantics and replication. |
| Toughness | reuse sets health by sandbox toughness (:3801–3811); constructor starts health (:579) | Health is damageable current state, not an independent toughness multiplier. No toughness recalculation in DoZombieStats. | SPAWN-ONLY observed baseline; BLOCKED runtime profile. Resetting health could heal or kill an already damaged zombie; injury-preserving semantics unresolved. |
| Sight | public int sight (:468); detection reads :1975/:2332; vision radius :4777/:4780 | DoZombieStats overwrites it. Radius also tests sandbox sight with OR conditions; field assignment cannot cancel a global modifier. | SOURCE-SUPPORTED partial; BLOCKED complete profile. Cached radius/derived update timing and replication unresolved. |
| Hearing | public int hearing (:469); WorldSoundManager.getHearingMultiplier(IsoZombie) :419–435 | DoZombieStats overwrites it. Obstructed sound targeting in IsoZombie :1579/:1582 reads sandbox directly; WorldSoundManager also reads sandbox :132/:378. Clothing/weather modifiers remain native. | SOURCE-SUPPORTED partial; BLOCKED all-reader consistency and replication. |
| Memory | public int memory (:467); target expiry :2983 | DoZombieStats may reroll random modes. getSandboxMemoryDuration (:4534–4546) reads sandbox and inactive directly, rather than memory field. | SOURCE-SUPPORTED partial; BLOCKED complete target-memory semantics. |
| Cognition | public int cognition (:466); IsoDoor.Thump :1053; IsoThumpable readers | DoZombieStats may assign/reroll; reuse resets -1. | SOURCE-SUPPORTED door interaction; BLOCKED complete intelligence path and replication. |
| Decomposition | No verified dynamic adapter found in scoped trace | Not written by DoZombieStats; aging and persistence readers not established | UNKNOWN; no functional option. |
| Environmental attacks | ThumpState delegates native object thumping; objects read strength/cognition | No independent per-zombie environmental-attack field verified. Door damage has global sandbox dependencies. | UNKNOWN; no functional option. |
| Under-vehicle crawling | private boolean; public isCanCrawlUnderVehicle/setCanCrawlUnderVehicle; init :4158–4189 maps 0/5/10/25/50/75/100% | Reinitialized by DoZombieStats. toggleCrawling saves/restores it. ZombieStateFlags.intFromZombie :41 includes it; load :1185 restores initialized flag. | SOURCE-SUPPORTED setter and population-state serialization; BLOCKED actual pathfinding, client replication and safe profile lifecycle. |

Lua registration exposes IsoZombie, but public fields/methods only support a source-level accessibility inference. Actual Lua writes, Java bridge invocation, reflected exclusions, safe execution side and gameplay effects remain UNKNOWN / NOT TESTED.

All requested attributes lack VERIFIED RUNTIME evidence. No ordinary zombie packet mapping inspected carries strength, sight, hearing, memory or cognition. See ATTRIBUTE_NETWORK_REPLICATION.md. Population flags are not arbitrary Lua mod-data storage; custom field values have no demonstrated virtualization persistence.

## Conclusion

No requested attribute can yet be called safe to modify on existing multiplayer zombies. Some native fields can represent values without activity toggles, but their complete readers, lifecycle and synchronization do not satisfy the profile contract. DoZombieStats is not a general profile setter and must not be called repeatedly or under temporary global sandbox mutation. A supported bridge must preserve native transition work and apply only independently verified profile operations afterwards, with explicit native-recalculation reconciliation.

## Whole-JAR census and revised feasibility

[TESTED offline] Research index parsed **23,829 class files, zero errors, 247 selected direct references**. ATTRIBUTE_DIRECT_REFERENCE_INDEX.md supplies caller descriptors, resolved member descriptors, bytecode offsets and read/write/invoke classification for every hit. It closes the direct Java-reference inventory for the selected members in this exact JAR. It does NOT enumerate reflective access, invokedynamic/bootstrap method handles, native DLL code, mod Lua/Java writers or runtime-agent output. These remain [UNKNOWN]; do not call the complete engine/runtime graph proven.

Additional [VERIFIED source] references (paths relative to research/jar-source):

- Strength: IsoBarricade.Thump :401; IsoWindow.Thump :476; vehicles/AttackVehicleState.animEvent :193/:209. Damage/defense global strength readers: BodyDamage/BodyDamage.AddRandomDamageFromZombie :1172/:1175 and IsoGameCharacter.testDefense :12508/:12511. No per-zombie attack-strength profile can claim all these semantics via strength assignment.
- Toughness: IsoPlayer.calculateCritChance :3942/:3945 consults global toughness for a zombie target. VirtualZombieManager.createZombieOutsideWorld :381–391 and IsoDeadBody.reanimate :1971–1978 initialize health separately. This confirms toughness is more than current health. Runtime toughness remains BLOCKED, including injury preservation and crit semantics.
- Speed: IsoZombie.getZombieWalkTowardSpeed(float,float,Vector2) :3154/:3163 and getZombieLungeSpeed() :3172/:3173 consult global speed. pathfind/PathFindBehavior2.update :906, moveToPoint :985, moveToDir :1015 also consult global speed. DoZombieSpeeds(float) :3392 is another derived speed writer. Explicit category assignment is insufficient for arbitrary global-speed configurations.
- Cognition: observed direct runtime field readers are IsoDoor.Thump :1053, IsoThumpable.Thump :970, IsoWindow.Thump :468. Observed direct writes are constructor sentinel, DoZombieStats and resetForReuse; see census offsets. This is the strongest narrow per-zombie field candidate, but native and agent readers and replication remain UNKNOWN. No complete Intelligence/Cognition preset mapping is invented.
- Sight: direct field readers are spotted/spottedNew and getVisionRadiusAdjusted; DoZombieStats and constructor write it. The reachable radius path also ORs global categories. No complete independent profile is supported.
- Hearing: WorldSoundManager.getHearingMultiplier :419–435 uses the field; RespondToSound, sound creation and virtual-population sound handling read global options. Live-field partial behavior cannot cover virtual zombies. No full profile is supported.
- Memory correction: the earlier global-reader warning needs qualification. getSandboxMemoryDuration is defined at :4534, but the full selected Java call census finds **no direct invocation anywhere in this JAR**. Do not treat it as a proven reachable gameplay reader. Direct memory field reader is updateInternal target expiry (:2983); writers are constructor and DoZombieStats. [INFERRED] A field-only memory-duration experiment is plausible without activity toggles; reflective/native use and duration units still require validation. Runtime support remains UNKNOWN/BLOCKED, not proven globally overridden by this unused helper.
- Under-vehicle eligibility: pathfind/PathFindRequest.init :66 and pathfind/nativeCode/PathFindRequest.init :85 snapshot `isCrawling() || isCanCrawlUnderVehicle()` into canCrawl. A setter does not retroactively change an already submitted native path request. Repath/cancellation semantics require source/native investigation before a live profile.
- Decomposition: no ZombieLore decomposition field exists in the inspected SandboxOptions$ZombieLore declaration. Corpse decay options in SandboxOptions are different. [UNKNOWN] A living-zombie aging control; no option or substitute implemented.
- Environmental attacks: global thumpNoChasing and thumpOnConstruction readers occur in collideWith/tryThump, IsoThumpable.Thump :953 and IsoCompost.Thump. No corresponding independent per-zombie toggle is established. Native path requests also assign canThump for zombies. [BLOCKED] Whole-profile semantics via one field.

No extra DoZombieStats call or forced activity toggle is proposed. Candidates for individual runtime experiments are cognition and memory FIRST, with all other profile values Vanilla; speed and under-vehicle eligibility need additional derived/path ordering, and toughness/global-dependent controls stay disabled. This is an experiment ordering, not runtime approval or production feature selection.
