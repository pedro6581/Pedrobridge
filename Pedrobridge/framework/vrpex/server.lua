---@diagnostic disable: duplicate-set-field

if not string.find(Bridge.Framework, "vrpex") and not string.find(Bridge.Framework, "vrp") then return end

local libLoaded = false
local count = GetNumResourceMetadata(Bridge.ResourceName, "shared_script") or 0

for i = 0, count - 1 do
    local entry = GetResourceMetadata(Bridge.ResourceName, "shared_script", i)
    if entry == "@vrp/lib/utils.lua" then
        libLoaded = true
        break
    end
end

if not libLoaded then
    Wait(300)
    print(string.format("\n\n^6[BjornBridge]^0 -^1 %s ^0", Lang["vrpLibNotLoaded"]))
    return
end


local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local vRP = Proxy.getInterface("vRP")
local vRPClient = Tunnel.getInterface("vRP")

local notifyColors = {
    sucesso = "sucesso",
    aviso = "aviso",
    negado = "negado"
}

function Bridge.Functions.Notify(type, message, source)
    local color = notifyColors[type]
    TriggerClientEvent("Notify", source or -1, color, message, 5000)
end

function Bridge.Functions.GetPlayerId(source)
    return vRP.getUserId(source)
end

function Bridge.Functions.GetSource(user_id)
    return vRP.getUserSource(user_id)
end

function Bridge.Functions.GetUsers()
    return vRP.getUsers()
end

function Bridge.Functions.GetIdentity(source)
    local user_id = Bridge.Functions.GetPlayerId(source)
    local identity = vRP.getUserIdentity(user_id)
    if identity then
        return (identity.name or "") .. (identity.firstname and (" " .. identity.firstname) or "")
    end
end

function Bridge.Functions.CheckPermission(source, permission)
    local user_id = Bridge.Functions.GetPlayerId(source)
    return vRP.hasPermission(user_id, permission)
end

function Bridge.Functions.CheckItem(source, item)
    local user_id = Bridge.Functions.GetPlayerId(source)
    local amount = vRP.getInventoryItemAmount(user_id, item)
    return type(amount) == "table" and amount[1] or amount
end

function Bridge.Functions.RemoveItem(source, item, amount)
    local user_id = Bridge.Functions.GetPlayerId(source)
    return vRP.tryGetInventoryItem(user_id, item, amount)
end

function Bridge.Functions.GiveItem(source, item, amount)
    local user_id = Bridge.Functions.GetPlayerId(source)
    return vRP.giveInventoryItem(user_id, item, amount, true)
end

function Bridge.Functions.GetInventory(source)
    local user_id = Bridge.Functions.GetPlayerId(source)
    return vRP.getInventory(user_id)
end

function Bridge.Functions.GetInventoryWeight(source)
    local user_id = Bridge.Functions.GetPlayerId(source)
    return vRP.getInventoryWeight(user_id)
end

function Bridge.Functions.GetInventoryMaxWeight(source)
    local user_id = Bridge.Functions.GetPlayerId(source)
    return vRP.getInventoryMaxWeight(user_id)
end

function Bridge.Functions.GetItemWeight(item)
    return vRP.getItemWeight(item)
end

function Bridge.Functions.GetItemName(item)
    return (vRP.itemNameList and vRP.itemNameList(item)) or item
end

function Bridge.Functions.GetItemIndex(item)
    return (vRP.itemIndexList and vRP.itemIndexList(item)) or item
end

function Bridge.Functions.RemoveMoney(source, amount)
    local user_id = Bridge.Functions.GetPlayerId(source)
    return vRP.tryFullPayment(user_id, amount) or vRP.tryPayment(user_id, amount)
end

function Bridge.Functions.GiveMoney(source, amount)
    local user_id = Bridge.Functions.GetPlayerId(source)
    return vRP.giveMoney(user_id, amount)
end

function Bridge.Functions.Revive(source, health)
    vRPClient.killGod(source)
    vRPClient.setHealth(source, health or 400)
end

function Bridge.Functions.SetHealth(source, health)
    vRPClient.setHealth(source, health or 400)
end

function Bridge.Functions.Prompt(source, message, placeholder)
    local text = Bridge.Callback.AwaitClient(source, "BjornBridge:prompt", nil, message, placeholder or "")
    if type(text) == "string" then
        text = text:gsub("^%s*(.-)%s*$", "%1")
        if text == "" then return nil end
        return text
    end
    return nil
end

function Bridge.Functions.Request(source, message, timeoutSeconds)
    local timeoutMs = ((timeoutSeconds or 30) * 1000)
    local accepted = Bridge.Callback.AwaitClient(source, "BjornBridge:request", timeoutMs, message, timeoutMs)
    return accepted == true
end

function Bridge.Functions.Prepare(action, data)
    return Bridge.DB.Prepare(action, data)
end

function Bridge.Functions.Query(action, data)
    return Bridge.DB.Query(action, data)
end

function Bridge.Functions.Execute(action, data)
    return Bridge.DB.Execute(action, data)
end
