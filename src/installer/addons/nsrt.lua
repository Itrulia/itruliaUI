local addonName, ItruliaUI = ...

local Installer = ItruliaUI:GetModule("Installer")
local profileString = "9LvFST111D9ISRILDt032kXoLu1snUX2XwYjZklww8drrUqjstsjN26bZ3J8s9Eqp(E3EFpkkA4H1suKP)ijdtTlazZBiLWjRb9pYMMNb6qbYMsqwnWAXDeddEafyDSaPTODFu1HcmSwKDo337XhfJ3(dBEF3Z5EUNZ5E(439kPPcxu2wERNy3iMM6fnRAKuZYEQ78OJLXIs01N6H)oloLIzPsweBPWgYLj7LwtxxMfWSuGymtl7JDGiFIP4hqIFq6aIjQwJv(ZyfiwfwT3)rhJ37yp8B9hbm0hYqiw5A4kTvjbIsKlshkd8)1IOskSEwITTMXAw)s6Gr1SO6Y1wKzwHkOLFNmeQSgZ5J6lsk7mA3fmkOkBy78vZmYAfdxPujNp3oNgXDf0JMDDn6IY2KQY1EbsnfnJIckQTYAwr3Y20G4Y5JLTwzfntBTczi6Y2AMgwQAoAHkD0W6G7HWa9mBbzDIL78d6k6SQYSIUcAGL0SSagty7QTQ0HGnJvGKQ0sYRPvW1eIWKlzt8uhK7KKni6UlzK4YwltQgsNWSZAZQuWUcJKF30QYwKCALrhw)0rcvHjNJjxyDuXC9JtfoNSX6BfOzuGiAhrm1nz)w92B6dCUZo9Z07UzTHf85sjoB7DNLHZw3poeDaV1eZ0WoR2nibzB6q7AtSNhnxUL2fxAAtlnCYPZLknRMdLBEewwQCbqzoEpncBYksyOS6ntsqXTpCt48TAungPaUWWjxiwoLqW5PjtjYclNBHmoA4l6iSJ3tZCKnTrfkMU8AwSuRKlzILxGrmKv0jfvR7rUXcBszell48ObtCgUbjNj)0ct0vAsneY2ZL0RJ9VGJOY3uqSTTlmqVVUuMRQv0w9EnIRvK4yuQ0bWp88lOEahCjm2GWSiE5vzRQrj5Pd7Sh7FwL4eT1uTVx4pVPzzPDqHLdyWwJQ22B7P4kPHmdcBRa8t4FwYFIE5FQdXdeKh80hNpHe)tZpjFYKFc(uhVh(NPx(tEy(PYKjXIXZXFk(P5NbM9S8NMFov(55tZNbM6cs8Nr4i4pBE(Vrq(fVeF27XFov(VPk)5ZZVuE(C3JFzj(8Q8qs0HwXIeLusUIUD6qqqTrrlvfrmQ1ukI0wRxJE0zo)fN5Mjb9pq6ZhacpnCcrgB7cMqjeQf4P3ZNhmA1AmECinPJfotGmORbMp)(MF6aznLf8NF3oM(cOa6CIz6MJZ39etlK9G7Bptskj2YwqnatsgcKNbNZw53btWjfx20My1FDVmTTUq7KDVkqwGe9oJZPcrJQW4rRdLpUXnGse5zlPzOvwMofDqGu1eqYzzQmZUmXWoFyviaiFdWZs0lLgKkeBNl7QMAfihKE0f1nvK1HcFGBhkf5fxEQ9wHcLYjxvvZMGvP6FVqfkqO2lRvyDma2QpO(BfBth2qf9QHuRVIHQSou(rTHJCrXXNEcGuRfjgqLUcUfJJjICWqLGV8r4tEGX3ZzbTfF(w(sqOq0hBvWNHfEWszGt0CdWvArHkQe4qg91UY2j0(Z99hUbyNPG0gi6asv6C5PbFiX2Q)mRwrnQz(DWv7USV9bQlcU01G0UbxXGHTusz45(bb1whZwZOGJx5GkPkBOfjQAMfzAfNo)0zRetTzuzX5CmMWGOdUuMC4zTZHJMLPbKQ3HE7u(i(L)RgD0a90tppOb)K8h8lbdAjcC8pk6q)FX7foc0PnF9KYgRvrEnsyIXkzNg2A1wct3ZqafA0RsKxhl2BLOm1Kz7yl9UDuIsL1sAUMf00dJu0RuMqYiMfCj7Z8ZsmkEWDtM4kRKi61xkuKmPuBSunpwQNbc9ykvmYSG(gRKiF9SXEXLQGXh0bwytiCZqwVDu5E(h4IsY8NEAy3Z3mDiGvMCirDD1D9d6GOQhW5(l(F94IyD3KPHvstyzmRokp41EC6aWO91NyIvsdrFhM)KhIFkEemO0PuUOFC85FKsLYd(B(5Yd5dw4CEfqZZNvM)C5XcAtbqrqNtPs5Qr9kIZNtweEpp06oKUWuTjUkQAR0HWY6Ekzjq(aZNmJyxt370N9zan5K8Gs8jF5Jqhkeumyndmz2BfXU9hmwgrjlvLugPRORRE7V3u8)q1gzPqGRdL3)dgdMbSz3coT9jNKowwOmHWT6rueKcNUiHuvSTGdUuLW0AiSrJvqN47rR7LtgF(NQ1xgcmLeA6V6anqKmIOylNI)NAIvOOpDx0A97PBsdJl)RJoO6rjfGsx6w9XqMa4i0ijWkrLKlqUwOIftzyDTLHGtvWfMD9AOkHDZSU2sKIAYxZDrwxRGqlV(fPBEwQXA7udj4cajmQWkxPI8n00AydZ3HoUZM(mkPKfaQTEnPwyv0WqyWAmSBeCeF4MI2OALjmNgYdSIHMDIcMgE(LvR7zGWP(CZWNu4vMDMD78KERb43k(8NlyZFa61W4JVEF8VPkpyV8)mhxgwwC24ZBF3dJj68PIp)NEP)85XHVj)Tuk0TZDU4Zh)h(Qc6VnCguPzec68cPdbmqdXDcl7FS)yk1egGe)wNzxfryQRJqssQxLnfepDp8G3Eu(KNUVTvK9O3lqV9HztbFEXaNH3OEiBMzbn7AEg03asiuA7983J09EUZEXm1qVMuMnf)WN99hIFBjW4MM)oo7d4oM7k83(WEEea0rDih2clDMhYu2jIorMLY4f0WYCzX7vG1jGvqhf5ZekQSVO67ksVAeovUCPwcXfYdoYi1xc6FGyNu5Zg9tH7pl8Ic3RNModFUVYKGb)U4r5ToXUq5PQE(Yn2oNkePya4cpeG)e(Duq9L6fu)GskjjgRzRo62XyKVyfIrHAO4MgeJaZzeStlwbwIoOiOcMZpWQPNbjM6W0HszOxtmNpUHMoDrCfdue8JNjFxen2mma(SJblX)BABO8)29BI36eOf(u8VRiuT9w3sSRDQTyTHUQxmGGj36AIYF4XAyiSZc0luEjm8ouqTgwbAqzifiao6fROPd4JFaAo)7()VodAR7XcUhEfLhD3oZi3AC(osHXJT4Z3F)JppMY9xkI153rAB017Gxgc2Fi(Pchfmsr63DFg(LJp)N9l8N(V8rF0h5eth)Y)W)U)7FGBczFFL38lHYcstJ(f)wI00Vbgb)wqPweDPBYhQy5XyBiG2nu(DC(zo)fcH53AsEWN)rbUyUU)80Xrp9dmwwDBHdhBUcnwCX3iGmxsdILDIEA7o2gBwkWkKNoswBtaSPdKtpz(qI2PjnLfGq7Nog2LDdYhBRBfvg60uX4mVGmG4C9(BfMrQ2X30HxXWPt)zWTPSOvz)7bxk3UZLv3dE)wHo2WV0XMkJf(fDKBwiwSleouOixmNmBncaq4MmfO8oIu4ydpX)6u8FkDiFMIPTj0m9Mm()gqvPBQzPiKnxQBDuGk)NHJh6)8Vh5CqFotINwUm(hVjsCaFIH1R4TfN43XxiTQ2E8WrVt7X99S)Z(Z)N8s(Jd87HJ)3f888dIJ)pGX0J6FLNLsRxXYZXK)ydD7(6wtmTSC1KV2TrAD4VIYmPPH2HEM78i9X8PlUzFa80ZLJp53Ql3LdYfhQ9DP)cFn)nEny8E(mMH45uN773Ht9)PlTfUyHhFpXB4lT)Xl01(MbWN6lXpSdp2BIJ)LIXd8bDTQiQyaI7Qgmrx7DMkgE0(K)dD5jItK1dPyzYuC4yOFXw(75ScRyyFUtPG36zDxw)ERIS(RfSo(72(aD4hX)qVVN(U(Zp(98f9jI4p(rA574(W701wgdtwimx9)RED)LL02F8lSG)2eCPU8oqNO1B7tF0FExEhevORb9MFhViXJn0DM33F)YVH)8)IFAh(Nv8v8F8ItT)0iOwGNGh(5(MaX7l1J4Jud1HP)RAl5H)Q)AFB45l4ZZ2B4p)x7D8N)17y8eFHU2DbAa3D)Gh1FtEYVT)I(T7Xx9BUR3yE08hB4Z(7ku4hc(E6RyM8FAp8f8QIfrHmlkaHQbwHmHXgAIMxzW7nIjKUT8Y3cUSyrbqc8T2SEnehVao8rghqnITvsD1LfO5H68ZEj(CxcUZNPPqgELxD2dN3KuLoze4kTvkJIekkRvsRGOyUxr9SeOfxrRdVxeO4rrgqWvr3r0j0rTwLFRlHAb28cBPbqpCeVhZ7crBw2Txk220DPVeFYF2OOvWYwawHXAGrCFPhgXKfusyiZEf6OUVqjufd1Z2oJ0Hq85TF7v(l3hiP3v8UrWIbuXVcEHRzNX9PGWhssCRlbgRxn(L)5V(R)gI7Bb3erClawfQp45JZdEc64TN3T(zopa9IMR7TCLYkoWtDVfjFYVCl)jrmR1OJ2TqCfaGnGoGdZz64T(yzf3haUv3tP4aJSf2bUdwozDVx1JpT4X)CVn6O4tFnZ9LE8w(MJON3O(rWTPCtwdFfLpDtNpCFQuj3pDfSuh2WYMv7WjG4BM9En90hxVaDmF2ryg7JFHg7TpnWpCE5uqV5ZDVookGDYzviux6q7tKENbs9URJM6id4cdDca0Q)TBdKT)TB)wcB9yTsAwyDFSc86Tcd3kuvw2DcfNp3Brt91zALptuMmXWKXC)MosevDt4aPSshqq41PhngHjRxw26m5QQzHbsltW6S868FcqEiSFLa3IMoaLQSjC)T6nwPIN8vsPcP3m8(EUaCCjGRfatvgNkJ8gamF4wO2WSdUmdqJFMLKxd3gTIOaPJalxdOlRSpMBT6792V3BBB22OBgr2UtNaDKymZBqm2pYky(Htuw2OYA61u0Sl4Z(q5Qzdxd1A)Q0aRsi2MkaMn)nAvY(2y(pcxTJpUQ2nUrnxk3x688pefre4cpQA7t3gigk29Px8Fm6bIBQxt99(RnS9CwHXzA4uff)tc1pDWUXyA1pD04YwjnxdGfabwMlPv0abOLNoMd01Uxr)Hxo7kjwDpMNeUEjeIC)7zd3FrhUu21RcZBwfGzIkheVI8NZL4vf0g7(WLkW)rhG4(Guwxxwe4owDl3cppRIQ4f1FLDCOK2uZW(ZZpD9vsKgqtd5QNwQ4HYufFj)xrGOgFIpDah7utC1q9Njurii4jOJ79mgbYUETayHYaIxYOOm9O)FqA7uuWyGswf7hFZizJ2)DT2AqEWRnbDSLGIxAiHp(ZADZJGfyXAVylGx9q4fR(9v9Fi(tX)S4ZWlELkv(FGk9epO)Wpq3iiVarIVdLzI3YatyzfDQB()o"

local function importAs(payload, name)
    local NSAPI = _G.NSAPI

    if not (NSAPI and NSAPI.ImportProfileString) then
        return false, "NSRT's profile API is not available"
    end

    local NSRT = _G.NSRT

    if type(NSRT) == "table" and type(NSRT.Profiles) == "table" then
        NSRT.Profiles[name] = nil
    end

    if NSAPI:ImportProfileString(payload, name) ~= name then
        return false, "NSRT rejected the profile string"
    end

    return true
end

Installer:RegisterAddon({
    key = "NSRT",
    title = "|cFF00FFFFNorthern Sky Raid Tools|r",
    shortTitle = "|cFF00FFFFNSRT|r",
    description = "Raid Tool Addon for the Guild \"Northern Sky\"",
    folder = "NorthernSkyRaidTools",
    version = "1",
    needsReload = false,
    profile = profileString,
    defaultProfile = "default",
    supportsDefault = true,
    apply = function(_, payload, profileName)
        return importAs(payload, profileName)
    end,
    markDefault = function(_, profileName)
        local NSRT = _G.NSRT

        if type(NSRT) ~= "table" then
            return false, "NSRT is not loaded"
        end

        NSRT.MainProfile = profileName

        return true
    end,
})
