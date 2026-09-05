---@diagnostic disable: duplicate-set-field

if not string.find(Bridge.Framework, "creativev5") then return end


local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local vRP = Proxy.getInterface("vRP")
local vRPclient = Tunnel.getInterface("vRP")

local notifyColors = {
    sucesso = "verde",
    aviso = "amarelo",
    negado = "vermelho"
}

function Bridge.Functions.Notify(type, message)
    local color = notifyColors[type]
    TriggerEvent("Notify", color, message, 5000)
end

function Bridge.Functions.SetHealth(health)
    vRPclient.setHealth(health or 200)
end

RegisterNetEvent("BjornBridge:client:setHealth", function(health)
    Bridge.Functions.SetHealth(health)
end)
