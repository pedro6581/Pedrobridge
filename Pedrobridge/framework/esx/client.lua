---@diagnostic disable: duplicate-set-field

if not string.find(Bridge.Framework, "esx") then return end


local ESX = exports["es_extended"] and exports["es_extended"].getSharedObject()
if not ESX then
    Citizen.CreateThread(function()
        while not ESX do
            TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
            Wait(100)
        end
    end)
end

local notifyColors = {
    sucesso = "success",
    aviso = "inform",
    negado = "error"
}

function Bridge.Functions.Notify(type, message)
    local notifyType = notifyColors[type]
    if notifyType then
        ESX.ShowAdvancedNotification("BjornBridge", "", message, notifyType, 1)
    else
        ESX.ShowNotification(message)
    end
end

function Bridge.Functions.SetHealth(health)
    local ped = PlayerPedId()
    SetEntityHealth(ped, health or 200)
end

RegisterNetEvent("BjornBridge:client:setHealth", function(health)
    Bridge.Functions.SetHealth(health)
end)
