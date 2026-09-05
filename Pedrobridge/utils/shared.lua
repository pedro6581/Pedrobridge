local resourceName = GetCurrentResourceName()

Bridge = {
    ResourceName = resourceName,
    Config = BridgeConfig,
    Functions = {},
    Framework = string.lower(BridgeConfig.Framework or "vrpex"),
    Language = string.lower(BridgeConfig.Language or "en"),
    Version = GetResourceMetadata(resourceName, "version", 0)
}


exports("GetBridge", function()
    return Bridge
end)



function splitString(str, delimiter)
    delimiter = delimiter or "-"

    local parts = {}
    for part in string.gmatch(str, "([^" .. delimiter .. "]+)") do
        parts[#parts + 1] = part
    end

    return parts
end
