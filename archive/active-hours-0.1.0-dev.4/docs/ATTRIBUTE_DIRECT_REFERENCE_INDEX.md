# Whole-JAR direct attribute references

JAR SHA256: `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`; 23829 classes; 0 parse errors.

Generated research appendix. Offsets are bytecode offsets in the named method descriptor, not source line numbers. Reads of sandbox option fields identify the option object; source review establishes the getValue use. UI/metadata references are retained so the census is auditable. See script limits; this is not runtime proof.

## DoZombieStats

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/VirtualZombieManager.createZombieOutsideWorld(Lzombie/iso/IsoDirections;ZI)Lzombie/characters/IsoZombie;` | 421 | invoke | `zombie/characters/IsoZombie.DoZombieStats()V` |
| `zombie/Lua/LuaManager$GlobalObject.addZombiesInOutfit(IIIILjava/lang/String;Ljava/lang/Integer;ZZZZZZFZFZZ)Ljava/util/ArrayList;` | 382 | invoke | `zombie/characters/IsoZombie.DoZombieStats()V` |
| `zombie/characters/IsoZombie.<init>(Lzombie/iso/IsoCell;Lzombie/characters/SurvivorDesc;I)V` | 664 | invoke | `zombie/characters/IsoZombie.DoZombieStats()V` |
| `zombie/characters/IsoZombie.load(Ljava/nio/ByteBuffer;IZ)V` | 209 | invoke | `zombie/characters/IsoZombie.DoZombieStats()V` |
| `zombie/characters/IsoZombie.load(Ljava/nio/ByteBuffer;IZ)V` | 375 | invoke | `zombie/characters/IsoZombie.DoZombieStats()V` |
| `zombie/characters/IsoZombie.resetForReuse()V` | 238 | invoke | `zombie/characters/IsoZombie.DoZombieStats()V` |
| `zombie/characters/IsoZombie.toggleCrawling()V` | 38 | invoke | `zombie/characters/IsoZombie.DoZombieStats()V` |
| `zombie/characters/IsoZombie.toggleCrawling()V` | 55 | invoke | `zombie/characters/IsoZombie.DoZombieStats()V` |
| `zombie/characters/IsoZombie.makeInactive(Z)V` | 72 | invoke | `zombie/characters/IsoZombie.DoZombieStats()V` |
| `zombie/iso/objects/IsoDeadBody.reanimate()Lzombie/characters/IsoGameCharacter;` | 374 | invoke | `zombie/characters/IsoZombie.DoZombieStats()V` |
| `zombie/popman/ZombiePopulationManager.addZombieStanding(FFFLzombie/iso/IsoDirections;ILzombie/popman/ZombieStateFlags;I)V` | 365 | invoke | `zombie/characters/IsoZombie.DoZombieStats()V` |
| `zombie/popman/ZombiePopulationManager.addZombieMoving(FFFLzombie/iso/IsoDirections;ILzombie/popman/ZombieStateFlags;III)V` | 250 | invoke | `zombie/characters/IsoZombie.DoZombieStats()V` |

## canCrawlUnderVehicle

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/characters/IsoZombie.<init>(Lzombie/iso/IsoCell;Lzombie/characters/SurvivorDesc;I)V` | 345 | write | `zombie/characters/IsoZombie.canCrawlUnderVehicleZ` |
| `zombie/characters/IsoZombie.isCanCrawlUnderVehicle()Z` | 1 | read | `zombie/characters/IsoZombie.canCrawlUnderVehicleZ` |
| `zombie/characters/IsoZombie.setCanCrawlUnderVehicle(Z)V` | 2 | write | `zombie/characters/IsoZombie.canCrawlUnderVehicleZ` |
| `zombie/characters/IsoZombie.toggleCrawling()V` | 1 | read | `zombie/characters/IsoZombie.canCrawlUnderVehicleZ` |
| `zombie/characters/IsoZombie.toggleCrawling()V` | 66 | write | `zombie/characters/IsoZombie.canCrawlUnderVehicleZ` |

