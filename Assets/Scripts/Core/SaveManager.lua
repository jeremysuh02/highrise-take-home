--!Type(Module)

-- PlayerData type hold information about a player
export type PlayerData = {
    PlayerId: string,
    WinCount: number,
    CoinCount: number,
}

local PlayerDataKey = "PlayerData"

-- Table to hold player data for all players on the server
local _serverPlayerSaveList: { [string]: PlayerData } = {}

-- Client player data
local _clientPlayerData: PlayerData = nil

-- Events for loading and saving data
local LoadDataRequestEvent = Event.new("LoadDataRequestEvent")
local LoadDataResponseEvent = Event.new("LoadDataResponseEvent")
local SaveDataRequestEvent = Event.new("SaveDataRequestEvent")
local SaveDataResponseEvent = Event.new("SaveDataResponseEvent")
SaveDataLoadedEvent = Event.new("SaveDataLoadedEvent")

--------------------------------------------------------
-- Server Functions
--------------------------------------------------------

-- New player save data
function CreateNewPlayerData(player: Player): PlayerData
    return {
        PlayerId = player.user.id,
        WinCount = 0,
        CoinCount = 0,
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

-- Initialize server-side events
function self.ServerAwake()
    LoadDataRequestEvent:Connect(ServerLoadPlayerData)
    SaveDataRequestEvent:Connect(OnSaveDataRequest)
    
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
    _clientPlayerData = playerData
end

-- Load player data from server
function LoadPlayerDataFromServer(OnLoaded: (playerData: PlayerData) -> ())
    _onLoadCallback = OnLoaded
    LoadDataRequestEvent:FireServer()
end

-- Save player data to server
function SavePlayserDataToServer()
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
    SavePlayserDataToServer() -- Save the new data to server
end

-- Initialize client-side events
function self.ClientAwake()
    LoadDataResponseEvent:Connect(OnDataLoaded)
    SaveDataResponseEvent:Connect(function(playerData: PlayerData)
        SetClientPlayerData(playerData)
        print("Data saved")
    end)
end