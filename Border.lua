------------------------------------------------------------------------
--	Configure stuff here. Should be self-explanatory.
------------------------------------------------------------------------

local BORDER_SIZE = 24
local BORDER_COLOR = { 0.8, 0.8, 0.8, 1 } -- { 0.3, 0.3, 0.3, 1 }
local BORDER_TEXTURE = [[Interface\AddOns\PhanxMedia\LerbUI\bordernp]]

local SHADOW_SIZE = 1.5
local SHADOW_COLOR = { 0, 0, 0, 1 }
local SHADOW_TEXTURE = [[Interface\AddOns\PhanxBorder\Shadow]]

------------------------------------------------------------------------
--	GTFO.
------------------------------------------------------------------------

local AddBorder, GetBorderAlpha, SetBorderAlpha, GetBorderColor, SetBorderColor, GetBorderSize, SetBorderSize
local AddShadow, GetShadowAlpha, SetShadowAlpha, GetShadowColor, SetShadowColor, GetShadowSize, SetShadowSize
local noop = function() end

------------------------------------------------------------------------
--	BORDER
------------------------------------------------------------------------

function SetBorderAlpha(self, a)
	if not self or type(self) ~= "table" or not self.BorderTextures then return end
	if not a then a = 1 end

	for i, tex in ipairs(self.BorderTextures) do
		tex:SetAlpha(a)
	end
end

function GetBorderAlpha(self)
	if not self or type(self) ~= "table" or not self.BorderTextures then return end
	return self.BorderTextures[1]:GetAlpha()
end

------------------------------------------------------------------------

function SetBorderColor(self, r, g, b, a)
	if not self or type(self) ~= "table" or not self.BorderTextures then return end
	if not r or not g or not b or a == 0 then
		r, g, b, a = unpack(BORDER_COLOR)
	end

	for i, tex in ipairs(self.BorderTextures) do
		tex:SetVertexColor(r, g, b)
	end
end

function GetBorderColor(self)
	if not self or type(self) ~= "table" or not self.BorderTextures then return end
	return self.BorderTextures[1]:GetVertexColor()
end

------------------------------------------------------------------------

function SetBorderSize(self, size, offset)
	if not self or type(self) ~= "table" or not self.BorderTextures then return end
	if not size then
		size = BORDER_SIZE
	end

	local scale = self:GetEffectiveScale() / UIParent:GetScale()
	if scale ~= 1 then
		size = size * (1 / scale)
	end

	local d = offset or floor(size * 0.25 + 0.5) -- (size / 2 - 2)

	local t = self.BorderTextures

	for i, tex in ipairs(t) do
		tex:SetWidth(size)
		tex:SetHeight(size)
	end

	t[1]:SetPoint("TOPLEFT", self, -d, d)

	t[2]:SetPoint("TOPRIGHT", self, d, d)

	t[3]:SetPoint("LEFT", t[1], "TOPRIGHT")
	t[3]:SetPoint("TOPRIGHT", t[2], "TOPLEFT")

	t[4]:SetPoint("BOTTOMLEFT", self, -d, -d)

	t[5]:SetPoint("BOTTOMRIGHT", self, d, -d)

	t[6]:SetPoint("BOTTOMLEFT", t[4], "BOTTOMRIGHT")
	t[6]:SetPoint("BOTTOMRIGHT", t[5], "BOTTOMLEFT")

	t[7]:SetPoint("TOPLEFT", t[1], "BOTTOMLEFT")
	t[7]:SetPoint("BOTTOMLEFT", t[4], "TOPLEFT")

	t[8]:SetPoint("TOPRIGHT", t[2], "BOTTOMRIGHT")
	t[8]:SetPoint("BOTTOMRIGHT", t[5], "TOPRIGHT")

	self.BorderSize = size
end

function GetBorderSize(self)
	if not self or type(self) ~= "table" or not self.BorderTextures then return end
	return self.BorderSize or BORDER_SIZE
end

------------------------------------------------------------------------

local borderedFrames = { }

local function ScaleBorder(self)
	return self:SetBorderSize(self:GetBorderSize())
end

