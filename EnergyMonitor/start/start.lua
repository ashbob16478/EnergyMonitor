-- Extreme Reactors Control by SeekerOfHonjo --
-- Original work by Thor_s_Crafter on https://github.com/ThorsCrafter/Reactor-and-Turbine-control-program -- 
-- Version 1.0 --
-- Start program --

--========== Global variables for all program parts ==========

--All options
_G.optionList = {}
_G.version = 0
_G.program = ""
_G.lang = ""
_G.meterType = 0
_G.modemChannel = 0
_G.pingInterval = 0.5
_G.autoUpdate = 1
_G.debugEnabled = 1
_G.language = {}

--========== Global functions for all program parts ==========

--===== Functions for loading and saving the options =====

local repoUrl = "https://raw.githubusercontent.com/ashbob16478/EnergyMonitor/"

function  _G.debugOutput(message) 
	if  _G.debugEnabled == 1 then
		print(message)
	end
end

--Loads the options.txt file and adds values to the global variables
function _G.loadOptionFile()
	debugOutput("Loading Option File")
	--Loads the file
	local file = fs.open("/EnergyMonitor/config/options.txt","r")
	local list = file.readAll()
	file.close()
    
    --Insert Elements and assign values
    _G.optionList = textutils.unserialise(list)

	--Assign values to variables
	_G.version = optionList["version"]
	_G.program = optionList["program"]
	_G.lang = optionList["language"]
	_G.peripheralType = optionList["peripheralType"]
	_G.transferType = optionList["transferType"]
	_G.modemChannel = optionList["modemChannel"]
	_G.pingInterval = optionList["pingInterval"]
	_G.autoUpdate = optionList["autoUpdate"]
	_G.debugEnabled = optionList["debug"]
end

--Refreshes the options list
function _G.refreshOptionList()
	debugOutput("Refreshing Option List")
	debugOutput("Variable: version")
	optionList["version"] = version
	debugOutput("Variable: program")
	optionList["program"] = program
	debugOutput("Variable: meterType")
	optionList["meterType"] = meterType
	debugOutput("Variable: lang")
	optionList["language"] = lang
	debugOutput("Variable: modemChannel")
	optionList["modemChannel"] = modemChannel
	debugOutput("Variable: pingInterval")
	optionList["pingInterval"] = pingInterval
	optionList["debug"] = debug
	debugOutput("Variable: autoUpdate")
	optionList["autoUpdate"] = autoUpdate
end

--Saves all data back to the options.txt file
function _G.saveOptionFile()
	debugOutput("Saving Option File")
	--Refresh option list
	refreshOptionList()
    --Serialise the table
    local list = textutils.serialise(optionList)
	--Save optionList to the config file
	local file = fs.open("/EnergyMonitor/config/options.txt","w")
    file.writeLine(list)
	file.close()
	print("Saved.")
end


--===== Automatic update detection =====

--Check for updates
function _G.checkUpdates()

	--Check current branch (release or beta)
	local currBranch = ""

	if string.find(version,"beta") or string.find(version, "development") then
		currBranch = "development"
	else
		currBranch = "main"
	end

	--Get Remote version file
	local success, ErrorStatement = pcall(downloadFile, repoUrl..currBranch.."/EnergyMonitor/",currBranch..".ver")
	local tries = 1

	-- Retry 10 times to get the remote version file otherwise continue
	while not success do

		if tries < 10 then 
			-- used to prevent errors on server start due to computercraft http problems while server is starting
			print("Couldn't get remote version from github. Retrying in 5 seconds...")
			os.sleep(5)
			success, ErrorStatement = pcall(downloadFile, repoUrl..currBranch.."/EnergyMonitor/",currBranch..".ver")
		else 
			print("Couldn't get remote version from github. Continuing...")
			return
		end
		
	end
	
	--downloadFile(repoUrl..currBranch.."/EnergyMonitor/",currBranch..".ver")

	--Compare local and remote version
	local file = fs.open(currBranch..".ver","r")
	local remoteVer = file.readLine()
	file.close()
	
	print("localVer: "..version)
	
    if remoteVer == nil then
		print("Couldn't get remote version from gitlab.")
	else
		-- only used to check for update since eg. 1.1-XXX > 1.1.5-XXX
		vNum = string.sub(version, 0, string.find(version, "-")-1)
		rvNum = string.sub(remoteVer, 0, string.find(remoteVer, "-")-1)

		print("remoteVer: "..remoteVer)
		print("Update? -> "..tostring(rvNum > vNum))
		
	    --Update if available
	    if rvNum > vNum then
		    print("Update...")
		    sleep(2)
		    doUpdate(remoteVer,currBranch)
	    end
	end

	--Remove remote version file
	shell.run("rm "..currBranch..".ver")
end


