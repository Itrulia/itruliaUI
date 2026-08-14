local addonName, ItruliaUI = ...
local moduleName = "Installer"

local Installer = ItruliaUI:NewModule(moduleName)
Installer.euiDisplay = "Installer"
Installer.euiDescription = "Imports this setup's profiles into the addons it is built on."
Installer.EUINoEnableSwitch = true

Installer.profileName = addonName

Installer.addons = {}
Installer.order = {}

function Installer:RegisterAddon(def)
    if type(def) ~= "table" or type(def.key) ~= "string" then
        return
    end

    if self.addons[def.key] then
        -- A reload of the same file replaces the definition rather than adding a
        -- second page for the same addon.
        self.addons[def.key] = def

        return
    end

    self.addons[def.key] = def
    self.order[#self.order + 1] = def.key
end

function Installer:GetAddon(key)
    return self.addons[key]
end

-- Every registered addon, in page order.
function Installer:IterateAddons()
    local i = 0

    return function()
        i = i + 1

        local key = self.order[i]

        return key and self.addons[key] or nil
    end
end

function Installer:GetInstalledVersion(key)
    return self.db.installed[key]
end

function Installer:IsInstalled(key)
    return self:GetInstalledVersion(key) ~= nil
end

function Installer:MarkInstalled(key)
    local def = self:GetAddon(key)

    self.db.installed[key] = (def and def.version) or true

    -- Armed here rather than at the end of Install, so the asynchronous importers --
    -- the ones that stamp from their own callback -- arm it too.
    if def and def.needsReload then
        self.needsReload = true
    end

    -- Every import that lands passes through here, the asynchronous ones included, so
    -- this is the one place the default flag can hang off and cover all of them.
    self:MarkDefault(key)

    self:RefreshStatus(key)
end

-- Drops one addon's stamp. Nothing is undone in the addon itself -- its profile is still
-- there and still active -- this only forgets that we put it there, so the page offers
-- the import again and an update run stops counting it as ours.
function Installer:ForgetInstalled(key)
    self.db.installed[key] = nil
    self:RefreshStatus(key)
end

-- Out of date = never imported, or imported at a version older than the one this
-- addon now ships. Version numbers are plain strings compared for inequality:
-- they are our own stamps, not a scheme anyone else writes into, so there is
-- nothing to order.
function Installer:IsOutOfDate(key)
    local def = self:GetAddon(key)

    if not def then
        return false
    end

    local saved = self:GetInstalledVersion(key)

    if saved == nil then
        return true
    end

    return saved ~= (def.version or true)
end

------------------------------------------------------------------------
-- Addon presence and payloads
------------------------------------------------------------------------

local function isLoaded(folder)
    local loaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded

    return loaded and loaded(folder) and true or false
end

-- An addon whose folder is not loaded gets no page: there is nothing to import into,
-- and offering the button would only produce an error on click. It still gets a rail
-- entry, greyed and flagged "Not Installed" (see missingStep in steps.lua).
function Installer:IsPresent(key)
    local def = self:GetAddon(key)

    if not def then
        return false
    end

    local folder = def.folder

    if folder == nil then
        return true
    end

    if type(folder) == "string" then
        return isLoaded(folder)
    end

    for _, name in ipairs(folder) do
        if isLoaded(name) then
            return true
        end
    end

    return false
end

function Installer:GetPayload(key)
    local def = self:GetAddon(key)

    if not def then
        return nil
    end

    local payload = def.profile

    if type(payload) == "function" then
        payload = payload(def)
    end

    return payload
end

-- Has this addon's file actually been filled in? An empty string, the placeholder
-- and an empty table all count as "not yet".
function Installer:HasPayload(key)
    local payload = self:GetPayload(key)

    if type(payload) == "string" then
        return payload ~= "" and payload ~= self.PLACEHOLDER
    end

    if type(payload) == "table" then
        return next(payload) ~= nil
    end

    return payload ~= nil
end

------------------------------------------------------------------------
-- The default profile
------------------------------------------------------------------------
--
-- An import lands as a profile named after this addon and switches the character
-- to it, which leaves every alt where it was. Ticking "as default" imports into the
-- addon's FALLBACK profile INSTEAD -- the one a character that has never picked
-- anything runs on -- so the setup carries to the rest of the account without
-- visiting each alt, and without leaving a second profile behind that holds the same
-- settings and would have to be kept in step by hand.
--
-- Almost everything here calls that profile "Default"; NSRT spells it lower case,
-- and Hiding Bar has no fallback NAME at all (it flags one of its own profiles
-- instead), which is what defaultProfile on a def is for.
Installer.defaultProfileName = "Default"

function Installer:GetDefaultProfileName(key)
    local def = self:GetAddon(key)

    return (def and def.defaultProfile) or self.defaultProfileName
end

-- Only a def that says so. An addon with no fallback profile to speak of (Edit Mode
-- imports account-wide already, EXBoss has one bucket) gets no checkbox rather than
-- one that quietly does nothing.
function Installer:SupportsDefault(key)
    local def = self:GetAddon(key)

    return type(def) == "table" and def.supportsDefault == true
end

function Installer:WantsDefault(key)
    if not self:SupportsDefault(key) then
        return false
    end

    return self.db.asDefault[key] and true or false
end

-- Remembered per addon, so an update run repeats the choice made on the install run
-- without asking again -- the same contract EllesmereUI's module picks have.
function Installer:SetWantsDefault(key, on)
    self.db.asDefault[key] = on and true or nil
end

-- Where the import lands. The tick does not add a second write -- it moves the one
-- write, so a ticked run leaves the addon holding exactly one profile of ours.
function Installer:GetTargetProfileName(key)
    if self:WantsDefault(key) then
        return self:GetDefaultProfileName(key)
    end

    return self.profileName
end

-- Writing the fallback profile is the import itself (see GetTargetProfileName), so
-- most addons need nothing here. This is for the ones where the name alone does not
-- make a profile the fallback: NSRT points MainProfile at it, Hiding Bar carries the
-- fallback as a flag on a profile rather than as a name.
--
-- Runs off a ticked box only, and AFTER the import has landed -- the profile it
-- points at has to exist first.
function Installer:MarkDefault(key)
    if not self:WantsDefault(key) then
        return false
    end

    local def = self:GetAddon(key)

    if type(def.markDefault) ~= "function" then
        return true
    end

    local ok, result, err = pcall(def.markDefault, def, self:GetTargetProfileName(key))

    if not ok or not result then
        self:Toast(def.title .. ": could not mark the default profile: "
            .. tostring((not ok and result) or err or "unknown error"), 1, 0.85, 0.3)

        return false
    end

    return true
end

------------------------------------------------------------------------
-- Importing
------------------------------------------------------------------------

-- The single import path. Everything that is true for every addon -- presence,
-- payload, error reporting, the version stamp, the chime, the status refresh --
-- happens here, so an addon file only has to describe its own API call.
--
-- A def's apply is called as apply(def, payload, profileName) and is expected to write
-- the payload as profileName and leave the character on it. The name is the ONLY thing
-- the "default profile" tick changes, so an apply that honours it needs nothing else.
--
-- An apply that returns "pending" has put a confirmation dialog on screen (BigWigs
-- does this) and stamps the version itself from its callback.
function Installer:Install(key)
    local def = self:GetAddon(key)

    if not def then
        return false, "unknown addon"
    end

    if not self:IsPresent(key) then
        self:Toast(def.title .. " is not loaded", 1, 0.4, 0.4)

        return false, "addon not loaded"
    end

    if not self:HasPayload(key) then
        self:Toast("No " .. def.title .. " profile is bundled yet", 1, 0.85, 0.3)

        return false, "no profile bundled"
    end

    if type(def.apply) ~= "function" then
        return false, "no importer"
    end

    -- The profile the settings are written as: ours by name, or the addon's fallback
    -- profile when the page's box is ticked.
    local ok, result, err = pcall(def.apply, def, self:GetPayload(key), self:GetTargetProfileName(key))

    if not ok then
        self:Toast(def.title .. " import failed: " .. tostring(result), 1, 0.4, 0.4)

        return false, result
    end

    if result == "pending" then
        -- Confirmation is up; the def stamps from its own callback.
        return true
    end

    if not result then
        self:Toast(def.title .. " import failed: " .. tostring(err or "unknown error"), 1, 0.4, 0.4)

        return false, err
    end

    self:MarkInstalled(key)

    -- Quiet during a batch: seven chimes and seven toasts for one button press is
    -- noise, and InstallAll reports once at the end. Failures still speak up.
    if not self.batch then
        self:PlayInstallSound()
        self:Toast("Imported " .. def.title, 1, 1, 1)
    end

    return true
end

-- Run every page of a flow in one press, in page order. Takes the flow's step list
-- rather than the whole registry, so "everything" means what this run offers: all the
-- addons on an install, only the stale ones on an update.
--
-- Pages with nothing bundled yet are counted apart from failures -- that is a build
-- that has not been filled in, not something that went wrong. An addon whose import
-- ends in its own dialog (BigWigs) is left mid-flight on purpose: it is counted as
-- started, and its own callback stamps and reports when the user answers.
function Installer:InstallAll(steps)
    local imported, failed, missing, pending = 0, 0, 0, 0

    self.batch = true

    for _, step in ipairs(steps or {}) do
        local key = step.statusKey

        if key and self:GetAddon(key) then
            if not self:IsPresent(key) then
                -- Not loaded: its entry in the flow carries no statusKey and the rail
                -- already says "Not Installed", so there is nothing to add here.
            elseif not self:HasPayload(key) then
                missing = missing + 1
            elseif self:Install(key) then
                -- A stamp already in place means the import finished inside the call
                -- (most of them, plus the ones whose callback fires synchronously).
                if self:IsInstalled(key) then
                    imported = imported + 1
                else
                    pending = pending + 1
                end
            else
                failed = failed + 1
            end
        end
    end

    self.batch = nil

    local parts = { imported .. " imported" }

    if pending > 0 then
        parts[#parts + 1] = pending .. " waiting on a prompt"
    end

    if failed > 0 then
        parts[#parts + 1] = failed .. " failed"
    end

    if missing > 0 then
        parts[#parts + 1] = missing .. " not bundled"
    end

    if imported > 0 then
        self:PlayInstallSound()
    end

    self:Toast(addonName .. ": " .. table.concat(parts, ", "),
        (failed > 0) and 1 or 0.5, (failed > 0) and 0.85 or 1, (failed > 0) and 0.3 or 0.5)

    -- The page the user is on is the welcome page, so nothing on screen changed --
    -- but a re-render picks up the reload state the Close button now depends on.
    if self.Wizard and self.Wizard.Refresh then
        self.Wizard:Refresh()
    end
end

------------------------------------------------------------------------
-- Status line (drawn by the wizard, reused by the options page)
------------------------------------------------------------------------
function Installer:GetStatusText(key)
    local def = self:GetAddon(key)

    if not def then
        return ""
    end

    if not self:IsPresent(key) then
        return "|cff808080" .. def.title .. " is not loaded|r"
    end

    if not self:HasPayload(key) then
        return "|cffffd100No profile bundled yet|r"
    end

    local saved = self:GetInstalledVersion(key)

    if saved == nil then
        return "|cffff6666Not imported|r"
    end

    if self:IsOutOfDate(key) then
        return "|cffffd100Imported v" .. tostring(saved) .. ", update available (v" .. tostring(def.version) .. ")|r"
    end

    return "|cff4dff4dImported (v" .. tostring(saved) .. ")|r"
end

function Installer:RefreshStatus(key)
    local Wizard = self.Wizard

    if Wizard and Wizard.RefreshStatus then
        Wizard:RefreshStatus(key)
    end
end

------------------------------------------------------------------------
-- Feedback
------------------------------------------------------------------------

-- Own toast rather than UIErrorsFrame: the big mid-screen error text lands right
-- on top of the wizard.
local toast

local function ensureToast()
    if toast then
        return toast
    end

    toast = CreateFrame("Frame", nil, UIParent)
    PixelUtil.SetPoint(toast, "TOP", UIParent, "TOP", 0, -80)
    PixelUtil.SetSize(toast, 600, 60)
    toast:SetFrameStrata("FULLSCREEN_DIALOG")
    toast.lines = {}

    for i = 1, 2 do
        local fs = toast:CreateFontString(nil, "OVERLAY")
        Installer.Kit.SetFont(fs, 16, "OUTLINE")
        PixelUtil.SetPoint(fs, "TOP", fs:GetParent() or UIParent, "TOP", 0, -(i - 1) * 22)
        fs:Hide()
        toast.lines[i] = fs
    end

    return toast
end

function Installer:Toast(message, r, g, b)
    local frame = ensureToast()
    local first, second = frame.lines[1], frame.lines[2]

    -- Newest on top; the previous line drops down so a fast sequence of imports
    -- does not swallow its own messages.
    if first:IsShown() then
        second:SetText(first:GetText())
        second:SetTextColor(first:GetTextColor())
        second:Show()
    end

    first:SetText(message)
    first:SetTextColor(r or 1, g or 1, b or 1)
    first:SetAlpha(1)
    first:Show()

    if frame.hideTimer then
        frame.hideTimer:Cancel()
    end

    frame.hideTimer = C_Timer.NewTimer(3, function()
        UIFrameFadeOut(frame, 0.5, 1, 0)

        C_Timer.After(0.6, function()
            first:Hide()
            second:Hide()
            frame:SetAlpha(1)
        end)
    end)
end

function Installer:PlayInstallSound()
    if PlaySound and SOUNDKIT and SOUNDKIT.UI_GARRISON_MISSION_COMPLETE then
        -- Master, not the default channel: the default can be ducked or muted, and
        -- a confirmation nobody hears is not one.
        PlaySound(SOUNDKIT.UI_GARRISON_MISSION_COMPLETE, "Master")
    end
end

------------------------------------------------------------------------
-- Confirmations
------------------------------------------------------------------------
StaticPopupDialogs["ITRULIAUI_INSTALL_OVERWRITE"] = {
    text = "You have already installed these profiles.\n\nRunning the installer again re-imports them and overwrites the |cffe8853d"
        .. addonName .. "|r profile in every addon it touches.\n\nContinue?",
    button1 = YES or "Yes",
    button2 = NO or "No",
    OnAccept = function(self)
        if self.data then
            self.data()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function Installer:ConfirmOverwrite(onAccept)
    local dialog = StaticPopup_Show("ITRULIAUI_INSTALL_OVERWRITE")

    if dialog then
        dialog.data = onAccept
    else
        onAccept()
    end
end

function Installer:LoadDB()
    local global = ItruliaUI.db.global
    global.installed = global.installed or {}
    global.asDefault = global.asDefault or {}

    return global
end

function Installer:OnInitialize()
    self.db = self:LoadDB()
end

function Installer:RefreshConfig()
    self.db = self:LoadDB()
end

function Installer:OnEnable()
    self.db = self:LoadDB()
end
