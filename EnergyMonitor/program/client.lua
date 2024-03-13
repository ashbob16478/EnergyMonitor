print("THIS IS THE CLIENT PROGRAM!")

while true do
    os.sleep(1)

    -- Send test message to all connected clients
    
    -- Receive messages from all connected clients
    local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
    print("I just received a message on channel: "..senderChannel)
    print("I should apparently reply on channel: "..replyChannel)
    print("The modem receiving this is located on my "..modemSide.." side")
    print("The message was: "..message)
    print("The sender is: "..(senderDistance or "an unknown number of").." blocks away from me.")

    -- Process messages from clients
    
end