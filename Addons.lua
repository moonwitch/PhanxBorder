--[[--------------------------------------------------------------------
	PhanxBorder
	World of Warcraft user interface addon:
	Adds shiny borders to things.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
----------------------------------------------------------------------]]

local _, Addon = ...
local Masque = IsAddOnLoaded("Masque")
local AddBorder = Addon.AddBorder
local AddShadow = Addon.AddShadow
local config = Addon.config
local noop = Addon.noop

local applyFuncs = {}

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event)
	for i, func in pairs(applyFuncs) do
		if applyFuncs[i]() then
			tremove(applyFuncs, i)
		end
	end
	if #applyFuncs == 0 then
		self:UnregisterAllEvents()
		self:SetScript("OnEvent", nil)
		applyFuncs = nil
	elseif event == "PLAYER_LOGIN" then
		self:RegisterEvent("ADDON_LOADED")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
end)

------------------------------------------------------------------------
--	Dewdrop-2.0
------------------------------------------------------------------------
--[[
tinsert(applyFuncs, function()
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
]]
------------------------------------------------------------------------
--	LibQTip-1.0
------------------------------------------------------------------------

tinsert(applyFuncs, function()
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
--[[
tinsert(applyFuncs, function()
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
]]
------------------------------------------------------------------------
--	Archy
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	if not ArchyDigSiteFrame then return end

	AddBorder(ArchyArtifactFrame)
	ArchyArtifactFrame.SetBackdropBorderColor = noop
	ArchyArtifactFrame:SetFrameStrata("LOW")

	ArchyArtifactFrameSkillBarBorder:SetTexture("")

	AddBorder(ArchyDigSiteFrame)
	ArchyDigSiteFrame.SetBackdropBorderColor = noop
	ArchyDigSiteFrame:SetFrameStrata("LOW")

	ArchyDistanceIndicatorFrame:SetPoint("CENTER", ArchyDigSiteFrame, "TOPLEFT", 40, 5)
	ArchyDistanceIndicatorFrameCircleDistance:SetFont((GameFontNormal:GetFont()), 30, "OUTLINE")
	ArchyDistanceIndicatorFrameCircleDistance:SetTextColor(1, 1, 1)
	ArchyDistanceIndicatorFrameSurveyButton:SetNormalTexture("")
	ArchyDistanceIndicatorFrameCrateButton:SetNormalTexture("")
	ArchyDistanceIndicatorFrameLorItemButton:SetNormalTexture("")

	return true
end)

------------------------------------------------------------------------
--	AtlasLoot
------------------------------------------------------------------------
--[[
tinsert(applyFuncs, function()
	if AtlasLootTooltip then
		-- print("Adding border to AtlasLootTooltip")
		AddBorder(AtlasLootTooltip)
		return true
	end
end)
]]
------------------------------------------------------------------------
--	Auracle
------------------------------------------------------------------------
--[[
tinsert(applyFuncs, function()
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
]]
------------------------------------------------------------------------
--	Bagnon
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	if not Bagnon then return end

	-- TODO: Something to prevent conflicts with Masque?
	if select(4, GetAddOnInfo("Bagnon_Facade")) then
		print("WARNING: Bagnon_Facade is enabled. You should disable it!")
	end

	local function ItemSlot_Update(button)
		button:SetBorderSize(nil, 1) -- fixes scaling issues
		button.icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)
	end
	local function ItemSlot_OnEnter(button)
		Addon.ColorByClass(button)
	end
	local function ItemSlot_OnLeave(button)
		button:UpdateBorder()
	end

	local ItemSlot_Create = Bagnon.ItemSlot.Create
	function Bagnon.ItemSlot:Create()
		local button = ItemSlot_Create(self)
		AddBorder(button)
		button:GetNormalTexture():SetTexture("")
		button:GetHighlightTexture():SetTexture("")
		button.icon:SetTexCoord(0.04, 0.96, 0.04, 0.96)
		button.border.Show = button.border.Hide
		hooksecurefunc(button, "HideBorder", button.SetBorderColor)
		hooksecurefunc(button, "Update", ItemSlot_Update)
		button:HookScript("OnEnter", ItemSlot_OnEnter)
		button:HookScript("OnLeave", ItemSlot_OnLeave)
		return button
	end

	local function ResizeChildBorders(frame)
		for i = 1, frame:GetNumChildren() do
			local child = select(i, frame:GetChildren())
			local slots = child.itemSlots
			if slots then
				for i = 1, #slots do
					ItemSlot_Update(slots[i])
				end
				break
			end
		end
	end

	local function MoveFrames(frame)
		frame:SetBackdrop({ bgFile = config.backdrop.texture, tile = true, tileSize = config.backdrop.size })
		frame:GetSettings():SetColor(config.backdrop.color.r, config.backdrop.color.g, config.backdrop.color.b, config.backdrop.color.a)
		frame:SetBackdropColor(config.backdrop.color.r, config.backdrop.color.g, config.backdrop.color.b, config.backdrop.color.a)
		-- ^ Required because :SetColor won't actually set the color if it's the same as the previously saved color.

		local inventory = Bagnon.frames.inventory
		if not inventory then return end
		--print("Moving inventory frame...")
		inventory:ClearAllPoints()
		inventory:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -15)
		inventory.titleFrame:StopMovingFrame()

		local bank = Bagnon.frames.bank
		if not bank then return end
		--print("Moving bank frame...")
		bank:ClearAllPoints()
		bank:SetPoint("TOPRIGHT", inventory, "TOPLEFT", -15, 0)
		bank.titleFrame:StopMovingFrame()
	end

	hooksecurefunc(Bagnon, "CreateFrame", function(Bagnon, id)
		--print("Adding border to Bagnon", id, "frame")
		local frame = Bagnon.frames[id]
		AddBorder(frame)
		hooksecurefunc(frame, "UpdateScale", ResizeChildBorders)

		if config.useClassColor then
			local _, class = UnitClass("player")
			local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
			frame:GetSettings():SetBorderColor(color.r, color.g, color.b, 1)
		else
			frame:GetSettings():SetBorderColor(f.BorderTextures.TOPLEFT:GetVertexColor())
		end

		if Addon.isPhanx then
			frame:HookScript("OnShow", MoveFrames)
			local LibBackdrop = LibStub and LibStub("LibBackdrop-1.0", true)
			if LibBackdrop then
				LibBackdrop:EnhanceBackdrop(frame)
				frame.SetBackdropBorderColor = Addon.SetBorderColor
			end
		end
	end)

	return true
end)

