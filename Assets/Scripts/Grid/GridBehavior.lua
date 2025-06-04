--!Type(ClientAndServer)
local GridManager: GridManager = require("GridManager")
local SaveManager: SaveManager = require("SaveManager")
local GameManager: GameManager = require("GameManager")
local PopupModule: PopupUIModule = require("PopupUIModule")
local InventoryModule: InventoryModule = require("InventoryModule")

local GridRequest = Event.new("GridRequest")
local GridResponse = Event.new("GridResponse")
local DisableTapEvent = Event.new("DisableTapEvent")
local EnableTapEvent = Event.new("EnableTapEvent")
local EmoteRequestEvent = Event.new("EmoteRequestEvent")
local PlayEmoteEvent = Event.new("PlayEmoteEvent")
local WaitEvent = Event.new("WaitEvent")
local StartTimerUIEvent = Event.new("StartTimerUIEvent")

--!SerializeField
local EmoteIds : {string} = {}

local GridItem: ItemBehavior = nil
local ObjectReference: GameObject = nil

local hasBeenTapped = false -- edge case handler: two player could tap a grid at the same time. Only one rewarded the item.


function self:ClientAwake()
    local tapHandler = self.gameObject:GetComponent(TapHandler)
    
    tapHandler.Tapped:Connect(function()
        if InventoryModule.IsShovelActive() then
            EmoteRequestEvent:FireServer(EmoteIds[1])
            WaitEvent:FireServer()
            
        end
    end)

    GridResponse:Connect(function(item: string)
        GameManager.HideTime()
        DisplayTappedItem(item)
    end)
    
    DisableTapEvent:Connect(function()
        if tapHandler then 
            tapHandler.enabled = false 
            print("Tap disabled by server")
        end
    end)

    EnableTapEvent:Connect(function()
        if tapHandler then
            tapHandler.enabled = true
            print("Tap enabled.")
        end
    end)

    PlayEmoteEvent:Connect(function(player, string)
        if player.character then
            player.character:PlayEmote(string)
        end
    end)

    StartTimerUIEvent:Connect(function(countDown: number)
        print("Count down" .. countDown)
        GameManager.StartTime(countDown)
    end)
    
end

function self:ServerAwake()
    GridRequest:Connect(function(player)
        
    end)

    EmoteRequestEvent:Connect(function(player, string)
        PlayEmoteEvent:FireAllClients(player, string)
    end)

    WaitEvent:Connect(function(player)
        local playerId = player.user.id
        local playerData = SaveManager.ServerGetPlayerData(playerId)
        if playerData then
            -- determine how long digging takes based on shovel level
            local shovelLevel = playerData.ShovelLevel
            if shovelLevel > 10 then shovelLevel = 10 end
            local decrease = 0.1 * shovelLevel + math.log(shovelLevel)
            if shovelLevel == 1 then decrease = 0 end
            print("timer start")
            print("Decrease: " .. decrease)
            local countDown = 3 - decrease
            if countDown then StartTimerUIEvent:FireClient(player, countDown) end
            Timer.After(countDown, function()
                    if hasBeenTapped then 
                        print("Grid already visited.")
                        GridResponse:FireClient(player, "Nothing")
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
        else
            print("shovel data null.")
        end
    end)
    
    -- local item = GridManager:GetCurrentItem()
    -- print("Grid with item '" .. item .. "' tapped.")
    -- print("Grid with item '" .. CurrentItem .. "' tapped.")
end

function ResetTap()
    hasBeenTapped = false
    EnableTapEvent:FireAllClients()
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