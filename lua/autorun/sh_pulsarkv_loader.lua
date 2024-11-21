PulsarKV = PulsarKV or {}

PulsarKV.Loaded = false

local function load()
    include("pulsarkv/sv_sql.lua")
    include("pulsarkv/sv_core.lua")
    include("pulsarkv/sv_net.lua")
    include("pulsarkv/sh_core.lua")

    AddCSLuaFile("pulsarkv/cl_core.lua")
    AddCSLuaFile("pulsarkv/cl_net.lua")
    AddCSLuaFile("pulsarkv/sh_core.lua")

    if CLIENT then
        include("pulsarkv/cl_core.lua")
        include("pulsarkv/cl_net.lua")
        include("pulsarkv/sh_core.lua")
    end

    PulsarKV.Log("Fully loaded!")
    PulsarKV.Loaded = true
    hook.Run("PulsarKV.FullyLoaded")
end

--- Logs a message to the console
--- @param ... any The message to log
function PulsarKV.Log(...)
    MsgC(Color(0, 255, 255), "[PulsarKV] ", Color(255, 255, 255), ...)
    MsgN("")
end

if file.IsDir("pulsar_lib", "LUA") then
    PulsarKV.Log("PulsarLib detected, waiting for it to load...")

    PulsarKV.UsingPulsarLib = true
    if PulsarLib.Loaded then
        load()
    end

    hook.Add("PulsarLib.Loaded", "PulsarKV.Load", load)
else
    PulsarKV.Log("Loading...")
    load()
end
