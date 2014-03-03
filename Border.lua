--[[--------------------------------------------------------------------
	PhanxBorder
	World of Warcraft user interface addon:
	Adds shiny borders to things.
	Copyright (c) 2008-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
----------------------------------------------------------------------]]

local ADDON, Addon = ...
_G[ADDON] = Addon

local isPhanx = select(6, GetAddOnInfo("PhanxMedia")) ~= "MISSING"

local config = {
	border = {
		color = { r = 0.47, g = 0.47, b = 0.47, a = 1 },
		texture = [[Interface\AddOns\PhanxBorder\Textures\Border]], -- SimpleSquare]]
		size = 16,
	},
	shadow = {
		color = { r = 0, g = 0, b = 0, a = 1 },
		texture = [[Interface\AddOns\PhanxBorder\Textures\GlowOuter]],
		size = 1.5,
	},
	backdrop = {
		color = { r = 136/255, g = 149/255, b = 169/255, a = 1 },
		texture = [[Interface\FrameGeneral\UI-Background-Rock]],
		size = 256,
	},
	font = oUFPhanxConfig and oUFPhanxConfig.font or isPhanx and [[Interface\AddOns\PhanxMedia\font\DejaWeb-Bold.ttf]] or [[Fonts\FRIZQT__.ttf]],
	statusbar = oUFPhanxConfig and oUFPhanxConfig.statusbar or isPhanx and [[Interface\AddOns\PhanxMedia\statusbar\BlizzStone2]] or [[Interface\TargetingFrame\UI-StatusBar]],
	useClassColor = true,
}

------------------------------------------------------------------------
--	GTFO.
------------------------------------------------------------------------

local noop = function() end
local points = { "TOPLEFT", "TOP", "TOPRIGHT", "RIGHT", "BOTTOMRIGHT", "BOTTOM", "BOTTOMLEFT", "LEFT" }

------------------------------------------------------------------------
--	BORDER
------------------------------------------------------------------------

local borderedFrames = {}

local function ScaleBorder(self, scale)
	return self:SetBorderSize(self.BorderSize)
end

function Addon.AddBorder(self, size, offset, forceBG, shadow)
	assert(type(self) == "table", "AddBorder: 'self' is not a table!")
	assert(type(rawget(self, 0)) == "userdata", "AddBorder: 'self' is not a valid frame!")
	assert(type(self.CreateTexture) == "function", "AddBorder: 'self' is missing a 'CreateTexture' method!")
	assert(type(self.IsForbidden) ~= "function" or not self:IsForbidden(), "AddBorder: 'self' is a forbidden frame!")
	if self.BorderTextures then return end

	local t = {}
	self.BorderTextures = t

	for i = 1, #points do
		local point = points[i]
		t[point] = self:CreateTexture(nil, "OVERLAY")
		t[point]:SetTexture(config.border.texture)
	end

	t.TOPLEFT:SetTexCoord(0, 1/3, 0, 1/3)
	t.TOP:SetTexCoord(1/3, 2/3, 0, 1/3)
	t.TOPRIGHT:SetTexCoord(2/3, 1, 0, 1/3)
	t.RIGHT:SetTexCoord(2/3, 1, 1/3, 2/3)
	t.BOTTOMRIGHT:SetTexCoord(2/3, 1, 2/3, 1)
	t.BOTTOM:SetTexCoord(1/3, 2/3, 2/3, 1)
	t.BOTTOMLEFT:SetTexCoord(0, 1/3, 2/3, 1)
	t.LEFT:SetTexCoord(0, 1/3, 1/3, 2/3)

	if self.SetBackdropBorderColor then
		local backdrop = self:GetBackdrop()
		if type(backdrop) == "table" then
			local r, g, b, a = self:GetBackdropColor()
			backdrop.edgeFile = nil
			if backdrop.insets then
				backdrop.insets.top = 0
				backdrop.insets.right = 0
				backdrop.insets.bottom = 0
				backdrop.insets.left = 0
			end
			self:SetBackdrop(backdrop)
			self:SetBackdropColor(r, g, b, a)
		end


		if forceBG then
			self.SetBackdrop = noop
			self.SetBackdropColor = noop
			self.SetBackdropBorderColor = noop
		else
			self.SetBackdropBorderColor = Addon.SetBorderColor
		end
	end

	do
		local icon = self.Icon or self.icon
		if type(icon) == "table" and icon.SetTexCoord then
			icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
		end
	end

	self.GetBorderAlpha  = Addon.GetBorderAlpha
	self.SetBorderAlpha  = Addon.SetBorderAlpha

	self.GetBorderColor  = Addon.GetBorderColor
	self.SetBorderColor  = Addon.SetBorderColor

	self.GetBorderLayer  = Addon.GetBorderLayer
	self.SetBorderLayer  = Addon.SetBorderLayer

	self.GetBorderParent = Addon.GetBorderParent
	self.SetBorderParent = Addon.SetBorderParent

	self.GetBorderSize   = Addon.GetBorderSize
	self.SetBorderSize   = Addon.SetBorderSize

	if self.SetScale then
		hooksecurefunc(self, "SetScale", ScaleBorder)
	end

	if shadow then
		Addon.AddShadow(self)
	end

	tinsert(borderedFrames, self)

	self:SetBorderColor()
	self:SetBorderSize(size, offset)
