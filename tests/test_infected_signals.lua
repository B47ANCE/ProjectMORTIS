package.loaded["Mortis/Runtime/Authority"]={canWriteCanonicalState=function() return true end}
local ids={};package.loaded["Mortis/Runtime/Identity"]={getStableId=function(e)return ids[e]end,ensureStableId=function(e)ids[e]="Z1";return ids[e]end}
local memory=setmetatable({},{__mode="k"});package.loaded["Mortis/Runtime/Components"]={set=function(e,_,v)memory[e]=v end,get=function(e)return memory[e]or{} end}
local Signals=require "Mortis/Runtime/InfectedSignals"
local source={}
local emitted=assert(Signals.emit({source=source,type="alpha-death",x=10,y=20,z=0,radius=30,worldAgeHours=5,expiresWorldAgeHours=8,persistOnSource=true,payload={alphaId="Z1"}}))
assert(emitted.sourceId=="Z1" and Signals.getLastPersistent(source).type=="alpha-death")
assert(#Signals.query(15,20,0,30,6,function(s)return s.type=="alpha-death"end)==1)
assert(#Signals.query(100,100,0,30,6)==0)
assert(#Signals.query(15,20,0,30,9)==0)
print("M.O.R.T.I.S. infected semantic signal checks passed")
