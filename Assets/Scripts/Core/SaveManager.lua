--!Type(Module)

Utils = require("Utils")

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
AddWinRequest = Event.new("AddWinRequest")
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

local function TrackPlayers(game, characterCallback)
    -- Ensure player data is loaded when they join
    scene.PlayerJoined:Connect(function(scene, player: Player)
        LoadDataRequestEvent:Connect(ServerLoadPlayerData)


        player.CharacterChanged:Connect(function(player, character)
            local playerinfo = ServerGetPlayerData(player.user.id)
            -- Check if the character is instantiated
            if character == nil then
                return  -- If no character, exit the function
            end

            -- Call the provided callback function with player info
            if characterCallback then
                characterCallback(playerinfo)
            end
        end)
    end)

    -- Optionally clear the data when they leave
    game.PlayerDisconnected:Connect(function(player)
        _serverPlayerSaveList[player.user.id] = nil
    end)
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

function AddWin(amount)
    AddWinRequest:FireServer(amount)
end

-- Initialize server-side events
function self.ServerAwake()
    TrackPlayers(server)
    SaveDataRequestEvent:Connect(OnSaveDataRequest)

    AddWinRequest:Connect(function(player, amount)
        if amount > 1 then
            amount = 1
        end
        local playerInfo = ServerGetPlayerData(player.user.id)
        local playerWins = playerInfo.WinCount
        playerWins = playerWins + amount

        AddWinServer(player, amount)
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
    _clientPlayerData = playerData
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

-- Initialize client-side events
function self.ClientAwake()
    LoadDataResponseEvent:Connect(OnDataLoaded)
    SaveDataResponseEvent:Connect(function(playerData: PlayerData)
        SetClientPlayerData(playerData)
        print("Data saved")
    end)

    function OnCharacterInstantiate(playerInfo)
        local player = playerInfo.player
        
    end

   
end

--------------------------------------------------------
-- Currency Functions
--------------------------------------------------------
