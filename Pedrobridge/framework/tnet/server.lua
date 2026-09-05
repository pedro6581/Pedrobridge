---@diagnostic disable: duplicate-set-field

if not string.find(Bridge.Framework, "tnet") then return end


local tNet = exports.tnet_core:getSharedObject()
local _itemsCache

local notifyColors = {
    sucesso = "success",
    aviso = "warning",
    negado = "error"
}

function Bridge.Functions.Notify(type, message, source)
    local color = notifyColors[type]
    TriggerEvent('Notify', source, color, message, 10)
end

function Bridge.Functions.GetPlayerId(source)
    return tNet.GetCharacterIdByPlayerSrc(source)
end

function Bridge.Functions.GetSource(user_id)
    return tNet.GetPlayerSrcByCharacterId(user_id)
end

function Bridge.Functions.GetUsers()
    return tNet.GetUsers()
end

function Bridge.Functions.GetIdentity(source)
    local character = tNet.GetCharacterByPlayerSrc(source)
    if character then
        return (character.name or "") .. " " .. (character.lastName or "")
    end
end

function Bridge.Functions.CheckPermission(source, permission)
    local character = tNet.GetCharacterByPlayerSrc(source)
    if character then
        return character.getRoleIdByGroupName(permission)
    end
end

function Bridge.Functions.CheckItem(source, item)
    local amount = exports.tnet_inventory:Search(source,'count', item)
    return type(amount) == "table" and amount[1] or amount
end

function Bridge.Functions.RemoveItem(source, item, amount, metadata)
    return exports.tnet_inventory:RemoveItem(source, item, amount, metadata)
end

function Bridge.Functions.GiveItem(source, item, amount, metadata)
    return exports.tnet_inventory:AddItem(source, item, amount, metadata)
end

function Bridge.Functions.GetInventory(source)
    local items = exports.tnet_inventory:GetInventoryItems(source) or {}
    local formattedInv = {}

    for _, itemData in pairs(items) do
        if itemData and itemData.name then
            local itemName = itemData.name
            local itemAmount = itemData.count or itemData.amount or 0

            formattedInv[#formattedInv + 1] = {
                name = itemName,
                label = itemData.label or Bridge.Functions.GetItemName(itemName),
                amount = itemAmount,
                slot = itemData.slot,
                metadata = itemData.metadata
            }
        end
    end

    return formattedInv
end

function Bridge.Functions.GetInventoryWeight(source)
    local inv = exports.tnet_inventory:GetInventory(source)
    return inv and inv.weight or 0
end

function Bridge.Functions.GetInventoryMaxWeight(source)
    local inv = exports.tnet_inventory:GetInventory(source)
    return inv and inv.maxWeight or 0
end

function Bridge.Functions.GetItemWeight(item)
    local name = (type(item) == 'table' and (item.name or item.item)) or item
    if not name then return 0 end

    local items = GetOxItems()
    local data = items[name]
    return (data and data.weight) or 0
end

function Bridge.Functions.GetItemName(item)
    local name = (type(item) == 'table' and (item.name or item.item)) or item
    if not name then return item end

    local items = GetOxItems()
    local data = items[name]
    return (data and (data.label or data.name)) or name
end

function Bridge.Functions.GetItemIndex(item)
    return item
end

function Bridge.Functions.RemoveMoney(source, amount)
    local character = tNet.GetCharacterByPlayerSrc(source)
    if character then
        return character.tryFullPayment(amount)
    end
end

function Bridge.Functions.GiveMoney(source, amount)
    local character = tNet.GetCharacterByPlayerSrc(source)
    if character then
        return character.addBankMoney(amount, 'cash')
    end
end

function Bridge.Functions.Revive(source)
   TriggerClientEvent('net.reviveCharacter', source)
end

function Bridge.Functions.SetHealth(source, health)
    TriggerClientEvent('net.setEntityHealth', source, health)
end

function Bridge.Functions.Prompt(source, message, placeholder)
    return tNet.Prompt(source, message, placeholder, false)
end

function Bridge.Functions.Request(source, message, timeoutSeconds)
    return tNet.Request(source, message, timeoutSeconds)
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

function GetOxItems()
    if not _itemsCache then
        _itemsCache = exports.tnet_inventory:Items() or {}
    end
    return _itemsCache
end