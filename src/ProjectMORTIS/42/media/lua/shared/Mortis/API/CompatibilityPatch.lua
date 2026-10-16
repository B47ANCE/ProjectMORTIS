local Compatibility = require "Mortis/API/WeaponCompatibility"

local Patch = {}

function Patch.begin(definition)
    local provider = Compatibility.registerProvider(definition)
    local api = {}

    function api.weapon(fullType, trauma)
        return Compatibility.registerWeapon(provider.id, fullType, trauma)
    end

    function api.provider()
        return provider
    end

    return api
end

return Patch
