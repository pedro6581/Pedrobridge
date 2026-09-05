if BridgeConfig.Language ~= "en" then return end

Lang = {
    promptTitle = "Prompt",
    requestTitle = "Request",
    inputLabel = "Fill in the field below",
    acceptTitle = "Accept",
    declineTitle = "Decline",
    configuredFramework = "Framework configured: %s",
    vrpLibNotLoaded = "@vrp/lib/utils.lua was not loaded. Uncomment it in the fxmanifest and then refresh and ensure!",
    frameworkNotSet = "Framework not defined. Update config.lua.",
    missingSqlDriver = "No MySQL driver detected (oxmysql/mysql-async).",
    updateNewVersion = "New version available: %s (current: %s)",
    updateUpToDate = "You are using the latest version (%s)",
    updateError = "Could not check for updates."
}
