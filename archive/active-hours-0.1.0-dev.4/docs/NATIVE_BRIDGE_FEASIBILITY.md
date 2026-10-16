> SUPERSEDED ARCHITECTURE — The 2026-10-08 Lua-only handoff forbids native interception, agents and class replacement. This document is preserved historical research, not an active implementation plan. Current proof design: LUA_ONE_ZOMBIE_POC.md. Source observations and historical test evidence remain unchanged.

# Native bridge feasibility

2026-10-08. Current design: NATIVE_BRIDGE_DESIGN.md; expanded attribute requirements: DYNAMIC_ATTRIBUTES_API_AUDIT.md. No loader adopted and no native production adapter exists.

SOURCE-SUPPORTED: a decision interception in private IsoZombie.updateActiveState is the smallest activity seam observed. It must leave makeInactive side effects intact. Additional attribute support may require selected reader seams because global sandbox values bypass per-zombie fields. This increases feasibility requirements; it does not authorize replacing AI or mutating sandbox globals.

Public dependency discovery on 2026-10-08 found [FadedMods publisher release notes](https://github.com/FadedMods/faded-mod-installer-cloud/releases). These describe installed loose-class overrides and one client-only plugin. They do not establish a supported interception API or dedicated availability for this project. No dependency binaries or implementation source were downloaded/copied; no loader was adopted. Those notes cannot satisfy the required API, licensing, exact matching, transform-order or no-match gates. Third-party capability reference only: SOURCE CODE COPIED: NO; IMPLEMENTATION DERIVED FROM REFERENCE: NO. Independent vanilla evidence remains the native seam audit; the dependency's actual interception capability remains UNKNOWN.

Installed loose-class precedence is an environment constraint, not an implementation technique. Base-game replacement remains prohibited. Required evidence: documented public startup transformer interface, exact effective-class match, server/client versions, no-match fallback, agent interoperability, license/distribution terms and an isolated runtime diagnostic. None has been verified.

G2 BLOCKED. Phase B NOT STARTED (feasibility research only; no executable bridge phase). G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED.

## Foundational investigation — documented mechanisms

2026-10-08 addition; earlier discovery record retained. No dependency adopted, downloaded, installed or bundled.

[VERIFIED documentation/license] ZombieBuddy **v2.3.4**, commit `9a08a542cfb55f7c8f4973a545639430b3c601ee`, is a legally usable candidate under its [MIT-style license](https://raw.githubusercontent.com/zed-0xff/ZombieBuddy/v2.3.4/LICENSE.txt), requiring notice preservation when copying/distributing. This establishes dependency permission, not permission to redistribute game classes. Its [pinned guide](https://raw.githubusercontent.com/zed-0xff/ZombieBuddy/v2.3.4/doc/ModdingGuide.md) lines 40–46 documents server/client placement; lines 130–177 document advice entry/exit and conditional original-method skipping. The public annotation interface at `java/src/main/java/me/zed_0xff/zombie_buddy/Patch.java` exposes `strictMatch`, `This` and `OnEnter(skipOn)` at that commit. Only dependency documentation and the public API declaration were inspected; no loader internals or third-party gameplay implementations were copied.

[INFERRED] Entry advice targeting exactly the no-argument activity helper can consume this-zombie, call its unchanged public makeInactive with a delivered server decision, and skip the helper only for an authorized binding. Otherwise allow the helper. This changes the decision seam, not the rest of AI. [UNKNOWN] Actual private-method transform success, no-match reporting, patch exception policy and compatibility with Java 25 and other agents. The v2.3.4 README still lists Java 17, while installed runtime release reports Azul Java 25.0.1; master documentation has newer APIs. Do not compile against master and claim v2.3.4 compatibility.

The upstream [Windows installation guide](https://raw.githubusercontent.com/zed-0xff/ZombieBuddy/master/doc/Installation.md), lines 92–115, describes copying a JAR/native loader into the game directory and changing startup options. No such installation was performed. A no-install-change Windows startup route for this candidate remains [UNKNOWN]. Public support for both environments does not prove this specific setup works.

### Platform-only alternative

[VERIFIED API] Java's [startup instrumentation specification](https://docs.oracle.com/en/java/javase/25/docs/api/java.instrument/java/lang/instrument/package-summary.html), lines 23–38, defines Premain-Class and -javaagent startup before application main. Installed Java lists java.instrument@25.0.1. A separate research agent can use the platform [ClassFile](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/lang/classfile/ClassFile.html), [CodeTransform](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/lang/classfile/CodeTransform.html) and [InvokeInstruction](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/lang/classfile/instruction/InvokeInstruction.html) APIs to inspect/transform a call site. These are normal exported Java APIs; no copied dependency code or runtime redistribution is needed. No JDK-private ASM, reflection or game-class replacement is proposed.

[INFERRED] This is the smallest dependency-free mechanism for an external, disposable client/server test launcher, without editing installed files. It is a research-agent alternative, not an adopted Workshop loader. [UNKNOWN] Windows instrumentation startup/library resolution, helper linkage, game custom-loader behavior and exact runtime installation. A matching Java 25 compiler is not present in the installed game's module list (java.compiler is an API module; jdk.compiler is absent). No agent was compiled or launched.

### Effective class and transformation order

[TESTED offline bytecode] Both retained IsoZombie variants have descriptor `updateActiveState()V` and the same resolved code:

```text
0  aload_0
1  invokestatic  zombie/GameTime.getInstance()Lzombie/GameTime;
4  invokevirtual zombie/GameTime.isZombieInactivityPhase()Z
7  invokevirtual zombie/characters/IsoZombie.makeInactive(Z)V
10 return
```

Bytecode references are decoded in research/attribute-bytecode-index.json, not assumed from decompiler text. Raw Code hashes differ because constant-pool indices differ; semantic references match. [INFERRED] A platform call-site transform can preserve the getInstance and makeInactive instructions, replacing only the decision invocation with a static resolver accepting game time and this-zombie. Exact stack shape, verification and helper linkage require offline transformation tests before runtime. No transformed game class was written.

[VERIFIED API] [ClassFileTransformer specification](https://docs.oracle.com/en/java/javase/25/docs/api/java.instrument/java/lang/instrument/ClassFileTransformer.html), lines 13–29: results chain; ordering groups depend on retransformation capability/native status, then registration order. An exception does not block later transformers and behaves as no transform. Therefore throwing on mismatch is NOT a guaranteed stop mechanism. Startup agent order alone cannot guarantee the last effective transformation.

[INFERRED safety design] Refuse activation unless incoming effective bytes match the exact allowlisted helper; record defining loader, source/hash, match count and transformed fingerprint. Keep helper default vanilla. Require observed hook invocation/capability confirmation from server and both clients before binding a zombie. A later agent can still change the seam; final behavior must be observed. No silent local vanilla fallback while other peers continue custom gameplay. Missing/mismatched hook blocks the session before custom activation. If capability fails after activation, stop the experiment and coordinate restoration; disconnection alone cannot guarantee an already changed zombie was restored.

[UNKNOWN] Existing external agent transformation registration/order and behavior; it was not executed or decompiled. No compatibility claim is made. A future clean isolated session and this modified installation need separate evidence. G2 remains BLOCKED; executable Phase B NOT STARTED.

Final effective-input provenance: installed loose-class hash changed externally relative to the historical A25DFE... baseline. Rechecked snapshot is `AA340922464B04A9EF12116C0CEBCD9EA5E5DAA33E1B9617A12822BDA839633F`; saved as research/effective-snapshots/aa340922464b04a9ef12116c0cebcd9ea5e5daa33e1b9617a12822bda839633f.class. The bytecode census now names this exact input hash, and a hash-named census copy is preserved. Five-instruction resolved seam still matches the main JAR. This proves only this method's static shape; unrelated modified behavior and runtime transforms remain UNKNOWN. This work made no installed-file writes.