## cognition

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/SandboxOptions$ZombieLore.<init>(Lzombie/SandboxOptions;)V` | 176 | write | `zombie/SandboxOptions$ZombieLore.cognitionLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.<init>(Lzombie/iso/IsoCell;Lzombie/characters/SurvivorDesc;I)V` | 46 | write | `zombie/characters/IsoZombie.cognitionI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 6 | read | `zombie/SandboxOptions$ZombieLore.cognitionLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 18 | write | `zombie/characters/IsoZombie.cognitionI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 27 | read | `zombie/SandboxOptions$ZombieLore.cognitionLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 59 | write | `zombie/characters/IsoZombie.cognitionI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 67 | write | `zombie/characters/IsoZombie.cognitionI` |
| `zombie/characters/IsoZombie.resetForReuse()V` | 153 | write | `zombie/characters/IsoZombie.cognitionI` |
| `zombie/iso/objects/IsoDoor.Thump(Lzombie/iso/IsoMovingObject;I)V` | 61 | read | `zombie/characters/IsoZombie.cognitionI` |
| `zombie/iso/objects/IsoThumpable.Thump(Lzombie/iso/IsoMovingObject;I)V` | 79 | read | `zombie/characters/IsoZombie.cognitionI` |
| `zombie/iso/objects/IsoWindow.Thump(Lzombie/iso/IsoMovingObject;I)V` | 53 | read | `zombie/characters/IsoZombie.cognitionI` |

## crawlUnderVehicle

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/SandboxOptions$ZombieLore.<init>(Lzombie/SandboxOptions;)V` | 220 | write | `zombie/SandboxOptions$ZombieLore.crawlUnderVehicleLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.initCanCrawlUnderVehicle()V` | 9 | read | `zombie/SandboxOptions$ZombieLore.crawlUnderVehicleLzombie/SandboxOptions$EnumSandboxOption;` |

## doFastShambler

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/characters/IsoZombie.doZombieSpeedInternal(I)V` | 86 | invoke | `zombie/characters/IsoZombie.doFastShambler()V` |

## doShambler

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/characters/IsoZombie.doZombieSpeedInternal(I)V` | 43 | invoke | `zombie/characters/IsoZombie.doShambler()V` |

## doSprinter

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/characters/IsoZombie.doZombieSpeedInternal(I)V` | 114 | invoke | `zombie/characters/IsoZombie.doSprinter()V` |

## doZombieSpeed

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/characters/IsoZombie.DoZombieStats()V` | 478 | invoke | `zombie/characters/IsoZombie.doZombieSpeed()V` |
| `zombie/characters/IsoZombie.makeInactive(Z)V` | 55 | invoke | `zombie/characters/IsoZombie.doZombieSpeed()V` |

## doorOpeningPercentage

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/SandboxOptions$ZombieLore.<init>(Lzombie/SandboxOptions;)V` | 199 | write | `zombie/SandboxOptions$ZombieLore.doorOpeningPercentageLzombie/SandboxOptions$IntegerSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 48 | read | `zombie/SandboxOptions$ZombieLore.doorOpeningPercentageLzombie/SandboxOptions$IntegerSandboxOption;` |

## getHearingMultiplier

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/WorldSoundManager.addSound(Ljava/lang/Object;IIIIIFFZZZZS)Lzombie/WorldSoundManager$WorldSound;` | 122 | invoke | `zombie/WorldSoundManager.getHearingMultiplier(I)F` |
| `zombie/WorldSoundManager.getBiggestSoundZomb(IIIZLzombie/characters/IsoZombie;)Lzombie/WorldSoundManager$ResultBiggestSound;` | 165 | invoke | `zombie/WorldSoundManager.getHearingMultiplier(Lzombie/characters/IsoZombie;)F` |
| `zombie/WorldSoundManager.getSoundAttract(Lzombie/WorldSoundManager$WorldSound;Lzombie/characters/IsoZombie;)F` | 67 | invoke | `zombie/WorldSoundManager.getHearingMultiplier(Lzombie/characters/IsoZombie;)F` |
| `zombie/WorldSoundManager.render()V` | 68 | invoke | `zombie/WorldSoundManager.getHearingMultiplier(I)F` |
| `zombie/WorldSoundManager.getHearingMultiplier(Lzombie/characters/IsoZombie;)F` | 6 | invoke | `zombie/WorldSoundManager.getHearingMultiplier(I)F` |
| `zombie/WorldSoundManager.getHearingMultiplier(Lzombie/characters/IsoZombie;)F` | 15 | invoke | `zombie/WorldSoundManager.getHearingMultiplier(I)F` |
| `zombie/popman/ZombiePopulationManager.addWorldSound(Lzombie/WorldSoundManager$WorldSound;Z)V` | 62 | invoke | `zombie/WorldSoundManager.getHearingMultiplier(I)F` |

## getVisionRadiusAdjusted

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/characters/IsoZombie.updateVisionRadius()V` | 100 | invoke | `zombie/characters/IsoZombie.getVisionRadiusAdjusted(FFF)F` |

## getZombieLungeSpeed

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/ai/states/LungeState.execute(Lzombie/characters/IsoGameCharacter;)V` | 129 | invoke | `zombie/characters/IsoZombie.getZombieLungeSpeed()V` |

