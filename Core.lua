-- Modern Spellbook Rebuilt
-- Fresh implementation for WoW 3.3.5a / Ascension CoA.

local ADDON_NAME = "ModernSpellBook"
local VERSION = "2.2.0-CoA"
local BOOK_SPELL = BOOKTYPE_SPELL or "spell"
local BOOK_PET = BOOKTYPE_PET or "pet"
local QUESTION_MARK = "Interface\\Icons\\INV_Misc_QuestionMark"
local WHITE = "Interface\\Buttons\\WHITE8X8"

local ParentBook = AscensionSpellbookFrame or SpellBookFrame
if not ParentBook then return end

local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[select(2, UnitClass("player"))]
local accentR, accentG, accentB = 0.42, 0.22, 0.95
if classColor then
    accentR, accentG, accentB = classColor.r, classColor.g, classColor.b
end

ModernSpellBookRebuiltDB = ModernSpellBookRebuiltDB or {}
local DB = ModernSpellBookRebuiltDB
if DB.showPassives == nil then DB.showPassives = true end
if DB.showAllRanks == nil then DB.showAllRanks = false end
if DB.mode == nil then DB.mode = "player" end

local function SetBackdrop(frame, alpha, borderAlpha, edgeSize)
    if not frame.SetBackdrop then return end
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = edgeSize or 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame:SetBackdropColor(0.025, 0.03, 0.045, alpha or 0.97)
    frame:SetBackdropBorderColor(accentR * 0.75, accentG * 0.75, accentB * 0.75, borderAlpha or 0.95)
end

local function CreateSolid(parent, layer, sublevel, r, g, b, a)
    local texture = parent:CreateTexture(nil, layer or "BACKGROUND")
    if texture.SetDrawLayer then texture:SetDrawLayer(layer or "BACKGROUND", sublevel or 0) end
    texture:SetTexture(WHITE)
    texture:SetVertexColor(r, g, b, a)
    return texture
end

local function SafeText(value)
    if value == nil then return "" end
    return tostring(value)
end

local function TextureForSlot(slot, bookType, spellID, spellName)
    local texture
    if GetSpellBookItemTexture then
        texture = GetSpellBookItemTexture(slot, bookType)
    end
    if not texture and spellID then
        local _, _, byID = GetSpellInfo(spellID)
        texture = byID
    end
    if not texture and spellName then
        local _, _, byName = GetSpellInfo(spellName)
        texture = byName
    end
    return texture or QUESTION_MARK
end

local function SpellLink(info)
    if info.spellID and GetSpellLink then
        local link = GetSpellLink(info.spellID)
        if link then return link end
    end
    if info.name and info.rank and info.rank ~= "" then
        return info.name .. "(" .. info.rank .. ")"
    end
    return info.name
end

local Frame = CreateFrame("Frame", "ModernSpellBookRebuiltFrame", ParentBook)
Frame:SetFrameStrata("HIGH")
Frame:SetFrameLevel((ParentBook:GetFrameLevel() or 1) + 20)
Frame:SetPoint("TOPLEFT", ParentBook, "TOPLEFT", 28, -54)
Frame:SetPoint("BOTTOMRIGHT", ParentBook, "BOTTOMRIGHT", -42, 46)
Frame:EnableMouse(true)
SetBackdrop(Frame, 0.985, 0.95, 16)
Frame:Hide()

Frame.currentPage = 1
Frame.itemsPerPage = 15
Frame.spells = {}
Frame.pages = {}
Frame.cards = {}
Frame.pendingRefresh = nil
Frame.refreshToken = 0
Frame.mode = DB.mode

local header = CreateSolid(Frame, "BACKGROUND", 0, 0.035, 0.04, 0.065, 1)
header:SetPoint("TOPLEFT", Frame, "TOPLEFT", 5, -5)
header:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -5, -5)
header:SetHeight(50)

local accent = CreateSolid(Frame, "ARTWORK", 0, accentR, accentG, accentB, 0.95)
accent:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
accent:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
accent:SetHeight(2)

