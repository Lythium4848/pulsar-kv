PulsarKV = PulsarKV or {}

net.Receive("PulsarKV.Insert", function()
    local success = net.ReadBool()

    if not success then
        local err = net.ReadString()
        PulsarKV.Log("Error inserting key-value pair: " .. err)
        return
    end

    PulsarKV.Log("Successfully inserted key-value pair")
end)

net.Receive("PulsarKV.Fetch", function()
    local success = net.ReadBool()

    if not success then
        local err = net.ReadString()
        PulsarKV.Log("Error fetching key-value pair: " .. err)
        return
    end

    local value = net.ReadString()
    local type2 = net.ReadUInt(4)
    value = PulsarKV.ConvertType(value, type2)
    print(type(value), value)
    PulsarKV.Log("Successfully fetched key-value pair")
end)

net.Receive("PulsarKV.Delete", function()
    local success = net.ReadBool()

    if not success then
        local err = net.ReadString()
            PulsarKV.Log("Error deleting key-value pair: " .. err)
        return
    end

    PulsarKV.Log("Successfully deleted key-value pair")
end)

net.Receive("PulsarKV.FetchAll", function()
    local success = net.ReadBool()

    if not success then
        local err = net.ReadString()
        PulsarKV.Log("Error fetching all key-value pairs: " .. err)
        return
    end

    local len = net.ReadUInt(32)
    local data = net.ReadData(len)
    data = util.Decompress(data)
    local table = util.JSONToTable(data)

    PrintTable(table)

    PulsarKV.Log("Successfully fetched all key-value pairs")
end)