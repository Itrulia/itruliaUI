local addonName, ItruliaUI = ...

local moduleName = "Installer"
local Installer = ItruliaUI:GetModule(moduleName)
local Kit = Installer.Kit

-- The wizard window, ported from atrocityUI's Core/Wizard: window backdrop with a
-- slim header plate and a chevron close, a left rail listing every step in the
-- active flow, step title/description over a per-step content area, a status line
-- and Previous/Next. atrocityUI's progress dots are dropped -- the rail already
-- names every page and says which one you are on, and a second, less specific
-- version of that under it is only noise.
--
-- Steps are plain tables handed in per flow (see steps.lua):
--   title, desc (string or function), build(content, wizard),
--   statusKey, finishLabel, onFinish
local Wizard = {}
Installer.Wizard = Wizard

local sidebarWidth = 150
-- The 14 on top of the round 400 is the strip of squares every gallery now reserves
-- (see Kit.Gallery): without it, equalising the pages would have meant shrinking the
-- single-picture ones to the welcome page's size rather than the other way round.
local windowWidth, windowHeight = 560 + sidebarWidth, 414

-- Insets of the content area, which is what the chrome leaves for a page: the title
-- and description above it, the nav buttons below, the rail to its left.
--
-- atrocityUI leaves 90 at the bottom because the step dots sit in that band; with the
-- dots gone the content only has to clear the nav buttons (12 + 24 high).
local contentTop = 130
local contentBottom = 56
local contentSide = 30

-- A rail heading and the air above it, for a step that opens a section of its own. The
-- gap is what separates the group from the rows before it; without it the heading reads
-- as a label on the row above rather than on the ones below.
local sectionGap = 10
local sectionHeight = 14

local steps = {}
local current = 1
local frame
local pendingHeader

-- A step for an addon that is not loaded: it is in the flow so the rail can say the
-- addon exists and was skipped, but there is nothing to import, so it is not a page
-- you can stand on. Navigation walks over those, and their rail rows take no clicks.
local function findStep(from, direction)
    local i = from

    while i >= 1 and i <= #steps do
        if not steps[i].disabled then
            return i
        end

        i = i + direction
    end

    return nil
end

function Wizard:SetSteps(list)
    steps = list or {}

    -- Both flows open on a welcome page, so this only matters for a flow that does
    -- not: the first page has to be one you can be on.
    current = findStep(1, 1) or 1
end

function Wizard:GetSteps()
    return steps
end

-- "Installer" vs "Update", with an optional smaller dimmed context string beside
-- it, set per flow.
function Wizard:SetHeader(mode, context)
    pendingHeader = { mode = mode or "Installer", context = context }

    if not frame then
        return
    end

    frame.titleMain:SetText("|cffe9e9edItrulia|r|cffe8853dUI|r " .. pendingHeader.mode)

    if context then
        frame.titleContext:SetText(context)
        frame.titleContext:Show()
    else
        frame.titleContext:Hide()
    end
end

