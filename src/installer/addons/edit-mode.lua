local addonName, ItruliaUI = ...

local Installer = ItruliaUI:GetModule("Installer")

local profileString = "2 50 0 0 0 4 4 UIParent 0.0 -682.0 -1 ##$$%/&&'')$+$,$ 0 1 0 6 0 MainActionBar 0.0 3.0 -1 ##$$%/&&''(#,$ 0 2 0 8 8 UIParent -505.3 74.5 -1 ##$$%/&&''(#,$ 0 3 0 0 0 UIParent 1587.5 -1290.5 -1 ##$$%/&&''(#,$ 0 4 0 0 0 UIParent 1587.5 -1251.5 -1 ##$$%/&&''(#,$ 0 5 0 0 0 UIParent 1587.5 -1212.5 -1 ##$$%/&&''(#,$ 0 6 0 3 3 UIParent 2.0 -372.5 -1 ##$$%/&&''(#,$ 0 7 0 0 0 UIParent 2.0 -1035.5 -1 ##$$%/&&''(#,$ 0 10 1 7 7 UIParent 0.0 45.0 -1 ##$$&('% 0 11 0 0 0 UIParent 1119.6 -1312.0 -1 ##$$&('',# 0 12 1 7 7 UIParent 0.0 45.0 -1 ##$$&('% 1 -1 1 4 4 UIParent 0.0 0.0 -1 ##$#%# 2 -1 1 2 2 UIParent 0.0 0.0 -1 ##$#%( 3 0 1 8 7 UIParent -300.0 250.0 -1 $#3# 3 1 1 6 7 UIParent 300.0 250.0 -1 %#3# 3 2 1 6 7 UIParent 520.0 265.0 -1 %#&#3# 3 3 0 0 0 UIParent 524.0 -1081.5 -1 '$(#)#-k.#/#1$3#5#627U8( 3 4 0 0 0 UIParent 0.0 -1081.7 -1 ,#-;.3/#0%1$2(5#6-6$7-7$8( 3 5 0 2 2 UIParent -419.0 -413.0 -1 &#*$3# 3 6 1 5 5 UIParent 0.0 0.0 -1 -#.#/#4$5#6-6$7-7$8( 3 7 1 4 4 UIParent 0.0 0.0 -1 3# 4 -1 1 7 7 UIParent 0.0 45.0 -1 # 5 -1 1 7 7 UIParent 0.0 45.0 -1 # 6 0 0 0 0 UIParent 1256.5 -5.6 -1 ##$#%#&/())( 6 1 0 2 8 BuffFrame -15.0 -4.0 -1 ##$#%#'+(()--$ 6 2 0 7 7 UIParent -160.0 422.8 -1 ##$$%$&-(/)(+#,-,$ 7 -1 0 0 0 UIParent 534.0 -1080.4 -1 # 8 -1 0 6 6 UIParent 14.2 8.2 -1 #'$i%%&- 9 -1 0 7 7 UIParent -430.0 204.0 -1 # 10 -1 1 0 0 UIParent 16.0 -116.0 -1 # 11 -1 0 0 0 UIParent 2085.1 -1287.0 -1 # 12 -1 0 4 4 UIParent -832.0 380.0 -1 ##$#%# 13 -1 0 8 8 UIParent -94.5 3.0 -1 ##$#%)&) 14 -1 0 8 8 UIParent -223.0 0.0 -1 ##$#%( 15 0 1 7 7 StatusTrackingBarManager 0.0 0.0 -1 &- 15 1 1 7 7 StatusTrackingBarManager 0.0 17.0 -1 &- 16 -1 1 5 5 UIParent 0.0 0.0 -1 #( 17 -1 1 1 1 UIParent 0.0 -100.0 -1 ## 18 -1 0 7 7 UIParent -409.0 124.0 -1 #% 19 -1 1 7 7 UIParent 0.0 0.0 -1 ## 20 0 0 4 4 UIParent 0.0 -200.0 -1 ##$,%$&('((-($)#+$,$-$ 20 1 0 4 4 UIParent -0.0 -230.0 -1 ##$+%$&('((-($)#+$,$-$ 20 2 0 4 4 UIParent 0.0 -141.0 -1 ##$$%$&(')(-($)#+$,$-# 20 3 0 0 0 UIParent 1087.3 -859.5 -1 #+$,$-%+&('((-($)#*#+$,$-..-.$ 21 -1 1 7 7 UIParent -410.0 380.0 -1 ##%#&#'((()#*-*$+#,&-#.#/(0#1# 22 0 0 4 4 UIParent 429.9 130.5 -1 #.#/$-%,&''((()U*$+%,$-#.#/U0% 22 1 0 4 4 UIParent 0.0 296.0 -1 &''()U*#+% 22 2 0 0 0 UIParent 973.5 -351.6 -1 &''())*#+% 22 3 0 0 0 UIParent 1027.0 -311.6 -1 &''()U*#+% 23 -1 0 5 5 UIParent -2.0 -356.5 -1 ##$#%%&L'1'$(#)U+$,$-/.)/#"

