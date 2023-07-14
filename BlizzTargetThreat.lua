local Threat = LibStub("Threat-2.0")
if not ThreatLib then ThreatLib = Threat end


local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:SetScript("OnEvent", function()
    local player_guid = UnitGUID("player")
    local target_guid = UnitGUID("target")
    local threat = Threat:GetThreat(player_guid, target_guid)
    print("Threat for player:", player_guid, "on target:", target_guid, "is", threat)
end)