## hearing

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/SandboxOptions$ZombieLore.<init>(Lzombie/SandboxOptions;)V` | 281 | write | `zombie/SandboxOptions$ZombieLore.hearingLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/WorldSoundManager.addSound(Ljava/lang/Object;IIIIIFFZZZZS)Lzombie/WorldSoundManager$WorldSound;` | 69 | read | `zombie/SandboxOptions$ZombieLore.hearingLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/WorldSoundManager.render()V` | 45 | read | `zombie/SandboxOptions$ZombieLore.hearingLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/WorldSoundManager.getHearingMultiplier(Lzombie/characters/IsoZombie;)F` | 12 | read | `zombie/characters/IsoZombie.hearingI` |
| `zombie/characters/IsoZombie.<init>(Lzombie/iso/IsoCell;Lzombie/characters/SurvivorDesc;I)V` | 61 | write | `zombie/characters/IsoZombie.hearingI` |
| `zombie/characters/IsoZombie.RespondToSound()V` | 977 | read | `zombie/SandboxOptions$ZombieLore.hearingLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.RespondToSound()V` | 996 | read | `zombie/SandboxOptions$ZombieLore.hearingLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 409 | read | `zombie/SandboxOptions$ZombieLore.hearingLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 426 | write | `zombie/characters/IsoZombie.hearingI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 438 | read | `zombie/SandboxOptions$ZombieLore.hearingLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 455 | write | `zombie/characters/IsoZombie.hearingI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 468 | read | `zombie/SandboxOptions$ZombieLore.hearingLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 474 | write | `zombie/characters/IsoZombie.hearingI` |
| `zombie/popman/ZombiePopulationManager.addWorldSound(Lzombie/WorldSoundManager$WorldSound;Z)V` | 39 | read | `zombie/SandboxOptions$ZombieLore.hearingLzombie/SandboxOptions$EnumSandboxOption;` |

## inactive

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/VirtualZombieManager.createZombieOutsideWorld(Lzombie/iso/IsoDirections;ZI)Lzombie/characters/IsoZombie;` | 416 | write | `zombie/characters/IsoZombie.inactiveZ` |
| `zombie/characters/IsoZombie.<init>(Lzombie/iso/IsoCell;Lzombie/characters/SurvivorDesc;I)V` | 660 | write | `zombie/characters/IsoZombie.inactiveZ` |
| `zombie/characters/IsoZombie.load(Ljava/nio/ByteBuffer;IZ)V` | 205 | write | `zombie/characters/IsoZombie.inactiveZ` |
| `zombie/characters/IsoZombie.spottedNew(Lzombie/iso/IsoMovingObject;Z)V` | 1172 | read | `zombie/characters/IsoZombie.inactiveZ` |
| `zombie/characters/IsoZombie.spottedOld(Lzombie/iso/IsoMovingObject;Z)V` | 1637 | read | `zombie/characters/IsoZombie.inactiveZ` |
| `zombie/characters/IsoZombie.getZombieWalkTowardSpeed(FFLzombie/iso/Vector2;)V` | 66 | read | `zombie/characters/IsoZombie.inactiveZ` |
| `zombie/characters/IsoZombie.getZombieLungeSpeed()V` | 18 | read | `zombie/characters/IsoZombie.inactiveZ` |
| `zombie/characters/IsoZombie.resetForReuse()V` | 163 | write | `zombie/characters/IsoZombie.inactiveZ` |
| `zombie/characters/IsoZombie.makeInactive(Z)V` | 2 | read | `zombie/characters/IsoZombie.inactiveZ` |
| `zombie/characters/IsoZombie.makeInactive(Z)V` | 46 | write | `zombie/characters/IsoZombie.inactiveZ` |
| `zombie/characters/IsoZombie.makeInactive(Z)V` | 68 | write | `zombie/characters/IsoZombie.inactiveZ` |
| `zombie/characters/IsoZombie.getSandboxMemoryDuration()I` | 18 | read | `zombie/characters/IsoZombie.inactiveZ` |
| `zombie/characters/IsoZombie.determineZombieSpeed(I)I` | 21 | read | `zombie/characters/IsoZombie.inactiveZ` |
| `zombie/characters/BodyDamage/BodyDamage.AddRandomDamageFromZombie(Lzombie/characters/IsoZombie;Ljava/lang/String;I)Z` | 766 | read | `zombie/characters/IsoZombie.inactiveZ` |

