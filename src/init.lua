local addonName, namespace = ...

ItruliaUI = LibStub("AceAddon-3.0"):NewAddon(namespace, addonName, "AceConsole-3.0")
ItruliaUI.LSM = LibStub("LibSharedMedia-3.0")
ItruliaUI.testMode = false
ItruliaUI.EUI = _G.EllesmereUI
ItruliaUI.QoL = _G.ItruliaQoL

local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

function ItruliaUI:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ItruliaUIDB", {}, true)

    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshModules")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshModules")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshModules")
end

function ItruliaUI:OnEnable()
    self:RegisterEUI()
end

function ItruliaUI:RefreshModules()
    for _, module in self:IterateModules() do
        if module.RefreshConfig then
            module:RefreshConfig()
        end
    end
end

function ItruliaUI:ApplyModuleStyles(moduleName)
    local module = self:GetModule(moduleName, true)

    if module and module.db and module.db.enabled == false then
        return
    end

    local frame = _G[addonName .. moduleName]

    if frame and frame.UpdateStyles then
        frame:UpdateStyles()
    end
end

function ItruliaUI:ExportCurrentProfile()
    local profileName = self.db:GetCurrentProfile()
    local profileData = self.db.profiles[profileName]

    local serialized = AceSerializer:Serialize(profileData)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForPrint(compressed)

    return addonName .. encoded
end

function ItruliaUI:DecodeImportString(str)
    if type(str) ~= "string" or not str:find("^" .. addonName) then
        return false, "Missing or invalid prefix"
    end

    local payload = str:sub(#addonName + 1)

    local decoded = LibDeflate:DecodeForPrint(payload)
    if not decoded then
        return false, "Invalid encoded data"
    end

    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then
        return false, "Decompression failed"
    end

    local success, data = AceSerializer:Deserialize(decompressed)
    if not success or type(data) ~= "table" then
        return false, "Invalid serialized profile"
    end

    return true, data
end

-- Both importers take an optional callback as their last argument, reported as
-- callback(success, err) once the import has finished -- after RefreshModules, so
-- the modules already run on the new profile by the time it fires. Every exit path
-- goes through here, failures included, so a caller can drive off the callback
-- alone; the return values are unchanged for callers that do not pass one.
--
-- The installer is what this exists for: it treats an import as an operation that
-- reports back when it lands, the way BigWigs' RegisterProfile does, rather than as
-- a call whose return value it has to interpret.
local function finish(callback, ok, err)
    if callback then
        callback(ok, err)
    end

    return ok, err
end

function ItruliaUI:ImportAsNewProfile(str, profileName, override, callback)
    if not profileName or profileName == "" then
        return finish(callback, false, "Invalid profile name")
    end

    if self.db.profiles[profileName] and not override then
        return finish(callback, false, "Profile already exists")
    end

    local ok, data = self:DecodeImportString(str)
    if not ok then
        return finish(callback, false, data)
    end

    self.db:SetProfile(profileName)

    local profile = self.db.profile
    for k in pairs(profile) do
        profile[k] = nil
    end

    for k, v in pairs(data) do
        profile[k] = v
    end

    self:RefreshModules()

    return finish(callback, true)
end

function ItruliaUI:ImportIntoCurrentProfile(str, callback)
    local ok, dataOrErr = self:DecodeImportString(str)
    if not ok then
        return finish(callback, false, dataOrErr)
    end

    local profile = self.db.profile

    for k in pairs(profile) do
        profile[k] = nil
    end

    for k, v in pairs(dataOrErr) do
        profile[k] = v
    end

    self:RefreshModules()

    return finish(callback, true)
end

function ItruliaUI:ToggleTestMode(enabled)
    self.testMode = enabled

    for _, module in self:IterateModules() do
        if module.ToggleTestMode then
            module:ToggleTestMode(enabled)
        end
    end
end

ItruliaUI:RegisterChatCommand("iui", "SlashProcessor")

function ItruliaUI:SlashProcessor(input)
    local arg = input and input:lower():match("^%s*(%S*)") or ""

    -- Bare `/iui` opens the installer, this addon being the installer. The settings
    -- page keeps `config`, the way it does in ItruliaQoL and ItruliaEUI -- but those
    -- two are settings first, so their bare command is the panel.
    if arg == "" or arg == "install" or arg == "i" then
        self:GetModule("Installer"):Toggle()
    elseif arg == "config" or arg == "c" then
        if self.EUI and self.EUI.ShowModule then
            self.EUI:ShowModule(addonName .. "_Installer")
        else
            self:Print("|cffff8000EllesmereUI is not available|r. These settings have no other panel.")
        end
    elseif arg == "test" or arg == "t" then
        self:ToggleTestMode(not self.testMode)
    elseif arg == "update" or arg == "u" then
        self:GetModule("Installer"):OpenUpdate()
    else
        self:Print("AddOn commands:")
        self:Print("/iui - open the installer")
        self:Print("/iui update")
        self:Print("/iui config")
        self:Print("/iui test")
    end
end