local function buildFrame()
    if frame then
        return frame
    end

    frame = CreateFrame("Frame", "ItruliaUIInstaller", UIParent)
    PixelUtil.SetSize(frame, windowWidth, windowHeight)
    PixelUtil.SetPoint(frame, "CENTER", frame:GetParent() or UIParent, "CENTER", 0, 80)
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    Kit.Backdrop(frame)
    Kit.Header(frame, 24)

    local title = frame:CreateFontString(nil, "OVERLAY")
    Kit.SetFont(title, 12)
    PixelUtil.SetPoint(title, "TOPLEFT", title:GetParent() or UIParent, "TOPLEFT", 12, -6)
    title:SetText("|cffe9e9edItrulia|r|cffe8853dUI|r Installer")
    frame.titleMain = title

    local context = frame:CreateFontString(nil, "OVERLAY")
    Kit.SetFont(context, 11)
    PixelUtil.SetPoint(context, "BOTTOMLEFT", title, "BOTTOMRIGHT", 6, 0.5)
    context:SetTextColor(Kit.palette.textDim[1], Kit.palette.textDim[2], Kit.palette.textDim[3])
    context:Hide()
    frame.titleContext = context

    local closeButton = Kit.CloseButton(frame, 14, function() frame:Hide() end)
    PixelUtil.SetPoint(closeButton, "TOPRIGHT", closeButton:GetParent() or UIParent, "TOPRIGHT", -8, -5)

    -- Sidebar rail: the step list, click to jump.
    local side = CreateFrame("Frame", nil, frame)
    PixelUtil.SetPoint(side, "TOPLEFT", side:GetParent() or UIParent, "TOPLEFT", 0, -24)
    PixelUtil.SetPoint(side, "BOTTOMLEFT", side:GetParent() or UIParent, "BOTTOMLEFT", 0, 0)
    side:SetWidth(sidebarWidth)
    frame.side = side
    frame.sideButtons = {}
    frame.sideHeaders = {}

    local divider = side:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(Kit.palette.brand[1], Kit.palette.brand[2], Kit.palette.brand[3], 1)
    PixelUtil.SetPoint(divider, "TOPRIGHT", divider:GetParent() or UIParent, "TOPRIGHT", 0, 0)
    PixelUtil.SetPoint(divider, "BOTTOMRIGHT", divider:GetParent() or UIParent, "BOTTOMRIGHT", 0, 0)
    divider:SetWidth(1)
    frame.sideDivider = divider

    local stepTitle = frame:CreateFontString(nil, "OVERLAY")
    Kit.SetFont(stepTitle, 16)
    PixelUtil.SetPoint(stepTitle, "TOP", stepTitle:GetParent() or UIParent, "TOP", sidebarWidth / 2, -46)
    frame.stepTitle = stepTitle

    local desc = frame:CreateFontString(nil, "OVERLAY")
    Kit.SetFont(desc, 12)
    PixelUtil.SetPoint(desc, "TOP", stepTitle, "BOTTOM", 0, -10)
    PixelUtil.SetPoint(desc, "LEFT", desc:GetParent() or UIParent, "LEFT", sidebarWidth + 30, 0)
    PixelUtil.SetPoint(desc, "RIGHT", desc:GetParent() or UIParent, "RIGHT", -30, 0)
    desc:SetJustifyH("CENTER")
    desc:SetSpacing(3)
    desc:SetTextColor(Kit.palette.text[1], Kit.palette.text[2], Kit.palette.text[3])
    frame.stepDesc = desc

    local status = frame:CreateFontString(nil, "OVERLAY")
    Kit.SetFont(status, 11)
    frame.status = status

    local content = CreateFrame("Frame", nil, frame)
    PixelUtil.SetPoint(content, "TOPLEFT", content:GetParent() or UIParent, "TOPLEFT", sidebarWidth + contentSide, -contentTop)
    PixelUtil.SetPoint(content, "BOTTOMRIGHT", content:GetParent() or UIParent, "BOTTOMRIGHT", -contentSide, contentBottom)
    frame.content = content

    -- Status tops the page's bottom band, with the import button under it and the "as
    -- default" checkbox under that, along the bottom of the content area (see steps.lua).
    PixelUtil.SetPoint(status, "BOTTOM", content, "BOTTOM", 0, 62)

    frame.prevButton = Kit.Button(frame, "Previous", 100, 24, function() Wizard:Go(current - 1) end)
    PixelUtil.SetPoint(frame.prevButton, "BOTTOMLEFT", frame.prevButton:GetParent() or UIParent, "BOTTOMLEFT", sidebarWidth + 14, 12)
    frame.nextButton = Kit.Button(frame, "Next", 100, 24, function() Wizard:Go(current + 1) end)

    -- The way out of the last page that isn't a reload, since the finish button always
    -- reloads now. Only shown there: on every other page "Next" is the way on, and the
    -- corner X is the way out.
    --
    -- It holds the right-hand corner, so the finish button steps left to make room for
    -- it on the last page (see Go).
    frame.closeButton = Kit.Button(frame, "Close", 100, 24, function() frame:Hide() end)
    PixelUtil.SetPoint(frame.closeButton, "BOTTOMRIGHT", frame.closeButton:GetParent() or UIParent, "BOTTOMRIGHT", -14, 12)

    -- Combat puts the window away and brings it back afterwards. Nothing in here is
    -- protected, but a window this size over the middle of the screen is not what you
    -- want when a pull starts -- and the Edit Mode page cannot import in combat at
    -- all, so a page could be sitting there refusing to work.
    --
    -- The flag is set AFTER the hide, because Hide() runs the OnHide below
    -- synchronously: closing the window yourself while in combat clears the flag, so
    -- it stays closed once combat ends.
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_DISABLED" then
            if self:IsShown() then
                self:Hide()
                self.hiddenByCombat = true
            end

            return
        end

        if self.hiddenByCombat then
            self.hiddenByCombat = nil
            Wizard:Show()
        end
    end)

    frame:HookScript("OnHide", function(self)
        self.hiddenByCombat = nil
    end)

    frame:Hide()
    tinsert(UISpecialFrames, "ItruliaUIInstaller")

    if pendingHeader then
        Wizard:SetHeader(pendingHeader.mode, pendingHeader.context)
    end

    return frame
