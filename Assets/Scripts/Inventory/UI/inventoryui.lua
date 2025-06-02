--!Type(UI)
local InventoryModule : InventoryModule = require("InventoryModule")

--!Bind
local _handButton : VisualElement = nil

--!Bind
local _shovelButton : VisualElement = nil

function self:ClientAwake()
    HandSelected()
end

function HandSelected()
    _shovelButton.style.backgroundColor = StyleColor.new(Color.new(0, 0, 0, 0.5))
    _handButton.style.backgroundColor = StyleColor.new(Color.new(0, 255, 0, 0.5))
    InventoryModule.ToggleShovel(false)
end
    
function ShovelSelected()
    _shovelButton.style.backgroundColor = StyleColor.new(Color.new(0, 255, 0, 0.5))
    _handButton.style.backgroundColor = StyleColor.new(Color.new(0, 0, 0, 0.5))
    InventoryModule.ToggleShovel(true)
end

_handButton:RegisterPressCallback(function()
    print("Button pressed.")
    HandSelected()
end)

_shovelButton:RegisterPressCallback(function()
    print("Button pressed.")
    ShovelSelected()
end)