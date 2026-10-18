# MORTIS supplied thumbnail

## Current branded revision - 0.26.0-dev.8

The owner supplied the branded revision in the same thumbnail conversation.
It adds the B47ANCE's heading. Use it for the same requested thumbnail role;
no additional artist/licensing claims are inferred.

- Original: `mortis-thumbnail-branded-original.png`, PNG, 1254x1254,
  1,626,849 bytes, SHA-256 `b6665fd6a2e777e00657d4a05e6a5ac337a6357e42f72b79372dbd7a31e3b911`.
- Exports: root `preview.png` and `src/ProjectMORTIS/thumbnail.png`, identical
  512x512 PNGs, 439,120 bytes, SHA-256 `2a9832fb909c2cf9e26066152d8feb4040a81986e4d7bf3589b905d311cff03c`.
- Export uses the same Windows System.Drawing settings described below,
  preserving the full canvas without crop/redraw. Both decode; visual review
  confirms the branded heading and complete composition remain visible.
- Original matches the supplied attachment byte for byte. Previous full-size
  original remains here; previous exports remain in Git and the dev.7 package.
- This revision has no package/upload/native-test evidence. The dev.7 Workshop
  receipt records the previous thumbnail, never this replacement.

## Historical first supplied thumbnail - 0.26.0-dev.7

The project owner supplied this artwork in chat and requested its use as the
new project thumbnail. This records permission for that requested use; no
additional artist attribution or third-party licensing claim is asserted.

- Original: `mortis-thumbnail-original.png`, PNG, 1254x1254, 1,613,076 bytes,
  SHA-256 `f9df88657a302a6462d4e8ea47013c588bb2cac7b917bc0605f2cdc2743102b5`.
- Exports: root `preview.png` and `src/ProjectMORTIS/thumbnail.png`, identical
  512x512 PNGs, SHA-256
  `e1ec7377f34883f3c0ecb496a74ff2e48386d29e6580cf68400e9bcc834399f0`.
- Export operation: Windows System.Drawing, 512x512 Format32bppArgb canvas,
  SourceCopy compositing, HighQuality compositing/pixel offset and
  HighQualityBicubic resampling. The entire source rectangle is mapped to the
  square destination; no crop, retouch, redraw or background removal.
- The original is preserved exactly as received; exports are below 1 MiB.
  Both decode successfully and were visually reviewed offline. Native display
  remains human-operated / NOT TESTED.

Artwork was introduced in the 0.26.0-dev.7 source checkpoint. The existing 32x32
`src/ProjectMORTIS/42/icon.png` is unchanged. `mod.info` still selects
`poster=thumbnail.png`; the packaging script already selects root preview.png
and the mod thumbnail export. The full original is not a runtime/package input.

Previous artwork remains in Git at merged commit
436f8c005093fda7bd67d10174dbeb64c281c469 and its ancestors. Historical packages,
staging backups and the dev.6 Workshop receipt remain untouched. This artwork
request does not publish another Workshop update, deploy, package, launch PZ
or change any gameplay, API, sandbox, save or multiplayer behavior.
