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
            -- Client is a transferrer
            data.peripheral = _G.MessageDataPeripheral.Transfer

            -- use peripheral data as transfer data structure
            setmetatable(peripheralData,{__index = TransferData})
            peripheralData.name = os.getComputerLabel()
            peripheralData.id = tostring(_G.transferrer.id)
            peripheralData.transferIn = _G.transferrer:transferRateInput()
            peripheralData.transferOut = _G.transferrer:transferRateOutput()
            peripheralData.transferType = _G.transferType
            -- TODO: set appropriate status (DISCONNECTED when no energy is transferred)
            peripheralData.status = "N/A"
            
            -- print data structure to computer screen
            _G.printEnergyTransferData(_G.transferrer)
        elseif _G.capacitor ~= nil then
            -- Client is a capacitor
            data.peripheral = _G.MessageDataPeripheral.Capacitor

            -- use peripheral data as capacitor data structure
            setmetatable(peripheralData,{__index = CapacitorData})
            peripheralData.name = os.getComputerLabel()
            peripheralData.id = tostring(_G.capacitor.id)
            peripheralData.energy = _G.capacitor:energy()
            peripheralData.maxEnergy = _G.capacitor:capacity()
            peripheralData.status = "N/A"

            -- print data structure to computer screen
            _G.printEnergyStorageData(_G.capacitor)
        end

        data.data = peripheralData

        -- send data as update to server
        local msg = _G.NewUpdateToServer(data)
        _G.sendMessage(msg)
    end
end