local function import(_, payload, profileName)
    if InCombatLockdown() then
        return false, "Edit Mode cannot be changed in combat"
    end

    local mgr = EditModeManagerFrame

    if not (C_EditMode and C_EditMode.ConvertStringToLayoutInfo and C_EditMode.GetLayouts
        and C_EditMode.SaveLayouts and C_EditMode.SetActiveLayout) then
        return false, "this client has no Edit Mode API"
    end

    if not (mgr and mgr.accountSettings)
        or not (EditModePresetLayoutManager and EditModePresetLayoutManager.GetCopyOfPresetLayouts) then
        return false, "Edit Mode is not ready. Open it once (Esc -> Edit Mode), then try again"
    end

    local imported = C_EditMode.ConvertStringToLayoutInfo(payload)

    if not imported then
        return false, "that string is not an Edit Mode layout"
    end

    imported.layoutType = Enum.EditModeLayoutType.Account
    imported.layoutName = profileName

    if mgr.ReconcileWithModern then
        mgr:ReconcileWithModern(imported)
    end

    local info = C_EditMode.GetLayouts()

    if not (info and info.layouts) then
        return false, "Edit Mode returned no layouts"
    end

    if mgr.ReconcileWithModern then
        for _, layout in ipairs(info.layouts) do
            mgr:ReconcileWithModern(layout)
        end
    end

    -- The combined list the indices above refer to.
    local layouts = EditModePresetLayoutManager:GetCopyOfPresetLayouts()
    local presetCount = #layouts

    for _, layout in ipairs(info.layouts) do
        layouts[#layouts + 1] = layout
    end

    -- Re-importing refreshes rather than duplicates. This also clears out a
    -- Character-type layout of the same name left by an older run.
    for i = #layouts, presetCount + 1, -1 do
        if layouts[i].layoutName == profileName then
            table.remove(layouts, i)
        end
    end

    -- Slotted before the first Character layout, so it groups with the other
    -- account-wide ones the way Edit Mode's own list expects.
    local slot = #layouts + 1
    for i = presetCount + 1, #layouts do
        if layouts[i].layoutType == Enum.EditModeLayoutType.Character then
            slot = i
            break
        end
    end

    table.insert(layouts, slot, imported)

    info.layouts = layouts
    info.activeLayout = slot

    C_EditMode.SaveLayouts(info)
    C_EditMode.SetActiveLayout(slot)

    return true
end

Installer:RegisterAddon({
    key = "EditMode",
    title = "Edit Mode",
    description = "Where Blizzard's own HUD sits: action bars, the buff frame, the cast bar and the rest.\n\nImported as an account-wide Edit Mode layout named " .. Installer.profileName .. " and made active.",
    folder = nil,
    version = "1",
    -- An Edit Mode import taints Edit Mode until a reloadt.
    needsReload = true,
    profile = profileString,
    apply = import,
})
