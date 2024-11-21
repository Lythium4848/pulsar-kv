PulsarKV = PulsarKV or {}
PulsarKV.SQL = PulsarKV.SQL or {}

--- Executes a raw SQL query
--- @param query string The query to execute
--- @param onSuccess? function The function to call when the query is successful
--- @param onError? function The function to call when the query fails
function PulsarKV.SQL.Query(query, onSuccess, onError)
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

--- Escapes a string for use in a SQL query
--- @param str string The string to escape
function PulsarKV.SQL.Escape(str)
    return sql.SQLStr(str)
end