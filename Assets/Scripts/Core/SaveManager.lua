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