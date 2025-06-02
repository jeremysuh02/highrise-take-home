--!Type(Module)

--!SerializeField
local ShovelEquipped : boolean = false

function ToggleShovel(set: boolean) 
    ShovelEquipped = set
end

function IsShovelActive() : boolean
    return ShovelEquipped
end