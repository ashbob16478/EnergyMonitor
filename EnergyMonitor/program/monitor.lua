local basalt = require("basalt")

local displayData = {
    clientInfo = {},
    displayFrm = {},
    dpName = "",
    dpRate = "",
    dpType = "",
    dpState = ""
}

local capacitors = {}
local capacitorsCount = 0
local energyMeters = {}
local energyMetersCount = 0
local storedEnergy = 0
local maxEnergy = 0
local energyPercentage = 0
local inputRate = 0
local outputRate = 0

local debugPrint = false

-- table contrains energyMeters[i].id as key and the value is the displayData{clientInfo = energyMeters[i], display = already created frame}
local displayCells = {}
setmetatable(displayCells, {__index = "displayData"})


-- GUI COMPONENT SETTINGS

local headerHeight = 4
local footerHeight = 3
local versionFooterHeight = 1

local btnWidth,btnHeight = 6,1

-- prev/next button, page lbl size
local lblWidth,lblHeight = 20, btnHeight

local cellWidth, cellHeight = 18, 6
local cellBackground = colors.yellow

local headerColor = colors.blue
local bgColor = colors.black
local footerColor = colors.green
local versionFooterColor = colors.lightBlue

if true then
    local c = colors.lightGray
    headerColor = c
    bgColor = c
    footerColor = c
end

-- GUI COMPONENT SETTINGS END



-- GUI COMPONENTS

local main = basalt.addMonitor()
main:setMonitor(_G.controlMonitor)

-- default content pane
local flex = main:addFlexbox():setWrap("wrap"):setBackground(colors.red):setPosition(2, 1):setSize("parent.w-2", "parent.h"):setDirection("column"):setSpacing(0)

-- frame that contains the header (energy stored, input/output rates)
local header = flex:addFrame():setBackground(headerColor):setSize("parent.w", headerHeight)

-- flexbox that contains the individual energy meter displays
local main = flex:addFlexbox():setWrap("wrap"):setBackground(bgColor):setSize("parent.w", "parent.h" .. "-" .. headerHeight + footerHeight + versionFooterHeight):setSpacing(1) --:setJustifyContent("space-evenly")

-- frame that contains the footer (previous, next, page number)
local footer = flex:addFrame():setBackground(footerColor):setSize("parent.w", footerHeight)
local versionFooter = flex:addFrame():setBackground(versionFooterColor):setSize("parent.w", 1)

local pageLbl = {}

local energyLbl = {}
local energyBar = {}

local rateLblIn = {}
local rateLblOut = {}


-- GUI COMPONENTS END


local currentPageId = 1
local totalPageCount = 0

print("THIS IS THE MONITOR PROGRAM!")

local function listen()
    -- Receive data from server
    while true do
        local clock = os.clock()
        local msg = _G.receiveMessage()

        if debugPrint then
            term.redirect(term.native())
            term.clear()
            term.setCursorPos(1,1)
            print(clock)
            print("Receiving monitor data from server on channel: ".._G.modemChannel)
        end

        if msg.type == _G.MessageType.Monitor and msg.sender == _G.Sender.Server then

            -- extract data from message
            local data = msg.messageData.data

            capacitors = data.capacitors
            capacitorsCount = data.capacitorsCount
            energyMeters = data.energyMeters
            energyMetersCount = data.energyMetersCount
            storedEnergy = data.storedEnergy
            maxEnergy = data.maxEnergy
            energyPercentage = data.energyPercentage
            inputRate = data.inputRate
            outputRate = data.outputRate

            if debugPrint then
                term.redirect(_G.controlMonitor)
                term.clear()
                term.setCursorPos(1,1)
                print(clock)
                print("Type: " .. _G.parsePeripheralType(msg.messageData.peripheral)) 

                -- Write to terminal
            term.redirect(term.native())
            end
        end
    end
end

local function changePage(button)
    currentPage:flash(button, 0.2)

    if button == "Prev" then
        if currentPageId > 1 then
            currentPageId = currentPageId - 1
        end
    elseif button == "Next" then
        if currentPageId < totalPageCount then
            currentPageId = currentPageId + 1
        end
    end
end

