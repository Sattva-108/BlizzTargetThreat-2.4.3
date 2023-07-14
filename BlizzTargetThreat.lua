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
    ChatFrame1:AddMessage(format("%.1f%%", threatPercent))
end)



--local threat = Threat:GetThreat(player_guid, target_guid)
