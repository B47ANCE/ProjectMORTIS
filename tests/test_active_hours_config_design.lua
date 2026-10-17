local Config=dofile('experiments/active-hours/configuration.lua')
local Choices=dofile('experiments/active-hours/life_choices.lua')
local Weighted=dofile('experiments/active-hours/weighted_ranges.lua')
local function copy(t)local c={};for k,v in pairs(t)do c[k]=v end;return c end
local defaults=assert(Config.normalize({}))
assert(not defaults.enabled and defaults.mode=='Night')
assert(defaults.selectionKey=='AHC1|A=inherit|I=inherit')
local raw=Config.defaults();raw.Enabled=true;raw.Mode=3
assert(Config.normalize(raw).selectionKey==defaults.selectionKey)
local supplied={active=.1,inactive=.9}
local saved=assert(Choices.reconcile(nil,'test-life',1,defaults.selectionKey,supplied))
assert(Choices.reconcile(saved,'test-life',1,Config.normalize(raw).selectionKey))
-- Fixed mode ignores valid range relationships, never invalid primitives.
raw.ActiveRangeMin=3;raw.ActiveRangeMax=1;raw.ActiveMinWeight=100;raw.ActiveMaxWeight=100
assert(Config.normalize(raw).selectionKey==defaults.selectionKey)
raw.ActiveMinWeight='100';assert(not Config.normalize(raw));raw.ActiveMinWeight=100
raw.ActiveSelection=2;assert(not Config.normalize(raw))
raw=Config.defaults();raw.ActiveSelection=2;raw.ActiveRangeMax=2;raw.ActiveMinWeight=20;raw.ActiveMaxWeight=40
local first=assert(Config.normalize(raw))
assert(first.selectionKey=='AHC1|A=shambler:1/3,fastShambler:2/3|I=inherit')
raw.ActiveMinWeight=10;raw.ActiveMaxWeight=20
assert(Config.normalize(raw).selectionKey==first.selectionKey,'equivalent fractions must not reroll')
local record=assert(Choices.reconcile(nil,'test-life',1,first.selectionKey,supplied))
assert(Choices.reconcile(record,'test-life',1,Config.normalize(raw).selectionKey))
raw.ActiveMaxWeight=30
local changed=assert(Config.normalize(raw))
assert(changed.selectionKey~=first.selectionKey)
assert(not Choices.reconcile(record,'test-life',1,changed.selectionKey))
assert(not Choices.reconcile(record,'test-life',2,changed.selectionKey))
assert(Choices.reconcile(record,'test-life',2,changed.selectionKey,{active=.4,inactive=.6}))
-- Equivalent point distributions normalize across fixed/weighted representations.
raw=Config.defaults();raw.ActiveFixedTier=2
local point=assert(Config.normalize(raw)).selectionKey
raw.ActiveSelection=2;raw.ActiveRangeMin=1;raw.ActiveRangeMax=1;raw.ActiveMinWeight=100;raw.ActiveMaxWeight=100
assert(Config.normalize(raw).selectionKey==point)
raw.ActiveRangeMax=3;raw.ActiveMaxWeight=0
assert(Config.normalize(raw).selectionKey==point,'zero-probability endpoints are not distinct choices')
raw.ActiveMinWeight=10;raw.ActiveMaxWeight=40
local three=assert(Config.normalize(raw))
assert(three.selectionKey=='AHC1|A=shambler:1/10,fastShambler:1/2,sprinter:2/5|I=inherit')
assert(Weighted.sample(three.active.cdf,.6)=='sprinter')
local reverse={};for k,v in pairs(raw)do reverse[k]=v end
assert(Config.normalize(reverse).selectionKey==three.selectionKey,'table order must not affect encoding')
raw.InactiveSelection=2;raw.InactiveMinWeight=40;raw.InactiveMaxWeight=10
local both=assert(Config.normalize(raw))
assert(both.selectionKey~=three.selectionKey and both.inactive.kind=='distribution')
local before=copy(raw);local normalized=assert(Config.normalize(raw));normalized.active.cdf.entries[1].category='changed'
assert(Config.normalize(raw).active.cdf.entries[1].category=='shambler')
for k,v in pairs(before)do assert(raw[k]==v)end
for _,bad in ipairs({'1',false,0/0,math.huge,-1,101,1.5})do
 local invalid=copy(raw);invalid.ActiveMinWeight=bad;assert(not Config.normalize(invalid))
end
for _,key in ipairs({'Mode','ActiveSelection','InactiveSelection','ActiveFixedTier','InactiveFixedTier','ActiveRangeMin','InactiveRangeMax'})do
 local invalid=copy(raw);invalid[key]=99;assert(not Config.normalize(invalid),key)
end
local invalid=copy(raw);invalid.Enabled=1;assert(not Config.normalize(invalid))
invalid=copy(raw);invalid.Unknown=1;assert(not Config.normalize(invalid))
assert(not Config.normalize(setmetatable({}, {__index=raw})))
raw=Config.defaults();raw.ActiveSelection=2;raw.ActiveRangeMax=2;raw.ActiveMinWeight=0;raw.ActiveMaxWeight=0
assert(not Config.normalize(raw));raw.ActiveRangeMax=3
assert(Config.normalize(raw).selectionKey=='AHC1|A=fastShambler:1/1|I=inherit')
assert(rawget(_G,'MortisActiveHours')==nil)
print('Offline configuration normalization, rational canonical keys and revision/roll retention pass')
