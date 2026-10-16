Project Version: 0.1.0-dev.4

# Lua-only API audit

Current experiment: MORTIS_SPEED_PROOF.md / TEAM_API_RESEARCH.md, using negotiated/typed LocomotionOverrides.acquire/release and Authority.canWriteCanonicalState on server. Native helpers remain the existing source-supported candidates below, not runtime-verified calls. No guessed vanilla API or client-owner bridge is added.

Current authority: the Lua-only handoff of 2026-10-08. This supersedes native interception proposals; it does not invalidate their source observations. Project version initialized; prior source observations are unchanged. G2 BLOCKED; Phase B NOT STARTED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED.

References below are exact one-based lines in retained CFR output under `research/jar-source/`, from the installed 42.21 main JAR. Decompiled source is source inspection, not original source or actual Lua/runtime evidence. See existing SHA256 manifests and VALIDATION.md. The externally modified loose IsoZombie differs from this JAR; actual loaded peer behavior remains UNKNOWN.

| Capability | Evidence and classification | Decision |
|---|---|---|
| Normal Lua method exposure | [VERIFIED source] `zombie/Lua/LuaManager$Exposer.java:1974` registers IsoZombie; `:2846` selects Java-style exposure. `se/krka/kahlua/integration/expose/LuaJavaClassExposer.java:324` exposes public nonstatic methods unless HiddenFromLua. | Public speed methods are source-supported Lua candidates; successful normal Lua calls are [UNKNOWN]. |
| Instance field assignment | [VERIFIED source] exposer `:305` exposes only public static fields. | Public Java strength/memory/etc fields do not establish ordinary Lua setters. No reflective workaround. |
| Category speed methods | [VERIFIED source] `zombie/characters/IsoZombie.java:4880`, `:4891`, `:4920`, `:4930`: doSprinter, doFastShambler, doShambler, getSpeedType. | Audit candidate; see LUA_SPEED_CONTROL.md. |
| General speed selector | [VERIFIED source] IsoZombie `:4854`, `:4858`, `:4952`. | Explicit integer still interacts with global sandbox speed. Not a sandbox-independent adapter. |
| Native activity | [VERIFIED source] IsoZombie `:2813`, `:2829`, `:4486`. | No interception, inactive access or makeInactive calls permitted. ActiveOnly=Both is required; never mutate it. |
| Additional attributes | [VERIFIED source] IsoZombie `:3327` DoZombieStats and ATTRIBUTE_DIRECT_REFERENCE_INDEX.md enumerate selected direct references. | All dynamic attribute adapters remain [BLOCKED]; no verified complete supported getter/setter pair and MP semantics. Health is not toughness. |
| Ownership and identity | [VERIFIED source] IsoZombie `:631`, `:635`, `:639`, `:647` offers online ID, remote state, owner and owner player methods. | [UNKNOWN] actual Lua usability and transfer timing. Never set ownership. Online ID is reusable transport identity. |

Speed must pass its independent proof before additional attributes. The existing attribute census remains useful, but does not prove reflection/native/mod paths or normal Lua field access. Cognition and memory remain field-based research candidates only; the uncalled memory-duration helper is not a proven reachable blocker. Strength damage includes global readers, sight/hearing include global readers, and speed has derived animation/locomotion state. Toughness requires damage/max-health semantics, not merely setHealth.

No Java agents, third-party loaders, replacement classes, installed binary changes or production Lua implementation are part of the current architecture.

## Observation and routing API refinement — 2026-10-14

[VERIFIED source] IsoZombie.java:2900 emits OnZombieUpdate(zombie) after native updateActiveState :2829 and movement statistics. It has no current-owner predicate at its call site. Nearby early returns include null sprite :2886-2887 and dedicated indoor-zombie :2890-2892, plus remote stale/removal paths :2865-2883. Callback presence does not prove ownership, and absence does not prove destruction/unload.

[VERIFIED source] IsoZombie.java:845-854 registers shouldSprint as a callback that can setTarget(null) while evaluating it. It is target intent, not a getter for speed category or lunger. Avoid arbitrary animation-variable reads as passive diagnostic substitutes. Public isCrawling :4138 and isDead (IsoGameCharacter.java:4936) are candidate safety predicates, not a complete registration/ownership proof. No supported lunger getter/setter pair was found in the targeted IsoZombie source inspection; normal Lua instance-field assignment remains disallowed.

[UNKNOWN] Actual Lua event/getter availability, every lifecycle path, observation across server indoor states, and a supported stable object lookup after event gaps. IsoCell is exposed (LuaManager$Exposer.java:2314), but its implementation was not in the retained source set inspected here; no indexed lookup or full-world traversal guarantee is assumed. No runtime prototype is enabled.

## Additional exposed surface does not complete rollback

[VERIFIED source / TESTED offline method metadata] IsoSpriteInstance is exposed at LuaManager$Exposer.java:2278; IsoGameCharacter.getSpriteDef is public but may allocate. Its public concrete API includes getFrame()F and setFrameSpeedPerFrame(F)V, not a matching frame-rate getter. The setter reads a multiplier and writes animFrameIncrease. No named lunger/walkVariant accessor pair was found in the targeted concrete-method surface of IsoZombie/IsoGameCharacter; this is a bounded census, not proof against arbitrary reflective/native/other APIs. Those alternatives are not authorized ordinary-Lua bridges. See restoration matrix in LUA_SPEED_CONTROL.md.

[UNKNOWN] Normal Lua invocation, exact lifetime/null behavior, every inherited/engine path, actual rendering influence and runtime recovery. No custom Java or game modifications are introduced.
