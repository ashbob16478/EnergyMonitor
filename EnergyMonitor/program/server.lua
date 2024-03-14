_G.connectedClients = {}

print("THIS IS THE SERVER PROGRAM!")

function main_loop()
    while true do
        term.clear()
        term.setCursorPos(1,1)

        -- Send ping to all connected clients
        print(os.clock())
        print("Sending a ping to all clients on channel: ".._G.modemChannel)
        local msg = _G.NewPingFromServer()
        _G.sendMessage(msg)


        -- needed since otherwise no yield detected in parallel.waitForAll
        os.sleep(0.1)
    end
end

function listen()
    -- Receive data from all connected clients
    while true do
        local msg = _G.receiveMessage()
        if msg.type == _G.MessageType.Update then
            local data = msg.data

            -- Write to monitor
            term.redirect(_G.controlMonitor)
            term.clear()
            term.setCursorPos(1,1)

            print(os.clock())
            print("Client: "..data.name)
            print("ID: "..data.id)
            print("Transfer: "..data.transfer)
            print("Mode: "..data.mode)
            print("Status: "..data.status)

            -- Write to terminal
            term.redirect(term.native())
        end
    end
end

-- Run the pinger and the listener in parallel
parallel.waitForAll(listen, main_loop)
