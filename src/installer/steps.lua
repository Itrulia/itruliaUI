local addonName, ItruliaUI = ...

local moduleName = "Installer"
local Installer = ItruliaUI:GetModule(moduleName)
local Kit = Installer.Kit

-- Page definitions and the two flows.
--
--   install  every addon that is loaded, in registration order
--   update   only the addons whose bundled profile is newer than what was imported
--
-- atrocityUI has a third, "load", which activates already-imported profiles on an
-- alt. There is no equivalent here: the profiles themselves are stored account-wide,
-- and the pick an alt would otherwise have to make is what the "as default" checkbox
-- settles once -- it writes the fallback profile every character starts on.

local buttonWidth, buttonHeight = 200, 28

-- Breathing room around the gallery: the same gap under the page description above it
-- as above whatever sits below it, so the pictures read as their own band rather than
-- crowding the button. Same value the EllesmereUI page puts above its checkbox grid.
local pad = 14

-- Where the wizard anchors the status line, which tops the bottom band of a page.
local statusY = 62

-- The bottom band, read from the bottom up: the "as default" checkbox sits UNDER the
-- import button, on the pages whose addon has a fallback profile to write. The band is
-- reserved whether or not a page draws the box, so the gallery above it is the same size
-- on every page of a run.
local defaultY, defaultHeight = 4, 20
local buttonY = defaultY + defaultHeight + 6

-- Above the status line the wizard puts 62 up, which the button and the checkbox sit
-- under. An addon's note sits in this slot.
local noteY = 79

-- What a page keeps below its gallery: the bottom band -- button, checkbox, status line
-- -- and a gap above it. One figure for every page, welcome included, so the pictures
-- come out the same size wherever you are in the run. The welcome page has no status
-- line of its own and puts its note in that slot instead.
--
-- The gallery gets what is left of the content box, which keeps the window at the same
-- size on every page -- the pictures come out thumbnail-sized, so clicking one opens it
-- full screen (see Kit.Gallery).
local footerHeight = statusY + 13 + pad

-- The screenshots for a page, drawn from the top of its content box down. Shared by the
-- welcome page and the addon pages, which differ only in how much room is left under it.
local function renderPreviews(content, images, footer)
    if not images or #images == 0 then
        return
    end

    local availableW = content:GetWidth()
    local availableH = content:GetHeight()

    if not availableW or availableW < 100 then
        availableW = 500
    end

    if not availableH or availableH < 100 then
        availableH = 228
    end

    local gallery = Kit.Gallery(content, images, availableW, availableH - footer - pad)

    if gallery then
        PixelUtil.SetPoint(gallery, "TOP", content, "TOP", 0, -pad)
    end
end

local function importButton(content, def)
    local button = Kit.Button(content, "Import " .. def.title, buttonWidth, buttonHeight, function()
        Installer:Install(def.key)
    end)
    PixelUtil.SetPoint(button, "BOTTOM", content, "BOTTOM", 0, buttonY)
    Kit.Accent(button)

    if not Installer:HasPayload(def.key) then
        -- Nothing to import yet, so the button says why instead of failing on click.
        button:SetLabel("No profile bundled yet")
    end

    return button
end

