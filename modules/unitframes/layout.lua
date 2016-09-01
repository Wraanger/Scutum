local name, addon = ...
local oUF = addon.oUF
local E, F, C = unpack(select(2, ...))

local _, CLASS = UnitClass'player'
local CLASSCOLOR = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[CLASS] or RAID_CLASS_COLORS[CLASS]

local RAID_TARGET_UPDATE = function(self, event)
	local index = GetRaidTargetIndex(self.unit)
	if(index) then
		self.RIcon:SetText(ICON_LIST[index].."23|t")
	else
		self.RIcon:SetText()
	end
end

local PostUpdateClassIcon = function(element, cur, max, diff, event)
	if(diff or event == 'ClassPowerEnable') then
		element:UpdateTexture()
	end
end

local UpdateClassIconTexture = function(element)
	local r, g, b
	if(CLASS == 'MONK') then
		r, g, b = 0, 4/5, 3/5
	elseif(CLASS == 'WARLOCK') then
		r, g, b = 2/3, 1/3, 2/3
	elseif(CLASS == 'PRIEST') then
		r, g, b = 2/3, 1/4, 2/3
	elseif(CLASS == 'PALADIN') then
		r, g, b = 1, 1, 2/5
	elseif(CLASS == 'MAGE') then
		r, g, b = 5/6, 1/2, 5/6
	else
		r, g, b = 1, 228/255, 0
	end

	for index = 1, 8 do
		local ClassIcon = element[index]
		ClassIcon.Texture:SetColorTexture(r, g, b)
	end
end

local CastbarCheckShield = function(self, unit)
    if self.interrupt and UnitCanAttack("player", unit) then
      --show shield
      self:SetStatusBarColor(.4, .4, .4, 1)
    else
      --no shield
	  if unit == 'player' then
		self:SetStatusBarColor(CLASSCOLOR.r, CLASSCOLOR.g, CLASSCOLOR.b, 1)
	  else
		self:SetStatusBarColor(12/255,211/255,99/255,1)
	  end
    end
  end
  
local CastbarCheckCast = function(bar, unit, name, rank, castid)
    CastbarCheckShield(bar, unit)
  end
  
local CastbarCheckChannel = function(bar, unit, name, rank)
    CastbarCheckShield(bar, unit)
end
  
local CastbarCustomTimeText = function(self, duration)
	self.Time:SetFormattedText("%.1f", self.max - duration)
end

local CreateCastbar = function(self, unit) 


	local castbar = CreateFrame("StatusBar", "oUF_LynCastbarTarget", self)
	castbar:SetStatusBarTexture(C.Texture)
		
	local castbarSpark = castbar:CreateTexture(nil,'OVERLAY')
	castbarSpark:SetBlendMode('Add')
	castbarSpark:SetHeight(castbar:GetHeight() * 2.3)
	castbarSpark:SetWidth(10)
	castbarSpark:SetVertexColor(1, 1, 1)
	castbar.Spark = castbarSpark

	local castbarText = F.CreateFS(castbar, 'LEFT', C.FONT, 14)
	castbarText:SetPoint('LEFT', castbar, 'LEFT', 5, 0)
	castbar.Text = castbarText
	
	local castbarTime = F.CreateFS(castbar, 'RIGHT', C.FONTBIG, 15)
	castbarTime:SetPoint('LEFT', castbarText, 'RIGHT', 10, -1)
	castbar.Time = castbarTime
		
	if unit == 'target' then
		F.BD(castbar)
		castbar:SetHeight(30)
		castbar:SetWidth(350)
		castbar:SetPoint("BOTTOM", self, "TOP", 0, 175)	
	elseif unit == 'player' then
		castbar:SetAllPoints(self.Health)
		castbar:SetFrameStrata('HIGH')
		castbar:SetAlpha(0.75)

    end
		
	self.Castbar = castbar
	
	self.Castbar.CustomTimeText = CastbarCustomTimeText
	self.Castbar.PostCastStart = CastbarCheckCast
	self.Castbar.PostChannelStart = CastbarCheckChannel

end

