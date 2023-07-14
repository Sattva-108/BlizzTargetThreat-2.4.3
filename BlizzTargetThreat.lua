local addon = {}

addon.gui = {
    ["Frame"] = TargetFrameNumericalThreat,
    ["bg"] = TargetFrameNumericalThreatBG,
    ["text"] = TargetFrameNumericalThreatValue,
}

local Threat = LibStub("Threat-2.0")

local frame = CreateFrame("Frame")
frame:SetScript("OnUpdate", function()
    local player = UnitGUID("player")
    local target = UnitGUID("target")
    if target == nil then return end
    if not target then return end
    if UnitIsDeadOrGhost("target") then return end
    if not UnitAffectingCombat("target") then return end
    if not UnitCanAttack("player", "target") then return end
    local maxThreat, _ = Threat:GetMaxThreatOnTarget(target)
    local myThreat = Threat:GetThreat(player, target)
    local threatPercent = myThreat / maxThreat * 100

    -- Update the GUI elements
    local text = threatPercent
    if threatPercent == math.floor(threatPercent) then
        text = string.format("%d", threatPercent)
    else
        text = string.format("%.1f", threatPercent)
    end


    addon.gui.bg:SetVertexColor(addon.GetThreatStatusColor(threatPercent))
    addon.gui.bg:Show()  -- Show the background texture


    addon.gui.Frame:Show()
end)

addon.GetThreatStatusColor = function(percentage)
    if not percentage then
        return 0.69, 0.69, 0.69
    end
    if percentage >= 90 then
        return 1.0, 0.0, 0.0
    elseif percentage >= 75 then
        return 1.0, 0.6, 0.0
    elseif percentage >= 55 then
        return 1.0, 1.0, 0.47
    else
        return 0.69, 0.69, 0.69
    end
end
