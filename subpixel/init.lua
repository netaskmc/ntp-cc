local asciiOffset = tonumber("0x80")

local function errorIfStrNotBits(str)
    for i = 1, #str do
        local char = str:sub(i, i)
        if char ~= "0" and char ~= "1" then
            error("Expected a string of bits, but found '" .. char .. "' at index " .. i)
        end
    end
end

local function flipString(str)
    local result = ""
    for i = 1, #str do
        result = str:sub(i, i) .. result
    end
    return result
end

local function fromBitString(str)
    errorIfStrNotBits(str)
    if #str ~= 6 then
        error("Expected 6 bits, but found " .. #str .. " bits instead")
    end

    local inverted = false
    local offset = tonumber(flipString(str), 2)
    if offset > 31 then
        offset = 63 - offset
        inverted = true
    end
    local charcode = offset + asciiOffset
    
    return string.char(charcode), inverted
end

local function fromBitTable(tbl)
    local str = ""
    for i = 1, #tbl do
        local bit = 1
        if tbl[i] == 0 or tbl[i] == "" or tbl[i] == false then
            bit = 0
        end
        str = str .. bit
    end
    return fromBitString(str)
end

local function divideTable(tbl, cols)
    local rows = #tbl / cols / 6
    if rows % 1 ~= 0 then
        error("Table can not be divided into 2x3 pixel chunks, as it'll have " .. rows .. " (nonint) rows with width " .. cols)
    end

    local result = {}
    for i = 0, rows * cols - 1 do
        local x = i % cols
        local y = math.floor(i / cols)

        local xOff = x * 2
        local yOff = y * 6 * cols
        local char = {
            tbl[xOff + yOff              + 1], tbl[xOff + yOff              + 2],
            tbl[xOff + yOff + (cols * 2) + 1], tbl[xOff + yOff + (cols * 2) + 2],
            tbl[xOff + yOff + (cols * 4) + 1], tbl[xOff + yOff + (cols * 4) + 2]
        }
        table.insert(result, char)
    end

    return result
end

local function mapChars(tbl)
    local result = {}
    for i = 1, #tbl do
        local char, inverted = fromBitTable(tbl[i])
        table.insert(result, {
            char = char,
            inverted = inverted
        })
    end
    return result
end

local function renderToBlitFormat(tbl, width, bg, fg)
    if tbl == nil then error("expected table as 2nd arg") end
    if width == nil then error("expected width as 3rd arg") end
    if bg == nil then bg = "f" end
    if fg == nil then fg = "0" end

    local chars = mapChars(divideTable(tbl, width))

    local result = {}
    for row = 1, #chars / width do
        local text = ""
        local bgc = ""
        local fgc = ""
        for col = 1, width do
            local char = chars[(row - 1) * width + col]
            text = text .. char.char
            if char.inverted then
                bgc = bgc .. fg
                fgc = fgc .. bg
            else
                bgc = bgc .. bg
                fgc = fgc .. fg
            end
        end
        table.insert(result, {
            text = text,
            fg = fgc,
            bg = bgc
        })
    end
    
    return result
end

local function render(ctx, tbl, width, bg, fg)
    if ctx == nil then error("expected render context as 1st arg") end

    local blitFmt = renderToBlitFormat(tbl, width, bg, fg)
    local x, y = ctx.getCursorPos()
    for i, b in pairs(blitFmt) do
        ctx.blit(b.text, b.fg, b.bg)
        ctx.setCursorPos(x, y + i)
    end
end

return {
    renderToBlitFormat = renderToBlitFormat,
    render = render
}
