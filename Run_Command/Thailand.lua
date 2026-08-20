--// 🌒 EclipseX — เมืองไทย2 (PlaceId 4503309821) ล็อกแมพ + โหลดทั้ง Stable/Beta
local EO = loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/EclipseX/main/EclipseX_Core.lua"))()

-- ตั้งค่าก่อนปลุกระบบ
EO:Configure({
    Prefix = "!",
    MapLockEnabled = true,
    AllowedPlaceIds = {4503309821},
    RankDataUrl = "https://raw.githubusercontent.com/wino444/EclipseX/main/DATA.lua"
})

-- ปลุก EclipseX
EO:Init()

-- รอให้ branch พร้อม (หรือ stable อัตโนมัติถ้าไม่ใช่ Shadow)
EO:OnBranchReady(function()
    -- ดวงตาสุริยุปราคา
    EO:LoadModule("ECLIPSE_EYE", "https://raw.githubusercontent.com/wino444/EclipseX/main/ECLIPSE_EYE.lua")

    -- กองทัพคำสั่งเมืองไทย2 (Stable 2 + Beta 2)
    local allCommandModules = {
        -- Stable 2 ไฟล์
        { version = "stable", name = "TH2_CMDS1_STABLE", url = "https://raw.githubusercontent.com/wino444/EclipseX-Commands/main/TH2/TH2_CMDS1_STABLE.lua" },
        { version = "stable", name = "TH2_CMDS2_STABLE", url = "https://raw.githubusercontent.com/wino444/EclipseX-Commands/main/TH2/TH2_CMDS2_STABLE.lua" },
        -- Beta 2 ไฟล์
        { version = "beta",   name = "TH2_CMDS1_BETA",   url = "https://raw.githubusercontent.com/wino444/EclipseX-Commands/main/TH2/TH2_CMDS1_BETA.lua" },
        { version = "beta",   name = "TH2_CMDS2_BETA",   url = "https://raw.githubusercontent.com/wino444/EclipseX-Commands/main/TH2/TH2_CMDS2_BETA.lua" }
    }

    -- ระบบจะโหลดเฉพาะ branch ที่ถูกเลือกเท่านั้น
    EO:RegisterCommandModules(allCommandModules)
end)
