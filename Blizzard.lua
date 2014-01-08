--[[--------------------------------------------------------------------
	PhanxBorder
	World of Warcraft user interface addon:
	Adds shiny borders to things.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
----------------------------------------------------------------------]]

local _, PhanxBorder = ...
local _, _, _, Masque = GetAddOnInfo("Masque")
local AddBorder = PhanxBorder.AddBorder
local AddShadow = PhanxBorder.AddShadow
local config = PhanxBorder.config
local noop = function() end

local applyFuncs = { }

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
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
	elseif event == "PLAYER_LOGIN" then
		self:RegisterEvent("ADDON_LOADED")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
end)

local BACKDROP = {
	bgFile = [[Interface\BUTTONS\WHITE8X8]], tile = true, tileSize = 8,
	edgeFile = [[Interface\BUTTONS\WHITE8X8]], edgeSize = 2,
	insets = { left = 0, right = 0, top = 0, bottom = 0 },
}

------------------------------------------------------------------------
--	Bordered tooltips
------------------------------------------------------------------------

local borderedTooltips = {
	"BattlePetTooltip",
	"FloatingBattlePetTooltip",
	"LFDSearchStatus",
	"PetBattlePrimaryAbilityTooltip",
	"PetBattlePrimaryUnitTooltip",
	"PetJournalPrimaryAbilityTooltip",
	"PetJournalSecondaryAbilityTooltip",
	"QueueStatusFrame",
}

local borderedTooltipRegions = {
	"Background",
	"BorderBottom",
	"BorderBottomLeft",
	"BorderBottomRight",
	"BorderLeft",
	"BorderRight",
	"BorderTop",
	"BorderTopLeft",
	"BorderTopRight",
}

tinsert(applyFuncs, function()
	for i = #borderedTooltips, 1, -1 do
		local f = _G[borderedTooltips[i]]
		if f then
			--print("Adding border to", borderedTooltips[i])
			for _, region in pairs(borderedTooltipRegions) do
				f[region]:Hide()
			end
			f:SetBackdrop(GameTooltip:GetBackdrop())
			AddBorder(f)
			tremove(borderedTooltips, i)
		end
	end
	if #borderedTooltips == 0 then
		borderedTooltips = nil
		borderedTooltipRegions = nil
		return true
	end
end)