local Shared = function(self, unit, isSingle)
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:RegisterForClicks"AnyUp"
	self:SetSize(150, 20)
	
	if unit ~= 'targettarget' then
		F.BD(self)
		local Health = CreateFrame("StatusBar", nil, self)
		Health:SetStatusBarTexture(C.Texture)
		Health:SetStatusBarColor(.25, .25, .25)

		Health.frequentUpdates = true
		Health.Smooth = true

		Health:SetPoint"TOP"
		Health:SetPoint"LEFT"
		Health:SetPoint"RIGHT"

		self.Health = Health

		local Background = Health:CreateTexture(nil, 'BORDER')
		Background:SetColorTexture(.35, .35, .35)
		Background:SetAllPoints()
		
		Health.PostUpdate = PostUpdateHealth
	end
	
	
end

local UnitSpecific = {
	player = function(self, ...)
		Shared(self, ...)
		self:SetSize(350, 30)
		
		local HealthPoints = F.CreateFS(self.Health, 'RIGHT', C.FONTBIG, 22)
		HealthPoints:SetPoint("RIGHT", -2, 0)
		HealthPoints:SetTextColor(1, 1, 1)
		self:Tag(HealthPoints, '[lyn:hpp]')
		self.Health.value = HealthPoints
		
		local hpv = F.CreateFS(self.Health, 'RIGHT', C.FONTBIG, 11)
		hpv:SetPoint('RIGHT', HealthPoints, 'LEFT', -5, 0)
		hpv:SetTextColor(.8, .8, .8)
		self:Tag(hpv, '[lyn:hpv]')
		
		local power = F.CreateFS(self.Health, 'CENTER', C.FONTBIG, 32)
		power:SetPoint("CENTER", self.Health, 0, 0)
		power:SetTextColor(1, 1, 1)
		self:Tag(power, '[lyn:power]')
		
		local raidIcon = self.Health:CreateTexture(nil, 'OVERLAY')
		raidIcon:SetTexture([[Interface\AddOns\Scutum\media\textures\raidicons]])
		raidIcon:SetSize(32, 32)
		raidIcon:SetPoint('TOP', 0, 14)
		self.RaidIcon = raidIcon
		
		local leader = self.Health:CreateTexture(nil, "OVERLAY")
		leader:SetSize(13, 13)
		leader:SetTexture([[Interface\AddOns\Scutum\media\textures\commander.tga]])
		leader:SetPoint("BOTTOM", self.Health, "TOP", 0, -6)
		leader:SetPoint("RIGHT", -6, 0)
		self.Leader = leader
		
		local pvp = F.CreateFS(self.Health, 'CENTER', C.FONTBIG, 12)
		pvp:SetPoint('TOPLEFT', self.Health, 4, 8)
		pvp:SetTextColor(1, 1, 1)
		self:Tag(pvp, '[lyn:smallpvp]')
		
		local ClassIcons = {}
		ClassIcons.UpdateTexture = UpdateClassIconTexture
		ClassIcons.PostUpdate = PostUpdateClassIcon
		
		for index = 1, 8 do
			local ClassIcon = CreateFrame('Frame', nil, self)
			ClassIcon:SetSize(10, 10)
			ClassIcon:SetBackdrop({
				bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
				tiled = false,
				insets = {left = 0, right = 0, top = 0, bottom = 0}
			})
			ClassIcon:SetBackdropColor(0, 0, 0, 0)
			
			Texture = ClassIcon:CreateTexture(nil, 'BORDER')
			Texture:SetAllPoints(ClassIcon)
			ClassIcon.Texture = Texture
			
			if index > 1 then
				ClassIcon:SetPoint('LEFT', ClassIcons[index - 1], 'RIGHT', 9, 0)
			else
				ClassIcon:SetPoint('LEFT', self, 0, -26)
			end
			
			local Background = ClassIcon:CreateTexture(nil, 'BACKGROUND')
			Background:SetTexture([[Interface/Buttons/WHITE8X8]])
			Background:SetVertexColor(0, 0, 0, .5)
			Background:SetPoint('TOPLEFT', ClassIcon, -3, 3)
			Background:SetPoint('BOTTOMRIGHT', ClassIcon, 3, -3)
			ClassIcon.Background = Background

			ClassIcons[index] = ClassIcon
		end
	   
	   self.ClassIcons = ClassIcons
	   CreateCastbar(self, 'player')
	end,
	target = function(self, ...)
		Shared(self, ...)
		self:SetSize(350, 30)
		
		local HealthPoints = F.CreateFS(self.Health, 'RIGHT', C.FONTBIG, 22)
		HealthPoints:SetPoint("RIGHT", -2, 0)
		HealthPoints:SetTextColor(1, 1, 1)
		self:Tag(HealthPoints, '[lyn:hpp]')
		self.Health.value = HealthPoints
		
		local hpv = F.CreateFS(self.Health, 'RIGHT', C.FONTBIG, 11)
		hpv:SetPoint('RIGHT', HealthPoints, 'LEFT', -5, 0)
		hpv:SetTextColor(.8, .8, .8)
		self:Tag(hpv, '[lyn:hpv]')
		
		local raidIcon = self.Health:CreateTexture(nil, 'OVERLAY')
		raidIcon:SetTexture([[Interface\AddOns\Scutum\media\textures\raidicons]])
		raidIcon:SetSize(32, 32)
		raidIcon:SetPoint('TOP', 0, 14)
		self.RaidIcon = raidIcon
		
		local leader = self.Health:CreateTexture(nil, "OVERLAY")
		leader:SetSize(13, 13)
		leader:SetTexture([[Interface\AddOns\Scutum\media\textures\commander.tga]])
		leader:SetPoint("BOTTOM", self.Health, "TOP", 0, -6)
		leader:SetPoint("RIGHT", -6, 0)
		self.Leader = leader
		
		local name = F.CreateFS(self.Health, 'LEFT', C.FONT, 18)
		name:SetPoint("LEFT", self.Health, 5, 0)
		name:SetWidth(360)
		
		self.Name = name
		self:Tag(self.Name, '[lyn:color][lyn:targetname]')	
		
		local classification = F.CreateFS(self.Health, 'RIGHT', C.FONTBIG, 12)
		classification:SetPoint('BOTTOM', self.Health, 'TOP', 0, -4)
		classification:SetHeight(12)
		self:Tag(classification, '[lyn:classification]')
		
		local pvp = F.CreateFS(self.Health, 'LEFT', C.FONTBIG, 12)
		pvp:SetPoint('LEFT', 6, 18)
		self:Tag(pvp, '[lyn:targetpvp]')
		
		local quest = F.CreateFS(self.Health, 'RIGHT', C.FONTBIG, 12)
		quest:SetPoint('RIGHT', classification, 'LEFT', -1, -1)
		quest:SetText('|cffffe400QUESTMOB|r')
		self.QuestIcon = quest
		
		CreateCastbar(self, 'target')

	end,
	targettarget = function(self, ...)
		Shared(self, ...)
		
		local name = F.CreateFS(self, 'RIGHT', C.FONT, 16)
		name:SetPoint("BOTTOMRIGHT", self, 0, 0)
		name:SetWidth(150)
		
		self.Name = name
		self:Tag(self.Name, '[lyn:name]')	
	end,
	focus = function(self, ...)
		Shared(self, ...)
	end,
	pet	= function(self, ...)
		Shared(self, ...)
	end,
}

