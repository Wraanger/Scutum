local E, F, C = unpack(select(2, ...))

local Minimap, MinimapCluster = Minimap, MinimapCluster
local anchor = CreateFrame('Frame', nil, UIParent)
anchor:SetSize(160, 160)
anchor:SetPoint('TOPRIGHT', -30, -30)
F.BD(anchor)
local function OnMouseUp(self, button)
	if(button == 'RightButton') then
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, 'cursor')
	elseif(button == 'MiddleButton') then
		ToggleCalendar()
	else
		Minimap_OnClick(self)
	end
end
local function OnMouseWheel(self, direction)
	self:SetZoom(self:GetZoom() + (self:GetZoom() == 0 and direction < 0 and 0 or direction))
end

function GetMinimapShape() return 'SQUARE' end
function TimeManager_LoadUI() end

local function setup()
	F.Kill(MinimapCluster)
	Minimap:SetMaskTexture(C.PlainTexture)
	Minimap:SetParent(anchor)
	Minimap:ClearAllPoints()
	Minimap:SetSize(anchor:GetWidth(), anchor:GetHeight())
	Minimap:SetAllPoints(anchor)
	Minimap:SetScript('OnMouseUp', OnMouseUp)
	Minimap:SetScript('OnMouseWheel', OnMouseWheel)
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetArchBlobRingAlpha(0)
	Minimap:SetQuestBlobRingScalar(0)
	Minimap:SetQuestBlobRingAlpha(0)
	
	-- garrison/orderhall
	GarrisonLandingPageMinimapButton:ClearAllPoints()
	GarrisonLandingPageMinimapButton:SetParent(Minimap)
	GarrisonLandingPageMinimapButton:SetPoint('TOPRIGHT', 2, 2)
	GarrisonLandingPageMinimapButton:SetSize(36, 36)
	hooksecurefunc('GarrisonLandingPageMinimapButton_UpdateIcon', function(self)
		self:SetNormalTexture('')
		self:SetPushedTexture('')
		self:SetHighlightTexture('')
		
		local icon = self:CreateTexture(nil,'OVERLAY',nil,7)
		icon:SetSize(24, 24)
		icon:SetPoint('CENTER')
		icon:SetTexture([[Interface/AddOns/Scutum/media/textures/garrison2]])
		icon:SetVertexColor(1, 1, 1)
		self.icon = icon
		
		if (C_Garrison.GetLandingPageGarrisonType() == LE_GARRISON_TYPE_6_0) then
			self.title = GARRISON_LANDING_PAGE_TITLE;
			self.description = MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP;
		else
			self.title = ORDER_HALL_LANDING_PAGE_TITLE;
			self.description = MINIMAP_ORDER_HALL_LANDING_PAGE_TOOLTIP;
		end
	end)
	
	GarrisonLandingPageMinimapButton:SetScript('OnEnter', function(self) 
		self.icon:SetVertexColor(1, .8, 0)
	end)
	
	GarrisonLandingPageMinimapButton:SetScript('OnLeave', function(self) 
		self.icon:SetVertexColor(1, 1, 1)
	end)		
	GarrisonMinimapBuilding_ShowPulse = function() end
	
	-- mail
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:SetFrameStrata'HIGH'
	MiniMapMailFrame:SetPoint('BOTTOMRIGHT')
	MiniMapMailIcon:ClearAllPoints()
	MiniMapMailIcon:SetTexCoord(.1, .9, .1, .9)
	MiniMapMailIcon:SetTexture([[Interface/AddOns/Scutum/media/textures/mail]])
	MiniMapMailIcon:SetPoint("TOPLEFT", MiniMapMailFrame, "TOPLEFT", 8, -8)
	MiniMapMailIcon:SetPoint("BOTTOMRIGHT", MiniMapMailFrame, "BOTTOMRIGHT", -8, 8)
	
	local rd = CreateFrame('Frame', nil, Minimap)
	rd:SetSize(24, 15)
	rd:SetPoint('TOPLEFT', Minimap, 'TOPLEFT', 5, -5)
	rd:RegisterEvent('PLAYER_ENTERING_WORLD')
	rd:RegisterEvent('PLAYER_DIFFICULTY_CHANGED')
	rd:RegisterEvent('GUILD_PARTY_STATE_UPDATED')
	rd:RegisterEvent('INSTANCE_GROUP_SIZE_CHANGED')

	rd.text = F.CreateFS(rd, 'LEFT', C.FONTBIG, 15)
	rd.text:SetPoint('TOPLEFT')

	local instanceTexts = {
		[0] = '',
		[1] = '5',
		[2] = '5H',
		[3] = '10',
		[4] = '25',
		[5] = '10H',
		[6] = '25H',
		[7] = 'RF',
		[8] = 'CM',
		[9] = '40',
		[11] = '3H',
		[12] = '3',
		[16] = 'M',
		[23] = '5M',	-- Mythic 5-player
		[24] = '5T',	-- Timewalker 5-player
	}

	rd:SetScript('OnEvent', function()
		local inInstance, instanceType = IsInInstance()
		local _, _, difficultyID, _, maxPlayers, _, _, _, instanceGroupSize = GetInstanceInfo()

		if instanceTexts[difficultyID] ~= nil then
			rd.text:SetText(instanceTexts[difficultyID])
		else
			if difficultyID == 14 then
				rd.text:SetText(instanceGroupSize..'N')
			elseif difficultyID == 15 then
				rd.text:SetText(instanceGroupSize..'H')
			elseif difficultyID == 17 then
				rd.text:SetText(instanceGroupSize..'RF')
			else
				rd.text:SetText('')
			end
		end

		rd:SetShown(inInstance and (instanceType == 'party' or instanceType == 'raid' or instanceType == 'scenario'))

		if GuildInstanceDifficulty:IsShown() then
			rd.text:SetTextColor(0, .9, 0)
		else
			rd.text:SetTextColor(1, 1, 1)
		end
	end)

	local lfg = MiniMapLFGFrame or QueueStatusMinimapButton
	lfg:SetScale(.75)
	lfg:ClearAllPoints()
	lfg:SetParent(Minimap)
	lfg:SetFrameStrata'HIGH'
	lfg:SetPoint('BOTTOMLEFT', Minimap, 0, 0)
	lfg:SetHighlightTexture(nil)
	QueueStatusMinimapButtonBorder:SetTexture(nil)
	-- Default LFG icon
	LFG_EYE_TEXTURES.raid = LFG_EYE_TEXTURES.default
	LFG_EYE_TEXTURES.unknown = LFG_EYE_TEXTURES.default
	
	for _, name in next, {
		'GameTimeFrame',
		'MinimapBorder',
		'MinimapBorderTop',
		'MinimapNorthTag',
		'MinimapZoomIn',
		'MinimapZoomOut',
		'MinimapZoneTextButton',
		'MiniMapMailBorder',
		'MiniMapTracking',
		'MiniMapWorldMapButton',
		'MiniMapInstanceDifficulty',
		'MiniMapVoiceChatFrame',
		'VoiceChatTalkers',
		'ChannelFrameAutoJoin',
		'QueueStatusMinimapButtonBorder',
		'QueueStatusMinimapButtonGroupSize',
		'DurabilityFrame',
	} do F.Kill(_G[name])
	end
	GuildInstanceDifficulty:SetAlpha(0)
	MiniMapChallengeMode:GetRegions():SetTexture("")
	
	E.UnregisterEvent('PLAYER_LOGIN', setup)
end
E.RegisterEvent('PLAYER_LOGIN', setup)
