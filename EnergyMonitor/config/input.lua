function formatNumberComma(number)
    local finalOutput =  format_int(number)
   
    return finalOutput
end

function _G.formatDecimals(number, decimals) 
    return string.format("%." .. decimals .. "f", number)
end

function _G.EnergyWithUnitToNumber(energy)
  --extract number and unit separately from string
  local number = energy:match("%d+%.?%d*")
  local unit = energy:match("%a+")
  if unit == "FE" then
    return tonumber(number)
  elseif unit == "KFE" then
    return tonumber(number) * 1000
  elseif unit == "MFE" then
    return tonumber(number) * 1000000
  elseif unit == "GFE" then
    return tonumber(number) * 1000000000
  elseif unit == "TFE" then
    return tonumber(number) * 1000000000000
  elseif unit == "PFE" then
    return tonumber(number) * 1000000000000000
  elseif unit == "EFE" then
    return tonumber(number) * 1000000000000000000
  elseif unit == "ZFE" then
    return tonumber(number) * 1000000000000000000000
  elseif unit == "YFE" then
    return tonumber(number) * 1000000000000000000000000
  end
end

function _G.numberToEnergyUnit(number)
  -- turn 1000 into 1kFE
  -- turn 1000000 into 1MFE
  -- turn 1000000000 into 1GFE
  -- turn 1000000000000 into 1TFE

  local decimal_places = 1

  local unit = "FE"
  local value = 0
  if number >= 1000000000000000000000000 then
    unit = "YFE"
    value = number / 1000000000000000000000
  elseif number >= 1000000000000000000000 then
    unit = "ZFE"
    value = number / 1000000000000000000
  elseif number >= 1000000000000000000 then
    unit = "EFE"
    value = number / 1000000000000000
  elseif number >= 1000000000000000 then
    unit = "PFE"
    value = number / 1000000000000
  elseif number >= 1000000000000 then
    unit = "TFE"
    value = number / 1000000000000
  elseif number >= 1000000000 then
    unit = "GFE"
    value = number / 1000000000
  elseif number >= 1000000 then
    unit = "MFE"
    value = number / 1000000
  elseif number >= 1000 then
    unit = "KFE"
    value = number / 1000
  else
    value = number
  end

  -- format value to have exact 3 decimal places
  return formatDecimals(value, 1) .. " " .. unit
end

function format_int(number)
  --thanks to https://stackoverflow.com/questions/10989788/format-integer-in-lua answer by Bert Kiers
  local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

  if int == nil then
    int = ""
  end

  if fraction == nil then
    fraction = ""
  end

  if minus == nil then
    minus = ""
  end
  
  -- reverse the int-string and append a comma to all blocks of 3 digits
  int = int:reverse():gsub("(%d%d%d)", "%1".._G.language:getText("thousandsDelimiter"))

  if fraction:len() > 0 then
    fraction = _G.language:getText("fractionDelimiter")..fraction:sub(2)
  end

  -- reverse the int-string back remove an optional comma and put the 
  -- optional minus and fractional part back
  return minus .. int:reverse():gsub("^%p", "") .. fraction
end

function _G.ternary ( cond , T , F )
  if cond then return T else return F end
end

function _G.defaultNil ( val , def )
  return ternary(val == nil, def, val)
end

function _G.defaultNan ( val , def )
  return ternary(val ~= val, def, val)
end