function _G.doUpdate(toVer,branch)

	if program ~= "client" and program ~= "server" then
		--Set the monitor up
		local x,y = controlMonitor.getSize()
		controlMonitor.setBackgroundColor(colors.black)
		controlMonitor.clear()

		local x1 = x/2-15
		local y1 = y/2-4
		local x2 = x/2
		local y2 = y/2

		--Draw Box
		controlMonitor.setBackgroundColor(colors.gray)
		controlMonitor.setTextColor(colors.gray)
		controlMonitor.setCursorPos(x1,y1)
		for i=1,8 do
			controlMonitor.setCursorPos(x1,y1+i-1)
			controlMonitor.write("                              ") --30 chars
		end

		--Print update message
		controlMonitor.setTextColor(colors.white)

		controlMonitor.setCursorPos(x2-9,y1+1)
		controlMonitor.write(_G.language:getText("updateAvailableLineOne")) --17 chars

		controlMonitor.setCursorPos(x2-(math.ceil(string.len(toVer)/2)),y1+3)
		controlMonitor.write(toVer)

		controlMonitor.setCursorPos(x2-8,y1+5)
		controlMonitor.write(_G.language:getText("updateAvailableLineTwo")) --15 chars

		controlMonitor.setCursorPos(x2-12,y1+6)
		controlMonitor.write(_G.language:getText("updateAvailableLineThree")) --24 chars
	end

	--Print install instructions to the terminal
	term.clear()
	term.setCursorPos(1,1)
	local tx,ty = term.getSize()

	print(_G.language:getText("updateProgram"))
	term.write("Input: ")

--
    --Run Counter for installation skipping
    local count = 10
    local out = false

    term.setCursorPos(tx/2-5,ty)
    term.write(" -- 10 -- ")

	if autoUpdate == 1 then
		shell.run("/EnergyMonitor/install/installer.lua update "..branch)
		os.reboot()
		return
	end

    while true do

        local timer1 = os.startTimer(1)

        while true do

            local event, p1 = os.pullEvent()

            if event == "key" then

                if p1 == 90 or p1 == 98 then
                    shell.run("/EnergyMonitor/install/installer.lua update "..branch)
                    out = true
					os.reboot()
                    break
				elseif p1 == 78 then
					out = true
					break
                end

            elseif event == "timer" and p1 == timer1 then

                count = count - 1
                term.setCursorPos(tx/2-5,ty)
                term.write(" -- 0"..count.." -- ")
                break
            end
        end

        if out then break end

        if count == 0 then
            term.clear()
            term.setCursorPos(1,1)
            break
        end
    end
--
end

--Download Files (For Remote version file)
function _G.downloadFile(relUrl,path)
	local gotUrl = http.get(relUrl..path)
	if gotUrl == nil then
		term.clear()
		error("File not found! Please check!\nFailed at "..relUrl..path)
	else
		_G.url = gotUrl.readAll()
	end

	local file = fs.open(path,"w")
	file.write(url)
	file.close()
end


--===== Shutdown and restart the computer =====

function _G.reactorestart()
	saveOptionFile()
	controlMonitor.clear()
	controlMonitor.setCursorPos(38,8)
	controlMonitor.write("Rebooting...")
	os.reboot()
end


function initClasses()
    -- Create base paths
    local binPath = "/EnergyMonitor/classes/"
	local periPath = binPath.."peripherals/"
	local transportPath = binPath.. "transport/"

	-- Load Peripherals support
    shell.run(periPath.."base/EnergyStorage.lua")
	shell.run(periPath.."base/EnergyTransfer.lua")
	shell.run(periPath.."Peripherals.lua")

	-- Load Language localization
	shell.run(binPath.."Language.lua")

	-- Load utils
	shell.run(binPath.."Utils.lua")

	-- Load NetworkMessenger with Packets
    shell.run(transportPath.."Networking.lua")
	


	---------------------------
	-- Add Mod Support below --
	---------------------------

	-- Energy Meters Mod Support
	shell.run(periPath.."energyMeter/EnergyMeter.lua")

	-- Mekanism Mod Support
    shell.run(periPath.."mekanism/MekanismEnergyStorage.lua")
	shell.run(periPath.."mekanism/MekanismEnergyTransfer.lua")

	-- Draconic Evolution Mod Support
	shell.run(periPath.."draconicEvolution/DraconicCoreEnergyStorage.lua")
	shell.run(periPath.."draconicEvolution/DraconicCoreEnergyTransfer.lua")
	shell.run(periPath.."draconicEvolution/DraconicFluxGateEnergyTransfer.lua")
end


--=========== Run the program ==========

--Load the option file and initialize the peripherals

debugOutput("Loading Options File")
loadOptionFile()

debugOutput("Initializing Classes")
initClasses()

debugOutput("Initializing Language")
_G.language = _G.newLanguageById(_G.lang)

debugOutput("Initializing Network Devices")
_G.initPeripherals()

-- check for updates in gitlab/github branch (NOT NEEDED)
debugOutput("Checking for Updates")
checkUpdates()

--Run program based on the settings
if program == "server" then
	shell.run("/EnergyMonitor/program/server.lua")
elseif program == "client" then
	shell.run("/EnergyMonitor/program/client.lua")
elseif program == "monitor" then
	shell.run("/EnergyMonitor/program/monitor.lua")
end
shell.completeProgram("/EnergyMonitor/start/start.lua")

--========== END OF THE START.LUA FILE ==========