local function setupMonitorOLD() 
    local monWidth,monHeight = _G.controlMonitor.getSize()
    monWidth = monWidth
    monHeight = monHeight - 1
    local btnOffsetBorder = 2


    ------------------------------------
    -- Total Capacitor Energy Display --
    ------------------------------------

    local capWidth = 30
    local capHeight = 2

    local capMinX = btnOffsetBorder
    local capMinY = btnOffsetBorder
    local capMaxX = capWidth + capMinX
    local capMaxY = capHeight + capMinY
    local lh = 3
    
    currentPage:add("Energy Stored:", function() end, capMinX, capMinY, capMaxX, capMaxY, colors.red, colors.lime)
    currentPage:add("Energy", function() end, capMinX, capMinY + lh, capMaxX, capMaxY + lh, colors.red, colors.lime)



    ----------------------------------------
    -- Total EnergyMeter Transfer Display --
    ----------------------------------------

    local trnsfWidth = 30
    local trnsfHeight = 2

    local trnsfMinX = monWidth - btnOffsetBorder - trnsfWidth
    local trnsfMinY = btnOffsetBorder
    local trnsfMaxX = monWidth - btnOffsetBorder
    local trnsfMaxY = trnsfHeight + trnsfMinY
    local lh = 3

    currentPage:add("OutputRate", function() end, trnsfMinX, trnsfMinY, trnsfMaxX, trnsfMaxY, colors.red, colors.lime)
    currentPage:add("InputRate", function() end, trnsfMinX, trnsfMinY + lh, trnsfMaxX, trnsfMaxY + lh, colors.red, colors.lime)




    -------------------------------
    -- EnergyMeter Display Cells --
    -------------------------------
    local vertOffset = capMaxY + lh + 4
    local horiOffset = 5

    ---------------
    -- DISPLAY 1 --
    ---------------

    local dpWidth = 15
    local dpHeight = 2

    dp1MinX1 = btnOffsetBorder
    dp1MinY1 = vertOffset
    dp1MaxX1 = dpWidth + dp1MinX1
    dp1MaxY1 = dpHeight + dp1MinY1

    dp1MinX2 = dp1MinX1
    dp1MinY2 = dp1MaxY1 + 1
    dp1MaxX2 = dpWidth + dp1MinX2
    dp1MaxY2 = dpHeight + dp1MinY2

    dp1MinX3 = dp1MinX2
    dp1MinY3 = dp1MaxY2 + 1
    dp1MaxX3 = dpWidth + dp1MinX3
    dp1MaxY3 = dpHeight + dp1MinY3

    currentPage:add("Display1Name", function() end, dp1MinX1, dp1MinY1, dp1MaxX1, dp1MaxY1, colors.red, colors.lime)
    currentPage:add("Display1Rate", function() end, dp1MinX2, dp1MinY2, dp1MaxX2, dp1MaxY2, colors.red, colors.lime)
    currentPage:add("Display1State", function() end, dp1MinX3, dp1MinY3, dp1MaxX3, dp1MaxY3, colors.red, colors.lime)


    ---------------
    -- DISPLAY 2 --
    ---------------

    dp2MinX1 = dp1MaxX1 + horiOffset
    dp2MinY1 = vertOffset
    dp2MaxX1 = dpWidth + dp2MinX1
    dp2MaxY1 = dpHeight + dp2MinY1

    dp2MinX2 = dp2MinX1
    dp2MinY2 = dp2MaxY1 + 1
    dp2MaxX2 = dpWidth + dp2MinX2
    dp2MaxY2 = dpHeight + dp2MinY2

    dp2MinX3 = dp2MinX2
    dp2MinY3 = dp2MaxY2 + 1
    dp2MaxX3 = dpWidth + dp2MinX3
    dp2MaxY3 = dpHeight + dp2MinY3

    currentPage:add("Display2Name", function() end, dp2MinX1, dp2MinY1, dp2MaxX1, dp2MaxY1, colors.red, colors.lime)
    currentPage:add("Display2Rate", function() end, dp2MinX2, dp2MinY2, dp2MaxX2, dp2MaxY2, colors.red, colors.lime)
    currentPage:add("Display2State", function() end, dp2MinX3, dp2MinY3, dp2MaxX3, dp2MaxY3, colors.red, colors.lime)


    ---------------
    -- DISPLAY 3 --
    ---------------

    dp3MinX1 = dp2MaxX1 + horiOffset
    dp3MinY1 = vertOffset
    dp3MaxX1 = dpWidth + dp3MinX1
    dp3MaxY1 = dpHeight + dp3MinY1

    dp3MinX2 = dp3MinX1
    dp3MinY2 = dp3MaxY1 + 1
    dp3MaxX2 = dpWidth + dp3MinX2
    dp3MaxY2 = dpHeight + dp3MinY2

    dp3MinX3 = dp3MinX2
    dp3MinY3 = dp3MaxY2 + 1
    dp3MaxX3 = dpWidth + dp3MinX3
    dp3MaxY3 = dpHeight + dp3MinY3

    currentPage:add("Display3Name", function() end, dp3MinX1, dp3MinY1, dp3MaxX1, dp3MaxY1, colors.red, colors.lime)
    currentPage:add("Display3Rate", function() end, dp3MinX2, dp3MinY2, dp3MaxX2, dp3MaxY2, colors.red, colors.lime)
    currentPage:add("Display3State", function() end, dp3MinX3, dp3MinY3, dp3MaxX3, dp3MaxY3, colors.red, colors.lime)


    ---------------
    -- DISPLAY 4 --
    ---------------

    dp4MinX1 = dp3MaxX1 + horiOffset
    dp4MinY1 = vertOffset
    dp4MaxX1 = dpWidth + dp4MinX1
    dp4MaxY1 = dpHeight + dp4MinY1

    dp4MinX2 = dp4MinX1
    dp4MinY2 = dp4MaxY1 + 1
    dp4MaxX2 = dpWidth + dp4MinX2
    dp4MaxY2 = dpHeight + dp4MinY2

    dp4MinX3 = dp4MinX2
    dp4MinY3 = dp4MaxY2 + 1
    dp4MaxX3 = dpWidth + dp4MinX3
    dp4MaxY3 = dpHeight + dp4MinY3

    currentPage:add("Display4Name", function() end, dp4MinX1, dp4MinY1, dp4MaxX1, dp4MaxY1, colors.red, colors.lime)
    currentPage:add("Display4Rate", function() end, dp4MinX2, dp4MinY2, dp4MaxX2, dp4MaxY2, colors.red, colors.lime)
    currentPage:add("Display4State", function() end, dp4MinX3, dp4MinY3, dp4MaxX3, dp4MaxY3, colors.red, colors.lime)




    ---------------------------------------
    -- footer buttons offsets/dimensions --
    ---------------------------------------

    local btnWidth = 5
    local btnHeight = 0

    pMinX = btnOffsetBorder
    pMinY = monHeight - btnHeight
    pMaxX = btnWidth + btnOffsetBorder
    pMaxY = monHeight

    nMinX = monWidth - btnOffsetBorder - btnWidth
    nMinY = monHeight - btnHeight
    nMaxX = monWidth - btnOffsetBorder
    nMaxY = monHeight
    

    local lblWidth = 11
    local lblHeight = 0

    lMinX = (monWidth - lblWidth) / 2
    lMinY = monHeight - lblHeight
    lMaxX = (monWidth + lblWidth) / 2
    lMaxY = monHeight
    
    --# coordinates are minX, minY, maxX, maxY. The button will be drawn from (minX, minY) to (maxX, maxY)
    currentPage:add("Prev", function() changePage("Prev") end, pMinX, pMinY, pMaxX, pMaxY, colors.red, colors.lime)
    currentPage:add("Next", function() changePage("Next") end, nMinX, nMinY, nMaxX, nMaxY, colors.red, colors.lime)
    currentPage:add("Page", function() end, lMinX, lMinY, lMaxX, lMaxY, colors.red, colors.lime)

    
    currentPage:draw()
