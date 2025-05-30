--!Type(ClientAndServer)
local ItemModule = require("ItemModule")

--!SerializeField
local itemType: string = ""

function GetItemType(): string
    return itemType
end