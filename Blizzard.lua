--[[--------------------------------------------------------------------
	PhanxBorder
	World of Warcraft user interface addon:
	Adds shiny borders to things.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
----------------------------------------------------------------------]]

local ADDON, Addon = ...
local Masque = IsAddOnLoaded("Masque")
local AddBorder = Addon.AddBorder
local AddShadow = Addon.AddShadow
local config = Addon.config
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

local _, PLAYER_CLASS = UnitClass("player")
local function ColorByClass(frame, class)
	local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class or PLAYER_CLASS]
	frame:SetBorderColor(color.r, color.g, color.b)
end
Addon.ColorByClass = ColorByClass

local function ColorByItemQuality(frame, quality, link)
	if not frame.BorderTextures then
		AddBorder(frame)
	end
	if not quality then
		local _
		_, _, quality = GetItemInfo(link or 0)
	end
	if quality and quality > 1 then
		local color = ITEM_QUALITY_COLORS[quality]
		frame:SetBorderColor(color.r, color.g, color.b)
		return true
	else
		frame:SetBorderColor()
	end
end
Addon.ColorByItemQuality = ColorByItemQuality

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
		["GhostFrame"] = 2,
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
		["MerchantBuyBackItemItemButton"] = 1,

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
	-- Bags
	---------------------------------------------------------------------
	-- TODO: test
	hooksecurefunc("ContainerFrame_Update", function(self)
		local bag = self:GetID()
		local name = self:GetName()
		for slot = 1, self.size do
			local button = _G[name.."Item"..slot]
			local link = GetContainerItemLink(bag, slot)
			ColorByItemQuality(button, nil, link)
		end
		--[[
		local id = self:GetID()
		local name = self:GetName()
		local size = self.size

		for i=1, size do
			local bid = size - i + 1
			local slotFrame = _G[name .. 'Item' .. bid]
			local slotLink = GetContainerItemLink(id, i)

			oGlow:CallFilters('bags', slotFrame, _E and slotLink)
		end
		]]
	end)

	---------------------------------------------------------------------
	--	Bank
	---------------------------------------------------------------------

	hooksecurefunc("BankFrameItemButton_Update", function(button)
		local link = GetContainerItemLink(BANK_CONTAINER, button:GetID())
		ColorByItemQuality(button, nil, link)
	end)

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
		Addon.AddBorder(_G[slot], nil, 1)
		_G[slot.."Frame"]:SetTexture("")
	end

	select(10, CharacterMainHandSlot:GetRegions()):SetTexture("")
	select(10, CharacterSecondaryHandSlot:GetRegions()):SetTexture("")

	local function ColorPaperDollItemSlot(self)
		if not self.BorderTextures then return end
		local item = GetInventoryItemID("player", self:GetID())
		ColorByItemQuality(self, nil, item)
	end

	hooksecurefunc("PaperDollItemSlotButton_Update", ColorPaperDollItemSlot)
	hooksecurefunc("PaperDollItemSlotButton_OnLeave", ColorPaperDollItemSlot)
	hooksecurefunc("PaperDollItemSlotButton_OnEnter", function(self)
		if not self.BorderTextures then return end
		ColorByClass(self)
	end)

	hooksecurefunc("EquipmentFlyout_Show", function(parent)
		local f = EquipmentFlyoutFrame.buttonFrame
		for i = 1, f.numBGs do
			f["bg"..i]:SetTexture("")
		end
	end)

	hooksecurefunc("EquipmentFlyout_DisplayButton", function(self)
		AddBorder(self)
		self:SetBorderSize(nil, 1) -- scale is wrong on load

		local location = self.location
		if location and location < EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
			local player, bank, bags, _, slot, bag = EquipmentManager_UnpackLocation(location)
			if player or bank or bags then
				local link = bags and GetContainerItemID(bag, slot) or GetInventoryItemID("player", slot)
				return ColorByItemQuality(self, nil, link)
			end
		end

		self:SetBorderColor()
	end)

	---------------------------------------------------------------------
	-- Loot
	---------------------------------------------------------------------
	-- TODO: test
	hooksecurefunc("LootFrame_UpdateButton", function(index)
		local button = _G["LootButton"..index]
		ColorByItemQuality(button, button:IsEnabled() and button.quality)
	end)

	---------------------------------------------------------------------
	-- Mailbox
	---------------------------------------------------------------------

	local mailInboxButtons, mailOpenButtons, mailSendButtons = {}, {}, {}

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local button = _G["MailItem"..i.."Button"]
		mailInboxButtons[i] = button
		AddBorder(button)

		--_G["MailItem"..i.."ButtonIcon"]:SetTexCoord()
	end

	hooksecurefunc("InboxFrame_Update", function()
		local numItems = GetInboxNumItems()
		local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY) + 1

		for i = 1, INBOXITEMS_TO_DISPLAY do
			local best = 0
			if index <= numItems then
				for j = 1, ATTACHMENTS_MAX_RECEIVE do
					-- GetInboxItem is bugged since 2.3.3 (lol) and always returns quality -1
					-- local _, _, _, quality = GetInboxItem(index, j)
					local link = GetInboxItemLink(index, j)
					local _, _, quality = GetItemInfo(link or 0)
					best = quality and quality > best and quality or best
				end
			end
			ColorByItemQuality(mailInboxButtons[i], best)
			index = index + 1
		end
	end)

	for i = 1, ATTACHMENTS_MAX_RECEIVE do
		local button = _G["OpenMailAttachmentButton"..i]
		mailOpenButtons[i] = button
		AddBorder(button)
	end

	hooksecurefunc("OpenMail_Update", function()
		if not InboxFrame.openMailID then return end

		for i = 1, ATTACHMENTS_MAX_RECEIVE do
			-- GetInboxItem is bugged since 2.3.3 (lol) and always returns quality -1
			-- local _, _, _, quality = GetInboxItem(InboxFrame.openMailID, i)
			local link = GetInboxItemLink(InboxFrame.openMailID, i)
			ColorByItemQuality(mailOpenButtons[i], nil, link)
		end
	end)

	for i = 1, ATTACHMENTS_MAX_SEND do
		local button = _G["SendMailAttachment"..i]
		mailSendButtons[i] = button
		button:GetRegions():SetTexCoord(0, 0.62, 0, 0.61) -- empty slot texture
		AddBorder(button)
	end

	hooksecurefunc("SendMailFrame_Update", function()
		if not SendMailFrame:IsShown() then return end

		for i = 1, ATTACHMENTS_MAX_SEND do
			-- GetSendMailItem is bugged since 2.3.3 (lol) and always returns quality -1
			-- local _, _, quality = GetSendMailItem(i)
			local link = GetSendMailItemLink(i)
			ColorByItemQuality(mailSendButtons[i], nil, link)
		end
	end)

	---------------------------------------------------------------------
	-- Merchant frame
	---------------------------------------------------------------------

	MerchantBuyBackItemNameFrame:SetTexture("")

	hooksecurefunc("MerchantFrame_Update", function()
		if not MerchantFrame:IsShown() then return end
		if MerchantFrame.selectedTab == 1 then
			for i = 1, MERCHANT_ITEMS_PER_PAGE do
				local index = i + ((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE)
				local link = GetMerchantItemLink(index)
				ColorByItemQuality(_G["MerchantItem"..i.."ItemButton"], nil, link)
			end

			local link = GetBuybackItemLink(GetNumBuybackItems())
			ColorByItemQuality(MerchantBuyBackItemItemButton, nil, link)
		else
			for i = 1, BUYBACK_ITEMS_PER_PAGE do
				local link = GetBuybackItemLink(i)
				ColorByItemQuality(_G["MerchantItem"..i.."ItemButton"], nil, link)
			end
		end
	end)

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
		-- Have to set border sizes here because scale is weird OnLoad?
		--QuestInfoRewardSpell:SetBorderSize(nil, -3, -103, 4, -8)
		QuestInfoSkillPointFrame:SetBorderSize(nil, -1, 112, 2, 3)
		for i = 1, MAX_NUM_ITEMS do
			local f = _G["QuestInfoItem"..i]
			f:SetBorderSize(nil, 2, 109, 2, 3)

			local link = f.type and (QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(f.type, f:GetID())
			ColorByItemQuality(f, nil, link)
		end
	end)

	hooksecurefunc("QuestInfo_ShowRewards", function()
		print("QuestInfo_ShowRewards")
		-- TODO: does this ever fire?
	end)

	for i = 1, MAX_REQUIRED_ITEMS do
		local f = _G["QuestProgressItem"..i]
		AddItemBorder(f)
		f:SetBorderSize(nil, 2, 107, 1, 2)
	end

	hooksecurefunc("QuestFrameProgressItems_Update", function()
		for i = 1, MAX_REQUIRED_ITEMS do
			local f = _G["QuestProgressItem"..i]
			local link = f.type and GetQuestItemLink(f.type, f:GetID())
			ColorByItemQuality(f, nil, link)
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
		button.EmptySlot:SetTexture("")
		button.UnlearnedFrame:SetTexture("")
		_G["SpellButton" .. i .. "SlotFrame"]:SetTexture("") -- swirly thing
		_G["SpellButton" .. i .. "IconTexture"]:SetTexCoord(0.06, 0.94, 0.06, 0.94)
		button:HookScript("OnDisable", Button_OnDisable)
		button:HookScript("OnEnable", Button_OnEnable)
		if config.isPhanx then
			button.SpellName:SetFont(config.font, 16)
		end
	end

	hooksecurefunc("SpellBook_UpdateCoreAbilitiesTab", function()
		for i = 1, #SpellBookCoreAbilitiesFrame.Abilities do
			local button = SpellBookCoreAbilitiesFrame.Abilities[i]
			if not button.BorderTextures then
				AddBorder(button)
				button.iconTexture:SetTexCoord(0.05, 0.95, 0.05, 0.95)
				button.FutureTexture:SetTexture("")
				select(3, button:GetRegions()):SetTexture("") -- swirly thing
				local a, b, c, x, y = button.Name:GetPoint(1)
				button.Name:SetPoint(a, b, c, x, 3)
				if config.isPhanx then
					button.Name:SetFont(config.font, 16)
				end
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
		ColorByItemQuality(_G["TradePlayerItem"..i.."ItemButton"], nil, link)
	end)

	hooksecurefunc("TradeFrame_UpdateTargetItem", function(id)
		local _, _, _, quality = GetTradeTargetItemInfo(id)
		ColorByItemQuality(_G["TradeRecipientItem"..i.."ItemButton"], quality)
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
			if not button.BorderTextures then
				AddBorder(button)
				button:SetBorderSize(nil, 3, 125, 4, 4)
				button.icon:SetDrawLayer("ARTWORK")
			end
		end
	end)

	return true
end)

------------------------------------------------------------------------
--	Blizzard_GuildBankUI
------------------------------------------------------------------------

tinsert(applyFuncs, function()
	if not GuildBankFrame then return end

	hooksecurefunc("GuildBankFrame_ShowColumns", function()
		local tab = GetCurrentGuildBankTab()
		for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
			local row = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)
			if row == 0 then
				row = NUM_SLOTS_PER_GUILDBANK_GROUP
			end
			local col = ceil((i - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
			local button = _G["GuildBankColumn"..col.."Button"..row]
			local link = GetGuildBankItemLink(tab, i)
			ColorByItemQuality(button, nil, link)
		end
	end)

	return true
end)

------------------------------------------------------------------------
--	Blizzard_InspectUI
------------------------------------------------------------------------
-- TODO: test
tinsert(applyFuncs, function()
	if not InspectPaperDollItemSlotButton_Update then return end

	hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
		local item = GetInventoryItemID(InspectFrame.unit, button:GetID())
		ColorByItemQuality(button, nil, item)
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

		AddBorder(f.CatchButton, nil, 2)
		AddBorder(f.ForfeitButton, nil, 2)
		AddBorder(f.SwitchPetButton, nil, 2)

		for i = 1, #f.abilityButtons do
			AddBorder(f.abilityButtons[i], nil, 2)
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
		AddBorder(button.DragButton, nil, 2)
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
		AddBorder(iconFrame, nil, 2)

		f.favorite:SetParent(iconFrame)
		f.levelBG:SetParent(iconFrame)
		f.level:SetParent(iconFrame)

		f.dragButton = iconFrame
		hooksecurefunc(f.qualityBorder, "SetVertexColor", qualityBorder_SetVertexColor)
	end

	for i = 1, 6 do
		AddBorder(_G["PetJournalPetCardSpell"..i], nil, 2)
	end

	for i = 1, 2 do
		AddBorder(_G["PetJournalSpellSelectSpell"..i], nil, 2)
		select(i, PetJournalSpellSelect:GetRegions()):SetTexture("")
	end

	for i = 1, 3 do
		local f = _G["PetJournalLoadoutPet"..i]
		AddBorder(f.dragButton, nil, 2)
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
		AddBorder(button.dragButton, nil, 2)
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

	AddBorder(PlayerTalentFrameSpecializationSpellScrollFrameScrollChildAbility1, nil, 10)
	PlayerTalentFrameSpecializationSpellScrollFrameScrollChildAbility1.ring:Hide()

	hooksecurefunc("PlayerTalentFrame_CreateSpecSpellButton", function(self, index)
		local f = self.spellsScroll.child["abilityButton"..index]
		AddBorder(f, nil, 10)
		f.ring:Hide()
	end)

	for row = 1, 6 do
		for col = 1, 3 do
			local button = _G["PlayerTalentFrameTalentsTalentRow"..row.."Talent"..col]
			AddBorder(button)
			button:SetBorderSize(nil, 36, 116, 6, 6)
		end
	end

	return true
end)

---------------------------------------------------------------------
-- Blizzard_TradeSkillUI
---------------------------------------------------------------------

tinsert(applyFuncs, function()
	if not TradeSkillFrame then return end

	AddBorder(TradeSkillSkillIcon, nil, 1)

	hooksecurefunc("TradeSkillFrame_SetSelection", function(i)
		local link = GetTradeSkillItemLink(i)
		ColorByItemQuality(TradeSkillSkillIcon, nil, link)

		for j = 1, GetTradeSkillNumReagents(i) do
			local button = _G["TradeSkillReagent"..j]
			local link = GetTradeSkillReagentItemLink(i, j)
			ColorByItemQuality(button, nil, link)
			button:SetBorderSize(nil, 0, 107, 0, 3)
		end
	end)

	return true
end)

---------------------------------------------------------------------
-- Blizzard_VoidStorageUI
---------------------------------------------------------------------

tinsert(applyFuncs, function()
	if not VoidStorage_ItemsUpdate then return end

	hooksecurefunc("VoidStorage_ItemsUpdate", function(doDeposit, doContents)
		if doDeposit then
			for i = 1, VOID_DEPOSIT_MAX do
				local button = _G["VoidStorageDepositButton"..i]
				local item = GetVoidTransferDepositInfo(i)
				ColorByItemQuality(button, nil, item)
			end
		end
		if doContents then
			for i = 1, VOID_WITHDRAW_MAX do
				local button = _G["VoidStorageWithdrawButton"..i]
				local item = GetVoidTransferWithdrawalInfo(i)
				ColorByItemQuality(button, nil, item)
			end
			for i = 1, VOID_STORAGE_MAX do
				local button = _G["VoidStorageStorageButton"..i]
				local item = GetVoidItemInfo(i)
				ColorByItemQuality(button, nil, item)
			end
		end
	end)

	return true
end)