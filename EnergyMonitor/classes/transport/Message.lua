_G.MessageType = {
    Ping = 0,          --Sent to check if the client is still alive
    Handshake = 1,     --Sent as a handshake to establish a connection from client to server
    Update = 2,        --Sent to update values to the server from the client
    Monitor = 3,       --Sent to the monitor to update the monitor
    Control = 4,       --Sent to the client to control its behaviour
 }

 _G.Sender = {
    Server = 0,
    Client = 1,
    Monitor = 2
 }

_G.MeterType = {
    providing = 0,
    using = 1
}

--Data structure to use in MessageData.data
_G.MeterData = {
    name = "",
    id = "",
    transfer = -1,
    mode = "",
    status = "",
    meterType = ""
}

--Data structure to use in MessageData.data
_G.CapacitorData = {
    name = "",
    id = "",
    energy = -1,
    maxEnergy = -1,
    status = "",
}

--Data structure to use in MessageData.data
_G.MonitorData = {
    capacitors = {},
    capacitorsCount = -1,
    energyMeters = {},
    energyMetersCount = -1,
    storedEnergy = -1,
    maxEnergy = -1,
    energyPercentage = -1,
    inputRate = -1,
    outputRate = -1,
}

--Data structure to use in MessageData.data
_G.ControlData = {
    peripheral = {},
}

--peripheral used in MessageData.data
_G.MessageDataPeripheral = {
    Capacitor = 0,
    EnergyMeter = 1,
}

--data to use in Message.messageData
_G.MessageData = {
    peripheral = {},
    data = {}
}

_G.Message = {
    type = "",
    sender = "",
    messageData = {}
}




function _G.NewHandshakeToServer(messageData)
    local message = {}
    setmetatable(message,{__index = Message})

    message.messageData = messageData
    message.type = MessageType.Handshake
    message.sender = Sender.Client

    return message
end

function _G.NewHandshakeFromServer(messageData)
    local message = {}
    setmetatable(message,{__index = Message})

    message.messageData = messageData
    message.type = MessageType.Handshake
    message.sender = Sender.Server

    return message
end




function _G.NewUpdateToServer(messageData)
    local message = {}
    setmetatable(message,{__index = Message})

    message.messageData = messageData
    message.type = MessageType.Update
    message.sender = Sender.Client

    return message
end

function _G.NewUpdateFromServer(messageData)
    local message = {}
    setmetatable(message,{__index = Message})

    message.messageData = messageData
    message.type = MessageType.Update
    message.sender = Sender.Server

    return message
end



function _G.NewUpdateToMonitor(messageData)
    local message = {}
    setmetatable(message,{__index = Message})

    message.messageData = messageData
    message.type = MessageType.Monitor
    message.sender = Sender.Server

    return message
end



function _G.NewPingToServer()
    local message = {}
    setmetatable(message,{__index = Message})

    message.messageData = "data"
    message.type = MessageType.Ping
    message.sender = Sender.Client

    return message
end

function _G.NewPingFromServer()
    local message = {}
    setmetatable(message,{__index = Message})

    message.messageData = "data"
    message.type = MessageType.Ping
    message.sender = Sender.Server

    return message
end




function _G.parseSender(sender)
    if sender == Sender.Server then
        return "Server"
    elseif sender == Sender.Client then
        return "Client"
    elseif sender == Sender.Monitor then
        return "Monitor"
    else
        return "Unknown"
    end
end

function _G.parseType(type)
    if type == MessageType.Handshake then
        return "Handshake"
    elseif type == MessageType.Update then
        return "Update"
    elseif type == MessageType.Ping then
        return "Ping"
    elseif type == MessageType.Control then
        return "Control"
    else
        return "Unknown"
    end
end

function _G.parsePeripheralType(type)
    if type == MessageDataPeripheral.Capacitor then
        return "Capacitor"
    elseif type == MessageDataPeripheral.EnergyMeter then
        return "EnergyMeter"
    else
        return "Unknown"
    end
end

function _G.parseMeterType(type)
    if type == MeterType.providing then
        return "Input"
    elseif type == MeterType.using then
        return "Output"
    else
        return "Unknown"
    end
end

local function serializeMessage(message)
    return textutils.serialise(message)
end

local function deserializeMessage(serializedMessage)
    local message = textutils.unserialise(serializedMessage)
    setmetatable(message,{__index = Message})
    return message
end




function _G.sendMessage(message)
    local msg = serializeMessage(message)
    _G.wirelessModem.transmit(_G.modemChannel, _G.modemChannel, msg)
end

function _G.receiveMessage()
    local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
    return deserializeMessage(message)
end