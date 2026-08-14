local addonName, ItruliaUI = ...

local Installer = ItruliaUI:GetModule("Installer")
local profileString = "ItruliaQoLnR1w3jQYs4FlNh2VKSYSaKRpAmsgpXGUdoZSNZAwSSvA1(mi4PPjzC)G)2pv3nOGGjQ5YEEyMqG(s11xvF1LobQbJc8VhnLM4IMYsOR5)oognjchgCDalW3nzAw6ieDoMDpI(tmT6i8rXXjzXtX8NxkhGNUyIrRjXZVgjMqkEAsC43iXH8FBbMmFblWZa(adXYsNGOJW)ILrXb(()mlkAwuYtyQwG)0KOeXkGc8ud8Ne4P8jnd4P58NmuGHq5FHX3YvjKygFWRdCVYWsrvt3W22r1qXXYky2v6Wg(RaVRu(KIMUJzRww2okMAgfZ0VtxVrDFGVuZOOLyFgfXqb(x3UZD3(WGV4DtG)tKq2IaVwgkb(psMlfUZ)abcVs(HX0j)85ylpoPlsE6wkODdbv9Ka)SvHigUxmdtFefXhjSaPRW4kkvvTZsi(K(wTQLEHM2qttkkvmjEapjB2ShWlb4SM9qfmWewaBnhvfhDtfhh9DyqRpPOa7OPPIQrzey0GH8TOUakfoPGXHB)qs6Qi0A(jmW)IlKc1fxaRe8wFUwJRZMLiLg(p9xGctEQZUL21qxrVLQJLPLHJMJPciFgTKNDPUihGy5la5VXbEA25Mh9XpIJeY0Uv)7dMnlfdWWv5VEqglIediWGVmQFpVULh8Fvmy1NXGJpCx0ss06a)U)AffNM(eAnxKyS0cWqEQhnYx4sgHPSVTah3lms4xcd8RjrzlbH3wCygcoZK0uW)SxCizkILSpm(EP3A(WCAAQgv2vD)9APOiSZuAW3UUFKX5yXbkXnJxkvJ)lWWdE59jzP4oe6uqVxvFwAUc)rXUpdnf)J2HHdIt)rpgnlIG(ZK()yjoKG(bto0TFP0AFpmGSLFInhmvsNcWTqmRrv6AR6OBzBaSCMkwoT4uGgg8tLRTULvltDdlW5SLPP4lM8tTRPJwlvBvntDRwAQfqlNnQaefNZhXlXXS2ClT9oPmcyhVIqrrG54xtiqObokWjZgT9tvhOWBTWcvLJChbAugTnomyV3Ue47LWTX296HLPlQi8b(FoHMIFxCgu1R6m8NzO)MqA2rWV)xU9KDgQEaZzgAmcsPZSWY2LIXBgxaX1aujkzY11u8uskjjwij7gwN9bpxDBLw2TCSnAPyARzBNRI2cOkYOmpGiHUCEW7rXO5YqlLH5Rm2dMZJwmjJXsIlVTcx6MqGLCVi4OrBhTAHu(sxHMcUWINHKGGZtkFvOjr4HjrrCZckgfUUZc80FkJaUcfgct57apt1GFY3)xCR4s7fFjsIJw3lMhoFfFKc3HKKigzv6lgNQAIcB1yLnN0o6ysNyCMt2I8)MLYiZw)5YoHYdphE5N1PiiFXOHqcjCnrcLaMziUEhC4g8qV)ZaVrT7xs95IcX5Wfh6H5XjsOCuc2qUQ2td(HHWShmHRR52N8GZqKSCcAhb2uXV6ZquwAD7xB7wkqMKkgAqsl2A6nz)(BllHYrgY8WCOLSWL6PUXHPsYIRK6XYFOt9u2luvhKkGvfbKR9L5Rn8i8AWM5SswPIm0Sw(T155SaPd44ugF02N9B3WoIWLvsE5sbx2MXs16L8V)zmpTroX7zPLFBSVFn8ohJnU7v62AqrHgo2MQgoW)4vKOZj4JgwrPUNogu8GLRUMguXj4)Bc5g5iNADT)KsA)8AtZvJskqbFFXlUjlEoMhXbuWZPjp9LvpHOIHaZ6gmITylfvfBHNj92JqCQymesa81FseA6pJiPWlG4QLZCRX0LtLjt9ns0cC0sWsAkeJCPyMW)jw3szliYPBxDzVpgtV71xuYxyY6hsK54NRk5pEt77BFlGbJ2RE5rT9UR2l)C329RpwwHMT5LBYPVC8IeFRKn4tpTGWWfMjf1CojxQlGBnEYpGQhYH7MmQm0UhVtc5rDfHV)GyxkZRFWiHvj2VPx7(dU90mMooI9(DDhvJsY02s10wxX0XbiNuSZBsYXqjDLLUQLJcucNLPTJMQ1PWjXty3nHUKh9Ut)bDUJ)YhWRqe6hyiGFB6Msz6v1xz3dEro3lUOFYtBgZ9oMqIiS15nqquFW)g2sCyZ9xJXlGv2o2pqqQMN0jbspBu7JbOYZOAFhhiBCliwSMPPJHLmRCDRJnSOONNw8EUk65PQQDr3L1SQbxEjBgZekDUed1RegTMK(vuejuIfsM5Huq9eZEahHrP73bike6FauhuWU2QlmIOzRoiuUx65hbLGe5kf6L3v3tn9W7i8KdrpIirCr5dQLQNaB7E2nJgmO)OEdpOn2HcOxTbv1AcvPwQMwU3rICC(jOJ4Rr7mws7PtXRyfzeuXzDycp6xt5WbK3QaJpumKPQTLTHmHsRIUJBOAbg1QAg4RuA6ckovmvkiBglALXwHSiJ0R3tziATSCkhQRr76PSHYEkO6QYYgKFaPc(BdF1w1C588lzxjmLa9C6EMnOOOcvYBSQrZ80C1oNsUGnSV7T9wUIM3errkOiWtPFsc3pjAFUrzSU8eCrpVlvP5XhzUM9gYSzKPzrmrQ4H7(npTwflk3w)WJt1KpU5VCeyo9DEqapWAaGtgo95ccF(16UTTODaBhW9jTPoUxMuXsPfKpPPHPbuQQIUjNtX8GXePIS9Uoz)vScZHmLWnJNJr0A(9LkbOCqIJJGAbSIS1UqWYAxIa3Jq(HQct32J2m(IlGkuEy03V4InJD722FufFQQsitqhf9eUMrNyp4T9GTiLb8wP1oCv25BFO91Bg3zWG7611VYgU3b)zDAls94WTY9mIfEsoN(ZEb99bq49nleirjTFzOhLffsHqhnSjDk(wtAx3(T9VZFZ42E3Sz8WbJ6nWZ)fW2SLltI954xt7MV4ZppW(5U9hUzS)xU)(bEpdUY4DHuyT8rM4TwJrwEZyQpZgm(I13CzUQI)Hoz00eAJ3kk)EbGAGiXZZB17K3IBkT(LK(IxnQYBXvJkUaIHy2quAk5XZRB1NNzY7oNX)exT(kPAmVY47WRfS09jPmzi5dC)q7YEqeuIsEeKi59UXV7jAsAQR8A(4GXR7QdxqcXFJWwKKXkKp(IcvnHJkATcxG3m(Y)iINk6Fe4hNS9OWhMS4YTZUsuyrJ2Yh1n5DDJWWlZZQLdah(chp5By8iyIoUuQpyPzhR55X1mTgVLexDtvlhdfDDlnO(QwIeGADuLo7Az2sZwvrZW02r1rrxovMeM7f3lovCDjfHgszR5)Lxiw8)xgHcjmIyIlsEhWiVH4gUuYgyqHn6ECe(JK3qx50aMxfVHYrHcsr8K4rkLgvfEeqO3mEG7MX33TF3UYa4CaSPCOFrVJp07F)CdZ)bEfIvUbrry(fikWRIBU5XVeb0RW(94u7NI18PqGv3i)veASGvW12u120OLdKhIjukxXFWm0MmZVuWDe8)p"

Installer:RegisterAddon({
    key = "ItruliaQoL",
    title = "|cffe9e9edItrulia|r|cff9184d9QoL|r",
    description = "StrongAuras that give you an unfair advantage in m+ and raiding",
    folder = "ItruliaQoL",
    version = "1",
    needsReload = false,
    profile = profileString,
    supportsDefault = true,
    apply = function(def, payload, profileName)
        local QoL = _G.ItruliaQoL

        if not (QoL and QoL.ImportAsNewProfile) then
            return false, "ItruliaQoL's profile API is not available"
        end

        QoL:ImportAsNewProfile(payload, profileName, true, function(ok, err)
            if not ok then
                Installer:Toast("ItruliaQoL import failed: " .. tostring(err), 1, 0.4, 0.4)

                return
            end

            Installer:MarkInstalled(def.key)
            Installer:PlayInstallSound()
            Installer:Toast("Imported ItruliaQoL", 1, 1, 1)
        end)

        return "pending"
    end,
})
