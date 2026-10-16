> CURRENT SCOPE — Lua-only custom behavior profiles supersede native activity control. Retained source evidence is historical and does not prove normal Lua invocation or dedicated multiplayer behavior. See LUA_ONLY_API_AUDIT.md and LUA_MULTIPLAYER_AUTHORITY.md; no runtime gate has passed.

# Current multiplayer contract

2026-10-08 expanded handoff supersedes the original requirement to follow vanilla Day/Night selection. Historical API_AUDIT.md and MP_AUTHORITY_AUDIT.md retain their inspected facts and earlier design context.

Core B47ANCEDActiveHours alone leaves gameplay untouched and does not require vanilla Both. Exactly one of B47ANCEDActiveHoursNight or B47ANCEDActiveHoursDay may supply policy. Both modules enabled, missing Core, invalid configuration or missing native capabilities disables custom activity AND profiles. Never choose a module silently.

With one gameplay module, server must require vanilla ActiveOnly=Both without mutating it. Configured WhenActive Night/Day/Both supplies policy independent of module name. WarnVanillaConflict=false may suppress optional output, never enforcement. Server owns effective enabled state, configuration, solar values, thresholds, profile decisions and lifecycle identity. Owners and observers receive consistent state. Unsupported clients require coordinated vanilla fallback.

No transport is implemented. MP_AUTHORITY_AUDIT.md and ATTRIBUTE_NETWORK_REPLICATION.md identify the current evidence gaps. Join/reconnect, ownership transfer, virtualization and restart must be proven before implementation. G7 BLOCKED / NOT TESTED.

Foundational follow-up: NATIVE_OWNERSHIP_ORDERING.md records exact native addressing and ownership order, including source-verified targeted server commands and connection-bound client event identity. ONE_ZOMBIE_POC_ARCHITECTURE.md defines a restricted prepared-peer experiment without inventing a packet schema or persistent identity. Native owner locomotion/health feedback remains a trust boundary; full server-authoritative profiles are not solved by merely receiving a valid owner's packet. G2 and G7 remain BLOCKED.
