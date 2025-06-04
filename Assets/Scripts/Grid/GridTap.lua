--!Type(Client)

function self:Awake()
    self.gameObject:GetComponent(TapHandler).Tapped:Connect(function() 
        print("Grid tapped")
    end)
end