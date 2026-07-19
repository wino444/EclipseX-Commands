--// 🌒 EclipseX Command Module — Basic Commands STABLE
local EO = getgenv().EclipseOps
if not EO or not EO.CoreLoaded then
    warn("[EclipseX] ❌ CMDS_BASIC — ต้องเรียก EO:Init() ก่อน")
    return
end

--// [SERVICES]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

--// [UTILS]
local function printDebug(...)
    if EO.EODebug then print("[CMDS_BASIC DEBUG]", ...) end
end

--// [FEATURES STATE]
local Features = {
    FullBright = { Enabled = false, Original = {}, Connections = {} },
    NoJump = false,
}

--// ====================== [!prefix] ======================
EO:AddCommand("prefix", "เปลี่ยน Prefix", function(newPrefix)
    if not newPrefix or #newPrefix == 0 then
        EO:Notify("EclipseX", "❌ ระบุ Prefix ใหม่ด้วย!", 3)
        return
    end
    EO.Prefix = newPrefix
    EO:Notify("EclipseX", "✅ Prefix เปลี่ยนเป็น: " .. EO.Prefix, 3)
end, EO.Ranks.Normal)

--// ====================== [!rankme] ======================
EO:AddCommand("rankme", "ดูยศของตัวเอง + เวลาที่เหลือ", function()
    local realRank = EO.RankDB.GetRankByName(LocalPlayer.Name)
    local effectiveRank = EO:SafeGetPlayerRank(LocalPlayer)
    local rankText = effectiveRank == EO.Ranks.Owner and "👑 Owner"
        or effectiveRank == EO.Ranks.VIP and "⭐ VIP"
        or "👤 Normal"

    local source = ""
    local vipData = EO.TempVIP[LocalPlayer.UserId]
    if realRank >= EO.Ranks.VIP then
        source = "ถาวร (RankDB)"
    elseif vipData then
        if type(vipData) == "number" then
            local remaining = vipData - os.time()
            if remaining > 0 then
                local mins = math.floor(remaining/60)
                local secs = remaining % 60
                source = "TempVIP ⏳ เหลือ "..(mins>0 and mins.." นาที " or "")..secs.." วิ"
            else
                EO.TempVIP[LocalPlayer.UserId] = nil
                source = "TempVIP หมดอายุแล้ว"
            end
        else
            source = "TempVIP ✅ (หายตอนออกเกม)"
        end
    else
        source = "ไม่มีสิทธิ์พิเศษ"
    end

    EO:Notify("EclipseX", "ยศ: " .. rankText .. "\n" .. source, 6)
end, EO.Ranks.Normal)

--// ====================== [!to] — วาร์ปไปหาผู้เล่น ======================
EO:AddCommand("to", "วาร์ปไปหาผู้เล่น (ชื่อบางส่วน)", function(targetName)
    if not targetName or #targetName == 0 then
        EO:Notify("EclipseX", "❌ ระบุชื่อผู้เล่น!", 3); return
    end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then
        EO:Notify("EclipseX", "❌ ตัวละครยังไม่โหลด!", 3); return
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
    myChar.HumanoidRootPart.CFrame = tChar.HumanoidRootPart.CFrame
    EO:Notify("EclipseX", "✅ วาร์ปไปหา " .. target.DisplayName .. " แล้ว!", 2)
end, EO.Ranks.Normal)

--// ====================== [!camerafix] — Fix Camera + Unlock ======================
EO:AddCommand("camerafix", "Fix Camera + Unlock — ซ่อมกล้อง + ปลดล็อค", function()
    Workspace.CurrentCamera:Remove()
    task.wait(0.1)
    repeat task.wait() until LocalPlayer.Character
    local cam = Workspace.CurrentCamera
    cam.CameraSubject = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    cam.CameraType = Enum.CameraType.Custom
    LocalPlayer.CameraMinZoomDistance = 0.5
    LocalPlayer.CameraMaxZoomDistance = math.huge
    LocalPlayer.CameraMode = Enum.CameraMode.Classic
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
        LocalPlayer.Character.Head.Anchored = false
    end
    EO:Notify("Camera", "ปลดล็อค+ซ่อมเสร็จ!", 3)
end, EO.Ranks.Normal)

