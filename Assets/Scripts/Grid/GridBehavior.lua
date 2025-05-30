--!Type(ClientAndServer)
local GridManager: GridManager = require("GridManager")

local GridRequest = Event.new("GridRequest")
local GridResponse = Event.new("GridResponse")

local GridItem: ItemBehavior = nil
local ObjectReference: GameObject = nil

function self:ClientAwake()
    self.gameObject:GetComponent(TapHandler).Tapped:Connect(function() 
        GridRequest:FireServer(GetCurrentItem())
    end)

    GridResponse:Connect(function(item: string)
        DisplayTappedItem(item)
    end)
end

function self:ServerAwake()
    GridRequest:Connect(function(player, item)
        print("Grid tapped by " .. player.name .. " Item Type:" .. typeof(item))
        if typeof(item) == "ItemBehavior" then
            print(self.gameObject.name .." tapped by " .. player.name .. ". Current item: " .. item.GetItemType())
            GridResponse:FireClient(player, item.GetItemType())
        end
    end)
    -- local item = GridManager:GetCurrentItem()
    -- print("Grid with item '" .. item .. "' tapped.")
    -- print("Grid with item '" .. CurrentItem .. "' tapped.")
end

function DisplayTappedItem(item: string)
    print("Client sees tapped item: " .. item)
end

function SetCurrentItem(item: ItemBehavior)
    GridItem = item
end

function GetCurrentItem(): ItemBehavior
    return GridItem
end

function SetObjectReference(object: GameObject)
    ObjectReference = object
end

function GetObjectReference(): GameObject
    return ObjectReference
end