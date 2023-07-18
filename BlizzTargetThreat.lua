--------------------------------------------------------------------------------
--- BlizzTargetThreat - TBC - 2.4.3
--- Idea by Finrodi
--- Coding by Sattva
--- Source Code: https://github.com/yutsuku/KLHThreatMeterBlizz
--- Credit to : yutsuku, Finrodi
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
---- Init Locals and DB
--------------------------------------------------------------------------------

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

    BlizzlikeTT_defaults = {
        EnableGlow = false, -- disable glow by default
    }

--------------------------------------------------------------------------------
---- OnUpdate
--------------------------------------------------------------------------------

    local function onUpdate(self, elapsed)
        timer = timer + elapsed
        if timer >= updateFrequency then
            timer = 0
            --print("OnUpdate")
            local player = UnitGUID("player")
            local target = UnitGUID("target")

            if not target or UnitIsDeadOrGhost("target") or not UnitAffectingCombat("target") or not UnitCanAttack("player", "target") then
                addon.gui.Frame:Hide()
                TargetFrameFlash:Hide()
                return
            end

            --------------------------------------------------------------------------------
            ---- Threat Calculaction Logic
            --------------------------------------------------------------------------------


            local maxThreat = 0
            local secondMaxThreat = 0
            local maxThreatGUID = nil
            local myThreat = Threat:GetThreat(player, target)
            for guid, threat in Threat:IterateGroupThreatForTarget(target) do
                if threat > maxThreat then
                    secondMaxThreat = maxThreat
                    maxThreat = threat
                    maxThreatGUID = guid
                elseif threat > secondMaxThreat then
                    secondMaxThreat = threat
                end
            end

            if myThreat >= maxThreat and secondMaxThreat > 0 then
                maxThreat = secondMaxThreat
            end

            local threatPercent = math.floor(myThreat / maxThreat * 100 + 0.5)

            -- Check if you have aggro
            local hasAggro = UnitIsUnit("player", "targettarget")
            local playerAtPosition1 = (Threat:GetPlayerAtPosition(target, 1) == player)
            if hasAggro then
                -- Set TargetFrameFlash color to red
                TargetFrameFlash:SetVertexColor(1, 0, 0, 1) -- red color
                TargetFrameFlash:Show()
            else
                -- Remove the red glow when you lose aggro
                TargetFrameFlash:Hide()
            end

            --------------------------------------------------------------------------------
            ---- Rest of code
            --------------------------------------------------------------------------------


            addon.gui.Frame:Show()

            local threatStr = string.format("%d%%", threatPercent)
            if threatPercent > 0 then
                addon.gui.text:SetText(threatStr)
            else
                addon.gui.text:SetText("0 %")
            end

            addon.gui.bg:SetVertexColor(addon.GetThreatStatusColor(threatPercent))

            -- Set TargetFrameFlash color based on threatPercent
            if BlizzlikeTT_defaults.EnableGlow then
                if hasAggro then
                    TargetFrameFlash:SetVertexColor(1, 0, 0, 1) -- red color
                    return
                elseif threatPercent >= 80 or playerAtPosition1 then
                    --print("80")
                    TargetFrameFlash:SetVertexColor(1, 1, 0, 1) -- yellow color
                    TargetFrameFlash:Show()
                --elseif threatPercent >= 50 then
                --    TargetFrameFlash:SetVertexColor(0, 1, 0, 1) -- green color
                --    TargetFrameFlash:Show()
                else
                    TargetFrameFlash:Hide()
                end
            else
                TargetFrameFlash:Hide()
            end
        end
    end

--------------------------------------------------------------------------------
---- Color Threat GUI
--------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------
---- Check for number of people in threat meter for target.
--- This is where we call our OnUpdate via Callback from Threat 2.0 lib.
--- We check for GUIDs to match and have more than 1 threat guy in order to start OnUpdate.
---------------------------------------------------------------------------------------------

    local function threatUpdatedCallback()
        local numThreatGuys = 0
        local currentTarget = UnitGUID("target") -- get the GUID of the current target

        if not currentTarget then
            --print("No current target")
            addon.gui.Frame:Hide()
            return
        end

        --print("Current target GUID: " .. currentTarget)

        for guid, threat in Threat:IterateGroupThreatForTarget(currentTarget) do
            if threat > 0 then
                numThreatGuys = numThreatGuys + 1
                --print("Matched target: GUID = " .. guid .. ", Threat Guys = " .. numThreatGuys)
            end
        end

        --print("Total Threat Guys: " .. numThreatGuys)

        if numThreatGuys > 1 then
            frame:SetScript("OnUpdate", onUpdate)
            addon.gui.Frame:Show()
        else
            frame:SetScript("OnUpdate", nil)
            addon.gui.Frame:Hide()
            TargetFrameFlash:Hide()
        end
    end

    -- Register the callback
    Threat:RegisterCallback("ThreatUpdated", threatUpdatedCallback)
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")

--------------------------------------------------------------------------------
---- Slash Function
--------------------------------------------------------------------------------

    SLASH_BTT1 = "/btt"
    function SlashCmdList.BTT(msg, editbox)
        local command, rest = msg:match("^(%S*)%s*(.-)$")

        if command == "glow" then
            -- Toggle the glow
            BlizzlikeTT_defaults.EnableGlow = not BlizzlikeTT_defaults.EnableGlow
            if BlizzlikeTT_defaults.EnableGlow then
                print("Glow is now enabled.")
            else
                print("Glow is now disabled.")
            end
        else
            -- Print help commands
            print("BlizzlikeTT commands:")
            print("/btt glow - Toggle the target glow.")
        end
    end

--------------------------------------------------------------------------------
---- Code ENDs
--------------------------------------------------------------------------------


