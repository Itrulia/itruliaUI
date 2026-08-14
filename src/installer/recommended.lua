local _, ItruliaUI = ...

local moduleName = "Installer"
local Installer = ItruliaUI:GetModule(moduleName)
local Kit = Installer.Kit

Installer.recommended = {
    {
        title = "Auto Potion",
        folder = "AutoPotion",
        description = "Updates the Macro AutoPotion to use either Healthstone or Healing Potion",
        url = "https://www.curseforge.com/projects/312940",
    },
    {
        title = "BetterUpgradeTooltip",
        folder = "BetterUpgradeTooltip",
        description = "Enhances item upgrade tooltips with ilvl ranges and crest info",
        url = "https://www.curseforge.com/wow/addons/betterupgradetooltip",
    },
    {
        title = "Plumber",
        folder = "Plumber",
        description = "Quality-of-life features including Expansion Summary UI, Loot Window, Instance Difficulty Selector and more.",
        url = "https://www.curseforge.com/wow/addons/plumber",
    },
    {
        title = "Talent Loadout Ex",
        folder = "TalentLoadoutsEx",
        description = "Multiple talent settings will be saved without limitation.",
        url = "https://www.curseforge.com/projects/730873",
    },
    {
        title = "Talent Tree Tweaks",
        folder = "TalentTreeTweaks",
        description = "Various improvements and addition to the Retail talent tree and profession tree UI",
        url = "https://www.curseforge.com/projects/678792",
    },
    {
        title = "Waypoint UI",
        folder = "WaypointUI",
        description = "An in-world waypoint and pinpoint to show relevant information directly in world-space.",
        url = "https://www.curseforge.com/wow/addons/waypointui",
    },
}

local rowGap = 4
local titleTopPad = 4
local titleDescGap = 3
local rowBottomPad = 4

-- Air above the first row and below the last, so the list does not start or stop hard
-- against the edge of the viewport once it scrolls.
local topPad = 8
local bottomPad = 8

local function isInstalled(folder)
    local exists = C_AddOns and C_AddOns.DoesAddOnExist

    return exists and exists(folder) and true or false
end

local function isEnabled(folder)
    local getState = C_AddOns and C_AddOns.GetAddOnEnableState

    if not getState then
        return true
    end

    -- Without a character argument this reports across all characters, so an addon
    -- disabled here but enabled elsewhere would read back as "Some" and pass as enabled.
    return getState(folder, UnitName("player")) == Enum.AddOnEnableState.All
end

-- One addon: name and what it does on the left, its state on the right, the whole row
-- clickable for the link. A row for something you already have says so and stops being
-- a link -- there is nothing to go and get. An installed addon that is disabled says so
-- too, since "Installed" alone would read as ready when it is not loading at all.
local function buildRow(parent, entry, width)
    local installed = isInstalled(entry.folder)
    local enabled = installed and isEnabled(entry.folder)
    local hasURL = entry.url and entry.url ~= ""

    local row = CreateFrame("Button", nil, parent)
    PixelUtil.SetWidth(row, width)

    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(Kit.palette.brand[1], Kit.palette.brand[2], Kit.palette.brand[3], 0.10)
    highlight:SetBlendMode("ADD")

    local state = row:CreateFontString(nil, "OVERLAY")
    Kit.SetFont(state, 10)
    PixelUtil.SetPoint(state, "RIGHT", row, "RIGHT", -4, 0)

    if installed and not enabled then
        state:SetText("Disabled")
        state:SetTextColor(Kit.palette.warn[1], Kit.palette.warn[2], Kit.palette.warn[3])
    elseif installed then
        state:SetText("Installed")
        state:SetTextColor(0.30, 0.75, 0.30)
    elseif hasURL then
        state:SetText("Get the link")
        state:SetTextColor(Kit.palette.brand[1], Kit.palette.brand[2], Kit.palette.brand[3])
    else
        state:SetText("No link set")
        state:SetTextColor(Kit.palette.textDim[1], Kit.palette.textDim[2], Kit.palette.textDim[3])
    end

    local title = row:CreateFontString(nil, "OVERLAY")
    Kit.SetFont(title, 12)
    PixelUtil.SetPoint(title, "TOPLEFT", row, "TOPLEFT", 4, -titleTopPad)
    PixelUtil.SetPoint(title, "RIGHT", state, "LEFT", -8, 0)
    title:SetJustifyH("LEFT")
    title:SetWordWrap(false)
    title:SetText(entry.title)

    -- An addon you already have is listed for completeness rather than as something to
    -- act on, so it reads back a step.
    if installed then
        title:SetTextColor(Kit.palette.textDim[1], Kit.palette.textDim[2], Kit.palette.textDim[3])
    else
        title:SetTextColor(Kit.palette.text[1], Kit.palette.text[2], Kit.palette.text[3])
    end

    local description = row:CreateFontString(nil, "OVERLAY")
    Kit.SetFont(description, 10)
    PixelUtil.SetPoint(description, "TOPLEFT", title, "BOTTOMLEFT", 0, -titleDescGap)
    description:SetJustifyH("LEFT")
    description:SetWordWrap(true)
    description:SetTextColor(Kit.palette.textDim[1], Kit.palette.textDim[2], Kit.palette.textDim[3])

    -- An explicit width rather than a second (RIGHT) anchor: a wrapped FontString only
    -- resolves an anchor-implied width on the next layout pass, so GetStringHeight()
    -- below would read back last frame's (too-short) height and rows would overlap.
    PixelUtil.SetWidth(description, width - 16 - state:GetStringWidth())
    description:SetText(entry.description)

    if hasURL and not installed then
        row:SetScript("OnClick", function(self)
            Kit.ShowLink(entry.url, self)
        end)
    else
        row:SetScript("OnClick", nil)
        highlight:SetAlpha(0)
    end

    -- Rows are as tall as their wrapped description needs, so a long blurb gets its own
    -- extra lines rather than being clamped to whatever a short one would fit in.
    local rowHeight = titleTopPad + title:GetStringHeight() + titleDescGap + description:GetStringHeight() + rowBottomPad
    PixelUtil.SetHeight(row, rowHeight)

    return row, rowHeight
end

-- The page, appended to the install flow (see steps.lua). No status line, no import
-- button, no "as default" box: nothing here is imported, so the bottom band the addon
-- pages reserve is given back to the list.
function Installer:RecommendedStep()
    return {
        title = "Recommended addons",
        shortTitle = "Recommended",
        section = "Extras",
        desc = "Addons that pair well with this setup. None of them are required, and the "
            .. "installer does not touch them: click one for a link you can copy.",
        build = function(content)
            -- The list is longer than the page is tall, and grows whenever an addon is
            -- added to it, so it lives in a viewport rather than straight on the page.
            local list, refresh = Kit.ScrollList(content)
            local width = list:GetWidth()

            local previous
            local height = topPad

            for _, entry in ipairs(Installer.recommended) do
                local row, rowHeight = buildRow(list, entry, width)

                if previous then
                    PixelUtil.SetPoint(row, "TOPLEFT", previous, "BOTTOMLEFT", 0, -rowGap)
                    height = height + rowGap
                else
                    PixelUtil.SetPoint(row, "TOPLEFT", list, "TOPLEFT", 0, -topPad)
                end

                height = height + rowHeight
                previous = row
            end

            PixelUtil.SetSize(list, width, height + bottomPad)
            refresh()
        end,
    }
end
