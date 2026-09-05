Bridge.Callback = Bridge.Callback or {}

local handlers = {}
local pending = {}

local function generateRequestId()
    local requestId
    repeat
        requestId = string.format("c:%s:%d", GetGameTimer(), math.random(100000, 999999))
    until not pending[requestId]
    return requestId
end

function Bridge.Callback.RegisterClient(name, fn)
    handlers[name] = fn
end

RegisterNetEvent("BjornBridge:callbackClient", function(requestId, name, ...)
    local handler = handlers[name]
    if handler then
        handler(requestId, ...)
    else
        TriggerServerEvent("BjornBridge:callbackClientResult", requestId, nil)
    end
end)

function Bridge.Callback.AwaitServer(name, timeoutMs, ...)
    local requestId = generateRequestId()
    local p = promise.new()
    pending[requestId] = p

    TriggerServerEvent("BjornBridge:callbackServer", requestId, name, ...)

    if timeoutMs and timeoutMs > 0 then
        SetTimeout(timeoutMs, function()
            if pending[requestId] then
                pending[requestId] = nil
                p:resolve(nil)
            end
        end)
    end

    return Citizen.Await(p)
end

RegisterNetEvent("BjornBridge:callbackServerResult", function(requestId, ...)
    local p = pending[requestId]
    if p then
        pending[requestId] = nil
        p:resolve(...)
    end
end)

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    for requestId, p in pairs(pending) do
        pending[requestId] = nil
        p:resolve(nil)
    end
end)
