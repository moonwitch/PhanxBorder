local AddBorder = PhanxBorder.AddBorder
local AddShadow = PhanxBorder.AddShadow
local Masque = select(4, GetAddOnInfo("Masque"))

local COLOR_BY_CLASS = true

------------------------------------------------------------------------
--	Addon frames
------------------------------------------------------------------------

local noop = function() end

local applyFuncs = { }

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event)
	for i, func in pairs(applyFuncs) do
		if func() then
			applyFuncs[i] = nil
		end
	end
	if #applyFuncs == 0 then
		self:UnregisterAllEvents()
		self:SetScript("OnEvent", nil)
		applyFuncs = nil
	end
end)

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("VARIABLES_LOADED")

------------------------------------------------------------------------
--	Blizzard frames
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	GhostFrameLeft:Hide()
	GhostFrameMiddle:Hide()
	GhostFrameRight:Hide()
	GhostFrame:SetBackdrop({ bgFile = [[Interface\BUTTONS\WHITE8X8]], tile = true, tileSize = 8 })
	GhostFrame:SetBackdropColor(0, 0, 0, 0.8)
	GhostFrame:SetScript("OnMouseDown", nil)
	GhostFrame:SetScript("OnMouseUp", nil)

	for i, f in ipairs({
		"GhostFrame",
		"LFDSearchStatus",
		"Minimap",
		"TicketStatusFrame",

		"DropDownList1MenuBackdrop",
		"DropDownList2MenuBackdrop",

		"ConsolidatedBuffsTooltip",
		"FrameStackTooltip",
		"FriendsTooltip",
		"GameTooltip",
		"ItemRefShoppingTooltip1",
		"ItemRefShoppingTooltip2",
		"ItemRefShoppingTooltip3",
		"ItemRefTooltip",
		"MovieRecordingFrameTextTooltip1",
		"MovieRecordingFrameTextTooltip2",
		"PartyMemberBuffTooltip",
		"PrimaryProfession1SpellButtonBottom",
		"PrimaryProfession1SpellButtonTop",
		"PrimaryProfession2SpellButtonBottom",
		"PrimaryProfession2SpellButtonTop",
		"SecondaryProfession1SpellButtonLeft",
		"SecondaryProfession1SpellButtonRight",
		"SecondaryProfession2SpellButtonLeft",
		"SecondaryProfession2SpellButtonRight",
		"SecondaryProfession3SpellButtonLeft",
		"SecondaryProfession3SpellButtonRight",
		"SecondaryProfession4SpellButtonLeft",
		"SecondaryProfession4SpellButtonRight",
		"ShoppingTooltip1",
		"ShoppingTooltip2",
		"ShoppingTooltip3",
		"SmallTextTooltip",
		"VideoOptionsTooltip",
		"WorldMapCompareTooltip1",
		"WorldMapCompareTooltip2",
		"WorldMapCompareTooltip3",
		"WorldMapTooltip",
	}) do
		-- print("Adding border to " .. f)
		AddBorder(_G[f])
	end

	-- Spellbook/companion buttons
	local function Button_OnDisable( button )
		button:SetAlpha(0)
	end
	local function Button_OnEnable( button )
		button:SetAlpha(1)
	end

	-- Spellbook buttons
	for i = 1, 12 do
		local button = _G["SpellButton" .. i]
		AddBorder(button)
		button:HookScript("OnDisable", Button_OnDisable)
		button:HookScript("OnEnable", Button_OnEnable)
		_G["SpellButton" .. i .. "Background"]:SetTexture("")
		_G["SpellButton" .. i .. "SlotFrame"]:SetTexture("")
		_G["SpellButton" .. i .. "IconTexture"]:SetTexCoord(0.06, 0.94, 0.06, 0.94)
	end

	--[[ Companion buttons
	for i = 1, 12 do
		local button = _G["SpellBookCompanionButton" .. i]
		AddBorder(button)
		button:HookScript("OnDisable", Button_OnDisable)
		button:HookScript("OnEnable", Button_OnEnable)
		button.Background:SetTexture("")
		button.IconTexture:SetTexCoord(0.06, 0.94, 0.06, 0.94)
	end]]

	--[[ Core Abilities buttons
	for i = 1, 8 do
		local button = select(i, SpellBookCoreAbilitiesFrame:GetChildren())
		if button then
			button:HookScript("OnDisable", Button_OnDisable)
			button:HookScript("OnEnable", Button_OnEnable)
			_G["SpellButton" .. i .. "Background"]:SetTexture("")
			_G["SpellButton" .. i .. "SlotFrame"]:SetTexture("")
			button.iconTexture:SetTexCoord(0.06, 0.94, 0.06, 0.94)
		end
	end]]
	return true
end)