------------------------------------------------------------------------
--	FrameXML
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	for frame, offset in pairs({
		["GhostFrame"] = 4,
		["HelpFrameCharacterStuckHearthstone"] = false,
		["Minimap"] = false,
		["TicketStatusFrame"] = false,

		["DropDownList1MenuBackdrop"] = false,
		["DropDownList2MenuBackdrop"] = false,

		["ConsolidatedBuffsTooltip"] = false,
		["FriendsTooltip"] = false,
		["GameTooltip"] = false,
		["ItemRefShoppingTooltip1"] = false,
		["ItemRefShoppingTooltip2"] = false,
		["ItemRefShoppingTooltip3"] = false,
		["ItemRefTooltip"] = false,
		["MovieRecordingFrameTextTooltip1"] = false,
		["MovieRecordingFrameTextTooltip2"] = false,
		["PartyMemberBuffTooltip"] = false,
		["ShoppingTooltip1"] = false,
		["ShoppingTooltip2"] = false,
		["ShoppingTooltip3"] = false,
		["SmallTextTooltip"] = false,
		["VideoOptionsTooltip"] = false,
		["WorldMapCompareTooltip1"] = false,
		["WorldMapCompareTooltip2"] = false,
		["WorldMapCompareTooltip3"] = false,
		["WorldMapTooltip"] = false,

		["MerchantRepairItemButton"] = 3,
		["MerchantRepairAllButton"] = 3,
		["MerchantBuyBackItemItemButton"] = 5,

		["PrimaryProfession1SpellButtonBottom"] = 3,
		["PrimaryProfession1SpellButtonTop"] = 3,
		["PrimaryProfession2SpellButtonBottom"] = 3,
		["PrimaryProfession2SpellButtonTop"] = 3,
		["SecondaryProfession1SpellButtonLeft"] = 3,
		["SecondaryProfession1SpellButtonRight"] = 3,
		["SecondaryProfession2SpellButtonLeft"] = 3,
		["SecondaryProfession2SpellButtonRight"] = 3,
		["SecondaryProfession3SpellButtonLeft"] = 3,
		["SecondaryProfession3SpellButtonRight"] = 3,
		["SecondaryProfession4SpellButtonLeft"] = 3,
		["SecondaryProfession4SpellButtonRight"] = 3,
	}) do
		-- print("Adding border to " .. frame)
		AddBorder(_G[frame], nil, offset)
		if strmatch(frame, "aryProfession") then
			_G[frame.."NameFrame"]:SetTexture("")
		end
	end

	GhostFrame:SetWidth(140)
	GhostFrame:SetBackdrop(BACKDROP)
	GhostFrame:SetBackdropColor(0, 0, 0, 0.8)
	GhostFrameLeft:SetTexture("")
	GhostFrameRight:SetTexture("")
	GhostFrameMiddle:SetTexture("")
	GhostFrameContentsFrameIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

	---------------------------------------------------------------------
	--	Character frame
	---------------------------------------------------------------------

	for _, slot in pairs({
		"CharacterHeadSlot",
		"CharacterNeckSlot",
		"CharacterShoulderSlot",
		"CharacterBackSlot",
		"CharacterChestSlot",
		"CharacterShirtSlot",
		"CharacterTabardSlot",
		"CharacterWristSlot",
		"CharacterHandsSlot",
		"CharacterWaistSlot",
		"CharacterLegsSlot",
		"CharacterFeetSlot",
		"CharacterFinger0Slot",
		"CharacterFinger1Slot",
		"CharacterTrinket0Slot",
		"CharacterTrinket1Slot",
		"CharacterMainHandSlot",
		"CharacterSecondaryHandSlot",
	}) do
		PhanxBorder.AddBorder(_G[slot], nil, 5)
		_G[slot.."Frame"]:SetTexture("")
	end

	select(10, CharacterMainHandSlot:GetRegions()):SetTexture("")
	select(10, CharacterSecondaryHandSlot:GetRegions()):SetTexture("")

	hooksecurefunc("PaperDollItemSlotButton_Update", function(self)
		if not self.BorderTextures then return end

		if not self.levelText then
			self.levelText = self:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
			self.levelText:SetPoint("BOTTOMRIGHT")
		end

		local id = GetInventoryItemID("player", self:GetID())
		if id then
			local _, _, rarity, level = GetItemInfo(id)
			self.levelText:SetText(level or "")
			if rarity > 1 then
				local color = ITEM_QUALITY_COLORS[rarity]
				self.levelText:SetTextColor(color.r, color.g, color.b)
				return self:SetBorderColor(color.r, color.g, color.b)
			end
		end

		self.levelText:SetText("")
		self:SetBorderColor()
	end)

	hooksecurefunc("PaperDollItemSlotButton_OnEnter", function(self)
		if not self.BorderTextures then return end

		local _, class = UnitClass("player")
		local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
		self:SetBorderColor(color.r, color.g, color.b)
	end)

	hooksecurefunc("PaperDollItemSlotButton_OnLeave", function(self)
		if not self.BorderTextures then return end
		PaperDollItemSlotButton_Update(self)
	end)


	---------------------------------------------------------------------
	-- Mailbox
	---------------------------------------------------------------------

	for i = 1, 7 do
		AddBorder(_G["MailItem"..i.."Button"])
	end

	for i = 1, 12 do
		AddBorder(_G["OpenMailAttachmentButton"..i])
		AddBorder(_G["SendMailAttachment"..i])
	end

	---------------------------------------------------------------------
	-- Merchant frame
	---------------------------------------------------------------------

	MerchantBuyBackItemNameFrame:SetTexture("")

	for i = 1, 12 do
		AddBorder(_G["MerchantItem"..i.."ItemButton"])
	end

	---------------------------------------------------------------------
	-- Pet stable
	---------------------------------------------------------------------

	for i = 1, 10 do
		AddBorder(_G["PetStableStabledPet"..i])
	end

	---------------------------------------------------------------------
	-- Quest frames
	---------------------------------------------------------------------

	local function AddItemBorder(f)
		AddBorder(f)
		local icon = f.icon or f.Icon or _G[f:GetName().."IconTexture"]
		local name = f.name or f.Name or _G[f:GetName().."Name"]
		if icon then
			icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		end
		if name then
			name:SetFontObject("QuestFontNormalSmall")
			_G[f:GetName().."NameFrame"]:SetTexture("")
		end
	end

	AddItemBorder(QuestInfoRewardSpell)
	QuestInfoRewardSpellSpellBorder:SetTexture("")

	AddItemBorder(QuestInfoSkillPointFrame)

	for i = 1, MAX_NUM_ITEMS do
		AddItemBorder(_G["QuestInfoItem"..i])
	end

	hooksecurefunc("QuestInfo_Display", function()
		QuestInfoRewardSpell:SetBorderSize(nil, -3, -102, 4, -8)

		QuestInfoSkillPointFrame:SetBorderSize()

		for i = 1, MAX_NUM_ITEMS do
			local f = _G["QuestInfoItem"..i]
			f:SetBorderSize(nil, 3, -104, 3, 3)
			local colored
			if f.type then
				local link = GetQuestItemLink(f.type, i)
				if link then
					local _, _, quality = GetItemInfo(link)
					if quality and quality > 1 then
						local color = ITEM_QUALITY_COLORS[quality]
						f:SetBorderColor(color.r, color.g, color.b)
						colored = true
					end
				end
			end
			if not colored then
				f:SetBorderColor()
			end
		end
	end)

	hooksecurefunc("QuestInfo_ShowRewards", function()
		print("QuestInfo_ShowRewards")
	end)

	for i = 1, MAX_REQUIRED_ITEMS do
		AddItemBorder(_G["QuestProgressItem"..i])
	end

	hooksecurefunc("QuestFrameProgressItems_Update", function()
		print("QuestFrameProgressItems_Update") -- #TODO
		for i = 1, MAX_REQUIRED_ITEMS do
			local f = _G["QuestProgressItem"..i]
			f:SetBorderSize(nil, 4, -102, 4, 3)
			local colored
			if f:IsShown() then
			end
			if not colored then
				f:SetBorderColor()
			end
		end
	end)

	---------------------------------------------------------------------
	-- Static popups
	---------------------------------------------------------------------

	AddBorder(StaticPopup1ItemFrame)

	---------------------------------------------------------------------
	-- Trade window
	---------------------------------------------------------------------

	for i = 1, 7 do
		AddBorder(_G["TradePlayerItem"..i.."ItemButton"])
		AddBorder(_G["TradeRecipientItem"..i.."ItemButton"])
	end

	hooksecurefunc("TradeFrame_UpdatePlayerItem", function(id)
		local link = GetTradePlayerItemLink(id)
		if link then
			local _, _, quality = GetItemInfo(link)
			if quality and quality > 1 then
				local color = ITEM_QUALITY_COLORS[quality]
				return _G["TradePlayerItem"..i.."ItemButton"]:SetBorderColor(color.r, color.g, color.b)
			end
		end
		_G["TradePlayerItem"..i.."ItemButton"]:SetBorderColor()
	end)

	hooksecurefunc("TradeFrame_UpdateTargetItem", function(id)
		local _, _, _, quality = GetTradeTargetItemInfo(id)
		if quality and quality > 1 then
			local color = ITEM_QUALITY_COLORS[quality]
			_G["TradeRecipientItem"..i.."ItemButton"]:SetBorderColor(color.r, color.g, color.b)
		else
			_G["TradeRecipientItem"..i.."ItemButton"]:SetBorderColor()
		end
	end)

	---------------------------------------------------------------------
	-- Spellbook
	---------------------------------------------------------------------

	for i = 1, 5 do
		AddBorder(_G["SpellBookSkillLineTab"..i])
	end

	local function Button_OnDisable(self)
		self:SetAlpha(0)
	end
	local function Button_OnEnable(self)
		self:SetAlpha(1)
	end

	for i = 1, SPELLS_PER_PAGE do
		local button = _G["SpellButton" .. i]
		AddBorder(button)
		button.SpellName:SetFont(config.font, 16)
		button.EmptySlot:SetTexture("")
		button.UnlearnedFrame:SetTexture("")
		_G["SpellButton" .. i .. "SlotFrame"]:SetTexture("") -- swirly thing
		_G["SpellButton" .. i .. "IconTexture"]:SetTexCoord(0.06, 0.94, 0.06, 0.94)
		button:HookScript("OnDisable", Button_OnDisable)
		button:HookScript("OnEnable", Button_OnEnable)
	end

	hooksecurefunc("SpellBook_UpdateCoreAbilitiesTab", function()
		for i = 1, #SpellBookCoreAbilitiesFrame.Abilities do
			local button = SpellBookCoreAbilitiesFrame.Abilities[i]
			if not button.BorderTextures then
				AddBorder(button)
				button.iconTexture:SetTexCoord(0.05, 0.95, 0.05, 0.95)
				button.Name:SetFont(config.font, 16)
				button.FutureTexture:SetTexture("")
				select(3, button:GetRegions()):SetTexture("") -- swirly thing
				local a, b, c, x, y = button.Name:GetPoint(1)
				button.Name:SetPoint(a, b, c, x, 3)
			end
		end
	end)

	---------------------------------------------------------------------
	-- Done!
	---------------------------------------------------------------------

	return true
