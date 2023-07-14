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
    if target == nil then
        addon.gui.Frame:Hide()
        return
    end
    if not target then
        addon.gui.Frame:Hide()
        return
    end
    if UnitIsDeadOrGhost("target") then
        addon.gui.Frame:Hide()
        return
    end
    if not UnitAffectingCombat("target") then
        addon.gui.Frame:Hide()
        return
    end
    if not UnitCanAttack("player", "target") then
        addon.gui.Frame:Hide()
        return
    end
    local maxThreat, _ = Threat:GetMaxThreatOnTarget(target)
    local myThreat = Threat:GetThreat(player, target)
    local threatPercent = math.floor(myThreat / maxThreat * 100 + 0.5)
    print(threatPercent)

    if threatPercent > 0 then
        -- Show frame
        addon.gui.Frame:Show()

        local threatStr = string.format("%d%%", threatPercent)
        addon.gui.text:SetText(threatStr)

        addon.gui.bg:SetVertexColor(addon.GetThreatStatusColor(threatPercent))

    else
        -- Hide frame
        addon.gui.Frame:Hide()
    end
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
