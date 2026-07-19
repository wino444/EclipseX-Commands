--// 🌒 EclipseX Command Module — Basic Commands STABLE (Full Arsenal + UI Hunter + InfJump)
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
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

--// [UTILS]
local function printDebug(...)
    if EO.EODebug then print("[CMDS_BASIC DEBUG]", ...) end
end

local function getRoot(char)
    char = char or LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

--// [FEATURES STATE]
local Features = {
    FullBright = { Enabled = false, Original = {}, Connections = {} },
    NoJump = false,
    NoClip = { Enabled = false, Connection = nil },
    UpsideDown = { Enabled = false, Conn = nil },
    TPWalk = { Enabled = false, Speed = 200, Conn = nil },
    InfiniteJump = { Enabled = false, Conn = nil },  -- เพิ่มตรงนี้
    ESP = {
        PlayersEnabled = false,
        NPCsEnabled = false,
        PlayerDrawings = {},
        NPCDrawings = {},
        Loop = nil
    },
    NpcHunter = {
        Speed = 20,
        HuntV2 = false,
        Connection = nil,
        ActivePaths = {}
    }
}
getgenv().CMDS_BASIC_Features = Features

--// ====================== Hunter V2 Logic ======================
local function updateHunterV2()
    for _, npc in Workspace:GetChildren() do
        if not npc:IsA("Model") then continue end
        local hum = npc:FindFirstChild("Humanoid")
        local root = npc:FindFirstChild("HumanoidRootPart")
        if not (hum and root) or Players:GetPlayerFromCharacter(npc) then continue end
        hum.WalkSpeed = Features.NpcHunter.Speed
        local target, best = nil, math.huge
        for _, plr in Players:GetPlayers() do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local d = (root.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                if d < best then best = d; target = plr end
            end
        end
        if not target then continue end
        local key = tostring(npc)
        if not Features.NpcHunter.ActivePaths[key] or tick() - (Features.NpcHunter.ActivePaths[key].Last or 0) > 1.5 then
            local path = PathfindingService:CreatePath({AgentRadius = 3, AgentHeight = 6, AgentCanJump = true})
            path:ComputeAsync(root.Position, target.Character.HumanoidRootPart.Position)
            if path.Status == Enum.PathStatus.Success then
                Features.NpcHunter.ActivePaths[key] = {Waypoints = path:GetWaypoints(), Index = 2, Last = tick()}
            end
        end
        local data = Features.NpcHunter.ActivePaths[key]
        if data and data.Index <= #data.Waypoints then
            local wp = data.Waypoints[data.Index]
            hum:MoveTo(wp.Position)
            if (root.Position - wp.Position).Magnitude < 6 then
                data.Index += 1
                if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
            end
            if data.Index > #data.Waypoints then Features.NpcHunter.ActivePaths[key] = nil end
        end
    end
end

local function setHunterV2Enabled(state)
    Features.NpcHunter.HuntV2 = state
    if state then
        if Features.NpcHunter.Connection then Features.NpcHunter.Connection:Disconnect() end
        Features.NpcHunter.Connection = RunService.Heartbeat:Connect(updateHunterV2)
    else
        if Features.NpcHunter.Connection then
            Features.NpcHunter.Connection:Disconnect()
            Features.NpcHunter.Connection = nil
        end
        Features.NpcHunter.ActivePaths = {}
    end
end

--// ====================== UI Hunter ======================
local HunterUI = nil

local function createHunterUI()
    if HunterUI then return end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EclipseX_HunterUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 120)
    frame.Position = UDim2.new(0.5, -125, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 10)
    frameCorner.Parent = frame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(80, 0, 180)
    frameStroke.Thickness = 2
    frameStroke.Parent = frame

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(80, 0, 180)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -30, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "💀 Hunter System"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.Activated:Connect(function()
        screenGui:Destroy()
        HunterUI = nil
    end)

    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -20, 0, 20)
    speedLabel.Position = UDim2.new(0, 10, 0, 40)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "⚡ ความเร็ว: 20"
    speedLabel.TextColor3 = Color3.new(1, 1, 1)
    speedLabel.Font = Enum.Font.Code
    speedLabel.TextSize = 14
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 10)
    sliderBg.Position = UDim2.new(0, 10, 0, 65)
    sliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 5)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0, 20, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(120, 0, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 5)

    local sliderThumb = Instance.new("TextButton")
    sliderThumb.Size = UDim2.new(0, 20, 0, 20)
    sliderThumb.Position = UDim2.new(0, -10, 0.5, -10)
    sliderThumb.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
    sliderThumb.Text = ""
    sliderThumb.BorderSizePixel = 0
    sliderThumb.Parent = sliderBg
    Instance.new("UICorner", sliderThumb).CornerRadius = UDim.new(1, 0)

    local function updateSliderFromPosition(input)
        local relativeX = input.Position.X - sliderBg.AbsolutePosition.X
        local width = sliderBg.AbsoluteSize.X
        local percent = math.clamp(relativeX / width, 0, 1)
        local speed = math.floor(16 + percent * (400 - 16))
        Features.NpcHunter.Speed = speed
        speedLabel.Text = "⚡ ความเร็ว: " .. speed
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderThumb.Position = UDim2.new(percent, -10, 0.5, -10)
    end

    sliderThumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local moveConn, releaseConn
            moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    updateSliderFromPosition(moveInput)
                end
            end)
            releaseConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    moveConn:Disconnect()
                    releaseConn:Disconnect()
                end
            end)
        end
    end)

    local initialPercent = (20 - 16) / (400 - 16)
    sliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
    sliderThumb.Position = UDim2.new(initialPercent, -10, 0.5, -10)

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -20, 0, 30)
    toggleBtn.Position = UDim2.new(0, 10, 0, 85)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    toggleBtn.Text = "HUNTER V2: OFF"
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.Parent = frame
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

    toggleBtn.Activated:Connect(function()
        Features.NpcHunter.HuntV2 = not Features.NpcHunter.HuntV2
        setHunterV2Enabled(Features.NpcHunter.HuntV2)
        if Features.NpcHunter.HuntV2 then
            toggleBtn.Text = "HUNTER V2: ON"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        else
            toggleBtn.Text = "HUNTER V2: OFF"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        end
    end)

    HunterUI = screenGui
