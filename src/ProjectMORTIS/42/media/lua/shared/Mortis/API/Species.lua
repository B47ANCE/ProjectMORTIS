local Registry = require "Mortis/Core/Registry"
local Util = require "Mortis/Core/Util"
local Species = { registry = Registry.new("species/anatomy"), MAX_PARENT_DEPTH=32 }

local function normalizeNumericMap(values, label)
    if values == nil then return {} end
    if type(values) ~= "table" then error(label .. " must be a table", 3) end
    local result = {}
    for key, value in pairs(values) do
        local id = Util.assertString(key, label .. " key")
        local number = tonumber(value)
        if not number or number ~= number or number == math.huge or number == -math.huge then
            error(label .. " value for '" .. id .. "' must be finite", 3)
        end
        result[id] = number
    end
    return result
end

local function normalizeStringList(values, label)
    if values == nil then return {} end
    if type(values) ~= "table" then error(label .. " must be a table", 3) end
    local result, seen = {}, {}
    for _, value in ipairs(values) do
        local text = Util.assertString(value, label .. " entry")
        if not seen[text] then
            seen[text] = true
            result[#result + 1] = text
        end
    end
    table.sort(result)
    return result
end

local function normalizeSocket(regionId, socketId, definition)
    if type(definition) ~= "table" then
        error("socket '" .. tostring(socketId) .. "' on region '" .. regionId .. "' must be a table", 3)
    end
    local socket = Util.deepCopy(definition)
    socket.id = Util.assertString(socketId, "anatomy socket id")
    socket.socketType = Util.assertString(socket.socketType, "anatomy socket type")
    socket.compatibilityTags = normalizeStringList(socket.compatibilityTags, "socket compatibilityTags")
    socket.exclusive = socket.exclusive ~= false
    socket.availability = socket.availability or "missing"
    if socket.availability ~= "always" and socket.availability ~= "missing" and
       socket.availability ~= "attached" and socket.availability ~= "disabled" and
       socket.availability ~= "destroyed" then
        error("socket '" .. socket.id .. "' has unsupported availability '" .. tostring(socket.availability) .. "'", 3)
    end
    return socket
end

local function anatomyNumber(value,default,label,positive)
    if value==nil then return default end
    local number=tonumber(value)
    if not number or number~=number or number==math.huge or number==-math.huge
        or number<0 or (positive and number==0) then
        error(label.." must be "..(positive and "positive" or "nonnegative").." and finite",3)
    end
    return number
end

local NUTRIENTS={calories=true,carbohydrates=true,lipids=true,proteins=true}
local function normalizeNutrition(value,label)
    local result=normalizeNumericMap(value,label)
    for key,number in pairs(result) do
        if not NUTRIENTS[key] then error(label.." contains unsupported nutrient '"..key.."'",3) end
        if number<0 then error(label.." values must be nonnegative",3) end
    end
    for key in pairs(NUTRIENTS) do result[key]=result[key] or 0 end
    return result
end

local function normalizeRegion(id, def, defaultNutrition)
    def = Util.deepCopy(def or {})
    def.id = id
    def.integrity = anatomyNumber(def.integrity,100,"region integrity",true)
    -- Optional relative soft-tissue quantity. No implicit integrity/mass mapping.
    def.tissueCapacity = anatomyNumber(def.tissueCapacity,nil,"region tissueCapacity",true)
    def.tissueNutritionDensity=normalizeNutrition(def.tissueNutritionDensity or defaultNutrition,
        "region tissueNutritionDensity")
    def.severable = def.severable == true
    def.critical = def.critical == true
    def.disableThreshold = anatomyNumber(def.disableThreshold,0,"region disableThreshold",false)
    def.destroyThreshold = anatomyNumber(def.destroyThreshold,0,"region destroyThreshold",false)
    def.tags = def.tags or {}
    def.aliases = def.aliases or {}
    def.channelMultipliers = def.channelMultipliers or {}
    def.capabilityModifiers = normalizeNumericMap(def.capabilityModifiers, "region capabilityModifiers")
    local sockets = {}
    for socketId, socket in pairs(def.attachmentSockets or {}) do
        sockets[socketId] = normalizeSocket(id, socketId, socket)
    end
    def.attachmentSockets = sockets
    return def
end

function Species.register(definition)
    if type(definition) ~= "table" then error("species definition must be a table", 2) end
    local d = Util.deepCopy(definition)
    d.id = Util.assertString(d.id, "species id")
    d.version = math.max(1, math.floor(tonumber(d.version) or 1))
    d.displayName = d.displayName or d.id
    d.defaultRegion = d.defaultRegion or "torso"
    d.regions = d.regions or {}
    d.aliases = d.aliases or {}
    d.tissueNutritionDensity=normalizeNutrition(d.tissueNutritionDensity,"species tissueNutritionDensity")

    local normalized, aliases = {}, {}
    for id, region in pairs(d.regions) do normalized[id] = normalizeRegion(id, region,d.tissueNutritionDensity) end
    for id, region in pairs(normalized) do
        if region.parent and not normalized[region.parent] then
            error("region '" .. id .. "' references missing parent '" .. tostring(region.parent) .. "'", 2)
        end
        aliases[string.lower(id)] = id
        for _, alias in ipairs(region.aliases) do aliases[string.lower(tostring(alias))] = id end
    end
    -- Validate every chain before publishing the definition. Checking only
    -- parent existence accepts self-links and multi-region cycles.
    for id in pairs(normalized) do
        local seen,depth,current={},0,id
        while normalized[current].parent do
            seen[current]=true
            current=normalized[current].parent
            depth=depth+1
            if seen[current] then error("cyclic anatomy parent chain at '"..id.."'",2) end
            if depth>Species.MAX_PARENT_DEPTH then error("anatomy parent depth exceeds supported limit",2) end
        end
    end
    for alias, target in pairs(d.aliases) do aliases[string.lower(tostring(alias))] = tostring(target) end
    if not normalized[d.defaultRegion] then error("invalid defaultRegion: " .. tostring(d.defaultRegion), 2) end
    d.regions, d._aliasMap = normalized, aliases
    return Species.registry:register(d.id, d)
end

function Species.get(id) return Species.registry:get(id) end
function Species.has(id) return Species.registry:has(id) end
function Species.all() return Species.registry:all() end
function Species.resolveRegion(speciesOrId, region)
    local species = type(speciesOrId) == "table" and speciesOrId or Species.get(speciesOrId)
    if not species then return nil end
    if region == nil then return species.defaultRegion end
    return species._aliasMap[string.lower(tostring(region))] or nil
end
return Species
