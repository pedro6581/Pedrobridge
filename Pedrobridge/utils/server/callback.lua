Bridge.Callback = Bridge.Callback or {}

local pending = {}
local serverHandlers = {}

local function generateRequestId(src)
    local requestId
    repeat
        requestId = string.format("%s:%s:%d", src or 0, GetGameTimer(), math.random(100000, 999999))
    until not pending[requestId]
    return requestId
end

function Bridge.Callback.RegisterServer(name, fn)
    serverHandlers[name] = fn
end

RegisterNetEvent("BjornBridge:callbackServer", function(requestId, name, ...)
    local src = source
    local handler = serverHandlers[name]

    if not handler then
        TriggerClientEvent("BjornBridge:callbackServerResult", src, requestId, nil)
        return
    end

    local responded = false
    local function reply(...)
        if responded then return end
        responded = true
        TriggerClientEvent("BjornBridge:callbackServerResult", src, requestId, ...)
    end

    local ok, a, b, c, d, e = pcall(handler, src, reply, ...)
    if not ok then
        reply(nil)
        return
    end

    if not responded then
        if a ~= nil or b ~= nil or c ~= nil or d ~= nil or e ~= nil then
            reply(a, b, c, d, e)
        else
            reply(nil)
        end
    end
end)

function Bridge.Callback.AwaitClient(source, name, timeoutMs, ...)
    local requestId = generateRequestId(source)
    local p = promise.new()

    pending[requestId] = { promise = p, source = source }

    TriggerClientEvent("BjornBridge:callbackClient", source, requestId, name, ...)

    if timeoutMs and timeoutMs > 0 then
        SetTimeout(timeoutMs, function()
            local entry = pending[requestId]
            if entry then
                pending[requestId] = nil
                entry.promise:resolve(nil)
            end
        end)
    end

    return Citizen.Await(p)
end

RegisterNetEvent("BjornBridge:callbackClientResult", function(requestId, ...)
    local entry = pending[requestId]
    if entry then
        pending[requestId] = nil
        entry.promise:resolve(...)
    end
end)

AddEventHandler("playerDropped", function()
    local src = source
    for requestId, entry in pairs(pending) do
        if entry.source == src then
            pending[requestId] = nil
            entry.promise:resolve(nil)
        end
    end
end)

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    for requestId, entry in pairs(pending) do
        pending[requestId] = nil
        entry.promise:resolve(nil)
    end
end)

