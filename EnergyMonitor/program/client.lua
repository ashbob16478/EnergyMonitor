print("THIS IS THE CLIENT PROGRAM!")

while true do    
    -- Receive ping from server
    local msg = _G.receiveMessage()
    term.clear()
    term.setCursorPos(1,1)

    if msg.type == MessageType.Ping and msg.sender == Sender.Server then
        print(os.clock())
        debugOutput("I just received a message of type: ".. _G.parseType(msg.type))
        debugOutput("The message was sent from: ".. _G.parseSender(msg.sender))
        debugOutput("The message was: "..msg.messageData)
        debugOutput()
    end


    -- send updated Data to server
    local data = {}
    setmetatable(data, {__index = MessageData})

    local peripheralData = {}
    if _G.energyMeter ~= nil then
        data.peripheral = _G.MessageDataPeripheral.EnergyMeter

        setmetatable(peripheralData,{__index = MeterData})
        peripheralData.name = os.getComputerLabel()
        peripheralData.id = tostring(_G.energyMeter.id)
        peripheralData.transfer = _G.energyMeter:transferRate()
        peripheralData.mode = _G.energyMeter:mode()
        peripheralData.status = _G.energyMeter:status()
        peripheralData.meterType = _G.meterType
        
        _G.printEnergyMeterData(_G.energyMeter)
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