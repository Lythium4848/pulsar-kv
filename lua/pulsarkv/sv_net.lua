PulsarKV = PulsarKV or {}

util.AddNetworkString("PulsarKV.Insert")
util.AddNetworkString("PulsarKV.Fetch")
util.AddNetworkString("PulsarKV.Delete")
util.AddNetworkString("PulsarKV.FetchAll")

net.Receive("PulsarKV.Insert", function(_, ply)
    if not PulsarKV.HasPermission(ply) then
        return
    end

    if (ply.PulsarKVRateLimit or 0) > CurTime() then
        return
    end

    ---@diagnostic disable-next-line: inject-field
    ply.PulsarKVRateLimit = CurTime() + 2

    local key = net.ReadString()
    local value = net.ReadString()
    local state = net.ReadUInt(3)
    local type = net.ReadUInt(4)

    print(key, value, state, type)

    if state != PulsarKV.State.CLIENT and state != PulsarKV.State.SHARED then
        net.Start("PulsarKV.Insert")
            net.WriteBool(false)
            net.WriteString("Unable to insert server only key-value pairs from the client")
        net.Send(ply)

        return
    end

    PulsarKV.Insert(key, value, state, type,
    function()
        net.Start("PulsarKV.Insert")
            net.WriteBool(true)
        net.Send(ply)
    end,
    function(err)
        net.Start("PulsarKV.Insert")
            net.WriteBool(false)
            net.WriteString(err)
        net.Send(ply)
    end)
end)

net.Receive("PulsarKV.Fetch", function(_, ply)
    if (ply.PulsarKVRateLimit or 0) > CurTime() then
        return
    end

    ---@diagnostic disable-next-line: inject-field
    ply.PulsarKVRateLimit = CurTime() + 2

    local key = net.ReadString()

    PulsarKV.Fetch(key, PulsarKV.From.CLIENT,
    function(value, type)
        net.Start("PulsarKV.Fetch")
            net.WriteBool(true)
            net.WriteString(value)
            net.WriteUInt(type, 4)
        net.Send(ply)
    end,
    function(err)
        net.Start("PulsarKV.Fetch")
            net.WriteBool(false)
            net.WriteString(err)
        net.Send(ply)
    end)
end)

net.Receive("PulsarKV.Delete", function(_, ply)
    if not PulsarKV.HasPermission(ply) then
        return
    end

    if (ply.PulsarKVRateLimit or 0) > CurTime() then
        return
    end

    ---@diagnostic disable-next-line: inject-field
    ply.PulsarKVRateLimit = CurTime() + 2

    local key = net.ReadString()
    local state = net.ReadUInt(3)

    if state != PulsarKV.State.CLIENT and state != PulsarKV.State.SHARED then
        net.Start("PulsarKV.Insert")
            net.WriteBool(false)
            net.WriteString("Unable to insert server only key-value pairs from the client")
        net.Send(ply)

        return
    end

    PulsarKV.Delete(key, state,
    function()
        net.Start("PulsarKV.Delete")
            net.WriteBool(true)
        net.Send(ply)
    end,
    function(err)
        net.Start("PulsarKV.Delete")
            net.WriteBool(false)
            net.WriteString(err)
        net.Send(ply)
    end)
end)

net.Receive("PulsarKV.FetchAll", function(_, ply)
    if (ply.PulsarKVRateLimit or 0) > CurTime() then
        return
    end

    ---@diagnostic disable-next-line: inject-field
    ply.PulsarKVRateLimit = CurTime() + 2

    PulsarKV.FetchAll(PulsarKV.From.CLIENT,
    function(data)
        data = util.TableToJSON(data)
        data = util.Compress(data)

        local len = #data

        net.Start("PulsarKV.FetchAll")
            net.WriteBool(true)
            net.WriteUInt(len, 32)
            net.WriteData(data, len)
        net.Send(ply)
    end,
    function(err)
        net.Start("PulsarKV.FetchAll")
            net.WriteBool(false)
            net.WriteString(err)
        net.Send(ply)
    end)
end)