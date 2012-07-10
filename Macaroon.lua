local cfg = {
	textures = {
		normal            = "Interface\\AddOns\\rActionButtonStyler\\media\\gloss",
		flash             = "Interface\\AddOns\\rActionButtonStyler\\media\\flash",
		hover             = "Interface\\AddOns\\rActionButtonStyler\\media\\hover",
		pushed            = "Interface\\AddOns\\rActionButtonStyler\\media\\pushed",
		checked           = "Interface\\AddOns\\rActionButtonStyler\\media\\checked",
		equipped          = "Interface\\AddOns\\rActionButtonStyler\\media\\gloss_grey",
		buttonback        = "Interface\\AddOns\\rActionButtonStyler\\media\\button_background",
		buttonbackflat    = "Interface\\AddOns\\rActionButtonStyler\\media\\button_background_flat",
		outer_shadow      = "Interface\\AddOns\\rActionButtonStyler\\media\\outer_shadow",
	},
	background = {
		showbg            = true,  -- show an background image?
		showshadow        = true,  -- show an outer shadow?
		useflatbackground = false, -- true uses plain flat color instead
		backgroundcolor   = { r = 0.2, g = 0.2, b = 0.2, a = 0.3},
		shadowcolor       = { r = 0, g = 0, b = 0, a = 0.9},
		inset             = 5,
	},
	color = {
		normal            = { r = 0.4, g = 0.4, b = 0.4 }, -- { r = 0.37, g = 0.3, b = 0.3, },
		equipped          = { r = 0.1, g = 0.5, b = 0.1, },
	},
	cooldown = {
		spacing         = 0,
	},
}

local BACKDROP = {
	bgFile = cfg.background.useflatbackground and cfg.textures.buttonbackflat or nil,
	tile = false, tileSize = 32,
	edgeFile = cfg.background.showshadow and cfg.textures.outer_shadow or nil,
	edgeSize = cfg.background.inset,
	insets = {
		left = cfg.background.inset,
		right = cfg.background.inset,
		top = cfg.background.inset,
		bottom = cfg.background.inset
	}
}

local inhookUB
local function UpdateButton(button)
	if inhookUB then return end
	inhookUB = true

	local action = button.action
	if action and IsEquippedAction(action) then
		button:SetNormalTexture(cfg.textures.equipped)
		button:GetNormalTexture():SetVertexColor(cfg.color.equipped.r,cfg.color.equipped.g,cfg.color.equipped.b,1)
	else
		button:SetNormalTexture(cfg.textures.normal)
		button:GetNormalTexture():SetVertexColor(cfg.color.normal.r,cfg.color.normal.g,cfg.color.normal.b,1)
	end

	inhookUB = nil
end

local inhookSVC
local function SetVertexColor(texture, r, g, b, a)
	if inhookSVC then return end
	inhookSVC = true

	local button = texture:GetParent()
	local action = button.action
	if r == 0.5 and g == 0.5 and b == 1 then
		-- OOM
		texture:SetVertexColor(cfg.color.normal.r,cfg.color.normal.g,cfg.color.normal.b,1)
	elseif r == 1 and g == 1 and b == 1 then
		if action and IsEquippedAction(action) then
			-- Equipped
			texture:SetVertexColor(cfg.color.equipped.r,cfg.color.equipped.g,cfg.color.equipped.b,1)
		else
			texture:SetVertexColor(cfg.color.normal.r,cfg.color.normal.g,cfg.color.normal.b,1)
		end
	end

	inhookSVC = nil
end

local function SkinButton(button)
--[[
	PhanxBorder.AddBorder(button)

	local border = button.BorderTextures
	local d = border[1]:GetWidth() / 2 - 6
	border[1]:SetPoint("TOPLEFT", button, -2 - d, 2 + d)
	border[2]:SetPoint("TOPRIGHT", button, 2 + d, 2 + d)
	border[4]:SetPoint("BOTTOMLEFT", button, -2 - d, -2 - d)
	border[5]:SetPoint("BOTTOMRIGHT", button, 2 + d, -2 - d)
]]
	local border = button.border
	border:SetTexture(nil)

	local hotkey = button.hotkey
	hotkey:ClearAllPoints()
	hotkey:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 4)

	local name = button.macroname
	name:Hide()
	name.Show = name.Hide

	local count = button.count
	count:ClearAllPoints()
	count:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

	local flash = button.flash
	flash:SetTexture(cfg.textures.flash)

	button:SetHighlightTexture(cfg.textures.hover)
	button:SetPushedTexture(cfg.textures.pushed)
	button:SetCheckedTexture(cfg.textures.checked)
	button:SetNormalTexture(cfg.textures.normal)

	button.iconframe:SetFrameLevel(2)

	local icon = button.iconframeicon
	icon:ClearAllPoints()
	icon:SetPoint("TOPLEFT", button, 4, -4)
	icon:SetPoint("BOTTOMRIGHT", button, -4, 4)
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

	local cd = button.iconframecooldown
	cd:ClearAllPoints()
	cd:SetPoint("TOPLEFT", button, 2, -2)
	cd:SetPoint("BOTTOMRIGHT", button, -2, 2)

	local normal = button:GetNormalTexture()
	normal:SetAllPoints(button)
	button.normal = normal

	if not button.hooked_SetVertexColor then
		hooksecurefunc(normal, "SetVertexColor", function(n,...)
			-- print("SetVertexColor")
			SetVertexColor(n,...)
		end)
		button.hooked_SetVertexColor = true
	end
