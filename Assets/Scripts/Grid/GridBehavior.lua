--!Type(ClientAndServer)
local GridManager: GridManager = require("GridManager")

local GridRequest = Event.new("GridRequest")
local GridResponse = Event.new("GridResponse")

local GridItem: ItemBehavior = nil
local ObjectReference: GameObject = nil

function self:ClientAwake()
    self.gameObject:GetComponent(TapHandler).Tapped:Connect(function() 
        GridRequest:FireServer()
    end)

    GridResponse:Connect(function(item: string)
        DisplayTappedItem(item)
    end)
end

function self:ServerAwake()
    GridRequest:Connect(function(player)
        if GridItem then
            print(self.gameObject.name .. " tapped by " .. player.name .. " Item Type:" .. GridItem.GetItemType())
            GridResponse:FireClient(player, GridItem.GetItemType())
        else
            print(self.gameObject.name .. " tapped by " .. player.name .. " but GridItem is nil")
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
    print("SetCurrentItem called on grid: " .. self.gameObject.name .. " and of type: " .. typeof(item))
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