end

------------------------------------------------------------------------

function Addon.SetBorderAlpha(self, a)
	if type(self) ~= "table" or not self.BorderTextures then return end
	if not a then
		a = config.border.color.a
	end
	for i = 1, #points do
		self.BorderTextures[points[i]]:SetAlpha(a)
	end
end

function Addon.GetBorderAlpha(self)
	if type(self) ~= "table" or not self.BorderTextures then return end
	return self.BorderTextures.TOPLEFT:GetAlpha()
end

------------------------------------------------------------------------

function Addon.SetBorderColor(self, r, g, b)
	if type(self) ~= "table" or not self.BorderTextures then return end
	if not r or not g or not b then
		r, g, b = config.border.color.r, config.border.color.g, config.border.color.b
	end
	for i = 1, #points do
		self.BorderTextures[points[i]]:SetVertexColor(r, g, b)
	end
end

function Addon.GetBorderColor(self)
	if type(self) ~= "table" or not self.BorderTextures then return end
	local r, g, b = self.BorderTextures.TOPLEFT:GetVertexColor()
	return r, g, b
end

------------------------------------------------------------------------

function Addon.SetBorderLayer(self, layer)
	if type(self) ~= "table" or not self.BorderTextures then return end
	if not layer then
		layer = "OVERLAY"
	end
	for i = 1, #points do
		self.BorderTextures[points[i]]:SetDrawLayer(layer)
	end
end

function Addon.GetBorderLayer(self)
	if type(self) ~= "table" or not self.BorderTextures then return end
	return self.BorderTextures.TOPLEFT:GetDrawLayer()
end

------------------------------------------------------------------------

function Addon.SetBorderParent(self, parent)
	if type(self) ~= "table" or not self.BorderTextures then return end
	if not parent then
		parent = self
	end
	for i = 1, #points do
		self.BorderTextures[points[i]]:SetParent(parent)
	end
end

function Addon.GetBorderParent(self)
	if type(self) ~= "table" or not self.BorderTextures then return end
	return self.BorderTextures.TOPLEFT:GetParent()
end

------------------------------------------------------------------------

