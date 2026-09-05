---@diagnostic disable: duplicate-set-field

if not string.find(Bridge.Framework, "creativev5") then return end

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
    print(string.format("\n\n^6[BjornBridge]^0 -^2 %s ^0", Lang["vrpLibNotLoaded"]))
    return
end


local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local vRP = Proxy.getInterface("vRP")
local vRPClient = Tunnel.getInterface("vRP")

module("vrp", "lib/itemlist")

local notifyColors = {
    sucesso = "verde",
    aviso = "amarelo",
    negado = "vermelho"
}

function Bridge.Functions.Notify(type, message, source)
    local color = notifyColors[type]
    TriggerClientEvent("Notify", source, color, message, 5000)
end

function Bridge.Functions.GetPlayerId(source)
    return vRP.getUserId(source)
end

function Bridge.Functions.GetSource(user_id)
    if vRP.userSource then
        return vRP.userSource(user_id)
    end
    if vRP.getUserSource then
        return vRP.getUserSource(user_id)
    end
    if vRP.Source then
        return vRP.Source(user_id)
    end
end

function Bridge.Functions.GetUsers()
    return vRP.userList()
end

function Bridge.Functions.GetIdentity(source)
    local user_id = Bridge.Functions.GetPlayerId(source)
    local identity = vRP.userIdentity(user_id)
    return identity and identity.name or "Unknown"
end

function Bridge.Functions.CheckPermission(source, permission)
    local user_id = Bridge.Functions.GetPlayerId(source)
    return vRP.hasPermission(user_id, permission)
end

function Bridge.Functions.CheckItem(source, item)
    local user_id = Bridge.Functions.GetPlayerId(source)
    local amount = vRP.itemAmount(user_id, item)
    return type(amount) == "table" and amount[1] or amount
end

function Bridge.Functions.RemoveItem(source, item, amount)
    local userId = Bridge.Functions.GetPlayerId(source)
    local hasTimestampSuffix = item:match("^.+%-%d+$") ~= nil
    local itemToRemove = item

    if not hasTimestampSuffix then
        local itemData = vRP.getInventoryItemAmount(userId, item)
        itemToRemove = (itemData and itemData[2]) or item
    end

    return vRP.tryGetInventoryItem(userId, itemToRemove, amount)
end

function Bridge.Functions.GiveItem(source, item, amount)
    local user_id = Bridge.Functions.GetPlayerId(source)
    return vRP.giveInventoryItem(user_id, item, amount, true)
end

function Bridge.Functions.GetInventory(source)
    local user_id = Bridge.Functions.GetPlayerId(source)
    return vRP.userInventory(user_id)
end

function Bridge.Functions.GetInventoryWeight(source)
    local user_id = Bridge.Functions.GetPlayerId(source)
    return vRP.inventoryWeight(user_id)
end

function Bridge.Functions.GetInventoryMaxWeight(source)
    local user_id = Bridge.Functions.GetPlayerId(source)
    return vRP.getWeight(user_id)
end

function Bridge.Functions.GetItemWeight(item)
    return itemWeight(item)
end

function Bridge.Functions.GetItemName(item)
    return itemName(item)
end

function Bridge.Functions.GetItemIndex(item)
    return itemIndex(item)
end

function Bridge.Functions.RemoveMoney(source, amount)
    local user_id = Bridge.Functions.GetPlayerId(source)
    return vRP.paymentFull(user_id, amount)
end

function Bridge.Functions.GiveMoney(source, amount)
    local user_id = Bridge.Functions.GetPlayerId(source)
    return vRP.giveInventoryItem(user_id, "dollars", amount, true)
end

function Bridge.Functions.Revive(source, health)
    vRPClient.revivePlayer(source, health or 400)
end

function Bridge.Functions.SetHealth(source, health)
    vRPClient.revivePlayer(source, health or 400)
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
