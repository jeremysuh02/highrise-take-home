--!Type(UI)

local SaveManager : SaveManager = require("SaveManager")

--!Bind
local _winsText : Label = nil

function UpdateWinText()
    local wins = SaveManager.GetPlayerDataValue("WinCount", 0)
    print("Wins text: " .. wins)
    _winsText.text = "Wins: " .. tostring(wins)
end

function self:ClientAwake()
    SaveManager.SaveDataLoadedEvent:Connect(function()
        UpdateWinText()
    end)
end