function Addon.SetBorderSize(self, size, dL, dR, dT, dB)
	if type(self) ~= "table" or not self.BorderTextures then return end
	if not size then
		size = config.border.size
	end
	self.BorderSize = size

	local scale = self:GetEffectiveScale() / UIParent:GetScale()
	if scale ~= 1 then
		size = size * (1 / scale)
	end

	local t = self.BorderTextures
	for i = 1, #points do
		t[points[i]]:SetSize(size, size)
	end

	local offset = floor(size * 0.5) - 2 -- floor(size * 0.25 + 0.5)
	dR = offset - (dR or dL or 0)
	dT = offset - (dT or dL or 0)
	dB = offset - (dB or dL or 0)
	dL = offset - (dL or 0) -- has to be last so it can be a fallback above

	t.TOPLEFT:SetPoint("TOPLEFT", self, -dL, dT)
	t.TOPRIGHT:SetPoint("TOPRIGHT", self, dR, dT)
	t.BOTTOMLEFT:SetPoint("BOTTOMLEFT", self, -dL, -dB)
	t.BOTTOMRIGHT:SetPoint("BOTTOMRIGHT", self, dR, -dB)

	t.TOP:SetPoint("TOPLEFT", t.TOPLEFT, "TOPRIGHT")
	t.TOP:SetPoint("TOPRIGHT", t.TOPRIGHT, "TOPLEFT")

	t.BOTTOM:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "BOTTOMRIGHT")
	t.BOTTOM:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "BOTTOMLEFT")

	t.LEFT:SetPoint("TOPLEFT", t.TOPLEFT, "BOTTOMLEFT")
	t.LEFT:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "TOPLEFT")

	t.RIGHT:SetPoint("TOPRIGHT", t.TOPRIGHT, "BOTTOMRIGHT")
	t.RIGHT:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "TOPRIGHT")
end

function Addon.GetBorderSize(self)
	if type(self) ~= "table" or not self.BorderTextures then return end
	return self.BorderSize or config.border.size
end

------------------------------------------------------------------------

function Addon.WithBorder(self, method, ...)
	for i = 1, #points do
		local tex = self.BorderTextures[points[i]]
		local ret = tex[method](tex, ...)
		if ret then
			return ret
		end
	end
end

------------------------------------------------------------------------
--	SHADOW
------------------------------------------------------------------------

local shadowedFrames = {}

function Addon.AddShadow(self, size, offset)
	if type(self) ~= "table"
	or type(rawget(self, 0)) ~= "userdata"
	or (type(self.IsForbidden) == "function" and self:IsForbidden())
	or type(self.CreateTexture) ~= "function"
	or self.ShadowTextures then return end

	if not self.BorderTextures then
		Addon.AddBorder(self)
	end

	local s = {}
	self.ShadowTextures = s

	for i = 1, #points do
		local point = points[i]
		s[point] = self:CreateTexture(nil, "BACKGROUND")
		s[point]:SetTexture(config.shadow.texture)
	end

	s.TOPLEFT:SetTexCoord(0, 1/3, 0, 1/3)
	s.TOP:SetTexCoord(1/3, 2/3, 0, 1/3)
	s.TOPRIGHT:SetTexCoord(2/3, 1, 0, 1/3)
	s.RIGHT:SetTexCoord(2/3, 1, 1/3, 2/3)
	s.BOTTOMRIGHT:SetTexCoord(2/3, 1, 2/3, 1)
	s.BOTTOM:SetTexCoord(1/3, 2/3, 2/3, 1)
	s.BOTTOMLEFT:SetTexCoord(0, 1/3, 2/3, 1)
	s.LEFT:SetTexCoord(0, 1/3, 1/3, 2/3)

	self.GetShadowAlpha = Addon.GetShadowAlpha
	self.SetShadowAlpha = Addon.SetShadowAlpha

	self.GetShadowColor = Addon.GetShadowColor
	self.SetShadowColor = Addon.SetShadowColor

	self.GetShadowSize  = Addon.GetShadowSize
	self.SetShadowSize  = Addon.SetShadowSize

	self.WithShadow     = Addon.WithShadow

	tinsert(shadowedFrames, self)

	self:SetShadowColor()
	self:SetShadowSize(size, offset)
end

------------------------------------------------------------------------

function Addon.SetShadowAlpha(self, a)
	if type(self) ~= "table" or not self.ShadowTextures then return end
	if not a then
		a = 1
	end
	for i = 1, #points do
		self.ShadowTextures[points[i]]:SetAlpha(a)
	end
