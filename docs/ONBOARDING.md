# Repository onboarding provenance

On 2026-10-16 the user explicitly authorized repository/canonical-version onboarding and authority/replication corrections, then confirmed creation of the public repository [B47ANCE/ProjectMORTIS](https://github.com/B47ANCE/ProjectMORTIS). GitHub authentication identified B47ANCE. The repository did not previously exist and the local source had no Git metadata.

Initial imported baseline commit: `e9cb19d5fcedf9b9bd91da7579f07c19f41af754` (0.23.2). Local and remote main SHAs matched after push. No earlier Git history was available or invented. The imported runtime matches the existing authoritative source; root VERSION adopted the already consistent source metadata/runtime/README version with user authorization. Both offline CI baseline runs succeeded. This says nothing about earlier runtime correctness.

The current iteration is on `fix/authority-replication-0.23.3` and must enter main through a PR. No main merge is authorized by the implementation request. CI is offline-only with read-only token permissions, pinned action commits, and no Steam/SFTP credentials. The workflow does not itself establish branch protection.

Local junctions/settings, dated audit snapshots, SteamCMD upload markers, `Contents/`, and `dist/` are excluded from Git and preserved in place. Source, tests, authoring art/metadata, examples, compatibility template, current docs, and the historical checksum ledger are tracked. The old packaging copy and immutable 0.23.2 ZIP retain their original bytes; exclusion does not claim they are backed up by GitHub. See SOURCE_INVENTORY.json and VERSION_POLICY.md for classifications.

Canonical adoption is not a release. The fix is a compatible development PATCH candidate `0.23.3-dev.1`; public API 1.5.0 remains unchanged, and all peers must update together for clear handling. G7 BLOCKED / NOT TESTED and stable G8 BLOCKED until human dedicated evidence exists.