## initCanCrawlUnderVehicle

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/characters/IsoZombie.DoZombieStats()V` | 482 | invoke | `zombie/characters/IsoZombie.initCanCrawlUnderVehicle()V` |

## isCanCrawlUnderVehicle

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/characters/IsoZombie.load(Ljava/nio/ByteBuffer;IZ)V` | 389 | invoke | `zombie/popman/ZombieStateFlags.isCanCrawlUnderVehicle()Z` |
| `zombie/characters/IsoZombie.renderlast()V` | 17 | invoke | `zombie/characters/IsoZombie.isCanCrawlUnderVehicle()Z` |
| `zombie/pathfind/PathFindRequest.init(Lzombie/pathfind/IPathfinder;Lzombie/ai/astar/Mover;FFFFFF)Lzombie/pathfind/PathFindRequest;` | 71 | invoke | `zombie/characters/IsoZombie.isCanCrawlUnderVehicle()Z` |
| `zombie/pathfind/nativeCode/PathFindRequest.init(Lzombie/pathfind/IPathfinder;Lzombie/ai/astar/Mover;FFFFFF)Lzombie/pathfind/nativeCode/PathFindRequest;` | 110 | invoke | `zombie/characters/IsoZombie.isCanCrawlUnderVehicle()Z` |
| `zombie/popman/ZombiePopulationManager.addZombieStanding(FFFLzombie/iso/IsoDirections;ILzombie/popman/ZombieStateFlags;I)V` | 380 | invoke | `zombie/popman/ZombieStateFlags.isCanCrawlUnderVehicle()Z` |
| `zombie/popman/ZombiePopulationManager.addZombieMoving(FFFLzombie/iso/IsoDirections;ILzombie/popman/ZombieStateFlags;III)V` | 265 | invoke | `zombie/popman/ZombieStateFlags.isCanCrawlUnderVehicle()Z` |
| `zombie/popman/ZombieStateFlags.intFromZombie(Lzombie/characters/IsoZombie;)I` | 51 | invoke | `zombie/characters/IsoZombie.isCanCrawlUnderVehicle()Z` |

## makeInactive

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/characters/IsoZombie.updateActiveState()V` | 7 | invoke | `zombie/characters/IsoZombie.makeInactive(Z)V` |

## memory

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/SandboxOptions$ZombieLore.<init>(Lzombie/SandboxOptions;)V` | 241 | write | `zombie/SandboxOptions$ZombieLore.memoryLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.<init>(Lzombie/iso/IsoCell;Lzombie/characters/SurvivorDesc;I)V` | 51 | write | `zombie/characters/IsoZombie.memoryI` |
| `zombie/characters/IsoZombie.updateInternal()V` | 1501 | read | `zombie/characters/IsoZombie.memoryI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 196 | read | `zombie/SandboxOptions$ZombieLore.memoryLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 232 | read | `zombie/characters/IsoZombie.memoryI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 252 | write | `zombie/characters/IsoZombie.memoryI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 256 | read | `zombie/characters/IsoZombie.memoryI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 277 | write | `zombie/characters/IsoZombie.memoryI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 281 | read | `zombie/characters/IsoZombie.memoryI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 302 | write | `zombie/characters/IsoZombie.memoryI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 306 | read | `zombie/characters/IsoZombie.memoryI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 326 | write | `zombie/characters/IsoZombie.memoryI` |
| `zombie/characters/IsoZombie.getSandboxMemoryDuration()I` | 6 | read | `zombie/SandboxOptions$ZombieLore.memoryLzombie/SandboxOptions$EnumSandboxOption;` |

## setCanCrawlUnderVehicle

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/characters/IsoZombie.load(Ljava/nio/ByteBuffer;IZ)V` | 392 | invoke | `zombie/characters/IsoZombie.setCanCrawlUnderVehicle(Z)V` |
| `zombie/characters/IsoZombie.initCanCrawlUnderVehicle()V` | 108 | invoke | `zombie/characters/IsoZombie.setCanCrawlUnderVehicle(Z)V` |
| `zombie/popman/ZombiePopulationManager.addZombieStanding(FFFLzombie/iso/IsoDirections;ILzombie/popman/ZombieStateFlags;I)V` | 383 | invoke | `zombie/characters/IsoZombie.setCanCrawlUnderVehicle(Z)V` |
| `zombie/popman/ZombiePopulationManager.addZombieMoving(FFFLzombie/iso/IsoDirections;ILzombie/popman/ZombieStateFlags;III)V` | 268 | invoke | `zombie/characters/IsoZombie.setCanCrawlUnderVehicle(Z)V` |

