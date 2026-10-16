local bound=0
local function event()return{Add=function()bound=bound+1 end}end
Events={OnClientCommand=event(),OnServerCommand=event(),OnTick=event(),OnZombieCreate=event(),OnConnected=event(),OnDisconnect=event()}
isServer=function()return false end
isClient=function()return false end
package.loaded['Mortis/init']={Events={on=function()bound=bound+1 end}}
package.loaded['Mortis/Runtime/Replication']={newSessionEpoch=function()return 'sp' end}
package.loaded['Mortis/Runtime/Adapters/NetworkAdapter']={}
package.loaded['Mortis/Core/Logger']={info=function()end}
local server=require 'Mortis/ReplicationServer'
local client=require 'Mortis/ReplicationClient'
assert(type(server.sendZombie)=='function' and type(client.onZombieCreated)=='function')
assert(bound==0,'single-player must not register multiplayer reconciliation work')
print('SP keeps core presentation/test tooling without MP polling')
