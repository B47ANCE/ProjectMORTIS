-- Offline design experiment only. Not in the runtime/package source tree.
-- No RNG, native APIs, settings, hooks, persistence or controller registration.
local Weighted = {}
local categories = {'shambler','fastShambler','sprinter'}
local index = {shambler=1,fastShambler=2,sprinter=3}
local totalTolerance = 1e-9 -- Floating-point arithmetic tolerance, not balance.

local function weight(value)
    return type(value)=='number' and value==value and value>=0 and value<=100
end

function Weighted.compile(first,last,firstWeight,lastWeight)
    local lo,hi=index[first],index[last]
    if not lo or not hi then return nil,'unknown-category' end
    if lo>hi then return nil,'reversed-range' end
    if not weight(firstWeight) or not weight(lastWeight) then return nil,'invalid-weight' end
    local count=hi-lo+1
    local total=firstWeight+lastWeight
    local probabilities={}
    if count==1 then
        -- Both inputs must be well formed, but allocations are ignored.
        probabilities[1]=1
    else
        if total>100+totalTolerance then return nil,'endpoint-total-exceeded' end
        if count==2 then
            if total==0 then return nil,'zero-weight-range' end
            probabilities[1]=firstWeight/total
            probabilities[2]=lastWeight/total
        else
            -- Roundoff just above 100 leaves no negative middle bucket.
            local divisor=math.max(100,total)
            probabilities[1]=firstWeight/divisor
            probabilities[2]=math.max(0,100-total)/divisor
            probabilities[3]=lastWeight/divisor
        end
    end
    local result={entries={}}
    local cumulative=0
    for offset=1,count do
        cumulative=cumulative+probabilities[offset]
        result.entries[offset]={category=categories[lo+offset-1],probability=probabilities[offset],
            cumulative=offset==count and 1 or cumulative}
    end
    return result
end

-- The future authority supplies a persisted per-life/config-revision roll.
-- This experiment never draws/re-draws it or assigns a zombie profile.
function Weighted.sample(compiled,roll)
    if type(roll)~='number' or roll~=roll or roll<0 or roll>=1 then return nil,'invalid-roll' end
    for _,entry in ipairs(compiled.entries) do
        if roll<entry.cumulative then return entry.category end
    end
    return nil,'invalid-cdf'
end

return Weighted
