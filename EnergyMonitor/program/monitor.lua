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
local cellSpacing = 1

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
local flex = main:addFlexbox():setWrap("wrap"):setBackground(colors.red):setPosition(1, 1):setSize("parent.w", "parent.h"):setDirection("column"):setSpacing(0)

-- frame that contains the header (energy stored, input/output rates)
local header = flex:addFrame():setBackground(headerColor):setSize("parent.w", headerHeight)

-- flexbox that contains the individual energy meter displays
local main = flex:addFlexbox():setWrap("wrap"):setBackground(bgColor):setSize("parent.w", "parent.h" .. "-" .. headerHeight + footerHeight + versionFooterHeight):setSpacing(cellSpacing):setJustifyContent("center")--:setOffset(-1, 0) --:setJustifyContent("space-evenly")

-- frame that contains the footer (previous, next, page number)
local footer = flex:addFrame():setBackground(footerColor):setSize("parent.w", footerHeight)
local versionFooter = flex:addFrame():setBackground(versionFooterColor):setSize("parent.w", 1)

-- amount of cells per page
local flexWidth, flexHeight = main:getSize()
local numCellsRow = math.floor((flexWidth + cellSpacing) / (cellWidth + cellSpacing))
local numCellsCol = math.floor((flexHeight + cellSpacing) / (cellHeight + cellSpacing))
local totalCellsPerPage = numCellsRow * numCellsCol


local pageLbl = {}

local energyLbl = {}
local energyBar = {}

local rateLblIn = {}
local rateLblOut = {}


-- GUI COMPONENTS END


local currentPageId = 1
local totalPageCount = 1

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

local function showPage()
    -- iterate over table with displays and hide all except the ones that are on the current page
    local startIdx = (currentPageId - 1) * totalCellsPerPage + 1
    local endIdx = currentPageId * totalCellsPerPage
    local currIdx = 1

    for k,v in pairs(displayCells) do
        if currIdx >= startIdx and currIdx <= endIdx then
            v.displayFrm:setVisible(true)
        else
            v.displayFrm:setVisible(false)
        end
        currIdx = currIdx + 1
    end
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

        showPage()
    else
        -- update values stored in table
        displayCells[peripheralId].clientInfo = energyMeters[peripheralId]
    end
end

local function removeDisplayCell(peripheralId)
    -- remove display cell from the monitor
    if displayCells[peripheralId] ~= nil then
        displayCells[peripheralId].displayFrm:remove()
        displayCells[peripheralId] = nil

        showPage()
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

local function updatePageCount()
    totalPageCount = math.ceil(energyMetersCount / totalCellsPerPage)
    pageLbl:setText("Page: " .. currentPageId .. "/" .. totalPageCount)

    -- set currentPageId to last page if last page got deleted
    if currentPageId > totalPageCount then
        -- currentPageId = totalPageCount
        -- DOES NOT WORK CORRECTLY TODO
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
        updatePageCount()

        os.sleep(0.1)
    end
end

local function nextPage()
    if currentPageId < totalPageCount then
        currentPageId = currentPageId + 1
        showPage()
    end
end

local function prevPage()
    if currentPageId > 1 then
        currentPageId = currentPageId - 1
        showPage()
    end
end

local function setupMonitor()
    -- setup header
    energyLbl = header:addLabel():setText("Energy: STORED"):setFontSize(1):setSize("parent.w / 2", 1):setPosition(0, 1):setTextAlign("center")
    energyBar = header:addProgressbar():setProgress(0):setSize("parent.w / 3", 1):setPosition("1/12 * parent.w", 3):setProgressBar(colors.lime):setDirection("right"):setBackground(colors.black)
    rateLblIn = header:addLabel():setText("Transfer: IN"):setFontSize(1):setSize("parent.w / 3", 1):setPosition("2 * parent.w / 3", 1):setTextAlign("left")
    rateLblOut = header:addLabel():setText("Transfer: OUT" ):setFontSize(1):setSize("parent.w / 3", 1):setPosition(" 2 * parent.w / 3", 2):setTextAlign("left")

    
    -- setup footer
    footer:addButton():setText("Prev"):setSize(btnWidth, btnHeight):setPosition(2, math.ceil(footerHeight / 2) + math.floor(btnHeight / 2)):onClick(prevPage)
    pageLbl = footer:addLabel():setText("Page: 0/0"):setFontSize(1):setSize(lblWidth,lblHeight):setPosition("(parent.w / 2) - " .. (lblWidth / 2), math.ceil(footerHeight / 2) + math.floor(btnHeight / 2)):setTextAlign("center")
    footer:addButton():setText("Next"):setSize(btnWidth, btnHeight):setPosition("parent.w-"..btnWidth, math.ceil(footerHeight / 2) + math.floor(btnHeight / 2)):onClick(nextPage)
    versionFooter:addLabel():setText("version: " .. _G.version):setFontSize(1):setSize("parent.w", 1):setPosition(0, versionFooterHeight):setTextAlign("right"):setForeground(colors.gray)


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