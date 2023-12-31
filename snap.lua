local _G = getfenv()

local frame = CreateFrame('Frame')
frame:Hide()
frame.enableSnapping = false
frame.lastFrameID = 0

frame.lazyload = CreateFrame('Frame')
frame.lazyload.elapsed = 0
frame.lazyload.attempts = 0

--------------------------------------------------------------------------------
---- Define threatFrame aka our main target threat bar.
--------------------------------------------------------------------------------


local threatFrame = _G['TargetFrameNumericalThreat']

threatFrame.instructionText = threatFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
threatFrame.instructionText:SetPoint('BOTTOM', threatFrame, 'TOP', 0, 0)
threatFrame.instructionText:SetText('Select frame to attach to')
threatFrame.instructionText:SetTextColor(1, 1, 0)  -- RGB color, yellow
threatFrame.instructionText:Hide() -- Hide on start

local frameAttachedMsg = CreateFrame('Frame', nil, UIParent)
frameAttachedMsg.text = frameAttachedMsg:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
frameAttachedMsg.text:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
frameAttachedMsg.text:SetTextColor(0, 1, 0)  -- RGB color for green
frameAttachedMsg:Hide()

frameAttachedMsg.timeLeft = 0
frameAttachedMsg:SetScript('OnUpdate', function(self, elapsed)
	threatFrame:Show()
	if not frame.enableSnapping then
		threatFrame.instructionText:Hide()
	end
	self.timeLeft = self.timeLeft - elapsed
	if self.timeLeft <= 0 then
		self:Hide()
		threatFrame:Hide()
	end
end)

--------------------------------------------------------------------------------
---- Rest of code
--------------------------------------------------------------------------------

_DEBUG_BTT = {}

local function printTable(t, indent, done)
	done = done or {}
	indent = indent or 0

	for k, v in pairs(t) do
		if type(v) == "table" and not done[v] then
			done[v] = true
			print(string.rep("\t", indent)..tostring(k)..":")
			printTable(v, indent + 1, done)
		else
			print(string.rep("\t", indent)..tostring(k)..": "..tostring(v))
		end
	end
end

--printTable(_DEBUG_BTT)

local function save_position()
	local point, relativeTo, relativePoint, x, y = threatFrame:GetPoint()

	BTT_Parent = threatFrame:GetParent():GetName()
	if point == 'TOPLEFT' and relativePoint == 'TOPLEFT' then
		--print("x y IF")
		relativeTo = threatFrame:GetParent()
		BTT_x = x - relativeTo:GetLeft()
		BTT_y = y + threatFrame:GetHeight()
		relativeTo = relativeTo:GetName()
	else
		--print("x y ELSE")
		BTT_x = x
		BTT_y = y
	end
	BTT_point = point
	BTT_relativePoint = relativePoint

	-- Debug is obviously just for debugging, not for actual saving .
	_DEBUG_BTT.save_position = {}
	_DEBUG_BTT.save_position.x = BTT_x
	_DEBUG_BTT.save_position.y = BTT_y
	_DEBUG_BTT.save_position.point = BTT_point
	_DEBUG_BTT.save_position.relativePoint = BTT_relativePoint
	--printTable(_DEBUG_BTT)
end

local function load_position()
	if BTT_Parent and BTT_x and BTT_y and BTT_point and BTT_relativePoint then
		if not _G[BTT_Parent] then
			if frame.lazyload.attempts >= 10 then
				frame.lazyload.enable = false
			else
				frame.lazyload.enable = true
			end
		else
			frame.lazyload.enable = false
			frame.lazyload:Hide()
			threatFrame:SetParent(BTT_Parent)
			threatFrame:ClearAllPoints()
			threatFrame:SetPoint(BTT_point, BTT_Parent, BTT_relativePoint, BTT_x, BTT_y)

			_DEBUG_BTT.load_position = {}
			_DEBUG_BTT.load_position.point = BTT_point
			_DEBUG_BTT.load_position.relativePoint = BTT_relativePoint
			_DEBUG_BTT.load_position.parent = BTT_Parent
			_DEBUG_BTT.load_position.x = BTT_x
			_DEBUG_BTT.load_position.y = BTT_y
			_DEBUG_BTT.load_position.attempts = frame.lazyload.attempts
			--printTable(_DEBUG_BTT)
		end
	end
end

-- not working.
frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function()
	if arg1 == 'BlizzardTargetThreat' then
		_DEBUG_BTT.addon_loaded = true
		load_position()
		--print("loading position")
	end
end)

-- working
frame:RegisterEvent('PLAYER_LOGIN')
frame:SetScript('OnEvent', function()
	load_position()
	--print("loading position")
end)

frame.lazyload:SetScript('OnUpdate', function()
	if this.enable then
		--print("enabled")
		this.elapsed = this.elapsed + arg1
		if this.elapsed >= 1 then
			this.elapsed = 0
			this.attempts = this.attempts + 1
			load_position()
		end
	end
end)

