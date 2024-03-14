local EnergyMeter = {
    name = "",
    id = {},
    side = "",
    type = "",
    
    sideConfig = function(self)
        return self.id.getSideConfig()
    end,
    interval = function(self)
        return self.id.getInterval()
    end,
    accuracy = function(self)
        return self.id.getAccuracy()
    end,
    hasOutput = function(self)
        return self.id.hasOutput()
    end,
    threshold = function(self)
        return self.id.getThreshold()
    end,
    mode = function(self)
        return self.id.getMode()
    end,
    fullSideConfig = function(self)
        return self.id.getFullSideConfig()
    end,
    hasMaxOutputs = function(self)
        return self.id.hasMaxOutputs()
    end,
    status = function(self)
        return self.id.getStatus()
    end,
    hasInput = function(self)
        return self.id.hasInput()
    end,
    numberMode = function(self)
        return self.id.getNumberMode()
    end,
    transferRate = function(self)
        return self.id.getTransferRate()
    end
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
    print("hasOutput: "..tostring(meter:hasOutput()))
    print("mode: "..tostring(meter:mode()))
    print("status: "..tostring(meter:status()))
    print("hasInput: "..tostring(meter:hasInput()))
    print("transferRate: "..tostring(meter:transferRate()))
    
end