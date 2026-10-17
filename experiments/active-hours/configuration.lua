-- Offline proposal only; not a sandbox reader, runtime validator or controller.
local Weighted = dofile('experiments/active-hours/weighted_ranges.lua')
local Config = {}
local modes = {'Night','Day','Both'}
local tiers = {'inherit','shambler','fastShambler','sprinter'}
local categories = {'shambler','fastShambler','sprinter'}
local defaults = {Enabled=false,Mode=1}
for _,side in ipairs({'Active','Inactive'}) do
    defaults[side..'Selection']=1; defaults[side..'FixedTier']=1
    defaults[side..'RangeMin']=1; defaults[side..'RangeMax']=3
    defaults[side..'MinWeight']=25; defaults[side..'MaxWeight']=25
end
function Config.defaults()
    local result={};for k,v in pairs(defaults) do result[k]=v end;return result
end
local function integer(n,lo,hi)
    return type(n)=='number' and n==n and n>=lo and n<=hi and n%1==0
end
local function gcd(a,b) while b~=0 do a,b=b,a%b end;return a end
local function distribution(compiled, numerators, denominator)
    local parts={}
    for i,entry in ipairs(compiled.entries) do
        local n=numerators[i]
        if n>0 then
            local divisor=gcd(n,denominator)
            parts[#parts+1]=entry.category..':'..string.format('%.0f/%.0f',n/divisor,denominator/divisor)
        end
    end
    return {kind='distribution',cdf=compiled}, table.concat(parts,',')
end
local function profile(values,side)
    if values[side..'Selection']==1 then
        local tier=tiers[values[side..'FixedTier']]
        if tier=='inherit' then return {kind='inherit'},'inherit' end
        return distribution(assert(Weighted.compile(tier,tier,0,0)),{1},1)
    end
    local lo,hi=values[side..'RangeMin'],values[side..'RangeMax']
    local first,last=values[side..'MinWeight'],values[side..'MaxWeight']
    local compiled,err=Weighted.compile(categories[lo],categories[hi],first,last)
    if not compiled then return nil,side..':'..err end
    if lo==hi then return distribution(compiled,{1},1) end
    if hi-lo==1 then return distribution(compiled,{first,last},first+last) end
    return distribution(compiled,{first,100-first-last,last},100)
end
function Config.normalize(raw)
    if type(raw)~='table' or getmetatable(raw)~=nil then return nil,'invalid-config' end
    for key in pairs(raw) do if defaults[key]==nil then return nil,'unknown-option' end end
    local values=Config.defaults()
    for key in pairs(defaults) do if rawget(raw,key)~=nil then values[key]=raw[key] end end
    if type(values.Enabled)~='boolean' then return nil,'Enabled' end
    if not integer(values.Mode,1,3) then return nil,'Mode' end
    -- Ignored fields still require well-formed bounded primitives.
    for _,side in ipairs({'Active','Inactive'}) do
        for suffix,bounds in pairs({Selection={1,2},FixedTier={1,4},RangeMin={1,3},RangeMax={1,3},MinWeight={0,100},MaxWeight={0,100}}) do
            local key=side..suffix
            if not integer(values[key],bounds[1],bounds[2]) then return nil,key end
        end
    end
    local active,activeKey=profile(values,'Active');if not active then return nil,activeKey end
    local inactive,inactiveKey=profile(values,'Inactive');if not inactive then return nil,inactiveKey end
    return {enabled=values.Enabled,mode=modes[values.Mode],active=active,inactive=inactive,
        selectionKey='AHC1|A='..activeKey..'|I='..inactiveKey}
end
return Config
