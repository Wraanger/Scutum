local E, F, C, S = unpack(select(2, ...))
local bar = S.InfoBar
local addonList = 50
local customColor = false

local timeframe = CreateFrame('Frame', nil, bar)
timeframe:SetSize(50, bar:GetHeight())
timeframe:SetPoint('RIGHT', bar, -2, 0)
timeframe:SetFrameStrata('HIGH')
timeframe:EnableMouse(true)

timeframe.text = F.CreateFS(timeframe, 'RIGHT', C.FONTBIG, 24)
timeframe.text:SetPoint('RIGHT', timeframe)
timeframe.text:SetJustifyH('RIGHT')
timeframe.text:SetTextColor(1, 1, 1)

local color
if customColor then
	color = { r = 0, g = 1, b = 0.7 }
else
	local _, class = UnitClass('player')
	color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
end
local gradientColor = {
    0, 1, 0,
    1, 1, 0,
    1, 0, 0
}
local function memFormat(number)
	if number > 1024 then
		return string.format("%.2f mb", (number / 1024))
	else
		return string.format("%.1f kb", floor(number))
	end
end
local function numFormat(v)
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

-- http://www.wowwiki.com/ColorGradient
local function ColorGradient(perc, ...)
    if (perc > 1) then
        local r, g, b = select(select('#', ...) - 2, ...) return r, g, b
    elseif (perc < 0) then
        local r, g, b = ... return r, g, b
    end

    local num = select('#', ...) / 3

    local segment, relperc = math.modf(perc*(num-1))
    local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

    return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

local function RGBGradient(num)
    local r, g, b = ColorGradient(num, unpack(gradientColor))
    return r, g, b
end

local function RGBToHex(r, g, b)
    r = r <= 1 and r >= 0 and r or 0
    g = g <= 1 and g >= 0 and g or 0
    b = b <= 1 and b >= 0 and b or 0
    return string.format('|cff%02x%02x%02x', r*255, g*255, b*255)
end

local function addonCompare(a, b)
	return a.memory > b.memory
end
local function clearGarbage()
	UpdateAddOnMemoryUsage()
	local before = gcinfo()
	collectgarbage()
	UpdateAddOnMemoryUsage()
	local after = gcinfo()
	F.Print("|c0000ddffCleaned:|r "..memFormat(before-after))
end

timeframe:SetScript("OnMouseDown", function(self, button, down)
	if button == 'RightButton' and IsShiftKeyDown() then 
		clearGarbage()
	elseif button == 'RightButton' then
		securecall(TimeManager_Toggle)
	elseif button == 'LeftButton' then
		securecall(ToggleCalendar)
	end
end)
local function getLatencyWorldRaw()
	return select(4, GetNetStats())
end

local function getLatencyWorld()
	return "|c00ffffff" .. getLatencyWorldRaw() .. "|r ms"
end

local function getLatencyRaw()
	return select(3, GetNetStats())
end

local function getLatency()
	return "|c00ffffff" .. getLatencyRaw() .. "|r ms"
end
local function getTime()
	local current = GameTime_GetTime(true)
	return '|c00ffffff' .. current .. '|r'
end

local function addonTooltip(self)

	GameTooltip_SetDefaultAnchor(GameTooltip, self)

	local blizz = collectgarbage("count")
	local addons = {}
	local enry, memory
	local total = 0
	local nr = 0
	UpdateAddOnMemoryUsage()

	GameTooltip:AddLine('Statistics', 1, 1, 1)
	GameTooltip:AddLine(" ")
	
	GameTooltip:AddLine("Latency", color.r, color.g, color.b)
	GameTooltip:AddDoubleLine("Home", getLatencyRaw().." ms", 1, 1, 1, RGBGradient(getLatencyRaw()/ 100))
	GameTooltip:AddDoubleLine("World", getLatencyWorldRaw().." ms", 1, 1, 1, RGBGradient(getLatencyWorldRaw()/ 100))
	GameTooltip:AddLine(" ")
	
	GameTooltip:AddLine("Memory", color.r, color.g, color.b)
	for i=1, GetNumAddOns(), 1 do
		if (GetAddOnMemoryUsage(i) > 0 ) then
			memory = GetAddOnMemoryUsage(i)
			entry = {name = GetAddOnInfo(i), memory = memory}
			table.insert(addons, entry)
			total = total + memory
		end
	end
	table.sort(addons, addonCompare)
	for _, entry in pairs(addons) do
		if nr < addonList then
			GameTooltip:AddDoubleLine(entry.name, memFormat(entry.memory), 1, 1, 1, RGBGradient(entry.memory / 800))
			nr = nr+1
		end
	end
	GameTooltip:AddDoubleLine("Total", memFormat(total), 1, 1, 1, RGBGradient(total / (1024*10)))
	
	GameTooltip:Show()
end

timeframe:SetScript("OnEnter", function()
	addonTooltip(timeframe)
end)
timeframe:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

local lastUpdate = 0
local function update(self,elapsed)
	lastUpdate = lastUpdate + elapsed
	if lastUpdate > 1 then
		lastUpdate = 0

		timeframe.text:SetText(getTime())
		self:SetWidth(timeframe.text:GetStringWidth())
		self:SetHeight(timeframe.text:GetStringHeight())
	end
end

timeframe:SetScript("OnEvent", function(self, event)	
	self:SetScript("OnUpdate", update)
end)
timeframe:RegisterEvent("PLAYER_LOGIN")