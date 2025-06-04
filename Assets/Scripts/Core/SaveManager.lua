--!Type(Module)

local Utils : Utils = require("Utils")
local WinManager : WinManager = require("WinManager")
local GameManager : GameManager = require("GameManager")
local WinManager : WinManager = require("WinManager")

-- PlayerData type hold information about a player
export type PlayerData = {
    PlayerId: string,
    WinCount: number,
    CoinCount: number,
    ShovelLevel: number,
}

local PlayerDataKey = "PlayerData"

-- Table to hold player data for all players on the server
local _serverPlayerSaveList: { [string]: PlayerData } = {}

-- Client player data
local _clientPlayerData: PlayerData = nil

--!SerializeField
local UpgradeModule : UpgradeModule = nil

--!SerializeField
local Testing : boolean = false

-- Events for loading and saving data
local LoadDataRequestEvent = Event.new("LoadDataRequestEvent")
local LoadDataResponseEvent = Event.new("LoadDataResponseEvent")
local SaveDataRequestEvent = Event.new("SaveDataRequestEvent")
local SaveDataResponseEvent = Event.new("SaveDataResponseEvent")
AddWinRequest = Event.new("AddWinRequest")
CoinTransactionRequest = Event.new("CoinTransactionRequest")
AddLevelRequest = Event.new("AddLevelRequest")
SaveDataLoadedEvent = Event.new("SaveDataLoadedEvent")
ResetPlayerDataRequest = Event.new("ResetPlayerDataRequest")

players = {}

--------------------------------------------------------
-- Server Functions
--------------------------------------------------------

-- New player save data
function CreateNewPlayerData(player: Player): PlayerData
    return {
        PlayerId = player.user.id,
        WinCount = 0,
        CoinCount = 0,
        ShovelLevel = 1,
    }
end

-- Validate and initialize player data
local function ValidatePlayerData(playerData: PlayerData)
    if not playerData.WinCount or type(playerData.WinCount) ~= "number" then
        playerData.WinCount = 0
    end
    if not playerData.CoinCount or type(playerData.CoinCount) ~= "number" then
        playerData.CoinCount = 0
    end
    if not playerData.ShovelLevel or type(playerData.ShovelLevel) ~= "number" then
        playerData.ShovelLevel = 1
    end
end

-- Load player data from storage
local function ServerLoadPlayerData(player: Player)
    LoadDataForPlayer(player, PlayerDataKey, function(playerData)
        print("Loading player data for: " .. player.user.id)
        if not playerData then
            print ("Creating new player data")
            playerData = CreateNewPlayerData(player)
        end
        ValidatePlayerData(playerData) -- Validate
        _serverPlayerSaveList[player.user.id] = playerData -- Store in server list
        LoadDataResponseEvent:FireClient(player, playerData) -- Send data back to client
    end)
end

-- handle save data requests from client
function OnSaveDataRequest(player: Player, data: any)
    ServerSavePlayerData(player, data.PlayerData, nil, true)
end

-- Save player data to storage
function ServerSavePlayerData(
    player: Player,
    playerData: PlayerData,
    callback: (() -> ()) | nil,
    sendClientResponse: boolean
)
    Storage.SetPlayerValue(player, PlayerDataKey, playerData, function(err: StorageError)
        if err ~= StorageError.None then
            error("Failed to save player data: " .. tostring(err))
        else
            _serverPlayerSaveList[player.user.id] = playerData
        end
        if sendClientResponse then
            SaveDataResponseEvent:FireClient(player, playerData)
        end
        if callback then 
            callback()
        end
    end)
end

-- Load data for a specific player
function LoadDataForPlayer(player: Player, key: string, callback: (data: any) -> ())
    Storage.GetPlayerValue(player, key, function(data)
        callback(data)
    end)
end

-- Save data for a specific player
function SaveDataForPlayer(player: Player, key: string, data: any)
    Storage.SetPlayerValue(player, key, data, function(err: StorageError)
        if err ~= StorageError.None then
            error("Failed to save player data: " .. tostring(err))
        end
    end)
end

function LoadGlobalData(key: string, callback: (data: any) -> ())
	Storage.GetValue(key, function(data)
		callback(data) -- Call the provided callback with the loaded global data
	end)
end

-- Function to save global data
function SaveGlobalData(key: string, data: any)
	Storage.SetValue(key, data, function(err: StorageError)
		if err ~= StorageError.None then
			error("Failed to save global data: " .. tostring(err)) -- Log error if saving fails
		end
	end)
end

-- Function to update global data with a validator function
function UpdateGlobalData(key: string, validator: (data: any) -> any?, callback: (data: any) -> any)
	Storage.UpdateValue(key, function(data)
		return validator(data) -- Validate and return updated data
	end, callback) -- Call the provided callback with the updated data
end

function ServerGetPlayerData(id: string): PlayerData
	return _serverPlayerSaveList[id] -- Return the player data for the given ID
end

-- Set player data on the server
-- Set player data on the server
function ServerSetPlayerData(player: Player, key: string, value: any)
    local playerData = _serverPlayerSaveList[player.user.id]
    if playerData then
        playerData[key] = value
        ValidatePlayerData(playerData)
        _serverPlayerSaveList[player.user.id] = playerData
        ServerSavePlayerData(player, playerData, nil, false)
    end
end


function AddWinServer(player, amount)
    Storage.IncrementPlayerValue(player, "WinCount", amount)
    local playerInfo = ServerGetPlayerData(player.user.id)
    if playerInfo then
        playerInfo.WinCount = (playerInfo.WinCount or 0) + amount
    end
    ServerSavePlayerData(player, playerInfo, nil, true)
    print("Wins: " .. playerInfo.WinCount)
