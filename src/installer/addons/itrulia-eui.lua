local addonName, ItruliaUI = ...

local Installer = ItruliaUI:GetModule("Installer")
local profileString = "ItruliaEUIv942Qnmmmy4NP9iK4zAm0ApSsjSBuqPvSfW5a2kWE8NTBVO9kD8t)6h)a7rWsl8EGeovQ4vAkW3XweMx23IcTkd)YR9u8hwQdee8CA7iEJBPyLs4)KJ4Jl4VAnQXVCdApcgjEeMPlehssCBPa)IeP9WSuG6CN)(jtUDJx1y1JQUg)jnu6OCxAD5fm2(ATgaTvPlPz9EUtNPea31ZJqg9tO(Szf75LQdF1GtLbM1KqHahF36fi8))"

Installer:RegisterAddon({
    key = "ItruliaEUI",
    title = "|cffe9e9edItrulia|r|cff3fbf9fEUI|r",
    description = "EllesmereUI improvements",
    folder = "ItruliaEUI",
    version = "1",
    needsReload = false,
    profile = profileString,
    supportsDefault = true,

    apply = function(def, payload, profileName)
        local EUI = _G.ItruliaEUI

        if not (EUI and EUI.ImportAsNewProfile) then
            return false, "ItruliaEUI's profile API is not available"
        end

        EUI:ImportAsNewProfile(payload, profileName, true, function(ok, err)
            if not ok then
                Installer:Toast("ItruliaEUI import failed: " .. tostring(err), 1, 0.4, 0.4)

                return
            end

            Installer:MarkInstalled(def.key)
            Installer:PlayInstallSound()
            Installer:Toast("Imported ItruliaEUI", 1, 1, 1)
        end)

        return "pending"
    end,
})