------------------------------------------------------------------------
--	Dewdrop-2.0
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	local Dewdrop = LibStub and LibStub("Dewdrop-2.0", true)
	if Dewdrop then
		local function AddDewdropBorders()
			local i = 1
			while true do
				local f = _G["Dewdrop20Level" .. i]
				if not f then break end
				if not f.borderTextures then
					local j = 1
					while true do
						local fc = select(j, f:GetChildren())
						if not fc then break end
						if fc.GetBackdrop then
							fc:SetBackdropColor(0, 0, 0, 0)
							fc:SetBackdropBorderColor(0, 0, 0, 0)
							fc:SetBackdrop(nil)
						end
						j = j + 1
					end
					f:SetBackdrop(GameTooltip:GetBackdrop())
					f:SetBackdropColor(0, 0, 0, 0.8)
					AddBorder(f)
				end
				i = i + 1
			end
		end
		hooksecurefunc(Dewdrop, "Open", AddDewdropBorders)
		AddDewdropBorders()
		return true
	end
end)

------------------------------------------------------------------------
--	LibQTip-1.0
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	local QTip = LibStub and LibStub("LibQTip-1.0", true)
	if QTip then
		local Acquire = QTip.Acquire
		QTip.Acquire = function(lib, ...)
			local tooltip = Acquire(lib, ...)
			if tooltip then
				AddBorder(tooltip)
				tooltip:SetBorderColor()
			end
			return tooltip
		end
		return true
	end
end)

------------------------------------------------------------------------
--	Tablet-2.0
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	local Tablet = LibStub and LibStub("Tablet-2.0", true)
	if Tablet then
		local function AddTabletBorders()
			AddBorder(Tablet20Frame)
			local i = 1
			while true do
				local frame = _G["Tablet20DetachedFrame" .. i]
				if not frame then break end
				AddBorder(frame)
				i = i + 1
			end
		end
		hooksecurefunc(Tablet, "Open", AddTabletBorders)
		hooksecurefunc(Tablet, "Detach", AddTabletBorders)
		AddTabletBorders()
		return true
	end
end)

------------------------------------------------------------------------
--	AtlasLoot
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	if AtlasLootTooltip then
		-- print("Adding border to AtlasLootTooltip")
		AddBorder(AtlasLootTooltip)
		return true
	end
end)

------------------------------------------------------------------------
--	Auracle
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	if Auracle and Auracle.windows then
		-- print("Adding border to Auracle")
		-- Auracle.windows[1].trackers[1].uiFrame
		local function Auracle_SetVertexColor(icon, r, g, b, a)
			icon:realSetVertexColor(r, g, b, a)
			icon:GetParent():SetBorderAlpha(a)
		end
		for i, window in pairs(Auracle.windows) do
			for i, tracker in ipairs(window.trackers) do
				local f = tracker.uiFrame
				AddBorder(f)

				local cd = f.Auracle_tracker.uiCooldown
				cd:ClearAllPoints()
				cd:SetPoint("TOPLEFT", f, 2, -2)
				cd:SetPoint("BOTTOMRIGHT", f, -2, -2)

				local icon = f.Auracle_tracker.uiIcon
				icon.realSetVertexColor = icon.SetVertexColor
				icon.SetVertexColor = Auracle_SetVertexColor

				local _, _, _, a = icon:GetVertexColor()
				f:SetBorderAlpha(a)
			end
		end
		return true
	end
end)

------------------------------------------------------------------------
--	Bagnon
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	local o = Bagnon and Bagnon.Frame and Bagnon.Frame.New
	if o then
		-- print("Adding border to Bagnon")
		Bagnon.Frame.New = function(...)
			local f = o(...)
			AddBorder(f)
			local color = COLOR_BY_CLASS and (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))]
			if color then
				f:GetSettings():SetBorderColor(color.r, color.g, color.b, 1)
			end
			return f
		end
		return true
	end
end)

------------------------------------------------------------------------
--	Bazooka
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	if Bazooka and Bazooka.bars and #Bazooka.bars > 0 then
		-- print("Adding border to Bazooka")
		local color = COLOR_BY_CLASS and (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))]
		for i, bar in ipairs(Bazooka.bars) do
			AddBorder(bar.frame, nil, nil, nil, true)
			Bazooka.db.profile.bars[i].bgBorderTexture = "None"
			if color then
				Bazooka.db.profile.bars[i].bgBorderColor.r = color.r
				Bazooka.db.profile.bars[i].bgBorderColor.g = color.g
				Bazooka.db.profile.bars[i].bgBorderColor.b = color.b
			end
			bar:applyBGSettings()
		end

		return true
	end
end)

------------------------------------------------------------------------
--	BuffBroker
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	if Masque then
		return true
	end
	local btn = BuffBroker and BuffBroker.BuffButton
	if btn then
		-- print("Adding border to BuffBroker")
		AddBorder(btn)
		btn:GetNormalTexture():SetTexCoord(0.03, 0.97, 0.03, 0.97)
		return true
	end
end)

------------------------------------------------------------------------
--	Butsu
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	if Butsu then
		AddBorder(Butsu)
		local color = COLOR_BY_CLASS and (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))]
		if color then
			Butsu:SetBorderColor(color.r, color.g, color.b)
			Butsu.title:SetTextColor(color.r, color.g, color.b)
		end
		return true
	end