## setSpeedTypeFromWalkType

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/characters/NetworkZombieAI.parse(Lzombie/network/packets/character/ZombiePacket;)V` | 273 | invoke | `zombie/characters/IsoZombie.setSpeedTypeFromWalkType()V` |
| `zombie/popman/NetworkZombiePacker.applyZombie(Lzombie/characters/IsoZombie;)V` | 375 | invoke | `zombie/characters/IsoZombie.setSpeedTypeFromWalkType()V` |
| `zombie/popman/NetworkZombieSimulator.parseZombie(Lzombie/core/network/ByteBufferReader;Lzombie/network/IConnection;)V` | 559 | invoke | `zombie/characters/IsoZombie.setSpeedTypeFromWalkType()V` |

## sight

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/SandboxOptions$ZombieLore.<init>(Lzombie/SandboxOptions;)V` | 261 | write | `zombie/SandboxOptions$ZombieLore.sightLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.<init>(Lzombie/iso/IsoCell;Lzombie/characters/SurvivorDesc;I)V` | 56 | write | `zombie/characters/IsoZombie.sightI` |
| `zombie/characters/IsoZombie.spottedNew(Lzombie/iso/IsoMovingObject;Z)V` | 1140 | read | `zombie/characters/IsoZombie.sightI` |
| `zombie/characters/IsoZombie.spottedNew(Lzombie/iso/IsoMovingObject;Z)V` | 1156 | read | `zombie/characters/IsoZombie.sightI` |
| `zombie/characters/IsoZombie.spottedOld(Lzombie/iso/IsoMovingObject;Z)V` | 1605 | read | `zombie/characters/IsoZombie.sightI` |
| `zombie/characters/IsoZombie.spottedOld(Lzombie/iso/IsoMovingObject;Z)V` | 1621 | read | `zombie/characters/IsoZombie.sightI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 335 | read | `zombie/SandboxOptions$ZombieLore.sightLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 352 | write | `zombie/characters/IsoZombie.sightI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 364 | read | `zombie/SandboxOptions$ZombieLore.sightLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 381 | write | `zombie/characters/IsoZombie.sightI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 394 | read | `zombie/SandboxOptions$ZombieLore.sightLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 400 | write | `zombie/characters/IsoZombie.sightI` |
| `zombie/characters/IsoZombie.getVisionRadiusAdjusted(FFF)F` | 13 | read | `zombie/characters/IsoZombie.sightI` |
| `zombie/characters/IsoZombie.getVisionRadiusAdjusted(FFF)F` | 26 | read | `zombie/SandboxOptions$ZombieLore.sightLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.getVisionRadiusAdjusted(FFF)F` | 45 | read | `zombie/characters/IsoZombie.sightI` |
| `zombie/characters/IsoZombie.getVisionRadiusAdjusted(FFF)F` | 58 | read | `zombie/SandboxOptions$ZombieLore.sightLzombie/SandboxOptions$EnumSandboxOption;` |