--[[
	if not button.hooked_update and type(button.update) == "function" then
		hooksecurefunc(button, "update", function(b)
			-- print("update")
			UpdateButton(b)
		end)
		button.hooked_update = true
	end

	if not button.hooked_updateData and type(button.updateData) == "function" then
		hooksecurefunc(button, "updateData", function(b)
			-- print("updateData")
			UpdateButton(b)
		end)
		button.hooked_updateData = true
	end

	if not button.hooked_SetNormalTexture then
		hooksecurefunc(button, "SetNormalTexture", function(b)
			-- print("SetNormalTexture")
			UpdateButton(b)
		end)
		button.hooked_SetNormalTexture = true
	end
]]
	if not button.hooked_normal then
		hooksecurefunc(normal, "SetTexture", function(n)
			-- print("SetTexture")
			UpdateButton(n:GetParent())
		end)
	end

	if button:GetFrameLevel() < 1 then
		button:SetFrameLevel(1)
	end

	local bg = button.bg or CreateFrame("Frame", nil, button)
	bg:ClearAllPoints()
	bg:SetPoint("TOPLEFT", -4, 4)
	bg:SetPoint("BOTTOMRIGHT", 4, -4)
	bg:SetFrameLevel(button:GetFrameLevel() - 1)
	bg:SetBackdrop(BACKDROP)
	bg:SetBackdropBorderColor(cfg.background.shadowcolor.r,cfg.background.shadowcolor.g,cfg.background.shadowcolor.b,cfg.background.shadowcolor.a)
	button.bg = bg

	if cfg.background.showflatbackground then
		local t = bg.t or bg:CreateTexture(nil, "BACKGROUND", -8)
		t:SetTexture(cfg.textures.buttonback)
		t:SetAllPoints(button)
		t:SetVertexColor(cfg.background.backgroundcolor.r,cfg.background.backgroundcolor.g,cfg.background.backgroundcolor.b,cfg.background.backgroundcolor.a)
		bg.t = t
	end
end

local function SkinAll()
	for _, bar in pairs(Macaroon.ButtonBars) do
		if bar.config.buttonList then
			for _, btnIDList in pairs(bar.config.buttonList) do
				for btnID in btnIDList:gmatch("[^;]+") do
					local button = _G[bar.btnType .. btnID]
					if button and not button.BorderTextures then
						SkinButton(button)
					end
				end
			end
		end
	end
end

local function SkinMacaroon()
	if ButtonFacade or (LibStub and LibStub("Masque", true)) then
		return true
	end

	-- print("Adding borders to Macaroon")

	hooksecurefunc(Macaroon, "SetButtonType", function(b)
		-- print("SetButtonType")
		SkinButton(b)
	end)
	hooksecurefunc(Macaroon, "SetButtonUpdate", function(b)
		-- print("SetButtonUpdate")
		SkinButton(b)
	end)

	for _, f in ipairs({ "Button_OnLoad", "CreateButton", "CreateNewBar", "Initialize", "LoadConfig", "Save", "SetButtonType", "SetNewButton", "UpdateConfig", "UpdateShape" }) do
		if type(Macaroon[f]) == "function" then
			hooksecurefunc(Macaroon, f, function()
				-- print(f)
				SkinAll()
			end)
		end
	end
	return true
end

if Macaroon then
	SkinMacaroon()
else
	local f = CreateFrame("Frame")
	f:RegisterEvent("ADDON_LOADED")
	f:SetScript("OnEvent", function()
		if Macaroon and SkinMacaroon() then
			f:UnregisterAllEvents()
			f:SetScript("OnEvent", nil)
		end
	end)
end

--[[
<CheckButton>
	<Texture name="$parentFlash" file="Interface\Buttons\UI-QuickslotRed">
	<Texture name="$parentFlyoutArrow" parentKey="FlyoutArrow">
	<Texture name="$parentFlyoutBorder" parentKey="FlyoutBorder">
	<Texture name="$parentFlyoutBorderShadow" parentKey="FlyoutBorderShadow">
	<FontString name="$parentMacroName" inherits="GameFontHighlightSmallOutline">
	<Texture name="$parentBorder" file="Interface\Buttons\UI-ActionButton-Border" alphaMode="ADD">
	<Texture name="$parentGloss" file="" hidden="false" alphaMode="ADD">
	<Texture name="$parentFlyoutTop" file="Interface\AddOns\Macaroon\Images\flyout.tga">
	<Texture name="$parentFlyoutBottom" file="Interface\AddOns\Macaroon\Images\flyout.tga">
	<Texture name="$parentFlyoutLeft" file="Interface\AddOns\Macaroon\Images\flyout.tga">
	<Texture name="$parentFlyoutRight" file="Interface\AddOns\Macaroon\Images\flyout.tga">
	<FontString name="$parentHotKey" parentKey="hotkey">
	<FontString name="$parentCount">
	<Texture name="$parentAutoCastable" file="Interface\Buttons\UI-AutoCastableOverlay">
	<Frame name="$parentIconFrame">
		<Texture name="$parentIcon">
		<Texture name="$parentBackGround">
		<Cooldown name="$parentCooldown" inherits="CooldownFrameTemplate">
			<FontString name="$parentTimer" parentKey="timer">
		<Cooldown name="$parentAuraWatch" inherits="CooldownFrameTemplate" reverse="true">
			<FontString name="$parentTimer" parentKey="timer">
	<Frame name="$parentShine" inherits="AutoCastShineTemplate">
	<NormalTexture name="$parentNormalTexture" file="Interface\Buttons\UI-Quickslot">
	<PushedTexture name="$parentPushedTexture" file="Interface\Buttons\UI-Quickslot-Depress">
	<HighlightTexture name="$parentHighlightTexture" file="Interface\Buttons\ButtonHilight-Square" alphaMode="ADD">
	<CheckedTexture name="$parentCheckedTexture" file="Interface\Buttons\CheckButtonHilight" alphaMode="ADD">
</CheckButton>
--]]