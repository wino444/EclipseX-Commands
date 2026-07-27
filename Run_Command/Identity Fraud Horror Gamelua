--// 🌒 EclipseX — Identity Fraud Horror Game (ล็อกแมพ)
local EO = loadstring(game:HttpGet("https://raw.githubusercontent.com/wino444/EclipseX/main/EclipseX_Core.lua"))()

-- ตั้งค่าก่อนการปลุกระบบ
EO:Configure({
    Prefix = "!",                              -- ตัวนำหน้าคำสั่ง
    MapLockEnabled = true,                     -- เปิดการล็อกแมพ
    AllowedPlaceIds = {7304314747},            -- อนุญาตเฉพาะ Identity Fraud
    RankDataUrl = "https://raw.githubusercontent.com/wino444/EclipseX/main/DATA.lua"
})

-- ปลุก EclipseX
EO:Init()

-- รอให้ branch ถูกเลือก (หรือ stable อัตโนมัติ)
EO:OnBranchReady(function()
    -- เสียบปลั๊กอินดวงตาสุริยุปราคา
    EO:LoadModule("ECLIPSE_EYE", "https://raw.githubusercontent.com/wino444/EclipseX/refs/heads/main/ECLIPSE_EYE.lua")
    
    -- กองทัพคำสั่งสำหรับ Identity Fraud
    EO:LoadCommandModule("stable", "IFH_CMDS1", "https://raw.githubusercontent.com/wino444/EclipseX-Commands/main/IFH/IFH_CMDS1_STABLE.lua")
end)
