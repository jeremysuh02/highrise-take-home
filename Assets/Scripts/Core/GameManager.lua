--!Type(Module)
local SaveManager : SaveManager = require("SaveManager")
local Utils : Utils = require("Utils")
local UpgradeModule : UpgradeModule = require("UpgradeModule")
local GridManager : GridManager = require("GridManager")

--!SerializeField
local PopupUI: GameObject = nil

--!SerializeField 
local TimerUI: GameObject = nil

--!SerializeField
local UpgradeUI: GameObject = nil

--!SerializeField
local LoserUI: GameObject = nil


type PlayerData = SaveManager.PlayerData

players = {}

local GameStates = {
    Idle = "Idle",
    PlayerLost = "PlayerLost",
    Victory = "Victory"
}

local currentGameState = GameStates.Idle

-- Event declarations

VictoryEvent = Event.new("VictoryEvent")
TurnOffUIEvent = Event.new("TurnOffUIEvent")

local function OnPlayerDataLoaded(playerData: PlayerData)
    Utils.PrintTable(playerData)
    SaveManager.SaveDataLoadedEvent:Fire(playerData)
    print("Player data loaded successfully for: " .. playerData.PlayerId)
end

local function SetGameState(newState)
    currentGameState = newState
    print("Game State changed to:", newState)

    if newState == GameStates.PlayerLost then
        PopupUI:SetActive(false)
        TimerUI:SetActive(false)
        LoserUI:SetActive(true)
        Timer.After(3, function()
            LoserUI:SetActive(false)
            SetGameState(GameStates.Idle)
        end)
    elseif newState == GameStates.Victory then
        Timer.After(3, function()
            GridManager.ResetAllGrids()
        end)
    elseif newState == GameStates.Idle then
        PopupUI:SetActive(false)
        TimerUI:SetActive(false)
        UpgradeUI:SetActive(false)
        LoserUI:SetActive(false)
    end
end

function self:ClientAwake()
    SaveManager.LoadPlayerDataFromServer(OnPlayerDataLoaded)
    TurnOffUIEvent:Connect(function(player)
        SetGameState(GameStates.PlayerLost)
    end)
end

function self:ServerAwake()
    VictoryEvent:Connect(function(player)
        TurnOffUIEvent:FireAllOtherClients(player)
        SetGameState(GameStates.Victory)
    end)
end

function self:ClientStart()
    SetGameState(GameStates.Idle)
end



function ActivePopup()
    PopupUI:SetActive(true)
end

function StartTime(countdown: number)
    TimerUI:SetActive(true)
    local timerUIScript = TimerUI:GetComponent(timerui)
    timerUIScript.StartCountdown(countdown)
end

function HideTime()
    TimerUI:SetActive(false)
end

