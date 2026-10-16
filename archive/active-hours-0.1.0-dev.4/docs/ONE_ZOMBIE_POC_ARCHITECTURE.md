> SUPERSEDED ARCHITECTURE — The 2026-10-08 Lua-only handoff forbids native interception, agents and class replacement. This document is preserved historical research, not an active implementation plan. Current proof design: LUA_ONE_ZOMBIE_POC.md. Source observations and historical test evidence remain unchanged.

# Smallest defensible proof-of-concept architecture

Research design only, 2026-10-08. No agent/mod/packet implementation or runnable package. G2 BLOCKED; executable Phase B NOT STARTED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. The prototype is not yet authorized to launch/deploy by this document.

## Scope

One alive, continuously loaded zombie; one dedicated server; exactly two prepared clients, both relevant to the zombie throughout the test. Vanilla ActiveOnly=Both. Start with every attribute profile Vanilla and fixed native baseline settings. No solar controller, population scans, weighting implementation, persistence promises or new AI. The human records actual Build 42.21 binaries, runtime and agents for all peers.

This is deliberately an activity-seam experiment before feature implementation. It cannot satisfy production lifecycle or Insane performance gates. Server is sole policy owner; a test operator changes server intent, never directly writes client state.

## Layer 1: inert capability probe

[INFERRED] First build a research-only startup instrument/probe, separate from production source. Prefer the Java 25 platform Instrumentation/ClassFile route if its Windows startup can be verified without editing installed binaries; ZombieBuddy v2.3.4 remains a licensed/documented candidate but Java 25 and non-installing startup compatibility are unresolved. Do not combine loaders speculatively.

Before any change: identify the exact effective IsoZombie helper descriptor and five-instruction semantic fingerprint; verify one match; confirm native makeInactive unchanged; record classloader and prior-agent chain. Both retained class variants match this seam offline. Actual transformed verification and helper linkage still need an offline probe. Keep resolver permanently vanilla while proving startup/no-match/unsupported signatures cause no custom state. A loaded agent/JAR alone is not successful-hook evidence. Capture hook invocation and original-method counters without per-update logging.

## Layer 2: bounded server decision delivery

[INFERRED] After registration completes, server binds the selected loaded object to a server-created test-session identity, with transport online ID only as a lookup hint. This is not a durable zombie ID. Each client resolves its live object and reports capability/readiness through the existing native Lua command transport. Server validates the reporting connection, both peer identities and current native owner; no client-supplied policy is accepted.

Do not activate until both clients have confirmed the intended live-object binding and delivered server decision. Begin with active=true, then make one inactive/active transition. Deliver server decisions to both prepared clients and server native adapter; measure acknowledgement/application ordering rather than claiming simultaneous cross-peer application. No wire format is fixed at research stage. If native ownership moves to either already prepared client, its existing binding must survive; observe becomeLocal and subsequent update sequence. No ownership-forcing hook is needed for this restricted two-prepared-peer experiment unless source/runtime ordering proves otherwise.

Restricting scope is not a production solution: online-ID wrapping, persistent allocator durability and late join remain unresolved. Missing binding at the moment of decision must block the test; do not silently calculate thresholds locally. A future multi-zombie system requires a lifecycle generation and verified authority-transfer readiness barrier.

## Layer 3: smallest activity interception

[INFERRED] Change only the boolean decision used by updateActiveState for the bound test zombie. The platform call-site candidate preserves native GameTime.getInstance and makeInactive, substituting the boolean resolver invocation; the documented advice alternative conditionally skips only the verified helper after making the same native call. Every other zombie and any disabled session take vanilla. No forced activity toggle to recalculate stats, repeated Lua overrides, sandbox mutation or replacement base class.

Counters distinguish native helper calls from actual state transitions and DoZombieStats executions. Repeated helper evaluations are normal; mutation must happen once at crossing, as native makeInactive already guards unchanged values. Independently randomized native stat values on peers are recorded, not falsely reported as server-authoritative attributes. Native owner packet feedback may rewrite locomotion and must be observed on the server and observer. First experiment proves only authoritative activity-decision delivery and native transition consistency, not full profile authority.

## Layer 4: one-attribute experiments after activity passes

First candidates: cognition door interaction and memory target-expiry duration, separately. Apply only a server-selected per-zombie value after required native initialization/real transitions; never invoke DoZombieStats as a refresh. Record every reachable writer and restore recorded originals under a verified event order. The direct memory helper has no JAR calls, but native/reflective access and time units still need proof.

Speed requires all derived locomotion and global-reader constraints; toughness requires injury-preserving semantics and global crit handling; sight/hearing depend on global reader branches; under-vehicle eligibility snapshots into native path requests. These are not included until their individual feasibility is resolved. No attribute can yet be advertised as supported.

## Abort and restoration

Before first activation demonstrate server-controlled disable while all peers are connected. Any mismatch, missing hook, unexpected owner, extra participant, delayed stale binding, unload, death/reuse or disconnect pauses further decisions and ends the experiment. Restoration must be confirmed on server and both clients; record if it cannot be confirmed. A network failure cannot magically guarantee coordinated vanilla restoration, so mark failure rather than leaving the prototype enabled or claiming a safe automatic fallback. Human shutdown is a runtime failure containment option, not a release behavior.

## Entry evidence still required

1. Compatible compiler/research-agent startup without installed changes; offline transformed-bytecode verification, no-match fixture, duplicate-transform and helper-linkage checks.
2. Actual server and both client invocation probes with the effective agent chain.
3. Native command dispatch order/readiness measured against ownership and update events.
4. One-object binding correctness and safe connected restoration before inactive intent.
5. Native transition/stat/packet ordering and two-client observation, then native ownership transfer.

The user request authorizes this architecture research, not deployment or game launch. No gate moves to PASS merely because these steps are specified.
