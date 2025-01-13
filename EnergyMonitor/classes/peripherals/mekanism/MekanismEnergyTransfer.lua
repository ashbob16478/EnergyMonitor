-- EnergyTransfer Base Class
local MekanismEnergyTransfer = setmetatable({
    successGetLastInput = false,
    successGetLastOutput = false,

    -- Basic Methods
    transferRateInput = function(self)
        if transferType == "input" or transferType == "both" then
            return defaultNil(self.id.getLastInput(), 0) * 0.4 -- Assuming this method exists
        else
            return 0
        end
    end,

    transferRateOutput = function(self)
        if transferType == "output" or transferType == "both" then
            return defaultNil(self.id.getLastOutput(), 0) * 0.4 -- Assuming this method exists
        else
            return 0
        end
    end
}, {__index = EnergyTransfer})

function _G.newMekanismEnergyTransfer(name, id, side, type, transferType)
    print("Creating new Mekanism Energy Transfer")
    local transfer = {}
    setmetatable(transfer, {__index=MekanismEnergyTransfer})
    if id == nil then
        print("MISSING wrapped peripheral object. This is going to break!")
    end

    local successGetLastInput, errGetMaxEnergy= pcall(function() id.getLastInput() end)
    local successGetLastOutput, errGetTotalMaxEnergy= pcall(function() id.getLastOutput() end)

    transfer.successGetLastInput = successGetLastInput    
    transfer.successGetLastOutput = successGetLastOutput

    transfer.name = name
    transfer.id = id
    transfer.side = side
    transfer.type = type
    transfer.transferType = transferType

    return transfer
end
