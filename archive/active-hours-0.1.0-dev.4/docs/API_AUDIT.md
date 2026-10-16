> CURRENT SCOPE — Lua-only custom behavior profiles supersede native activity control. Retained source evidence is historical and does not prove normal Lua invocation or dedicated multiplayer behavior. See LUA_ONLY_API_AUDIT.md and LUA_MULTIPLAYER_AUTHORITY.md; no runtime gate has passed.

# Native API audit

Scope update: the expanded user handoff now requires vanilla Both for gameplay modules and permits supported attribute profiles. Earlier policy/configuration passages below are historical design context, not the current contract. See MULTIPLAYER_AUTHORITY.md and DYNAMIC_ATTRIBUTES_API_AUDIT.md. Native source findings remain applicable to the unchanged inspected JAR.

Environment update: final foundational checks observed the loose installed IsoZombie class at SHA256 `AA340922464B04A9EF12116C0CEBCD9EA5E5DAA33E1B9617A12822BDA839633F`, different from the historical hash below. This work did not modify installed files; cause/timing of the external change is UNKNOWN. The new bytes are retained under research/effective-snapshots and the exact helper seam was independently rechecked. JAR hash remains unchanged. Do not use the earlier loose-class hash as current runtime identity.

Date: 2026-10-08. Project: B47ANCE'd Active Hours (`B47ANCEDActiveHours`). Project version: unassigned, audit only.

## Decision

[VERIFIED] The inspected main JAR identifies its game version as 42.21: `research/jar-source/zombie/core/Core.java:5234`, static initializer `new GameVersion(42, 21, "")`. This supersedes the workspace's historical 42.20.3 description for this inspected artifact only.

[VERIFIED] Lua calling `IsoZombie.makeInactive(boolean)` cannot provide durable independent activity: `update()` -> `updateInternal()` -> private `updateActiveState()` unconditionally reapplies `GameTime.isZombieInactivityPhase()` at each native update. It runs before the remote-client branch and before OnZombieUpdate. Evidence: `research/jar-source/zombie/characters/IsoZombie.java:2813`, :2829, :2865, :2900. Reapplying after every update would fight the native system and violate the handoff.

BLOCKED: Phase B safe gameplay proof of concept and Phase C implementation. No forced-override Lua has been written. G1 has identified a blocker; G2 safe authority design unresolved; G3–G5 gameplay checks blocked; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. No PZ client or server was launched.

## Provenance

Installed root: `E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid`.

- `projectzomboid.jar` SHA-256: `E1A69EB743EDE60B213A0FE7F8B83D4FCAB773036D256CC4543A336F3B058A33`.
- Loose `zombie/characters/IsoZombie.class` SHA-256: `A25DFE5FBD50B8DB6BB83E8BC5F892AF635969C1B6568E6B2D8ACBF601AB4AB3`.
- CFR 0.152 from workspace `.tmp-nightfall-decompile/cfr-0.152.jar`; Java from installed `jre64/bin/java.exe`. Only decompiler main was executed, not game main.
- JAR entries extracted to `research/jar-classes`; decompiled to `research/jar-source`. Loose IsoZombie decompiled to `research/native`. Evidence references below are JAR output unless explicitly marked loose.

[VERIFIED] Loose IsoZombie includes pzopt members absent from the JAR version. Both inspected implementations overwrite activity. [UNKNOWN] Runtime classpath precedence, transformed classes, official distribution integrity, and dedicated-server binary parity. Main JAR identity alone does not certify a pristine installation. CFR output is reconstructed source, not upstream source; its warnings and malformed local-variable reconstruction (notably climate interpolation) must not be copied into production code.

## Native activity API

| Question | Source finding | Remaining gate |
|---|---|---|
| Lua access | Public `void makeInactive(boolean)`; IsoZombie registered in `LuaManager$Exposer.java:1974`; `exposeLikeJavaRecursively` at :2846 | [INFERRED] Lua callable through exposure; actual invocation UNTESTED |
| Field access | `public boolean inactive`, IsoZombie :464; `updateActiveState()` private | Field mutation cannot bypass overwrite or native side effects |
| Vanilla equivalence | `updateActiveState()` calls the same `makeInactive` | [VERIFIED] same source path |
| Overwrite | Every `updateInternal()` applies the global phase | [VERIFIED] architectural blocker |
| Per-zombie representation | Boolean is an instance field | [VERIFIED] representable; durable independent control BLOCKED |
| Authority/replication | No inactivity flag in inspected normal zombie boolean packet mapping | Safe server control [UNKNOWN]; see MP audit |

