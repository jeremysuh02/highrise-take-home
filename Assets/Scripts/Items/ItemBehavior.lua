--!Type(ClientAndServer)

--!SerializeField
local itemType: string = ""

--!SerializeField
local itemImage: Texture = nil

function GetItemType(): string
    return itemType
end

function GetItemImage(): Texture
    return itemImage
end