--!Type(Module)

local SaveManager : SaveManager = require("SaveManager")

--!SerializeField
local StoreButton : storebuttonui = nil

--!SerializeField
local UpgradeUI : upgradeui = nil

UpdatePlayerDataEvent = Event.new("UpdatePlayerDataEvent")

function self:ClientAwake()
    
end

function self:ServerAwake()
    UpdatePlayerDataEvent:FireAllClients()
end

function UpdatePlayerCoins()
    StoreButton.UpdateCoinText()
end

function UpdateShovelLevel()
    UpgradeUI.UpdateUpgradeText()
end