end)

------------------------------------------------------------------------
--	Blizzard_DebugTools
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	if EventTraceTooltip then
		AddBorder(EventTraceTooltip)
		AddBorder(FrameStackTooltip)
		return true
	end
end)

------------------------------------------------------------------------
--	Blizzard_GlyphUI
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	if not GlyphFrame_UpdateGlyphList then return end

	hooksecurefunc("GlyphFrame_UpdateGlyphList", function()
		local buttons = GlyphFrame.scrollFrame.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			AddBorder(button)
			button:SetBorderSize(nil, 3, -118, 3, 3)
			button.icon:SetDrawLayer("ARTWORK")
		end
	end)

	return true
end)

------------------------------------------------------------------------
--	Blizzard_PetBattleUI
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	if not PetBattleFrame then return end

	hooksecurefunc("PetBattleFrame_UpdateAllActionButtons", function(self)
		--print("PetBattleFrame_UpdateAllActionButtons")
		local f = self.BottomFrame
		if f.CatchButton.BorderTextures then return end

		AddBorder(f.CatchButton, nil, 4)
		AddBorder(f.ForfeitButton, nil, 4)
		AddBorder(f.SwitchPetButton, nil, 4)

		for i = 1, #f.abilityButtons do
			AddBorder(f.abilityButtons[i], nil, 4)
		end
	end)

	-- Fix battle pet ability selection glow not appearing after the first turn
	hooksecurefunc("PetBattleActionButton_UpdateState", function(self)
		if not self.SelectedHighlight then return end
		local actionType, actionIndex = self.actionType, self.actionIndex
		local selectedType, selectedIndex = C_PetBattles.GetSelectedAction()
		self.SelectedHighlight:SetShown(selectedType and selectedType == actionType and (not actionIndex or selectedIndex == actionIndex))
	end)

	return true
