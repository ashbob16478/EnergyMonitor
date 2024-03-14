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


local function addClient(client) 
    -- add client to connectedClients
    if connectedClients[client.id] ~= nil then
        -- update client
        connectedClients[client.id] = client
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
            term.redirect(_G.controlMonitor)
            term.clear()
            term.setCursorPos(1,1)
            print(clock)

            -- extract data from message and setup clientInfo
            local data = msg.messageData.data
            client.id = data.id
            client.name = data.name
            client.data = data
            client.type = _G.parsePeripheralType(msg.messageData.peripheral)
            client.lastPing = clock

            -- add client as connected
            addClient(client)

            print("Type: " .. _G.parsePeripheralType(msg.messageData.peripheral))
            if msg.messageData.peripheral == _G.MessageDataPeripheral.EnergyMeter then
                print("Client: "..data.name)
                print("ID: "..data.id)
                print("Transfer: "..data.transfer)
                print("Mode: "..data.mode)
                print("Status: "..data.status)

                
            elseif msg.messageData.peripheral == _G.MessageDataPeripheral.Capacitor then
                print("Client: "..data.name)
                print("ID: "..data.id)
                print("Energy: "..data.energy)
                print("MaxEnergy: "..data.maxEnergy)
                print("Filled: "..math.floor(data.energy / data.maxEnergy * 100) .. "%")
                print("Status: "..data.status)
            end

            print("Connected clients: "..connectedClientsCount)
            -- Write to terminal
            term.redirect(term.native())
        end
    end
end

-- Run the pinger and the listener in parallel
parallel.waitForAll(listen, ping_clients)
