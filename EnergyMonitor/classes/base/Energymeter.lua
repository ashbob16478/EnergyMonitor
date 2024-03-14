local EnergyMeter = {
    name = "",
    id = {},
    side = "",
    type = "",
    
    transferRate = function(self)
        return self.id.getTransferRate()
    end,
    transferRateLimit = function(self)
        return self.id.getTransferRateLimit()
    end,
    setTransferLimit = function (self, limit)
        self.id.setTransferRateLimit(limit)
    end,
    totalTransferred = function(self)
        return self.id.getTotalEnergyTransferred()
    end,
    status = function(self)
        return self.id.getStatus()
    end,
    redstoneControlState = function(self)
        return self.id.getRedstoneControlState()
    end,
    energyType = function(self)
        return self.id.getEnergyType()
    end,

}

function _G.newEnergyMeter(name,id, side, type)
    print("Creating new Base Energy Storage")
    local meter = {}
    setmetatable(meter,{__index=EnergyMeter})
    
    if id == nil then
        print("MISSING wrapped peripheral object. This is going to break!")
    end

    meter.name = name
    meter.id = id
    meter.side = side
    meter.type = type

    return meter
end

function _G.printEnergyMeterData(meter)
    print("Name: "..meter.name)
    print("ID: "..tostring(meter.id))
    print("transferRate: "..meter:transferRate())
    print("transferRateLimit: "..meter:transferRateLimit())
    print("totalTransferred: "..meter:totalTransferred())
    print("status: "..meter:status())
    print("redstoneControlState: "..meter:redstoneControlState())
    print("energyType: "..meter:energyType())
end