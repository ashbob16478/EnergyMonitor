-- EnergyTransfer Base Class
local DraconicFluxGateEnergyTransfer = setmetatable({
    -- Basic Methods
    transferRateInput = function(self)
        if transferType == "input" or transferType == "both" then
            return defaultNil(self.id.getFlow(), 0)
        else
            return 0
        end
    end,

    transferRateOutput = function(self)
        if transferType == "output" or transferType == "both" then
            return defaultNil(self.id.getFlow(), 0)
        else
            return 0
        end
    end
}, {__index = EnergyTransfer})

function _G.newDraconicFluxGateEnergyTransfer(name, id, side, type, transferType)
    print("Creating new Draconic Flux Gate Transfer")
    local transfer = {}
    setmetatable(transfer, {__index=DraconicFluxGateEnergyTransfer})
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
