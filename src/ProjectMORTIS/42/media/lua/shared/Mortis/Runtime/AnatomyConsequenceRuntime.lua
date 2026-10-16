local Providers = require "Mortis/API/AnatomyConsequenceProviders"
local Identity = require "Mortis/Runtime/Identity"
local FaultIsolation = require "Mortis/Core/FaultIsolation"

local Runtime = {}

local function matches(provider, entity, result)
    if type(provider.matches) == "function" then
        local ok, value = FaultIsolation.call(provider.id, "matches", provider.matches, entity, result)
        return ok and value == true
    end
    if provider.typeId ~= nil and Identity.getTypeId(entity) ~= provider.typeId then return false end
    if provider.speciesId ~= nil and result.speciesId ~= provider.speciesId then return false end
    return true
end

function Runtime.dispatch(callback, entity, result)
    local responses = {}
    for _, provider in ipairs(Providers.allSorted()) do
        local fn = provider[callback]
        if type(fn) == "function" and matches(provider, entity, result) then
            local ok, response = FaultIsolation.call(provider.id, callback, fn, entity, result)
            responses[#responses+1] = { providerId=provider.id, ok=ok, response=response }
        end
    end
    return responses
end

return Runtime
