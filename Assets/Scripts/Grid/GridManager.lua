--!Type(Module)

local GridManager = {}

local ItemRequest = Event.new("ItemRequest")
local ItemResponse = Event.new("ItemResponse")

--!SerializeField
local Grids: {GridBehavior} = {}

local PossibleItems = {"Treasure", "Coins", "Trash", "Nothing"}

function self:ClientAwake()
    ItemResponse:Connect(function(player, item)
        print("Client received item: " .. tostring(item))
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
    
    
end

function self:ServerStart()
    
end

function InitializeGrids()
-- Initialize each grid with a random item
    for _, grid in ipairs(Grids) do
        local randomItem = PossibleItems[math.random(1, #PossibleItems)]
        grid.SetCurrentItem(randomItem)
        local _gridItem = grid.GetCurrentItem()
        print("Grid initialized with item: " .. _gridItem)
        ItemRequest:Connect(function(player)
        -- Send only one item per request, or modify as needed
            ItemResponse:FireClient(player, _gridItem)
        end)
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