do
	local range = {
		insideAlpha = 1,
		outsideAlpha = .5,
	}

	UnitSpecific.party = function(self, ...)
		Shared(self, ...)
		
		local HealthPoints = F.CreateFS(self.Health, 'RIGHT', C.FONTBIG, 15)
		HealthPoints:SetPoint("RIGHT", -2, 0)
		HealthPoints:SetTextColor(1, 1, 1)
		self:Tag(HealthPoints, '[lyn:hpp]')
		self.Health.value = HealthPoints
		
		local leader = self.Health:CreateTexture(nil, "OVERLAY")
		leader:SetSize(13, 13)
		leader:SetTexture([[Interface\AddOns\Scutum\media\textures\commander.tga]])
		leader:SetPoint("BOTTOM", self.Health, "TOP", 0, -6)
		leader:SetPoint("RIGHT", -6, 0)
		self.Leader = leader
		
		local name = F.CreateFS(self.Health, 'LEFT', C.FONT, 12)
		name:SetPoint("LEFT", self.Health, 5, 0)
		name:SetWidth(120)
		
		self.Name = name
		self:Tag(self.Name, '[lyn:color][lyn:targetname]')	
	end
	UnitSpecific.raid = function(self, ...)
		Shared(self, ...)
		
		local HealthPoints = F.CreateFS(self.Health, 'RIGHT', C.FONTBIG, 15)
		HealthPoints:SetPoint("RIGHT", -2, 0)
		HealthPoints:SetTextColor(1, 1, 1)
		self:Tag(HealthPoints, '[lyn:hpp]')
		self.Health.value = HealthPoints
		
		local name = F.CreateFS(self.Health, 'LEFT', C.FONT, 12)
		name:SetPoint("LEFT", self.Health, 5, 0)
		name:SetWidth(120)
		
		self.Name = name
		self:Tag(self.Name, '[lyn:color][lyn:targetname]')	
	end
	UnitSpecific.boss = function(self, ...)
		Shared(self, ...)
		
		local HealthPoints = F.CreateFS(self.Health, 'RIGHT', C.FONTBIG, 15)
		HealthPoints:SetPoint("RIGHT", -2, 0)
		HealthPoints:SetTextColor(1, 1, 1)
		self:Tag(HealthPoints, '[lyn:hpp]')
		self.Health.value = HealthPoints
		
		local name = F.CreateFS(self.Health, 'LEFT', C.FONT, 12)
		name:SetPoint("LEFT", self.Health, 5, 0)
		name:SetWidth(120)
		
		self.Name = name
		self:Tag(self.Name, '[lyn:color][lyn:targetname]')	
	end
