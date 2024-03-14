print("THIS IS THE CLIENT PROGRAM!")

while true do
    --os.sleep(1)
    term.clear()
    term.setCursorPos(1,1)

    
    -- Receive ping from server
    local msg = _G.receiveMessage()
    print(os.clock())
    print("I just received a message of type: ".. _G.parseType(msg.type))
    print("The message was sent from: ".. _G.parseSender(msg.sender))
    print("The message was: "..msg.data)
    print()




    -- send updated Data to server
    _G.printEnergyMeterData(_G.energyMeter)
    
    local data = {}
    setmetatable(data,{__index = MeterData})
    data.name = os.getComputerLabel()
    data.id = tostring(_G.energyMeter.id)
    data.transfer = _G.energyMeter:transferRate()
    data.mode = _G.energyMeter:mode()
    data.status = _G.energyMeter:status()

    local msg = _G.NewUpdateToServer(data)
    _G.sendMessage(msg)

--[[

    local msg = _G.receiveMessage()

    print("I just received a message of type: ".. _G.parseType(msg.type))
    print("The message was sent from: ".. _G.parseSender(msg.sender))
    print("The message was: "..msg.data)
    
    print("I just received a message on channel: "..senderChannel)
    print("I should apparently reply on channel: "..replyChannel)
    print("The modem receiving this is located on my "..modemSide.." side")
    print("The message was: "..message)
    print("The sender is: "..(senderDistance or "an unknown number of").." blocks away from me.")
    --]]


    -- Process messages from clients
    
end