## speed

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/SandboxOptions$ZombieLore.<init>(Lzombie/SandboxOptions;)V` | 31 | write | `zombie/SandboxOptions$ZombieLore.speedLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/SandboxOptions.<init>()V` | 6 | write | `zombie/SandboxOptions.speedI` |
| `zombie/SandboxOptions.updateFromLua()V` | 76 | read | `zombie/SandboxOptions.speedI` |
| `zombie/characters/IsoZombie.getZombieWalkTowardSpeed(FFLzombie/iso/Vector2;)V` | 55 | read | `zombie/SandboxOptions$ZombieLore.speedLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.getZombieLungeSpeed()V` | 7 | read | `zombie/SandboxOptions$ZombieLore.speedLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieSpeeds(F)V` | 43 | read | `zombie/SandboxOptions$ZombieLore.speedLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieSpeeds(F)V` | 125 | read | `zombie/SandboxOptions$ZombieLore.speedLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.doZombieSpeedInternal(I)V` | 27 | read | `zombie/SandboxOptions$ZombieLore.speedLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.doZombieSpeedInternal(I)V` | 70 | read | `zombie/SandboxOptions$ZombieLore.speedLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.doZombieSpeedInternal(I)V` | 98 | read | `zombie/SandboxOptions$ZombieLore.speedLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.determineZombieSpeed(I)I` | 13 | read | `zombie/SandboxOptions$ZombieLore.speedLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/gameStates/GameLoadingState.renderProgressIndicator()V` | 32 | read | `zombie/SandboxOptions$ZombieLore.speedLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/pathfind/PathFindBehavior2.update(F)Lzombie/pathfind/PathFindBehavior2$BehaviorResult;` | 1511 | read | `zombie/SandboxOptions$ZombieLore.speedLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/pathfind/PathFindBehavior2.moveToPoint(FFF)V` | 158 | read | `zombie/SandboxOptions$ZombieLore.speedLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/pathfind/PathFindBehavior2.moveToDir(Lzombie/iso/IsoMovingObject;F)V` | 106 | read | `zombie/SandboxOptions$ZombieLore.speedLzombie/SandboxOptions$EnumSandboxOption;` |

## speedMod

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/characters/IsoGameCharacter.<init>(Lzombie/iso/IsoCell;FFF)V` | 121 | write | `zombie/characters/IsoGameCharacter.speedModF` |
| `zombie/characters/IsoGameCharacter.getSpeedMod()F` | 1 | read | `zombie/characters/IsoGameCharacter.speedModF` |
| `zombie/characters/IsoGameCharacter.setSpeedMod(F)V` | 2 | write | `zombie/characters/IsoGameCharacter.speedModF` |
| `zombie/characters/IsoZombie.updateInternal()V` | 1442 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.DoZombieSpeeds(F)V` | 9 | write | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.DoZombieSpeeds(F)V` | 55 | write | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.DoZombieSpeeds(F)V` | 60 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.DoZombieSpeeds(F)V` | 74 | write | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.DoZombieSpeeds(F)V` | 109 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.DoZombieSpeeds(F)V` | 142 | write | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.DoZombieSpeeds(F)V` | 177 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doCrawlerSpeed(I)V` | 4 | write | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doCrawlerSpeed(I)V` | 9 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doCrawlerSpeed(I)V` | 23 | write | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doSprinter()V` | 9 | write | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doSprinter()V` | 21 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doSprinter()V` | 35 | write | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doSprinter()V` | 57 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doFastShambler()V` | 9 | write | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doFastShambler()V` | 21 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doFastShambler()V` | 35 | write | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doFastShambler()V` | 57 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doFakeShambler()V` | 4 | write | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doFakeShambler()V` | 9 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doFakeShambler()V` | 23 | write | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doFakeShambler()V` | 52 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doFakeShambler(I)V` | 4 | write | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doFakeShambler(I)V` | 9 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doFakeShambler(I)V` | 23 | write | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doFakeShambler(I)V` | 52 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doShambler()V` | 4 | write | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doShambler()V` | 9 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doShambler()V` | 23 | write | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/IsoZombie.doShambler()V` | 52 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/NetworkZombieAI.setUsingLungeState(Lzombie/network/packets/character/ZombiePacket;J)V` | 145 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/NetworkZombieAI.setUsingLungeState(Lzombie/network/packets/character/ZombiePacket;J)V` | 215 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/NetworkZombieAI.setUsingPathFindState(Lzombie/network/packets/character/ZombiePacket;)V` | 75 | read | `zombie/characters/IsoZombie.speedModF` |
| `zombie/characters/NetworkZombieAI.set(Lzombie/network/packets/character/ZombiePacket;)V` | 82 | read | `zombie/characters/IsoZombie.speedModF` |

## speedType

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/VirtualZombieManager.createZombieOutsideWorld(Lzombie/iso/IsoDirections;ZI)Lzombie/characters/IsoZombie;` | 405 | write | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/ai/states/AttackState.execute(Lzombie/characters/IsoGameCharacter;)V` | 250 | read | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/ai/states/ZombieHitReactionState.animEvent(Lzombie/characters/IsoGameCharacter;Lzombie/core/skinnedmodel/advancedanimation/AnimLayer;Lzombie/core/skinnedmodel/animation/AnimationTrack;Lzombie/core/skinnedmodel/advancedanimation/AnimEvent;)V` | 145 | read | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.<init>(Lzombie/iso/IsoCell;Lzombie/characters/SurvivorDesc;I)V` | 36 | write | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.load(Ljava/nio/ByteBuffer;IZ)V` | 195 | write | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.moveUnmodded(FF)V` | 1 | read | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.isSolidForSeparate()Z` | 51 | read | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.updateZombieTripping()V` | 1 | read | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.getVoiceChoice()I` | 1 | read | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.getVoiceChoice()I` | 20 | read | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.getVoiceChoice()I` | 41 | read | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.getVoiceSoundName()Ljava/lang/String;` | 9 | read | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.getBiteSoundName()Ljava/lang/String;` | 9 | read | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.getZombieWalkTowardSpeed(FFLzombie/iso/Vector2;)V` | 73 | read | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.getZombieLungeSpeed()V` | 25 | read | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.setSpeedTypeFromWalkType()V` | 8 | write | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.resetForReuse()V` | 168 | write | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.makeInactive(Z)V` | 51 | write | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.makeInactive(Z)V` | 63 | write | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.doZombieSpeed()V` | 2 | read | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.doSprinter()V` | 66 | write | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.doFastShambler()V` | 66 | write | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.doShambler()V` | 61 | write | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.getSpeedType()I` | 1 | read | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.doZombieSpeedInternal2()V` | 2 | read | `zombie/characters/IsoZombie.speedTypeI` |
| `zombie/characters/IsoZombie.doZombieSpeedInternal2(I)V` | 72 | write | `zombie/characters/IsoZombie.speedTypeI` |

