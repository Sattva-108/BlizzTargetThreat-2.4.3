local _G = getfenv()

local threatFrame = _G['TargetFrameNumericalThreat']
local frame = CreateFrame('Frame')
frame:Hide()
frame.enableSnapping = false
frame.lastFrameID = 0

frame.lazyload = CreateFrame('Frame')
frame.lazyload.elapsed = 0
frame.lazyload.attempts = 0

_DEBUG_BTT = {}

local function save_position()
	local point, relativeTo, relativePoint, x, y = threatFrame:GetPoint()

	BTT_Parent = threatFrame:GetParent():GetName()
	if point == 'TOPLEFT' and relativePoint == 'TOPLEFT' then
		relativeTo = threatFrame:GetParent()
		BTT_x = x - relativeTo:GetLeft()
		BTT_y = y + threatFrame:GetHeight()
		relativeTo = relativeTo:GetName()
	else
		BTT_x = x
		BTT_y = y
	end
	BTT_point = point
	BTT_relativePoint = relativePoint

	_DEBUG_BTT.save_position = {}
	_DEBUG_BTT.save_position.x = BTT_x
	_DEBUG_BTT.save_position.y = BTT_y
	_DEBUG_BTT.save_position.point = BTT_point
	_DEBUG_BTT.save_position.relativePoint = BTT_relativePoint
	printTable(_DEBUG_BTT)
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
			printTable(_DEBUG_BTT)
		end
	end
end

-- not working.
frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function()
	if arg1 == 'BlizzardTargetThreat' then
		_DEBUG_BTT.addon_loaded = true
		load_position()
		print("loading position")
	end
end)

-- working
frame:RegisterEvent('PLAYER_LOGIN')
frame:SetScript('OnEvent', function()
	load_position()
	print("loading position")
end)

frame.lazyload:SetScript('OnUpdate', function()
	if this.enable then
		print("enabled")
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
	DEFAULT_CHAT_FRAME:AddMessage('Locking on')
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

	threatFrame:Show()

	threatFrame:SetMovable(true)
	threatFrame:EnableMouse(true)
	threatFrame:SetScript('OnMouseDown', function()
		if arg1 == 'LeftButton' then
			this:StartMoving()
		elseif arg1 == 'RightButton' then
			threatFrame:SetMovable(false)
			threatFrame:EnableMouse(false)
			threatFrame:Hide()
			visualFrame:Hide()
			--klhtm.blizzardui.enableAdjust = false
			save_position()
			DEFAULT_CHAT_FRAME:AddMessage('Locked!')
		end
	end)
	threatFrame:SetScript('OnMouseUp', function()
		this:StopMovingOrSizing()
	end)
end)

frame:SetScript('OnUpdate', function()
	if not this.enableSnapping then
		return
	end

	this.frameID = GetMouseFocus()
	if this.enableSnapping and this.frameID and this.frameID == frame.visual then
		frame.visual:EnableMouse(false)
		this.frameID = GetMouseFocus()
		frame.visual:EnableMouse(true)
	end

	-- dumb check
	if not this.frameID or this.frameID == WorldFrame or this.frameID == UIParent or this.FrameID == this.visual then
		return
	end

	if this.frameID ~= this.lastFrameID then
		this.lastFrameID = this.frameID
		DEFAULT_CHAT_FRAME:AddMessage('Snapping to: ' .. tostring(this.frameID:GetName() or this.frameID))
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

SLASH_KTMBLIZZ1 = '/ktmsnap'
SLASH_KTMBLIZZ2 = '/ts'
SlashCmdList["KTMBLIZZ"] = function(msg)
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
	else
		frame:Hide()
		frame.visual:EnableMouse(false)
		frame.visual:Hide()
	end
end

function printTable(t, indent, done)
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

printTable(_DEBUG_BTT)