------------------------------------------------------------------------
--	Bazooka
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	if Bazooka and Bazooka.bars and #Bazooka.bars > 0 then
		-- print("Adding border to Bazooka")
		local color = config.useClassColor and (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))]
		for i = 1, #Bazooka.bars do
			local bar = Bazooka.bars[i]
			local db = Bazooka.db.profile.bars[i]

			AddBorder(bar.frame, nil, nil, false, true)
			bar.frame:SetShadowSize(2.5, 6)
			bar.frame:SetShadowAlpha(0.5)

			db.bgBorderInset = 0
			db.bgBorderTexture = "None"
			db.bgBorderColor.r = config.border.color.r
			db.bgBorderColor.g = config.border.color.g
			db.bgBorderColor.b = config.border.color.b
			if color then
				db.textColor.r = color.r
				db.textColor.g = color.g
				db.textColor.b = color.b
			end
			bar:applyBGSettings()
			bar:applySettings()
		end
		return true
	end
end)

------------------------------------------------------------------------
--	BuffBroker
------------------------------------------------------------------------
--[[
tinsert(applyFuncs, function()
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
]]
------------------------------------------------------------------------
--	Butsu
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	if Butsu then
		AddBorder(Butsu)
		--[[
		local color = config.useClassColor and (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))]
		if color then
			Butsu:SetBorderColor(color.r, color.g, color.b)
			Butsu.title:SetTextColor(color.r, color.g, color.b)
		end
		]]
		return true
	end
