--// 🌒 TH2 Items Registration — ข้อมูลไอเทมเมืองไทย2 (ฉบับสมบูรณ์พร้อม Rotation)
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
    { Name = "Bloxy Soda",      Method = "fireclickdetector", Data = CFrame.new(398.939087, 167.176117, 42.1815681, 0.587827086, 0, 0.808986604, 0, 1, 0, -0.808986604, 0, 0.587827086),  RequiredTeam = "Citizen" },
    { Name = "Bottle of water", Method = "fireclickdetector", Data = CFrame.new(-35.8496094, 178.114868, 236.537445, 1, 0, 0, 0, 1, 0, 0, 0, 1),  RequiredTeam = "Citizen" },
    { Name = "Bloxiade",        Method = "fireclickdetector", Data = CFrame.new(40.1529236, 153.846573, 138.041046, 0.970329344, -0, -0.241787016, 0, 1, -0, 0.241787016, 0, 0.970329344),  RequiredTeam = "Citizen" },
})

-- 🍜 หมวดอาหาร
Collector:RegisterCategory("🍜 Food", {
    { Name = "Tom Yum Kung",                        Method = "fireclickdetector", Data = CFrame.new(396.719818, 167.244568, 45.2357788, 0.587827086, 0, 0.808986604, 0, 1, 0, -0.808986604, 0, 0.587827086), RequiredTeam = "Citizen" },
    { Name = "Somtum",                              Method = "fireclickdetector", Data = CFrame.new(394.169647, 167.244553, 48.7453537, 0.587827086, 0, 0.808986604, 0, 1, 0, -0.808986604, 0, 0.587827086), RequiredTeam = "Citizen" },
    { Name = "Fried Rice",                          Method = "fireclickdetector", Data = CFrame.new(391.235413, 167.244568, 52.7832603, 0.587827086, 0, 0.808986604, 0, 1, 0, -0.808986604, 0, 0.587827086), RequiredTeam = "Citizen" },
    { Name = "Grilled fish vegetables and peppers", Method = "fireclickdetector", Data = CFrame.new(388.251038, 167.244568, 56.8902512, 0.587827086, 0, 0.808986604, 0, 1, 0, -0.808986604, 0, 0.587827086), RequiredTeam = "Citizen" },
    { Name = "Bok Choy Oyster Sauce",               Method = "fireclickdetector", Data = CFrame.new(385.463379, 167.244568, 60.7266884, 0.587827086, 0, 0.808986604, 0, 1, 0, -0.808986604, 0, 0.587827086), RequiredTeam = "Citizen" },
    { Name = "Girlled Pork",                        Method = "fireclickdetector", Data = CFrame.new(94.905777, 176.677673, 201.630219, 1, 0, 0, 0, 1, 0, 0, 0, 1), RequiredTeam = "Citizen" },
    { Name = "Chinese steamed dumpling",            Method = "fireclickdetector", Data = CFrame.new(-54.7672348, 178.144699, 219.016937, 0, 0, -1, 0, 1, 0, 1, 0, 0), RequiredTeam = "Citizen" },
    { Name = "Steamed stuff bun",                   Method = "fireclickdetector", Data = CFrame.new(-54.687233, 180.004684, 220.858276, 0, 0, -1, 0, 1, 0, 1, 0, 0), RequiredTeam = "Citizen" },
    { Name = "Sausage",                             Method = "fireclickdetector", Data = CFrame.new(-54.6872482, 181.144684, 220.858246, 0, 0, -1, 0, 1, 0, 1, 0, 0), RequiredTeam = "Citizen" },
    { Name = "LazyChip",                            Method = "fireclickdetector", Data = CFrame.new(-33.7161102, 178.103027, 225.749756, 1, 0, 0, 0, 1, 0, 0, 0, 1), RequiredTeam = "Citizen" },
    { Name = "Taco",                                Method = "fireclickdetector", Data = CFrame.new(36.8973083, 153.846573, 137.229767, 0.970329344, -0, -0.241787016, 0, 1, -0, 0.241787016, 0, 0.970329344), RequiredTeam = "Citizen" },
})