end)

------------------------------------------------------------------------
--	Blizzard_PetJournal
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	if not MountJournalListScrollFrame then return end

	local function qualityBorder_SetVertexColor(self, r, g, b)
		self:GetParent().dragButton:SetBorderColor(r, g, b)
	end

	---------------------------------------------------------------------
	-- Mount Journal
	---------------------------------------------------------------------

	local function FixTexture(icon, texture)
		if texture == "Interface\\PetBattles\\MountJournalEmptyIcon" then
			icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
			icon:GetParent():Hide()
		else
			icon:SetTexCoord(0, 1, 0, 1)
			icon:GetParent():Show()
		end
	end
	for i = 1, #MountJournalListScrollFrame.buttons do
		local button = MountJournalListScrollFrame.buttons[i]
		AddBorder(button.DragButton, nil, 4)
		hooksecurefunc(button.icon, "SetTexture", FixTexture)
	end

	---------------------------------------------------------------------
	-- Pet Journal
	---------------------------------------------------------------------

	AddBorder(PetJournalHealPetButton)
	PetJournalHealPetButtonBorder:SetTexture("")

	do
		local f = PetJournalPetCardPetInfo

		local iconFrame = CreateFrame("Frame", nil, f)
		iconFrame:SetAllPoints(f.icon)
		AddBorder(iconFrame, nil, 4)

		f.favorite:SetParent(iconFrame)
		f.levelBG:SetParent(iconFrame)
		f.level:SetParent(iconFrame)

		f.dragButton = iconFrame
		hooksecurefunc(f.qualityBorder, "SetVertexColor", qualityBorder_SetVertexColor)
	end

	for i = 1, 6 do
		AddBorder(_G["PetJournalPetCardSpell"..i], nil, 4)
	end

	for i = 1, 2 do
		AddBorder(_G["PetJournalSpellSelectSpell"..i], nil, 4)
		select(i, PetJournalSpellSelect:GetRegions()):SetTexture("")
	end

	for i = 1, 3 do
		local f = _G["PetJournalLoadoutPet"..i]
		AddBorder(f.dragButton, nil, 4)
		f.levelBG:SetParent(f.dragButton)
		f.level:SetParent(f.dragButton)
		hooksecurefunc(f.qualityBorder, "SetVertexColor", qualityBorder_SetVertexColor)

		for j = 1, 3 do
			AddBorder(_G["PetJournalLoadoutPet"..i.."Spell"..j])
		end
	end

	local function IconBorder_SetVertexColor(iconBorder, ...)
		return iconBorder:GetParent().dragButton:SetBorderColor(...)
	end

	for i = 1, #PetJournalListScrollFrame.buttons do
		local button = PetJournalListScrollFrame.buttons[i]
		AddBorder(button.dragButton, nil, 4)
		button.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
		button.iconBorder.SetVertexColor = IconBorder_SetVertexColor
		button.iconBorder.Hide = IconBorder_SetVertexColor
	end

	return true
end)

------------------------------------------------------------------------
--	Blizzard_TalentUI
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	if not PlayerTalentFrame then return end

	AddBorder(PlayerTalentFrameSpecializationSpellScrollFrameScrollChildAbility1, nil, -4)
	PlayerTalentFrameSpecializationSpellScrollFrameScrollChildAbility1.ring:Hide()

	hooksecurefunc("PlayerTalentFrame_CreateSpecSpellButton", function(self, index)
		local f = self.spellsScroll.child["abilityButton"..index]
		AddBorder(f, nil, -4)
		f.ring:Hide()
	end)

	for row = 1, 6 do
		for col = 1, 3 do
			local button = _G["PlayerTalentFrameTalentsTalentRow"..row.."Talent"..col]
			AddBorder(button)
			button:SetBorderSize(nil, -30, -110, 0, 0)
		end
	end

	return true
end)