end

function CoinTransactionServer(player, amount)
    Storage.IncrementPlayerValue(player, "CoinCount", amount)
    local playerInfo = ServerGetPlayerData(player.user.id)
    if playerInfo then
        playerInfo.CoinCount = (playerInfo.CoinCount or 0) + amount
    end
    ServerSavePlayerData(player, playerInfo, nil, true)
    print("Coins: " .. playerInfo.CoinCount)
end

function AddLevelServer(player)
    local playerInfo = ServerGetPlayerData(player.user.id)
    if playerInfo.CoinCount >= 10 then 
        Storage.IncrementPlayerValue(player, "ShovelLevel", 1)
        Storage.IncrementPlayerValue(player, "CoinCount", -10)
        
        if playerInfo then
            print("adding level and taking coins")
            playerInfo.ShovelLevel = (playerInfo.ShovelLevel or 0) + 1
            playerInfo.CoinCount = (playerInfo.CoinCount or 0) - 10
        end
        ServerSavePlayerData(player, playerInfo, nil, true)
        print("Coins: " .. playerInfo.CoinCount .. " and Shovel Level: " .. playerInfo.ShovelLevel)
    end
end

function AddWin(amount)
    AddWinRequest:FireServer(amount)
    GameManager.VictoryEvent:FireServer()
end

function CoinTransaction(amount)
    CoinTransactionRequest:FireServer(amount)
end

function AddLevel()
    print("AddLevel to server")
    AddLevelRequest:FireServer()
end

function ResetPlayerData(player: Player)
    local newData = CreateNewPlayerData(player)
    ValidatePlayerData(newData)
    _serverPlayerSaveList[player.user.id] = newData
    ServerSavePlayerData(player, newData, nil, true)
    print("reset data")
end


-- Initialize server-side events
function self.ServerAwake()
    LoadDataRequestEvent:Connect(ServerLoadPlayerData)
    SaveDataRequestEvent:Connect(OnSaveDataRequest)

    ResetPlayerDataRequest:Connect(function(player)
        ResetPlayerData(player)
    end)

    AddWinRequest:Connect(function(player, amount)
        if amount > 1 then -- ensures players can only receieve 1 win
            amount = 1
        end
        AddWinServer(player, amount)
        CoinTransactionServer(player, 5)
    end)
    
    CoinTransactionRequest:Connect(function(player, amount)
        if amount > 1 then -- ensures players can only receive 1 coin
            amount = 1
        end
        CoinTransactionServer(player, amount)
    end)

    AddLevelRequest:Connect(function(player)
        print("Adding level to server")
        AddLevelServer(player)
    end)

end



--------------------------------------------------------
-- Client Functions
--------------------------------------------------------

-- Getter for current client player data
function GetClientPlayerData(): PlayerData
    return _clientPlayerData
end

-- Check if player data is loaded
function IsPlayerDataLoaded(): boolean
    return _clientPlayerData ~= nil
end

-- Setter for current client player data
function SetClientPlayerData(playerData: PlayerData)
    local oldData = _clientPlayerData
    _clientPlayerData = playerData

    if not oldData then return end

    if _clientPlayerData.CoinCount ~= oldData.CoinCount then
        UpgradeModule.UpdatePlayerCoins() -- only coin changed
    end
    if _clientPlayerData.ShovelLevel ~= oldData.ShovelLevel then
        UpgradeModule.UpdateShovelLevel() -- shovel upgrade
    end

    if _clientPlayerData.WinCount ~= oldData.WinCount then
        WinManager.DisplayWins()
    end
end

-- Load player data from server
function LoadPlayerDataFromServer(OnLoaded: (playerData: PlayerData) -> ())
    _onLoadCallback = OnLoaded
    LoadDataRequestEvent:FireServer()
end

-- Save player data to server
function SavePlayerDataToServer()
    local data = {
        playerData = _clientPlayerData,
    }

    SaveDataRequestEvent:FireServer(data)
end

-- Handle data loaded from server
local function OnDataLoaded(playerData: PlayerData)
    print("Client received player data: " .. playerData.PlayerId)
    SetClientPlayerData(playerData) -- Set client data
    if _onLoadCallback then
        _onLoadCallback(playerData) -- Call the callback if provided
    end
    SaveDataLoadedEvent:Fire() -- Notify that data is loaded
end

-- Clear player data and create new data
function ClearPlayerData()
    _clientPlayerData = CreateNewPlayerData(client.localPlayer)
    SavePlayerDataToServer() -- Save the new data to server
end

-- Get the current player's shovel level
function GetShovelLevel(): number
    if _clientPlayerData and _clientPlayerData.ShovelLevel then
        return _clientPlayerData.ShovelLevel
    end
    return 1
end

function GetPlayerDataValue(key: string, default)
    if _clientPlayerData and _clientPlayerData[key] ~= nil then
        print("_clientPlayerData value: " .. _clientPlayerData[key])
        return _clientPlayerData[key]
    elseif not _clientPlayerData then
        print("_clientPlayerData is nil")
    end
    return default
end

-- Initialize client-side events
function self.ClientAwake()
    LoadDataResponseEvent:Connect(OnDataLoaded)
    SaveDataResponseEvent:Connect(function(playerData: PlayerData)
        SetClientPlayerData(playerData)
        print("Data saved")
    end)

    function OnCharacterInstantiate(playerInfo)
        local player = playerInfo.player
        local character = player.character

        playerInfo.CoinCount.Changed:Connect(function(coins, oldVal)
            UpgradeModule.UpdatePlayerCoins()
        end)
    end
    if Testing then ResetPlayerDataRequest:FireServer() end

end