end)

------------------------------------------------------------------------
--	CandyBuckets
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	if CandyBucketsTooltipFrame then
		AddBorder(CandyBucketsTooltipFrame)
		return true
	end
end)

------------------------------------------------------------------------
--	CoolLine
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	if CoolLine then
		-- print("Adding border to CoolLine")
		AddBorder(CoolLine)

		function CoolLine_AddBorders()
			-- print("Adding border to CoolLine icons")
			for i = 1, CoolLine.border:GetNumChildren() do
				local f = select(i, CoolLine.border:GetChildren())
				if f.icon and not f.BorderTextures then
					-- print("Adding border to CoolLine icon", i)
					AddBorder(f)
					f:SetBackdrop(nil)
					f.icon:SetDrawLayer("BACKGROUND")
				end
			end
		end

		local osa = CoolLine.SetAlpha
		CoolLine.SetAlpha = function(...)
			osa(...)
			if CoolLine.border then
				CoolLine_AddBorders()
			end
		end

		return true
	end
end)

------------------------------------------------------------------------
--	DockingStation
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	local panel = DockingStation and DockingStation:GetPanel(1)
	if panel then
		-- print("Adding border to DockingStation panels")
		local i = 1
		while true do
			local p = DockingStation:GetPanel(i)
			if not p then break end
			AddBorder(p, nil, nil, nil, true)
			i = i + 1
		end
		return true
	end
end)


------------------------------------------------------------------------
--	Forte_Cooldown
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	if FWCDFrame then
		-- print("Adding border to Forte_Cooldown")
		AddBorder(FWCDFrame, nil, nil, true)
		return true
	end
end)


------------------------------------------------------------------------
--	Grid
------------------------------------------------------------------------

table.insert(applyFuncs, function()
--[[
	if GridLayoutFrame then
		GridLayoutFrame.texture:SetTexture("")
		GridLayoutFrame.texture:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 0)
		GridLayoutFrame.texture:Hide()

		AddBorder(GridLayoutFrame, 15)

		local backdrop = GridLayoutFrame:GetBackdrop()
		backdrop.bgFile = "Interface\\BUTTONS\\WHITE8X8"
		GridLayoutFrame:SetBackdrop(backdrop)
		GridLayoutFrame:SetBackdropColor(16/255, 16/255, 16/255, 1)

		GridLayoutFrame.SetBackdrop = noop
		GridLayoutFrame.SetBackdropColor = noop
		GridLayoutFrame.SetBackdropBorderColor = noop
		GridLayoutFrame.texture.SetGradientAlpha = noop
		GridLayoutFrame.texture.SetTexture = noop
		GridLayoutFrame.texture.Show = noop

		return true
	end
]]
	local GridFrame = Grid and Grid:GetModule("GridFrame")
	if GridFrame and GridFrame.registeredFrames then
		-- print("Adding borders to Grid frames")
		local function Grid_SetBackdropBorderColor(f, r, g, b, a)
			if a and a == 0 then
				f:SetBorderColor()
			else
				f:SetBorderColor(r, g, b)
			end
		end
		local function Grid_AddBorder(f)
			if not f.SetBorderColor then
				f:SetBorderSize(0.1)
				AddBorder(f)
				f.SetBackdropBorderColor = Grid_SetBackdropBorderColor
				f.SetBorderSize = noop
			end
		end
		for frame in pairs(GridFrame.registeredFrames) do
			Grid_AddBorder(_G[frame])
		end
		local o = GridFrame.RegisterFrame
		GridFrame.RegisterFrame = function(self, f)
			o(self, f)
			Grid_AddBorder(f)
		end

		return true
	end
end)

------------------------------------------------------------------------
--	Omen
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	if OmenBarList then
		-- print("Adding border to Omen")
		AddBorder(OmenBarList)
		return true
	end
end)

------------------------------------------------------------------------
--	SexyCooldown
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	if SexyCooldown and SexyCooldown.bars then
		-- print("Adding border to SexyCooldown")
		local color = COLOR_BY_CLASS and (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))]
		for i, bar in ipairs(SexyCooldown.bars) do
			AddBorder(bar)
			if color then
				local bcolor = bar.settings.bar.backgroundColor
				bcolor.r, bcolor.g, bcolor.b = color.r * 0.2, color.g * 0.2, color.b * 0.2
				bar:SetBackdropColor(bcolor.r, bcolor.g, bcolor.b, bcolor.a)

				local tcolor = bar.settings.bar.fontColor
				tcolor.r, tcolor.g, tcolor.b = color.r, color.g, color.b
				bar:SetBarFont()
			end
		end
		return true
	end
end)

------------------------------------------------------------------------
--	TourGuide
------------------------------------------------------------------------

table.insert(applyFuncs, function()
	if TourGuide and TourGuide.statusframe then
		-- print("Adding border to TourGuide status frame")
		AddBorder(TourGuide.statusframe)
		AddBorder(TourGuideItemFrame)
		return true
	end
end)