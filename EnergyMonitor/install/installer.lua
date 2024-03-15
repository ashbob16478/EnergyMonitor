-- Extreme Reactors Control by SeekerOfHonjo --
-- Original work by Thor_s_Crafter on https://github.com/ThorsCrafter/Reactor-and-Turbine-control-program -- 
-- Version 2.6 --
-- Installer (English) --


--===== Local Variables =====

local arg = {... }
local update
local branch = ""
local repoUrl = "https://raw.githubusercontent.com/TrickShotMLG02/EnergyMonitor/"
local selectedLang = {}
local installLang = nil

--Program arguments for updates
if #arg == 0 then

  --No update
  update = false
  branch = "main"

elseif #arg == 2 or #arg == 3 then

 --Select branch
 if arg[2] == "stable" then branch = "main"
 elseif arg[2] == "main" then branch = "main"
 else
   error("Invalid 2nd argument!")
 end
  if arg[1] == "update" then
    --Update!
    update = true
  elseif arg[1] == "install" then
    update = false
  else
    error("Invalid 1st argument!")
  end
  if #arg == 3 then
    installLang = arg[3]
  end
else
  error("0, 2, or 3 arguments required!")
end

--Url for file downloads
local relUrl = repoUrl..branch.."/EnergyMonitor/"

--===== Functions =====

function getLanguage()
  local pickLang = true

  if _G.lang == nil then
  else
    --global lang 
    if installLang == nil then
      installLang = _G.lang
    end
  end

  pickLang = installLang == nil    

  if pickLang then    
    languages = downloadAndRead("supportedLanguages.txt")
    downloadAndExecuteClass("Language.lua")
    for k, v in pairs(languages) do
      print(k..") "..v)
    end

    term.write("Language? (example: en): ")
  
    installLang = read()
  
    if installLang == "" or installLang == nil then
      installLang = "en"
    end
    
    if languages[installLang] == nil then
      error("Language not found!")
    else
      writeFile("lang/"..installLang..".txt")
      selectedLang = _G.newLanguageById(installLang)
    end
  else
    downloadAndExecuteClass("Language.lua")
    writeFile("lang/"..installLang..".txt")
    selectedLang = _G.newLanguageById(installLang)
  end

	print(selectedLang:getText("language"))
end

--Writes the files to the computer
function writeFile(path)
	local file = fs.open("/EnergyMonitor/"..path,"w")
	local content = getURL(path);
	file.write(content)
	file.close()
end

--Resolve the right url
function getURL(path)
	local gotUrl = http.get(relUrl..path)
	if gotUrl == nil then
    term.clear()
		error("File not found! Please check!\nFailed at "..relUrl..path)
	else
		return gotUrl.readAll()
	end
end

--Saves all data basck to the options.txt file
function updateOptionFileWithLanguage()

    local fileRead = fs.open("/EnergyMonitor/config/options.txt","r")
    local optionList = textutils.unserialise(fileRead.readAll())
    fileRead.close()
    
    optionList["language"] = installLang

    --Serialise the table
    local optList = textutils.serialise(optionList)

	  --Save optionList to the config file
	  local fileSave = fs.open("/EnergyMonitor/config/options.txt","w")
    fileSave.writeLine(optList)
	  fileSave.close()
end

function updateOptionFile(option, value)
    local fileRead = fs.open("/EnergyMonitor/config/options.txt","r")
    local optionList = textutils.unserialise(fileRead.readAll())
    fileRead.close()
    
    optionList[option] = value

    --Serialise the table
    local optList = textutils.serialise(optionList)

    --Save optionList to the config file
    local fileSave = fs.open("/EnergyMonitor/config/options.txt","w")
    fileSave.writeLine(optList)
    fileSave.close()
end

function downloadAndRead(fileName)
	writeFile(fileName)
	local fileData = fs.open("/EnergyMonitor/"..fileName,"r")
	local list = fileData.readAll()
	fileData.close()

	return textutils.unserialise(list)
end

function downloadAndExecuteClass(fileName)	
	writeFile("classes/"..fileName)
  shell.run("/EnergyMonitor/classes/"..fileName)
end

function getAllFiles()
	local fileEntries = downloadAndRead("files.txt")

	for k, v in pairs(fileEntries) do
	  print(v.name.." files...")

	  for fileCount = 1, #v.files do
      local fileName = v.files[fileCount]
      writeFile(fileName)
	  end

	  print(selectedLang:getText("done"))
	end
end

function getVersion()
  writeFile("main.ver")
	local fileData = fs.open("/EnergyMonitor/main.ver","r")
	local list = fileData.readAll()
	fileData.close()

  return list
end

--===== Run installation =====

local meterType = -1
local programType = ""

--load language data
getLanguage()

