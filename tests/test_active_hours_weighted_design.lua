local Weighted=dofile('experiments/active-hours/weighted_ranges.lua')
local unpackValues=table.unpack or unpack
local function near(a,b)assert(math.abs(a-b)<1e-12)end
local two=assert(Weighted.compile('shambler','fastShambler',20,40))
near(two.entries[1].probability,1/3);near(two.entries[2].probability,2/3)
assert(Weighted.sample(two,0)=='shambler')
assert(Weighted.sample(two,1/3)=='fastShambler')
local three=assert(Weighted.compile('shambler','sprinter',10,40))
near(three.entries[2].probability,.5)
assert(Weighted.sample(three,0)=='shambler')
assert(Weighted.sample(three,.1)=='fastShambler')
assert(Weighted.sample(three,.6)=='sprinter')
local single=assert(Weighted.compile('fastShambler','fastShambler',100,100))
assert(#single.entries==1 and single.entries[1].probability==1)
assert(Weighted.sample(single,.999999)=='fastShambler')
local middle=assert(Weighted.compile('shambler','sprinter',0,0))
assert(Weighted.sample(middle,0)=='fastShambler' and Weighted.sample(middle,.999999)=='fastShambler')
local zeroFirst=assert(Weighted.compile('fastShambler','sprinter',0,40))
assert(Weighted.sample(zeroFirst,0)=='sprinter')
local zeroLast=assert(Weighted.compile('shambler','sprinter',100,0))
assert(Weighted.sample(zeroLast,.999999)=='shambler')
for _,range in ipairs({{'unknown','sprinter',10,40},{'sprinter','shambler',10,40},
 {'shambler','sprinter',70,40},{'shambler','fastShambler',70,40},
 {'shambler','fastShambler',0,0}})do
 assert(Weighted.compile(unpackValues(range))==nil)
end
for _,bad in ipairs({-1,101,math.huge,-math.huge,0/0,'10',false})do
 assert(Weighted.compile('shambler','sprinter',bad,40)==nil)
 assert(Weighted.compile('sprinter','sprinter',bad,40)==nil,'ignored allocations still require valid numbers')
end
for _,bad in ipairs({-1,1,math.huge,0/0,'0.5',false})do assert(Weighted.sample(three,bad)==nil)end
assert(Weighted.sample(three,nil)==nil)
local rounded=assert(Weighted.compile('shambler','sprinter',60,40+1e-10))
assert(rounded.entries[2].probability==0 and rounded.entries[3].cumulative==1)
assert(Weighted.compile('shambler','sprinter',60,40+1e-6)==nil)
-- Deterministic grid checks the complete probability partition without RNG.
local counts={shambler=0,fastShambler=0,sprinter=0}
for i=0,999 do
 local roll=(i+.5)/1000
 local category=Weighted.sample(three,roll)
 assert(category==Weighted.sample(three,roll),'same supplied roll must remain stable')
 counts[category]=counts[category]+1
end
assert(counts.shambler==100 and counts.fastShambler==500 and counts.sprinter==400)
assert(rawget(_G,'MortisActiveHours')==nil,'math experiment creates no controller globals')
print('Offline weighted-range design validates bounds, normalized CDF and stable supplied rolls')
