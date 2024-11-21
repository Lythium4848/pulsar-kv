PulsarKV = PulsarKV or {}

hook.Add("PulsarKV.DBConnected", "PulsarKV.CreateTable", function()
    PulsarKV.SQL.Query([[
        CREATE TABLE IF NOT EXISTS pulsarkv (
            `key` VARCHAR(100) PRIMARY KEY,
            `value` TEXT NOT NULL,
            `state` INT DEFAULT 0,
            `type` INT DEFAULT 0
        )
    ]], print, function()
        PulsarKV.Log("Failed to create pulsarkv table")
    end)
end)


--- Inserts or updates a key-value pair in the database
--- @param key string The key to insert
--- @param value string The value to insert
--- @param state PulsarKVState The state of the key-value pair
--- @param type PulsarKVType The type of the value
--- @param onSuccess? function The function to call when the query is successful
--- @param onError? function The function to call when the query fails
function PulsarKV.Insert(key, value, state, type, onSuccess, onError)
    key = PulsarKV.SQL.Escape(key)
    value = PulsarKV.SQL.Escape(value)

    PulsarKV.SQL.Query(string.format("REPLACE INTO pulsarkv (`key`, `value`, `state`, `type`) VALUES (%s, %s, %s, %s)", key, value, state, type), onSuccess, onError)
end

--- Fetches a value from the database
--- @param key string The key to fetch
--- @param from PulsarKVFrom Where is the query being called from (server or client)
--- @param onSuccess function The function to call when the query is successful
--- @param onError? function The function to call when the query fails
function PulsarKV.Fetch(key, from, onSuccess, onError)
    key = PulsarKV.SQL.Escape(key)

    local state1, state2
    if from == PulsarKV.From.SERVER then
        state1, state2 = PulsarKV.State.SERVER, PulsarKV.State.SHARED
    else
        state1, state2 = PulsarKV.State.CLIENT, PulsarKV.State.SHARED
    end

    PulsarKV.SQL.Query(string.format("SELECT `value`, `type` FROM pulsarkv WHERE `key` = %s AND `state` IN (%i, %i)", key, state1, state2), function(data)
        if data and data[1] then
            local value = data[1].value
            local type = data[1].type

            local convertedValue = PulsarKV.ConvertType(value, type)
            onSuccess(convertedValue)
        else
            onSuccess(nil)
        end
    end, onError)
end

--- Deletes a key-value pair from the database
--- @param key string The key to delete
--- @param onSuccess? function The function to call when the query is successful
--- @param onError? function The function to call when the query fails
function PulsarKV.Delete(key, onSuccess, onError)
    key = PulsarKV.SQL.Escape(key)

    PulsarKV.SQL.Query(string.format("DELETE FROM pulsarkv WHERE `key` = %s", key), onSuccess, onError)
end

--- Fetches all key-value pairs from the database
--- @param from PulsarKVFrom Where is the query being called from (server or client)
--- @param onSuccess function The function to call when the query is successful
--- @param onError? function The function to call when the query fails
function PulsarKV.FetchAll(from, onSuccess, onError)
    local state1, state2
    if from == PulsarKV.From.SERVER then
        state1, state2 = PulsarKV.State.SERVER, PulsarKV.State.SHARED
    else
        state1, state2 = PulsarKV.State.CLIENT, PulsarKV.State.SHARED
    end

    PulsarKV.SQL.Query(string.format("SELECT `key`, `value`, `type` FROM pulsarkv WHERE `state` IN (%i, %i)", state1, state2), function(data)
        if data then
            local convertedData = {}

            for k, v in pairs(data) do
                convertedData[v.key] = {
                    key = v.key,
                    value = PulsarKV.ConvertType(v.value, v.type),
                    type = v.type
                }
            end

            onSuccess(convertedData)
        else
            if onError then
                onError("No data found")
            end
        end
    end, onError)
end
