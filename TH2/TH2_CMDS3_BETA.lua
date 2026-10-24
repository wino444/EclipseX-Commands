--// 🌒 EclipseOps Command Module — เมืองไทย2 (TH2) STABLE (ชุดที่ 3)
--// ย้ายคำสั่งดูป์มาไว้ที่นี่ เพื่อแยกความเสี่ยง
--// 🔧 v2.1 — ไม่โหลด Collector เอง (CMDS1 โหลดให้แล้ว)

local EO = getgenv().EclipseOps
if not EO or not EO.CoreLoaded then
    warn("[EclipseOps] ❌ TH2_CMDS3 — ต้องเรียก EO:Init() ก่อน")
    return
end

--// [SERVICES]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// [UTILS]
local function printDebug(...)
    if EO.EODebug then print("[TH2_CMDS3 DEBUG]", ...) end
end

--// [COLLECTOR CHECK — ไม่โหลดเอง, แค่ตรวจสอบ]
local function EnsureCollector()
    local C = getgenv().CollectModuleCore
    if C then
        if C.Probed then return C end
        printDebug("Collector มี แต่ยังไม่ Probe")
        return C
    end
    warn("[TH2_CMDS3] ❌ Collector ไม่พร้อม — ต้องโหลด TH2_CMDS1 ก่อน!")
    return nil
end

--// [ITEM DATABASE — Fallback ถ้า Collector ไม่พร้อม]
local ItemDBFallback = {
    Drink = {
        { Eng = "Bloxy Soda",       Thai = "บล็อกซี่โซดา", Price = "10" },
        { Eng = "Bottle of water",  Thai = "ขวดน้ำ",        Price = "10" },
        { Eng = "Bloxiade",         Thai = "บล็อกซี่เอ้ด",   Price = "12" }
    },
    Food = {
        { Eng = "Tom Yum Kung",                        Thai = "ต้มยำกุ้ง",           Price = "30" },
        { Eng = "Somtum",                              Thai = "ส้มตำ",               Price = "30" },
        { Eng = "Fried Rice",                          Thai = "ข้าวผัด",             Price = "30" },
        { Eng = "Grilled fish vegetables and peppers", Thai = "ปลาย่างผักและพริก",   Price = "30" },
        { Eng = "Bok Choy Oyster Sauce",               Thai = "ผักกวางตุ้งน้ำมันหอย", Price = "30" },
        { Eng = "Girlled Pork",                        Thai = "หมูปิ้ง",             Price = "10" },
        { Eng = "Chinese steamed dumpling",            Thai = "เกี๊ยวซ่า",           Price = "10" },
        { Eng = "Steamed stuff bun",                   Thai = "ซาลาเปา",             Price = "10" },
        { Eng = "Sausage",                             Thai = "ไส้กรอก",             Price = "10" },
        { Eng = "LazyChip",                            Thai = "เลย์",                Price = "10" },
        { Eng = "Taco",                                Thai = "ทาโก้",               Price = "30" }
    },
    Gun = {
        { Eng = "M4",       Thai = "เอ็มโฟ",     Price = "1000" },
        { Eng = "Revolver", Thai = "รีวอลเวอร์", Price = "5000" },
        { Eng = "Gun",      Thai = "ปืน",         Price = "3000" }
    },
    Car = {
        { Eng = "Elitoria RZ750", Thai = "Elitoria RZ750", Price = "ฟรี" },
        { Eng = "Elitoria RN750", Thai = "Elitoria RN750", Price = "ฟรี" },
        { Eng = "Eltoria RX750",  Thai = "Eltoria RX750",  Price = "ฟรี" },
        { Eng = "Eltoria RS750",  Thai = "Eltoria RS750",  Price = "ฟรี" },
        { Eng = "Police Car",     Thai = "รถตำรวจ",        Price = "1000" }
    },
    Temple = {
        { Eng = "Tube",        Thai = "ธูป",      Price = "ฟรี" },
        { Eng = "Folding Fan", Thai = "พัดลมพับ", Price = "ฟรี" },
        { Eng = "Bowl",        Thai = "ชาม",      Price = "ฟรี" },
        { Eng = "Broom",       Thai = "ไม้กวาด",  Price = "ฟรี" }
    },
    Light = {
        { Eng = "BlueLight",   Thai = "ไฟสีฟ้า",   Price = "ฟรี" },
        { Eng = "WhiteLight",  Thai = "ไฟสีขาว",   Price = "ฟรี" },
        { Eng = "GreenLight",  Thai = "ไฟสีเขียว", Price = "ฟรี" },
        { Eng = "YellowLight", Thai = "ไฟสีเหลือง", Price = "ฟรี" },
        { Eng = "RedLight",    Thai = "ไฟสีแดง",   Price = "ฟรี" },
        { Eng = "PinkLight",   Thai = "ไฟสีชมพู",  Price = "ฟรี" },
        { Eng = "VioletLight", Thai = "ไฟสีม่วง",  Price = "ฟรี" }
    },
    Other = {
        { Eng = "Handcuff",           Thai = "กุญแจมือ",       Price = "ฟรี" },
        { Eng = "Boombox",            Thai = "บูมบ็อกซ์",      Price = "100" },
        { Eng = "Spray",              Thai = "สเปรย์",         Price = "500" },
        { Eng = "SlurpeeBig",         Thai = "สเลอปี้ใหญ่",    Price = "50"  },
        { Eng = "Fireflies",          Thai = "หิ่งห้อย",       Price = "12"  },
        { Eng = "Syringe",            Thai = "เข็มฉีดยา",      Price = "30"  },
        { Eng = "Stethoscope",        Thai = "หูฟังแพทย์",     Price = "30"  },
        { Eng = "Pickaxe",            Thai = "จอบ",             Price = "125" },
        { Eng = "CampingLantern",     Thai = "ตะเกียงแคมป์ปิ้ง", Price = "100" },
        { Eng = "Flashlight",         Thai = "ไฟฉาย",          Price = "100" },
        { Eng = "Axe",                Thai = "ขวาน",            Price = "100" },
        { Eng = "PirateFlintockSword",Thai = "ดาบฟลินทล็อคโจรสลัด", Price = "500" },
        { Eng = "Sign",               Thai = "ป้าย",            Price = "100" },
        { Eng = "Rose",               Thai = "ดอกกุหลาบ",      Price = "5" },
        { Eng = "High Five",          Thai = "ไฮไฟว์",          Price = "70" }
    }
}

