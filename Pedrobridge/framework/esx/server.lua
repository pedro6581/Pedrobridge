---@diagnostic disable: duplicate-set-field

if not string.find(Bridge.Framework, "esx") then return end


local ESX = exports["es_extended"] and exports["es_extended"].getSharedObject()

if not ESX then
    TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
end

local notifyColors = {
    sucesso = "success",
    aviso = "inform",
    negado = "error"
}

function Bridge.Functions.Notify(type, message, source)
    local notifyType = notifyColors[type]
    if source then
        if notifyType then
            TriggerClientEvent("esx:showAdvancedNotification", source, "BjornBridge", "", message, notifyType, 1)
        else
            TriggerClientEvent("esx:showNotification", source, message)
        end
    else
        print(string.format("[BjornBridge][ESX] %s", message))
    end
end

function GetPlayer(source)
    return ESX.GetPlayerFromId(source)
end

function Bridge.Functions.GetPlayerId(source)
    local xPlayer = GetPlayer(source)
	return xPlayer and xPlayer.identifier or nil
end

function Bridge.Functions.GetSource(user_id)
    return user_id
end

function Bridge.Functions.GetUsers()
    return ESX and ESX.GetPlayers() or {}
end

function Bridge.Functions.GetIdentity(source)
    local xPlayer = GetPlayer(source)
    if xPlayer then
        return (xPlayer.getName and xPlayer.getName()) or xPlayer.get("firstName") or xPlayer.get("name") or "Unknown"
    end
end

function Bridge.Functions.CheckPermission(source, permission)
    local xPlayer = GetPlayer(source)
    return xPlayer and xPlayer.getGroup and xPlayer.getGroup() == permission
end

function Bridge.Functions.CheckItem(source, item)
    local xPlayer = GetPlayer(source)
    local inventoryItem = xPlayer and xPlayer.getInventoryItem(item)
    return inventoryItem and inventoryItem.count or 0
end

function Bridge.Functions.RemoveItem(source, item, amount, metadata)
    local xPlayer = GetPlayer(source)

    if Bridge.Config.Inventory == "default" then

		return xPlayer.removeInventoryItem(item,amount)

    elseif Bridge.Config.Inventory == "ox_inventory" then

		if exports["ox_inventory"]:CanCarryItem(source, item, amount) then
			return exports["ox_inventory"]:RemoveItem(source, item, amount)
		end

	end
end

function Bridge.Functions.GiveItem(source, item, amount, metadata)
    local xPlayer = GetPlayer(source)

    if Bridge.Config.Inventory == "default" then

		return xPlayer.addInventoryItem(item, amount)

    elseif Bridge.Config.Inventory == "ox_inventory" then

		if exports["ox_inventory"]:CanCarryItem(source, item, amount) then
			return exports["ox_inventory"]:AddItem(source, item, amount, metadata)
		end

	end
end

function Bridge.Functions.GetInventory(source)
    if Bridge.Config.Inventory == "default" then
        local xPlayer = GetPlayer(source)
        local playerInv = xPlayer and xPlayer.getInventory() or {}
        local formattedInv = {}

        for _, itemData in pairs(playerInv) do
            local itemName = itemData.name
            local itemLabel = itemData.label
            local itemAmount = itemData.count or itemData.amount or 0

            formattedInv[#formattedInv + 1] = {
                name = itemName,
                label = itemLabel or Bridge.Functions.GetItemName(itemName),
                amount = itemAmount
            }
        end

        return formattedInv

    elseif Bridge.Config.Inventory == "ox_inventory" then
        local items = exports["ox_inventory"]:GetInventoryItems(source) or {}
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
end


function Bridge.Functions.GetInventoryWeight(source)
    local xPlayer = GetPlayer(source)
    if xPlayer then
        if xPlayer.getWeight then
            return xPlayer.getWeight()
        end
        if xPlayer.weight then
            return xPlayer.weight
        end
    end
end

function Bridge.Functions.GetInventoryMaxWeight(source)
    local xPlayer = GetPlayer(source)
    if xPlayer then
        if xPlayer.getMaxWeight then
            return xPlayer.getMaxWeight()
        end
        if xPlayer.maxWeight then
            return xPlayer.maxWeight
        end
    end
end

function Bridge.Functions.GetItemWeight(item)
    if ESX and ESX.Items and ESX.Items[item] then
        return ESX.Items[item].weight
    end
end

function Bridge.Functions.GetItemName(item)
    if ESX and ESX.Items and ESX.Items[item] then
        return ESX.Items[item].label or item
    end
    return item
end

function Bridge.Functions.GetItemIndex(item)
    return item
end

function Bridge.Functions.RemoveMoney(source, amount)
    local xPlayer = GetPlayer(source)
    if xPlayer then
        if xPlayer.removeMoney then
            return xPlayer.removeMoney(amount)
        end
        return xPlayer.removeAccountMoney("money", amount)
    end
end

function Bridge.Functions.GiveMoney(source, amount)
    local xPlayer = GetPlayer(source)
    if xPlayer then
        if xPlayer.addMoney then
            return xPlayer.addMoney(amount)
        end
        return xPlayer.addAccountMoney("money", amount)
    end
end

function Bridge.Functions.Revive(source, health)
    TriggerClientEvent("esx_ambulancejob:revive", source)
    Bridge.Functions.SetHealth(source, health)
end

function Bridge.Functions.SetHealth(source, health)
    TriggerClientEvent("BjornBridge:client:setHealth", source, health or 200)
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


GetPlayer = Bridge.Functions.GetPlayer(source)