end

local function updateMonitorValuesOLD()
    while true do

        -- Header
        currentPage:setLabel("Energy", _G.numberToEnergyUnit(storedEnergy) .. "/" .. _G.numberToEnergyUnit(maxEnergy) .. " (" .. _G.formatDecimals(energyPercentage, 1) .. "%)")
        currentPage:setLabel("OutputRate", "Out: ".. _G.numberToEnergyUnit(outputRate) .. "/t")
        currentPage:setLabel("InputRate", "In: ".. _G.numberToEnergyUnit(inputRate) .. "/t")


        -- Footer
        currentPage:setLabel("Page", "Page: " .. currentPageId .. "/" .. totalPageCount)


        -- EnergyMeter Display Values
        local meters = energyMeters
        table.sort(meters, function(a,b) return a.name < b.name end)
        local metersWithIdx = {}
        local idx = 0
        
        for k, v in pairs(meters) do
            idx = idx + 1
            metersWithIdx[idx] = v
        end
        local meterCount = energyMetersCount
        totalPageCount = math.ceil(meterCount / 4)

        -- meters for every display
        local dp1 = metersWithIdx[currentPageId * 4 - 3]
        local dp2 = metersWithIdx[currentPageId * 4 - 2]
        local dp3 = metersWithIdx[currentPageId * 4 - 1]
        local dp4 = metersWithIdx[currentPageId * 4]

        -- display values
        if dp1 ~= nil then
            currentPage:setLabel("Display1Name", dp1.name)
            currentPage:setLabel("Display1Rate", _G.numberToEnergyUnit(dp1.data.transfer) .. "/t")
            currentPage:setLabel("Display1State", _G.parseMeterType(dp1.data.meterType))
        else
            currentPage:setLabel("Display1Name", "N/A")
            currentPage:setLabel("Display1Rate", "N/A")
            currentPage:setLabel("Display1State", "N/A")
        end

        if dp2 ~= nil then
            currentPage:setLabel("Display2Name", dp2.name)
            currentPage:setLabel("Display2Rate", _G.numberToEnergyUnit(dp2.data.transfer) .. "/t")
            currentPage:setLabel("Display2State", _G.parseMeterType(dp2.data.meterType))
        else
            currentPage:setLabel("Display2Name", "N/A")
            currentPage:setLabel("Display2Rate", "N/A")
            currentPage:setLabel("Display2State", "N/A")
        end

        if dp3 ~= nil then
            currentPage:setLabel("Display3Name", dp3.name)
            currentPage:setLabel("Display3Rate", _G.numberToEnergyUnit(dp3.data.transfer) .. "/t")
            currentPage:setLabel("Display3State", _G.parseMeterType(dp3.data.meterType))
        else
            currentPage:setLabel("Display3Name", "N/A")
            currentPage:setLabel("Display3Rate", "N/A")
            currentPage:setLabel("Display3State", "N/A")
        end

        if dp4 ~= nil then
            currentPage:setLabel("Display4Name", dp4.name)
            currentPage:setLabel("Display4Rate", _G.numberToEnergyUnit(dp4.data.transfer) .. "/t")
            currentPage:setLabel("Display4State", _G.parseMeterType(dp4.data.meterType))
        else
            currentPage:setLabel("Display4Name", "N/A")
            currentPage:setLabel("Display4Rate", "N/A")
            currentPage:setLabel("Display4State", "N/A")
        end


        os.sleep(0.1)
    end
