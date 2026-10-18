local Settings={}
local DEFAULTS={
    EnableZombieHunger=true,
    HungerDaysToFull=7.0,
    HungerWorkPerTick=32,
    EnableZombieDesiccation=true,
    DesiccationYearsToTerminal=5.0,
    EnableTerminalWithering=true,
    FoodSearchRadius=12.0,
    FoodSeekingMinimumHunger=0.0,
    FoodValueMultiplier=1.0,
    CollisionRuntimeBatchSize=96,
    MovementRuntimeBatchSize=48,
}
local function sandbox()
    local root=rawget(_G,"SandboxVars")
    return root and root.MORTISSystems or nil
end
function Settings.get(name)
    local values=sandbox()
    if values and values[name]~=nil then return values[name] end
    return DEFAULTS[name]
end
function Settings.bool(name) return Settings.get(name)==true end
function Settings.number(name) return tonumber(Settings.get(name)) or tonumber(DEFAULTS[name]) or 0 end
return Settings
