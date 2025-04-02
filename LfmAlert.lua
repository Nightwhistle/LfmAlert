-- Create the addon frame
local frame = CreateFrame("Frame")

-- Register chat events
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_CHANNEL")
frame:RegisterEvent("CHAT_MSG_SAY")
frame:RegisterEvent("CHAT_MSG_YELL")
frame:RegisterEvent("CHAT_MSG_GUILD")
frame:RegisterEvent("CHAT_MSG_PARTY")
frame:RegisterEvent("CHAT_MSG_RAID")
frame:RegisterEvent("CHAT_MSG_WHISPER")

-- Ensure SavedVariables persist
LFMAlertDB = LFMAlertDB or {}

-- Function to show alert and send a chat message
local function ShowAlert(msg, sender)
	CreateAlertFrame(msg, sender)
end

-- Function to check for "LFM" and a saved keyword
local function CheckForLFM(msg, sender)
    if not msg or type(msg) ~= "string" then return end

    msg = string.lower(msg)
    
    if string.find(msg, "lfm") or string.find(msg, "lf%d+m") then
        for _, keyword in ipairs(LFMAlertDB) do
            if string.find(msg, keyword) then
                ShowAlert(msg, sender)
                break
            end
        end
    end
end

-- Event handler function
frame:SetScript("OnEvent", function()
    local msg = arg1
	local sender = arg2  -- Sender's name

    if not msg or type(msg) ~= "string" then return end  -- Ensure msg is valid before processing

	CheckForLFM(msg, sender)
end)

-- Slash command to manage keywords
SLASH_LFM1 = "/lfm"
SlashCmdList["LFM"] = function(msg)
    local command, arg = string.match(msg, "(%S+)%s*(.*)")

    if command == "add" and arg ~= "" then
        table.insert(LFMAlertDB, string.lower(arg))
        print("LFM Alert: Added keyword - " .. arg)
    elseif command == "remove" and arg ~= "" then
        for i, keyword in ipairs(LFMAlertDB) do
            if keyword == string.lower(arg) then
                table.remove(LFMAlertDB, i)
                print("LFM Alert: Removed keyword - " .. arg)
                break
            end
        end
    elseif command == "list" then
        print("LFM Alert Keywords:")
        for _, keyword in ipairs(LFMAlertDB) do
            print("- " .. keyword)
        end
    elseif command == "clear" then
        LFMAlertDB = {}
        print("LFM Alert: Cleared all keywords.")
    else
        print("Usage: /lfm add <keyword>, /lfm remove <keyword>, /lfm list, /lfm clear")
    end
end

function CreateAlertFrame(msg, sender)
	local alertFrame = CreateFrame("Frame", nil, UIParent)
	alertFrame:SetPoint("TOP", UIParent, "TOP", 0, -100) -- Move to top, 50 pixels down
	alertFrame:SetWidth(400)
	alertFrame:SetHeight(100)
	alertFrame:SetMovable(true)
	alertFrame:EnableMouse(true)
	alertFrame:SetUserPlaced(true)
	alertFrame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	alertFrame:SetBackdropColor(0.8, 0.0, 0.0, 0.8)
	alertFrame:SetFrameStrata("HIGH")
	local alertText = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	alertText:SetPoint("CENTER", 0, 0)
	alertText:SetTextColor(1.0, 1.0, 1.0)
	alertText:SetJustifyH("CENTER")
	alertText:SetJustifyV("CENTER")
	alertText:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
	alertText:SetWidth(380)  -- Allow wrapping

	-- Create a clickable link with "/w sender"
	local clickableName = "|Hplayer:" .. sender .. "|h|cffffcc00[" .. sender .. "]|r|h"

	-- Full alert message
	local fullMsg = clickableName .. " " .. msg  

	alertText:SetText(fullMsg)
	alertFrame:Show()
	PlaySoundFile("Sound\\Interface\\RaidWarning.wav")

	-- Use Timer instead of C_Timer
	local timer = 5 -- 5 seconds
	local function hideFunction()
		alertFrame:Hide()
	end
	alertFrame:SetScript("OnUpdate", function(parent) 
		local elapsed = arg1
		timer = timer - elapsed
		if timer <= 0 then
		  hideFunction()
		  alertFrame:SetScript("OnUpdate", nil) 
		end
	  end)
	  
	return alertFrame
  end
  