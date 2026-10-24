--[[
	📦 TH2 Items Data v3.2
	═══════════════════════════════════════════════════════════
	URL:
	https://raw.githubusercontent.com/wino444/EclipseX-Commands/main/TH2/TH2_Items.lua
	
	🔧 v3.2 Changes:
	- ✅ เพิ่ม Thai (ชื่อภาษาไทย) ทุกไอเท็ม
	- ✅ Zone ตรงกับ CategoryName
	- ✅ Single Source of Truth (ลบ ItemDB ใน CMDS1)
	- ✅ 29 ไอเท็ม 7 Zones
	
	Collector Core v5.1 จะโหลดไฟล์นี้อัตโนมัติ
--]]

local Collector = getgenv().CollectModuleCore
if not Collector then
	warn("[TH2_Items] ❌ Collector Core ยังไม่พร้อม!")
	return
end

-- ═══════════════════════════════════════════════════════════
-- 🎨 MESH DATABASE
-- ═══════════════════════════════════════════════════════════
Collector:AddMeshes({
	["145815901"]        = { name = "Rose",              category = "Flower" },
	["1032879482"]       = { name = "Bloxy Soda",        category = "Drink"  },
	["17230208"]         = { name = "Bottle of water",   category = "Drink"  },
	["19106014"]         = { name = "LazyChip",          category = "Food"   },
	["79146128"]         = { name = "Spray",             category = "Other"  },
	["133107060401499"]  = { name = "Girlled Pork",      category = "Food"   },
	["868958273"]        = { name = "Revolver",          category = "Weapon" },
	["36365830"]         = { name = "Broom",             category = "Temple" },
	["22147051"]         = { name = "Pickaxe",           category = "Mine"   },
})

-- ═══════════════════════════════════════════════════════════
-- 🖼️ DECAL DATABASE
-- ═══════════════════════════════════════════════════════════
Collector:AddDecal("8979654359", "High Five", "Other")

-- ═══════════════════════════════════════════════════════════
-- 🔵 Zone 1: จุดเกิด (Spawn) — 5 ไอเท็ม
-- ═══════════════════════════════════════════════════════════
Collector:RegisterCategory("Spawn", {
    { Name = "Sign",       Thai = "ป้าย",        Zone = "Spawn", Price = 100, Data = CFrame.new(89.4352951, 176.4534, 262.949463, 0, 0, 1, 0, 1, -0, -1, 0, 0) },
    { Name = "High Five",  Thai = "ไฮไฟว์",       Zone = "Spawn", Price = 70,  Data = CFrame.new(89.4352951, 176.4534, 257.418091, 0, 0, 1, 0, 1, -0, -1, 0, 0), DecalId = "8979654359" },
    { Name = "Boombox",    Thai = "บูมบ็อกซ์",    Zone = "Spawn", Price = 100, Data = CFrame.new(89.4352951, 176.4534, 252.473312, -1.1920929e-07, 0, 1.00000012, 0, 1, 0, -1.00000012, 0, -1.1920929e-07) },  -- 🎵 Boombox
    { Name = "Rose",       Thai = "ดอกกุหลาบ",   Zone = "Spawn", Price = 5,   Data = CFrame.new(89.4352951, 176.470078, 247.635803, 0, 0, 1, 0, 1, -0, -1, 0, 0), MeshId = "145815901" },
    { Name = "Fireflies",  Thai = "หิ่งห้อย",     Zone = "Spawn", Price = 12,  Data = CFrame.new(89.4352951, 176.4534, 243.022141, 0, 0, 1, 0, 1, -0, -1, 0, 0) },  -- ✨ Fireflies
})