`makeInactive` (:4486): on entering inactivity sets slow walk type, running=false, inactive=true, speedType=3 and calls doZombieSpeed. On leaving, sets speedType=-1, inactive=false and calls DoZombieStats. `DoZombieStats` (:3327) calls doZombieSpeed (:3367); `determineZombieSpeed` (:4952) samples randomized speed when configured speed=4, using the vanilla sprinterPercentage.

[VERIFIED] Reactivation can reroll individual randomized speed; repeated overrides risk repeated stat recalculation. [UNKNOWN] Whether “preserve speed distributions” requires preserving each individual's pre-inactive speed as well as the configured statistical distribution. No custom speed restoration should be invented without resolving this contract. Vanilla inactivity also changes memory (`getSandboxMemoryDuration`, :4537) and is consulted by pursuit logic (:1981, :2338); changing only locomotion would not reproduce activity behavior.

Constructor (:604), load (:1161), and pooled reuse area (:3772) initialize inactivity from the current global phase. [UNKNOWN] Stable identity lifetime through virtualization, unload/reload, restart and ownership transfer. No threshold scheme or persistent writes approved yet.

`GameTime.java:1290`: ActiveOnly 1=both, 2=night, 3=day. `isDay` uses seasonal dawn/dusk; `isNight` uses its inverse with endless-cycle handling. Therefore the handoff's fixed-clock description is not accurate for this inspected build: the transition is global and abrupt but already follows seasonal boundaries.

## Solar API

[VERIFIED] ClimateValues exposes public float `getDawn()`, `getDusk()`, `getNightStrength()`, `getDayLightStrengthBase()`, `getLerpNight()` (:313, :317, :373, :389, :393). ClimateManager exposes `getClimateValuesCopy()` (:2245) and `getNightStrength()` (:521). ClimateValues and ClimateManager are registered by LuaManager Exposer (:2297, :2283). Lua execution remains UNTESTED.

ClimateValues update reads season dawn/dusk (:242), derives lerpNight from time/dusk/dawn, doubles and clamps it, and assigns nightStrength (:286–287). This branch has no weather/indoor/artificial-light input. [INFERRED] It is the strongest candidate for normalized natural darkness; actual twilight endpoints and seasonal timing need runtime measurements. Do not assume it models a short twilight window.

`getDayLightStrengthBase` is unsuitable as pure solar progression: its computation includes windIntensity and seasonal day percentage (:294–295). ClimateManager's public night-strength value is a managed climate value; raw ClimateValues is preferable for avoiding override/render effects, pending validation. Endless day/night paths must be handled explicitly: cached fields are not uniformly reassigned in all branches.

## Configuration assessment

Deferred until authority is safe: enable (default true), bounded curve choice, debug (default false). Vanilla ActiveOnly remains authoritative and is never duplicated or mutated. Automatic dusk/dawn are core behavior, not useful one-value selectors. Weather activation conflicts with the current weather-independent scope; retain Off as behavior, defer an option until a supported use case is designed. No unsupported settings or meaningless micro-settings shipped. Future options require server interpretation, stable IDs, bounds/defaults/save semantics and all 29 JSON language folders.

## Smallest sound next step

[INFERRED] Investigate a narrowly scoped Java interception of the per-zombie native activity decision, with vanilla fallback for disabled/Both Active, rather than a Lua loop that fights it. This is a recommendation, not a verified hook or approved implementation contract. It must first establish server-owned state delivery to owning and observing clients, identity persistence, native stat/speed semantics, loader capability and patched-class compatibility. The handoff requires documenting the blocker before continuing; no Java adapter was implemented.

Phase B can resume only after those source questions are resolved: one selected zombie, inactive/active restoration across native updates under both activity modes, then dedicated two-client observation including ownership transfer. Human-operated G6/G7 evidence is required. Do not package this audit as a mod release.
