--!Type(UI)

local UpgradeModule : UpgradeModule = require("UpgradeModule")
local SaveManager : SaveManager = require("SaveManager")

--!Bind
local _storeButton : VisualElement = nil

--!Bind
local _storeText : Label = nil

--!SerializeField
local UpgradeUI : GameObject = nil

function UpdateCoinText()
    local coins = SaveManager.GetPlayerDataValue("CoinCount", 0)
    print("Store coin text: " .. coins)
    _storeText.text = "Coins: " .. tostring(coins)
end

_storeButton:RegisterPressCallback(function()
    if UpgradeUI.activeSelf then
        return
    end
    UpgradeUI:SetActive(true)
end)

function self:ClientAwake()
    SaveManager.SaveDataLoadedEvent:Connect(function()
        UpdateCoinText()
    end)
end


function self:ServerAwake()
    
end
