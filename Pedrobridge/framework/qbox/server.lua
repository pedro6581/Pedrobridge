---@diagnostic disable: duplicate-set-field

if not string.find(Bridge.Framework, "qbox") then return end


local _itemsCache

local notifyColors = {
    sucesso = "success",
    aviso = "warning",
    negado = "error"
}

function Bridge.Functions.Notify(type, message, source)
    local notifyType = notifyColors[type]
    exports["qbx_core"]:Notify(source, message, notifyType, 5000)
end

function GetPlayer(source)
    return exports["qbx_core"]:GetPlayer(source)
end

function Bridge.Functions.GetPlayerId(source)
    local xPlayer = GetPlayer(source)
	return xPlayer and xPlayer.PlayerData.citizenid or nil
end

function Bridge.Functions.GetSource(user_id)
    return exports["qbx_core"]:GetSource(user_id)
end

function Bridge.Functions.GetUsers()
    return exports["qbx_core"]:GetPlayersData()
end

function Bridge.Functions.GetIdentity(source)
    local xPlayer = GetPlayer(source)
    if xPlayer then
        local info = xPlayer.PlayerData.charinfo or {}
        return string.format("%s %s", info.firstname or "", info.lastname or ""):gsub("^%s*(.-)%s*$", "%1")
    end
end

function Bridge.Functions.CheckPermission(source, permission)

    if IsPlayerAceAllowed(source, permission) then
        return true
    end

    if exports["qbx_core"]:HasGroup(source, permission) then
        return true
    end

    local xPlayer = GetPlayer(source)

    if xPlayer.PlayerData.job and xPlayer.PlayerData.job.name == permission then
        return true
    end

    -- Deprecated.
    local ok, hasPerm = pcall(function()
        return exports["qbx_core"]:HasPermission(source, permission)
    end)

    if ok and hasPerm then
        return true
    end
end

function Bridge.Functions.CheckItem(source, item, metadata, strict)
    return exports["ox_inventory"]:GetItemCount(source, item, metadata, strict)
end

function Bridge.Functions.RemoveItem(source, item, amount, metadata)
    return exports["ox_inventory"]:RemoveItem(source, item, amount, metadata)
end

function Bridge.Functions.GiveItem(source, item, amount, metadata)
    if Bridge.Config.Inventory == "default" or Bridge.Config.Inventory == "ox_inventory" then
		if exports["ox_inventory"]:CanCarryItem(source, item, amount) then
			return exports["ox_inventory"]:AddItem(source, item, amount, metadata)
		end
	end
end

function Bridge.Functions.GetInventory(source)
    if Bridge.Config.Inventory == "default" or Bridge.Config.Inventory == "ox_inventory" then
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
    local inv = exports["ox_inventory"]:GetInventory(source)
    return inv and inv.weight or 0
end

function Bridge.Functions.GetInventoryMaxWeight(source)
    local inv = exports["ox_inventory"]:GetInventory(source)
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
    return exports["qbx_core"]:RemoveMoney(source, "cash", amount)
end

function Bridge.Functions.GiveMoney(source, amount)
    return exports["qbx_core"]:AddMoney(source, "cash", amount)
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

function GetOxItems()
    if not _itemsCache then
        _itemsCache = exports["ox_inventory"]:Items() or {}
    end
    return _itemsCache
end