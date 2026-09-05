if BridgeConfig.Language ~= "br" then return end

Lang = {
    promptTitle = "Prompt",
    requestTitle = "Pedido",
    inputLabel = "Preencha o campo abaixo",
    acceptTitle = "Aceitar",
    declineTitle = "Negar",
    configuredFramework = "Framework configurada: %s",
    vrpLibNotLoaded = "@vrp/lib/utils.lua não foi carregada, descomente no fxmanifest de refresh e ensure!",
    frameworkNotSet = "Framework não definido. Atualize o config.lua.",
    missingSqlDriver = "Nenhum driver MySQL detectado (oxmysql/mysql-async).",
    updateNewVersion = "Nova versão disponível: %s (atual: %s)",
    updateUpToDate = "Você está utilizando a versão mais recente (%s)",
    updateError = "Não foi possível verificar atualizações."
}