# MORTIS Workshop MP-test distribution

## Current dev.10 icon publication selection

The user authorizes the transparent specimen mod icon, unchanged thumbnail,
merge of all open MORTIS PRs after checks, and publication. The current source
is based on reconciled PR #16 / 8dbb648; dev.9 hunger fixes and dependency
contracts are preserved. Use the existing isolated-package verifier and fixed
item 3788592827 / App 108600; omit title/visibility/tags. Preserve earlier
packages and receipts. Current actual source/package/upload results belong in
the dev.10 receipt after success. Native tests remain human / NOT TESTED;
G7/stable G8 blocked. Steam restart requires separate post-upload approval.
The dev.9 build-set inventory below is historical exact input; current MORTIS
version/icon/input hashes are bound by its current manifest and upload receipt.

## Historical dev.9 matching MP-test selection

The user authorized merged Knowledge 0.17.0 / MORTIS 0.26.0-dev.9 / Nightfall 0.31.0-dev.8 distribution. Follow [current preparation/evidence](WORKSHOP_0.26.0-dev.9.md) and [exact runtime inventory](MP_TEST_BUILD_SET.json). Historical dev.7 receipts and dev.8 authoring checkpoint are retained. Upload outcome is recorded separately. G7/stable G8 BLOCKED.

## Historical dev.8 upload selection

The user explicitly requested merging #14 then #15 and publishing the branded
thumbnail. They merged as af7c02bbef419d9fb967cdb1a4ad92802036edf4 and
3c403c307e724add19622e4a66a3865886d39c95 respectively; main matches the
checked thumbnail tree. Select 0.26.0-dev.8, existing item 3788592827 / App ID
108600. Build an isolated package only from committed/pushed fresh source.
Preserve prior packages/receipts, title, visibility and tags. No gameplay or
native acceptance changes. Actual upload/public preview proof is recorded
below. Steam desktop restart requires a new confirmation.

## Observed dev.8 publication

SteamCMD exited 0 with `Committing update...Success.` on 2026-10-18 UTC
(2026-10-17 America/Phoenix), from committed/pushed source
e8454b69e138fe7ebc12823d1848fb2e7d725a3c. Both push/PR offline and integration
checks passed before upload. The 226-file package SHA-256 is
bf998af4a5863e3849389d8d5714ce02727b90fbb3f222baf610a4e4716f9855.
The existing item remains public with the same title; no title/visibility/tag
fields were submitted. Public API result 1 confirms the canonical dev.8
description. Downloaded Steam preview bytes exactly match the branded export:
2a9832fb909c2cf9e26066152d8feb4040a81986e4d7bf3589b905d311cff03c.
The [portable receipt](publications/0.26.0-dev.8-workshop-3788592827.json)
records immutable published source, package, staged-file hashes and observed
upload/public verification. The previous dev.7 package/receipt are preserved.
The user declined the separate Steam desktop restart; Steam was left unchanged.
Subscription/download
and native display/acceptance stay HUMAN / NOT TESTED; G7/stable G8 blocked.

## Historical dev.7 upload selection

The user explicitly requested merging PR #13 and publishing its new thumbnail.
The artwork PR is merged as da769eef6bb2d2761ecf958a0f1ee7c857a01552.
Select 0.26.0-dev.7, fixed item 3788592827 / App ID 108600, and preserve all prior
packages. The public API returns result 1 and public visibility before this
attempt. The outgoing changenote selects only the current section; prior notes
are historical. No gameplay change or native acceptance is inferred. Record the
actual upload and public preview verification below. A new
Steam desktop restart still requires a separate confirmation after success.

## Observed dev.7 publication

SteamCMD exited 0 with `Committing update...Success.` on 2026-10-18 UTC
(2026-10-17 America/Phoenix), from committed/pushed source
31225326635b810ff108ef46b750fe9cb1f358d3. Both push/PR offline and integration
checks passed before upload. The 226-file package SHA-256 is
773c424a4e894c35d3c29b828567318a8bf8885aeab3ad94f83cbf49c102018a.
The fixed existing item remains public, with its title preserved and no
visibility/title/tag fields submitted. Public API result 1 confirms the exact
canonical description. Downloaded Steam preview bytes match preview.png:
e1ec7377f34883f3c0ecb496a74ff2e48386d29e6580cf68400e9bcc834399f0.
The [portable receipt](publications/0.26.0-dev.7-workshop-3788592827.json)
records all staged file hashes and the actual upload/public verification.
Dev.6 package/receipt are preserved. The user declined the separate Steam
desktop restart; Steam was left unchanged. Subscription/download and native display/acceptance
remain HUMAN / NOT TESTED; G7 and stable G8 stay blocked.

## Observed dev.6 publication

