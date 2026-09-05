Bridge.DB = Bridge.DB or { prepared = {} }

local function resolveSql(actionOrSql)
    return Bridge.DB.prepared[actionOrSql] or actionOrSql
end

function Bridge.DB.Prepare(action, sql)
    Bridge.DB.prepared[action] = sql
    return true
end

function Bridge.DB.Query(actionOrSql, params)
    local sql = resolveSql(actionOrSql)
    if type(MySQL) == "table" and MySQL.query and MySQL.query.await then
        return MySQL.query.await(sql, params)
    elseif MySQL and MySQL.Async and MySQL.Async.fetchAll then
        local p = promise.new()
        MySQL.Async.fetchAll(sql, params or {}, function(result)
            p:resolve(result)
        end)
        return Citizen.Await(p)
    else
        print(("^3[Pedrobridge]^0 %s^0"):format(Lang["missingSqlDriver"]))
        return nil
    end
end

function Bridge.DB.Execute(actionOrSql, params)
    local sql = resolveSql(actionOrSql)
    local command = string.lower((string.match(sql or "", "^%s*(%w+)") or ""))

    if type(MySQL) == "table" and MySQL.query and MySQL.query.await then
        if command == "insert" and MySQL.insert and MySQL.insert.await then
            return MySQL.insert.await(sql, params)
        end

        if command == "update" or command == "delete" then
            if MySQL.update and MySQL.update.await then
                return MySQL.update.await(sql, params)
            end
        end

        if MySQL.update and MySQL.update.await then
            return MySQL.update.await(sql, params)
        end

        return MySQL.query.await(sql, params)
    elseif MySQL and MySQL.Async and MySQL.Async.execute then
        local p = promise.new()
        MySQL.Async.execute(sql, params or {}, function(affected)
            p:resolve(affected)
        end)
        return Citizen.Await(p)
    else
        print(("^3[Pedrobridge]^0 %s^0"):format(Lang["missingSqlDriver"]))
        return nil
    end
end
