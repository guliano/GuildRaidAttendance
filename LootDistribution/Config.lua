local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

local lootDistrConfigFrame = GRA:CreateFrame(L["Loot Distribution"], "GRA_LootDistrConfigFrame", gra.configFrame, 191, 300)
gra.lootDistrConfigFrame = lootDistrConfigFrame
lootDistrConfigFrame:SetPoint("BOTTOMLEFT", gra.configFrame, "BOTTOMRIGHT", 2, 0)

-----------------------------------------
-- statement
-----------------------------------------
local statementFrame = CreateFrame("Frame", nil, lootDistrConfigFrame)
statementFrame:SetPoint("TOPLEFT", 5, -5)
statementFrame:SetPoint("TOPRIGHT", -5, -5)
statementFrame:SetHeight(13)

local s = L["A simple loot distribution tool. You might want to use |cFF00BFFFBigDumbLootCouncil|r or |cFF00BFFFRCLootCouncil|r, if you need more functionality."]

local statementText = statementFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
statementText:SetText(s)
statementText:SetAllPoints(statementFrame)

statementFrame:SetScript("OnEnter", function(self)
    if statementText:IsTruncated() then
        gra.tooltip:SetOwner(self, "ANCHOR_NONE")
        gra.tooltip:AddLine(L["GRA Loot Distribution Tool"])
        gra.tooltip:AddLine(s, 1, 1, 1, true)
        gra.tooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -5, 0)
        gra.tooltip:Show()
    end
end)

statementFrame:SetScript("OnLeave", function(self)
    gra.tooltip:Hide()
end)

-----------------------------------------
-- quick notes section
-----------------------------------------
local qnSection = lootDistrConfigFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
qnSection:SetText("|cff80FF00"..L["Quick Notes"].."|r")
qnSection:SetPoint("TOPLEFT", 5, -25)
GRA:CreateSeperator(lootDistrConfigFrame, qnSection)

local qns = {}
local function LoadQuickNotes()
    for i = 1, 5 do
        if GRA_Config["notes"][i] then
            qns[i]:SetText(GRA_Config["notes"][i])
            qns[i]:SetAlpha(1)
        else
            qns[i]:SetText(" ")
            qns[i]:SetAlpha(.3)
        end
    end
end

local qnEB = GRA:CreateEditBox(lootDistrConfigFrame, lootDistrConfigFrame:GetWidth() - 10, 20)
GRA:StylizeFrame(qnEB, {.1, .1, .1, .9}, {0, .75, 1, 1})
qnEB:SetPoint("TOPLEFT", qnSection, "BOTTOMLEFT", 0, -30)
qnEB:Hide()

qnEB:HookScript("OnEscapePressed", function()
    qnEB:Hide()
end)

local qnIndex
qnEB:HookScript("OnEnterPressed", function()
    local note = strtrim(qnEB:GetText())
    if note ~= "" then
        if GRA_Config["notes"][qnIndex] then -- exists, changed
            GRA_Config["notes"][qnIndex] = note
        else
            table.insert(GRA_Config["notes"], note) -- create new
        end
    else
        if GRA_Config["notes"][qnIndex] then -- exists, deleted
            table.remove(GRA_Config["notes"], qnIndex)
        end
    end
    qnEB:Hide()
    LoadQuickNotes()
end)

qnEB:SetScript("OnHide", function()
    qnEB:SetText("")
end)

for i = 1, 5 do
    qns[i] = GRA:CreateButton(lootDistrConfigFrame, " ", "blue-hover", {37, 20})
    qns[i]:SetScript("OnClick", function(self)
        qnEB:Show()
        qnEB:SetText(strtrim(qns[i]:GetText()))
        qnEB:SetFocus()
        qnEB:HighlightText()
        qnIndex = i
    end)
    -- qns[i]:Hide()

    if i == 1 then
        qns[i]:SetPoint("TOPLEFT", qnSection, "BOTTOMLEFT", 0, -8)
    else
        qns[i]:SetPoint("LEFT", qns[i - 1], "RIGHT", -1, 0)
    end
end
-- local qnTips = lootDistrConfigFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
-- qnTips:SetText(L["Double-click to edit."])
-- qnTips:SetPoint("LEFT", qnEB)


-----------------------------------------
-- loot master
-----------------------------------------
local masterSection = lootDistrConfigFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
masterSection:SetText("|cff80FF00"..L["Loot Master Only"].."|r")
masterSection:SetPoint("TOPLEFT", 5, -95)
GRA:CreateSeperator(lootDistrConfigFrame, masterSection)

local masterTips = lootDistrConfigFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_TEXT")
masterTips:SetText(gra.colors.firebrick.s .. L["Only when you're the loot master and in a raid instance will these take effect."])
masterTips:SetWidth(lootDistrConfigFrame:GetWidth() - 10)
masterTips:SetSpacing(3)
masterTips:SetPoint("TOPLEFT", masterSection, "BOTTOMLEFT", 0, -8)

local function ShowMask(f)
	if f then
		-- show mask
		GRA:CreateMask(lootDistrConfigFrame, L["Loot distr tool is disabled"], {1, -185, -1, 1})
	else
		-- hide mask if exists
		if lootDistrConfigFrame.mask then lootDistrConfigFrame.mask:Hide() end
	end