SteamCMD exited 0 and confirmed `Committing update...Success.` for the fixed
existing-item VDF from source e96b56ee50ad6aae46d10d98cc8662f5a34fb215.
The public API then returned result 1, App ID 108600, item 3788592827, public
visibility and the exact canonical description; its public page was accessible.
The [portable receipt](publications/0.26.0-dev.6-workshop-3788592827.json) binds
226 file hashes and package SHA-256. Before upload both push/PR CI jobs passed.
The user declined a Steam desktop restart; Steam was left unchanged.
Subscription/download and all native acceptance remain human / NOT TESTED.
The procedure below records the preparation boundary; it does not relabel
upload success as dedicated validation or stable-release approval.

The user's publish request authorizes updating existing item 3788592827 with
0.26.0-dev.6, not a new item, visibility change or stable release. The user
reconfirmed that exact URL after anonymous API result 9 and an inaccessible
public page. Preserve those access limitations; upload success must be observed
through the cached-account SteamCMD result, not inferred from package creation.

Runtime source is unchanged from merged PR #11 / d5cfb21. This is publication
metadata/tooling preparation for that version, not a new gameplay iteration.
Canonical description is WORKSHOP_DESCRIPTION.txt, with existing workshop.txt
projection and documentation description preserved. The current changenote is
the first section of WORKSHOP_CHANGE_NOTE.txt; prior development notes stay
historical. Both outgoing texts contain the required MP-test label and known
dependency/native limits. The description adds the public GitHub source link.

Prepare only from the committed, pushed branch containing latest remote main:

```text
python -B scripts/check_versions.py
python -B scripts/prepare_workshop.py --output dist/workshop-mp-test/<unique-version-commit-directory>
python -B scripts/prepare_workshop.py --output dist/workshop-mp-test/<same-directory> --verify
```

This script never uploads, deploys, deletes, launches a game/server or restarts
Steam. It refuses an existing output directory; every preparation is isolated.
It copies authoritative src/ProjectMORTIS/42 plus root info/thumbnail and preview,
retains artwork bytes and adds only an empty common/.keep packaging marker for
the Build 42 common layer. Archive/staging checks enforce exact inventory,
source bytes, CRC, traversal/case/duplicate safety and a Lua-only runtime. No
archive, experiment, tests, unrelated mod, Java component or historical Contents
copy is an input. Generated files remain ignored under dist; preserve them.

The VDF targets App ID 108600 and the existing publishedfileid. contentfolder is
stage/Contents (Steam receives mods/ProjectMORTIS); preview stays outside content.
It omits visibility/title/tags to preserve the item's settings. Valve documents
that omitted fields are unchanged for existing-item updates. It preserves real
paragraph breaks; description must fit the reviewed 8000-byte Steamworks budget.
No credentials are written to the VDF. See the Steamworks implementation guide
and ISteamUGC.SetItemDescription documentation for these scoped constraints:
[update fields](https://partner.steamgames.com/doc/features/workshop/implementation#SteamCmd),
[description limit](https://partner.steamgames.com/doc/api/ISteamRemoteStorage#k_cchPublishedDocumentDescriptionMax).

provenance.json binds version, exact commit, Mod/Workshop IDs, all staged file
hashes, archive hash, source-reviewed Steam build and blocked native gates. The
runtime-input manifest is verified before preparation. The old 0.23.2 archive
remains immutable and its hash was checked before this attempt. Downgrade or
save rollback is not certified; humans must use disposable backed-up saves.

The project's `check_versions.py --release` is a **stable-release** gate and
continues to reject this prerelease. It is not bypassed or described as PASS.
This separate MP-test package check implements only the expressly authorized
distribution exception. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. Knowledge
0.16.0 refuses affected MP storage APIs; do not bypass it. Runtime tests remain
human-operated and the normal contaminated launcher is not an acceptance baseline.

Before invoking the verified SteamCMD executable, rerun freshness and package
verification, ensure public source backup and intended CI checks pass, then
use only the existing cached login and the generated upload.vdf. Never publish
from CI, include passwords, use publishedfileid 0, or infer success from exit
code alone. Require the successful committed-update marker for this item.
Record the observed result and attempt public-page verification separately.
If Steam refuses the existing item/account, stop without creating a replacement.

After successful upload, ask the user about a Steam desktop restart and wait for
that specific confirmation. Do not restart after failure/unverified upload.
No Workshop distribution result grants native acceptance or confirms downloads.

## Observed dev.9 publication

SteamCMD exit 0 / `Committing update...Success.` from `249198a76e72cb038a03d85cba6b9ecd6f798a60`, package `4551a7db6555b803974e963972344006d65a1739e352919db709f2fac177c73c` with 227 staged files. Public exact description/title/visibility match; no visibility changes or desktop restart. [Current result and receipt](WORKSHOP_0.26.0-dev.9.md). G7/stable G8 BLOCKED; subscription/native acceptance remains human / NOT TESTED. Prior dev.6/dev.7 receipts are unchanged.