-- 🔫 หมวดอาวุธปืน
Collector:RegisterCategory("🔫 Guns", {
    { Name = "M4",      Method = "fireclickdetector", Data = Vector3.new(420.693115, 167.687271, 253.479202), RequiredTeam = "Citizen" },
    { Name = "Revolver",Method = "fireclickdetector", Data = CFrame.new(483.952637, 167.630722, 497.549255, 0.999394894, 0, 0.0347825065, 0, 1, 0, -0.0347825065, 0, 0.999394894), RequiredTeam = "Citizen" },
    { Name = "Gun",     Method = "fireclickdetector", Data = Vector3.new(-76.836731, 162.669846, 231.239838), RequiredTeam = "Citizen" },
})

-- 🚗 หมวดยานพาหนะ
Collector:RegisterCategory("🚗 Vehicles", {
    { Name = "Elitoria RZ750", Method = "fireclickdetector", Data = CFrame.new(460.338776, 200.698547, -240.407883, 0.905360103, -0, -0.424644619, 0, 1, -0, 0.424644619, 0, 0.905360103), RequiredTeam = "Citizen" },
    { Name = "Elitoria RN750", Method = "fireclickdetector", Data = CFrame.new(476.06958, 200.830475, -233.029388, 0.905360103, -0, -0.424644619, 0, 1, -0, 0.424644619, 0, 0.905360103), RequiredTeam = "Citizen" },
    { Name = "Eltoria RX750",  Method = "fireclickdetector", Data = CFrame.new(489.310272, 200.830429, -226.81897, 0.905360103, -0, -0.424644619, 0, 1, -0, 0.424644619, 0, 0.905360103), RequiredTeam = "Citizen" },
    { Name = "Eltoria RS750",  Method = "fireclickdetector", Data = CFrame.new(495.135864, 200.830475, -242.960953, 0.424632013, 0, 0.905366063, 0, 1, 0, -0.905366063, 0, 0.424632013), RequiredTeam = "Citizen" },
    { Name = "Police Car",     Method = "fireclickdetector", Data = Vector3.new(210.850082, 175.298798, 216.522522),  RequiredTeam = "Police" },
})

-- 🛕 หมวดของวัด
Collector:RegisterCategory("🛕 Temple", {
    { Name = "Tube",        Method = "fireclickdetector", Data = Vector3.new(490.306519, 176.16925, -51.2645264), RequiredTeam = "Citizen" },
    { Name = "Folding Fan", Method = "fireclickdetector", Data = Vector3.new(565.241333, 175.982513, -33.4385223), RequiredTeam = "Citizen" },
    { Name = "Bowl",        Method = "fireclickdetector", Data = Vector3.new(565.46759, 175.982513, -37.7505493), RequiredTeam = "Citizen" },
    { Name = "Broom",       Method = "fireclickdetector", Data = Vector3.new(458.646027, 173.28302, -29.7921772), RequiredTeam = "Citizen" },
})

