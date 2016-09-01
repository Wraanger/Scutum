local E, F, C = unpack(select(2, ...))

local function orderhall(addon)
	if(addon == 'Blizzard_GuildUI') then
		-- Set default tab in guild window
		GuildFrame:HookScript('OnShow', function()
			GuildFrameTab2:Click()
		end)
	elseif(addon == 'Blizzard_OrderHallUI') then
		-- Hide the Class Hall bar
		OrderHallCommandBar:Hide()
		OrderHallCommandBar.Show = F.dummy
	end
end
E.RegisterEvent('ADDON_LOADED', orderhall)
-- Auto-deposit reagents
local function bankOpen()
	if(not IsShiftKeyDown()) then
		DepositReagentBank()
	end
end
E.RegisterEvent('BANKFRAME_OPENED', bankOpen)
-- Disable queue status sounds
QueueStatusMinimapButton.EyeHighlightAnim:SetScript('OnLoop', nil)