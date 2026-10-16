local SpawnAdapter = {}

function SpawnAdapter.spawn(_typeId, _location, _options)
    return false, "spawn injection belongs to Phase G and is not enabled yet"
end

return SpawnAdapter
