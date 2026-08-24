--// 🌒 EclipseX Tube Library (getgenv Edition) — เมืองไทย2
--// ทำงานเบื้องหลัง ไม่มีการแจ้งเตือน
--// ใช้: loadstring(game:HttpGet("URL"))()
--//      getgenv().TubeLibrary:Init()
--//      getgenv().TubeLibrary:ToggleAutoCollect()
--//      getgenv().TubeLibrary:CollectTube()

local EO = getgenv().EclipseOps
if not EO or not EO.CoreLoaded then
    warn("[TubeLibrary] ❌ ต้องเรียก EO:Init() ก่อน")
    return
end

if getgenv().TubeLibraryLoaded then
    print("[TubeLibrary] ⚠️ โหลดแล้ว — ข้ามซ้ำ!")
    return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local TubeLibrary = {
    Initialized = false,
    AutoCollectEnabled = false,
    AutoDropEnabled = false,
    Init = nil,
    ToggleAutoCollect = nil,
    ToggleAutoDrop = nil,
    CollectTube = nil,
    DropTube = nil,
    Shutdown = nil,
}

--// [UTILS]
local function getChar()
    return LocalPlayer.Character
end

local function getBackpack()
    return LocalPlayer:FindFirstChild("Backpack")
end

local function printDebug(...)
    if EO.EODebug then print("[TubeLibrary]", ...) end
end

-- เก็บ Tube โดยใช้ CollectModule (เงียบ) — ไม่มีเงื่อนไขตรวจสอบอีกต่อไป
local function collectTubeOnce()
    if getgenv().AutoCollectModule then
        return getgenv().AutoCollectModule.CollectItemByName("Tube")
    else
        return false
    end
end

-- ทิ้ง Tube จาก Backpack/ตัวละคร (เงียบ)
local function dropTubeOnce()
    local targetName = "Tube"
    local backpack = getBackpack()
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == targetName then
                tool.Parent = workspace
                return true
            end
        end
    end
    local char = getChar()
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == targetName then
                tool.Parent = workspace
                return true
            end
        end
    end
    return false
end

--// [Auto loops]
local function autoCollectLoop()
    while TubeLibrary.AutoCollectEnabled do
        collectTubeOnce()
        wait(0.5)
    end
end

local function autoDropLoop()
    while TubeLibrary.AutoDropEnabled do
        dropTubeOnce()
        wait(0.5)
    end
end

--// [API]
function TubeLibrary:Init()
    if self.Initialized then return end
    self.Initialized = true
    getgenv().TubeLibrary = self
    printDebug("พร้อมทำงาน")
end

function TubeLibrary:ToggleAutoCollect()
    self.AutoCollectEnabled = not self.AutoCollectEnabled
    if self.AutoCollectEnabled then
        coroutine.wrap(autoCollectLoop)()
        printDebug("Auto Collect เปิด")
    else
        printDebug("Auto Collect ปิด")
    end
end

function TubeLibrary:ToggleAutoDrop()
    self.AutoDropEnabled = not self.AutoDropEnabled
    if self.AutoDropEnabled then
        coroutine.wrap(autoDropLoop)()
        printDebug("Auto Drop เปิด")
    else
        printDebug("Auto Drop ปิด")
    end
end

function TubeLibrary:CollectTube()
    return collectTubeOnce()
end

function TubeLibrary:DropTube()
    return dropTubeOnce()
end

function TubeLibrary:Shutdown()
    self.AutoCollectEnabled = false
    self.AutoDropEnabled = false
    getgenv().TubeLibrary = nil
    getgenv().TubeLibraryLoaded = false
    printDebug("ปิดระบบแล้ว")
end

--// [FINALIZE]
getgenv().TubeLibraryLoaded = true
getgenv().TubeLibrary = TubeLibrary
