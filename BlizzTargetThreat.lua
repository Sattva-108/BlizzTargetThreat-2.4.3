local addon = {}

addon.gui = {
    ["Frame"] = TargetFrameNumericalThreat,
    ["bg"] = TargetFrameNumericalThreatBG,
    ["text"] = TargetFrameNumericalThreatValue,
}

local Threat = LibStub("Threat-2.0")
local frame = CreateFrame("Frame")
local updateFrequency = 0.5
local timer = 0

frame:SetScript("OnUpdate", function(self, elapsed)
    timer = timer + elapsed
    if timer >= updateFrequency then
        timer = 0

        local player = UnitGUID("player")
        local target = UnitGUID("target")

        --if not target or UnitIsDeadOrGhost("target") or not UnitAffectingCombat("target") or not UnitCanAttack("player", "target") then
        --    addon.gui.Frame:Hide()
        --    return
        --end
        local maxThreat, _ = Threat:GetMaxThreatOnTarget(target)
        local myThreat = Threat:GetThreat(player, target)
        local threatPercent = math.floor(myThreat / maxThreat * 100 + 0.5)
        --print("updated")

        --if threatPercent > 0 then
            addon.gui.Frame:Show()

            local threatStr = string.format("%d%%", threatPercent)
        if threatPercent > 0 then
            addon.gui.text:SetText(threatStr)
        else
            addon.gui.text:SetText("0 %")
        end

            addon.gui.bg:SetVertexColor(addon.GetThreatStatusColor(threatPercent))
        --else
        --    addon.gui.Frame:Hide()
        --end
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

