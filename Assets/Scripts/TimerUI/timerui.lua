--!Type(UI)

--!Bind
local _timerText : Label = nil

function SetTimerText(timeText: string)
    _timerText.text = timeText
end 

function StartCountdown(duration: number)
    local timeLeft: number = duration
    SetTimerText(string.format("%.2f", timeLeft) .. "s")

    local cancelHandle = nil  

    cancelHandle = Timer.Every(0.01, function()
        timeLeft -= 0.01
        if timeLeft > 0 then
            SetTimerText(string.format("%.2f",timeLeft).. "s")
        end
    end)
end
