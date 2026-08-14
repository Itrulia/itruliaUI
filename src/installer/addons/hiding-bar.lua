local addonName, ItruliaUI = ...

local Installer = ItruliaUI:GetModule("Installer")

local profileString = "fVXPb-NEGHUKQkhInCOQdnvihkRZgRASKnHsJK6dxKlTmhPV2P7szGY8Y82MlWS5lB8rdc972r2xXGAPHDjtjfP-B_wH3JZLA6IrJMZpth03yVZRFdlvvu-9971v8qQVMZrg9BcvCyUNQEpMU_GsPqrbhIDIgMOR08UUZyg3CykZ_dGWQmb5e3e_eXg0qns4tExH1dj76GQ4xTIa2xmTIHTUUAcdIhwDd_qVMrd0RHcuxziyCpoCo0PGSKVY0EM8wiebKX3929-BXsos0gBFk-2UXZgLVQA8xqSOOqwSEkR7DZ80K00skAhrJOHdp6P3dcAxwITMXcqmBOIUdLaVPvbIZKIi1tdf94LDYUXJbZ8UWQjcQzRWU_NRClsnVWnkEySB6zyqhLsgxywuJ7Vm_1EFd-fOpFFwJLZ6Y-L0GKeVCtVWAc4KxQYz2uQoqcxgoOMaPDpyrt6ePP2sWmY1g0ByQJkmTc2ikr4eYtPxoO9dAeL__qqmD0nOIiznthBAJUa6_HvPq-nxQKHxTPlZXKPId3_eWAuWqc-HPhISdH2utnC_Wjen239NapwOLgduIq6faG8wu7Np3Q5fr7GzySRv23I3u1XezsZQtNZ3yF4baWt9AbxtC-qmHIWrtC96UaFAWVs98rCQpwc4pYxD15T0dIDiuMVZZiGJTM4mwBe98qwFyer4-UCr1UjUZvRqHsvCstyggAJOrRBx8e1PDhbqFCqIXKxuzWcfOARTOMaxHL_ZE6Cexj4TuMzzxe-fvoPcsbK_o_aTADf6JdZkXA2kyQjjPxiGUXPEmE0tIGhuOGE6hJksONgBIzh2wxvYFqLRmHGb43QsHUWqnyQCpNFXX4fzHF61rlkC34O3RnVMlZoIclnuscT5K4DRzUGaSEoCKkqwWKpY9vn-Yv_tswc1o5OvoC-_vP_ixT9_GMbyB-KqQ-9ai63S2d7b9fEMiH_9-JJbzS31rRzYacEsV193DsK1k-0wvRR68cXZ2QPt336SzJzSxqVJ_35utFOUB0pfzb8pb9EPlxefhTlEJc0nja-MRsfwQo3RG00125-tsuKiG6u4KFNhyNQyGRZh0WThJiiGfo7KDalaXvpsYZETFEGmNsc4iBAtYxJCfL70vH774JJCSbB-y024uo7UraTCp1u2pH_ZzSq7nes9X-4_f1T-PXYZx6rL8nbc8TlSP4gmyCkAVcEWuysTl7XcsvYqPF4wKQhJCJsC_9iiioCtxO3u_Q8="

local function decode(str)
    if not (C_EncodingUtil and C_EncodingUtil.DecodeBase64) then
        return nil, "this client has no C_EncodingUtil"
    end

    local decoded = C_EncodingUtil.DecodeBase64(str, Enum.Base64Variant.StandardUrlSafe)

    if not decoded then
        return nil, "not a Hiding Bar export string"
    end

    local ok, decompressed = pcall(C_EncodingUtil.DecompressString, decoded, Enum.CompressionMethod.Deflate)

    if not ok or not decompressed then
        return nil, "decompression failed"
    end

    local decodedOk, data = pcall(C_EncodingUtil.DeserializeCBOR, decompressed)

    if not decodedOk or type(data) ~= "table" then
        return nil, "the string does not hold a profile"
    end

    return data
end

local function isProfile(data)
    local config = data.config

    return type(config) == "table"
        and type(config.grabMinimap) == "boolean"
        and type(config.ignoreMBtn) == "table"
        and type(config.grabMinimapAfterN) == "number"
        and type(config.customGrabList) == "table"
        and type(config.ombGrabQueue) == "table"
        and type(config.btnSettings) == "table"
        and type(config.mbtnSettings) == "table"
        and type(data.bars) == "table"
end

Installer:RegisterAddon({
    key = "HidingBar",
    title = "Hiding Bar",
    description = "Convenient hiding panel for addon buttons from DataBroker and Minimap",
    folder = "HidingBar",
    version = "1",
    needsReload = false,
    profile = profileString,
    supportsDefault = true,

    -- Hiding Bar has no profile named "Default": the fallback is whichever entry
    -- carries isDefault. There is therefore no second name to import into -- a ticked
    -- run writes the same profile as an unticked one and flags it (see markDefault),
    -- which is why the fallback name here is our own.
    defaultProfile = Installer.profileName,

    apply = function(_, payload, profileName)
        local hb = _G.HidingBarAddon

        if not (hb and hb.profiles and hb.checkProfile and hb.setProfile) then
            return false, "Hiding Bar's profile list is not available"
        end

        local data, err = decode(payload)

        if not data then
            return false, err
        end

        if not isProfile(data) then
            return false, "that string is not a Hiding Bar profile"
        end

        data.name, data.isDefault = profileName, nil

        for i = #hb.profiles, 1, -1 do
            if hb.profiles[i].name == profileName then
                table.remove(hb.profiles, i)
            end
        end

        hb:checkProfile(data)
        table.insert(hb.profiles, data)
        table.sort(hb.profiles, function(a, b)
            return strcmputf8i(a.name, b.name) < 0
        end)

        hb:setProfile(profileName)

        return true
    end,

    -- The fallback is whichever entry carries isDefault, which is what a character with
    -- no pick of its own -- or one whose pick has been deleted -- is given. Exactly one
    -- entry may hold it, so the flag is taken off the rest; that is what its own options
    -- menu does for "Set as default".
    markDefault = function(_, profileName)
        local hb = _G.HidingBarAddon

        if not (hb and hb.profiles) then
            return false, "Hiding Bar's profile list is not available"
        end

        local ours

        for _, profile in ipairs(hb.profiles) do
            profile.isDefault = nil

            if profile.name == profileName then
                ours = profile
            end
        end

        if not ours then
            return false, "the imported profile is no longer in Hiding Bar's list"
        end

        ours.isDefault = true

        return true
    end,
})
