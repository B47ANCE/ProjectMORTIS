Project Version: 0.1.0-dev.4

# Lua profile architecture — conditional design

[INFERRED design] Core `B47ANCEDActiveHours` owns configuration validation, shared profile definitions and diagnostics. Night `B47ANCEDActiveHoursNight` and Day `B47ANCEDActiveHoursDay` depend on Core and select default policy. Build 42.21 dependency metadata is [UNKNOWN]. Core alone changes no gameplay; both gameplay modules loaded disables custom gameplay with a warning. Neither module wins silently.

Active and Inactive are custom behavior profiles. Native AI continues detecting, pursuing and attacking. No native inactive reads/writes, makeInactive calls, activity interception, AI replacement or sandbox mutation. Vanilla ActiveOnly must be Both; conflict disables custom gameplay. Runtime-safe restoration after an already-applied profile is still BLOCKED, so initial conflict prevention is not evidence of safe live disable.

Server owns configuration, policy, solar percentage, threshold assignment, profile category and weighted selection. Client only executes an accepted server decision when native authority confirms it owns the current zombie. Remote observers use verified vanilla locomotion synchronization where possible. This is conditional on LUA_MULTIPLAYER_AUTHORITY.md; never downgrade to client decisions if transport/identity ordering fails.

Target speed defaults: Active Sprinter, Inactive Shambler. Proposed sampling policy [INFERRED]: server rolls separate Active and Inactive categories once per zombie life/configuration revision, then reuses each result across crossings. This provides stable profile categories; preserving the native randomized speedMod across crossings is not yet verified. Per-zombie persistent identity/reconstruction policy remains UNKNOWN, so no durable sampling implementation is approved.

Additional attributes are independent future capabilities requiring supported Lua getter/setter, complete readers/writers, restoration and dedicated MP proof. Unsupported attributes remain unavailable and do not block an independently proven speed-only feature. No current attribute is approved. No gameplay implementation exists; initial project SemVer is now assigned.