end

-- A page title is an addon's toc title, so it arrives with |cRRGGBBAA ... |r wrapped
-- around it. This takes them back out, for the rail rows that have to read as dim.
local function stripColor(text)
    if not text or not text:find("|c", 1, true) then
        return text
    end

    local plain = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")

    return plain
end

local function updateSidebar()
    local side = frame.side

    if not side then
        return
    end

    -- A one-page flow has nothing to navigate: the rail goes away and the content
    -- reclaims the width.
    local single = #steps <= 1

    side:SetShown(not single)
    frame.sideDivider:SetShown(not single)

    frame.content:ClearAllPoints()
    PixelUtil.SetPoint(frame.content, "TOPLEFT", frame.content:GetParent() or UIParent, "TOPLEFT", single and contentSide or (sidebarWidth + contentSide), -contentTop)
    PixelUtil.SetPoint(frame.content, "BOTTOMRIGHT", frame.content:GetParent() or UIParent, "BOTTOMRIGHT", -contentSide, contentBottom)

    frame.stepTitle:ClearAllPoints()
    PixelUtil.SetPoint(frame.stepTitle, "TOP", frame.stepTitle:GetParent() or UIParent, "TOP", single and 0 or (sidebarWidth / 2), -46)

    frame.stepDesc:ClearAllPoints()
    PixelUtil.SetPoint(frame.stepDesc, "TOP", frame.stepTitle, "BOTTOM", 0, -10)
    PixelUtil.SetPoint(frame.stepDesc, "LEFT", frame.stepDesc:GetParent() or UIParent, "LEFT", single and 30 or (sidebarWidth + 30), 0)
    PixelUtil.SetPoint(frame.stepDesc, "RIGHT", frame.stepDesc:GetParent() or UIParent, "RIGHT", -30, 0)

    if single then
        return
    end

    frame.sideDivider:SetWidth(1)

    local entryHeight = 24

    -- Rows are stacked by a running offset rather than by index, because a step may
    -- carry a `section` heading that takes a slot of its own above it.
    local offset = 8
    local headers = 0

    for i, step in ipairs(steps) do
        if step.section then
            headers = headers + 1

            local header = frame.sideHeaders[headers]

            if not header then
                header = side:CreateFontString(nil, "OVERLAY")
                Kit.SetFont(header, 9)
                header:SetJustifyH("LEFT")
                header:SetWordWrap(false)
                header:SetTextColor(0.40, 0.40, 0.40, 1)
                frame.sideHeaders[headers] = header
            end

            header:ClearAllPoints()
            PixelUtil.SetPoint(header, "TOPLEFT", side, "TOPLEFT", 12, -(offset + sectionGap))
            PixelUtil.SetPoint(header, "RIGHT", side, "RIGHT", -6, 0)
            header:SetText(step.section:upper())
            header:Show()

            offset = offset + sectionGap + sectionHeight
        end

        local button = frame.sideButtons[i]

        if not button then
            button = CreateFrame("Button", nil, side)
            button:SetHeight(entryHeight)

            local highlight = button:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints()
            highlight:SetColorTexture(Kit.palette.brand[1], Kit.palette.brand[2], Kit.palette.brand[3], 0.15)
            highlight:SetBlendMode("ADD")
            button.highlight = highlight

            local background = button:CreateTexture(nil, "BACKGROUND")
            background:SetAllPoints()
            button.background = background

            local bar = button:CreateTexture(nil, "ARTWORK")
            PixelUtil.SetPoint(bar, "TOPLEFT", bar:GetParent() or UIParent, "TOPLEFT", 0, 0)
            PixelUtil.SetPoint(bar, "BOTTOMLEFT", bar:GetParent() or UIParent, "BOTTOMLEFT", 0, 0)
            button.bar = bar

            local text = button:CreateFontString(nil, "OVERLAY")
            Kit.SetFont(text, 11)
            PixelUtil.SetPoint(text, "LEFT", text:GetParent() or UIParent, "LEFT", 12, 0)
            text:SetJustifyH("LEFT")
            text:SetWordWrap(false)
            button.text = text

            -- Why that row is dead, in the row itself: a rail that simply greyed the
            -- addon out would read as "not yet" rather than "not installed".
            local flag = button:CreateFontString(nil, "OVERLAY")
            Kit.SetFont(flag, 9)
            PixelUtil.SetPoint(flag, "RIGHT", flag:GetParent() or UIParent, "RIGHT", -6, 0)
            flag:SetText("Not Installed")
            flag:SetTextColor(Kit.palette.warn[1], Kit.palette.warn[2], Kit.palette.warn[3], 1)
            button.flag = flag

            frame.sideButtons[i] = button
        end

        -- Re-anchored on every render: a row's place in the rail moves when the flow in
        -- front of it changes, and a section heading above it shifts everything down.
        button:ClearAllPoints()
        PixelUtil.SetPoint(button, "TOPLEFT", side, "TOPLEFT", 0, -offset)
        PixelUtil.SetPoint(button, "RIGHT", side, "RIGHT", 0, 0)

        offset = offset + entryHeight

        local disabled = step.disabled

        button.bar:SetWidth(3)

        -- Dead to the mouse, and looks it: the hover wash is taken off too, or the row
        -- would light up under the pointer and then do nothing when clicked.
        button:SetEnabled(not disabled)
        button.highlight:SetShown(not disabled)

        if disabled then
            button:SetScript("OnClick", nil)
        else
            button:SetScript("OnClick", function() Wizard:Go(i) end)
        end

        -- The flag eats into the room the title has, so the title gives way to it only
        -- on the rows that carry one -- anchoring to a hidden flag would shorten every
        -- row. Re-pointed rather than offset, since a region keeps the anchors it has.
        button.flag:SetShown(disabled)
        button.text:ClearAllPoints()
        PixelUtil.SetPoint(button.text, "LEFT", button.text:GetParent() or UIParent, "LEFT", 12, 0)

        if disabled then
            PixelUtil.SetPoint(button.text, "RIGHT", button.flag, "LEFT", -4, 0)
        else
            PixelUtil.SetPoint(button.text, "RIGHT", button.text:GetParent() or UIParent, "RIGHT", -6, 0)
        end

        -- `shortTitle` when the step has one: the rail is a fixed width, so a long
        -- addon name would be cut off mid-word. The page heading still spells it out.
        local title = step.shortTitle or step.title or ("Step " .. i)
        local brand = Kit.palette.brand

        -- Only the page you are on is marked. atrocityUI also dims the pages behind
        -- you in brand, which reads as "done" -- but nothing here has to be imported
        -- in order, and pages are freely jumped between, so a page you walked past
        -- says nothing about whether its addon was imported. The status line on the
        -- page itself is what answers that.
        --
        -- The selected row spells its addon in the addon's own colours; the rest are
        -- flat dim grey. That means STRIPPING the codes rather than colouring over
        -- them -- an embedded |cff wins over SetTextColor, so a row that keeps them
        -- can never read as dim.
        if disabled then
            -- Dimmer than a row you simply are not on, so the two do not read alike.
            button.text:SetText(stripColor(title))
            button.text:SetTextColor(0.40, 0.40, 0.40, 1)
            button.bar:Hide()
            button.background:Hide()
        elseif i == current then
            button.text:SetText(title)
            button.text:SetTextColor(Kit.palette.text[1], Kit.palette.text[2], Kit.palette.text[3], 1)
            button.bar:SetColorTexture(brand[1], brand[2], brand[3], 1)
            button.bar:Show()
            button.background:SetColorTexture(brand[1], brand[2], brand[3], 0.08)
            button.background:Show()
        else
            button.text:SetText(stripColor(title))
            button.text:SetTextColor(Kit.palette.textDim[1], Kit.palette.textDim[2], Kit.palette.textDim[3], 1)
            button.bar:Hide()
            button.background:Hide()
        end

        button:Show()
    end

    for i = #steps + 1, #frame.sideButtons do
        frame.sideButtons[i]:Hide()
    end

    for i = headers + 1, #frame.sideHeaders do
        frame.sideHeaders[i]:Hide()
    end
