# Changelog

## 0.23.3-dev.1 - authority and replication development, 2026-10-16

- Target: compatible authority/replication bug fixes, preserving public API 1.5.0 and existing save components. Assignment-clear records are additive; peers must run the same mod build.
- Fixed client hunger writes, missing clear replication, directed-reply dirty acknowledgement, obsolete online-ID indexes, request admission, and revision continuity across wrapper replacement.
- Added persisted clear records, retries, lifecycle cleanup, and client pending-message ordering. All peers must use the same mod build.
- [TESTED offline] 120 source syntax checks and all 49 host cases pass (48 Lua 5.1, one Lua 5.4), including the local experienceWorks integration. CI explicitly excludes that dependency integration. G7 BLOCKED / NOT TESTED and stable G8 BLOCKED.
- Food-provider transaction changes and complete locomotion-baseline restoration remain open; see docs/AUTHORITY_REPLICATION.md.

## 0.23.2 — imported baseline, 2026-10-16

- Established canonical root VERSION from existing authoritative source metadata, runtime constant, README, tester handoff, and matching preserved ZIP.
- Added source/package classification and reproducible offline validation. Existing runtime code is unchanged in this baseline.
- [TESTED offline] Syntax and host regressions only. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. Historical partial experienceWorks runtime evidence is not current validation.

Earlier release notes remain in WORKSHOP_CHANGE_NOTE.txt and existing design documents; importing source does not certify prior releases.
