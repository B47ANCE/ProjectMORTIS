-- Pure offline interval proposal. Input comes from fixtures, never the game.
local Phase = {}
local function hour(value) return type(value)=='number' and value==value and value>=0 and value<24 end
function Phase.classify(window, time, mode)
    if mode~='Night' and mode~='Day' and mode~='Both' then return nil,'invalid-mode' end
    -- Both never needs an astronomical observation.
    if mode=='Both' then return 'active' end
    if type(window)~='table' or getmetatable(window)~=nil then return nil,'invalid-window' end
    for key in pairs(window) do
        if key~='kind' and key~='dawn' and key~='dusk' then return nil,'unknown-window-field' end
    end
    local day
    if window.kind=='normal' then
        if not hour(time) or not hour(window.dawn) or not hour(window.dusk) or window.dawn==window.dusk then
            return nil,'invalid-window'
        end
        if window.dawn<window.dusk then day=time>=window.dawn and time<window.dusk
        else day=time>=window.dawn or time<window.dusk end
    elseif window.kind=='endlessDay' or window.kind=='endlessNight' then
        if window.dawn~=nil or window.dusk~=nil then return nil,'ambiguous-window' end
        day=window.kind=='endlessDay'
    else return nil,'unknown-window-kind' end
    return ((mode=='Day')==day) and 'active' or 'inactive'
end
return Phase
