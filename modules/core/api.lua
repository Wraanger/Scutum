local E, F, C = unpack(select(2, ...))
-- [[ Constants ]]
C.Texture = [[Interface\AddOns\Scutum\media\textures\Skullflower.tga]]
C.PlainTexture = [[Interface\ChatFrame\ChatFrameBackground]]

C.FONT = [[Interface\AddOns\Scutum\media\fonts\Gotham.ttf]]
C.FONTBIG = [[Interface\AddOns\Scutum\media\fonts\GothamNarrow.ttf]]
C.FONTBIG2 = [[Interface\AddOns\Scutum\media\fonts\theboldfont.ttf]]
C.FONTDAMAGE = [[Interface\AddOns\Scutum\media\fonts\Coalition.ttf]]
DAMAGE_TEXT_FONT = C.FONTDAMAGE
-- [[ For secure frame hiding ]]
local hider = CreateFrame("Frame", "ScutumUIHider", UIParent)
hider:Hide()
-- [[ Functions ]]
F.dummy = function() end

F.Kill = function(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
		object:SetParent(hider)
	else
		object.Show = F.dummy
	end
	object:Hide()
end

F.Print = function(...)
	print('|cff0090ffScutum|r:', ...)
end

F.BD = function(parent)
	parent:SetBackdrop({
		bgFile = C.PlainTexture,
		edgeFile = C.PlainTexture,
		edgeSize = -3,
	})
	parent:SetBackdropColor(0, 0, 0, .5)
	parent:SetBackdropBorderColor(0, 0, 0)
end

F.CreateFS = function(parent, justify, fontName, fontSize, fontStyle)
	local f = parent:CreateFontString(nil, 'OVERLAY')
	f:SetJustifyH(justify or 'LEFT')
	f:SetFont(fontName or C.FONT, fontSize or 15, fontStyle or 'OUTLINE')
	f:SetShadowColor(0, 0, 0, 1)
	f:SetShadowOffset(1, -1)
	
	return f
end