function AddBorder(self, size, offset, force, shadow)
	if not self or type(self) ~= "table" or self.BorderTextures or not self.CreateTexture then return end

	local t = { }
	self.BorderTextures = t

	for i = 1, 8 do
		t[i] = self:CreateTexture(nil, "OVERLAY")
		t[i]:SetTexture(BORDER_TEXTURE)
	end

	t[1].name = "TOPLEFT"
	t[1]:SetTexCoord(0, 1/3, 0, 1/3)

	t[2].name = "TOPRIGHT"
	t[2]:SetTexCoord(2/3, 1, 0, 1/3)

	t[3].name = "TOP"
	t[3]:SetTexCoord(1/3, 2/3, 0, 1/3)

	t[4].name = "BOTTOMLEFT"
	t[4]:SetTexCoord(0, 1/3, 2/3, 1)

	t[5].name = "BOTTOMRIGHT"
	t[5]:SetTexCoord(2/3, 1, 2/3, 1)

	t[6].name = "BOTTOM"
	t[6]:SetTexCoord(1/3, 2/3, 2/3, 1)

	t[7].name = "LEFT"
	t[7]:SetTexCoord(0, 1/3, 1/3, 2/3)

	t[8].name = "RIGHT"
	t[8]:SetTexCoord(2/3, 1, 1/3, 2/3)

	if self.SetBackdropBorderColor then
		local a, backdrop = 0.8, self:GetBackdrop()
		if type(backdrop) == "table" then
			if strmatch(backdrop.bgFile or "", "Tooltip") then
				a = 1
			end
			if backdrop.edgeFile then
				backdrop.edgeFile = nil
			end
			if backdrop.insets then
				backdrop.insets.top = 0
				backdrop.insets.right = 0
				backdrop.insets.bottom = 0
				backdrop.insets.left = 0
			end
			self:SetBackdrop(backdrop)
		end

		self:SetBackdropColor(0, 0, 0, a)

		if force then
			self.SetBackdrop = noop
			self.SetBackdropColor = noop
			self.SetBackdropBorderColor = noop
		else
			self.SetBackdropBorderColor = SetBorderColor
		end
	end

	do
		local icon = self.Icon or self.icon
		if type(icon) == "table" and icon.SetTexCoord then
			icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
		end
	end

	SetBorderColor(self)
	SetBorderSize(self, size, offset)

	self.GetBorderAlpha = GetBorderAlpha
	self.SetBorderAlpha = SetBorderAlpha

	self.GetBorderColor = GetBorderColor
	self.SetBorderColor = SetBorderColor

	self.GetBorderSize  = GetBorderSize
	self.SetBorderSize  = SetBorderSize

	if self.SetScale then
		hooksecurefunc(self, "SetScale", ScaleBorder)
	end

	if shadow then
		AddShadow(self)
	end

	table.insert(borderedFrames, self)
end

------------------------------------------------------------------------
--	SHADOW
------------------------------------------------------------------------

local shadowedFrames = { }

function AddShadow(self, size, offset)
	if not self or type(self) ~= "table" or self.ShadowTextures or not self.CreateTexture then return end

	if not self.BorderTextures then
		AddBorder(self)
	end

	local s = { }
	self.ShadowTextures = s

	for i = 1, 8 do
		s[i] = self:CreateTexture(nil, "BACKGROUND")
		s[i]:SetTexture(SHADOW_TEXTURE)
	end

	s[1].name = "TOPLEFT"
	s[1]:SetTexCoord(0, 1/3, 0, 1/3)

	s[2].name = "TOPRIGHT"
	s[2]:SetTexCoord(2/3, 1, 0, 1/3)

	s[3].name = "TOP"
	s[3]:SetTexCoord(1/3, 2/3, 0, 1/3)

	s[4].name = "BOTTOMLEFT"
	s[4]:SetTexCoord(0, 1/3, 2/3, 1)

	s[5].name = "BOTTOMRIGHT"
	s[5]:SetTexCoord(2/3, 1, 2/3, 1)

	s[6].name = "BOTTOM"
	s[6]:SetTexCoord(1/3, 2/3, 2/3, 1)

	s[7].name = "LEFT"
	s[7]:SetTexCoord(0, 1/3, 1/3, 2/3)

	s[8].name = "RIGHT"
	s[8]:SetTexCoord(2/3, 1, 1/3, 2/3)

	self.GetShadowAlpha = GetShadowAlpha
	self.SetShadowAlpha = SetShadowAlpha

	self.GetShadowColor = GetShadowColor
	self.SetShadowColor = SetShadowColor

	self.GetShadowSize  = GetShadowSize
	self.SetShadowSize  = SetShadowSize

	SetShadowColor(self)
	SetShadowSize(self, offset)

	table.insert(shadowedFrames, self)
