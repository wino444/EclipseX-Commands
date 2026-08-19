--// 🌒 TH2 Items Registration — ข้อมูลไอเทมเมืองไทย2 (แยกจาก Core)
--// ใช้หลังจากโหลด Core และ Init แล้ว
--// ไฟล์นี้จะลงทะเบียนไอเทมทั้งหมดลงใน Collector

local Collector = getgenv().CollectModuleCore
if not Collector then
    warn("[TH2_Items] ❌ ยังไม่มี CollectModuleCore! (ต้องโหลด Core ก่อน)")
    return
end

--// ==================== ลงทะเบียนไอเทม ====================

-- 🥤 หมวดเครื่องดื่ม
Collector:RegisterCategory("🥤 Drinks", {
    { Name = "Bloxy Soda",      Method = "fireclickdetector", Data = Vector3.new(-16.6033745, 176.402084, 238.670059),  RequiredTeam = "Citizen" },
    { Name = "Bottle of water", Method = "fireclickdetector", Data = Vector3.new(377.602631,  168.262573, 52.0672989),  RequiredTeam = "Citizen" },
})

-- 🍜 หมวดอาหาร
Collector:RegisterCategory("🍜 Food", {
    { Name = "Tom Yum Kung",                Method = "fireclickdetector", Data = Vector3.new(-20.3787384, 176.47052,  238.670151), RequiredTeam = "Citizen" },
    { Name = "Somtum",                      Method = "fireclickdetector", Data = Vector3.new(-24.717041,  176.47052,  238.670181), RequiredTeam = "Citizen" },
    { Name = "Fried Rice",                  Method = "fireclickdetector", Data = Vector3.new(-29.7084618, 176.47052,  238.670105), RequiredTeam = "Citizen" },
    { Name = "Grilled Fish Veg & Peppers",  Method = "fireclickdetector", Data = Vector3.new(-34.7852478, 176.47052,  238.670105), RequiredTeam = "Citizen" },
    { Name = "Bok Choy Oyster Sauce",       Method = "fireclickdetector", Data = Vector3.new(-39.5275421, 176.47052,  238.670135), RequiredTeam = "Citizen" },
    { Name = "Girlled Pork",                Method = "fireclickdetector", Data = Vector3.new(94.905777,   176.677673, 201.630219), RequiredTeam = "Citizen" },
    { Name = "Chinese steamed dumpling",    Method = "fireclickdetector", Data = Vector3.new(352.308319,  168.292404, 57.0718842), RequiredTeam = "Citizen" },
    { Name = "Steamed stuff bun",           Method = "fireclickdetector", Data = Vector3.new(353.84494,   170.15239,  58.0895691), RequiredTeam = "Citizen" },
    { Name = "Sausage",                     Method = "fireclickdetector", Data = Vector3.new(353.84491,   171.292389, 58.0895615), RequiredTeam = "Citizen" },
    { Name = "LazyChip",                    Method = "fireclickdetector", Data = Vector3.new(370.129761,  168.250732, 43.9998932), RequiredTeam = "Citizen" },
})

-- 🔫 หมวดอาวุธ
Collector:RegisterCategory("🔫 Guns", {
    { Name = "M4",      Method = "fireclickdetector", Data = Vector3.new(420.693115,  167.687271, 253.479202), RequiredTeam = "Citizen" },
    { Name = "Revolver",Method = "fireclickdetector", Data = Vector3.new(-34.4966202, 176.234924, 242.627151), RequiredTeam = "Citizen" },
    { Name = "Gun",     Method = "fireclickdetector", Data = Vector3.new(-76.836731,  162.669846, 231.239838), RequiredTeam = "Citizen" },
})

-- 🚗 หมวดยานพาหนะ
Collector:RegisterCategory("🚗 Vehicles", {
    { Name = "Elitoria RZ750", Method = "fireclickdetector", Data = Vector3.new(380.279816, 168.692368, -188.027039), RequiredTeam = "Citizen" },
    { Name = "Elitoria RN750", Method = "fireclickdetector", Data = Vector3.new(396.658813, 168.824295, -193.825867), RequiredTeam = "Citizen" },
    { Name = "Eltoria RX750",  Method = "fireclickdetector", Data = Vector3.new(410.445068, 168.824249, -198.706772), RequiredTeam = "Citizen" },
    { Name = "Eltoria RS750",  Method = "fireclickdetector", Data = Vector3.new(403.252167, 168.824295, -214.287613), RequiredTeam = "Citizen" },
    { Name = "Police Car",     Method = "fireclickdetector", Data = Vector3.new(210.850082, 175.298798, 216.522522),  RequiredTeam = "Police" },
})

