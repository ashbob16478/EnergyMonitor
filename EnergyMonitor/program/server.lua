_G.amountClients = 0
_G.connectedClients = {}

print("THIS IS THE SERVER PROGRAM!")

while true do
    os.sleep(1)
    
    -- Send test message to all connected clients
    print("Sending a message to all clients on channel: ".._G.modemChannel)

    local msg = _G.NewPingFromServer()
    _G.sendMessage(msg)


    -- Receive messages from all connected clients


    -- Process messages from clients

end