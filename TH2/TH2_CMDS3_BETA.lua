--// 🌒 EclipseOps Command Module — เมืองไทย2 (TH2) v2.1
--// ชุดที่ 3: ดูป์ / จัดการธูป
--// ใช้ Collector v5.2 เป็น Single Source of Truth 100%

local EO = getgenv().EclipseOps
if not EO or not EO.CoreLoaded then
    warn("[EclipseOps] ❌ TH2_CMDS3 — ต้องเรียก EO:Init() ก่อน")
    return
end

--// [ANTI DOUBLE-RUN]
if getgenv()._TH2_CMDS3Loaded then
    warn("[EclipseOps] ⚠️ TH2_CMDS3 โหลดแล้ว — ข้ามซ้ำ")
    return
end
getgenv()._TH2_CMDS3Loaded = true

--// [SERVICES]
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local RunService         = game:GetService("RunService")
local LocalPlayer        = Players.LocalPlayer

--// [UTILS]
local function printDebug(...)
    if EO.EODebug then print("[TH2_CMDS3 DEBUG]", ...) end
end

--// [GET COLLECTOR — รองรับทั้ง 2 ชื่อ]
local function GetCollector()
    return getgenv().CollectModuleCore or getgenv().AutoCollectModule
end

--// [FIND ITEM — ใช้ Collector เท่านั้น (Single Source of Truth)]
local function findItem(query)
    if not query or query == "" then return nil, nil end
    query = string.lower(query)

    local Collector = GetCollector()
    if not Collector or not Collector.GetAllItems then
        printDebug("Collector ไม่พร้อม — findItem ไม่ทำงาน")
        return nil, nil
    end

    for _, item in ipairs(Collector:GetAllItems()) do
        local eng  = item.Name or ""
        local thai = item.Thai or eng
        if string.find(string.lower(eng),  query, 1, true)
           or string.find(string.lower(thai), query, 1, true) then
            return eng, thai
        end
    end

    return nil, nil
end

--// [DUPE ITEM]
getgenv().DupeItem = function(itemName)
    local Collector = GetCollector()
    if not Collector or not Collector.CollectItemByName then
        printDebug("Collector ไม่พร้อม")
        EO:Notify("EclipseOps", "❌ CollectModule ยังไม่พร้อม!", 4)
        return false
    end

    -- ดึง Remote
    local ts = ReplicatedStorage:FindFirstChild("ToolStorage")
    if not ts then
        printDebug("ToolStorage ไม่พบ")
        EO:Notify("EclipseOps", "❌ ToolStorage ไม่พบ!", 4)
        return false
    end
    local tss = ts:FindFirstChild("ToolsStorage")
    if not tss then
        printDebug("ToolsStorage ไม่พบ")
        EO:Notify("EclipseOps", "❌ ToolsStorage ไม่พบ!", 4)
        return false
    end

    -- Helpers
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
            if child.Name == targetName then count = count + 1 end
        end
        return count
    end

    -- รอ storagetools (สูงสุด 5 วิ)
    local storage = GetStorage()
    if not storage then
        local timeout = 0
        repeat
            task.wait(0.2)
            storage = GetStorage()
            timeout = timeout + 0.2
        until storage or timeout >= 5
    end
    if not storage then
        printDebug("ไม่พบ storagetools")
        EO:Notify("EclipseOps", "❌ ไม่พบ storagetools!", 4)
        return false
    end

    -- ตรวจช่องว่าง
    local free = GetFreeSlots(storage)
    if free == 0 then
        EO:Notify("EclipseOps", "❌ ช่องเก็บของเต็ม (10/10)", 3)
        return false
    end

    printDebug("เริ่มดูป์ '" .. itemName .. "' เป้าหมาย " .. free .. " ชิ้น")
    EO:Notify("EclipseOps", "🔮 กำลังดูป์ " .. itemName .. " (" .. free .. " ชิ้น)...", 3)

    local savedCount = 0

    for i = 1, free do
        local saved = false
        for attempt = 1, 3 do
            -- เก็บของ
            pcall(function() Collector:CollectItemByName(itemName) end)
            task.wait(0.3)

            -- ย้ายจากมือเข้า backpack
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChild(itemName)
                if tool then tool.Parent = LocalPlayer.Backpack end
            end

            -- Save
            pcall(function() tss:FireServer("Save", itemName) end)
            task.wait(0.5)

            -- ตรวจสอบ
            local currentStorage = GetStorage()
            if currentStorage then
                local currentCount = GetTargetCount(currentStorage, itemName)
                if currentCount > savedCount then
                    savedCount = savedCount + 1
                    saved = true
                    printDebug("Save ชิ้นที่ " .. i .. " สำเร็จ (รวม " .. savedCount .. ")")
                    break
                end
            end

            task.wait(0.2)
        end
        if not saved then
            printDebug("Save ชิ้นที่ " .. i .. " ล้มเหลว — หยุด")
            break
        end
    end

    -- ดึงของออกจาก storage
    storage = GetStorage()
    if not storage then
        printDebug("storagetools หายไปหลัง Save")
        return false
    end

    local targetCount = GetTargetCount(storage, itemName)
    if targetCount == 0 then
        printDebug("ไม่มี " .. itemName .. " ใน storagetools")
        EO:Notify("EclipseOps", "❌ ดูป์ล้มเหลว — ไม่มีของใน storage", 4)
        return false
    end

    printDebug("ดึง " .. targetCount .. " ชิ้นออกจาก storage")
    for i = 1, targetCount do
        pcall(function() tss:FireServer("Get", itemName) end)
        task.wait(0.2)
    end

    EO:Notify("EclipseOps", "✅ ดูป์ '" .. itemName .. "' สำเร็จ! ได้ " .. targetCount .. " ชิ้น 🎉", 4)
    return true