local title = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("LEFT", header, "LEFT", 18, 0)
title:SetText("Spellbook")
title:SetTextColor(0.97, 0.98, 1)

local versionText = Frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
versionText:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 19, 7)
versionText:SetText("Rebuilt " .. VERSION)
versionText:SetTextColor(0.52, 0.58, 0.68)

local function StyleButton(button)
    SetBackdrop(button, 0.94, 0.82, 10)
    button:SetBackdropBorderColor(0.18, 0.23, 0.31, 1)
    local hover = CreateSolid(button, "HIGHLIGHT", 0, accentR, accentG, accentB, 0.2)
    hover:SetAllPoints(button)
    button:SetHighlightTexture(hover)
    button:HookScript("OnEnter", function(self)
        self:SetBackdropBorderColor(accentR, accentG, accentB, 1)
    end)
    button:HookScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.18, 0.23, 0.31, 1)
    end)
end

local playerMode = CreateFrame("Button", nil, Frame)
playerMode:SetSize(96, 30)
playerMode:SetPoint("TOP", Frame, "TOP", -106, -15)
playerMode:SetText("Spells")
playerMode:SetNormalFontObject("GameFontNormal")
StyleButton(playerMode)

local petMode = CreateFrame("Button", nil, Frame)
petMode:SetSize(96, 30)
petMode:SetPoint("LEFT", playerMode, "RIGHT", 10, 0)
petMode:SetText("Pet")
petMode:SetNormalFontObject("GameFontNormal")
StyleButton(petMode)

local search = CreateFrame("EditBox", "ModernSpellBookRebuiltSearch", Frame)
search:SetSize(254, 30)
search:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -18, -15)
search:SetAutoFocus(false)
search:SetFontObject("GameFontHighlightSmall")
search:SetTextInsets(10, 10, 0, 0)
SetBackdrop(search, 0.96, 0.8, 10)
search:SetBackdropBorderColor(0.20, 0.26, 0.34, 1)
search.placeholder = search:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
search.placeholder:SetPoint("LEFT", search, "LEFT", 10, 0)
search.placeholder:SetText("Search spells, ranks, categories")
search.placeholder:SetTextColor(0.49, 0.55, 0.64)
search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
search:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
search:SetScript("OnEditFocusGained", function(self)
    self:SetBackdropBorderColor(accentR, accentG, accentB, 1)
end)
search:SetScript("OnEditFocusLost", function(self)
    self:SetBackdropBorderColor(0.20, 0.26, 0.34, 1)
end)
search:SetScript("OnTextChanged", function(self)
    if self:GetText() == "" then self.placeholder:Show() else self.placeholder:Hide() end
    Frame:ScheduleRefresh(0.12, true)
end)

local controls = CreateFrame("Frame", nil, Frame)
controls:SetPoint("TOPLEFT", Frame, "TOPLEFT", 16, -63)
controls:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -16, -63)
controls:SetHeight(38)
controls:EnableMouse(false)

local allRanks = CreateFrame("CheckButton", nil, controls, "UICheckButtonTemplate")
allRanks:SetSize(24, 24)
allRanks:SetPoint("LEFT", controls, "LEFT", 4, 0)
allRanks:SetChecked(DB.showAllRanks)
allRanks.label = controls:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
allRanks.label:SetPoint("LEFT", allRanks, "RIGHT", 2, 0)
allRanks.label:SetText("Show all spell ranks")
allRanks.label:SetTextColor(0.88, 0.90, 0.96)
allRanks:SetScript("OnClick", function(self)
    DB.showAllRanks = self:GetChecked() and true or false
    Frame.currentPage = 1
    Frame:Refresh()
end)

local passives = CreateFrame("CheckButton", nil, controls, "UICheckButtonTemplate")
passives:SetSize(24, 24)
passives:SetPoint("LEFT", controls, "LEFT", 245, 0)
passives:SetChecked(DB.showPassives)
passives.label = controls:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
passives.label:SetPoint("LEFT", passives, "RIGHT", 2, 0)
passives.label:SetText("Show passives")
passives.label:SetTextColor(0.88, 0.90, 0.96)
passives:SetScript("OnClick", function(self)
    DB.showPassives = self:GetChecked() and true or false
    Frame.currentPage = 1
    Frame:Refresh()
end)

