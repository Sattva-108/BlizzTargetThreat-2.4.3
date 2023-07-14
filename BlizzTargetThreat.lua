local Threat = LibStub("Threat-2.0")
if not ThreatLib then ThreatLib = Threat end


local frame = CreateFrame("Frame")
--frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:SetScript("OnUpdate", function()
    local player_name = UnitName("player")
    local target_name = UnitName("target")
    local player_guid = UnitGUID("player")
    local target_guid = UnitGUID("target")
    if target_guid == nil then return end
    local threat = Threat:GetThreat(player_guid, target_guid)
    print("Threat for player:", player_name, "on target:", target_name, "is", threat)
end)



--local threat = Threat:GetThreat(player_guid, target_guid)
