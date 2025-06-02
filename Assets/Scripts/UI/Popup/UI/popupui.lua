--!Type(UI)

local PopupModule = require("PopupUIModule")

--!Bind
local _overlay : VisualElement = nil

--!Bind
local _foundItemImage : Image = nil

--!Bind
local _itemName : Label = nil

type Item = {
    Name: string,
    Image: Texture | nil,
}

_overlay:RegisterPressCallback(function()
    self.gameObject:SetActive(false)
end)

function self:OnEnable()
    if PopupModule.GetItemImage() then
        _foundItemImage.image = PopupModule.GetItemImage()
    else
        _foundItemImage.image = PopupModule.GetPlaceholderImage()
    end

    if PopupModule.GetItemName() then
        _itemName.text = "You found: " .. PopupModule.GetItemName() .. "!"
    else
        _itemName.text = "You found: Item!"
    end
end