local countText = controls:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
countText:SetPoint("RIGHT", controls, "RIGHT", -5, 0)
countText:SetTextColor(0.53, 0.60, 0.70)

local categoryBar = CreateFrame("Frame", nil, Frame)
categoryBar:SetPoint("TOPLEFT", Frame, "TOPLEFT", 16, -105)
categoryBar:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -16, -105)
categoryBar:SetHeight(34)
categoryBar:EnableMouse(false)

local categoryLine = CreateSolid(categoryBar, "BACKGROUND", 0, accentR, accentG, accentB, 0.28)
categoryLine:SetPoint("BOTTOMLEFT", categoryBar, "BOTTOMLEFT", 0, 0)
categoryLine:SetPoint("BOTTOMRIGHT", categoryBar, "BOTTOMRIGHT", 0, 0)
categoryLine:SetHeight(1)

local categoryTitle = categoryBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
categoryTitle:SetPoint("LEFT", categoryBar, "LEFT", 4, 1)
categoryTitle:SetTextColor(accentR, accentG, accentB)
categoryTitle:SetText("Spells")

local categoryPageText = categoryBar:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
categoryPageText:SetPoint("RIGHT", categoryBar, "RIGHT", -4, 1)
categoryPageText:SetTextColor(0.58, 0.64, 0.73)

local grid = CreateFrame("Frame", nil, Frame)
grid:SetPoint("TOPLEFT", Frame, "TOPLEFT", 16, -148)
grid:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", -16, 78)
grid:EnableMouse(false)

local emptyText = grid:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
emptyText:SetPoint("CENTER", grid, "CENTER", 0, 10)
emptyText:SetText("No spells found")
emptyText:SetTextColor(0.68, 0.73, 0.82)
emptyText:Hide()

local previous = CreateFrame("Button", nil, Frame)
previous:SetSize(174, 40)
previous:SetPoint("BOTTOM", Frame, "BOTTOM", -205, 18)
previous:SetText("<  Previous Page")
previous:SetNormalFontObject("GameFontNormal")
StyleButton(previous)
previous:SetFrameLevel(Frame:GetFrameLevel() + 8)

local nextButton = CreateFrame("Button", nil, Frame)
nextButton:SetSize(174, 40)
nextButton:SetPoint("BOTTOM", Frame, "BOTTOM", 205, 18)
nextButton:SetText("Next Page  >")
nextButton:SetNormalFontObject("GameFontNormal")
StyleButton(nextButton)
nextButton:SetFrameLevel(Frame:GetFrameLevel() + 8)

local pageText = Frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
pageText:SetPoint("BOTTOM", Frame, "BOTTOM", 0, 31)
pageText:SetText("Page 1 of 1")
pageText:SetTextColor(0.94, 0.96, 1)

local function UpdateModeAppearance()
    local isPlayer = Frame.mode == "player"
    playerMode:SetBackdropBorderColor(isPlayer and accentR or 0.18, isPlayer and accentG or 0.23, isPlayer and accentB or 0.31, 1)
    petMode:SetBackdropBorderColor((not isPlayer) and accentR or 0.18, (not isPlayer) and accentG or 0.23, (not isPlayer) and accentB or 0.31, 1)
end

playerMode:SetScript("OnClick", function()
    Frame.mode = "player"
    DB.mode = "player"
    Frame.currentPage = 1
    UpdateModeAppearance()
    Frame:Refresh()
end)

petMode:SetScript("OnClick", function()
    Frame.mode = "pet"
    DB.mode = "pet"
    Frame.currentPage = 1
    UpdateModeAppearance()
    Frame:Refresh()
end)