end

------------------------------------------------------------------------

function SetShadowAlpha(self, a)
	if not self or type(self) ~= "table" or not self.ShadowTextures then return end
	if not a then a = 1 end

	for i, tex in ipairs(self.ShadowTextures) do
		tex:SetAlpha(a)
	end
end

function GetShadowAlpha(self)
	if not self or type(self) ~= "table" or not self.ShadowTextures then return end
	return self.ShadowTextures[1]:GetAlpha()
end

------------------------------------------------------------------------

function SetShadowColor(self, r, g, b, a)
	if not self or type(self) ~= "table" or not self.ShadowTextures then return end
	if not r or not g or not b or a == 0 then
		r, g, b, a = unpack(SHADOW_COLOR)
	end

	for i, tex in ipairs(self.ShadowTextures) do
		tex:SetVertexColor(r, g, b)
	end
end

function GetShadowColor(self)
	if not self or type(self) ~= "table" or not self.ShadowTextures then return end
	return self.ShadowTextures[1]:GetVertexColor()
end

------------------------------------------------------------------------

function SetShadowSize(self, size, offset)
	if not self or type(self) ~= "table" or not self.ShadowTextures then return end
	if not size then
		size = BORDER_SIZE * SHADOW_SIZE
	end
	if not offset then
		offset = 0
	end

	local s = self.ShadowTextures
	local t = self.BorderTextures

	for i, tex in ipairs(s) do
		tex:SetWidth(size)
		tex:SetHeight(size)
	end

	s[1]:SetPoint("CENTER", t[1], -offset, offset) -- TOPLEFT

	s[2]:SetPoint("CENTER", t[2], offset, offset) -- TOPRIGHT

	s[3]:SetPoint("TOPLEFT", s[1], "TOPRIGHT") -- TOP
	s[3]:SetPoint("TOPRIGHT", s[2], "TOPLEFT")

	s[4]:SetPoint("CENTER", t[4], -offset, -offset) -- BOTTOMLEFT

	s[5]:SetPoint("CENTER", t[5], offset, -offset) -- BOTTOMRIGHT

	s[6]:SetPoint("BOTTOMLEFT", s[4], "BOTTOMRIGHT") -- BOTTOM
	s[6]:SetPoint("BOTTOMRIGHT", s[5], "BOTTOMLEFT")

	s[7]:SetPoint("TOPLEFT", s[1], "BOTTOMLEFT") -- LEFT
	s[7]:SetPoint("BOTTOMLEFT", s[4], "TOPLEFT")

	s[8]:SetPoint("TOPRIGHT", s[2], "BOTTOMRIGHT") -- RIGHT
	s[8]:SetPoint("BOTTOMRIGHT", s[5], "TOPRIGHT")
end

function GetShadowSize(self)
	if not self or type(self) ~= "table" or not self.ShadowTextures then return end
	return self.ShadowTextures[1]:GetWidth()
end

------------------------------------------------------------------------
--	GLOBAL
------------------------------------------------------------------------

_G.PhanxBorder = {
	AddBorder = AddBorder,
	AddShadow = AddShadow,
	GetBorderAlpha = GetBorderAlpha,
	SetBorderAlpha = SetBorderAlpha,
	GetBorderColor = GetBorderColor,
	SetBorderColor = SetBorderColor,
	GetBorderSize  = GetBorderSize,
	SetBorderSize  = SetBorderSize,
	GetShadowAlpha = GetShadowAlpha,
	SetShadowAlpha = SetShadowAlpha,
	GetShadowColor = GetShadowColor,
	SetShadowColor = SetShadowColor,
	GetShadowSize  = GetShadowSize,
	SetShadowSize  = SetShadowSize,
}

------------------------------------------------------------------------