-- Host data simulation, no disk/native transaction or restart proof.
local Model=dofile('experiments/active-hours/ownership.lua')
local Config=dofile('experiments/active-hours/configuration.lua')
local Choices=dofile('experiments/active-hours/life_choices.lua')
local config=assert(Config.normalize(Config.defaults()))
local choices=assert(Choices.reconcile(nil,'life-A',1,config.selectionKey,{active=.2,inactive=.8}))
local function ctx(s,checkpointed)
 return {lifeId=s.lifeId,sessionId=s.sessionId,sequence=s.sequence,authority=true,checkpointed=checkpointed~=false}
end
local function target(tier)return {tier=tier,revision=1,selectionKey=config.selectionKey}end
local initial=assert(Model.new('life-A','session-A'))
local planned=assert(Model.plan(initial,ctx(initial),target('sprinter'),choices))
local issued,_,command=Model.dispatch(planned,ctx(planned));assert(issued)
assert(not Model.acknowledge(issued,ctx(issued,false),{token=command.token,outcome='applied'}),
 'AH-CR01: uncheckpointed issued input must not produce a confirmed lease')
local refused=assert(Model.acknowledge(issued,ctx(issued),{token=command.token,outcome='refused'}))
assert(not Model.retry(refused,ctx(refused,false)), 'AH-CR01: uncheckpointed refusal must not authorize retry')
local last=assert(Model.validate(planned));last.sequence=9007199254740990
assert(not Model.dispatch(last,ctx(last)), 'AH-CR02: reserve an outcome sequence before issuing')
local penultimate=assert(Model.validate(planned));penultimate.sequence=9007199254740989
local finalIssued,_,finalCommand=Model.dispatch(penultimate,ctx(penultimate));assert(finalIssued)
local finalOutcome=assert(Model.acknowledge(finalIssued,ctx(finalIssued),{token=finalCommand.token,outcome='unknown'}))
assert(finalOutcome.sequence==9007199254740991 and finalOutcome.pending.status=='uncertain')

-- Freeze at every checkpoint on restart, even a settled lease or ready acquire.
local acquired=assert(Model.acknowledge(issued,ctx(issued),{token=command.token,outcome='applied'}))
local release=assert(Model.plan(acquired,ctx(acquired),target('shambler'),choices))
local releasing,_,releaseCommand=Model.dispatch(release,ctx(release));assert(releasing)
local released=assert(Model.acknowledge(releasing,ctx(releasing),{token=releaseCommand.token,outcome='applied'}))
local unknown=assert(Model.acknowledge(releasing,ctx(releasing),{token=releaseCommand.token,outcome='unknown'}))
for _,saved in ipairs({initial,planned,issued,refused,acquired,release,releasing,released,unknown})do
 local reload=assert(Model.validate(saved))
 local restarted=ctx(reload);restarted.sessionId='session-B'
 assert(not Model.plan(reload,restarted,target('inherit'),choices))
 assert(not Model.dispatch(reload,restarted))
 assert(not Model.retry(reload,restarted))
 assert(not Model.acknowledge(reload,restarted,{token=command.token,outcome='applied'}))
end
-- Lost outcome checkpoint leaves an issued record: never resend or infer success.
assert(not Model.dispatch(issued,ctx(issued)))
assert(issued.applied==false and issued.pending.status=='issued')
assert(acquired.applied=='sprinter' and releasing.applied=='sprinter')
assert(released.applied==false and released.pending.kind=='acquire')
assert(not Model.dispatch(released,ctx(released,false)))
assert(not Model.plan(unknown,ctx(unknown),target('inherit'),choices))
print('Offline crash cutpoints, checkpoint admission and outcome sequence headroom pass')
