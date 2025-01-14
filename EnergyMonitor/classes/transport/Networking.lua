_G.MessageType = {
    Ping = 0,          --Sent to check if the client is still alive
    Handshake = 1,     --Sent as a handshake to establish a connection from client to server
    Update = 2,        --Sent to update values to the server from the client
    Monitor = 3,       --Sent to the monitor to update the monitor
    Control = 4,       --Sent to the client to control its behaviour
 }

 -- type that is specified in a packet as sender
 _G.Sender = {
    Server = 0,
    Client = 1,
    Monitor = 2
 }

 -- type of a transferrer specifying if it is measuring input/output or both
_G.TransferType = {
    Input = "input",
    Output = "output",
    Both = "both",
}

--Data structure to use in MessageData.data representing state of a transferrer
_G.TransferData = {
    name = "",
    id = "",
    transferIn = 0,
    transferOut = 0,
    status = "",
    transferType = ""
}

--Data structure to use in MessageData.data representing state of a capacitor
_G.CapacitorData = {
    name = "",
    id = "",
    energy = -1,
    maxEnergy = -1,
    status = "",
}

--Data structure to use in MessageData.data representing all values needed for displaying on a monitor
_G.MonitorData = {
    capacitors = {},
    capacitorsCount = -1,
    transferrers = {},
    transferrersCount = -1,
    storedEnergy = -1,
    maxEnergy = -1,
    energyPercentage = -1,
    inputRate = -1,
    outputRate = -1,
}

--Data structure to use in MessageData.data that will be used in the future to perform certain actions on a specific peripheral
--TODO: NOT IN USE RIGHT NOW
_G.ControlData = {
    peripheral = {},
}

--peripheral used in MessageData.data that contains the type of peripheral whose data is sent
_G.MessageDataPeripheral = {
    Capacitor = 0,
    Transfer = 1,
}

--data to use in Message.messageData that contains the MessageDataPeripheral and its data structure
_G.MessageData = {
    peripheral = {},
    data = {}
}

-- default packet that is used for communication and contains type, sender and actual data
_G.Message = {
    type = "",
    sender = "",
    messageData = {}
}

-- function that creates a handshake message from a client
function _G.NewHandshakeToServer(messageData)
    local message = {}
    setmetatable(message,{__index = Message})

    message.messageData = messageData
    message.type = MessageType.Handshake
    message.sender = Sender.Client

    return message
end

-- function that creates a handshake message from the server
function _G.NewHandshakeFromServer(messageData)
    local message = {}
    setmetatable(message,{__index = Message})

    message.messageData = messageData
    message.type = MessageType.Handshake
    message.sender = Sender.Server

    return message
end



-- function that will create a new message with an update from a client
function _G.NewUpdateToServer(messageData)
    local message = {}
    setmetatable(message,{__index = Message})

    message.messageData = messageData
    message.type = MessageType.Update
    message.sender = Sender.Client

    return message
end

-- function that will create a new message with an update from the server
function _G.NewUpdateFromServer(messageData)
    local message = {}
    setmetatable(message,{__index = Message})

    message.messageData = messageData
    message.type = MessageType.Update
    message.sender = Sender.Server

    return message
end


-- function that will wrap some data into a packet for monitor display
function _G.NewUpdateToMonitor(messageData)
    local message = {}
    setmetatable(message,{__index = Message})

    message.messageData = messageData
    message.type = MessageType.Monitor
    message.sender = Sender.Server

    return message
end


-- function that will create a new ping message from client that is ready to be sent
function _G.NewPingToServer()
    local message = {}
    setmetatable(message,{__index = Message})

    message.messageData = "data"
    message.type = MessageType.Ping
    message.sender = Sender.Client

    return message
end

-- function that will create a new ping message from server that is ready to be sent
function _G.NewPingFromServer()
    local message = {}
    setmetatable(message,{__index = Message})

    message.messageData = "data"
    message.type = MessageType.Ping
    message.sender = Sender.Server

    return message
end



-- function that will return the string for a sender
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

-- function that will return the string for a message type
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

-- function that will return the string for a peripheral type
function _G.parsePeripheralType(type)
    if type == MessageDataPeripheral.Capacitor then
        return "Capacitor"
    elseif type == MessageDataPeripheral.Transfer then
        return "Transferrer"
    else
        return "Unknown"
    end
end

-- function that will return the string for a TransferType
function _G.parseTransferType(type)
    if type == TransferType.Input then
        return "Input"
    elseif type == TransferType.Output then
        return "Output"
    elseif type == TransferType.Both then
        return "Input/Output"
    else
        return "Unknown"
    end
end

-- function that is used to serialize a message
local function serializeMessage(message)
    return textutils.serialise(message)
end

-- function that is used to deserialize a message back to its original data structure
local function deserializeMessage(serializedMessage)
    local message = textutils.unserialise(serializedMessage)
    setmetatable(message,{__index = Message})
    return message
end



-- function that is used to serialize and transmit a message object over the modem
function _G.sendMessage(message)
    local msg = serializeMessage(message)
    _G.wirelessModem.transmit(_G.modemChannel, _G.modemChannel, msg)
end

-- function that is used to receive a transmitted message over the modem and deserialize it
function _G.receiveMessage()
    local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
    return deserializeMessage(message)
end