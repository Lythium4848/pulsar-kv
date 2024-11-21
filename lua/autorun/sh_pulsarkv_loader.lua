PulsarKV = PulsarKV or {}

function PulsarKV.LoadDirectory(path)
    local files, folders = file.Find(path .. "/*", "LUA")

    for _, fileName in ipairs(files) do
        local filePath = path .. "/" .. fileName

        if CLIENT then
            include(filePath)
        else
            if fileName:StartWith("cl_") then
                AddCSLuaFile(filePath)
            elseif fileName:StartWith("sh_") then
                AddCSLuaFile(filePath)
                include(filePath)
            else
                include(filePath)
            end
        end
    end

    return files, folders
end

function PulsarKV.LoadDirectoryRecursive(basePath)
    local _, folders = PulsarKV.LoadDirectory(basePath)

    for _, folderName in ipairs(folders) do
        PulsarKV.LoadDirectoryRecursive(basePath .. "/" .. folderName)
    end
end

PulsarUI.LoadDirectoryRecursive("pulsarkv")
hook.Run("PulsarKV.FullyLoaded")