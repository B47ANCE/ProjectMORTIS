# ProjectMORTIS 0.26.0-dev.9 Workshop MP testing preparation

The user authorized merging Knowledge, MORTIS and Nightfall in dependency order
and publishing matching existing Workshop items on 2026-10-18 America/Phoenix.
Source PRs are merged: Knowledge #2, MORTIS #17, Nightfall #9 then #10.
Merged runtime commit: `df4121fd7187c54fd37cd3030290fb2e89080165`. This publication follow-up preserves
those runtime bytes and existing schemas, authority, research and category rules.
The version stays 0.26.0-dev.9: metadata/tooling preparation for the still-unpackaged
iteration, not a gameplay change or stable-release approval.

MP testing build - dedicated multiplayer NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.
Build 42 minimum declaration 42.20.3; local evidence Steam build 25485521.
Exact executed native version remains UNKNOWN / NOT TESTED. The known normal
launcher has unrelated non-Lua alterations; it is not an acceptance baseline.

## Matching source selection

[Build-set inventory](MP_TEST_BUILD_SET.json) pins the exact three merged runtime
inputs, versions and existing Workshop identities. Metadata follow-ups do not
turn prior evidence into current runtime proof. Knowledge private documents are
for fresh disposable dedicated worlds/server-created lives only. Existing-world
migration, progression, claims, journal recovery, XP and history remain guarded.
Three effigy models/rendering and other documented Nightfall gates remain open.
All server/client copies must match; other existing Nightfall dependency IDs stay
unchanged. No local deployment, server changes, native launch or stable tag.

## Packaging and upload boundary

Use only authoritative src/ source and supplied art. Preserve all earlier
Contents, packages, backups and receipts; no cleanup. Each candidate is verified
for exact inventory/bytes, SHA-256, CRC, safe paths/types/case and Lua-only payload.
Description and current changenote contain the required MP-test label and known
limits, real paragraphs and public source link. Use fixed existing item
3788592827 / App 108600; omit visibility changes and never create an item.
Each pre-upload receipt binds actual release SHA, package/source/text/preview
hashes, exact validation evidence and attempt outcome. Existing cached SteamCMD
authentication only; no credential in source/log reports. Actual SteamCMD success
and public-page verification are distinct; subscription/native acceptance remain
human / NOT TESTED. Steam desktop restart needs a new explicit confirmation
after upload success; upload scripts have no restart stage.

Offline validation and exact-head CI results will be recorded in the publication
PR and receipt. This preparation document itself does not claim upload success.

## Current offline evidence

[TESTED: Windows / Python 3.12.14 / Lupa 2.6 Lua 5.1] 131 Lua source parses, 68 Lua regression files, 32 Python tests and Active Hours offline experiments PASS. The full historical-contract integration suite selects exact Knowledge 0.16.0 bytes to retain refusal tests; it is not mislabeled as the matching 0.17.0 input. Matching Knowledge 0.17.0 / MORTIS dev.9 is covered by the 37 Knowledge and 73 Nightfall tests. Reviewed overview, 15 version mirrors and runtime input inventory PASS.

```text
python scripts/check_versions.py
python scripts/validate.py --knowledge-and-wisdom ../nightfall-effigy-container/.local/ci-dependencies/B47ANCEDKnowledgeAndWisdom --dependency-evidence docs/evidence/knowledge-dependency-6ba66c0-git-bytes.json
python -B scripts/check_overview.py
python scripts/check_public.py --staged
python scripts/prepare_workshop.py --output dist/workshop-mp-test/<selected-commit>
python scripts/prepare_workshop.py --output dist/workshop-mp-test/<selected-commit> --verify
git -c core.autocrlf=false diff --cached --check
```

Packaging verification and actual upload success are recorded only after execution. Exact-head CI results and final SHA are recorded in the publication PR. All G7/stable G8 native gates remain blocked.

## Verified upload — 2026-10-18 America/Phoenix

SteamCMD exited 0 and reported `Committing update...Success.` for existing item **3788592827**, after all required offline and exact-head CI checks passed. Release commit: `249198a76e72cb038a03d85cba6b9ecd6f798a60`. Package SHA-256: `4551a7db6555b803974e963972344006d65a1739e352919db709f2fac177c73c`; 227 exact staged files. Public API description, identity/title and public visibility match.

[Portable upload receipt](publications/0.26.0-dev.9-workshop-3788592827.json) binds the exact release/source commit, all package file hashes, publication text/VDF hashes, validation and actual result. No title, visibility or tags were submitted. Knowledge, MORTIS and Nightfall uploads completed in that order. No deployment, server changes, native launch or Steam desktop restart. Steam restart confirmation was requested separately and remains pending at receipt time. Subscriber download, dedicated startup/two-client synchronization, persistence/restart and native Insane-population timing remain HUMAN / NOT TESTED; G7/stable G8 BLOCKED.
