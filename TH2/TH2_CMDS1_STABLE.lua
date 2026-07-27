--// 🌒 EclipseX Command Module — เมืองไทย2 (TH2) STABLE
local EO = getgenv().EclipseOps
if not EO or not EO.CoreLoaded then
    warn("[EclipseX] ❌ TH2_CMDS1 — ต้องเรียก EO:Init() ก่อน")
    return
end

--// [SERVICES]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

--// [!prefix]
EO:AddCommand("prefix", "เปลี่ยน Prefix", function(newPrefix)
    if not newPrefix or #newPrefix == 0 then
        EO:Notify("EclipseX", "❌ ระบุ Prefix ใหม่ด้วย!", 3)
        return
    end
    EO.Prefix = newPrefix
    EO:Notify("EclipseX", "✅ Prefix เปลี่ยนเป็น: " .. EO.Prefix, 3)
end, EO.Ranks.Normal)

--// [!to — วาร์ปไปหาผู้เล่น (แบบนั่งสมาธิ บายพาส Anti-TP)]
EO:AddCommand("to", "วาร์ปไปหาผู้เล่น (ชื่อบางส่วน)", function(targetName)
    if not targetName or #targetName == 0 then
        EO:Notify("EclipseX", "❌ ระบุชื่อผู้เล่น!", 3); return
    end

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then
        EO:Notify("EclipseX", "❌ ตัวละครยังไม่โหลด!", 3); return
    end

    local hum = myChar:FindFirstChildOfClass("Humanoid")
    if not hum then
        EO:Notify("EclipseX", "❌ ไม่พบ Humanoid!", 3); return
    end

    local target
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and (
            string.find(string.lower(plr.Name), string.lower(targetName), 1, true) or
            string.find(string.lower(plr.DisplayName), string.lower(targetName), 1, true)
        ) then target = plr; break end
    end
    if not target then EO:Notify("EclipseX", "❌ ไม่พบ: " .. targetName, 3); return end

    local tChar = target.Character
    if not tChar or not tChar:FindFirstChild("HumanoidRootPart") then
        EO:Notify("EclipseX", "❌ ตัวละครเป้าหมายไม่โหลด!", 3); return
    end

    -- นั่งสมาธิก่อนข้ามมิติ
    hum.Sit = true
    wait(0.3) -- รอให้เซิร์ฟเวอร์รับรู้สถานะนั่ง

    -- ย้าย CFrame ขณะที่นั่งอยู่
    myChar.HumanoidRootPart.CFrame = tChar.HumanoidRootPart.CFrame + Vector3.new(0, 1, 0)

    -- ลุกขึ้น
    wait(0.1)
    hum.Sit = false

    EO:Notify("EclipseX", "✅ วาร์ปไปหา " .. target.DisplayName .. " แล้ว!", 2)
end, EO.Ranks.Normal)

print("[TH2_CMDS1] ✅ โหลดคำสั่งสำหรับเมืองไทย2 (to แบบนั่งสมาธิ) แล้ว")
return true
