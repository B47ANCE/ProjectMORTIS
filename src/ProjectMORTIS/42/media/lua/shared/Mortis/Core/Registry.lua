local Util = require "Mortis/Core/Util"

local Registry = {}
Registry.__index = Registry

function Registry.new(kind)
    return setmetatable({ kind = kind or "entry", entries = {} }, Registry)
end

function Registry:register(id, definition)
    Util.assertString(id, self.kind .. " id")
    if type(definition) ~= "table" then error(self.kind .. " definition must be a table", 2) end
    if self.entries[id] then error(self.kind .. " already registered: " .. id, 2) end
    self.entries[id] = Util.deepCopy(definition)
    return self.entries[id]
end

function Registry:replace(id, definition)
    Util.assertString(id, self.kind .. " id")
    if type(definition) ~= "table" then error(self.kind .. " definition must be a table", 2) end
    self.entries[id] = Util.deepCopy(definition)
    return self.entries[id]
end

function Registry:get(id)
    local value = self.entries[id]
    return value and Util.deepCopy(value) or nil
end

function Registry:has(id)
    return self.entries[id] ~= nil
end

function Registry:all()
    return Util.deepCopy(self.entries)
end

return Registry
