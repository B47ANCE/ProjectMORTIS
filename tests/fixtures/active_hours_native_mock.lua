
Events={}
printed={}
function print(text) printed[#printed+1]=text end
for _,name in ipairs({'OnTick','OnZombieUpdate','OnClientCommand','OnServerCommand','OnKeyPressed'}) do
 local handlers={}
 Events[name]={Add=function(fn) handlers[#handlers+1]=fn end, handlers=handlers}
end
function emit(name,...) for _,fn in ipairs(Events[name].handlers) do fn(...) end end
function require(_) end
function isServer() return mode=='S' end
function isClient() return mode~='S' end
SandboxVars={ZombieLore={ActiveOnly=1}}
Keyboard={KEY_LCONTROL=1,KEY_LSHIFT=2,KEY_F6=6,KEY_F7=7,KEY_F8=8,KEY_F9=9,KEY_F10=10,KEY_F11=11}
function isKeyDown(_) return modifiers or false end
players={}
for _,name in ipairs({'A','B'}) do
 local p={name=name}
 function p:isLocalPlayer() return mode==self.name end
 function p:getAccessLevel() return self.name=='A' and 'admin' or 'none' end
 players[name]=p
end
function getSpecificPlayer(_) return players[mode] end
function newZombie()
 local z={id=7,walk='slow1',category=3,scalar=0.60,owner='A',writes=0,x=0,y=0}
 function z:getOnlineID() return self.id end
 function z:isDead() return self.dead or false end
 function z:isCrawling() return self.crawling or false end
 function z:isOnFloor() return self.onFloor or false end
 function z:isGettingUp() return self.gettingUp or false end
 function z:getCurrentState() return self.nativeState or 'ZombieWalkTowardState' end
 function z:getOwnerPlayer() return players[self.owner] end
 function z:isRemoteZombie() return mode=='S' or self.owner~=mode end
 function z:getWalkType() return self.walk end
 function z:getSpeedType() return self.category end
 function z:getSpeedMod() return self.scalar end
 function z:isRunning() return self.category==1 end
 function z:getActionStateName() return 'WalkToward' end
 function z:getAnimationStateName() return 'walk' end
 function z:getX() return self.x end
 function z:getY() return self.y end
 function z:setWalkType(v) self.walk=v; self.writes=self.writes+1 end
 function z:setSpeedTypeFromWalkType()
  if self.failOnce then self.failOnce=false; error('mock setter failure') end
  self.category=({sprint1=1,['1']=2,slow1=3})[self.walk]
 end
 function z:setSpeedMod(v) self.scalar=v end
 return z
end
Z=newZombie()
