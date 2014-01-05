--[[--------------------------------------------------------------------
	PhanxBorder
	World of Warcraft user interface addon:
	Adds shiny borders to things.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
----------------------------------------------------------------------]]

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
--	Miscellaneous frames
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
	end

	GhostFrame:SetWidth(140)
	GhostFrame:SetBackdrop(BACKDROP)
	GhostFrame:SetBackdropColor(0, 0, 0, 0.8)
	GhostFrameLeft:SetTexture("")
	GhostFrameRight:SetTexture("")
	GhostFrameMiddle:SetTexture("")
	GhostFrameContentsFrameIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

	--	Character frame
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


	-- Mailbox
	for i = 1, 12 do
		AddBorder(_G["OpenMailAttachmentButton"..i])
		AddBorder(_G["SendMailAttachment"..i])
	end
	for i = 1, 7 do
		AddBorder(_G["MailItem"..i.."Button"])
	end

	-- Merchant frame
	for i = 1, 12 do
		AddBorder(_G["MerchantItem"..i.."ItemButton"])
	end

	-- Pet stable
	for i = 1, 10 do
		AddBorder(_G["PetStableStabledPet"])
	end

	-- Quests
	AddBorder(QuestInfoSkillPointFrame)
	for i = 1, MAX_NUM_ITEMS do
		local f = _G["QuestInfoItem"..i]
		f.name:SetFontObject("QuestFontNormalSmall")
		_G["QuestInfoItem"..i.."NameFrame"]:SetTexture("")

		local iconFrame = CreateFrame("Frame", nil, f)
		iconFrame:SetAllPoints(f.icon)
		AddBorder(iconFrame, nil, 3)
		f.iconFrame = iconFrame
	end
	hooksecurefunc("QuestInfo_Display", function()
		for i = 1, MAX_NUM_ITEMS do
			local f = _G["QuestInfoItem"..i]
			local colored
			if f.type then
				local link = GetQuestItemLink(f.type, i)
				if link then
					local _, _, quality = GetItemInfo(link)
					if quality and quality > 1 then
						local color = ITEM_QUALITY_COLORS[quality]
						f.iconFrame:SetBorderColor(color.r, color.g, color.b)
						colored = true
					end
				end
			end
			if not colored then
				f.iconFrame:SetBorderColor()
			end
		end
	end)
	for i = 1, MAX_REQUIRED_ITEMS do
		local f = _G["QuestProgressItem"..i]
		f.name:SetFontObject("QuestFontNormalSmall")
		_G["QuestProgressItem"..i.."NameFrame"]:SetTexture("")

		local iconFrame = CreateFrame("Frame", nil, f)
		iconFrame:SetAllPoints(f.icon)
		AddBorder(iconFrame, nil, 3)
		f.iconFrame = iconFrame
	end
	hooksecurefunc("QuestFrameProgressItems_Update", function()
		print("QuestFrameProgressItems_Update") -- #TODO
		for i = 1, MAX_REQUIRED_ITEMS do
			local f = _G["QuestProgressItem"..i]
			local colored
			if f:IsShown() then

			end
			if not colored then
				f.iconFrame:SetBorderColor()
			end
		end
	end)

	-- Static popups
	AddBorder(StaticPopup1ItemFrame)

	-- Trade window
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

	-- Spellbook side tabs
	for i = 1, 5 do
		AddBorder(_G["SpellBookSkillLineTab"..i])
	end

	-- Spellbook/companion buttons
	local function Button_OnDisable(self)
		self:SetAlpha(0)
	end
	local function Button_OnEnable(self)
		self:SetAlpha(1)
	end

	-- Spellbook
	for i = 1, SPELLS_PER_PAGE do
		local button = _G["SpellButton" .. i]
		AddBorder(button)
		button:HookScript("OnDisable", Button_OnDisable)
		button:HookScript("OnEnable", Button_OnEnable)
		button.SpellName:SetFont("Interface\\AddOns\\PhanxMedia\\font\\DejaWeb-Bold.ttf", 16)
		button.EmptySlot:SetTexture("")
		button.UnlearnedFrame:SetTexture("")
		_G["SpellButton" .. i .. "SlotFrame"]:SetTexture("")
		_G["SpellButton" .. i .. "IconTexture"]:SetTexCoord(0.06, 0.94, 0.06, 0.94)
	end

	-- Spellbook / Core Abilities
	hooksecurefunc("SpellBook_UpdateCoreAbilitiesTab", function()
		for i, button in ipairs(SpellBookCoreAbilitiesFrame.Abilities) do
			button.FutureTexture:SetTexture("")
			button.Name:SetFont("Interface\\AddOns\\PhanxMedia\\font\\DejaWeb-Bold.ttf", 16)
			AddBorder(button)
		end
	end)

	return true
end)

