local _G = getfenv()

local threatFrame = _G['TargetFrameNumericalThreat']
local frame = CreateFrame('Frame')
frame:Hide()
frame.enableSnapping = false
frame.lastFrameID = 0

frame.lazyload = CreateFrame('Frame')
frame.lazyload.elapsed = 0
frame.lazyload.attempts = 0

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
		end
	end
end

frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function(_, event, addonName)
	if event == 'ADDON_LOADED' and addonName == 'BlizzardTargetThreat' then
		load_position()
	end
end)

frame.lazyload:SetScript('OnUpdate', function(_, elapsed)
	if this.enable then
		this.elapsed = this.elapsed + elapsed
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
	threatFrame:SetScript('OnMouseDown', function(_, button)
		if button == 'LeftButton' then
			this:StartMoving()
		elseif button == 'RightButton' then
			threatFrame:SetMovable(false)
			threatFrame:EnableMouse(false)
			threatFrame:Hide()
			visualFrame:Hide()
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
