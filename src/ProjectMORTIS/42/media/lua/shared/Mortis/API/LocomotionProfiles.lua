local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"

local Profiles = { registry = Registry.new("locomotion profile") }

local validTiers = {
    sprinter = true,
    fastShambler = true,
    shambler = true,
    inherit = true,
}

local function normalize(definition)
    if type(definition) ~= "table" then error("locomotion profile definition must be a table", 3) end
    local result = Util.deepCopy(definition)
    result.id = Util.assertString(result.id, "locomotion profile id")
    result.tier = result.tier or "inherit"
    if not validTiers[result.tier] then error("invalid locomotion tier: " .. tostring(result.tier), 3) end

    if result.crawler ~= nil then result.crawler = result.crawler == true end
    if result.walkType ~= nil then result.walkType = Util.assertString(result.walkType, "walkType") end
    if result.reconcileInterval ~= nil then
        result.reconcileInterval = math.floor(tonumber(result.reconcileInterval) or 0)
        if result.reconcileInterval < 30 then error("reconcileInterval must be >= 30 ticks", 3) end
    else
        result.reconcileInterval = 600
    end
    if result.crawlerArgs ~= nil and type(result.crawlerArgs) ~= "table" then
        error("locomotion crawlerArgs must be a table", 3)
    end

    -- Reserved semantic knobs. They are validated and retained now so threat
    -- definitions do not need a schema rewrite when a runtime-safe B42 mapping
    -- is verified later.
    local numeric = { "speedMultiplier", "turnMultiplier", "lungeMultiplier" }
    for _, key in ipairs(numeric) do
        if result[key] ~= nil then
            result[key] = tonumber(result[key])
            if not result[key] or result[key] <= 0 then error(key .. " must be > 0", 3) end
        end
    end
    return result
end

function Profiles.register(definition)
    local normalized = normalize(definition)
    return Profiles.registry:register(normalized.id, normalized)
end
function Profiles.get(id) return Profiles.registry:get(id) end
function Profiles.has(id) return Profiles.registry:has(id) end
function Profiles.all() return Profiles.registry:all() end

return Profiles
