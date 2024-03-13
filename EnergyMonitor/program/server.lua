print("THIS IS THE SERVER PROGRAM!")

while true do
    os.sleep(1)
    
    -- Send test message to all connected clients
    print("Sending a message to all clients on channel: ".._G.modemChannel)
    _G.wirelessModem.transmit(_G.modemChannel, _G.modemChannel, "Hello, clients!")

    -- Receive messages from all connected clients

    -- Process messages from clients

end