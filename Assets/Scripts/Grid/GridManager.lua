--!Type(Module)

local InventoryModule: InventoryModule = require("InventoryModule")

local GridManager = {}

local ItemRequest = Event.new("ItemRequest")
local ItemResponse = Event.new("ItemResponse")

--!SerializeField
local Grids: {GridBehavior} = {}

--!SerializeField
local TreasureChest: GameObject = nil

--!SerializeField
local Trash: GameObject = nil

--!SerializeField
local Coins: GameObject = nil

--!SerializeField
local Nothing: GameObject = nil

--!SerializeField
local Items: {GameObject} = {}

local GridItems = {}

local PossibleItems = {"Treasure", "Coins", "Trash", "Nothing"}

function self:ClientAwake()
    print("ClientAwake called for GridManager")
    ItemRequest:FireServer()
    ItemResponse:Connect(function(items)
        print("Client received grid items:")
        print("Total items: " .. #items)
        for i, itemType in ipairs(items) do
            print("Grid " .. i .. ": " .. tostring(itemType))
        end
    end)
end


function self:ServerAwake()
    -- find all grid behaviors in the scene
    local grids = self.gameObject:GetComponentsInChildren(GridBehavior)
    -- add to Grids array
    for _, grid in ipairs(grids) do
        table.insert(Grids, grid)
    end
    print("GridManager initialized with " .. #Grids .. " grids.")
    InitializeGrids()
    print("Firing Grid Items to all clients")
    ItemResponse:FireAllClients(GridItems)
    ItemRequest:Connect(function(player)
        ItemResponse:FireClient(player, GridItems)
    end)
    
end

function self:ServerStart()
    
end

function InitializeGrids()
-- Initialize each grid with a random item
    local treasureIdx = math.random(1, #Grids)
    for i, grid in ipairs(Grids) do
        local randomInt = math.random(2, #Items) -- only one grid can be initialized with treasure
        if i == treasureIdx then
            SetGridHelper(1, grid, i)
        else
            SetGridHelper(randomInt, grid, i)
        end
    end
end

function ResetAllGrids()
    GridItems = {}
    for i, grid in ipairs(Grids) do
        grid.SetObjectReference(nil)
        grid.SetCurrentItem(nil)
        grid.ResetTap()
        table.insert(GridItems, "Nothing")
        print("Grid " .. tostring(i) .. " reset to empty.")
    end
    InitializeGrids()
end

function SetGridHelper(number: number, grid: GridBehavior, index: number)
    local getItem = Object.Instantiate(Items[number])
    grid.SetObjectReference(getItem)
    local itemBehavior = getItem:GetComponent(ItemBehavior)
    grid.SetCurrentItem(itemBehavior)
    local itemType = itemBehavior.GetItemType()
    print("Grid " .. tostring(index) .. " initialized with item: " .. itemType)
    table.insert(GridItems, itemType)
end


function RemoveItemFromGrid(grid: GridBehavior, item: ItemBehavior)
    -- Remove the item from the specified grid
    if grid and item then
        print("Removed item from grid: " .. tostring(item.GetItemType()))
    else
        print("Invalid grid or item provided for removal.")
    end
end

--[[
function InitializeGrids()
    -- Initialize each grid with a random item
    for _, grid in ipairs(Grids) do
        local randomItem = PossibleItems[math.random(1, #PossibleItems)]
        grid.SetCurrentItem(randomItem)
        print("Grid initialized with item: " .. tostring(grid.GetCurrentItem()))
    end

    -- Connect ItemRequest once, and respond with a random grid's item
    ItemRequest:Connect(function(player)
        if #Grids > 0 then
            local grid = Grids[math.random(1, #Grids)]
            ItemResponse:FireClient(player, grid.GetCurrentItem())
        else
            ItemResponse:FireClient(player, nil)
        end
    end)
end
]]--