## sprinterPercentage

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/SandboxOptions$ZombieLore.<init>(Lzombie/SandboxOptions;)V` | 54 | write | `zombie/SandboxOptions$ZombieLore.sprinterPercentageLzombie/SandboxOptions$IntegerSandboxOption;` |
| `zombie/characters/IsoZombie.determineZombieSpeed(I)I` | 48 | read | `zombie/SandboxOptions$ZombieLore.sprinterPercentageLzombie/SandboxOptions$IntegerSandboxOption;` |

## strength

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/SandboxOptions$ZombieLore.<init>(Lzombie/SandboxOptions;)V` | 74 | write | `zombie/SandboxOptions$ZombieLore.strengthLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoGameCharacter.testDefense(Lzombie/characters/IsoZombie;)Z` | 160 | read | `zombie/SandboxOptions$ZombieLore.strengthLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoGameCharacter.testDefense(Lzombie/characters/IsoZombie;)Z` | 179 | read | `zombie/SandboxOptions$ZombieLore.strengthLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.<init>(Lzombie/iso/IsoCell;Lzombie/characters/SurvivorDesc;I)V` | 41 | write | `zombie/characters/IsoZombie.strengthI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 71 | read | `zombie/characters/IsoZombie.strengthI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 84 | read | `zombie/SandboxOptions$ZombieLore.strengthLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 96 | write | `zombie/characters/IsoZombie.strengthI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 100 | read | `zombie/characters/IsoZombie.strengthI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 113 | read | `zombie/SandboxOptions$ZombieLore.strengthLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 125 | write | `zombie/characters/IsoZombie.strengthI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 129 | read | `zombie/characters/IsoZombie.strengthI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 142 | read | `zombie/SandboxOptions$ZombieLore.strengthLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 154 | write | `zombie/characters/IsoZombie.strengthI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 158 | read | `zombie/characters/IsoZombie.strengthI` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 171 | read | `zombie/SandboxOptions$ZombieLore.strengthLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.DoZombieStats()V` | 187 | write | `zombie/characters/IsoZombie.strengthI` |
| `zombie/characters/IsoZombie.resetForReuse()V` | 123 | write | `zombie/characters/IsoZombie.strengthI` |
| `zombie/characters/BodyDamage/BodyDamage.AddRandomDamageFromZombie(Lzombie/characters/IsoZombie;Ljava/lang/String;I)Z` | 157 | read | `zombie/SandboxOptions$ZombieLore.strengthLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/BodyDamage/BodyDamage.AddRandomDamageFromZombie(Lzombie/characters/IsoZombie;Ljava/lang/String;I)Z` | 176 | read | `zombie/SandboxOptions$ZombieLore.strengthLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/iso/objects/IsoBarricade.Thump(Lzombie/iso/IsoMovingObject;I)V` | 51 | read | `zombie/characters/IsoZombie.strengthI` |
| `zombie/iso/objects/IsoDoor.Thump(Lzombie/iso/IsoMovingObject;I)V` | 174 | read | `zombie/characters/IsoZombie.strengthI` |
| `zombie/iso/objects/IsoDoor.Thump(Lzombie/iso/IsoMovingObject;I)V` | 189 | read | `zombie/SandboxOptions$ZombieLore.strengthLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/iso/objects/IsoWindow.Thump(Lzombie/iso/IsoMovingObject;I)V` | 131 | read | `zombie/characters/IsoZombie.strengthI` |
| `zombie/vehicles/AttackVehicleState.animEvent(Lzombie/characters/IsoGameCharacter;Lzombie/core/skinnedmodel/advancedanimation/AnimLayer;Lzombie/core/skinnedmodel/animation/AnimationTrack;Lzombie/core/skinnedmodel/advancedanimation/AnimEvent;)V` | 407 | read | `zombie/characters/IsoZombie.strengthI` |
| `zombie/vehicles/AttackVehicleState.animEvent(Lzombie/characters/IsoGameCharacter;Lzombie/core/skinnedmodel/advancedanimation/AnimLayer;Lzombie/core/skinnedmodel/animation/AnimationTrack;Lzombie/core/skinnedmodel/advancedanimation/AnimEvent;)V` | 552 | read | `zombie/characters/IsoZombie.strengthI` |

