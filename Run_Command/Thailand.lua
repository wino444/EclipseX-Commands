--// 🌒 EclipseX — เมืองไทย2 (PlaceId 4503309821) ล็อกแมพ + STABLE
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

-- รอให้ branch พร้อม (หรือ stable อัตโนมัติ)
EO:OnBranchReady(function()
    -- ดวงตาสุริยุปราคา
    EO:LoadModule("ECLIPSE_EYE", "https://raw.githubusercontent.com/wino444/EclipseX/main/ECLIPSE_EYE.lua")
    
    -- กองทัพคำสั่งเมืองไทย2 (to แบบนั่งสมาธิ)
    EO:LoadCommandModule("stable", "TH2_CMDS1", "https://raw.githubusercontent.com/wino444/EclipseX-Commands/main/TH2/TH2_CMDS1_STABLE.lua")
end)