tinsert(applyFuncs, function()
	if not PlayerTalentFrame then return end
	for row = 1, 6 do
		for col = 1, 3 do
			local button = _G["PlayerTalentFrameTalentsTalentRow"..row.."Talent"..col]
			local frame = CreateFrame("Frame", nil, button)
			frame:SetAllPoints(button.icon)
			AddBorder(frame, nil, 4)
		end
	end
	return true
end)

tinsert(applyFuncs, function()
	if not MountJournalListScrollFrame then return end

	-- Mount Journal
	for i = 1, #MountJournalListScrollFrame.buttons do
		local button = MountJournalListScrollFrame.buttons[i]
		AddBorder(button.DragButton, nil, 4)
	end

	-- Pet Journal
	AddBorder(PetJournalHealPetButton)
	PetJournalHealPetButtonBorder:SetTexture("")

	for i = 1, 6 do
		AddBorder(_G["PetJournalPetCardSpell"..i], nil, 4)
	end

	for i = 1, 2 do
		AddBorder(_G["PetJournalSpellSelectSpell"..i], nil, 4)
		select(i, PetJournalSpellSelect:GetRegions()):SetTexture("")
	end

	local function qualityBorder_SetVertexColor(self, r, g, b)
		self:GetParent().dragButton:SetBorderColor(r, g, b)
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

	local f = PetJournalPetCardPetInfo
	local iconFrame = CreateFrame("Frame", nil, f)
	iconFrame:SetAllPoints(f.icon)
	AddBorder(iconFrame, nil, 4)
	f.favorite:SetParent(iconFrame)
	f.levelBG:SetParent(iconFrame)
	f.level:SetParent(iconFrame)
	f.dragButton = iconFrame
	hooksecurefunc(f.qualityBorder, "SetVertexColor", qualityBorder_SetVertexColor)

	return true
end)

tinsert(applyFuncs, function()
	if EventTraceTooltip then
		AddBorder(EventTraceTooltip)
		return true
	end
end)

tinsert(applyFuncs, function()
	if FrameStackTooltip then
		AddBorder(FrameStackTooltip)
		return true
	end
end)

--[[
tinsert(applyFuncs, function()
		PetBattleFrame:HookScript("OnShow", function()
			AddBorder(PetBattleFrame.BottomFrame.abilityButtons[1], nil, 4)
			AddBorder(PetBattleFrame.BottomFrame.abilityButtons[2], nil, 4)
			AddBorder(PetBattleFrame.BottomFrame.abilityButtons[3], nil, 4)
			AddBorder(PetBattleFrame.BottomFrame.SwitchPetButton, nil, 4)
			AddBorder(PetBattleFrame.BottomFrame.CatchButton, nil, 4)
			AddBorder(PetBattleFrame.BottomFrame.ForfeitButton, nil, 4)
		end)

		local function AddButtonBorder(button)
			local f = CreateFrame("Frame", nil, button)
			f:SetAllPoints(button.icon)
			button.iconBorderFrame = f

			AddBorder(f, nil, 3)

			button.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)

			if button.iconBorder then
				function button.iconBorder:SetVertexColor(...) return f:SetBorderColor(...) end
				function button.iconBorder:Hide() return f:SetBorderColor() end
			end

			if button.dragButton then
				button.dragButton.levelBG:SetParent(f)
				button.dragButton.level:SetParent(f)
			end
		end

		local function UpdateButtonBorders(scrollFrame)
			local offset = HybridScrollFrame_GetOffset(scrollFrame)
			for i, button in ipairs(scrollFrame.buttons) do
				if not button.BorderTextures then
					AddButtonBorder(button)
				end
				if button.dragButton then
					local petID, rarity, _ = button.petID
					if petID then
						_, _, _, _, rarity = C_PetJournal.GetPetStats(petID)
					end
					if rarity then
						local color = ITEM_QUALITY_COLORS[rarity - 1]
						button.name:SetTextColor(color.r, color.g, color.b)
						button.iconBorderFrame:SetBorderColor(color.r, color.g, color.b)
					else
						local color = ITEM_QUALITY_COLORS[0]
						button.name:SetTextColor(color.r, color.g, color.b)
						button.iconBorderFrame:SetBorderColor(color.r, color.g, color.b)
					end
				end
			end
		end

		PetJournalListScrollFrame:HookScript("OnShow", UpdateButtonBorders)
		PetJournalListScrollFrame:HookScript("OnMouseWheel", UpdateButtonBorders)
		PetJournalListScrollFrameScrollBarScrollDownButton:HookScript("OnClick", function(self)
			UpdateButtonBorders(PetJournalListScrollFrame)
		end)
		PetJournalListScrollFrameScrollBarScrollUpButton:HookScript("OnClick", function(self)
			UpdateButtonBorders(PetJournalListScrollFrame)
		end)
		hooksecurefunc("PetJournal_UpdatePetList", function()
			UpdateButtonBorders(PetJournalListScrollFrame)
		end)

		hooksecurefunc("MountJournal_UpdateMountList", function()
			UpdateButtonBorders(MountJournalListScrollFrame)
		end)

		return true
	end
end)
]]