-- Reactor / Turbine Control
-- (c) 2017 Thor_s_Crafter
-- Version 3.0
-- https://gitlab.com/seekerscomputercraft/extremereactorcontrol/-/blob/main/classes/Peripherals.lua?ref_type=heads


--Peripherals
_G.monitors = {} --Monitor
_G.controlMonitor = "" --Monitor
_G.wirelessModem = "" --wirelessModem
_G.enableWireless = false

_G.transferrer = nil --Energy Transfer
_G.capacitor = nil --Energy Storage

--Total count of all attachments
_G.amountMonitors = 0
_G.smallMonitor = 1
_G.amountClients = 0

-- function that grabs all peripherals and initializes the correct one as client
local function searchPeripherals()
    local peripheralList = peripheral.getNames()
    for i = 1, #peripheralList do
        local periItem = peripheralList[i]
        local periType = peripheral.getType(periItem)
        local peri = peripheral.wrap(periItem)
        
        
        if periType == "monitor" then
            print("Monitor - "..periItem)
            if(peripheralList[i] == controlMonitor) then
                --add to output monitors
                _G.monitors[amountMonitors] = peri
                _G.amountMonitors = amountMonitors + 1
            else
                _G.controlMonitor = peri
            end
        elseif periType == "modem" then
            if peri.isWireless() then
                print("Wireless Modem - "..periItem)
                _G.wirelessModem = peri
                _G.enableWireless = true
            end
        end


        if _G.peripheralType == "capacitor" then
            local successGetEnergyStored, errGetEnergyStored = pcall(function() peri.getEnergyStored() end)

            -- mekanism support
            local isMekanism = periType == "inductionMatrix" 
                or periType == "mekanismMachine" 
                or periType == "Induction Matrix" 
                or periType == "mekanism:induction_port" 
                or periType == "inductionPort"
                or string.find(periType, "rftoolspower:cell")
                or string.find(periType, "Energy Cube")
                or string.find(periType, "EnergyCube")
			
            -- draconic evolution support
			local isDraconicEvolution = periType == "draconic_rf_storage"

            -- fallback to base
            local isBase = (not isMekanism and not isThermalExpansion and not isDraconicEvolution) and successGetEnergyStored

            if isBase then
                --Capacitorbank / Energycell / Energy Core
                print("getEnergyStored() device - "..peripheralList[i])
                _G.capacitor = newEnergyStorage("ec0", peri, periItem, periType)
            end

            if isMekanism then
                --Mekanism V10plus 
                print("Mekanism Energy Storage device - "..peripheralList[i])
                _G.capacitor = newMekanismEnergyStorage("ec0", peri, periItem, periType)
            end
			
			if isDraconicEvolution then
                --Draconic energy core
                print("DraconicEvolution Energy Storage device - "..peripheralList[i])
                _G.capacitor = newDraconicEnergyStorage("ec0", peri, periItem, periType)
            end
        end


        if _G.peripheralType == "transfer" then
            local successGetEnergyTransferInput, errGetEnergyTransferInput = pcall(function() peri.getEnergyTransferInput() end)

            -- mekanism support
            local isMekanism = periType == "inductionMatrix" 
                or periType == "mekanismMachine" 
                or periType == "Induction Matrix" 
                or periType == "mekanism:induction_port" 
                or periType == "inductionPort"
                or string.find(periType, "rftoolspower:cell")
                or string.find(periType, "Energy Cube")
                or string.find(periType, "EnergyCube")
			
            -- energymeter support
            local isEnergyMeter = (periType == "energymeter") or (periType == "energyDetector") or string.find(periType, "energy_detector")

            -- draconic evolution support
			local isDraconicEvolutionEnergyCore = periType == "draconic_rf_storage"
            local isDraconicEvolutionFluxGate = periType == "flow_gate"
            local isDraconicEvolution = not isDraconicEvolutionEnergyCore and not isDraconicEvolutionFluxGate

            -- fallback to base
            local isBase = (not isMekanism and not isThermalExpansion and not isDraconicEvolution) and successGetEnergyTransfer

            if isBase then
                --Capacitorbank / Energycell / Energy Core
                print("getEnergyTransferInput() device - "..peripheralList[i])
                _G.transferrer = newEnergyTransfer("ec0", peri, periItem, periType, _G.transferType)
            end

            if isMekanism then
                --Mekanism V10plus 
                print("Mekanism Energy Transfer device - "..peripheralList[i])
                _G.transferrer = newMekanismEnergyTransfer("ec0", peri, periItem, periType, _G.transferType)
            end

            if isEnergyMeter then
                --Energymeter
                print("Energy Meter - "..periItem)
                _G.transferrer = newEnergyMeter("em0", peri, periItem, periType, _G.transferType)
            end
			
			if isDraconicEvolutionEnergyCore then
                --Draconic energy core
                print("DraconicEvolution EnergyCore Transfer device - "..peripheralList[i])
                _G.transferrer = newDraconicCoreEnergyTransfer("ec0", peri, periItem, periType, _G.transferType)
            end

            if isDraconicEvolutionFluxGate then
                --Draconic flux gate
                print("DraconicEvolution Flux Gate Transfer device - "..peripheralList[i])
                _G.transferrer = newDraconicFluxGateEnergyTransfer("ec0", peri, periItem, periType, _G.transferType)
            end
        end
            
    end
end

-- function that grabs all peripherals and checks if the required ones are attached
function _G.checkPeripherals()
    --Check for errors
    term.clear()
    term.setCursorPos(1,1)

    if _G.program == "monitor" then

        if controlMonitor == "" then
            error("Control Monitor not found!\nPlease check and reboot the computer (Press and hold Ctrl+R)")
        end

        --Monitor clear
        controlMonitor.setBackgroundColor(colors.black)
        controlMonitor.setTextColor(colors.red)
        controlMonitor.clear()
        controlMonitor.setCursorPos(1,1)
        controlMonitor.setTextScale(0.5)

        --Monitor too small
        local monX,monY = controlMonitor.getSize()
    end
    
    if _G.program == "client" or _G.program == "server" then
       -- No monitor required for clients and servers
    elseif _G.program == "monitor" then
        local monX,monY = controlMonitor.getSize()
        _G.smallMonitor = 0
        if monX < 79 or monY < 24 then
            local messageOut = _G.language:getText("monitorSize");
            controlMonitor.write(messageOut)
            error(messageOut)
        end
    end
end

-- function that creates the connection from the modem on the channel from the config
function setupModemConnection()
    debugOutput("Setup Modem Connection on channel " .. _G.modemChannel)
    if _G.enableWireless then
        _G.wirelessModem.open(_G.modemChannel)
    end
end

-- function that will grab all attached peripherals, set up the correct one and connect the modem to the server
function _G.initPeripherals()
    searchPeripherals()
    _G.checkPeripherals()
    setupModemConnection()
end