-- 🛕 หมวดของวัด
Collector:RegisterCategory("🛕 Temple", {
    { Name = "Tube",        Method = "fireclickdetector", Data = Vector3.new(490.306519, 176.16925,  -51.2645264), RequiredTeam = "Citizen" },
    { Name = "Folding Fan", Method = "fireclickdetector", Data = Vector3.new(565.241333, 175.982513, -33.4385223), RequiredTeam = "Citizen" },
    { Name = "Bowl",        Method = "fireclickdetector", Data = Vector3.new(565.46759,  175.982513, -37.7505493), RequiredTeam = "Citizen" },
    { Name = "Broom",       Method = "fireclickdetector", Data = Vector3.new(458.646027, 173.28302,  -29.7921772), RequiredTeam = "Citizen" },
})

-- 💡 หมวดไฟเวที
Collector:RegisterCategory("💡 Performance", {
    { Name = "BlueLight",   Method = "fireclickdetector", Data = Vector3.new(70.807457,  133.054077, 128.421112), RequiredTeam = "Citizen" },
    { Name = "WhiteLight",  Method = "fireclickdetector", Data = Vector3.new(68.0905838, 132.744095, 127.743759), RequiredTeam = "Citizen" },
    { Name = "GreenLight",  Method = "fireclickdetector", Data = Vector3.new(65.0826492, 132.654083, 126.993896), RequiredTeam = "Citizen" },
    { Name = "YellowLight", Method = "fireclickdetector", Data = Vector3.new(62.0747185, 132.854065, 126.244034), RequiredTeam = "Citizen" },
    { Name = "RedLight",    Method = "fireclickdetector", Data = Vector3.new(58.8726921, 133.054077, 125.445786), RequiredTeam = "Citizen" },
    { Name = "PinkLight",   Method = "fireclickdetector", Data = Vector3.new(70.9044571, 128.944092, 128.445267), RequiredTeam = "Citizen" },
    { Name = "VioletLight", Method = "fireclickdetector", Data = Vector3.new(67.7024612, 129.054047, 127.647003), RequiredTeam = "Citizen" },
})

-- 🛠️ หมวดอื่น ๆ
Collector:RegisterCategory("🛠️ Others", {
    { Name = "Handcuff",    Method = "fireclickdetector", Data = Vector3.new(164.228638,  177.92601,  250.528137), RequiredTeam = "Police" },
    { Name = "Boombox",     Method = "fireclickdetector", Data = Vector3.new(89.4352951,  176.4534,   256.519592), RequiredTeam = "Citizen" },
    { Name = "Spray",       Method = "fireclickdetector", Data = Vector3.new(375.218109,  168.250732, 36.9973984), RequiredTeam = "Citizen" },
    { Name = "SlurpeeBig",  Method = "fireclickdetector", Data = Vector3.new(379.064972,  168.250732, 31.7034531), RequiredTeam = "Citizen" },
    { Name = "Fireflies",   Method = "fireclickdetector", Data = Vector3.new(89.4352951,  176.4534,   244.019592), RequiredTeam = "Citizen" },
    { Name = "Syringe",     Method = "fireclickdetector", Data = Vector3.new(-192.2229,   179.741074, 210.603302), RequiredTeam = "Citizen" },
    { Name = "Stethoscope", Method = "fireclickdetector", Data = Vector3.new(-192.2229,   179.741074, 205.754181), RequiredTeam = "Citizen" },
    { Name = "Pickaxe",     Method = "fireclickdetector", Data = Vector3.new(-91.2831726, 127.940315, 35.5896149), RequiredTeam = "Citizen" },
})

print("[TH2_Items] ✅ ลงทะเบียนไอเทมเมืองไทย2 ครบทุกหมวดหมู่แล้ว!")
