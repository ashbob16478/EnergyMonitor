--Loads the touchpoint and input APIs
shell.run("cp /EnergyMonitor/config/touchpoint.lua /touchpoint")
os.loadAPI("touchpoint")
shell.run("rm touchpoint")


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


local currentPageId = 1
local totalPageCount = 10
local currentPage = touchpoint.new(_G.touchpointLocation)

print("THIS IS THE MONITOR PROGRAM!")

local function listen()
    -- Receive data from server
    while true do
        local clock = os.clock()
        local msg = _G.receiveMessage()

        if msg.type == _G.MessageType.Monitor and msg.sender == _G.Sender.Server then
            print(msg)

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
            end

            -- Write to terminal
            term.redirect(term.native())
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

local function setupMonitor() 
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

local function updateMonitorValues()
    while true do

        -- Header
        currentPage:setLabel("Energy", _G.numberToEnergyUnit(storedEnergy) .. "/" .. _G.numberToEnergyUnit(maxEnergy) .. " (" .. _G.formatDecimals(energyPercentage, 1) .. "%)")
        currentPage:setLabel("OutputRate", "Out: ".. _G.numberToEnergyUnit(inputRate) .. "/t")
        currentPage:setLabel("InputRate", "In: ".. _G.numberToEnergyUnit(outputRate) .. "/t")


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


---------------------------------------
-- ACTUAL SERVER PROGRAM STARTS HERE --
---------------------------------------

-- setup monitor gui
setupMonitor()

-- Run the pinger and the listener and monitor updaters in parallel
parallel.waitForAll(listen, updateMonitorValues, touchListener)


-------------------------------------
-- ACTUAL SERVER PROGRAM ENDS HERE --
-------------------------------------