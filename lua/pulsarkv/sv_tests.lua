PulsarKV.Insert("string", "string", PulsarKV.State.SHARED, PulsarKV.Type.STRING)
PulsarKV.Insert("number", tostring(123), PulsarKV.State.SHARED, PulsarKV.Type.NUMBER)
PulsarKV.Insert("bool", tostring(true), PulsarKV.State.SHARED, PulsarKV.Type.BOOL)
PulsarKV.Insert("bool2", tostring(false), PulsarKV.State.SHARED, PulsarKV.Type.BOOL)
PulsarKV.Insert("table", util.TableToJSON({test = true}), PulsarKV.State.SHARED, PulsarKV.Type.TABLE)
PulsarKV.Insert("vector", tostring(Vector(1, 2, 3)), PulsarKV.State.SHARED, PulsarKV.Type.VECTOR)
PulsarKV.Insert("angle", tostring(Angle(1, 2, 3)), PulsarKV.State.SHARED, PulsarKV.Type.ANGLE)
PulsarKV.Insert("color", tostring(Color(255, 255, 255)), PulsarKV.State.SHARED, PulsarKV.Type.COLOR)

local function testPrint(value)
    print(type(value), " - ", value)
end

PulsarKV.Fetch("string", PulsarKV.From.SERVER, testPrint)
PulsarKV.Fetch("number", PulsarKV.From.SERVER, testPrint)
PulsarKV.Fetch("bool", PulsarKV.From.SERVER, testPrint)
PulsarKV.Fetch("bool2", PulsarKV.From.SERVER, testPrint)
PulsarKV.Fetch("table", PulsarKV.From.SERVER, testPrint)
PulsarKV.Fetch("vector", PulsarKV.From.SERVER, testPrint)
PulsarKV.Fetch("angle", PulsarKV.From.SERVER, testPrint)
PulsarKV.Fetch("color", PulsarKV.From.SERVER, testPrint)

PulsarKV.Delete("string", PulsarKV.State.SHARED)

PulsarKV.Fetch("string", PulsarKV.From.SERVER, PrintTable)