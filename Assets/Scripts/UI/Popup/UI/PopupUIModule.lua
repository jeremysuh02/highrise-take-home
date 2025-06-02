--!Type(Module)

--!SerializeField
local ItemImages : {Texture} = nil

--!SerializeField
local PlaceholderImage : Texture = nil

local SetImage : Texture = nil

local SetName : string = nil

function SetItemImage(index: number)
    SetImage = ItemImages[index]
end

function GetItemImage() : Texture
    return SetImage
end

function GetPlaceholderImage() : Texture
    return PlaceholderImage
end

function SetItemName(name: string)
    SetName = name
end

function GetItemName() : string
    return SetName
end