end)

------------------------------------------------------------------------
--	CandyBuckets
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	if CandyBucketsTooltipFrame then
		AddBorder(CandyBucketsTooltipFrame)
		return true
	end
end)

------------------------------------------------------------------------
--	Clique
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	if CliqueSpellTab then
		AddBorder(CliqueSpellTab)
		return true
	end
end)

------------------------------------------------------------------------
--	CoolLine
------------------------------------------------------------------------
tinsert(applyFuncs, function()
	if CoolLine then
		-- print("Adding border to CoolLine")
		AddBorder(CoolLine, nil, -1)
--[[
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
]]
		return true
	end
end)
------------------------------------------------------------------------
--	DockingStation
------------------------------------------------------------------------
--[[
tinsert(applyFuncs, function()
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
]]
------------------------------------------------------------------------
--	Forte_Cooldown
------------------------------------------------------------------------
--[[
tinsert(applyFuncs, function()
	if FWCDFrame then
		-- print("Adding border to Forte_Cooldown")
		AddBorder(FWCDFrame, nil, nil, true)
		return true
	end
end)
]]
------------------------------------------------------------------------
--	Grid
------------------------------------------------------------------------

tinsert(applyFuncs, function()
--[[
	if GridLayoutFrame then
		GridLayoutFrame.texture:SetTexture("")
		GridLayoutFrame.texture:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 0)
		GridLayoutFrame.texture:Hide()

		AddBorder(GridLayoutFrame, -9)

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
--	InFlight
------------------------------------------------------------------------
--[[
tinsert(applyFuncs, function()
	if InFlight and InFlight.CreateBar then
		hooksecurefunc(InFlight, "CreateBar", function()
			-- print("Adding border to InFlight")
			AddBorder(InFlightBar)
		end)
		return true
	end
end)
]]
------------------------------------------------------------------------
--	LauncherMenu
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	local dataobj = LibStub and LibStub("LibDataBroker-1.1", true) and LibStub("LibDataBroker-1.1"):GetDataObjectByName("LauncherMenu")
	if dataobj then
		local OnClick = dataobj.OnClick
		dataobj.OnClick = function(frame)
			OnClick(frame)
			dataobj.OnClick = OnClick
			for i = UIParent:GetNumChildren(), 1, -1 do -- go backwards since it's probably the last one
				local f = select(i, UIParent:GetChildren())
				if f.anchorFrame == frame then
					AddBorder(f)
					break
				end
			end
		end
		return true
	end
end)

------------------------------------------------------------------------
--	Omen
------------------------------------------------------------------------
--[[
tinsert(applyFuncs, function()
	if OmenBarList then
		-- print("Adding border to Omen")
		AddBorder(OmenBarList)
		return true
	end
end)
]]
------------------------------------------------------------------------
--	PetBattleTeams
------------------------------------------------------------------------
--[[
tinsert(applyFuncs, function()
	if PetBattleTeamsRosterFrame then
		-- print("Adding borders to PetBattleTeams")
		for i, teamFrames in pairs(PetBattleTeamsRosterFrame.scrollChild.teamFrames) do
			for j, unitFrames in pairs(teamFrames.unitFrames) do
				for k, unitFrame in pairs(unitFrames) do
					AddBorder(unitFrame)
				end
			end
		end
		return true
	end
end)
]]
------------------------------------------------------------------------
--	PetJournalEnhanced
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	local PetJournalEnhanced = LibStub and LibStub("AceAddon-3.0", true) and LibStub("AceAddon-3.0"):GetAddon("PetJournalEnhanced", true)
	if not PetJournalEnhanced then return end
	--print("Adding borders to PetJournalEnhanced")

	local PetList = PetJournalEnhanced:GetModule("PetList")
	local Sorting = PetJournalEnhanced:GetModule("Sorting")

	local function UpdatePetList()
		--print("UpdatePetList")
		local scrollFrame = PetList.listScroll
		local buttons = scrollFrame.buttons
		local offset = HybridScrollFrame_GetOffset(scrollFrame)
		local isWild = PetJournal.isWild
		for i = 1, #buttons do
			local button = buttons[i]
			local index = offset + i
			AddBorder(button.dragButton, nil, 2)
			if index <= Sorting:GetNumPets() then
				local mappedPet = Sorting:GetPetByIndex(index)
				local petID, _, isOwned, _, _, _, _, name, _, _, _, _, _, _, canBattle = C_PetJournal.GetPetInfoByIndex(mappedPet.index, isWild)
				local colored
				if isOwned and canBattle then
					local _, _, _, _, rarity = C_PetJournal.GetPetStats(petID)
					if rarity and rarity > 2 then
						local color = ITEM_QUALITY_COLORS[rarity - 1]
						button.dragButton:SetBorderColor(color.r, color.g, color.b)
						colored = true
					end
				end
				if not colored then
					button.dragButton:SetBorderColor()
				end
			end
		end
	end

	hooksecurefunc(PetList, "PetJournal_UpdatePetList", UpdatePetList)
	hooksecurefunc(PetList.listScroll, "update", UpdatePetList)

	return true
end)

------------------------------------------------------------------------
--	PetTracker
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	if not PetTracker then return end
	--print("Adding borders to PetTracker")

	-- Add border to tracker bar
	local bar = PetTracker.Objectives.Bar
	bar:SetHeight(16)
	bar.Overlay.BorderLeft:SetTexture("")
	bar.Overlay.BorderRight:SetTexture("")
	bar.Overlay.BorderCenter:SetTexture("")
	AddBorder(bar.Overlay)

	local EnemyActions = PetTracker.EnemyActions
	for i = 1, EnemyActions:GetNumChildren() do
		local button = select(i, EnemyActions:GetChildren())
		AddBorder(button, nil, 2)
	end

	if Addon.isPhanx then
		for i = 1, bar:GetNumChildren() do
			local child = select(i, bar:GetChildren())
			if child:IsObjectType("StatusBar") then
				local r, g, b = child:GetStatusBarColor()
				child:SetStatusBarTexture(config.statusbar)
				child:SetStatusBarColor(r, g, b)
				child:SetAlpha(0.75)
			end
		end

		-- Move enemy action buttons to micro button area
		local _, parent = EnemyActions:GetPoint(1)
		EnemyActions:ClearAllPoints()
		EnemyActions:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 32, -30)

		-- Remove the micro buttons from the pet battle UI
		local okparents = {
			BT4BarMicroMenu = true,
			MainMenuBarArtFrame = true,
		}
		hooksecurefunc("UpdateMicroButtonsParent", function(parent)
			--print("UpdateMicroButtonsParent", parentGetName() or UNKNOWN)
			if InCombatLockdown() or okparents[parent and parent:GetName() or UNKNOWN] then
				return
			end
			MainMenuBar:GetScript("OnShow")(MainMenuBar)
		end)
	end

	return true
