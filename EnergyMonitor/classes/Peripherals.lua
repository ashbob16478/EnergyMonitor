-- Reactor / Turbine Control
-- (c) 2017 Thor_s_Crafter
-- Version 3.0
-- https://gitlab.com/seekerscomputercraft/extremereactorcontrol/-/blob/main/classes/Peripherals.lua?ref_type=heads


--Peripherals
_G.monitors = {} --Monitor
_G.controlMonitor = "" --Monitor
_G.wirelessModem = "" --wirelessModem
_G.enableWireless = false

_G.energyMeter = nil --Energy Meter
_G.capacitor = nil --Energy Storage

--Total count of all attachments
_G.amountMonitors = 0
_G.smallMonitor = 1
_G.amountClients = 0

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
                _G.touchpointLocation = periItem
            end
        elseif periType == "modem" then
            if peri.isWireless() then
                print("Wireless Modem - "..periItem)
                _G.wirelessModem = peri
                _G.enableWireless = true
            end
        elseif periType == "energymeter" then
            print("Energy Meter - "..periItem)
            _G.energyMeter = newEnergyMeter("em0", peri, periItem, periType)
        else
            local successGetEnergyStored, errGetEnergyStored = pcall(function() peri.getEnergyStored() end)
            local isMekanism = periType == "inductionMatrix" 
                or periType == "mekanismMachine" 
                or periType == "Induction Matrix" 
                or periType == "mekanism:induction_port" 
                or periType == "inductionPort"
                or string.find(periType, "rftoolspower:cell")
                or string.find(periType, "Energy Cube")
                or string.find(periType, "EnergyCube")

            local isBase = (not isMekanism and not isThermalExpansion) and successGetEnergyStored

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
        end
    end
end

function _G.checkPeripherals()
    --Check for errors
    term.clear()
    term.setCursorPos(1,1)

    if controlMonitor == "" then
        error("Monitor not found!\nPlease check and reboot the computer (Press and hold Ctrl+R)")
    end

    --Monitor clear
    controlMonitor.setBackgroundColor(colors.black)
    controlMonitor.setTextColor(colors.red)
    controlMonitor.clear()
    controlMonitor.setCursorPos(1,1)
    controlMonitor.setTextScale(0.5)
    
    --Monitor too small
    local monX,monY = controlMonitor.getSize()
    
    -- TODO: FIX THIS CHECK LATER ON
    if _G.program == "client" then
       -- No monitor required for clients
    else
        _G.smallMonitor = 0
        if monX ~= 79 or monY ~= 24 then
            local messageOut = _G.language:getText("monitorSize");
            controlMonitor.write(messageOut)
            error(messageOut)
        end
    end
end

function setupModemConnection()
    debugOutput("Setup Modem Connection on channel " .. _G.modemChannel)
    if _G.enableWireless then
        _G.wirelessModem.open(_G.modemChannel)
    end
end


function _G.initPeripherals()
    searchPeripherals()
    _G.checkPeripherals()
    setupModemConnection()
end

