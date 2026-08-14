local addonName, ItruliaUI = ...

local Installer = ItruliaUI:GetModule("Installer")
local profileString = "BW2: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"

Installer:RegisterAddon({
    key = "BigWigs",
    title = "BigWigs",
    description = "BigWigs is a modular and extremely lightweight addon designed to provide you with the tools you need to beat any boss encounter.",
    folder = "BigWigs",
    version = "1",
    needsReload = false,
    profile = profileString,
    supportsDefault = true,
    apply = function(def, payload, profileName)
        local API = _G.BigWigsAPI

        if not (API and API.RegisterProfile) then
            return false, "BigWigs' profile API is not available"
        end

        API.RegisterProfile(addonName, payload, profileName, function(accepted)
            if not accepted then
                Installer:Toast("BigWigs import declined", 1, 0.85, 0.3)

                return
            end

            Installer:MarkInstalled(def.key)
            Installer:PlayInstallSound()
            Installer:Toast("Imported BigWigs", 1, 1, 1)
        end)

        return "pending"
    end,
})