local function CreateCard(index)
    local card = CreateFrame("Button", nil, grid, "SecureActionButtonTemplate")
    card:SetSize(232, 62)
    card:RegisterForClicks("AnyUp")
    card:RegisterForDrag("LeftButton")
    card:SetFrameLevel(Frame:GetFrameLevel() + 4)
    SetBackdrop(card, 0.94, 0.72, 10)
    card:SetBackdropBorderColor(0.13, 0.17, 0.24, 1)

    card.iconBackground = CreateSolid(card, "BACKGROUND", 1, 0.02, 0.025, 0.035, 1)
    card.iconBackground:SetSize(48, 48)
    card.iconBackground:SetPoint("LEFT", card, "LEFT", 7, 0)

    card.icon = card:CreateTexture(nil, "ARTWORK")
    card.icon:SetSize(42, 42)
    card.icon:SetPoint("CENTER", card.iconBackground, "CENTER", 0, 0)
    card.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    card.cooldown = CreateFrame("Cooldown", nil, card, "CooldownFrameTemplate")
    card.cooldown:SetAllPoints(card.icon)
    if card.cooldown.SetDrawEdge then card.cooldown:SetDrawEdge(false) end

    card.name = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    card.name:SetPoint("TOPLEFT", card, "TOPLEFT", 62, -8)
    card.name:SetPoint("RIGHT", card, "RIGHT", -7, 0)
    card.name:SetJustifyH("LEFT")
    card.name:SetJustifyV("TOP")
    card.name:SetTextColor(0.96, 0.97, 1)

    card.rank = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    card.rank:SetPoint("TOPLEFT", card.name, "BOTTOMLEFT", 0, -2)
    card.rank:SetPoint("RIGHT", card, "RIGHT", -7, 0)
    card.rank:SetJustifyH("LEFT")
    card.rank:SetTextColor(0.58, 0.64, 0.73)

    card.category = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    card.category:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 62, 7)
    card.category:SetPoint("RIGHT", card, "RIGHT", -7, 0)
    card.category:SetJustifyH("LEFT")
    card.category:SetTextColor(accentR, accentG, accentB)

    card.highlight = CreateSolid(card, "HIGHLIGHT", 0, accentR, accentG, accentB, 0.13)
    card.highlight:SetAllPoints(card)
    card:SetHighlightTexture(card.highlight)

    card:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(accentR, accentG, accentB, 1)
        local info = self.info
        if not info then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if GameTooltip.SetSpellBookItem and info.slot then
            GameTooltip:SetSpellBookItem(info.slot, info.bookType)
        elseif info.spellID and GameTooltip.SetSpellByID then
            GameTooltip:SetSpellByID(info.spellID)
        else
            GameTooltip:SetText(info.name or "Spell")
        end
        GameTooltip:Show()
    end)

    card:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.13, 0.17, 0.24, 1)
        GameTooltip:Hide()
    end)

    card:SetScript("OnMouseDown", function(self)
        local info = self.info
        if not info then return end
        if IsModifiedClick and IsModifiedClick("CHATLINK") then
            local link = SpellLink(info)
            if link and ChatEdit_InsertLink then ChatEdit_InsertLink(link) end
        end
    end)

    card:SetScript("OnDragStart", function(self)
        local info = self.info
        if not info or info.passive or InCombatLockdown() then return end
        if info.bookType == BOOK_PET and PickupPetSpell then
            PickupPetSpell(info.slot)
        elseif PickupSpell then
            PickupSpell(info.slot, BOOK_SPELL)
        end
    end)

    card:SetScript("OnUpdate", function(self, elapsed)
        if not self.info or self.info.passive then return end
        self.cooldownElapsed = (self.cooldownElapsed or 0) + elapsed
        if self.cooldownElapsed < 0.15 then return end
        self.cooldownElapsed = 0
        local name = self.info.castName or self.info.name
        if name and GetSpellCooldown and CooldownFrame_Set then
            local start, duration, enabled = GetSpellCooldown(name)
            CooldownFrame_Set(self.cooldown, start or 0, duration or 0, enabled or 0)
        end
    end)

    Frame.cards[index] = card
    return card
end

local function HideCards()
    for _, card in ipairs(Frame.cards) do
        card:Hide()
        card.info = nil
        card:SetAttribute("type1", nil)
        card:SetAttribute("spell", nil)
        if card.cooldown then card.cooldown:Hide() end
    end