--// [FIND ITEM — ใช้ Collector ก่อน, Fallback ถ้าไม่มี]
local function findItem(query)
    query = string.lower(query)
    if not query or #query == 0 then return nil, nil end

    -- 🥇 ลองใช้ Collector ก่อน
    local C = getgenv().CollectModuleCore
    if C and C.GetAllItems then
        local all = C:GetAllItems()
        for _, item in ipairs(all) do
            local eng = item.Name or ""
            local thai = item.Thai or eng
            if string.find(string.lower(eng), query, 1, true)
                or string.find(string.lower(thai), query, 1, true) then
                return eng, thai
            end
        end
    end

    -- 🥈 Fallback: ItemDBFallback
    for _, category in pairs(ItemDBFallback) do
        for _, item in ipairs(category) do
            if string.find(string.lower(item.Eng), query, 1, true)
                or string.find(string.lower(item.Thai), query, 1, true) then
                return item.Eng, item.Thai
            end
        end
    end
    return nil, nil
end

--// ═══════════════════════════════════════════════════════════
--// [DUPE ITEM]
--// ═══════════════════════════════════════════════════════════
getgenv().DupeItem = function(itemName)
    local C = EnsureCollector()
    if not C or not C.CollectItemByName then
        printDebug("Collector ไม่พร้อม")
        return false
    end
    if not C.Probed then
        printDebug("Collector ยังไม่ Probe")
        return false
    end

    local ok1, ts = pcall(function() return ReplicatedStorage:WaitForChild("ToolStorage", 3) end)
    if not ok1 or not ts then
        printDebug("ToolStorage ไม่พบ")
        return false
    end
    local ok2, tss = pcall(function() return ts:WaitForChild("ToolsStorage", 2) end)
    if not ok2 or not tss then
        printDebug("ToolsStorage ไม่พบ")
        return false
    end
    local ToolEvent = tss

    local function GetStorage()
        return LocalPlayer:FindFirstChild("storagetools")
    end

    local function GetFreeSlots(storage)
        if not storage then return 0 end
        return math.max(0, 10 - #storage:GetChildren())
    end

    local function GetTargetCount(storage, targetName)
        if not storage then return 0 end
        local count = 0
        for _, child in ipairs(storage:GetChildren()) do
            if child.Name == targetName then count += 1 end
        end
        return count
    end

    local storage = GetStorage()
    if not storage then
        local timeout = 0
        repeat
            task.wait(0.2)
            storage = GetStorage()
            timeout += 0.2
        until storage or timeout >= 5
    end
    if not storage then
        printDebug("ไม่พบ storagetools")
        return false
    end

    local free = GetFreeSlots(storage)
    if free == 0 then
        EO:Notify("EclipseOps", "❌ ช่องเก็บของเต็มแล้ว (10/10)", 3)
        return false
    end

    printDebug("เริ่มดูป์ '" .. itemName .. "' เป้าหมาย " .. free .. " ชิ้น")

    local savedCount = 0
    for i = 1, free do
        local saved = false
        for attempt = 1, 3 do
            pcall(function()
                C:CollectItemByName(itemName)
            end)
            task.wait(0.3)

            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChild(itemName)
                if tool then
                    tool.Parent = LocalPlayer.Backpack
                end
            end

            pcall(function()
                ToolEvent:FireServer("Save", itemName)
            end)

            task.wait(0.5)

            local currentStorage = GetStorage()
            if currentStorage then
                local currentCount = GetTargetCount(currentStorage, itemName)
                if currentCount > savedCount then
                    savedCount = savedCount + 1
                    saved = true
                    break
                end
            end

            task.wait(0.2)
        end
        if not saved then
            printDebug("Save ชิ้นที่ " .. i .. " ไม่สำเร็จ")
        end
    end

    storage = GetStorage()
    if not storage then
        printDebug("ไม่พบ storagetools หลัง Save")
        return false
    end

    local targetCount = GetTargetCount(storage, itemName)
    if targetCount == 0 then
        printDebug("ไม่มี " .. itemName .. " ใน storagetools")
        return false
    end

    for i = 1, targetCount do
        pcall(function()
            ToolEvent:FireServer("Get", itemName)
        end)
        task.wait(0.2)
    end

    EO:Notify("EclipseOps", "✅ ดูป์ '" .. itemName .. "' สำเร็จ! ได้ " .. targetCount .. " ชิ้น 🎉", 4)
    return true
end

--// [!dupe]
EO:AddCommand("dupe", "ดูป์ของตามช่องว่าง", function(input)
    if not input or input == "" then
        EO:Notify("EclipseOps", "❌ ระบุชื่อไอเท็ม! เช่น: dupe ส้มตำ", 3); return
    end

    local C = EnsureCollector()
    if not C or not C.Probed then
        EO:Notify("EclipseOps", "❌ Collector ยังไม่พร้อม!\n(TH2_CMDS1 ต้องโหลดก่อน)", 4)
        return
    end

    local eng, thai = findItem(input)
    if not eng then
        EO:Notify("EclipseOps", "❌ ไม่พบ: " .. input, 4)
        return
    end

    task.spawn(function()
        getgenv().DupeItem(eng)
    end)
end, EO.Ranks.Owner)

--// ═══════════════════════════════════════════════════════════
--// [!droptube] ออโต้ทิ้งธูป
--// ═══════════════════════════════════════════════════════════
getgenv().DropTubeEnabled = false
getgenv()._DropTubeThread = nil

EO:AddCommand("droptube", "เปิด/ปิด ออโต้ทิ้งธูป", function()
    if getgenv().DropTubeEnabled then
        getgenv().DropTubeEnabled = false
        EO:Notify("EclipseOps", "🛑 ปิดออโต้ทิ้งธูปแล้ว", 3)
    else
        getgenv().DropTubeEnabled = true

        local function dropAllTube()
            local char = LocalPlayer.Character
            local bp = LocalPlayer:FindFirstChild("Backpack")

            if bp then
                for _, tool in pairs(bp:GetChildren()) do
                    if tool:IsA("Tool") and string.lower(tool.Name) == "tube" then
                        pcall(function() tool.Parent = workspace end)
                    end
                end
            end

            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") and string.lower(tool.Name) == "tube" then
                        pcall(function() tool.Parent = workspace end)
                    end
                end
            end
        end

        if not getgenv()._DropTubeThread then
            getgenv()._DropTubeThread = task.spawn(function()
                while getgenv().DropTubeEnabled do
                    pcall(dropAllTube)
                    task.wait(0.1)
                end
                getgenv()._DropTubeThread = nil
            end)
        end

        EO:Notify("EclipseOps", "🗑️ เปิดออโต้ทิ้งธูปแล้ว!", 3)
    end
end, EO.Ranks.Owner)

--// ═══════════════════════════════════════════════════════════
--// [!autotube] ออโต้เก็บธูป
--// ═══════════════════════════════════════════════════════════
getgenv().AutoTubeEnabled = false
getgenv()._AutoTubeThread = nil

EO:AddCommand("autotube", "เปิด/ปิด ออโต้เก็บธูป", function()
    local C = EnsureCollector()
    if not C then
        EO:Notify("EclipseOps", "❌ Collector ไม่พร้อม!\n(TH2_CMDS1 ต้องโหลดก่อน)", 4)
        return
    end

    if not C.Probed then
        EO:Notify("EclipseOps", "⏳ Collector ยัง Probe ไม่เสร็จ", 4)
        return
    end

    if getgenv().AutoTubeEnabled then
        getgenv().AutoTubeEnabled = false
        pcall(function() C:SetAutoCollectItem("Tube", false) end)
        if getgenv()._AutoTubeThread then
            getgenv()._AutoTubeThread = nil
        end
        EO:Notify("EclipseOps", "🛑 ปิดออโต้เก็บธูปแล้ว", 3)
    else
        getgenv().AutoTubeEnabled = true

        local ok = pcall(function() C:SetAutoCollectItem("Tube", true) end)
        if not ok then
            if not getgenv()._AutoTubeThread then
                getgenv()._AutoTubeThread = task.spawn(function()
                    while getgenv().AutoTubeEnabled do
                        pcall(function() C:CollectItemByName("Tube") end)
                        RunService.Heartbeat:Wait()
                    end
                    getgenv()._AutoTubeThread = nil
                end)
            end
        end

        EO:Notify("EclipseOps", "🌾 เปิดออโต้เก็บธูปแล้ว!", 3)
    end
end, EO.Ranks.Owner)

print("[EclipseOps] ✅ TH2_CMDS3 v2.1 (" .. (EO.CurrentBranch or "unknown"):upper() .. ") โหลดสำเร็จ!")
return true
