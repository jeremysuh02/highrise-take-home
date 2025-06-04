--!Type(UI)

local SaveManager : SaveManager = require("SaveManager")
local UpgradeModule : UpgradeModule = require("UpgradeModule")

--!Bind
local _closeButton : VisualElement = nil

--!Bind
local _upgradeShovel : VisualElement = nil

--!Bind
local _upgradeDesc : Label = nil


_closeButton:RegisterPressCallback(function()
    self.gameObject:SetActive(false)
end)

function UpdateUpgradeText()
    local shovelLevel = SaveManager.GetPlayerDataValue("ShovelLevel", 1)
    if shovelLevel then
        _upgradeDesc.text = "Speed up digging speed. Current level: " .. shovelLevel
        print("Speed up digging speed. Current level: " .. shovelLevel)
    else
        _upgradeDesc.text = "Loading..."
        print("playerData is nil")
    end
end

_upgradeShovel:RegisterPressCallback(function()
    SaveManager.AddLevel()
    UpdateUpgradeText()
end)

function self:OnEnable()
    UpdateUpgradeText()
end