end

EO:AddCommand("uihunter", "เปิด/ปิด UI Hunter System", function()
    if HunterUI then
        HunterUI:Destroy()
        HunterUI = nil
        EO:Notify("Hunter UI", "ปิดแล้ว", 2)
    else
        createHunterUI()
        EO:Notify("Hunter UI", "เปิดแล้ว!", 2)
    end
end, EO.Ranks.Normal)

--// ====================== คำสั่งพื้นฐานทั้งหมด ======================

EO:AddCommand("prefix", "เปลี่ยน Prefix", function(newPrefix)
    if not newPrefix or #newPrefix == 0 then
        EO:Notify("EclipseX", "❌ ระบุ Prefix ใหม่ด้วย!", 3)
        return
    end
    EO.Prefix = newPrefix
    EO:Notify("EclipseX", "✅ Prefix เปลี่ยนเป็น: " .. EO.Prefix, 3)
end, EO.Ranks.Normal)

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

EO:AddCommand("camerafix", "Fix Camera + Unlock", function()
    Workspace.CurrentCamera:Remove()
    wait(0.1)
    repeat wait() until LocalPlayer.Character
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

EO:AddCommand("fullbright", "Fullbright [on/off]", function(state)
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

EO:AddCommand("upsidedown", "Upside Down [on/off]", function(state)
    state = state and state:lower()
    local ud = Features.UpsideDown
    if state == "on" then ud.Enabled = true elseif state == "off" then ud.Enabled = false else ud.Enabled = not ud.Enabled end

    if ud.Enabled then
        local c = LocalPlayer.Character
        if not c or not c:FindFirstChild("HumanoidRootPart") then
            EO:Notify("UpsideDown", "❌ ตัวละครไม่พร้อม", 2)
            return
        end
        local hrp0 = c:FindFirstChild("HumanoidRootPart")
        local hrp1 = hrp0:Clone()
        c.Parent = nil
        hrp0.Parent = hrp1
        hrp0.RootJoint.Part0 = nil
        hrp1.Parent = c
        c.Parent = Workspace
        hrp0.Transparency = 0.5

        if ud.Conn then ud.Conn:Disconnect() end
        ud.Conn = RunService.Heartbeat:Connect(function()
            if not ud.Enabled or not c.Parent then
                ud.Conn:Disconnect()
                ud.Enabled = false
                return
            end
            hrp0.CFrame = hrp1.CFrame
            hrp0.Orientation = hrp0.Orientation + Vector3.new(0, 0, 180)
            hrp0.Position = hrp0.Position - Vector3.new(0, 1, 0)
            hrp0.Velocity = hrp1.Velocity
        end)
        EO:Notify("UpsideDown", "เปิดแล้ว!", 2)
    else
        if ud.Conn then ud.Conn:Disconnect(); ud.Conn = nil end
        EO:Notify("UpsideDown", "ปิดแล้ว", 2)
    end
end, EO.Ranks.Normal)

EO:AddCommand("unupsidedown", "ปิด Upside Down", function()
    Features.UpsideDown.Enabled = false
    if Features.UpsideDown.Conn then Features.UpsideDown.Conn:Disconnect(); Features.UpsideDown.Conn = nil end
    EO:Notify("UpsideDown", "ปิดแล้ว", 2)
end, EO.Ranks.Normal)

EO:AddCommand("nojumpbypass", "Bypass No-Jump [on/off]", function(state)
    state = state and state:lower()
    if state == "on" then Features.NoJump = true elseif state == "off" then Features.NoJump = false else Features.NoJump = not Features.NoJump end
    if Features.NoJump then
        coroutine.wrap(function()
            while Features.NoJump do
                wait(0.5)
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

EO:AddCommand("noclip", "NoClip [on/off]", function(state)
    state = state and state:lower()
    local nc = Features.NoClip
    if state == "on" then nc.Enabled = true elseif state == "off" then nc.Enabled = false else nc.Enabled = not nc.Enabled end

    if nc.Enabled then
        local function enableNoclip()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
        enableNoclip()
        if nc.Connection then nc.Connection:Disconnect() end
        nc.Connection = RunService.Stepped:Connect(function()
            if not nc.Enabled then return end
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end)
        LocalPlayer.CharacterAdded:Connect(function()
            if nc.Enabled then wait(0.1); enableNoclip() end
        end)
        EO:Notify("NoClip", "เปิดแล้ว! ทะลุกำแพง 💨", 2)
    else
        if nc.Connection then nc.Connection:Disconnect(); nc.Connection = nil end
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end
            end
        end
        EO:Notify("NoClip", "ปิดแล้ว", 2)
    end
end, EO.Ranks.Normal)

EO:AddCommand("speed", "ตั้ง WalkSpeed <16-500>", function(val)
    val = tonumber(val) or 16
    if val < 1 then val = 16 elseif val > 500 then val = 500 end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = val
        EO:Notify("Speed", "WalkSpeed = " .. val, 2)
    else
        EO:Notify("Speed", "❌ ตัวละครไม่พร้อม", 2)
    end
end, EO.Ranks.Normal)

EO:AddCommand("jump", "ตั้ง JumpPower <50-400>", function(val)
    val = tonumber(val) or 50
    if val < 0 then val = 50 elseif val > 400 then val = 400 end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = val
        EO:Notify("Jump", "JumpPower = " .. val, 2)
    else
        EO:Notify("Jump", "❌ ตัวละครไม่พร้อม", 2)
    end
end, EO.Ranks.Normal)

EO:AddCommand("infjump", "Infinite Jump — กระโดดอัตโนมัติ [on/off]", function(state)
    state = state and state:lower()
    local ij = Features.InfiniteJump
    if state == "on" then ij.Enabled = true elseif state == "off" then ij.Enabled = false else ij.Enabled = not ij.Enabled end

    if ij.Enabled then
        if ij.Conn then ij.Conn:Disconnect() end
        ij.Conn = RunService.Heartbeat:Connect(function()
            if not ij.Enabled then return end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum and hum:GetState() == Enum.HumanoidStateType.Landed then
                hum.Jump = true
            end
        end)
        EO:Notify("Infinite Jump", "เปิดแล้ว! กระโดดไม่หยุด 🦘", 2)
    else
        if ij.Conn then ij.Conn:Disconnect(); ij.Conn = nil end
        EO:Notify("Infinite Jump", "ปิดแล้ว", 2)
    end
end, EO.Ranks.Normal)

EO:AddCommand("tpwalk", "TPWalk <ความเร็ว/off>", function(speed)
    if speed == "off" then
        Features.TPWalk.Enabled = false
        if Features.TPWalk.Conn then Features.TPWalk.Conn:Disconnect(); Features.TPWalk.Conn = nil end
        EO:Notify("TPWalk", "ปิดแล้ว", 2)
        return
    end
    speed = tonumber(speed) or 200
    Features.TPWalk.Speed = speed
    Features.TPWalk.Enabled = true
    if Features.TPWalk.Conn then Features.TPWalk.Conn:Disconnect() end
    Features.TPWalk.Conn = RunService.Stepped:Connect(function(_, delta)
        if Features.TPWalk.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local hum = LocalPlayer.Character.Humanoid
            if hum.MoveDirection.Magnitude > 0 then
                LocalPlayer.Character:TranslateBy(hum.MoveDirection * Features.TPWalk.Speed * delta)
            end
        end
    end)
    EO:Notify("TPWalk", "เปิดความเร็ว " .. speed, 2)
end, EO.Ranks.Normal)

-- ESP ส่วนเดิม
local function createPlayerESP(plr)
    if plr == LocalPlayer then return end
    pcall(function()
        local Text = Drawing.new("Text")
        Text.Visible = false; Text.Center = true; Text.Outline = true; Text.Font = 2; Text.Size = 18
        Text.Color = Color3.fromRGB(255, 50, 50); Text.OutlineColor = Color3.new(0,0,0)
        Features.ESP.PlayerDrawings[plr] = Text
    end)
end

local function removePlayerESP(plr)
    pcall(function()
        if Features.ESP.PlayerDrawings[plr] then
            Features.ESP.PlayerDrawings[plr]:Remove()
            Features.ESP.PlayerDrawings[plr] = nil
        end
    end)
end

local function createNPCESP(npc)
    if not npc or not npc:FindFirstChild("HumanoidRootPart") or not npc:FindFirstChild("Humanoid") then return end
    if Players:GetPlayerFromCharacter(npc) then return end
    pcall(function()
        local Text = Drawing.new("Text")
        Text.Visible = false; Text.Center = true; Text.Outline = true; Text.Font = 2; Text.Size = 19
        Text.Color = Color3.fromRGB(0, 191, 255); Text.OutlineColor = Color3.new(0,0,0)
        Features.ESP.NPCDrawings[npc] = Text
    end)
end

local function removeNPCESP(npc)
    pcall(function()
        if Features.ESP.NPCDrawings[npc] then
            Features.ESP.NPCDrawings[npc]:Remove()
            Features.ESP.NPCDrawings[npc] = nil
        end
    end)
end

local function updateESP()
    local myRoot = getRoot()
    if not myRoot then return end
    local myPos = myRoot.Position
    local cam = Workspace.CurrentCamera

    if Features.ESP.PlayersEnabled then
        for plr, drawing in pairs(Features.ESP.PlayerDrawings) do
            pcall(function()
                if plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local headPos = plr.Character.Head.Position + Vector3.new(0, 3, 0)
                    local vector, onScreen = cam:WorldToViewportPoint(headPos)
                    local dist = math.floor((myPos - plr.Character.HumanoidRootPart.Position).Magnitude)
                    if onScreen and dist < 1000 then
                        drawing.Visible = true
                        drawing.Text = "👤 " .. plr.Name .. "\n[" .. dist .. " studs]"
                        drawing.Position = Vector2.new(vector.X, vector.Y)
                    else drawing.Visible = false end
                else drawing.Visible = false end
            end)
        end
    else
        for _, drawing in pairs(Features.ESP.PlayerDrawings) do pcall(function() drawing.Visible = false end) end
    end

    if Features.ESP.NPCsEnabled then
        for npc, drawing in pairs(Features.ESP.NPCDrawings) do
            pcall(function()
                if npc.Parent and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                    local root = npc.HumanoidRootPart
                    local headPos = root.Position + Vector3.new(0, 3.5, 0)
                    local vector, onScreen = cam:WorldToViewportPoint(headPos)
                    local dist = math.floor((myPos - root.Position).Magnitude)
                    if onScreen and dist < 1000 then
                        drawing.Visible = true
                        drawing.Text = "🩸 " .. (npc.Name:gsub("%.$","")) .. "\n[" .. dist .. " studs]"
                        drawing.Position = Vector2.new(vector.X, vector.Y)
                    else drawing.Visible = false end
                else
                    drawing.Visible = false
                    if not npc.Parent then removeNPCESP(npc) end
                end
            end)
        end
    else
        for _, drawing in pairs(Features.ESP.NPCDrawings) do pcall(function() drawing.Visible = false end) end
    end
end

for _, plr in Players:GetPlayers() do createPlayerESP(plr) end
Players.PlayerAdded:Connect(createPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)
Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
        wait(0.5)
        if obj.Parent and not Players:GetPlayerFromCharacter(obj) then createNPCESP(obj) end
    end
end)
Workspace.DescendantRemoving:Connect(function(obj)
    if Features.ESP.NPCDrawings[obj] then removeNPCESP(obj) end
end)

EO:AddCommand("espplayers", "ESP ผู้เล่น [on/off]", function(state)
    state = state and state:lower()
    if state == "on" then Features.ESP.PlayersEnabled = true elseif state == "off" then Features.ESP.PlayersEnabled = false else Features.ESP.PlayersEnabled = not Features.ESP.PlayersEnabled end
    if Features.ESP.PlayersEnabled or Features.ESP.NPCsEnabled then
        if not Features.ESP.Loop then Features.ESP.Loop = RunService.RenderStepped:Connect(updateESP) end
    else
        if Features.ESP.Loop then Features.ESP.Loop:Disconnect(); Features.ESP.Loop = nil end
    end
    EO:Notify("ESP", "ผู้เล่น " .. (Features.ESP.PlayersEnabled and "เปิด" or "ปิด"), 2)
end, EO.Ranks.Normal)

EO:AddCommand("espnpcs", "ESP NPC [on/off]", function(state)
    state = state and state:lower()
    if state == "on" then Features.ESP.NPCsEnabled = true elseif state == "off" then Features.ESP.NPCsEnabled = false else Features.ESP.NPCsEnabled = not Features.ESP.NPCsEnabled end
    if Features.ESP.NPCsEnabled then
        for _, obj in Workspace:GetDescendants() do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj) then
                createNPCESP(obj)
            end
        end
        if not Features.ESP.Loop then Features.ESP.Loop = RunService.RenderStepped:Connect(updateESP) end
    else
        for _, drawing in pairs(Features.ESP.NPCDrawings) do pcall(function() drawing.Visible = false end) end
        if not Features.ESP.PlayersEnabled and Features.ESP.Loop then Features.ESP.Loop:Disconnect(); Features.ESP.Loop = nil end
    end
    EO:Notify("ESP", "NPC " .. (Features.ESP.NPCsEnabled and "เปิด" or "ปิด"), 2)
end, EO.Ranks.Normal)

print("[CMDS_BASIC] ✅ โหลดคำสั่งพื้นฐานทั้งหมด (Infinite Jump, UI Hunter, ESP, NoClip...) สำเร็จ")
return true
