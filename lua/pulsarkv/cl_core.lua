PulsarKV = PulsarKV or {}

--- Inserts or updates a key-value pair in the database
--- @param key string The key to insert
--- @param value string The value to insert
--- @param state PulsarKVState The state of the key-value pair
--- @param type PulsarKVType The type of the value
--- @param onSuccess? function The function to call when the query is successful
--- @param onError? function The function to call when the query fails
function PulsarKV.Insert(key, value, state, type, onSuccess, onError)
    if state == PulsarKV.State.LOCAL then
        key = PulsarKV.SQL.Escape(key)
        value = PulsarKV.SQL.Escape(value)

        PulsarKV.SQL.Query(
        string.format("REPLACE INTO pulsarkv (`key`, `value`, `state`, `type`) VALUES (%s, %s, %s, %s)", key, value,
            state, type), onSuccess, onError)

        return
    end

    value = util.TypeToString(value)

    net.Start("PulsarKV.Insert")
    net.WriteString(key)
    net.WriteString(value)
    net.WriteUInt(state, 3)
    net.WriteUInt(type, 4)
    net.SendToServer()
end

--- Fetches a value from the database
--- @param key string The key to fetch
--- @param from PulsarKVFrom Where is the query being called from (server or client)
--- @param onSuccess function The function to call when the query is successful
--- @param onError? function The function to call when the query fails
function PulsarKV.Fetch(key, from, onSuccess, onError)
    if from == PulsarKV.From.LOCAL then
        key = PulsarKV.SQL.Escape(key)

        PulsarKV.SQL.Query(string.format("SELECT `value`, `type` FROM pulsarkv WHERE `key` = %s", key), function(data)
            if data and data[1] then
                local value = data[1].value
                local type = data[1].type

                local convertedValue = PulsarKV.ConvertType(value, type)
                onSuccess(convertedValue)
            else
                onSuccess(nil)
            end
        end, onError)

        return
    end

    net.Start("PulsarKV.Fetch")
    net.WriteString(key)
    net.SendToServer()
end

--- Deletes a key-value pair from the database
--- @param key string The key to delete
--- @param state PulsarKVState The state of the key-value pair
--- @param onSuccess? function The function to call when the query is successful
--- @param onError? function The function to call when the query fails
function PulsarKV.Delete(key, state, onSuccess, onError)
    if state == PulsarKV.State.LOCAL then
        key = PulsarKV.SQL.Escape(key)

        PulsarKV.SQL.Query(string.format("DELETE FROM pulsarkv WHERE `key` = %s", key), onSuccess, onError)

        return
    end

    net.Start("PulsarKV.Delete")
    net.WriteString(key)
    net.WriteUInt(state, 3)
    net.SendToServer()
end

--- Fetches all key-value pairs from the database
--- @param from? PulsarKVFrom Where is the query being called from (server or client)
--- @param onSuccess function The function to call when the query is successful
--- @param onError? function The function to call when the query fails
function PulsarKV.FetchAll(from, onSuccess, onError)
    if from == PulsarKV.From.LOCAL then
        PulsarKV.SQL.Query(string.format("SELECT `key`, `value`, `type` FROM pulsarkv"), function(data)
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

        return
    end

    net.Start("PulsarKV.FetchAll")
    net.SendToServer()
end