local visualFrame = CreateFrame('Frame', nil, UIParent)
frame.visual = visualFrame
visualFrame:SetBackdrop({
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
	tile = true,
	tileSize = 16,
	edgeFile = [[Interface\Addons\BlizzardTargetThreat\textures\snap-border]],
	edgeSize = 16,
})
visualFrame:SetBackdropColor(0, 0, 0, .6)
visualFrame:SetScript('OnMouseDown', function()
	--DEFAULT_CHAT_FRAME:AddMessage('Locking on')
	frame.enableSnapping = false
	this:EnableMouse(false)
	visualFrame:Hide()

	local point, relativeTo, relativePoint, x, y = frame.snapFrameID:GetPoint()
	threatFrame:SetParent(frame.snapFrameID)
	threatFrame:ClearAllPoints()
	threatFrame:SetPoint('BOTTOM', frame.snapFrameID:GetName(), 'TOP', 0, 0)

	if frame.snapFrameID:GetName() and strsub(frame.snapFrameID:GetName(), 1, 3) == 'LUF' then
		threatFrame:SetFrameLevel(frame.snapFrameID:GetFrameLevel() + 10)
	end
	threatFrame:SetMovable(false)
	threatFrame:EnableMouse(false)
	threatFrame:Hide()
	visualFrame:Hide()
	save_position()
	DEFAULT_CHAT_FRAME:AddMessage('|cffffff00Locked|r & |cFF00FF00Saved|r |cffffff00threat bar to: |r' .. "|cffff0000" .. frame.snapFrameID:GetName())

	-- Show the "Frame attached & saved" text for 3 seconds.
	frameAttachedMsg.text:SetText('Threat Frame attached to: ' .. "|cffff0000" .. frame.snapFrameID:GetName())
	frameAttachedMsg:Show()
	frameAttachedMsg.timeLeft = 3  -- Start the 3-second countdown


	--threatFrame:Show()
	--
	--threatFrame:SetMovable(true)
	--threatFrame:EnableMouse(true)
	--threatFrame:SetScript('OnMouseDown', function()
	--	if arg1 == 'LeftButton' then
	--		this:StartMoving()
	--	elseif arg1 == 'RightButton' then
	--		threatFrame:SetMovable(false)
	--		threatFrame:EnableMouse(false)
	--		threatFrame:Hide()
	--		visualFrame:Hide()
	--		--klhtm.blizzardui.enableAdjust = false
	--		save_position()
	--		DEFAULT_CHAT_FRAME:AddMessage('Locked!')
	--	end
	--end)
	--threatFrame:SetScript('OnMouseUp', function()
	--	this:StopMovingOrSizing()
	--end)
end)

frame:SetScript('OnUpdate', function()
	if not this.enableSnapping then
		return
	end
	threatFrame:Show()
	--print(this.enableSnapping)

	this.frameID = GetMouseFocus()
	if this.enableSnapping and this.frameID and this.frameID == frame.visual then
		frame.visual:EnableMouse(false)
		this.frameID = GetMouseFocus()
		frame.visual:EnableMouse(true)
	end

	-- dumb check
	if not this.frameID or this.frameID == WorldFrame or this.frameID == UIParent or this.FrameID == this.visual or this.FrameID == TargetFrameNumericalThreat then
		return
	end

	if this.frameID ~= this.lastFrameID then
		this.lastFrameID = this.frameID
		DEFAULT_CHAT_FRAME:AddMessage('|cFFFFA500Snapping Threat Bar to:|r |cFF00FF00' .. tostring(this.frameID:GetName() or this.frameID) .. '|r')
		this.snapFrameID = this.frameID
		local point, relativeTo, relativePoint, x, y = this.frameID:GetPoint()
		x = x * ((this.frameID:GetEffectiveScale() or 1) / (UIParent:GetScale() or 1))
		y = y * ((this.frameID:GetEffectiveScale() or 1) / (UIParent:GetScale() or 1))
		this.visual:ClearAllPoints()
		this.visual:SetPoint(point, relativeTo, relativePoint, x, y)
		this.visual:SetWidth(this.frameID:GetWidth() * this.frameID:GetEffectiveScale() / UIParent:GetScale())
		this.visual:SetHeight(this.frameID:GetHeight() * this.frameID:GetEffectiveScale() / UIParent:GetScale())
		this.visual:SetFrameStrata(this.frameID:GetFrameStrata())


		if this.frameID:GetName() and strsub(this.frameID:GetName(), 1, 3) == 'LUF' then
			this.visual:SetFrameLevel(this.frameID:GetFrameLevel() + 10)
		else
			this.visual:SetFrameLevel(this.frameID:GetFrameLevel() + 1)
		end

	end

end)

SLASH_BTTBLIZZ1 = '/bttsnap'
SLASH_BTTBLIZZ2 = '/threatsnap'
SlashCmdList["BTTBLIZZ"] = function(msg)
	frame.enableSnapping = not frame.enableSnapping

	if msg == 'reset' then
		BTT_Parent = nil
		BTT_x = nil
		BTT_y = nil
		BTT_point = nil
		BTT_relativePoint = nil
		ReloadUI()
		return
	end

	if frame.enableSnapping then
		frame:Show()
		frame.visual:EnableMouse(true)
		frame.visual:Show()
		threatFrame.instructionText:Show()  -- Show text
	else
		frame:Hide()
		frame.visual:EnableMouse(false)
		frame.visual:Hide()
		threatFrame.instructionText:Hide()  -- Hide text
	end
end


