--!Type(Module)
SaveManager = require("SaveManager")
Utils = require("Utils")

type PlayerData = SaveManager.PlayerData

players = {}

-- Event declarations
SaveDataLoadedEvent = Event.new("SaveDataLoadedEvent")

local function OnPlayerDataLoaded(playerData: PlayerData)
    Utils.PrintTable(playerData)
    SaveDataLoadedEvent:Fire(playerData)
    print("Player data loaded successfully for: " .. playerData.PlayerId)
end

function self:ClientAwake()
    SaveManager.LoadPlayerDataFromServer(OnPlayerDataLoaded)
end

function self:ServerAwake()

end

