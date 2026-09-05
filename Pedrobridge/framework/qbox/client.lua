---@diagnostic disable: duplicate-set-field

if not string.find(Bridge.Framework, "qbox") then return end


local notifyColors = {
    sucesso = "success",
    aviso = "primary",
    negado = "error"
}

function Bridge.Functions.Notify(type, message)
    local notifyType = notifyColors[type]
    exports["qbx_core"]:Notify(message, notifyType, 5000)
end

function Bridge.Functions.SetHealth(health)
    local ped = PlayerPedId()
    SetEntityHealth(ped, health or 200)
end

RegisterNetEvent("BjornBridge:client:setHealth", function(health)
    Bridge.Functions.SetHealth(health)
end)
