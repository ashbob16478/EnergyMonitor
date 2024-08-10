-- Reactor / Turbine Control
-- (c) 2021 SeekerOfHonjo
-- Version 2.0
-- https://gitlab.com/seekerscomputercraft/extremereactorcontrol/-/blob/main/classes/mekanism/MekanismEnergyStorage.lua?ref_type=heads

local DraconicEnergyStorage = {
    name = "",
    id = {},
    side = "",
    type = "",
    useGetEnergy = false,    
    useGetTotalEnergy = false,    
    useGetEnergyCapacity = false,    
    useGetMaxEnergy = false,    
    useGetTotalMaxEnergy = false,

    energy = function(self)
        if self.useGetEnergy then
            return defaultNil(self.id.getEnergy(), 0)
        end
        if self.useGetTotalEnergy then
            return defaultNil(self.id.getTotalEnergy(), 0)
        end
    end,
    capacity = function(self)
        if self.useGetEnergyCapacity then
            return defaultNil(self.id.getEnergyCapacity(), 0)
        end
        if self.useGetMaxEnergy then
            return defaultNil(self.id.getMaxEnergy(), 0)
        end
        if self.useGetTotalMaxEnergy then
            return defaultNil(self.id.getTotalMaxEnergy(), 0)
        end
    end,
    percentage = function(self)
        return defaultNan(math.floor(self:energy()/self:capacity()*100), 0)
    end,
    percentagePrecise = function(self)
        return defaultNan(self:energy()/self:capacity()*100, 0)
    end
}

function _G.newDraconicEnergyStorage(name,id, side, type)
    print("Creating new DraconicEvolution Energy Storage")
    local storage = {}
    setmetatable(storage,{__index=DraconicEnergyStorage})
    
    if id == nil then
        print("MISSING wrapped peripheral object. This is going to break!")
    end

    local successGetEnergy, errGetEnergy= pcall(function() id.getEnergy() end)
    local successGetTotalEnergy, errGetTotalEnergy= pcall(function() id.getTotalEnergy() end)
    local successGetEnergyCapacity, errGetEnergyCapacity= pcall(function() id.getEnergyCapacity() end)
    local successGetMaxEnergy, errGetMaxEnergy= pcall(function() id.getMaxEnergy() end)
    local successGetTotalMaxEnergy, errGetTotalMaxEnergy= pcall(function() id.getTotalMaxEnergy() end)

    storage.useGetEnergy = successGetEnergy
    storage.useGetTotalEnergy = successGetTotalEnergy   
    storage.useGetEnergyCapacity = successGetEnergyCapacity    
    storage.useGetMaxEnergy = successGetMaxEnergy    
    storage.useGetTotalMaxEnergy = successGetTotalMaxEnergy

    storage.name = name
    storage.id = id
    storage.side = side
    storage.type = type

    return storage
end




