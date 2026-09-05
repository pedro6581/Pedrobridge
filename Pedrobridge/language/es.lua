if BridgeConfig.Language ~= "es" then return end

Lang = {
    promptTitle = "Indicador",
    requestTitle = "Solicitud",
    inputLabel = "Complete el campo abajo",
    acceptTitle = "Aceptar",
    declineTitle = "Rechazar",
    configuredFramework = "Framework configurado: %s",
    vrpLibNotLoaded = "@vrp/lib/utils.lua no se cargó. Descoméntala en el fxmanifest y luego ejecuta refresh y ensure.",
    frameworkNotSet = "Framework no definida. Actualiza config.lua.",
    missingSqlDriver = "No se detectó un driver MySQL (oxmysql/mysql-async).",
    updateNewVersion = "Nueva versión disponible: %s (actual: %s)",
    updateUpToDate = "Estás usando la última versión (%s)",
    updateError = "No se pudo verificar actualizaciones."
}