end

function Wizard:RenderStep()
    local step = steps[current]

    if not step then
        return
    end

    -- A page title is the addon's own toc title, escape codes included, so the colours
    -- are already in the string. SetTextColor only decides what the uncoloured ones
    -- (and any |r-terminated tail) fall back to.
    frame.stepTitle:SetText(step.title or "")
    frame.stepTitle:SetTextColor(Kit.palette.text[1], Kit.palette.text[2], Kit.palette.text[3], 1)

    -- desc may be a function, evaluated when the page is shown: a description that
    -- reads install state cannot be computed when the flow is built.
    local desc = step.desc

    if type(desc) == "function" then
        local ok, text = pcall(desc)
        desc = ok and text or ""
    end

    frame.stepDesc:SetText(desc or "")
    frame.status:SetText("")

    -- Release the previous page's widgets. Children AND regions: FontStrings and
    -- textures created on the content host are regions, which GetChildren never
    -- returns, so a note drawn by one page would otherwise survive onto every page
    -- after it.
    for _, child in ipairs({ frame.content:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end

    for _, region in ipairs({ frame.content:GetRegions() }) do
        region:Hide()
        region:SetParent(nil)
    end

    if step.build then
        step.build(frame.content, self)
    end

    if step.statusKey then
        self:RefreshStatus(step.statusKey)
    end

    -- Measured in pages you can actually be on: a run whose last entries are missing
    -- addons still finishes on the last real page (see findStep).
    local previousStep = findStep(current - 1, -1)
    local nextStep = findStep(current + 1, 1)
    local isLast = nextStep == nil

    frame.prevButton:SetShown(previousStep ~= nil)

    frame.closeButton:SetShown(isLast)

    frame.nextButton:ClearAllPoints()

    if isLast then
        PixelUtil.SetPoint(frame.nextButton, "BOTTOMRIGHT", frame.closeButton, "BOTTOMLEFT", -8, 0)
    else
        PixelUtil.SetPoint(frame.nextButton, "BOTTOMRIGHT", frame.nextButton:GetParent() or UIParent, "BOTTOMRIGHT", -14, 12)
    end

    frame.nextButton:SetLabel(isLast and (step.finishLabel or "Reload") or "Next")
    frame.nextButton:SetScript("OnClick", function()
        local step = steps[current]

        if nextStep then
            Wizard:Go(nextStep)

            return
        end

        if step and step.onFinish then
            step.onFinish()
        end

        -- The run ends in a reload, whether or not anything was imported: EllesmereUI's
        -- profile import is explicitly "the caller reloads right after this returns",
        -- and several of the others only settle their frames on a fresh load. Making it
        -- unconditional beats a button that sometimes reloads and sometimes hides --
        -- the label says what the click does. The corner X still just closes.
        ReloadUI()
    end)

    updateSidebar()
end

function Wizard:Go(index)
    if index < 1 or index > #steps then
        return
    end

    -- Carry on the way you were going when the landing is a disabled row, so Next and
    -- Previous step over a missing addon instead of stopping on it. The second look is
    -- the other way, for a run that ends in disabled rows: better the nearest real page
    -- than nothing happening on the click.
    local direction = index < current and -1 or 1
    local target = findStep(index, direction) or findStep(index, -direction)

    if not target then
        return
    end

    current = target
    self:RenderStep()
end

-- Re-render the current page in place, for a step whose own state changed under it.
function Wizard:Refresh()
    if frame and frame:IsShown() then
        self:RenderStep()
    end
end

function Wizard:RefreshStatus(key)
    if not (frame and frame:IsShown()) then
        return
    end

    local step = steps[current]

    if not step or step.statusKey ~= key then
        return
    end

    frame.status:SetText(Installer:GetStatusText(key))
end

function Wizard:IsShown()
    return frame and frame:IsShown()
end

function Wizard:Hide()
    if frame then
        frame:Hide()
    end
end

-- Bring the current flow back up where it was, re-rendering the page so its status
-- line is current. Used by the combat handler above.
function Wizard:Show()
    if not frame or #steps == 0 then
        return
    end

    frame:Show()
    self:RenderStep()
end

-- Open a flow's page list. An empty list means there was nothing to do; say so
-- rather than showing an empty window.
function Wizard:OpenFlow(list, emptyMessage)
    if not list or #list == 0 then
        if emptyMessage then
            Installer:Toast(emptyMessage, 0.5, 1, 0.5)
        end

        return false
    end

    buildFrame()
    self:SetSteps(list)

    -- Opened in combat -- the login prompt can land mid-pull -- the flow is kept and
    -- shown when combat ends, the same as one hidden by walking into a fight. Without
    -- this the window would arrive in combat and stay, since the event that hides it
    -- has already been and gone.
    if InCombatLockdown() then
        frame.hiddenByCombat = true
        Installer:Toast(addonName .. ": installer will open when you leave combat", 1, 0.85, 0.3)

        return true
    end

    frame:Show()
    self:RenderStep()

    return true
end
