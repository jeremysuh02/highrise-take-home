--!Type(ClientAndServer)
local GridManager: GridManager = require("GridManager")
local SaveManager: SaveManager = require("SaveManager")
local GameManager: GameManager = require("GameManager")
local PopupModule: PopupUIModule = require("PopupUIModule")

local GridRequest = Event.new("GridRequest")
local GridResponse = Event.new("GridResponse")
local DisableTapEvent = Event.new("DisableTapEvent")

local GridItem: ItemBehavior = nil
local ObjectReference: GameObject = nil

local hasBeenTapped = false -- edge case handler: two player could tap a grid at the same time. Only one rewarded the item.


function self:ClientAwake()
    local tapHandler = self.gameObject:GetComponent(TapHandler)
    tapHandler.Tapped:Connect(function()
        GridRequest:FireServer()
        DisableTapEvent:FireServer()
    end)

    GridResponse:Connect(function(item: string)
        DisplayTappedItem(item)
    end)
    
    DisableTapEvent:Connect(function()
        if tapHandler then 
            tapHandler.enabled = false 
            print("Tap disabled by server")
        end
    end)
end

function self:ServerAwake()
    GridRequest:Connect(function(player)
        if hasBeenTapped then 
            print("Grid already visited.")
            return
        end
        if GridItem then
            hasBeenTapped = true
            print(self.gameObject.name .. " tapped by " .. player.name .. " Item Type:" .. GridItem.GetItemType())
            GridResponse:FireClient(player, GridItem.GetItemType())
            DisableTapEvent:FireAllClients()
        else
            print(self.gameObject.name .. " tapped by " .. player.name .. " but GridItem is nil")
        end
    end)
    -- local item = GridManager:GetCurrentItem()
    -- print("Grid with item '" .. item .. "' tapped.")
    -- print("Grid with item '" .. CurrentItem .. "' tapped.")
end

function SetPopupUI(index: number, name: string)
    PopupModule.SetItemImage(index)
    PopupModule.SetItemName(name)
    GameManager.ActivePopup()
end

function DisplayTappedItem(item: string)
    print("Client sees tapped item: " .. item)
    if item == "Treasure" then
        SaveManager.AddWin(1)
        SetPopupUI(1, item)
    elseif item == "Coin" then
        SaveManager.CoinTransaction(1)
        SetPopupUI(2, item)
    elseif item == "Trash" then
        SetPopupUI(3, item)
    elseif item == "Nothing" then
        SetPopupUI(4, item)
    end
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

function self:OnCollisionEnter(hit: Collision)
    
end