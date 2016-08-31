local E, F, C = unpack(select(2, ...))

local function sellgrays()
	if IsShiftKeyDown() then return end
	
	local total = 0

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local item = GetContainerItemID(bag, slot)
			if item then
				local _, _, rarity, _, _, _, _, _, _, _, price = GetItemInfo(item)
				if (rarity == 0) and (price > 0) then
					local _, quantity = GetContainerItemInfo(bag, slot)
					total = total + (price * quantity)
					UseContainerItem(bag, slot)
				end
			end
		end
	end

	if (total > 0) then
		F.Print('Sold grays for:'..' '..GetCoinTextureString(total))
	end
end
local function delayCall()
	C_Timer.After(3, sellgrays)
end
E.RegisterEvent('MERCHANT_SHOW', delayCall)