end)

------------------------------------------------------------------------
--	PetTracker_Broker
------------------------------------------------------------------------
-- sowohl X als auch Y = X as well as Y, both X and Y
-- sondern = but rather, "he is not old, but young", B negates A
-- aber = but, "he is old, but handsome", B does not negate A
tinsert(applyFuncs, function()
	if not PetTracker_BrokerTip then return end

	-- print("Adding borders to PetTracker_Broker")
	AddBorder(PetTracker_BrokerTip)

	local bar = select(2, PetTracker_BrokerTip:GetChildren()).Bar
	bar.Overlay.BorderLeft:SetTexture("")
	bar.Overlay.BorderRight:SetTexture("")
	bar.Overlay.BorderCenter:SetTexture("")
	AddBorder(bar.Overlay, 12)

	if Addon.isPhanx then
		for i = 1, bar:GetNumChildren() do
			local child = select(i, bar:GetChildren())
			if child:IsObjectType("StatusBar") then
				local r, g, b = child:GetStatusBarColor()
				child:SetStatusBarTexture(config.statusbar)
				child:SetStatusBarColor(r, g, b)
				child:SetAlpha(0.75)
			end
		end
	end

	return true
end)

------------------------------------------------------------------------
--	QuestPointer
------------------------------------------------------------------------
--[[
tinsert(applyFuncs, function()
	if QuestPointerTooltip then
		-- print("Adding border to QuestPointerTooltip")
		AddBorder(QuestPointerTooltip)
		return true
	end
end)
]]
------------------------------------------------------------------------
--	SexyCooldown
------------------------------------------------------------------------
--[[
tinsert(applyFuncs, function()
	if SexyCooldown and SexyCooldown.bars then
		-- print("Adding borders to SexyCooldown")
		local color = config.useClassColor and (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))]
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
]]
------------------------------------------------------------------------
--	TomTom
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	if TomTomTooltip then
		-- print("Adding border to TomTomTooltip")
		AddBorder(TomTomTooltip)
		return true
	end
