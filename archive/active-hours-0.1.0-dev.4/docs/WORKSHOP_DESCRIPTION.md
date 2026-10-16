Project Version: 0.1.0-dev.4

# B47ANCE'd Active Hours

## Overview
MP testing build - dedicated multiplayer NOT TESTED

An isolated one-zombie speed experiment using the same public M.O.R.T.I.S. locomotion override API as Project Nightfall's UV slowing. This item is an experimental diagnostic, not the finished day/night gameplay mod. Use a disposable test world and two clients.

## Features
- Admin-operated fixed Shambler, Fast Shambler and Sprinter requests.
- Server-side MORTIS override acquisition/release; diagnostic clients only observe.
- Bounded selected-zombie diagnostics and native overwrite observation without continuous correction.

## Compatibility & Requirements
Target: vanilla Project Zomboid Build 42.21. Required Mod IDs: ProjectMORTIS and experienceWorks. MORTIS API 1.5.0 or later within major version 1, with the required locomotion and authority functions. Project Nightfall itself is not required.

Subscribe to both dependencies before the test:
- Project M.O.R.T.I.S.: https://steamcommunity.com/sharedfiles/filedetails/?id=3788592827
- experienceWorks: https://steamcommunity.com/sharedfiles/filedetails/?id=3792566496

Diagnostic Mod ID: B47ANCEDActiveHoursMortisProof. Do not enable the older B47ANCEDActiveHoursSpeedProof, production Core/Night/Day modules, or Nightfall for this isolated test. Actual Build 42.21 loading, Kahlua, SP and dedicated multiplayer behavior are NOT TESTED. Lua mock tests do not establish in-game compatibility.

## Configuration
Use vanilla Zombie Lore Active Only = Both. Record vanilla Speed and leave it unchanged. Connect both clients before selecting a zombie; Client A needs server admin privileges. Hold Left Ctrl + Left Shift: F6 select next eligible zombie, F7 Fast Shambler, F8 Sprinter, F9 Shambler, F10 release override, F11 diagnostics. Start with passive F11/F6 observation and follow the repository test procedure before changing speed.

## Source Code & Development
GitHub: https://github.com/B47ANCE/B47ANCEDActiveHours

The current MORTIS_SPEED_PROOF document contains the human test procedure. The original owner-routed experiment is preserved separately and excluded from this item's content. Runtime code is Lua only; no custom Java or installed-game modifications.

## Known Issues
Native owners may overwrite server helper results. Observer locomotion, actual sprinting, animation and ownership-transfer behavior require testing. MORTIS release restores captured walk type/category, not original scalar or all helper-derived state; behavioral restoration is unverified. No persistence, unload/reconnect/restart recovery, population benchmark, solar progression or additional attribute system is implemented by this diagnostic.

G2 production architecture BLOCKED; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. Upload success is distribution evidence only.

## Credits & Permissions
Developed by B47ANCE'd Workshop. User-selected Active Hours artwork. Uses public APIs from the B47ANCE-authored Project M.O.R.T.I.S.; no Nightfall, MORTIS or experienceWorks implementation/assets are bundled.
