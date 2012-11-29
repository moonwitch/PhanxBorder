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
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
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
	end
end)

------------------------------------------------------------------------
--	Blizzard frames
------------------------------------------------------------------------

local TOOLTIP_BACKDROP = {
	bgFile = [[Interface\BUTTONS\WHITE8X8]], tile = true, tileSize = 8,
	edgeFile = [[Interface\BUTTONS\WHITE8X8]], edgeSize = 2,
	insets = { left = 0, right = 0, top = 0, bottom = 0 },
}

local borderedTooltips = {
	"BattlePetTooltip",
	"FloatingBattlePetTooltip",
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

table.insert(applyFuncs, function()
	for i = #borderedTooltips, 1, -1 do
		local f = _G[borderedTooltips[i]]
		if f then
			for _, region in pairs(borderedTooltipRegions) do
				BattlePetTooltip[region]:SetTexture(nil)
				FloatingBattlePetTooltip[region]:SetTexture(nil)
				QueueStatusFrame[region]:SetTexture(nil)
			end
			f:SetBackdrop(TOOLTIP_BACKDROP)
			f.SetBackdrop = noop
			f:SetBackdropColor(0, 0, 0, 0.9)
			f.SetBackdropColor = noop
			table.remove(borderedTooltips, i)
		end
	end
	if #borderedTooltips == 0 then
		borderedTooltips = nil
		borderedTooltipRegions = nil
		return true
	end
end)

table.insert(applyFuncs, function()
	for i, f in pairs({
		"GhostFrame",
		"LFDSearchStatus",
		"Minimap",
		"QueueStatusFrame",
		"TicketStatusFrame",

		"DropDownList1MenuBackdrop",
		"DropDownList2MenuBackdrop",

		"BattlePetTooltip",
		"ConsolidatedBuffsTooltip",
		"FloatingBattlePetTooltip",
		"FriendsTooltip",
		"GameTooltip",
		"ItemRefShoppingTooltip1",
		"ItemRefShoppingTooltip2",
		"ItemRefShoppingTooltip3",
		"ItemRefTooltip",
		"MovieRecordingFrameTextTooltip1",
		"MovieRecordingFrameTextTooltip2",
		"PartyMemberBuffTooltip",
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

	GhostFrameLeft:Hide()
	GhostFrameMiddle:Hide()
	GhostFrameRight:Hide()
	GhostFrame:SetBackdrop(TOOLTIP_BACKDROP)
	GhostFrame:SetBackdropColor(0, 0, 0, 0.8)
	GhostFrame:SetScript("OnMouseDown", nil)
	GhostFrame:SetScript("OnMouseUp", nil)

	for i, f in pairs({
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
	}) do
		-- print("Adding border to " .. f)
		AddBorder(_G[f], nil, 4)
	end

	-- Spellbook/companion buttons
	local function Button_OnDisable( button )
		button:SetAlpha(0)
	end
	local function Button_OnEnable( button )
		button:SetAlpha(1)
	end

	-- Spellbook
	for i = 1, 12 do
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

	-- Core Abilities
	hooksecurefunc("SpellBook_UpdateCoreAbilitiesTab", function()
		for i, button in ipairs(SpellBookCoreAbilitiesFrame.Abilities) do
			button.FutureTexture:SetTexture("")
			button.Name:SetFont("Interface\\AddOns\\PhanxMedia\\font\\DejaWeb-Bold.ttf", 16)
			AddBorder(button)
		end
	end)

	return true
end)

table.insert(applyFuncs, function()
	if EventTraceTooltip then
		AddBorder(EventTraceTooltip)
		return true
	end
end)

table.insert(applyFuncs, function()
	if FrameStackTooltip then
		AddBorder(FrameStackTooltip)
		return true
	end
end)

table.insert(applyFuncs, function()
	if PetJournal then
		for _, region in pairs({
			"Background",
			"BorderBottom",
			"BorderBottomLeft",
			"BorderBottomRight",
			"BorderLeft",
			"BorderRight",
			"BorderTop",
			"BorderTopLeft",
			"BorderTopRight",
		}) do
			PetBattlePrimaryAbilityTooltip[region]:Hide()
			PetBattlePrimaryUnitTooltip[region]:Hide()
			PetJournalPrimaryAbilityTooltip[region]:Hide()
			PetJournalSecondaryAbilityTooltip[region]:Hide()
		end

		PetBattlePrimaryAbilityTooltip:SetBackdrop(GameTooltip:GetBackdrop())
		PetBattlePrimaryUnitTooltip:SetBackdrop(GameTooltip:GetBackdrop())
		PetJournalPrimaryAbilityTooltip:SetBackdrop(GameTooltip:GetBackdrop())
		PetJournalSecondaryAbilityTooltip:SetBackdrop(GameTooltip:GetBackdrop())

		AddBorder(PetBattlePrimaryAbilityTooltip)
		AddBorder(PetBattlePrimaryUnitTooltip)
		AddBorder(PetJournalPrimaryAbilityTooltip)
		AddBorder(PetJournalSecondaryAbilityTooltip)

		PetBattleFrame:HookScript("OnShow", function()
			AddBorder(PetBattleFrame.BottomFrame.abilityButtons[1], nil, 4)
			AddBorder(PetBattleFrame.BottomFrame.abilityButtons[2], nil, 4)
			AddBorder(PetBattleFrame.BottomFrame.abilityButtons[3], nil, 4)
			AddBorder(PetBattleFrame.BottomFrame.SwitchPetButton, nil, 4)
			AddBorder(PetBattleFrame.BottomFrame.CatchButton, nil, 4)
			AddBorder(PetBattleFrame.BottomFrame.ForfeitButton, nil, 4)
		end)

		AddBorder(PetJournalHealPetButton, nil, 2)
		PetJournalHealPetButtonBorder:SetTexture("")

		local f = CreateFrame("Frame", nil, PetJournalPetCard)
		f:SetAllPoints(PetJournalPetCardPetInfoIcon)
		AddBorder(f, nil, 1)
		PetJournalPetCardPetInfoIcon.borderFrame = f

		for i = 1, 6 do
			local button = _G["PetJournalPetCardSpell"..i]
			AddBorder(button, nil, 4)
		end

		for i = 1, 3 do
			for j = 1, 3 do
				local button = _G["PetJournalLoadoutPet"..i.."Spell"..j]
				AddBorder(button, nil, 4)
			end
		end

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
		hooksecurefunc(PetJournalListScrollFrame, "SetVerticalScroll", UpdateButtonBorders)
		hooksecurefunc("PetJournal_UpdatePetList", function()
			UpdateButtonBorders(PetJournalListScrollFrame)
		end)

		hooksecurefunc("MountJournal_UpdateMountList", function()
			UpdateButtonBorders(MountJournalListScrollFrame)
		end)

		return true
	end
end)