end

local function ReadSpellSlot(slot, bookType, category)
    local name, rank = GetSpellBookItemName(slot, bookType)
    if not name or name == "" then return nil end

    local itemType, spellID = GetSpellBookItemInfo(slot, bookType)
    local nameByID, rankByID = nil, nil
    if spellID then
        nameByID, rankByID = GetSpellInfo(spellID)
    end

    name = name or nameByID
    rank = rank or rankByID or ""
    if not name then return nil end

    local passive = false
    if IsPassiveSpell then passive = IsPassiveSpell(slot, bookType) and true or false end

    return {
        name = name,
        rank = rank or "",
        category = category or "Spells",
        sourceCategory = category or "Spells",
        slot = slot,
        bookType = bookType,
        spellID = spellID,
        itemType = itemType,
        passive = passive,
        icon = TextureForSlot(slot, bookType, spellID, name),
        castName = nameByID or name,
    }
end

local function BuildTalentCategoryLookup()
    local lookup = {}
    local categoryOrder = {}
    local seenCategories = {}

    if not GetNumTalentTabs or not GetTalentTabInfo or not GetNumTalents or not GetTalentInfo then
        return lookup, categoryOrder
    end

    local tabCount = GetNumTalentTabs() or 0
    for tab = 1, tabCount do
        local tabName = GetTalentTabInfo(tab)
        tabName = tabName or ("Talent Tree " .. tab)
        if not seenCategories[tabName] then
            table.insert(categoryOrder, tabName)
            seenCategories[tabName] = true
        end

        local talentCount = GetNumTalents(tab) or 0
        for talent = 1, talentCount do
            local talentName, _, _, _, currentRank = GetTalentInfo(tab, talent)
            if talentName and (currentRank or 0) > 0 then
                lookup[string.lower(talentName)] = tabName
            end
        end
    end

    return lookup, categoryOrder
end

local function CollectPlayerSpells()
    local output = {}
    local tabs = GetNumSpellTabs and GetNumSpellTabs() or 0
    local talentLookup, talentOrder = BuildTalentCategoryLookup()
    local spellTabOrder = {}
    local seenSpellTabs = {}

    for tab = 1, tabs do
        local tabName, _, offset, count = GetSpellTabInfo(tab)
        tabName = tabName or ("Category " .. tab)
        offset = offset or 0
        count = count or 0

        if not seenSpellTabs[tabName] then
            table.insert(spellTabOrder, tabName)
            seenSpellTabs[tabName] = true
        end

        for i = 1, count do
            local slot = offset + i
            local info = ReadSpellSlot(slot, BOOK_SPELL, tabName)
            if info and (DB.showPassives or not info.passive) then
                local talentCategory = talentLookup[string.lower(info.name or "")]
                if talentCategory then
                    info.category = talentCategory
                    info.isTalentAbility = true
                end
                table.insert(output, info)
            end
        end
    end

    Frame.categoryOrder = {}
    local added = {}
    for _, name in ipairs(talentOrder) do
        table.insert(Frame.categoryOrder, name)
        added[name] = true
    end
    for _, name in ipairs(spellTabOrder) do
        if not added[name] then
            table.insert(Frame.categoryOrder, name)
            added[name] = true
        end
    end

    return output
end

local function CollectPetSpells()
    local output = {}
    local petName = UnitName("pet") or "Pet"
    local misses = 0

    for slot = 1, 200 do
        local info = ReadSpellSlot(slot, BOOK_PET, petName)
        if info then
            misses = 0
            if DB.showPassives or not info.passive then
                table.insert(output, info)
            end
        else
            misses = misses + 1
            if misses >= 12 and slot > 24 then break end
        end
    end

    return output
end

local function RankNumber(rank)
    if not rank then return 0 end
    local value = string.match(rank, "(%d+)")
    return tonumber(value) or 0
end

