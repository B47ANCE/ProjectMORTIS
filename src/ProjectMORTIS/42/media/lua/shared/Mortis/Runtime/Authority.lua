local Authority = {}

function Authority.isClientRuntime()
    return type(isClient) == "function" and isClient() == true
end

function Authority.isDedicatedServerRuntime()
    return type(isServer) == "function" and isServer() == true
end

function Authority.isServerRuntime()
    if Authority.isDedicatedServerRuntime() then return true end
    return not Authority.isClientRuntime()
end

function Authority.canRunCanonicalAI(_zombie)
    return Authority.isServerRuntime()
end

function Authority.canWriteCanonicalState(_zombie)
    return Authority.isServerRuntime()
end

function Authority.mode()
    if Authority.isDedicatedServerRuntime() then return "server" end
    if Authority.isClientRuntime() then return "client" end
    return "singleplayer"
end

return Authority
