--!Type(Module)
SaveManager = require("SaveManager")

type PlayerData = SaveManager.PlayerData

-- Event declarations
SaveDataLoadedEvent = Event.new("SaveDataLoadedEvent")

local function OnPlayerDataLoaded(playerData: PlayerData)
    SaveDataLoadedEvent:Fire(playerData)
    print("Player data loaded successfully for: " .. playerData.PlayerId)
end

function self:ClientAwake()
    SaveManager.LoadPlayerDataFromServer(OnPlayerDataLoaded)
end