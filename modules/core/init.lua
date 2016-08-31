-- [[ Core ]]
local addon, core = ...

core[1] = {} -- E, Events
core[2] = {} -- F, Functions
core[3] = {} -- C, Constants/Config
core[4] = {} -- S, Shared

local E, F, C = unpack(select(2, ...))

-- [[ Event handler ]]
local eventFrame = CreateFrame("Frame")
local events = {}

eventFrame:SetScript("OnEvent", function(_, event, ...)
	for i = #events[event], 1, -1 do
		events[event][i](event, ...)
	end
end)

E.RegisterEvent = function(event, func)
	if not events[event] then
		events[event] = {}
		eventFrame:RegisterEvent(event)
	end
	table.insert(events[event], func)
end

E.UnregisterEvent = function(event, func)
	for index, tFunc in ipairs(events[event]) do
		if tFunc == func then
			table.remove(events[event], index)
		end
	end
	if #events[event] == 0 then
		events[event] = nil
		eventFrame:UnregisterEvent(event)
	end
end

E.UnregisterAllEvents = function(func)
	for event in next, events do
		F.UnregisterEvent(event, func)
	end
end

E.debugEvents = function()
	for event in next, events do
		print(event..": "..#events[event])
	end
end

local updateScale = function(event)
	if not InCombatLockdown() then
		-- we don't bother with the cvar because of high resolution shenanigans
		UIParent:SetScale(768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))
	else
		E.RegisterEvent("PLAYER_REGEN_ENABLED", updateScale)
	end

	if event == "PLAYER_REGEN_ENABLED" then
		E.UnregisterEvent("PLAYER_REGEN_ENABLED", updateScale)
	end
end
E.RegisterEvent("VARIABLES_LOADED", updateScale)
E.RegisterEvent("UI_SCALE_CHANGED", updateScale)