local addonName, ItruliaUI = ...

local moduleName = "Installer"
local Installer = ItruliaUI:GetModule(moduleName)

function Installer:GetEUIOptions()
    local rows = {
        { header = "INSTALLER" },
        { type = "execute", label = "Open the installer", func = function()
            local EUI = ItruliaUI.EUI

            if EUI and EUI.Hide then
                EUI:Hide()
            end

            Installer:OpenInstall()
        end },
        { type = "execute", label = "Update only what changed", func = function()
            local EUI = ItruliaUI.EUI

            if EUI and EUI.Hide then
                EUI:Hide()
            end

            Installer:OpenUpdate()
        end },
        { spacer = 8 },
        { header = "STATUS" },
    }

    -- One row per addon: what it says on the wizard page, plus a way to take the stamp
    -- back off. The two halves keep the status column in the same place whether or not
    -- the row has a button, which is what the blank half is for.
    --
    -- rebuild rather than refresh: forgetting changes the status text and takes the
    -- button away, and only a rebuild re-reads a row set.
    for def in self:IterateAddons() do
        local key = def.key
        local status = { text = def.title .. "   " .. self:GetStatusText(key) }

        if self:IsInstalled(key) then
            rows[#rows + 1] = {
                pair = {
                    status,
                    { type = "execute", label = "Forget", rebuild = true, func = function()
                        Installer:ForgetInstalled(key)
                    end },
                },
            }
        else
            rows[#rows + 1] = { pair = { status, { type = "empty" } } }
        end
    end

    rows[#rows + 1] = { spacer = 6 }
    rows[#rows + 1] = { text = "Forgetting changes nothing in the addon itself. The profile stays where it is. It only makes the installer offer that page again." }

    return {
        name = "Installer",
        rows = rows,
    }
end
