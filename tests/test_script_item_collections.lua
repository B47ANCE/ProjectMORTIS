local ScriptItem = dofile(arg[1])
local getCalls = 0
local values = { "Blade", "Sharp" }
local collection = {
    iterator=function()
        local index = 0
        return {
            hasNext=function() return index < #values end,
            next=function() index=index+1 return values[index] end,
        }
    end,
    size=function() return #values end,
    get=function() getCalls=getCalls+1 error("Set has no indexed get") end,
}
local script = {
    getTags=function() return collection end,
    getWeaponCategories=function() return collection end,
    getTypeString=function() return "Weapon" end,
    getFullName=function() return "Base.TestWeapon" end,
    getName=function() return "TestWeapon" end,
}

local snapshot = ScriptItem.snapshot(script)
assert(#snapshot.tags == 2 and #snapshot.categories == 2, "expected iterator collection values")
assert(getCalls == 0, "Java Set must not be probed with indexed get")
print("MORTIS script-item collection regression checks passed")
