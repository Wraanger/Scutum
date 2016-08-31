local E, F, C, S = unpack(select(2, ...))

local bar = CreateFrame('Frame')
bar:SetSize(0, 30)
bar:SetFrameStrata('BACKGROUND')
bar:SetPoint('RIGHT', UIParent)
bar:SetPoint('LEFT', UIParent)
bar:SetPoint('BOTTOM')
F.BD(bar)

S.InfoBar = bar