-- 💡 หมวดไฟเวที
Collector:RegisterCategory("💡 Performance", {
    { Name = "BlueLight",   Method = "fireclickdetector", Data = CFrame.new(-197.713409, 180.987183, 155.59375, 0.10454309, -0, -0.994520426, 0, 1, -0, 0.994520426, 0, 0.10454309), RequiredTeam = "Citizen" },
    { Name = "WhiteLight",  Method = "fireclickdetector", Data = CFrame.new(-198.006058, 180.6772, 152.809052, 0.10454309, -0, -0.994520426, 0, 1, -0, 0.994520426, 0, 0.10454309), RequiredTeam = "Citizen" },
    { Name = "GreenLight",  Method = "fireclickdetector", Data = CFrame.new(-198.330139, 180.587189, 149.726044, 0.10454309, -0, -0.994520426, 0, 1, -0, 0.994520426, 0, 0.10454309), RequiredTeam = "Citizen" },
    { Name = "YellowLight", Method = "fireclickdetector", Data = CFrame.new(-198.654205, 180.78717, 146.643036, 0.10454309, -0, -0.994520426, 0, 1, -0, 0.994520426, 0, 0.10454309), RequiredTeam = "Citizen" },
    { Name = "RedLight",    Method = "fireclickdetector", Data = CFrame.new(-198.999176, 180.987183, 143.361099, 0.10454309, -0, -0.994520426, 0, 1, -0, 0.994520426, 0, 0.10454309), RequiredTeam = "Citizen" },
    { Name = "PinkLight",   Method = "fireclickdetector", Data = CFrame.new(-197.702942, 176.877182, 155.693161, 0.10454309, -0, -0.994520426, 0, 1, -0, 0.994520426, 0, 0.10454309), RequiredTeam = "Citizen" },
    { Name = "VioletLight", Method = "fireclickdetector", Data = CFrame.new(-198.047882, 176.987137, 152.411255, 0.10454309, -0, -0.994520426, 0, 1, -0, 0.994520426, 0, 0.10454309), RequiredTeam = "Citizen" },
})

-- 🛠️ หมวดอื่น ๆ
Collector:RegisterCategory("🛠️ Others", {
    { Name = "Handcuff",           Method = "fireclickdetector", Data = Vector3.new(164.228638, 177.92601, 250.528137), RequiredTeam = "Police" },
    { Name = "Boombox",            Method = "fireclickdetector", Data = Vector3.new(89.4352951, 176.4534, 256.519592), RequiredTeam = "Citizen" },
    { Name = "Spray",              Method = "fireclickdetector", Data = Vector3.new(375.218109, 168.250732, 36.9973984), RequiredTeam = "Citizen" },
    { Name = "SlurpeeBig",         Method = "fireclickdetector", Data = Vector3.new(379.064972, 168.250732, 31.7034531), RequiredTeam = "Citizen" },
    { Name = "Fireflies",          Method = "fireclickdetector", Data = Vector3.new(89.4352951, 176.4534, 244.019592), RequiredTeam = "Citizen" },
    { Name = "Syringe",            Method = "fireclickdetector", Data = Vector3.new(-192.2229, 179.741074, 210.603302), RequiredTeam = "Citizen" },
    { Name = "Stethoscope",        Method = "fireclickdetector", Data = Vector3.new(-192.2229, 179.741074, 205.754181), RequiredTeam = "Citizen" },
    { Name = "Pickaxe",            Method = "fireclickdetector", Data = Vector3.new(-91.2831726, 127.940315, 35.5896149), RequiredTeam = "Citizen" },
    { Name = "CampingLantern",     Method = "fireclickdetector", Data = CFrame.new(-86.2302322, 176.894485, 206.213943, 1, 0, 0, 0, 1, 0, 0, 0, 1), RequiredTeam = "Citizen" },
    { Name = "Flashlight",         Method = "fireclickdetector", Data = CFrame.new(-89.9848709, 176.894485, 206.213943, 1, 0, 0, 0, 1, 0, 0, 0, 1), RequiredTeam = "Citizen" },
    { Name = "Axe",                Method = "fireclickdetector", Data = CFrame.new(-93.7872849, 176.894485, 206.213943, 1, 0, 0, 0, 1, 0, 0, 0, 1), RequiredTeam = "Citizen" },
    { Name = "PirateFlintockSword",Method = "fireclickdetector", Data = CFrame.new(33.4809952, 153.846573, 136.378448, 0.970329344, -0, -0.241787016, 0, 1, -0, 0.241787016, 0, 0.970329344), RequiredTeam = "Citizen" },
})

print("[TH2_Items] ✅ ลงทะเบียนไอเทมเมืองไทย2 ครบทุกหมวดหมู่แล้ว!")