end

local function touchListener()
    currentPage:run()
end

local function addDisplayCell(peripheralId)
    -- add display cell to the monitor
    if displayCells[peripheralId] == nil then
        local frm = main:addFrame():setBackground(cellBackground):setSize(cellWidth, cellHeight)
        
        displayCells[peripheralId] = {
            clientInfo = energyMeters[peripheralId],
            displayFrm = frm,
            dpName = frm:addLabel():setText(energyMeters[peripheralId].name):setFontSize(1):setSize("parent.w-1", 1):setPosition(2, 2):setTextAlign("center"),
            dpRate = frm:addLabel():setText(_G.numberToEnergyUnit(energyMeters[peripheralId].data.transfer) .. "/t"):setFontSize(1):setSize("parent.w-1", 1):setPosition(2, 3):setTextAlign("center"),
            dpType = frm:addLabel():setText(_G.parseMeterType(energyMeters[peripheralId].data.meterType)):setFontSize(1):setSize("parent.w-1", 1):setPosition(2, 4):setTextAlign("center"),
            --dpState = frm:addLabel():setText("State: " .. energyMeters[peripheralId].data.state):setFontSize(1):setSize("parent.w-1", 1):setPosition(2, 5):setTextAlign("center")
        }
    else
        -- update values stored in table
        displayCells[peripheralId].clientInfo = energyMeters[peripheralId]
    end
end

local function removeDisplayCell(peripheralId)
    -- remove display cell from the monitor
    if displayCells[peripheralId] ~= nil then
        displayCells[peripheralId].dpName:remove()
        displayCells[peripheralId].dpRate:remove()
        displayCells[peripheralId].dpType:remove()
        --displayCells[peripheralId].dpState:remove()
        displayCells[peripheralId].displayFrm:remove()
        displayCells[peripheralId] = nil
    end
end

local function updateEnergyDisplay()
    energyLbl:setText("Energy: " .. _G.numberToEnergyUnit(storedEnergy) .. "/" .. _G.numberToEnergyUnit(maxEnergy) .. " (" .. _G.formatDecimals(energyPercentage, 1) .. "%)")
    energyBar:setProgress(tonumber(_G.formatDecimals(energyPercentage, 0)))
end

local function updateTransferDisplay()
    rateLblIn:setText("Transfer IN: " .. _G.numberToEnergyUnit(inputRate) .. "/t")
    rateLblOut:setText("Transfer OUT: " .. _G.numberToEnergyUnit(outputRate) .. "/t")