-- The addons of a flow that have a fallback profile to write, which is what the
-- welcome page's one box stands in for.
local function defaultKeys(steps)
    local keys = {}

    for _, step in ipairs(steps or {}) do
        if step.statusKey and Installer:SupportsDefault(step.statusKey) then
            keys[#keys + 1] = step.statusKey
        end
    end

    return keys
end

local function allWantDefault(keys)
    for _, key in ipairs(keys) do
        if not Installer:WantsDefault(key) then
            return false
        end
    end

    return #keys > 0
end

-- The profile the tick would overwrite, named. Almost every addon says "Default", so a
-- run whose addons agree can name it; NSRT's lower-case one -- or Hiding Bar, whose
-- fallback is our own profile flagged rather than a name -- in the mix makes the
-- welcome page's single box speak generally instead of naming one of them.
local function defaultProfileLabel(keys)
    local name

    for _, key in ipairs(keys) do
        local this = Installer:GetDefaultProfileName(key)

        if name and this ~= name then
            return nil
        end

        name = this
    end

    return name
end

-- Why anyone would tick it, and what it costs -- neither of which fits on the row
-- itself. The name of the profile being overwritten is the part worth being exact
-- about, so it is named whenever it can be.
--
-- Hiding Bar's fallback is a flag on a profile rather than a name of its own, so its
-- target IS our profile: the row there marks what the import wrote instead of sending
-- it somewhere else, and the second line says so.
local function defaultTooltip(row, name)
    local ours = name == Installer.profileName
    local target = name and ("|cffe8853d" .. name .. "|r") or "each addon's default profile"

    row:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Import into the default profile")
        GameTooltip:AddLine("Left unticked, the import lands as a profile named |cffe8853d"
            .. Installer.profileName .. "|r and switches this character to it, which leaves every "
            .. "alt where it was.", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine(" ")

        if ours then
            GameTooltip:AddLine("Ticked, that profile is also marked as the default, the one a "
                .. "character that has never picked anything runs on, so your alts get this setup "
                .. "without visiting each of them.", 0.8, 0.8, 0.8, true)
        else
            GameTooltip:AddLine("Ticked, the settings go into " .. target
                .. " instead, the profile a character that has never picked one runs on, so your "
                .. "alts get this setup without visiting each of them. Nothing else is written: it "
                .. "moves the import rather than making a second copy to keep in step.",
                0.8, 0.8, 0.8, true)
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Whatever it holds now is overwritten.", 1, 0.85, 0.3, true)
        GameTooltip:Show()
    end)

    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

-- Only on the pages whose addon actually has a fallback profile to write; the rest
-- leave the band empty rather than offering a box that would do nothing.
local function defaultCheckbox(content, def)
    if not Installer:SupportsDefault(def.key) then
        return nil
    end

    local row = Kit.Checkbox(content, "Import into the default profile", nil, defaultHeight,
        function(_, checked)
            Installer:SetWantsDefault(def.key, checked)
        end)
    PixelUtil.SetPoint(row, "BOTTOM", content, "BOTTOM", 0, defaultY)
    row:SetChecked(Installer:WantsDefault(def.key))

    defaultTooltip(row, Installer:GetDefaultProfileName(def.key))

    return row
end

-- An addon this setup builds on that is not installed, or is switched off. It is in the
-- flow only to hold a rail entry: there is nothing to import, so it carries no build and
-- no statusKey, and `disabled` tells the wizard to grey the row, flag it, and step over
-- it on the way past (see findStep in wizard.lua).
local function missingStep(def)
    return {
        title = def.title,
        shortTitle = def.shortTitle,
        disabled = true,
    }
end

-- One addon page: one button, and whatever the addon wants to put above it.
local function addonStep(def)
    return {
        title = def.title,
        -- Optional, for an addon whose name is too long for the rail (see the NSRT
        -- def). The page keeps the full name -- there is room for it there, and the
        -- page is where you want to be sure which addon you are importing.
        shortTitle = def.shortTitle,
        desc = def.description,
        statusKey = def.key,
        build = function(content)
            importButton(content, def)

            -- Read at click time by the import itself (see Installer:GetTargetProfileName), so
            -- the box only has to record what it says.
            defaultCheckbox(content, def)

            -- A page whose addon has something to choose draws it inline, in the
            -- space above the button (EllesmereUI's module list). It gets the whole
            -- content area and is expected to leave the bottom band alone -- which is
            -- also why it takes that space INSTEAD of screenshots rather than as well:
            -- there is only one band and a choice earns it over a picture.
            if def.render then
                def.render(def, content)
            else
                renderPreviews(content, Installer.previews[def.key], footerHeight)
            end

            -- Anything the addon needs the user to know that is not the profile
            -- itself -- a keybind that has to be set by hand, a setting the import
            -- cannot reach.
            if def.note then
                local note = content:CreateFontString(nil, "OVERLAY")
                Kit.SetFont(note, 11)
                PixelUtil.SetPoint(note, "BOTTOM", content, "BOTTOM", 0, noteY)
                PixelUtil.SetPoint(note, "LEFT", content, "LEFT", 0, 0)
                PixelUtil.SetPoint(note, "RIGHT", content, "RIGHT", 0, 0)
                note:SetJustifyH("CENTER")
                note:SetSpacing(2)
                note:SetTextColor(Kit.palette.textDim[1], Kit.palette.textDim[2], Kit.palette.textDim[3])
                note:SetText(def.note)
            end
        end,
    }
end

local function welcomeStep(isUpdate)
    return {
        title = isUpdate and "Update" or "Welcome",
        desc = isUpdate
            and "These profiles have a newer version bundled than the one you imported.\n\nOnly the out-of-date addons are listed. Importing overwrites that addon's "
                .. addonName .. " profile."
            or "This installer imports the " .. addonName .. " profile into each addon this setup is built on.\n\nTake the pages one at a time, or do the lot from here. You can re-run any page later with |cffe8853d/iui install|r.",
        build = function(content, wizard)
            -- Acts on the pages of THIS run rather than on every addon known: the
            -- install flow lists everything present, the update flow only what is out
            -- of date, so the button means "all of the above" on both.
            local button = Kit.Button(content, isUpdate and "Update everything" or "Install everything",
                buttonWidth, buttonHeight, function()
                    Installer:InstallAll(wizard:GetSteps())
                end)
            PixelUtil.SetPoint(button, "BOTTOM", content, "BOTTOM", 0, buttonY)
            Kit.Accent(button)

            -- The same choice as the per-addon boxes, made once for the whole run: it
            -- writes the per-addon flags the imports read, so a page visited afterwards
            -- shows its box already ticked. Ticked only when every addon in the run that
            -- can do it is -- a half-ticked state would read as "yes" from here.
            local keys = defaultKeys(wizard:GetSteps())

            if #keys > 0 then
                local row = Kit.Checkbox(content, "Import into the default profiles", nil, defaultHeight,
                    function(_, checked)
                        for _, key in ipairs(keys) do
                            Installer:SetWantsDefault(key, checked)
                        end
                    end)
                PixelUtil.SetPoint(row, "BOTTOM", content, "BOTTOM", 0, defaultY)
                row:SetChecked(allWantDefault(keys))

                defaultTooltip(row, defaultProfileLabel(keys))
            end

            -- In the slot the other pages give their status line, so the band under the
            -- gallery is the same height here and the pictures come out the same size.
            local note = content:CreateFontString(nil, "OVERLAY")
            Kit.SetFont(note, 11)
            PixelUtil.SetPoint(note, "BOTTOM", content, "BOTTOM", 0, statusY)
            PixelUtil.SetPoint(note, "LEFT", content, "LEFT", 0, 0)
            PixelUtil.SetPoint(note, "RIGHT", content, "RIGHT", 0, 0)
            note:SetJustifyH("CENTER")
            note:SetSpacing(2)
            note:SetTextColor(Kit.palette.textDim[1], Kit.palette.textDim[2], Kit.palette.textDim[3])
            note:SetText("EllesmereUI imports every module this way. Visit its page first to leave any out.")

            -- What the setup looks like, in the space left above the note.
            renderPreviews(content, Installer.previews.welcome, footerHeight)
        end,
    }
end

------------------------------------------------------------------------
-- Flows
------------------------------------------------------------------------
--
-- There is no completion page. Nothing has to be imported in order, or at all, so
-- a page announcing that the run is finished would be claiming something the
-- installer does not know -- and its only real job, the reload, is the Reload
-- button on the last page either way (see the wizard's finish handler).

-- Every loaded addon gets a page; where you stop is your business. The ones that are
-- not loaded are listed too, as dead rail entries, so the run says what it could not
-- do rather than quietly leaving them out (see missingStep).
function Installer:OpenInstall()
    local function build()
        self.needsReload = false

        local list = { welcomeStep(false) }

        for def in self:IterateAddons() do
            if self:IsPresent(def.key) then
                list[#list + 1] = addonStep(def)
            else
                list[#list + 1] = missingStep(def)
            end
        end

        -- After every addon this setup actually imports into, under its own rail
        -- heading: it is a reading page rather than a step of the run.
        list[#list + 1] = self:RecommendedStep()

        self.Wizard:SetHeader("Installer")
        self.Wizard:OpenFlow(list)
    end

    -- Re-running over an existing install overwrites profiles in nine addons; that
    -- is worth one confirmation.
    if next(self.db.installed) ~= nil then
        self:ConfirmOverwrite(build)
    else
        build()
    end
end

function Installer:OpenUpdate()
    self.needsReload = false

    local list = {}

    for def in self:IterateAddons() do
        if self:IsPresent(def.key) and self:IsInstalled(def.key) and self:IsOutOfDate(def.key) then
            list[#list + 1] = addonStep(def)
        end
    end

    if #list == 0 then
        self:Toast(addonName .. ": every imported profile is up to date", 0.5, 1, 0.5)

        return
    end

    table.insert(list, 1, welcomeStep(true))

    self.Wizard:SetHeader("Update")
    self.Wizard:OpenFlow(list)
end

function Installer:Toggle()
    if self.Wizard:IsShown() then
        self.Wizard:Hide()

        return
    end

    self:OpenInstall()
end

-- Is anything at all bundled? A build whose addon files still hold placeholders has
-- nothing to install, so the first-run window would only be in the way.
function Installer:HasAnyPayload()
    for def in self:IterateAddons() do
        if self:HasPayload(def.key) then
            return true
        end
    end

    return false
end

-- Is there anything the update flow would actually offer? Kept in step with
-- OpenUpdate so the login nudge can never point at an empty run.
function Installer:HasUpdates()
    for def in self:IterateAddons() do
        if self:IsPresent(def.key) and self:IsInstalled(def.key) and self:IsOutOfDate(def.key) then
            return true
        end
    end

    return false
end

------------------------------------------------------------------------
-- Login prompts
------------------------------------------------------------------------

-- First run opens the installer once per account. After that, a login only says
-- when a bundled profile has moved on from what was imported -- and only once per
-- session, in chat, so it is a nudge rather than a window in the way.
local login = CreateFrame("Frame")
login:RegisterEvent("PLAYER_ENTERING_WORLD")
login:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()

    C_Timer.After(4, function()
        local db = Installer.db

        if not db.promptShown then
            if not Installer:HasAnyPayload() then
                -- Nothing bundled yet: leave the one-shot unspent so the window
                -- still appears on the first login of a build that has profiles.
                return
            end

            db.promptShown = true
            Installer:OpenInstall()

            return
        end

        if Installer:HasUpdates() then
            Installer:Toast(addonName .. ": profile updates available, /iui update", 1, 0.85, 0.3)
        end
    end)
end)
