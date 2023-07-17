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

local function onUpdate(self, elapsed)
    timer = timer + elapsed
    if timer >= updateFrequency then
        timer = 0
print("OnUpdate")
        local player = UnitGUID("player")
        local target = UnitGUID("target")

        if not target or UnitIsDeadOrGhost("target") or not UnitAffectingCombat("target") or not UnitCanAttack("player", "target") then
            addon.gui.Frame:Hide()
            return
        end
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
end

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


frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("RAID_ROSTER_UPDATE")
frame:RegisterEvent("PARTY_MEMBERS_CHANGED")


frame:SetScript("OnEvent", function(self, event)
    addon.groupCheck()
    local PlayerInCombat = UnitAffectingCombat('player')
    print(PlayerInCombat)
    if event == "PLAYER_REGEN_DISABLED" and addon.inGroup and PlayerInCombat then
        self:SetScript("OnUpdate", onUpdate)
    elseif event == "RAID_ROSTER_UPDATE" and addon.inGroup and PlayerInCombat then
        self:SetScript("OnUpdate", onUpdate)
    elseif event == "PARTY_MEMBERS_CHANGED" and addon.inGroup and PlayerInCombat then
        self:SetScript("OnUpdate", onUpdate)
    else
        self:SetScript("OnUpdate", nil)
        addon.gui.Frame:Hide()
    end
end)

addon.groupCheck = function()
    local playersRaid = GetNumRaidMembers()
    local playersParty = GetNumPartyMembers()

    if playersRaid > 0 or playersParty > 0 then
        addon.inGroup = true
    else
        addon.inGroup = false
    end
end