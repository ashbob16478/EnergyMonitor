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
        total = total + _G.defaultNan(v.data.energy, 0)
    end
    return total
end

local function totalMaxEnergy()
    local total = 0
    for k, v in pairs(capacitors) do
        total = total + _G.defaultNan(v.data.maxEnergy, 0)
    end
    return total
end

local function energyPercentage()
    return _G.defaultNan(totalEnergy() / totalMaxEnergy(), 0) * 100
end

local function totalOutputRate()
    local total = 0
    for k, v in pairs(energyMeters) do
        if v.data.meterType == _G.MeterType.using then
            total = total + v.data.transfer
        end
    end
    return total
end

local function totalInputRate()
    local total = 0
    for k, v in pairs(energyMeters) do
        if v.data.meterType == _G.MeterType.providing then
            total = total + v.data.transfer
        end
    end
    return total
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
                debugOutput("Client: "..data.name)
                debugOutput("ID: "..data.id)
                debugOutput("Transfer: "..data.transfer)
                debugOutput("Mode: "..data.mode)
                debugOutput("Status: "..data.status)
            elseif msg.messageData.peripheral == _G.MessageDataPeripheral.Capacitor then
                debugOutput("Client: "..data.name)
                debugOutput("ID: "..data.id)
                debugOutput("Energy: "..data.energy)
                debugOutput("MaxEnergy: "..data.maxEnergy)
                debugOutput("Filled: "..math.floor(data.energy / data.maxEnergy * 100) .. "%")
                debugOutput("Status: "..data.status)
            end

            debugOutput("Connected clients: "..connectedClientsCount)
            debugOutput("Energy Meters: "..energyMetersCount)
            debugOutput("Capacitors: "..capacitorsCount)

            -- Write to terminal
            term.redirect(term.native())
        end
    end
end

local function sendMonitorData()
    while true do
        -- prepare data for sending to monitor
        local data = {}
        setmetatable(data, {__index = _G.MessageData})
        data.peripheral = -1

        local monitorData = {}
        setmetatable(monitorData, {__index = _G.MonitorData})

        monitorData.capacitors = capacitors
        monitorData.capacitorsCount = capacitorsCount
        monitorData.energyMeters = energyMeters
        monitorData.energyMetersCount = energyMetersCount
        monitorData.storedEnergy = totalEnergy()
        monitorData.maxEnergy = totalMaxEnergy()
        monitorData.energyPercentage = energyPercentage()
        monitorData.inputRate = totalInputRate()
        monitorData.outputRate = totalOutputRate()

        data.data = monitorData

        -- send data to all monitors
        local msg = _G.NewUpdateToMonitor(data)
        _G.sendMessage(msg)

        -- needed since otherwise no yield detected in parallel.waitForAll
        os.sleep(0.1)
    end
end

---------------------------------------
-- ACTUAL SERVER PROGRAM STARTS HERE --
---------------------------------------
print("THIS IS THE SERVER PROGRAM!")

-- Run the pinger and the listener and monitor updaters in parallel
parallel.waitForAll(listen, ping_clients, sendMonitorData)

-------------------------------------
-- ACTUAL SERVER PROGRAM ENDS HERE --
-------------------------------------