--// ====================== [!fullbright] ======================
EO:AddCommand("fullbright", "Fullbright — เปิด/ปิด Fullbright [on/off]", function(state)
    state = state and state:lower()
    local fb = Features.FullBright
    if state == "on" then fb.Enabled = true elseif state == "off" then fb.Enabled = false else fb.Enabled = not fb.Enabled end

    if fb.Enabled then
        fb.Original = {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows,
            Ambient = Lighting.Ambient
        }
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 786543
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178,178,178)

        for _, conn in ipairs(fb.Connections) do conn:Disconnect() end
        fb.Connections = {}
        local function protect(prop, val)
            table.insert(fb.Connections, Lighting:GetPropertyChangedSignal(prop):Connect(function()
                if fb.Enabled then Lighting[prop] = val end
            end))
        end
        protect("Brightness", 1)
        protect("ClockTime", 12)
        protect("FogEnd", 786543)
        protect("GlobalShadows", false)
        protect("Ambient", Color3.fromRGB(178,178,178))
        EO:Notify("Fullbright", "เปิดแล้ว!", 2)
    else
        for _, conn in ipairs(fb.Connections) do conn:Disconnect() end
        fb.Connections = {}
        if fb.Original.Brightness then
            Lighting.Brightness = fb.Original.Brightness
            Lighting.ClockTime = fb.Original.ClockTime
            Lighting.FogEnd = fb.Original.FogEnd
            Lighting.GlobalShadows = fb.Original.GlobalShadows
            Lighting.Ambient = fb.Original.Ambient
        end
        EO:Notify("Fullbright", "ปิดแล้ว", 2)
    end
end, EO.Ranks.Normal)

--// ====================== [!upsidedown] ======================
EO:AddCommand("upsidedown", "Upside Down", function()
    local c = LocalPlayer.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local hrp0 = c:FindFirstChild("HumanoidRootPart")
    local hrp1 = hrp0:Clone()
    c.Parent = nil
    hrp0.Parent = hrp1
    hrp0.RootJoint.Part0 = nil
    hrp1.Parent = c
    c.Parent = Workspace
    hrp0.Transparency = 0.5
    local h = RunService.Heartbeat
    while h:Wait() and c and c.Parent do
        hrp0.CFrame = hrp1.CFrame
        hrp0.Orientation = hrp0.Orientation + Vector3.new(0, 0, 180)
        hrp0.Position = hrp0.Position - Vector3.new(0, 1, 0)
        hrp0.Velocity = hrp1.Velocity
    end
end, EO.Ranks.Normal)

--// ====================== [!nojumpbypass] — Bypass No-Jump (Remove NoJump) ======================
EO:AddCommand("nojumpbypass", "Bypass No-Jump — บายพาสห้ามกระโดด [on/off]", function(state)
    state = state and state:lower()
    if state == "on" then Features.NoJump = true elseif state == "off" then Features.NoJump = false else Features.NoJump = not Features.NoJump end
    if Features.NoJump then
        coroutine.wrap(function()
            while Features.NoJump do
                task.wait(0.5)
                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                if char then
                    local nojump = char:FindFirstChild("NoJump") or Workspace:FindFirstChild("NoJump")
                    if nojump then nojump:Destroy() end
                end
            end
        end)()
        EO:Notify("NoJumpBypass", "เปิดแล้ว!", 2)
    else
        EO:Notify("NoJumpBypass", "ปิดแล้ว", 2)
    end
end, EO.Ranks.Normal)

print("[CMDS_BASIC] ✅ โหลดคำสั่งพื้นฐานทั้ง 7 ตัวสำเร็จ")

return true
