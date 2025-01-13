print("THIS IS THE CLIENT PROGRAM!")
print("Waiting for server ping...")

while true do    
    -- Receive ping from server
    local msg = _G.receiveMessage()
    if msg.type == MessageType.Ping and msg.sender == Sender.Server then
        term.clear()
        term.setCursorPos(1,1)

        print(os.clock())
        debugOutput("I just received a message of type: ".. _G.parseType(msg.type))
        debugOutput("The message was sent from: ".. _G.parseSender(msg.sender))
        debugOutput("The message was: "..msg.messageData)
        debugOutput()
    


        -- send updated Data to server
        local data = {}
        setmetatable(data, {__index = MessageData})

        local peripheralData = {}
        if _G.transferrer ~= nil then
            data.peripheral = _G.MessageDataPeripheral.Transfer

            setmetatable(peripheralData,{__index = TransferData})
            peripheralData.name = os.getComputerLabel()
            peripheralData.id = tostring(_G.transferrer.id)
            peripheralData.transferIn = _G.transferrer:transferRateInput()
            peripheralData.transferOut = _G.transferrer:transferRateOutput()
            peripheralData.transferType = _G.transferType
            -- TODO: set appropriate status (DISCONNECTED when no energy is transferred)
            peripheralData.status = "N/A"
            
            _G.printEnergyTransferData(_G.transferrer)
        elseif _G.capacitor ~= nil then
            data.peripheral = _G.MessageDataPeripheral.Capacitor

            setmetatable(peripheralData,{__index = CapacitorData})
            peripheralData.name = os.getComputerLabel()
            peripheralData.id = tostring(_G.capacitor.id)
            peripheralData.energy = _G.capacitor:energy()
            peripheralData.maxEnergy = _G.capacitor:capacity()
            peripheralData.status = "N/A"

            _G.printEnergyStorageData(_G.capacitor)
        end

        data.data = peripheralData

        local msg = _G.NewUpdateToServer(data)
        _G.sendMessage(msg)
    end
end