-- ═══════════════════════════════════════════════════════════
-- 🟢 Zone 2: 7-11 — 8 ไอเท็ม
-- ═══════════════════════════════════════════════════════════
Collector:RegisterCategory("7-Eleven", {
	{ Name = "Bloxy Soda",       Thai = "บล็อกซี่โซดา", Zone = "7-Eleven", Price = 10, Data = CFrame.new(-33.5496025, 177.479095, 236.537354, 1, 0, 0, 0, 1, 0, 0, 0, 1), MeshId = "1032879482" },
	{ Name = "Bottle of water",  Thai = "ขวดน้ำ",        Zone = "7-Eleven", Price = 10, Data = CFrame.new(-35.8496056, 177.479095, 236.537384, 1, 0, 0, 0, 1, 0, 0, 0, 1), MeshId = "17230208" },
	{ Name = "SlurpeeBig",       Thai = "สลอปปี้ใหญ่",  Zone = "7-Eleven", Price = 50, Data = CFrame.new(-45.7239647, 176.111298, 235.692612, 0, 0, 1, 0, 1, -0, -1, 0, 0) },
	{ Name = "SlurpeeLittle",    Thai = "สลอปปี้เล็ก",  Zone = "7-Eleven", Price = 45, Data = CFrame.new(-47.0254936, 176.226288, 235.697556, 0, 0, 1, 0, 1, -0, -1, 0, 0) },
	{ Name = "SlurpeeMedium",    Thai = "สลอปปี้กลาง",  Zone = "7-Eleven", Price = 30, Data = CFrame.new(-48.3586273, 176.226288, 235.799423, 0, 0, 1, 0, 1, -0, -1, 0, 0) },
	{ Name = "LazyChip",         Thai = "เลย์",          Zone = "7-Eleven", Price = 10, Data = CFrame.new(-33.7161064, 177.467255, 225.749756, 1, 0, 0, 0, 1, 0, 0, 0, 1), MeshId = "19106014" },
	{ Name = "Jupa Miss",        Thai = "จุป้ามิส",     Zone = "7-Eleven", Price = 10, Data = CFrame.new(-18.5160732, 177.467255, 225.749786, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
	{ Name = "Spray",            Thai = "สเปรย์",        Zone = "7-Eleven", Price = 50, Data = CFrame.new(-25.0601158, 177.467255, 225.749786, 1, 0, 0, 0, 1, 0, 0, 0, 1), MeshId = "79146128" },
})

-- ═══════════════════════════════════════════════════════════
-- 🟡 Zone 3: ติ่มซำ — 3 ไอเท็ม
-- ═══════════════════════════════════════════════════════════
Collector:RegisterCategory("Dim Sum", {
	{ Name = "Chinese steamed dumpling", Thai = "เกี๊ยวซ่า",  Zone = "Dim Sum", Price = 10, Data = CFrame.new(-54.7672501, 177.508926, 219.016983, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
	{ Name = "Steamed stuff bun",        Thai = "ซาลาเปา",   Zone = "Dim Sum", Price = 10, Data = CFrame.new(-54.6872482, 179.368912, 220.858307, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
	{ Name = "Sausage",                  Thai = "ไส้กรอก",   Zone = "Dim Sum", Price = 10, Data = CFrame.new(-54.6872635, 180.508911, 220.858276, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
})

-- ═══════════════════════════════════════════════════════════
-- 🔴 Zone 4: Girlled Pork — 1 ไอเท็ม
-- ═══════════════════════════════════════════════════════════
Collector:RegisterCategory("Pork Stand", {
	{ Name = "Girlled Pork", Thai = "หมูปิ้ง", Zone = "Pork Stand", Price = 10, Data = CFrame.new(95.4450226, 177.125458, 200.190567, 1, 0, 0, 0, 1, 0, 0, 0, 1), MeshId = "133107060401499" },
})

-- ═══════════════════════════════════════════════════════════
-- 🟣 Zone 5: ร้านอาหารใกล้วัด — 6 ไอเท็ม
-- ═══════════════════════════════════════════════════════════
Collector:RegisterCategory("Restaurant", {
	{ Name = "Tom Yum Kung",                        Thai = "ต้มยำกุ้ง",            Zone = "Restaurant", Price = 30,   Data = CFrame.new(396.719849, 168.74675, 45.2358131, 0.587827086, 0, 0.808986604, 0, 1, 0, -0.808986604, 0, 0.587827086) },
	{ Name = "Somtum",                              Thai = "ส้มตำ",                Zone = "Restaurant", Price = 30,   Data = CFrame.new(394.169708, 168.746735, 48.745369, 0.587827086, 0, 0.808986604, 0, 1, 0, -0.808986604, 0, 0.587827086) },
	{ Name = "Fried Rice",                          Thai = "ข้าวผัด",              Zone = "Restaurant", Price = 30,   Data = CFrame.new(391.235443, 168.74675, 52.7832832, 0.587827086, 0, 0.808986604, 0, 1, 0, -0.808986604, 0, 0.587827086) },
	{ Name = "Grilled fish vegetables and peppers", Thai = "ปลาย่างผักและพริก",    Zone = "Restaurant", Price = 30,   Data = CFrame.new(388.251068, 168.74675, 56.890274, 0.587827086, 0, 0.808986604, 0, 1, 0, -0.808986604, 0, 0.587827086) },
	{ Name = "Bok Choy Oyster Sauce",               Thai = "ผักกวางตุ้งน้ำมันหอย", Zone = "Restaurant", Price = 30,   Data = CFrame.new(385.46344, 168.74675, 60.7267151, 0.587827086, 0, 0.808986604, 0, 1, 0, -0.808986604, 0, 0.587827086) },
	{ Name = "Revolver",                            Thai = "รีวอลเวอร์",           Zone = "Restaurant", Price = 5000, Data = CFrame.new(391.621918, 168.511139, 58.9829025, -0.587827086, 0, -0.808986604, 0, 1, 0, 0.808986604, 0, -0.587827086), MeshId = "868958273" },
})

-- ═══════════════════════════════════════════════════════════
-- 🛕 Zone 6: วัด — 4 ไอเท็ม (ฟรี)
-- ═══════════════════════════════════════════════════════════
Collector:RegisterCategory("Temple", {
	{ Name = "Broom",       Thai = "ไม้กวาด",   Zone = "Temple", Price = 0, Data = CFrame.new(492.299866, 193.897461, -28.0260544, 0.0523988605, 0, 0.998626292, 0, 1, 0, -0.998626292, 0, 0.0523988605), MeshId = "36365830" },
	{ Name = "Tube",        Thai = "ธูป",        Zone = "Temple", Price = 0, Data = CFrame.new(523.960876, 196.783661, -49.4984512, -0.0523990393, 0, -0.998626292, 0, 1, 0, 0.998626292, 0, -0.0523990393) },
	{ Name = "Folding Fan", Thai = "พัดลมพับ",  Zone = "Temple", Price = 0, Data = CFrame.new(598.896301, 196.596863, -31.6724129, -0.0523990393, 0, -0.998626292, 0, 1, 0, 0.998626292, 0, -0.0523990393) },
	{ Name = "Bowl",        Thai = "ชาม",       Zone = "Temple", Price = 0, Data = CFrame.new(599.122742, 196.596863, -35.9844666, -0.0523990393, 0, -0.998626292, 0, 1, 0, 0.998626292, 0, -0.0523990393) },
})

-- ═══════════════════════════════════════════════════════════
-- ⛏️ Zone 7: เหมือง — 2 ไอเท็ม
-- ═══════════════════════════════════════════════════════════
Collector:RegisterCategory("Mine", {
	{ Name = "Pickaxe", Thai = "จอบ",    Zone = "Mine", Price = 125, Data = CFrame.new(-99.9707413, 132.16777, 38.1245766, 0.857151747, 0, 0.515064001, 0, 1, 0, -0.515064001, 0, 0.857151747), MeshId = "22147051" },
	{ Name = "Shovel",  Thai = "พลั่ว",  Zone = "Mine", Price = 125, Data = CFrame.new(69.6632309, 104.523727, 89.2878494, 0.998631775, -0, -0.0522932447, 0, 1, -0, 0.0522932447, 0, 0.998631775) },
})

print("[TH2_Items] ✅ Data registered (7 categories, 29 items)")

-- ═══════════════════════════════════════════════════════════
-- 🚀 AUTO START
-- ═══════════════════════════════════════════════════════════
Collector:Start({
	probePass = true,
	autoLoops = {},
	autoCollect = false,
})
