PulsarKV = PulsarKV or {}
PulsarKV.SQL = PulsarKV.SQL or {}

PulsarKV.MySQL = {-- If you have PulsarLib installed, and you have MySQL configured, you can ignore this. PulsarLib's MySQL configuration will be used.
    UsingMySQL = true,
    Host = "localhost",
    Port = 3306,
    Username = "root",
    Password = "",
    Database = ""
}

-- Do not touch anything below this line unless you know what you're doing.


if PulsarKV.UsingPulsarLib then
    PulsarKV.MySQL = PulsarLib.SQL:FetchDetails()
end

local db

if util.IsBinaryModuleInstalled("mysqloo") then
    require("mysqloo")
end

if !PulsarKV.UsingPulsarLib then
    PulsarKV.Log("Waiting for first think to connect to database...")
    hook.Add("Think", "PulsarKV.ConnectToDB", function()
        hook.Remove("Think", "PulsarKV.ConnectToDB")
        PulsarKV.Log("Connecting to database...")
        db = mysqloo.connect(PulsarKV.MySQL.Host, PulsarKV.MySQL.Username, PulsarKV.MySQL.Password, PulsarKV.MySQL.Database, PulsarKV.MySQL.Port)

        db.onConnected = function()
            hook.Run("PulsarKV.DBConnected")
        end

        db.onConnectionFailed = function(_, err)
            PulsarKV.Log("Failed to connect to database: " .. err)
        end

        db:connect()
    end)
else
    if PulsarLib.SQL.Connected then
        PulsarKV.Log("Connecting to database...")
        hook.Run("PulsarKV.DBConnected")
    else
        PulsarKV.Log("Waiting for PulsarLib to connect to database...")
        hook.Add("PulsarLib.SQL.Connected", "PulsarKV.ConnectToDB", function()
            hook.Remove("PulsarLib.SQL.Connected", "PulsarKV.ConnectToDB")
            PulsarKV.Log("Connecting to database...")
            hook.Run("PulsarKV.DBConnected")
        end)
    end
end

--- Executes a raw SQL query
--- @param query string The query to execute
--- @param onSuccess? function The function to call when the query is successful
--- @param onError? function The function to call when the query fails
function PulsarKV.SQL.Query(query, onSuccess, onError)
    if PulsarKV.UsingPulsarLib then
        PulsarLib.SQL:RawQuery(query, onSuccess, onError)
        return
    end

    if db and PulsarKV.MySQL.UsingMySQL then
        local queryObj = db:query(query)

        queryObj.onSuccess = function(_, data)
            if onSuccess then
                onSuccess(data)
            end
        end

        queryObj.onError = function(_, err)
            if onError then
                onError(err)
            end
        end

        queryObj:start()
    else
        local queryReturn = sql.Query(query)

        if queryReturn == false then
            if onError then
                onError(sql.LastError())
            end
        else
            if onSuccess then
                onSuccess(queryReturn)
            end
        end
    end
end

--- Escapes a string for use in a SQL query
--- @param str string The string to escape
function PulsarKV.SQL.Escape(str)
    if PulsarKV.UsingPulsarLib then
        return PulsarLib.SQL:Escape(str)
    end

    if db and PulsarKV.MySQL.UsingMySQL then
        return db:escape(str)
    else
        return sql.SQLStr(str)
    end
end