local function FilterAndSort(spells)
    local query = string.lower(search:GetText() or "")
    query = string.gsub(query, "^%s+", "")
    query = string.gsub(query, "%s+$", "")

    local filtered = {}
    for _, info in ipairs(spells) do
        local haystack = string.lower((info.name or "") .. " " .. (info.rank or "") .. " " .. (info.category or ""))
        if query == "" or string.find(haystack, query, 1, true) then
            table.insert(filtered, info)
        end
    end

    if not DB.showAllRanks then
        local best = {}
        local order = {}
        for _, info in ipairs(filtered) do
            local key = string.lower((info.category or "") .. "|" .. (info.name or ""))
            local existing = best[key]
            if not existing then
                best[key] = info
                table.insert(order, key)
            elseif RankNumber(info.rank) >= RankNumber(existing.rank) then
                best[key] = info
            end
        end
        filtered = {}
        for _, key in ipairs(order) do table.insert(filtered, best[key]) end
    end

    table.sort(filtered, function(a, b)
        local ac, bc = string.lower(a.category or ""), string.lower(b.category or "")
        if ac ~= bc then return ac < bc end
        local an, bn = string.lower(a.name or ""), string.lower(b.name or "")
        if an ~= bn then return an < bn end
        return RankNumber(a.rank) < RankNumber(b.rank)
    end)

    return filtered
end