end

-----------------------------------------
-- cb
-----------------------------------------
local lootDistrCB = GRA:CreateCheckButton(lootDistrConfigFrame, L["Enable loot distribution tool"], nil, function(checked, cb)
    -- restore check stat
	cb:SetChecked(GRA_Config["enableLootDistr"])
    
    local text
    if GRA_Config["enableLootDistr"] then
        text = gra.colors.firebrick.s .. L["Disable loot distribution tool?"]
    else
        text = gra.colors.firebrick.s .. L["Enable loot distribution tool"] .. "?"
    end
    -- confirm box
    local confirm = GRA:CreateConfirmBox(lootDistrConfigFrame, lootDistrConfigFrame:GetWidth()-10, text, function()
        GRA_Config["enableLootDistr"] = not GRA_Config["enableLootDistr"]
        ShowMask(not GRA_Config["enableLootDistr"])
        cb:SetChecked(GRA_Config["enableLootDistr"])
        -- enable/disable loot distr tool
        GRA:SetLootDistributionEnabled(GRA_Config["enableLootDistr"])
    end)
    confirm:SetPoint("TOP", 0, -190)
end)
lootDistrCB:SetPoint("TOPLEFT", masterSection, "BOTTOMLEFT", -9, -50)

-----------------------------------------
-- reply buttons
-----------------------------------------
local num
local ebs = {}
for i = 1, 7 do
    local eb = GRA:CreateEditBox(lootDistrConfigFrame, 143, 20)
    eb:Hide()
    table.insert(ebs, eb)
    -- eb.index = #ebs
    if i == 1 then
        eb:SetPoint("TOPLEFT", 5, -190)
    else
        eb:SetPoint("TOP", ebs[i - 1], "BOTTOM", 0, -2)
    end
end

local addBtn = GRA:CreateButton(lootDistrConfigFrame, "+", "green", {20, 20}, "GRA_FONT_BUTTON")
addBtn:Hide()
local removeBtn = GRA:CreateButton(lootDistrConfigFrame, "-", "red", {20, 20}, "GRA_FONT_BUTTON")
removeBtn:Hide()

local function UpdateHeight()
    lootDistrConfigFrame:SetHeight(218 + 22 * num)
end

addBtn:SetScript("OnClick", function()
    num = num + 1
    ebs[num]:Show()
    addBtn:ClearAllPoints()
    addBtn:SetPoint("LEFT", ebs[num], "RIGHT", -1, 0)
    removeBtn:Show()
    removeBtn:SetPoint("LEFT", addBtn, "RIGHT", -1, 0)

    if num == 7 then -- last, hide addBtn
        addBtn:ClearAllPoints()
        addBtn:Hide()
        removeBtn:ClearAllPoints()
        removeBtn:SetPoint("LEFT", ebs[num], "RIGHT", -1, 0)
    end

    UpdateHeight()
end)

removeBtn:SetScript("OnClick", function()
    ebs[num]:Hide()
    num = num - 1
    addBtn:Show()
    addBtn:SetPoint("LEFT", ebs[num], "RIGHT", -1, 0)
    removeBtn:ClearAllPoints()
    removeBtn:SetPoint("LEFT", addBtn, "RIGHT", -1, 0)

    if num == 1 then -- only one, hide removeBtn
        removeBtn:ClearAllPoints()
        removeBtn:Hide()
    end

    UpdateHeight()
end)

local function LoadReplyButtons()
    for i = 1, 7 do
        if GRA_Config["replies"][i] then
            ebs[i]:Show()
            ebs[i]:SetText(GRA_Config["replies"][i])
        else
            ebs[i]:Hide()
        end
        ebs[i]:ClearFocus()
    end

    addBtn:Show()
    addBtn:SetPoint("LEFT", ebs[#GRA_Config["replies"]], "RIGHT", -1, 0)
    
    if #GRA_Config["replies"] > 1 then
        removeBtn:Show()
        removeBtn:SetPoint("LEFT", addBtn, "RIGHT", -1, 0)
    end

    UpdateHeight()
end

-----------------------------------------
-- save button
-----------------------------------------
local saveBtn = GRA:CreateButton(lootDistrConfigFrame, L["Save Reply Buttons"], "green", {lootDistrConfigFrame:GetWidth()-10, 20})
saveBtn:SetPoint("BOTTOM", 0, 5)
saveBtn:SetScript("OnClick", function()
    local replies = {}
    for i = 1, num do
        local text = strtrim(ebs[i]:GetText())
        if text ~= "" then
            table.insert(replies, text)
        end
    end
    GRA_Config["replies"] = replies
    num = #replies
    LoadReplyButtons()
    GRA:Print(L["Reply buttons saved."])
end)

-----------------------------------------
-- script
-----------------------------------------
lootDistrConfigFrame:SetScript("OnShow", function()
    ShowMask(not GRA_Config["enableLootDistr"])
    lootDistrCB:SetChecked(GRA_Config["enableLootDistr"])
    num = #GRA_Config["replies"]
    LoadReplyButtons()
    LoadQuickNotes()
end)

lootDistrConfigFrame:SetScript("OnHide", function()
    lootDistrConfigFrame:Hide()
end)