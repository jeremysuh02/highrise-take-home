--!Type(ClientAndServer)
local GridManager: GridManager = require("GridManager")
local SaveManager: SaveManager = require("SaveManager")

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
        local gridPos =  self.gameObject.transform.position
        local playerPos = player.character.transform.position
        local distance = (gridPos - playerPos).magnitude
        print("distance between player and grid: " .. distance)
        if distance <= 0.7 then
            if GridItem then
                print(self.gameObject.name .. " tapped by " .. player.name .. " Item Type:" .. GridItem.GetItemType())
                GridResponse:FireClient(player, GridItem.GetItemType())
            else
                print(self.gameObject.name .. " tapped by " .. player.name .. " but GridItem is nil")
            end
        end
        
            
    end)
    -- local item = GridManager:GetCurrentItem()
    -- print("Grid with item '" .. item .. "' tapped.")
    -- print("Grid with item '" .. CurrentItem .. "' tapped.")
end

function DisplayTappedItem(item: string)
    print("Client sees tapped item: " .. item)
    if item == "Treasure" then
        SaveManager.AddWin(1)
    elseif item == "Coin" then
        SaveManager.CoinTransaction(1)
    end
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

function self:OnCollisionEnter(hit: Collision)
    
end