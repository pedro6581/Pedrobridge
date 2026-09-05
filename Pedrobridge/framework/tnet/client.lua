---@diagnostic disable: duplicate-set-field

if not string.find(Bridge.Framework, "vrpex") then return end


local notifyColors = {
    sucesso = "sucesso",
    aviso = "aviso",
    negado = "negado"
}

function Bridge.Functions.Notify(type, message)
    local color = notifyColors[type]
    TriggerEvent('Notify', color, message, 10)
end

function Bridge.Functions.SetHealth(health)
    TriggerEvent('net.setEntityHealth', health)
end

RegisterNetEvent("BjornBridge:client:setHealth", function(health)
    TriggerEvent('net.setEntityHealth', health)
end)
