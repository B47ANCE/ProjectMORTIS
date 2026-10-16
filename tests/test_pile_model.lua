local Piles = dofile(arg[1])
local body = { mass=75, footprintArea=0.55, thickness=0.28, posture="corpse", living=false }

local ok, incidental = Piles.evaluate({ contributors={body}, regionArea=1 })
assert(ok and incidental.mode == "INCIDENTAL", "default mode must be incidental")
assert(incidental.effectiveHeight > 0 and incidental.effectiveHeight < 1)

ok = Piles.evaluate({ mode="COMMANDED", contributors={body}, regionArea=1 })
assert(ok == false, "density alone must never create a commanded pile")
ok = Piles.evaluate({ mode="COMMANDED", commanded=true, orderId="alpha:1", contributors={body}, regionArea=1 })
assert(ok == true, "commanded mode requires explicit authority marker and order id")

local many = {}
for i=1,12 do many[i] = body end
local _, large = Piles.evaluate({ contributors=many, regionArea=1 })
assert(large.effectiveHeight > incidental.effectiveHeight, "additional geometry must increase height")
assert(large.bodyHeight <= 4 and large.compression < incidental.compression, "height must compress and remain bounded")

local _, supported = Piles.evaluate({ contributors={body}, regionArea=1, support={height=1.2,stability=0.8} })
assert(supported.effectiveHeight > incidental.effectiveHeight + 1, "static support height must compose")
assert(supported.stability < incidental.stability, "less-stable support must affect composite stability")

local living = { mass=75, footprintArea=0.55, thickness=0.28, posture="prone", living=true }
local _, livePile = Piles.evaluate({ contributors={living}, regionArea=1 })
assert(livePile.stability < incidental.stability, "moving living mass must reduce stability")

local oversized = {}
for i=1,Piles.MAX_CONTRIBUTORS+1 do oversized[i]=body end
ok = Piles.evaluate({ contributors=oversized })
assert(ok == false, "observations must be hard-capped")

local _, invalidEntries = Piles.evaluate({ contributors={{mass=0}, "bad", body}, regionArea=1 })
assert(invalidEntries.contributorCount == 1, "invalid contributors must be ignored safely")
print("M.O.R.T.I.S. bounded pile semantics checks passed")