end

oUF:RegisterStyle("Scutum", Shared)
for unit,layout in next, UnitSpecific do
	-- Capitalize the unit name, so it looks better.
	oUF:RegisterStyle('Scutum - ' .. unit:gsub("^%l", string.upper), layout)
end

-- A small helper to change the style into a unit specific, if it exists.
local spawnHelper = function(self, unit, ...)
	if(UnitSpecific[unit]) then
		self:SetActiveStyle('Scutum - ' .. unit:gsub("^%l", string.upper))
	elseif(UnitSpecific[unit:match('%D+')]) then -- boss1 -> boss
		self:SetActiveStyle('Scutum - ' .. unit:match('%D+'):gsub("^%l", string.upper))
	else
		self:SetActiveStyle'Scutum'
	end

	local object = self:Spawn(unit)
	object:SetPoint(...)
	return object
end

oUF:Factory(function(self)
	spawnHelper(self, 'player', 'BOTTOM', 0, 250)
	spawnHelper(self, 'target', 'BOTTOM', oUF_ScutumPlayer, 'TOP', 0, 10)
	spawnHelper(self, 'targettarget', 'BOTTOMRIGHT', oUF_ScutumTarget, 'TOPRIGHT', 3, 5)
	spawnHelper(self, 'focus', "CENTER", -314, 90)
	spawnHelper(self, 'pet', 'BOTTOM', -37, 178)

	for n=1, MAX_BOSS_FRAMES or 5 do
		spawnHelper(self, 'boss' .. n, 'TOPRIGHT', -40, -270 - (36 * n))
	end

	self:SetActiveStyle'Scutum - Party'
	local party = self:SpawnHeader(
		nil, nil, 'party',
		'showParty', true, 
		'showPlayer', true, 
		'showRaid', false,
		'showSolo', true, 
		'yOffset', -9,
		'oUF-initialConfigFunction', [[
			self:SetHeight(18)
			self:SetWidth(140)
		]]
	)
	party:SetPoint("TOPLEFT", 30, -30)
	
	self:SetActiveStyle'Scutum - Raid'
	local raid = self:SpawnHeader(
		nil, nil, 'raid',
		'showParty', true, 
		'showPlayer', true, 
		'showRaid', true,
		'showSolo', true, 
		'yOffset', -9,
		'columnSpacing', 35,
		'startingIndex', 1,
		'groupBy', 'GROUP',
		'unitsPerColumn', 25,
		'maxColumns', 8,
		'columnAnchorPoint', 'LEFT',
		'groupingOrder', '1,2,3,4,5,6,7,8',
		'oUF-initialConfigFunction', [[
			self:SetHeight(10)
			self:SetWidth(120)
		]]
	)
	raid:SetPoint("TOPLEFT", 30, -30)	
end)


SlashCmdList["TESTBOSS"] = function()
    oUF_ScutumBoss1:Show(); oUF_ScutumBoss1.Hide = function() end oUF_ScutumBoss1.unit = "player"
    oUF_ScutumBoss2:Show(); oUF_ScutumBoss2.Hide = function() end oUF_ScutumBoss2.unit = "player"
    oUF_ScutumBoss3:Show(); oUF_ScutumBoss3.Hide = function() end oUF_ScutumBoss3.unit = "player"
    oUF_ScutumBoss4:Show(); oUF_ScutumBoss4.Hide = function() end oUF_ScutumBoss4.unit = "player"
	oUF_ScutumBoss5:Show(); oUF_ScutumBoss5.Hide = function() end oUF_ScutumBoss5.unit = "player"
end
SLASH_TESTBOSS1 = "/tb"