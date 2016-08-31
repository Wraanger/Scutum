local E, F, C = unpack(select(2, ...))

local function repair()
	if IsShiftKeyDown() then return end
	
	local cost, needed = GetRepairAllCost()
	if needed and (cost > 0) then
		local repaired
		if (not repaired) then
			local funds = GetMoney()
			if (funds >= cost) then
				RepairAllItems()
				repaired = 1
			end
		end
		if repaired then
			F.Print('Repaired for:'..GetCoinTextureString(cost))
		else
			F.Print('Not enough money. Need '..GetCoinTextureString(cost))
		end
	end
end
E.RegisterEvent('MERCHANT_SHOW', repair)