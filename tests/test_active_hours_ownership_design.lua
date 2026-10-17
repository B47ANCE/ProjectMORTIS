local Model=dofile('experiments/active-hours/ownership.lua')
local Config=dofile('experiments/active-hours/configuration.lua')
local Choices=dofile('experiments/active-hours/life_choices.lua')
local raw=Config.defaults();raw.Enabled=true;raw.ActiveFixedTier=3;raw.InactiveFixedTier=2
local normalized=assert(Config.normalize(raw))
local choices=assert(Choices.reconcile(nil,'life-A',1,normalized.selectionKey,{active=.2,inactive=.8}))
local function target(tier,choice)return {tier=tier,revision=(choice or choices).revision,selectionKey=(choice or choices).selectionKey}end
local function ctx(s,checkpointed)return {lifeId=s.lifeId,sessionId=s.sessionId,sequence=s.sequence,authority=true,checkpointed=checkpointed~=false}end
local function copy(t)local r={};for k,v in pairs(t)do r[k]=type(v)=='table' and copy(v) or v end;return r end
local function equal(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not equal(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end
 return true
end
local function ack(s,command,outcome)return assert(Model.acknowledge(s,ctx(s),{token=command.token,outcome=outcome}))end
local initial=assert(Model.new('life-A','server-session-1'))
assert(initial.applied==false and initial.pending==false)
assert(not Model.plan(initial,ctx(initial,false),target('fastShambler'),choices),'checkpoint prerequisite')
local planned=assert(Model.plan(initial,ctx(initial),target('fastShambler'),choices))
assert(initial.sequence==0 and initial.pending==false,'plan must not mutate saved input')
local issued,_,command=Model.dispatch(planned,ctx(planned));assert(issued)
assert(command.owner==Model.OWNER and command.operation=='acquire' and command.tier=='fastShambler')
assert(not Model.dispatch(issued,ctx(issued)),'duplicate dispatch must not issue another command')
assert(not Model.plan(issued,ctx(issued),target('inherit'),choices),'do not cancel an issued native operation')
local retained=assert(Model.plan(issued,ctx(issued),target('fastShambler'),choices))
assert(equal(retained,issued),'identical pending intent is inert')
local badToken=copy(command);badToken.token='wrong'
assert(not Model.acknowledge(issued,ctx(issued),{token=badToken.token,outcome='applied'}))
local active=ack(issued,command,'applied')
assert(active.applied=='fastShambler' and active.accepted.tier=='fastShambler' and active.pending==false)
assert(not Model.acknowledge(active,ctx(issued),{token=command.token,outcome='applied'}),'stale duplicate result')

-- A phase change retains both rolls but releases this owner before replacement.
local beforeChoices=copy(choices)
local switching=assert(Model.plan(active,ctx(active),target('shambler'),choices))
assert(switching.pending.kind=='release' and switching.applied=='fastShambler')
local releasing,_,releaseCommand=Model.dispatch(switching,ctx(switching));assert(releasing)
assert(releaseCommand.operation=='release' and releaseCommand.tier==nil and releaseCommand.owner==Model.OWNER)
local refused=ack(releasing,releaseCommand,'refused')
assert(refused.applied=='fastShambler' and refused.pending.status=='refused')
assert(not Model.dispatch(refused,ctx(refused)),'busy refusal needs an explicit retry')
-- Disable while cleanup is refused: retain cleanup, never drop its bookkeeping.
local disabled=assert(Model.plan(refused,ctx(refused),target('inherit'),choices))
assert(disabled.applied=='fastShambler' and disabled.pending.kind=='release' and disabled.pending.status=='refused')
local retry=assert(Model.retry(disabled,ctx(disabled)))
local retried,_,retryCommand=Model.dispatch(retry,ctx(retry));assert(retried)
assert(retryCommand.token~=releaseCommand.token)
assert(not Model.acknowledge(retried,ctx(retried),{token=releaseCommand.token,outcome='applied'}),'old attempt cannot complete replacement')
local stopped=ack(retried,retryCommand,'applied')
assert(stopped.applied==false and stopped.pending==false and stopped.accepted.tier=='inherit')
assert(equal(choices,beforeChoices),'ownership and phase changes never redraw choices')

-- Successful release creates a new checkpoint boundary before acquire.
switching=assert(Model.plan(active,ctx(active),target('shambler'),choices))
releasing,_,releaseCommand=Model.dispatch(switching,ctx(switching))
local released=ack(releasing,releaseCommand,'applied')
assert(released.applied==false and released.pending.kind=='acquire' and released.pending.status=='ready')
assert(not Model.dispatch(released,ctx(released,false)))
local acquiring,_,acquireCommand=Model.dispatch(released,ctx(released));assert(acquiring)
assert(acquireCommand.operation=='acquire' and acquireCommand.tier=='shambler')
local inactive=ack(acquiring,acquireCommand,'applied');assert(inactive.applied=='shambler')
-- No-change/cancel is safe only before issue or after confirmed zero-change refusal.
local queued=assert(Model.plan(stopped,ctx(stopped),target('fastShambler'),choices))
local cancelled=assert(Model.plan(queued,ctx(queued),target('inherit'),choices))
assert(cancelled.pending==false and cancelled.applied==false)
local unchanged=assert(Model.plan(active,ctx(active),target('fastShambler'),choices))
assert(equal(active,unchanged))
local cancelledRelease=assert(Model.plan(switching,ctx(switching),target('fastShambler'),choices))
assert(cancelledRelease.pending==false and cancelledRelease.applied=='fastShambler')

-- Unknown/partially changed native outcomes freeze; no guessed rollback/replay.
local uncertain=ack(issued,command,'unknown')
assert(uncertain.pending.status=='uncertain' and uncertain.applied==false)
local reload=assert(Model.validate(copy(uncertain)))
assert(equal(reload,uncertain))
assert(not Model.dispatch(reload,ctx(reload)) and not Model.retry(reload,ctx(reload)))
assert(not Model.plan(reload,ctx(reload),target('inherit'),choices))
assert(not Model.acknowledge(reload,ctx(reload),{token=command.token,outcome='applied'}),'uncertain result needs explicit external review')
local restart=ctx(reload);restart.sessionId='server-session-2'
assert(not Model.dispatch(reload,restart),'restart cannot replay a previous-session lease')
local reusedId=ctx(active);reusedId.lifeId='new-life-on-same-online-id'
assert(not Model.plan(active,reusedId,target('inherit'),choices))
local client=ctx(active);client.authority=false
assert(not Model.plan(active,client,target('inherit'),choices))
assert(not Model.acknowledge(issued,ctx(issued),{token=command.token,outcome='applied',owner='Other.Owner'}))

-- Distribution revision changes are explicit and preserve the queued revision.
raw.ActiveFixedTier=4
local changed=assert(Config.normalize(raw))
local second=assert(Choices.reconcile(choices,'life-A',2,changed.selectionKey,{active=.3,inactive=.7}))
local reconfigured=assert(Model.plan(active,ctx(active),target('sprinter',second),second))
assert(reconfigured.accepted.revision==1 and reconfigured.pending.desired.revision==2)
assert(not Model.plan(reconfigured,ctx(reconfigured),target('inherit'),choices),'stale config cannot overwrite queued selection')
raw.ActiveFixedTier=3
local reverted=assert(Config.normalize(raw))
local third=assert(Choices.reconcile(second,'life-A',3,reverted.selectionKey,{active=.4,inactive=.6}))
local queuedRevert=assert(Model.plan(reconfigured,ctx(reconfigured),target('shambler',third),third))
assert(Model.validate(queuedRevert),'reverting through a queued selection must remain a valid record')
local skipped=assert(Model.plan(active,ctx(active),target('fastShambler',third),third))
assert(skipped.pending==false and skipped.accepted.revision==3,'checkpointed intermediate choice revisions need no native write')
local badChoice=copy(second);badChoice.lifeId='other'
assert(not Model.plan(active,ctx(active),target('sprinter',second),badChoice))
local detached=assert(Model.validate(reconfigured));detached.pending.desired.tier='inherit'
assert(reconfigured.pending.desired.tier=='sprinter')
for _,broken in ipairs({{},setmetatable(copy(active),{}),{version=2}})do assert(not Model.validate(broken))end
local future=copy(uncertain);future.version=2;assert(not Model.validate(future))
local corrupt=copy(active);corrupt.applied='inherit';assert(not Model.validate(corrupt))
corrupt=copy(issued);corrupt.pending.attempt=0;assert(not Model.validate(corrupt))
corrupt=copy(initial);corrupt.unknown=1;assert(not Model.validate(corrupt))
local full=copy(active);full.sequence=9007199254740991
assert(not Model.plan(full,ctx(full),target('inherit'),choices),'finite sequence exhaustion refuses')

-- Enumerate all modeled outcomes for both directions; validate every result.
for _,outcome in ipairs({'applied','refused','unknown'})do
 for _,baseline in ipairs({initial,active})do
  local before=copy(baseline)
  local wanted=baseline.applied==false and 'fastShambler' or 'inherit'
  local p=assert(Model.plan(baseline,ctx(baseline),target(wanted),choices))
  local i,_,effect=Model.dispatch(p,ctx(p));assert(i and Model.validate(i))
  assert(effect.owner==Model.OWNER and effect.operation~='clear')
  local result=ack(i,effect,outcome);assert(Model.validate(result))
  assert(equal(baseline,before),'outcome processing cannot mutate saved input')
 end
end
assert(rawget(_G,'MortisActiveHoursPolicy')==nil)
print('Offline ownership/reconfiguration: cleanup, receipts, cancellation, uncertainty and lifecycle refusal pass')
