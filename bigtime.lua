--[[!ntp_forward:pastebin:51K15aQ4]]--
-- The comment above tells NTP to pull the script from pastebin instead. Fallback:

args = {...}
monitor = peripheral.find("monitor")
digitColor = "0"
bgColor = "f"


function blitBg(matrixSlice)
    local x, y = monitor.getCursorPos()
    matrixSlice = matrixSlice:gsub(" ", bgColor)
    matrixSlice = matrixSlice:gsub("0", digitColor)
    local msLen = matrixSlice:len()
    local fillerText = string.rep(" ", msLen)
    local fillerTextColor = string.rep("0", msLen)
    monitor.blit(fillerText, fillerTextColor, matrixSlice)
    monitor.setCursorPos(x, y + 1)
end

function blitDigit(digit)
    local x, y = monitor.getCursorPos()
    if digit == "0" then
        blitBg(" 000 ")
        blitBg("0   0")
        blitBg("0   0")
        blitBg("0   0")
        blitBg(" 000 ")
    elseif digit == "1" then
        blitBg("  0  ")
        blitBg(" 00  ")
        blitBg("  0  ")
        blitBg("  0  ")
        blitBg("00000")
    elseif digit == "2" then
        blitBg(" 000 ")
        blitBg("0   0")
        blitBg("   0 ")
        blitBg(" 00  ")
        blitBg("00000")
    elseif digit == "3" then
        blitBg(" 000 ")
        blitBg("0   0")
        blitBg("   0 ")
        blitBg("0   0")
        blitBg(" 000 ")
    elseif digit == "4" then
        blitBg("  00 ")
        blitBg(" 0 0 ")
        blitBg("0  0 ")
        blitBg("00000")
        blitBg("   0 ")
    elseif digit == "5" then
        blitBg("00000")
        blitBg("0    ")
        blitBg("0000 ")
        blitBg("    0")
        blitBg("0000 ")
    elseif digit == "6" then
        blitBg(" 000 ")
        blitBg("0    ")
        blitBg("0000 ")
        blitBg("0   0")
        blitBg(" 000 ")
    elseif digit == "7" then
        blitBg("00000")
        blitBg("    0")
        blitBg("   0 ")
        blitBg("  0  ")
        blitBg("  0  ")
    elseif digit == "8" then
        blitBg(" 000 ")
        blitBg("0   0")
        blitBg(" 000 ")
        blitBg("0   0")
        blitBg(" 000 ")
    elseif digit == "9" then
        blitBg(" 000 ")
        blitBg("0   0")
        blitBg(" 0000")
        blitBg("    0")
        blitBg(" 000 ")
    elseif digit == ":" then
        blitBg("   ")
        blitBg(" 0 ")
        blitBg("   ")
        blitBg(" 0 ")
        blitBg("   ")
    end
    if digit == ":" then
        monitor.setCursorPos(x + 4, y)
    else
        monitor.setCursorPos(x + 6, y)
    end
end

function gameTime()
    time = os.time("ingame")
    h = math.floor(time)
    if math.floor(h / 10) == 0 then
        h = '0'..h
    end
    m = math.floor((time - h)*60)
    if math.floor(m / 10) == 0 then
        m = '0'..m
    end
    return (h..':'..m)
end

function irlTime()
    time = os.time("utc")
    h = math.floor(time)
    if math.floor(h / 10) == 0 then
        h = '0'..h
    end
    m = math.floor((time - h)*60)
    if math.floor(m / 10) == 0 then
        m = '0'..m
    end
    h = h + 3
    if h > 23 then
        h = h - 24
    end
    return (h..':'..m)
end

function getTOD()
    time = os.time("ingame")
    if time < 4 then
        return "night"
    elseif time < 6 then
        return "early morning"
    elseif time < 11 then
        return "morning"
    elseif time < 13 then
        return "noon"
    elseif time < 17 then
        return "afternoon"
    elseif time < 20 then
        return "early evening"
    elseif time < 22 then
        return "evening"
    elseif time > 22 then
        return "late evening"
    end
end


cycle = true
while cycle do
    if args[1] == "test" then
        cycle = false
    end
    monitor.clear()
    monitor.setTextScale(1)
    local width, heigth = monitor.getSize()
    local centerX = math.floor(width/2) + 1
    local centerY = math.floor(heigth/2)
    monitor.setCursorPos(centerX - 13, centerY - 4)
    gameTime():gsub(".", blitDigit)
    local tod = getTOD()
    monitor.setCursorPos(centerX - math.floor(tod:len() / 2), centerY + 3)
    monitor.write(tod)
    monitor.setTextColor(colors.gray)
    local irl = irlTime().." in Moscow"
    monitor.setCursorPos(centerX - math.floor(irl:len() / 2), centerY + 5)
    monitor.write(irl)
    sleep(0.4)
end