end)

------------------------------------------------------------------------
--	Touhin
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	local Touhin = LibStub and LibStub("AceAddon-3.0", true) and LibStub("AceAddon-3.0"):GetAddon("Touhin", true)
	if not Touhin then return end

	local origSetRow = {}

	local function SetRow(self, icon, color, text, hightlightColor)
		if not origSetRow[self] then
			--print("Adding border to new Touhin frame.")
			origSetRow[self] = self.SetRow
			self.SetRow = SetRow

			Touhin.db.profile.edgeFile = "None"
			Touhin.db.profile.insets = 0

			self:SetBackdrop(nil)

			self.background:ClearAllPoints()
			self.background:SetAllPoints(true)
			local color = Touhin.db.profile.bgColor
			self.background:SetVertexColor(color.r, color.g, color.b, 1)
			self.background.SetVertexColor = noop

			self.iconFrame:SetBackdrop(nil)

			self.icon:SetParent(self)
			self.icon:ClearAllPoints()
			self.icon:SetPoint("TOPLEFT")
			self.icon:SetPoint("BOTTOMLEFT")
			self.icon:SetWidth(self:GetHeight())

			AddBorder(self)
		end

		if not icon then return end

		origSetRow[self](self, icon, color, text, hightlightColor)
		self:SetWidth(self:GetWidth() + 5)

		if not highlightColor then
			self:SetBorderColor()
		end
	end

	local function ProcessorigSetRow()
		local f = EnumerateFrames()
		while f do
			if (not f.IsForbidden or not f:IsForbidden()) and f:GetParent() == UIParent and not f:GetName()
			and f.background and f.iconFrame and f.icon and f.rollIcon and f.text and f.fader and f.SetRow then
				if not origSetRow[f] then
					SetRow(f)
				end
			end
			f = EnumerateFrames(f)
		end
	end

	hooksecurefunc(Touhin, "AddCoin", ProcessorigSetRow)
	hooksecurefunc(Touhin, "AddCurrency", ProcessorigSetRow)
	hooksecurefunc(Touhin, "AddLoot", ProcessorigSetRow)
end)

------------------------------------------------------------------------
--	TourGuide
------------------------------------------------------------------------
--[[
tinsert(applyFuncs, function()
	if TourGuide and TourGuide.statusframe then
		-- print("Adding border to TourGuide status frame")
		AddBorder(TourGuide.statusframe)
		AddBorder(TourGuideItemFrame)
		return true
	end
end)
]]