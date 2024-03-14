_G.MessageType = {
    Ping = 0,          --Sent to check if the client is still alive
    Handshake = 1,     --Sent as a handshake to establish a connection from client to server
    Update = 2,        --Sent to update values to the server from the client
 }

 _G.Sender = {
    Server = 0,
    Client = 1,
 }

_G.Data = {
    name = "",
    transfer = -1,
}

_G.Message = {
    type = "",
    sender = "",
    data = {}
}




function _G.NewHandshakeToServer(data)
    local message = {}
    setmetatable(message,{__index = Message})

    message.data = data
    message.type = MessageType.Handshake
    message.sender = Sender.Client

    return message
end

function _G.NewHandshakeFromServer(data)
    local message = {}
    setmetatable(message,{__index = Message})

    message.data = data
    message.type = MessageType.Handshake
    message.sender = Sender.Server

    return message
end




function _G.NewUpdateToServer(data)
    local message = {}
    setmetatable(message,{__index = Message})

    message.data = data
    message.type = MessageType.Update
    message.sender = Sender.Client

    return message
end

function _G.NewUpdateFromServer(data)
    local message = {}
    setmetatable(message,{__index = Message})

    message.data = data
    message.type = MessageType.Update
    message.sender = Sender.Server

    return message
end




function _G.NewPingToServer()
    local message = {}
    setmetatable(message,{__index = Message})

    message.data = "data"
    message.type = MessageType.Ping
    message.sender = Sender.Client

    return message
end

function _G.NewPingFromServer()
    local message = {}
    setmetatable(message,{__index = Message})

    message.data = "data"
    message.type = MessageType.Ping
    message.sender = Sender.Server

    return message
end




function _G.parseSender(sender)
    if sender == Sender.Server then
        return "Server"
    elseif sender == Sender.Client then
        return "Client"
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