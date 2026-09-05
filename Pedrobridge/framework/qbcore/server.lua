---@diagnostic disable: duplicate-set-field

if not string.find(Bridge.Framework, "qbcore") then return end


local QBCore = exports["qb-core"]:GetCoreObject()

local notifyColors = {
    sucesso = "success",
    aviso = "primary",
    negado = "error"
}

function Bridge.Functions.Notify(type, message, source)
    local notifyType = notifyColors[type]
    QBCore.Functions.Notify(source, message, notifyType, 5000)
end

function GetPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

function Bridge.Functions.GetPlayerId(source)
    local xPlayer = GetPlayer(source)
	return xPlayer and xPlayer.PlayerData.citizenid or nil
end

function Bridge.Functions.GetSource(citizenId)
    local xPlayer = QBCore.Functions.GetPlayerByCitizenId(citizenId)
    return xPlayer and xPlayer.PlayerData.source or nil
end

function Bridge.Functions.GetUsers()
    return QBCore.Functions.GetPlayers()
end

function Bridge.Functions.GetIdentity(source)
    local xPlayer = GetPlayer(source)
    if xPlayer then
        local info = xPlayer.PlayerData.charinfo or {}
        return string.format("%s %s", info.firstname or "", info.lastname or ""):gsub("^%s*(.-)%s*$", "%1")
    end
end

function Bridge.Functions.CheckPermission(source, permission)
    if QBCore.Functions.HasPermission(source, permission) then
        return true
    else
        local xPlayer = GetPlayer(source)
        return xPlayer and xPlayer.PlayerData.job and xPlayer.PlayerData.job.name == permission
    end
end

function Bridge.Functions.CheckItem(source, item)
    local xPlayer = GetPlayer(source)
    local invItem = xPlayer and xPlayer.Functions.GetItemByName(item)
    return invItem and invItem.amount or 0
end

function Bridge.Functions.RemoveItem(source, item, amount)
    local xPlayer = GetPlayer(source)
    if xPlayer then
        return xPlayer.Functions.RemoveItem(item, amount)
    end
end

function Bridge.Functions.GiveItem(source, item, amount, metadata)
    local xPlayer = GetPlayer(source)

    if Bridge.Config.Inventory == "default" then

		return xPlayer.Functions.AddItem(item, amount, nil, metadata)

    elseif Bridge.Config.Inventory == "ox_inventory" then

		if exports["ox_inventory"]:CanCarryItem(source, item, amount) then
			return exports["ox_inventory"]:AddItem(source, item, amount, metadata)
		end

	end
end

function Bridge.Functions.GetInventory(source)
    if Bridge.Config.Inventory == "default" then
        local xPlayer = GetPlayer(source)
        local playerInv = xPlayer and xPlayer.PlayerData and xPlayer.PlayerData.items or {}
        local formattedInv = {}

        for slot, itemData in pairs(playerInv) do
            if itemData and itemData.name then
                local itemName = itemData.name
                local itemLabel = itemData.label
                local itemAmount = itemData.amount or itemData.count or 0

                formattedInv[#formattedInv + 1] = {
                    name = itemName,
                    label = itemLabel or itemName,
                    amount = itemAmount,
                    slot = itemData.slot or slot,
                    info = itemData.info
                }
            end
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

                    -- campos essenciais p/ durabilidade correta
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
    return xPlayer and xPlayer.PlayerData.weight or nil
end

function Bridge.Functions.GetInventoryMaxWeight(source)
    local xPlayer = GetPlayer(source)
    return xPlayer and xPlayer.PlayerData.maxweight or nil
end

function Bridge.Functions.GetItemWeight(item)
    if QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[item] then
        return QBCore.Shared.Items[item].weight
    end
end

function Bridge.Functions.GetItemName(item)
    if QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[item] then
        return QBCore.Shared.Items[item].label or item
    end
    return item
end

function Bridge.Functions.GetItemIndex(item)
    return item
end

function Bridge.Functions.RemoveMoney(source, amount)
    local xPlayer = GetPlayer(source)
    return xPlayer and xPlayer.Functions.RemoveMoney("cash", amount) or false
end

function Bridge.Functions.GiveMoney(source, amount)
    local xPlayer = GetPlayer(source)
    return xPlayer and xPlayer.Functions.AddMoney("cash", amount) or false
end

function Bridge.Functions.Revive(source, health)
    TriggerClientEvent("hospital:client:Revive", source)
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