--First time installation
if not update then
  --Description
  term.clear()
  term.setCursorPos(1,1)
  print(selectedLang:getText("installerIntroLineOne"))
  print(selectedLang:getText("wordVersion").." "..getVersion())
  print()
  print(selectedLang:getText("installerIntroLineThree"))
  print(selectedLang:getText("installerIntroLineFour"))
  print(selectedLang:getText("installerIntroLineFive"))
  print(selectedLang:getText("installerIntroLineSix"))
  print(selectedLang:getText("installerIntroLineSeven"))
  print(selectedLang:getText("installerIntroLineEight"))
  print(selectedLang:getText("installerIntroLineNine"))
  print()
  write(selectedLang:getText("pressEnter"))
  leer = read()


  term.clear()
  term.setCursorPos(1,1)
  print(selectedLang:getText("installerServerOrClient"))
  term.write("Input: ")
    programType = read()
    local meterTypeStr = ""
    if programType == "s" then
      programType = "server"
    elseif programType == "c" then
      programType = "client"

      term.clear()
      term.setCursorPos(1,1)
      print(selectedLang:getText("installerClientMeterOrStorage"))
      local clientType = read()
      term.write("Input: ")
      if clientType == "m" then

        term.clear()
        term.setCursorPos(1,1)
        print(selectedLang:getText("installerClientMeterType"))
        meterType = tonumber(read())

      elseif clientType == "s" then

      else
        error(selectedLang:getText("installerInvalidInput"))
      end

    else
      error(selectedLang:getText("installerInvalidInput"))
    end



  --Computer label
  local out = true
  while out do
    term.clear()
    term.setCursorPos(1,1)
    print(selectedLang:getText("installerLabelLineOne"))
    term.write(selectedLang:getText("installerLabelLineTwo"))

    local input = read()
    if selectedLang:yesCheck(input) then
      print()
      print(selectedLang:getText("installerLabelInfo"))
      term.write("Input: ")

      local lbl = read()
      shell.run("label set " .. lbl)
      print()
      print(selectedLang:getText("installerLabelSet"))
      print()
      sleep(2)
      out = false

    elseif selectedLang:noCheck(input) then
      print()
      print(selectedLang:getText("installerLabelNotSet"))
      print()
      out = false
    end
  end

  --Startup
  local out2 = true
  while out2 do
    term.clear()
    term.setCursorPos(1,1)
    print(selectedLang:getText("installerStartupLineOne"))
    print(selectedLang:getText("installerStartupLineTwo"))
    term.write(selectedLang:getText("installerStartupLineThree"))

    local input = read()
    if selectedLang:yesCheck(input) then
      local file = fs.open("startup","w")
      file.writeLine("shell.run(\"/EnergyMonitor/start/start.lua\")")
      file.close()
      print()
      print(selectedLang:getText("installerStartupInstalled"))
      print()
      out2 = false
    end
    if selectedLang:noCheck(input) then
      print()
      print(selectedLang:getText("installerStartupUninstalled"))
      print()
      out2 = false
    end
  end

  sleep(1)
end --update

term.clear()
term.setCursorPos(1,1)

print(selectedLang:getText("installerFileCheck"))
--Removes old files
if fs.exists("/EnergyMonitor/program/") then
  shell.run("rm /EnergyMonitor/")
end

print(selectedLang:getText("installerGettingNewFiles"))
getAllFiles()
term.clear()
term.setCursorPos(1,1)

print(selectedLang:getText("updatingStartup"))
--Refresh startup (if installed)
if fs.exists("startup") then
  shell.run("rm startup")
  local file = fs.open("startup","w")
  file.writeLine("shell.run(\"/EnergyMonitor/start/start.lua\")")
  file.close()
end

--settings language
term.clear()
term.setCursorPos(1,1)
updateOptionFileWithLanguage()

--settings
if not update then
  updateOptionFile("program", programType)
  updateOptionFile("meterType", meterType)
end
-- update options file with program to run and meter/storage



--Install complete
term.clear()
term.setCursorPos(1,1)

if not update then
  print(selectedLang:getText("installerOutroLineOne"))
  print(selectedLang:getText("installerOutroLineTwo"))
  print()
  term.setTextColor(colors.green)
  print()
  print(selectedLang:getText("installerOutroLineThree").." ;)")
  print(selectedLang:getText("installerOutroLineFour"))
  print()
  print("SeekerOfHonjo")
  print("(c) 2021")

  local x,y = term.getSize()
  term.setTextColor(colors.yellow)
  term.setCursorPos(1,y)
  term.write("Reboot in ")
  for i=5,0,-1 do
    term.setCursorPos(11,y)
    term.write(i)
    sleep(1)
  end
end

shell.completeProgram("/EnergyMonitor/install/installer.lua")