local function BuildCategoryPages(spells)
    local grouped = {}
    local categoryNames = {}
    local seen = {}

    for _, info in ipairs(spells) do
        local category = info.category or "Spells"
        if not grouped[category] then
            grouped[category] = {}
            if not seen[category] then
                table.insert(categoryNames, category)
                seen[category] = true
            end
        end
        table.insert(grouped[category], info)
    end

    local orderedCategories = {}
    local orderedSeen = {}
    for _, category in ipairs(Frame.categoryOrder or {}) do
        if grouped[category] and #grouped[category] > 0 then
            table.insert(orderedCategories, category)
            orderedSeen[category] = true
        end
    end
    table.sort(categoryNames, function(a, b) return string.lower(a) < string.lower(b) end)
    for _, category in ipairs(categoryNames) do
        if not orderedSeen[category] then
            table.insert(orderedCategories, category)
            orderedSeen[category] = true
        end
    end

    local pages = {}
    for _, category in ipairs(orderedCategories) do
        local list = grouped[category]
        local categoryPages = math.max(1, math.ceil(#list / Frame.itemsPerPage))
        for categoryPage = 1, categoryPages do
            local pageSpells = {}
            local first = (categoryPage - 1) * Frame.itemsPerPage + 1
            local last = math.min(#list, first + Frame.itemsPerPage - 1)
            for i = first, last do table.insert(pageSpells, list[i]) end
            table.insert(pages, {
                category = category,
                categoryPage = categoryPage,
                categoryPages = categoryPages,
                spells = pageSpells,
            })
        end
    end

    return pages
end

function Frame:PopulateCards()
    HideCards()

    local total = #self.spells
    local maxPages = math.max(1, #self.pages)
    self.currentPage = math.max(1, math.min(self.currentPage, maxPages))
    local page = self.pages[self.currentPage]
    local pageSpells = page and page.spells or {}
    local shown = 0

    local width = math.max(720, grid:GetWidth())
    local height = math.max(350, grid:GetHeight())
    local columns = 3
    local rows = 5
    local horizontalGap = 12
    local verticalGap = 10
    local cardWidth = math.floor((width - horizontalGap * (columns - 1)) / columns)
    local cardHeight = math.floor((height - verticalGap * (rows - 1)) / rows)
    cardWidth = math.max(210, math.min(340, cardWidth))
    cardHeight = math.max(60, math.min(72, cardHeight))

    for _, info in ipairs(pageSpells) do
        shown = shown + 1
        local card = self.cards[shown] or CreateCard(shown)
        local column = (shown - 1) % columns
        local row = math.floor((shown - 1) / columns)

        card:ClearAllPoints()
        card:SetSize(cardWidth, cardHeight)
        card:SetPoint("TOPLEFT", grid, "TOPLEFT", column * (cardWidth + horizontalGap), -row * (cardHeight + verticalGap))
        card.info = info
        card.icon:SetTexture(info.icon or QUESTION_MARK)
        card.name:SetText(info.name or "Unknown Spell")
        card.rank:SetText(info.rank ~= "" and info.rank or (info.passive and "Passive" or ""))
        card.category:SetText(info.isTalentAbility and "Talent ability" or (info.sourceCategory or info.category or "Spells"))
        if info.passive then card.cooldown:Hide() else card.cooldown:Show() end
        card.cooldownElapsed = 0.2

        card:SetAttribute("type1", nil)
        card:SetAttribute("spell", nil)
        card:SetAttribute("action", nil)
        if not info.passive and info.bookType == BOOK_SPELL then
            card:SetAttribute("type1", "spell")
            card:SetAttribute("spell", info.castName or info.name)
        elseif not info.passive and info.bookType == BOOK_PET then
            card:SetAttribute("type1", "pet")
            card:SetAttribute("action", info.castName or info.name)
        end

        card:Show()
    end

    if total == 0 then
        emptyText:Show()
        categoryTitle:SetText(self.mode == "pet" and "Pet Spells" or "Spells")
        categoryPageText:SetText("")
    else
        emptyText:Hide()
        categoryTitle:SetText(page.category or "Spells")
        if page.categoryPages and page.categoryPages > 1 then
            categoryPageText:SetText(string.format("Category page %d of %d", page.categoryPage, page.categoryPages))
        else
            categoryPageText:SetText(string.format("%d spell%s in category", #pageSpells, #pageSpells == 1 and "" or "s"))
        end
    end

    pageText:SetText(string.format("Page %d of %d", self.currentPage, maxPages))
    countText:SetText(string.format("%d spell%s", total, total == 1 and "" or "s"))

    if self.currentPage > 1 then previous:Enable() else previous:Disable() end
    if self.currentPage < maxPages then nextButton:Enable() else nextButton:Disable() end
    previous:SetAlpha(self.currentPage > 1 and 1 or 0.42)
    nextButton:SetAlpha(self.currentPage < maxPages and 1 or 0.42)
end

function Frame:Refresh()
    if InCombatLockdown and InCombatLockdown() then
        self.pendingRefresh = true
        return
    end

    local raw
    if self.mode == "pet" then
        raw = CollectPetSpells()
    else
        raw = CollectPlayerSpells()
    end

    self.spells = FilterAndSort(raw)
    self.pages = BuildCategoryPages(self.spells)
    self:PopulateCards()
    self.pendingRefresh = nil
end

function Frame:ScheduleRefresh(delay, resetPage)
    self.refreshToken = self.refreshToken + 1
    local token = self.refreshToken
    if resetPage then self.currentPage = 1 end

    local timer = CreateFrame("Frame")
    timer.remaining = delay or 0
    timer:SetScript("OnUpdate", function(self, elapsed)
        self.remaining = self.remaining - elapsed
        if self.remaining > 0 then return end
        self:SetScript("OnUpdate", nil)
        if token == Frame.refreshToken and Frame:IsShown() then
            Frame:Refresh()
        end
    end)
end

previous:SetScript("OnClick", function()
    if Frame.currentPage <= 1 then return end
    Frame.currentPage = Frame.currentPage - 1
    Frame:PopulateCards()
    PlaySound("igMainMenuOptionCheckBoxOn")
end)

nextButton:SetScript("OnClick", function()
    local maxPages = math.max(1, #Frame.pages)
    if Frame.currentPage >= maxPages then return end
    Frame.currentPage = Frame.currentPage + 1
    Frame:PopulateCards()
    PlaySound("igMainMenuOptionCheckBoxOn")
end)

Frame:EnableMouseWheel(true)
Frame:SetScript("OnMouseWheel", function(_, delta)
    local maxPages = math.max(1, #Frame.pages)
    if delta < 0 and Frame.currentPage < maxPages then
        Frame.currentPage = Frame.currentPage + 1
        Frame:PopulateCards()
    elseif delta > 0 and Frame.currentPage > 1 then
        Frame.currentPage = Frame.currentPage - 1
        Frame:PopulateCards()
    end
end)

local function IsSpellContentActive()
    if not AscensionSpellbookFrame then return true end
    if not AscensionSpellbookFrame.currentContent then return true end
    local name = AscensionSpellbookFrame.currentContent:GetName()
    return not name or name == "AscensionSpellbookFrameContentSpells"
end

local function NativeSpellContent(show)
    if AscensionSpellbookFrameContentSpells then
        if show then
            AscensionSpellbookFrameContentSpells:Show()
            AscensionSpellbookFrameContentSpells:EnableMouse(true)
        else
            AscensionSpellbookFrameContentSpells:EnableMouse(false)
            AscensionSpellbookFrameContentSpells:Hide()
        end
    end

    for i = 1, 12 do
        local button = _G["SpellButton" .. i]
        if button then
            if show then button:Show() else button:Hide() end
        end
    end
end

local originalWidth
local originalHeight
local function Activate()
    if not ParentBook:IsShown() then return end
    if not IsSpellContentActive() then
        Frame:Hide()
        NativeSpellContent(true)
        if originalWidth then ParentBook:SetWidth(originalWidth) end
        if originalHeight then ParentBook:SetHeight(originalHeight) end
        return
    end

    originalWidth = originalWidth or ParentBook:GetWidth()
    originalHeight = originalHeight or ParentBook:GetHeight()
    ParentBook:SetWidth(math.max(originalWidth or 500, 980))
    ParentBook:SetHeight(math.max(originalHeight or 600, 720))
    NativeSpellContent(false)
    Frame:Show()
    UpdateModeAppearance()
    Frame:ScheduleRefresh(0.05, false)
end

local function Deactivate()
    Frame:Hide()
    HideCards()
    NativeSpellContent(true)
    if originalWidth then ParentBook:SetWidth(originalWidth) end
    if originalHeight then ParentBook:SetHeight(originalHeight) end
end

ParentBook:HookScript("OnShow", function()
    Activate()
    Frame:ScheduleRefresh(0.20, false)
end)
ParentBook:HookScript("OnHide", Deactivate)

if AscensionSpellbookFrame and AscensionSpellbookFrame.UpdateSpells then
    hooksecurefunc(AscensionSpellbookFrame, "UpdateSpells", function()
        if ParentBook:IsShown() then
            Activate()
        end
    end)
elseif SpellBookFrame_Update then
    hooksecurefunc("SpellBookFrame_Update", function()
        if ParentBook:IsShown() then Activate() end
    end)
end

local events = CreateFrame("Frame")
events:RegisterEvent("SPELLS_CHANGED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("UNIT_PET")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("PLAYER_TALENT_UPDATE")
events:SetScript("OnEvent", function(_, event, unit)
    if event == "UNIT_PET" and unit ~= "player" then return end
    if event == "PLAYER_REGEN_ENABLED" and not Frame.pendingRefresh then return end
    if Frame:IsShown() then Frame:ScheduleRefresh(0.10, false) end
end)

SLASH_MODERNSPELLBOOKREBUILT1 = "/msb"
SlashCmdList.MODERNSPELLBOOKREBUILT = function(message)
    message = string.lower(message or "")
    if message == "refresh" then
        Frame:Refresh()
        print("Modern Spellbook: refreshed.")
    elseif message == "reset" then
        DB.showPassives = true
        DB.showAllRanks = false
        DB.mode = "player"
        Frame.mode = "player"
        Frame.currentPage = 1
        passives:SetChecked(true)
        allRanks:SetChecked(false)
        search:SetText("")
        UpdateModeAppearance()
        Frame:Refresh()
        print("Modern Spellbook: settings reset.")
    elseif message == "debug" then
        local tabs = GetNumSpellTabs and GetNumSpellTabs() or 0
        print(string.format("Modern Spellbook %s: mode=%s, tabs=%d, rendered=%d, page=%d", VERSION, Frame.mode, tabs, #Frame.spells, Frame.currentPage))
    else
        print("Modern Spellbook commands: /msb refresh, /msb reset, /msb debug")
    end
end

UpdateModeAppearance()
