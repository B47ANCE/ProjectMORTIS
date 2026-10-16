SandboxVars={MORTISSystems={
    EnableZombieHunger=false,
    HungerDaysToFull=30,
    FoodSearchRadius=18,
    FoodSeekingMinimumHunger=0.5,
    FoodValueMultiplier=2,
}}
local settings=dofile(assert(arg[1]))
assert(settings.bool("EnableZombieHunger")==false)
assert(settings.number("HungerDaysToFull")==30)
assert(settings.number("FoodSearchRadius")==18)
assert(settings.number("FoodSeekingMinimumHunger")==0.5)
assert(settings.number("FoodValueMultiplier")==2)
print("MORTIS system sandbox settings checks passed")
