--!Type(ClientAndServer)
local GridManager: GridManager = require("GridManager")

local GridRequest = Event.new("GridRequest")
local GridResponse = Event.new("GridResponse")

local GridItem = ""

function self:ClientAwake()
    self.CurrentItem = ""
    GridItem = self.CurrentItem
    self.gameObject:GetComponent(TapHandler).Tapped:Connect(function() 
        GridRequest:FireServer(GetCurrentItem())
    end)

    GridResponse:Connect(function(item: string)
        DisplayTappedItem(item)
    end)
end

function self:ServerAwake()
    GridRequest:Connect(function(player, item)
        print(self.gameObject.name .." tapped by " .. player.name .. ". Current item: " .. tostring(GetCurrentItem()))
        GridResponse:FireClient(player, GetCurrentItem())
    end)
    -- local item = GridManager:GetCurrentItem()
    -- print("Grid with item '" .. item .. "' tapped.")
    -- print("Grid with item '" .. CurrentItem .. "' tapped.")
end

function DisplayTappedItem(item: string)
    print("Client sees tapped item: " .. item)
end

function SetCurrentItem(item: string)
    GridItem = item

end

function GetCurrentItem(): string
    return GridItem
end