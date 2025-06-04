--!Type(Server)

function ReloadGame()
    print("Reload")
    Timer.After(3, function()
        print("Time's up")
        server.LoadScene("Room", false)
    end)
end