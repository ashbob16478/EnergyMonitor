-- EnergyTransfer Base Class
local DraconicCoreEnergyTransfer = setmetatable({
    -- Basic Methods
    transferRateInput = function(self)
        if transferType == "input" or transferType == "both" then
            return defaultNil(self.id.getInputPerTick(), 0)
        else
            return 0
        end
    end,

    transferRateOutput = function(self)
        if transferType == "output" or transferType == "both" then
            return defaultNil(self.id.getOutputPerTick(), 0)
        else
            return 0
        end
    end
}, {__index = EnergyTransfer})

function _G.newDraconicCoreEnergyTransfer(name, id, side, type, transferType)
    print("Creating new Draconic Energy Transfer")
    local transfer = {}
    setmetatable(transfer, {__index=DraconicCoreEnergyTransfer})
    if id == nil then
        print("MISSING wrapped peripheral object. This is going to break!")
    end

    transfer.name = name
    transfer.id = id
    transfer.side = side
    transfer.type = type
    transfer.transferType = transferType

    return transfer
end
