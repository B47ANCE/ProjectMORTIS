> CURRENT SCOPE — Lua-only custom behavior profiles supersede native activity control. Retained source evidence is historical and does not prove normal Lua invocation or dedicated multiplayer behavior. See LUA_ONLY_API_AUDIT.md and LUA_MULTIPLAYER_AUTHORITY.md; no runtime gate has passed.

# Native ownership, identity and delivery ordering

2026-10-08; [VERIFIED] means inspected Build 42.21 JAR source/bytecode, not runtime. Paths relative to research/jar-source. JAR SHA256 retained in API_AUDIT.md and the direct-reference index.

## Registration and identity

1. `VirtualZombieManager.createZombieOutsideWorld` prepares pooled/new zombie stats and health (:344, :381 onward).
2. `createRealZombieAlways(IsoDirections,boolean,int,int)` emits OnZombieCreate (:249), then assigns server onlineId (:257), adds zombieMap entry (:265), then calls registerZombie (:267).
3. `ZombiePopulationManager.registerZombie(IsoZombie,int)` :213 returns 0 on clients; server invokes native registration and records the returned ID. It is not a shared client-visible permanent identity.
4. `ServerMap.getUniqueZombieId()` :145 calls `network/IsoObjectID.allocateID()` :61. Its counter is a **short**, increments/wraps and skips -1, without a collision search in this method. Constructor starts at a random offset (:28). Online ID is transport identity, not a durable identity or uniqueness proof over time. A delayed message with an old online ID cannot safely bind a reused zombie.
5. Virtualization: ZombiePopulationManager :443/:450/:475 passes position/outfit/native state and persistentId to n_addZombie; reconstruction :582/:659/:767 carries persistentId to creation. `save()` :866–870 delegates to native n_save. Native DLL allocator/save bodies are not available in this Java trace. Restart durability remains [UNKNOWN]. Pooled reset clears identity before reuse.

## Server ownership sequence

`popman/NetworkZombiePacker.postupdate()` :142 calls updateAuth (:184), then processes received/deleted sets, then per fully connected peer builds/sends ZombieList and synchronization. `NetworkZombieManager.updateAuth(IsoZombie)` :87 chooses ownership based on grapple/target, relevance/distance, existing owner hysteresis and optional server stress setting.

`moveZombie(IsoZombie,UdpConnection,IsoPlayer)` :165 removes old-owner association, adds new-owner association, writes native owner/player, resets speed limiter, updates owner-change time and asks packer for extra update (:188–210). `getZombieAuth(UdpConnection,ZombieListPacket)` :215 lists online IDs; it does not carry a mod activity/profile decision.

Relevant observers are filtered in `NetworkZombiePacker.getZombieData` :208; its normal relayed-update branch excludes the current owner. Owner initial/request data takes a different path (:194–205). Do not assume broadcasting vanilla observer updates delivers mod decisions to the owner.

## Client ownership and reconstruction

`network/packets/character/ZombieListPacket.parse` :34–41 clears/adds authorization IDs then calls `NetworkZombieSimulator.added()` :130. It invokes `becomeLocal` (:154) for existing newly authorized zombies, or marks unknown IDs for later fetch. Lost authorization calls becomeRemote (:162). becomeLocal assigns GameClient.connection as owner and restores native path target; it does not wait for a mod readiness message.

`NetworkZombieSimulator.parseZombie` :194 creates missing zombies via VirtualZombieManager with persistentId=0 (:212), then establishes packet online ID/map and locomotion. At :288–291, an already authorized zombie is made local and the parser returns before the remote networkAi.parse path. At :295 onward, observers take the remote parse path.

`IsoZombie.getOwner/setOwner` :639/:643 delegate through NetworkZombieComponent. `characters/component/NetworkZombieComponent.isRemote` :26 checks authOwner==null; `IsoGameCharacter.isRemote()` :13640 delegates through NetworkComponent. Do not decide authority by a guessed `remote` field. Server and client component/ownership behavior must be observed separately.

## Native trust boundary and locomotion

`NetworkZombiePacker.parseZombie(ByteBufferReader,IConnection)` :100 maps the online ID, rejects updates whose connection differs from getOwner (:111), then applyZombie (:240). `applyZombie` writes packet health (:255), speedMod (:256), flags/walkType and derived speedType (:274–276). This proves a native owner-connection check, not validation of the mod's activity/profile state. A legitimate owner still supplies locomotion/health packets. Server-authoritative profile constraints would require a verified validation/reconciliation boundary; owner identity alone is insufficient.

`NetworkZombieAI.parse` :295–301 applies locomotion for remote zombies. Native updateActiveState runs on each zombie before its client-remote branch and overwrites custom inactivity unless intercepted. makeInactive side effects include random/native derived work. Calling it independently on peers is not proof that derived attributes equal the server's choices; explicit profile/derived-value validation remains required.

## Supported transport candidate, without a new packet protocol

[VERIFIED] LuaManager$GlobalObject exposes `sendServerCommand(IsoPlayer,String,String,KahluaTable)` (:5180), delegating to `GameServer.sendServerCommand` :3530, which resolves the player's connection. GameServer also provides connection-targeted :3462 and relevant-peer :3489 sends; the latter filters fully connected/relevant connections. GameClient.receiveClientCommand :1141–1157 decodes the native table and raises OnServerCommand. GameClient.sendClientCommand :1891 and GameServer.receiveClientCommand :2351–2383 supply OnClientCommand with a player derived from the sending connection.

[INFERRED] Native Lua command transport can carry a small research control message to each preselected peer, with a readiness response validated against connection-derived players. Clients may acknowledge receipt/capability only, never choose activity/profile values. The current simulation owner must be explicitly included, even when observer relevance selection differs. No command names, wire fields, packet rates or serialized schema have been designed or implemented.

[UNKNOWN] Native transport reliability/ordering relative to ZombieList and synchronization, network-thread versus Lua/game-thread dispatch timing, disconnect invalidation, lost-ack recovery and atomic coordinated disable. The source proves addressing and event entry points, not an ordering guarantee across streams. Readiness must be measured before live transitions or authority transfer. An independently arriving command is not a safe production ownership barrier.

## Consequence

A controlled one-zombie proof can preload both continuously connected/relevant clients before permitting the first custom transition, then observe native ownership switching between those same prepared clients. It need not claim restart identity or support unknown late joiners. Any death, reuse, unload, third peer, disconnect or unprepared ownership target ends that bounded proof and requires coordinated restoration. Production join/reconnect/virtualization/restart coverage remains BLOCKED. See ONE_ZOMBIE_POC_ARCHITECTURE.md for prerequisites and exclusions.
