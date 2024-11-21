PulsarKV.AccessGroups = { -- This is a table of groups that are able to upload/delete key-value pairs. This is ignored if PulsarLib is installed.
    ["owner"] = true,
    ["Owner"] = true,
    ["superadmin"] = true,
    ["SuperAdmin"] = true,
    ["Super Admin"] = true,
}

-- Do not touch anything below this line unless you know what you're doing.

if PulsarLib then
    PulsarKV.AccessGroups = PulsarLib.AdminUserGroups
end

---@enum PulsarKVState
PulsarKV.State = {
    SERVER = 0,
    CLIENT = 1,
    SHARED = 2
}


---@enum PulsarKVFrom
PulsarKV.From = {
    SERVER = 0,
    CLIENT = 1,
}

---@enum PulsarKVType
PulsarKV.Type = {
    STRING = 0,
    NUMBER = 1,
    BOOL = 2,
    TABLE = 3,
    VECTOR = 6,
    ANGLE = 7,
    COLOR = 8,
}

local typeConverts = {
    [PulsarKV.Type.STRING] = function(value) return value end,
    [PulsarKV.Type.NUMBER] = function(value) return tonumber(value) end,
    [PulsarKV.Type.BOOL] = function(value) return tobool(value) end,
    [PulsarKV.Type.TABLE] = function(value) return util.JSONToTable(value) end,
    [PulsarKV.Type.VECTOR] = function(value) return util.StringToType(value, "Vector") end,
    [PulsarKV.Type.ANGLE] = function(value) return util.StringToType(value, "Angle") end,
    [PulsarKV.Type.COLOR] = function(value) return string.ToColor(value) end
}

--- Converts a value to its correct type
--- @param value string The value to convert
--- @param type PulsarKVType The type to convert to
--- @return any The converted value
function PulsarKV.ConvertType(value, type)
    return typeConverts[type](value)
end