## thumpNoChasing

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/SandboxOptions$ZombieLore.<init>(Lzombie/SandboxOptions;)V` | 309 | write | `zombie/SandboxOptions$ZombieLore.thumpNoChasingLzombie/SandboxOptions$BooleanSandboxOption;` |
| `zombie/characters/IsoZombie.collideWith(Lzombie/iso/IsoObject;)V` | 356 | read | `zombie/SandboxOptions$ZombieLore.thumpNoChasingLzombie/SandboxOptions$BooleanSandboxOption;` |
| `zombie/characters/IsoZombie.tryThump(Lzombie/iso/IsoGridSquare;)Z` | 686 | read | `zombie/SandboxOptions$ZombieLore.thumpNoChasingLzombie/SandboxOptions$BooleanSandboxOption;` |

## thumpOnConstruction

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/SandboxOptions$ZombieLore.<init>(Lzombie/SandboxOptions;)V` | 323 | write | `zombie/SandboxOptions$ZombieLore.thumpOnConstructionLzombie/SandboxOptions$BooleanSandboxOption;` |
| `zombie/characters/IsoZombie.collideWith(Lzombie/iso/IsoObject;)V` | 390 | read | `zombie/SandboxOptions$ZombieLore.thumpOnConstructionLzombie/SandboxOptions$BooleanSandboxOption;` |
| `zombie/iso/objects/IsoCompost.Thump(Lzombie/iso/IsoMovingObject;I)V` | 6 | read | `zombie/SandboxOptions$ZombieLore.thumpOnConstructionLzombie/SandboxOptions$BooleanSandboxOption;` |
| `zombie/iso/objects/IsoThumpable.Thump(Lzombie/iso/IsoMovingObject;I)V` | 6 | read | `zombie/SandboxOptions$ZombieLore.thumpOnConstructionLzombie/SandboxOptions$BooleanSandboxOption;` |

## toughness

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/SandboxOptions$ZombieLore.<init>(Lzombie/SandboxOptions;)V` | 94 | write | `zombie/SandboxOptions$ZombieLore.toughnessLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/VirtualZombieManager.createZombieOutsideWorld(Lzombie/iso/IsoDirections;ZI)Lzombie/characters/IsoZombie;` | 642 | read | `zombie/SandboxOptions$ZombieLore.toughnessLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/VirtualZombieManager.createZombieOutsideWorld(Lzombie/iso/IsoDirections;ZI)Lzombie/characters/IsoZombie;` | 674 | read | `zombie/SandboxOptions$ZombieLore.toughnessLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/VirtualZombieManager.createZombieOutsideWorld(Lzombie/iso/IsoDirections;ZI)Lzombie/characters/IsoZombie;` | 706 | read | `zombie/SandboxOptions$ZombieLore.toughnessLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/VirtualZombieManager.createZombieOutsideWorld(Lzombie/iso/IsoDirections;ZI)Lzombie/characters/IsoZombie;` | 738 | read | `zombie/SandboxOptions$ZombieLore.toughnessLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoPlayer.calculateCritChance(Lzombie/characters/IsoGameCharacter;)I` | 779 | read | `zombie/SandboxOptions$ZombieLore.toughnessLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoPlayer.calculateCritChance(Lzombie/characters/IsoGameCharacter;)I` | 801 | read | `zombie/SandboxOptions$ZombieLore.toughnessLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.resetForReuse()V` | 322 | read | `zombie/SandboxOptions$ZombieLore.toughnessLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.resetForReuse()V` | 353 | read | `zombie/SandboxOptions$ZombieLore.toughnessLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.resetForReuse()V` | 384 | read | `zombie/SandboxOptions$ZombieLore.toughnessLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/characters/IsoZombie.resetForReuse()V` | 415 | read | `zombie/SandboxOptions$ZombieLore.toughnessLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/iso/objects/IsoDeadBody.reanimate()Lzombie/characters/IsoGameCharacter;` | 391 | read | `zombie/SandboxOptions$ZombieLore.toughnessLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/iso/objects/IsoDeadBody.reanimate()Lzombie/characters/IsoGameCharacter;` | 422 | read | `zombie/SandboxOptions$ZombieLore.toughnessLzombie/SandboxOptions$EnumSandboxOption;` |
| `zombie/iso/objects/IsoDeadBody.reanimate()Lzombie/characters/IsoGameCharacter;` | 453 | read | `zombie/SandboxOptions$ZombieLore.toughnessLzombie/SandboxOptions$EnumSandboxOption;` |

## updateActiveState

| Caller / descriptor | Offset | Operation | Resolved target |
|---|---:|---|---|
| `zombie/characters/IsoZombie.updateInternal()V` | 62 | invoke | `zombie/characters/IsoZombie.updateActiveState()V` |
