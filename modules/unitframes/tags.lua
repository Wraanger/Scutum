local addon, core = ...
local oUF = core.oUF
local E, F, C = unpack(select(2, ...))

oUF.colors.power['MANA'] = {0.37, 0.6, 1}
oUF.colors.power['RAGE']  = {0.9,  0.3,  0.23}
oUF.colors.power['FOCUS']  = {1, 0.81,  0.27}
oUF.colors.power['RUNIC_POWER']  = {0, 0.81, 1}
oUF.colors.power['AMMOSLOT'] = {0.78,1, 0.78}
oUF.colors.power['FUEL'] = {0.9,  0.3,  0.23}
oUF.colors.power['POWER_TYPE_STEAM'] = {0.55, 0.57, 0.61}
oUF.colors.power['POWER_TYPE_PYRITE'] = {0.60, 0.09, 0.17}	
oUF.colors.power['POWER_TYPE_HEAT'] = {0.55,0.57,0.61}
oUF.colors.power['POWER_TYPE_OOZE'] = {0.76,1,0}
oUF.colors.power['POWER_TYPE_BLOOD_POWER'] = {0.7,0,1}

local utf8sub = function(string, i, dots)
  local bytes = string:len()
  if bytes <= i then
    return string
  else
    local len, pos = 0, 1
    while pos <= bytes do
      len = len + 1
      local c = string:byte(pos)
      if c > 0 and c <= 127 then
        pos = pos + 1
      elseif c >= 194 and c <= 223 then
        pos = pos + 2
      elseif c >= 224 and c <= 239 then
        pos = pos + 3
      elseif c >= 240 and c <= 244 then
        pos = pos + 4
      end
      if len == i then break end
    end
    if len == i and pos <= bytes then
      return string:sub(1, pos - 1)..(dots and '...' or '')
    else
      return string
    end
  end
end	
local siValue = function(v)
	if v > 1E10 then
		return (floor(v/1E9)).."b"
	elseif v > 1E9 then
		return (floor((v/1E9)*10)/10).."b"
	elseif v > 1E7 then
		return (floor(v/1E6)).."m"
	elseif v > 1E6 then
		return (floor((v/1E6)*10)/10).."m"
	elseif v > 1E4 then
		return (floor(v/1E3)).."k"
	elseif v > 1E3 then
		return (floor((v/1E3)*10)/10).."k"
	else
		return v
	end
end
local hex = function(r, g, b)
	if r then
		if (type(r) == 'table') then
			if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
		end
		return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
	end
end

local tags = oUF.Tags.Methods or oUF.Tags
local tagevents = oUF.TagEvents or oUF.Tags.Events

tags['lyn:role'] = function(unit)
	local role = UnitGroupRolesAssigned(unit)
	if role == 'HEALER' then
		return '|cff8AFF30H|r'
	elseif role == 'TANK' then
		return '|cff5F9BFFT|r'
	elseif role == 'DAMAGER' then
		return '|cffFF6161D|r'
	else
		return '|cFF444444P|R'
	end
end
tagevents['lyn:role'] = 'PLAYER_ROLES_ASSIGNED PARTY_MEMBERS_CHANGED'

tags['lyn:smallpvp'] = function(unit)
	if UnitIsPVP(unit) or UnitIsPVPFreeForAll(unit) then
		return '|cff50BB33+|r'
	end
	return ''
end
tagevents['lyn:smallpvp'] = 'UNIT_FACTION'

tags['lyn:targetpvp'] = function(unit)
	if UnitIsPVP(unit) or UnitIsPVPFreeForAll(unit) then
		return '|cff50BB33PVP|r'
	end
	return ''
end
tagevents['lyn:targetpvp'] = 'UNIT_FACTION'

tags['lyn:classification'] = function(unit)
		local c = UnitClassification(unit)
		if(c == 'rare') then
			return '|cffF6C6F9rare|r'
		elseif(c == 'rareelite') then
			return '|cffF6C6F9rare+|r'
		elseif(c == 'elite') then
			return '|cff41C2B3elite|r'
		elseif(c == 'worldboss') then
			return '|cff9AF5DEboss|r'
		elseif(c == 'minus') then
			return ''
		else
			return ''
		end
end
tagevents['lyn:classification'] = 'UNIT_CLASSIFICATION_CHANGED'

tags["lyn:targetname"] = function(unit)
	local name, realm = UnitName(unit)
	name = utf8sub(name, 20, true)
	return strupper(name)
end
tagevents["lyn:targetname"] = "UNIT_NAME_UPDATE"

tags["lyn:name"] = function(unit)
	local name, realm = UnitName(unit)
	local myname = UnitName('player')
	if name == myname then
		name = '|cffFC110DYOU|r'
	else
		name = strupper(utf8sub(name, 10, true))
	end
	
	return strupper(name)
end
tagevents["lyn:name"] = "UNIT_NAME_UPDATE"

tags["lyn:color"] = function(unit)
	local _, class = UnitClass(unit)
	local reaction = UnitReaction(unit, "player")

	if UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit) then
		return "|cffA0A0A0"
	elseif UnitIsTapDenied(unit) then
		return hex(oUF.colors.tapped)
	elseif unit == "pet" then
		return hex(oUF.colors.class[class])
	elseif UnitIsPlayer(unit) then
		return hex(oUF.colors.class[class])
	elseif reaction then
		return hex(oUF.colors.reaction[reaction])
	else
		return hex(1, 1, 1)
	end
end
tagevents["lyn:color"] = 'UNIT_REACTION UNIT_HEALTH UNIT_HAPPINESS'

tags['lyn:hpv'] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	if min == 0 --[[or min == max]] or not UnitIsConnected(unit) or UnitIsGhost(unit) or UnitIsDead(unit) then
		return ''
	end
	
	return siValue(min)	
end
tagevents['lyn:hpv'] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION UNIT_NAME_UPDATE"

tags["lyn:hpp"] = function(unit)
	if not UnitIsConnected(unit) then
		return "|cff999999(._.)|r"
	elseif UnitIsGhost(unit) then
		return "|cff999999('o')|r"
	elseif UnitIsDead(unit) then
		return "|cff999999(x.x)|r"
	end
			
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local percent = math.floor((min / max) * 100+0.5)
	
	if percent < 100 then
		return hex(oUF.ColorGradient(min, max, 1,0,0, 1,1,0, 0,1,0)) .. percent .. "%"
	else
		return ''
	end
end
tagevents["lyn:hpp"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_DEAD PLAYER_ALIVE"

tags['lyn:health'] = function(unit)
	if UnitIsGhost(unit) then
		return "|cff999999('o')|r"
	elseif UnitIsDead(unit) then
		return "|cff999999(x.x)|r"
	end
	
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local percent = math.floor((min / max) * 100+0.5)
	
	return '|cffffffff'..siValue(min)..'|r '..hex(oUF.ColorGradient(min, max, 1,0,0, 1,1,0, 0,1,0))..percent..'%|r'
end
tagevents['lyn:health'] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_DEAD PLAYER_ALIVE"

tags['lyn:power'] = function(unit)
	local min, max = UnitPower(unit, UnitPowerType(unit)), UnitPowerMax(unit,  UnitPowerType(unit))
	if(min == 0 or max == 0 or not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit)) then 
		return '' 
	end

	local _, powerType = UnitPowerType(unit)
	return hex(oUF.colors.power[powerType]) .. siValue(min) .. '|r'
end
tagevents['lyn:power'] = "UNIT_MAXPOWER UNIT_POWER UNIT_CONNECTION PLAYER_DEAD PLAYER_ALIVE"