end

function Addon.GetShadowAlpha(self)
	if type(self) ~= "table" or not self.ShadowTextures then return end
	return self.ShadowTextures.TOPLEFT:GetAlpha()
end

------------------------------------------------------------------------

function Addon.SetShadowColor(self, r, g, b, a)
	if type(self) ~= "table" or not self.ShadowTextures then return end
	if not r or not g or not b or a == 0 then
		r, g, b, a = config.shadow.color.r, config.shadow.color.g, config.shadow.color.b, config.shadow.color.a
	end
	for i = 1, #points do
		self.ShadowTextures[points[i]]:SetVertexColor(r, g, b)
	end
end

function Addon.GetShadowColor(self)
	if type(self) ~= "table" or not self.ShadowTextures then return end
	return self.ShadowTextures.TOPLEFT:GetVertexColor()
end

------------------------------------------------------------------------

function Addon.SetShadowSize(self, size, dL, dR, dT, dB)
	if type(self) ~= "table" or not self.ShadowTextures then return end

	local s = self.ShadowTextures
	local t = self.BorderTextures

	size = self:GetBorderSize() * (size or config.shadow.size)

	for i = 1, #points do
		local point = points[i]
		s[point]:SetWidth(size)
		s[point]:SetHeight(size)
	end

	dR = 0 - (dR or dL or 0)
	dT = 0 - (dT or dL or 0)
	dB = 0 - (dB or dL or 0)
	dL = 0 - (dL or 0) -- has to be last so it can be a fallback above

	s.TOPLEFT:SetPoint("CENTER", t.TOPLEFT, -dL, dT)
	s.TOPRIGHT:SetPoint("CENTER", t.TOPRIGHT, dR, dT)
	s.BOTTOMLEFT:SetPoint("CENTER", t.BOTTOMLEFT, -dL, -dB)
	s.BOTTOMRIGHT:SetPoint("CENTER", t.BOTTOMRIGHT, dR, -dB)

	s.TOP:SetPoint("TOPLEFT", s.TOPLEFT, "TOPRIGHT")
	s.TOP:SetPoint("TOPRIGHT", s.TOPRIGHT, "TOPLEFT")

	s.BOTTOM:SetPoint("BOTTOMLEFT", s.BOTTOMLEFT, "BOTTOMRIGHT")
	s.BOTTOM:SetPoint("BOTTOMRIGHT", s.BOTTOMRIGHT, "BOTTOMLEFT")

	s.LEFT:SetPoint("TOPLEFT", s.TOPLEFT, "BOTTOMLEFT")
	s.LEFT:SetPoint("BOTTOMLEFT", s.BOTTOMLEFT, "TOPLEFT")

	s.RIGHT:SetPoint("TOPRIGHT", s.TOPRIGHT, "BOTTOMRIGHT")
	s.RIGHT:SetPoint("BOTTOMRIGHT", s.BOTTOMRIGHT, "TOPRIGHT")
end

function Addon.GetShadowSize(self)
	if type(self) ~= "table" or not self.ShadowTextures then return end
	return self.ShadowTextures.TOPLEFT:GetWidth()
end

------------------------------------------------------------------------

function Addon.WithShadow(self, method, ...)
	for i = 1, #points do
		local tex = self.ShadowTextures[points[i]]
		local ret = tex[method](tex, ...)
		if ret then
			return ret
		end
	end
end

------------------------------------------------------------------------
--	GLOBALIZATION
------------------------------------------------------------------------

function Addon.WithAllBorders(what, ...)
	local func = Addon[what]
	if type(func) == "function" then
		for i = 1, #borderedFrames do
			func(borderedFrames[i], ...)
		end
	end
end

function Addon.WithAllShadows(what, ...)
	local func = Addon[what]
	if type(func) == "function" then
		for i = 1, #shadowedFrames do
			func(shadowedFrames[i], ...)
		end
	end
end

Addon.isPhanx = isPhanx
Addon.config = config
Addon.noop = noop

------------------------------------------------------------------------