end

--// [!dupe]
EO:AddCommand("dupe", "ดูป์ของตามช่องว่าง", function(input)
    if not input or input == "" then
        EO:Notify("EclipseOps", "❌ ระบุชื่อไอเท็ม! เช่น: !dupe ส้มตำ", 3)
        return
    end

    local Collector = GetCollector()
    if not Collector or not Collector.GetAllItems or not Collector.CollectItemByName then
        EO:Notify("EclipseOps",
            "❌ Collector ไม่พร้อม!\n💡 พิมพ์ !get ก่อน (โหลด Collector)", 5)
        return
    end

    local eng, thai = findItem(input)
    if not eng then
        EO:Notify("EclipseOps", "❌ ไม่พบ '" .. input .. "' ในรายการไอเท็ม", 4)
        return
    end

    printDebug("Dupe target:", eng, "| Thai:", thai)
    task.spawn(function()
        pcall(function() getgenv().DupeItem(eng) end)
    end)
end, EO.Ranks.Owner)

--// [!droptube] เปิด/ปิด ออโต้ทิ้งธูป
getgenv().DropTubeEnabled = getgenv().DropTubeEnabled or false
getgenv()._DropTubeThread = getgenv()._DropTubeThread or nil

local function dropAllTube()
    local char = LocalPlayer.Character
    local bp   = LocalPlayer:FindFirstChild("Backpack")

    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and string.lower(tool.Name) == "tube" then
                tool.Parent = workspace
            end
        end
    end

    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and string.lower(tool.Name) == "tube" then
                tool.Parent = workspace
            end
        end
    end
end

EO:AddCommand("droptube", "เปิด/ปิด ออโต้ทิ้งธูป", function()
    if getgenv().DropTubeEnabled then
        getgenv().DropTubeEnabled = false
        EO:Notify("EclipseOps", "🛑 ปิดออโต้ทิ้งธูปแล้ว", 3)
        return
    end

    getgenv().DropTubeEnabled = true

    if not getgenv()._DropTubeThread then
        getgenv()._DropTubeThread = task.spawn(function()
            while getgenv().DropTubeEnabled do
                pcall(dropAllTube)
                task.wait(0.1)
            end
            getgenv()._DropTubeThread = nil
            printDebug("DropTube thread ended")
        end)
    end

    EO:Notify("EclipseOps", "🗑️ เปิดออโต้ทิ้งธูปแล้ว!", 3)
end, EO.Ranks.Owner)

--// [!autotube] เปิด/ปิด ออโต้เก็บธูป
getgenv().AutoTubeEnabled = getgenv().AutoTubeEnabled or false
getgenv()._AutoTubeThread = getgenv()._AutoTubeThread or nil

EO:AddCommand("autotube", "เปิด/ปิด ออโต้เก็บธูป", function()
    local Collector = GetCollector()
    if not Collector then
        EO:Notify("EclipseOps", "❌ ยังไม่โหลด CollectCore!\n💡 พิมพ์ !get ก่อน", 4)
        return
    end

    if getgenv().AutoTubeEnabled then
        getgenv().AutoTubeEnabled = false
        pcall(function() Collector:SetAutoCollectItem("Tube", false) end)
        EO:Notify("EclipseOps", "🛑 ปิดออโต้เก็บธูปแล้ว", 3)
        return
    end

    getgenv().AutoTubeEnabled = true

    -- 🥇 ลองใช้ SetSuperFastCollect (ถ้ามี)
    if Collector.SetSuperFastCollect then
        pcall(function() Collector:SetSuperFastCollect("Tube", true) end)
        printDebug("ใช้ SetSuperFastCollect")
    else
        -- 🥈 Fallback: SetAutoCollectItem + custom loop
        pcall(function() Collector:SetAutoCollectItem("Tube", true) end)
        printDebug("fallback: SetAutoCollectItem + custom loop")

        if not getgenv()._AutoTubeThread then
            getgenv()._AutoTubeThread = task.spawn(function()
                while getgenv().AutoTubeEnabled do
                    pcall(function() Collector:CollectItemByName("Tube") end)
                    RunService.Heartbeat:Wait()
                end
                getgenv()._AutoTubeThread = nil
                printDebug("AutoTube thread ended")
            end)
        end
    end

    EO:Notify("EclipseOps", "🌾 เปิดออโต้เก็บธูปแล้ว!", 3)
end, EO.Ranks.Owner)

--// [COMPLETE]
print("[EclipseOps] ✅ TH2_CMDS3 v2.1 (" .. (EO.CurrentBranch or "unknown"):upper() .. ") โหลดสำเร็จ!")
return true