end

local function updateDisplayCells()
    for k,v in pairs(displayCells) do
        local i = v.clientInfo
        local d = i.data
        displayCells[k].dpName:setText(d.name)
        displayCells[k].dpRate:setText(_G.numberToEnergyUnit(d.transfer) .. "/t")
        displayCells[k].dpType:setText(_G.parseMeterType(d.meterType))
        --displayCells[k].dpState:setText("State: " .. d.state)
    end
end

local function updateMonitorValues()
    while true do

        -- iterate over all energy meters and add them to the display
        for k,v in pairs(energyMeters) do
            addDisplayCell(k)
        end

        -- remove all energy meters that are not in the received data
        for k,v in pairs(displayCells) do
            if energyMeters[k] == nil then
                removeDisplayCell(k)
            end
        end

        updateEnergyDisplay()
        updateTransferDisplay()
        updateDisplayCells()

        os.sleep(0.1)
    end
end

local function setupMonitor()
    -- setup header
    energyLbl = header:addLabel():setText("Energy: STORED"):setFontSize(1):setSize("parent.w / 2", 1):setPosition(0, 1):setTextAlign("center")
    energyBar = header:addProgressbar():setProgress(0):setSize("parent.w / 3", 1):setPosition("1/12 * parent.w", 3):setProgressBar(colors.lime):setDirection("right"):setBackground(colors.black)
    rateLblIn = header:addLabel():setText("Transfer: IN"):setFontSize(1):setSize("parent.w / 3", 1):setPosition("2 * parent.w / 3", 1):setTextAlign("left")
    rateLblOut = header:addLabel():setText("Transfer: OUT" ):setFontSize(1):setSize("parent.w / 3", 1):setPosition(" 2 * parent.w / 3", 2):setTextAlign("left")

    
    -- setup footer
    footer:addButton():setText("Prev"):setSize(btnWidth, btnHeight):setPosition(2, math.ceil(footerHeight / 2) + math.floor(btnHeight / 2))
    pageLbl = footer:addLabel():setText("Page: 1/1"):setFontSize(1):setSize(lblWidth,lblHeight):setPosition("(parent.w / 2) - " .. (lblWidth / 2), math.ceil(footerHeight / 2) + math.floor(btnHeight / 2)):setTextAlign("center")
    footer:addButton():setText("Next"):setSize(btnWidth, btnHeight):setPosition("parent.w-"..btnWidth, math.ceil(footerHeight / 2) + math.floor(btnHeight / 2))
    versionFooter:addLabel():setText("version: " .. _G.version):setFontSize(1):setSize("parent.w", 1):setPosition(0, versionFooterHeight):setTextAlign("right"):setForeground(colors.gray)

    -- setup display cells (each cell is one frame)
    -- for k,v in pairs(energyMeters) add display cell and store it in a new table
    -- check on listen if there is a new energy meter which is not stored locally and thus add it to the table and the display
    -- check on listen if there is an energy meter which is stored locally but not in the received data and thus remove it from the table and the display
    -- eg. by subtracting local table from remote table to get the disconnected devices
    -- eg. by subtracting remote table from local table to get the newly added devices

    -- OR by creating table with peripheralId as key and the value is the frame object and on listen check for every received energy meter if it is already stored in the table and if not add it to the table and the display. If it is stored in the table, update the display values. If it is not in the remote table but in the local table, remove it from the table and the display

    --local display1 = main:addFrame():setBackground(colors.yellow):setSize(displayWidth, displayHeight)
    for i=0, 20 do
        --addDisplayCell(i)
    end
    --main:addButton():setSize(15,4)
    --main:addButton():setSize(15,4)
    --main:addButton():setFlexBasis(1):setFlexGrow(1)
    --main:addButton():setFlexBasis(1):setFlexGrow(1)
    --main:addButton():setFlexBasis(1):setFlexGrow(1)
    --main:addButton():setFlexBasis(1):setFlexGrow(1)
    --main:addButton():setFlexBasis(1):setFlexGrow(1)
    --main:addButton():setFlexBasis(1):setFlexGrow(1)
    




    -- auto update the monitor
    basalt.autoUpdate()
end

---------------------------------------
-- ACTUAL SERVER PROGRAM STARTS HERE --
---------------------------------------

-- setup monitor gui

-- Run the pinger and the listener and monitor updaters in parallel
parallel.waitForAll(setupMonitor, listen, updateMonitorValues)


-------------------------------------
-- ACTUAL SERVER PROGRAM ENDS HERE --
-------------------------------------