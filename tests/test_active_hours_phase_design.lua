local Phase = dofile('experiments/active-hours/phase_window.lua')
-- Synthetic windows explore the contract; these are not measured astronomy.
local windows = {
    {kind='normal',dawn=8,dusk=16},
    {kind='normal',dawn=5,dusk=21},
    {kind='normal',dawn=20,dusk=4}, -- normalized interval across midnight
}
for _,window in ipairs(windows) do
    assert(Phase.classify(window,window.dawn,'Day')=='active')
    assert(Phase.classify(window,window.dawn,'Night')=='inactive')
    assert(Phase.classify(window,window.dusk,'Day')=='inactive')
    assert(Phase.classify(window,window.dusk,'Night')=='active')
    for tick=0,1439 do
        local day=Phase.classify(window,tick/60,'Day')
        local night=Phase.classify(window,tick/60,'Night')
        assert(day~=night and (day=='active' or night=='active'))
        assert(Phase.classify(window,tick/60,'Both')=='active')
    end
end
assert(Phase.classify(windows[1],12,'Day')=='active')
assert(Phase.classify(windows[1],0,'Night')=='active')
assert(Phase.classify(windows[3],23,'Day')=='active')
assert(Phase.classify(windows[3],12,'Day')=='inactive')
for _,kind in ipairs({'endlessDay','endlessNight'}) do
    local expected=kind=='endlessDay' and 'active' or 'inactive'
    assert(Phase.classify({kind=kind},nil,'Day')==expected)
    assert(Phase.classify({kind=kind},nil,'Night')~=expected)
    assert(not Phase.classify({kind=kind,dawn=0},nil,'Day'))
end
assert(Phase.classify(nil,nil,'Both')=='active', 'Both has no solar requirement')
assert(not Phase.classify(nil,12,'Day'))
assert(not Phase.classify({kind='normal',dawn=6,dusk=6},12,'Day'))
assert(not Phase.classify({kind='unknown'},12,'Day'))
assert(not Phase.classify({kind='endlessDay',weather='rain'},12,'Day'))
assert(not Phase.classify(setmetatable({}, {__index=windows[1]}),12,'Day'))
for _,value in ipairs({-1,24,math.huge,0/0,'12',false}) do
    assert(not Phase.classify(windows[1],value,'Day'))
    assert(not Phase.classify({kind='normal',dawn=value,dusk=18},12,'Day'))
    assert(not Phase.classify({kind='normal',dawn=6,dusk=value},12,'Night'))
end
for _,mode in ipairs({'day','night','',1,false}) do assert(not Phase.classify(windows[1],12,mode)) end
print('Offline day/night boundaries, synthetic seasons, endless windows and invalid input pass')
