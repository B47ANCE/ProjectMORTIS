local path = 'experiments/active-hours/life_choices.lua'
local Choices = dofile(path)
local Weighted = dofile('experiments/active-hours/weighted_ranges.lua')
local function copy(t) local c={};for k,v in pairs(t) do c[k]=v end;return c end
local rolls = {active=.1,inactive=.9}
local original, status = Choices.reconcile(nil, 'fixture-life-1', 1, 'selection-A', rolls)
assert(original and status=='candidate')
assert(original.activeRoll==.1 and original.inactiveRoll==.9)
assert(rolls.active==.1, 'inputs are not mutated')
local cdf = assert(Weighted.compile('shambler','sprinter',10,40))
assert(Weighted.sample(cdf,original.activeRoll)=='fastShambler')
assert(Weighted.sample(cdf,original.inactiveRoll)=='sprinter')
-- Repeated updates, day/night changes, reconnect and module replacement all
-- receive the same supplied snapshot. This models reload, not native storage.
for i=1,200 do
    local api = i%2==0 and dofile(path) or Choices
    local current, why = api.reconcile(copy(original),'fixture-life-1',1,'selection-A')
    assert(current and why=='retained')
    assert(current.activeRoll==.1 and current.inactiveRoll==.9)
    current.activeRoll=.75
    assert(original.activeRoll==.1, 'returned records must be detached')
end
local changed = assert(Choices.reconcile(original,'fixture-life-1',2,'selection-B',{active=.9,inactive=.1}))
assert(changed.activeRoll==.9 and changed.inactiveRoll==.1)
assert(original.revision==1, 'candidate construction is not a durable commit')
assert(not Choices.reconcile(changed,'fixture-life-1',1,'selection-A'))
assert(not Choices.reconcile(original,'fixture-life-1',1,'selection-B'))
assert(not Choices.reconcile(original,'fixture-life-1',1,'selection-A',rolls))
assert(not Choices.reconcile(original,'fixture-life-1',2,'selection-A',rolls))
assert(not Choices.reconcile(original,'fixture-life-1',2,'selection-B'))
assert(not Choices.reconcile(original,'fixture-life-2',2,'selection-B',rolls))
assert(not Choices.reconcile(false,'fixture-life-1',1,'selection-A',rolls))
-- Separate draws can coincidentally match; independence is not inequality.
assert(Choices.reconcile(nil,'fixture-life-2',1,'selection-A',{active=.5,inactive=.5}))
for _,version in ipairs({0,2,'1',false}) do
    local bad=copy(original);bad.version=version
    assert(not Choices.reconcile(bad,'fixture-life-1',2,'selection-B',rolls))
    assert(bad.version==version, 'unknown records must be preserved')
end
for _,value in ipairs({0,-1,1.5,math.huge,0/0,'1',false,9007199254740992}) do
    assert(not Choices.reconcile(nil,'fixture-life-1',value,'selection-A',rolls))
    local bad=copy(original);bad.revision=value;assert(not Choices.validate(bad))
end
for _,value in ipairs({-1,1,math.huge,0/0,'0.1',false}) do
    for _,key in ipairs({'active','inactive'}) do
        local bad=copy(rolls);bad[key]=value
        assert(not Choices.reconcile(nil,'fixture-life-1',1,'selection-A',bad))
    end
end
local bad=copy(original);bad.extra=true;assert(not Choices.validate(bad))
bad=copy(original);bad.inactiveRoll=nil;assert(not Choices.validate(bad))
assert(not Choices.validate(setmetatable({}, {__index=original})))
assert(not Choices.reconcile(nil,'fixture-life-1',1,'selection-A',setmetatable({}, {__index=rolls})))
bad=copy(rolls);bad.extra=true;assert(not Choices.reconcile(nil,'fixture-life-1',1,'selection-A',bad))
for _,value in ipairs({'','\n','a\0b',string.rep('x',4097),false}) do
    assert(not Choices.reconcile(nil,'fixture-life-1',1,value,rolls))
end
assert(not Choices.reconcile(nil,string.rep('x',193),1,'selection-A',rolls))
assert(not Choices.reconcile(nil,'fixture-life-1',1,'selection-A',{}))
assert(rawget(_G,'MortisActiveHours')==nil)
print('Offline life/revision choice retention, stale/future/corrupt refusal and CDF integration pass')
