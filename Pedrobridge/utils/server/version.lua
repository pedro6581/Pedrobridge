local function semverToNumber(v)
    v = tostring(v or ""):gsub("^v", "")
    local major, minor, patch = v:match("^(%d+)%.(%d+)%.(%d+)$")
    if not major then return nil end
    return (tonumber(major) * 1000000) + (tonumber(minor) * 1000) + tonumber(patch)
end


CreateThread(function()

    print(string.format("^6[BjornBridge]^0 -^3 ".. Lang["configuredFramework"] .." ^0", BridgeConfig.Framework))

    if Bridge.Config.UpdateCheck then
        PerformHttpRequest("https://api.github.com/repos/Andrade001/BjornBridge/releases/latest", function(status, body)
            if status == 200 and body then

                local data = (json.decode(body))
                local latestTag = data.tag_name
                local latest = semverToNumber(latestTag)
                local current = semverToNumber(Bridge.Version)

                if latestTag and latest and current and current ~= latest then
                    print(string.format("^6[BjornBridge]^0 - " .. Lang["updateNewVersion"] .. "^0", latestTag, Bridge.Version))
                else
                    print(string.format("^6[BjornBridge]^0 - " .. Lang["updateUpToDate"] .. "^0", Bridge.Version))
                end
            else
                print(string.format("^6[BjornBridge]^0 - %s ^0", Lang["updateError"]))
            end
        end, "GET", "", { ["User-Agent"] = "BjornBridge" })
    end
end)

