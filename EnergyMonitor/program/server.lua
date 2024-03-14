--Loads the touchpoint and input APIs
shell.run("cp /EnergyMonitor/config/touchpoint.lua /touchpoint")
os.loadAPI("touchpoint")
shell.run("rm touchpoint")


local timeout = 5
local clientInfo = {
    id = "",
    name = "",
    type = "",
    data = {},
    lastPing = "",
}
local connectedClients = {}
local capacitors = {}
local energyMeters = {}
local connectedClientsCount = 0
local capacitorsCount = 0
local energyMetersCount = 0
local debugPrint = false


local function totalEnergy()
    local total = 0
    for k, v in pairs(capacitors) do
        total = total + v.data.energy
    end
    return total
end

local function totalMaxEnergy()
    local total = 0
    for k, v in pairs(capacitors) do
        total = total + v.data.maxEnergy
    end
    return total
end

local function energyPercentage()
    return totalEnergy() / totalMaxEnergy() * 100
end

local function addClient(client) 
    -- add client to connectedClients
    if connectedClients[client.id] ~= nil then
        -- update client
        connectedClients[client.id] = client

        if (capacitors[client.id] ~= nil) then
            capacitors[client.id] = client
        elseif (energyMeters[client.id] ~= nil) then
            energyMeters[client.id] = client
        end
    else
        -- add client
        connectedClients[client.id] = client
        connectedClientsCount = connectedClientsCount + 1

        -- add clientid to respective list
        if client.type == _G.MessageDataPeripheral.EnergyMeter then
            energyMeters[client.id] = client
            energyMetersCount = energyMetersCount + 1
        elseif client.type == _G.MessageDataPeripheral.Capacitor then
            capacitors[client.id] = client
            capacitorsCount = capacitorsCount + 1
        end
    end
end

local function dropNotRespondingClients()
    -- remove client from connectedClients if lastPing is older than timeout
    for k, v in pairs(connectedClients) do
        if os.clock() - v.lastPing > timeout then
            connectedClients[k] = nil
            connectedClientsCount = connectedClientsCount - 1

            -- remove clientid from respective list
            if v.type == _G.MessageDataPeripheral.EnergyMeter then
                energyMeters[k] = nil
                energyMetersCount = energyMetersCount - 1
            elseif v.type == _G.MessageDataPeripheral.Capacitor then
                capacitors[k] = nil
                capacitorsCount = capacitorsCount - 1
            end
        end
    end
end

print("THIS IS THE SERVER PROGRAM!")

local function ping_clients()
    while true do
        term.clear()
        term.setCursorPos(1,1)


        -- Send ping to all connected clients
        print(os.clock())
        print("Sending a ping to all clients on channel: ".._G.modemChannel)

        local msg = _G.NewPingFromServer()
        _G.sendMessage(msg)


        -- Remove clients that are not responding
        dropNotRespondingClients()

        -- needed since otherwise no yield detected in parallel.waitForAll
        os.sleep(0.1)
    end
end

local function listen()
    -- Receive data from all connected clients
    while true do
        local clock = os.clock()
        local msg = _G.receiveMessage()
        local client = {}
        setmetatable(client, {__index = clientInfo})

        if msg.type == _G.MessageType.Update then
            -- Write to monitor

            -- extract data from message and setup clientInfo
            local data = msg.messageData.data
            client.id = data.id
            client.name = data.name
            client.data = data
            client.type = msg.messageData.peripheral
            client.lastPing = clock

            -- add client as connected
            addClient(client)

            if debugPrint then
                term.redirect(_G.controlMonitor)
                term.clear()
                term.setCursorPos(1,1)
                print(clock)
                print("Type: " .. _G.parsePeripheralType(msg.messageData.peripheral)) 
            end
            
            if msg.messageData.peripheral == _G.MessageDataPeripheral.EnergyMeter then
                if debugPrint then
                    print("Client: "..data.name)
                    print("ID: "..data.id)
                    print("Transfer: "..data.transfer)
                    print("Mode: "..data.mode)
                    print("Status: "..data.status)
                end
            elseif msg.messageData.peripheral == _G.MessageDataPeripheral.Capacitor then
                if debugPrint then
                    print("Client: "..data.name)
                    print("ID: "..data.id)
                    print("Energy: "..data.energy)
                    print("MaxEnergy: "..data.maxEnergy)
                    print("Filled: "..math.floor(data.energy / data.maxEnergy * 100) .. "%")
                    print("Status: "..data.status)
                end
            end

            if debugPrint then
                print("Connected clients: "..connectedClientsCount)
                print("Energy Meters: "..energyMetersCount)
                print("Capacitors: "..capacitorsCount)

                -- Write to terminal
                term.redirect(term.native())
            end
        end
    end
end

local function toggle(page, button)
    --toggle redstone output on front of computer
    page:toggleButton(button)
    rs.setOutput("front", not rs.getOutput("front"))
end




    local pages = {}
    local currentPageId = 1
    local totalPageCount = 1
    local currentPage = {}
    
    currentPage = touchpoint.new(_G.touchpointLocation)
    pages[currentPageId] = currentPage


local function setupMonitor() 
    _G.controlMonitor.setTextScale(0.5)

    local monWidth,monHeight = _G.controlMonitor.getSize()
    monWidth = monWidth
    monHeight = monHeight - 1




    ------------------------------
    -- Capacitor Energy Display --
    ------------------------------

    local capWidth = 30
    local capHeight = 2

    local capMinX = 2
    local capMinY = 2
    local capMaxX = capWidth + capMinX
    local capMaxY = capHeight + capMinY

    
    currentPage:add("Energy", function() end, capMinX, capMinY, capMaxX, capMaxY, colors.red, colors.lime)
    currentPage:setLabel("Energy", "-1")
    print(totalPageCount)




    ---------------------------------------
    -- footer buttons offsets/dimensions --
    ---------------------------------------

    local btnWidth = 5
    local btnHeight = 0
    local btnOffsetBorder = 2

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
    currentPage:add("Prev", function() toggle(currentPage, "Prev") end, pMinX, pMinY, pMaxX, pMaxY, colors.red, colors.lime)
    currentPage:add("Next", function() toggle(currentPage, "Next") end, nMinX, nMinY, nMaxX, nMaxY, colors.red, colors.lime)
    currentPage:add("Page " .. currentPageId .. "/" .. totalPageCount, function() end, lMinX, lMinY, lMaxX, lMaxY, colors.red, colors.lime)

    
    currentPage:draw()
end


local function updateMonitorValues()
    while true do

        currentPage:setLabel("Energy", _G.numberToEnergyUnit(totalEnergy()) .. "/" .. _G.numberToEnergyUnit(totalMaxEnergy()) .. " (" .. _G.formatDecimals(energyPercentage(), 1) .. "%)")

        os.sleep(0.1)
    end
end

local function touchListener()
    currentPage:run()
end




---------------------------------------
-- ACTUAL SERVER PROGRAM STARTS HERE --
---------------------------------------


-- Run the pinger and the listener in parallel
setupMonitor()
parallel.waitForAll(listen, ping_clients, updateMonitorValues, touchListener)


-------------------------------------
-- ACTUAL SERVER PROGRAM ENDS HERE --
-------------------------------------