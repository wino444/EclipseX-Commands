--// 🌒 EclipseX Command Module — Identity Fraud Horror (PlaceId 7304314747) STABLE
local EO = getgenv().EclipseOps
if not EO or not EO.CoreLoaded then
    warn("[EclipseX] ❌ IFH_CMDS1 — ต้องเรียก EO:Init() ก่อน")
    return
end

--// [SERVICES]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

--// [UTILS]
local function printDebug(...)
    if EO.EODebug then print("[IFH DEBUG]", ...) end
end

local function getChar()
    return LocalPlayer and LocalPlayer.Character
end

local function getHum()
    local char = getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot(char)
    char = char or getChar()
    return char and (
        char:FindFirstChild("HumanoidRootPart") or
        char:FindFirstChild("Torso") or
        char:FindFirstChild("UpperTorso")
    )
end

--// [FEATURES STATE]
local Features = {
    FullBright = { Enabled = false, Original = {}, Connections = {} },
    NoJump = false,
    TPWalk = { Enabled = false, Speed = 200, Conn = nil },
    AntiKick = { Hooked = false, OldNamecall = nil },
    AntiFling = { Connections = {} },
    AntiSit = { Connection = nil },
    AntiCFrameTP = { Enabled = false, Connections = {}, RenderConn = nil, LastCFrames = {} },
    AntiVoid = { Connection = nil },
    AntiVoid2 = { OriginalFPDH = nil },
    AntiFlingHard = { On = false, Connections = {} },
    SpawnPoint = nil,
    SpawnConnection = nil,
    ESP = { PlayersEnabled = false, NPCsEnabled = false, PlayerDrawings = {}, NPCDrawings = {}, Loop = nil },
    NpcHunter = {
        Speed = 20,
        HuntV1 = false, HuntV2 = false, HuntV3 = false,
        Connections = {},
        ActivePaths = {},
        FollowTarget = nil,
        FollowEnabled = false,
        GodFollowConn = nil
    },
    AutoRejoinConn = nil
}
getgenv().IFHFeatures = Features

--// ====================== คำสั่งพื้นฐาน ======================

--// [!prefix]
EO:AddCommand("prefix", "เปลี่ยน Prefix", function(newPrefix)
    if not newPrefix or #newPrefix == 0 then
        EO:Notify("EclipseX", "❌ ระบุ Prefix ใหม่ด้วย!", 3)
        return
    end
    EO.Prefix = newPrefix
    EO:Notify("EclipseX", "✅ Prefix เปลี่ยนเป็น: " .. EO.Prefix, 3)
end, EO.Ranks.Normal)

--// [!rankme]
EO:AddCommand("rankme", "ดูยศของตัวเอง + เวลาที่เหลือ", function()
    local realRank = EO.RankDB.GetRankByName(LocalPlayer.Name)
    local effectiveRank = EO.SafeGetPlayerRank(LocalPlayer)
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

--// [!to — วาร์ปไปหาผู้เล่น]
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

--// ====================== คำสั่งกล้อง ======================
EO:AddCommand("camerafix", "ซ่อมกล้อง + ปลดล็อค", function()
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
    EO:Notify("กล้อง", "ปลดล็อค+ซ่อมเสร็จ!", 3)
end, EO.Ranks.Normal)

--// ====================== คำสั่ง Fullbright ======================
EO:AddCommand("fullbright", "เปิด/ปิด Fullbright [on/off]", function(state)
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

--// ====================== คำสั่งตัวละคร ======================
EO:AddCommand("walkspeed", "ตั้ง WalkSpeed <ค่า>", function(val)
    val = tonumber(val) or 16
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
        EO:Notify("WalkSpeed", "ตั้งเป็น "..val, 2)
    end
end, EO.Ranks.Normal)

EO:AddCommand("jumppower", "ตั้ง JumpPower <ค่า>", function(val)
    val = tonumber(val) or 50
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = val
        EO:Notify("JumpPower", "ตั้งเป็น "..val, 2)
    end
end, EO.Ranks.Normal)

EO:AddCommand("bypassnojump", "บายพาสห้ามกระโดด [on/off]", function(state)
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
        EO:Notify("NoJump", "บายพาสเปิดแล้ว!", 2)
    else
        EO:Notify("NoJump", "ปิดแล้ว", 2)
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
    EO:Notify("TPWalk", "เปิดความเร็ว "..speed, 2)
end, EO.Ranks.Normal)

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
        hrp0.Orientation += Vector3.new(0, 0, 180)
        hrp0.Position -= Vector3.new(0, 1, 0)
        hrp0.Velocity = hrp1.Velocity
    end
end, EO.Ranks.Normal)

EO:AddCommand("netpass", "NetPass ownership", function()
    if not getgenv().Network then
        getgenv().Network = {
            BaseParts = {}, FakeConnections = {}, Connections = {}, Output = { Enabled = true, Prefix = "[NETWORK] ", Send = function(t,m,b) if getgenv().Network.Output.Enabled then t(getgenv().Network.Output.Prefix..m) end end },
            LostParts = {}, CharacterRelative = true, LastCharacter = nil, TryKeep = true,
            PartOwnership = { PreMethodSettings = {}, Enabled = false }
        }
        function getgenv().Network.RetainPart(Part, Silent, ReturnFakePart)
            if not getgenv().Network.PartOwnership.Enabled then return end
            if not Part:IsDescendantOf(Workspace) then return false end
            if not table.find(getgenv().Network.BaseParts, Part) then
                table.insert(getgenv().Network.BaseParts, Part)
                Part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
            end
        end
        function getgenv().Network.RemovePart(Part)
            local idx = table.find(getgenv().Network.BaseParts, Part)
            if idx then table.remove(getgenv().Network.BaseParts, idx) end
        end
        getgenv().Network.PartOwnership.Enable = coroutine.create(function()
            if not getgenv().Network.PartOwnership.Enabled then
                getgenv().Network.PartOwnership.Enabled = true
                LocalPlayer.ReplicationFocus = Workspace
                getgenv().Network.PartOwnership.Connection = RunService.Stepped:Connect(function()
                    sethiddenproperty(LocalPlayer, "SimulationRadius", 1/0)
                    for _, Part in pairs(getgenv().Network.BaseParts) do
                        if Part:IsDescendantOf(Workspace) then
                            Part.AssemblyLinearVelocity = (Part.AssemblyLinearVelocity.Unit+Vector3.new(.01,.01,.01))*50
                        end
                    end
                end)
            end
        end)
        getgenv().Network.PartOwnership.Disable = coroutine.create(function()
            if getgenv().Network.PartOwnership.Connection then
                getgenv().Network.PartOwnership.Connection:Disconnect()
                for _, Part in pairs(getgenv().Network.BaseParts) do getgenv().Network.RemovePart(Part) end
                getgenv().Network.PartOwnership.Enabled = false
            end
        end)
    end
    coroutine.resume(getgenv().Network.PartOwnership.Enable)
    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
        if v:IsA("Accessory") then getgenv().Network.RetainPart(v.Handle) end
    end
    EO:Notify("NetPass", "เปิดแล้ว!", 2)
end, EO.Ranks.Normal)

--// ====================== คำสั่ง Anti ต่าง ๆ ======================
EO:AddCommand("antikick", "เปิด/ปิด Anti Kick + Destroy", function()
    local ak = Features.AntiKick
    if not ak.Hooked then
        local mt = getrawmetatable(game)
        ak.OldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if self == LocalPlayer and (method == "Kick" or method == "kick" or method == "Destroy" or method == "destroy") then
                EO:Notify("Anti-Kick", "บล็อก "..method.."!", 2)
                return task.wait(9e9)
            end
            return ak.OldNamecall(self, ...)
        end)
        setreadonly(mt, true)
        ak.Hooked = true
        EO:Notify("Anti-Kick", "เปิดแล้ว!", 3)
    else
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        mt.__namecall = ak.OldNamecall
        setreadonly(mt, true)
        ak.Hooked = false
        EO:Notify("Anti-Kick", "ปิดแล้ว", 2)
    end
end, EO.Ranks.VIP)

EO:AddCommand("antifling", "เปิด/ปิด Anti Fling (เบสิค)", function()
    local af = Features.AntiFling
    if #af.Connections == 0 then
        local function disable(part)
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        for _, plr in Players:GetPlayers() do
            if plr ~= LocalPlayer and plr.Character then
                for _, v in plr.Character:GetDescendants() do disable(v) end
                table.insert(af.Connections, plr.Character.DescendantAdded:Connect(disable))
            end
        end
        table.insert(af.Connections, Players.PlayerAdded:Connect(function(plr)
            if plr ~= LocalPlayer then
                plr.CharacterAdded:Connect(function(char)
                    for _, v in char:GetDescendants() do disable(v) end
                    table.insert(af.Connections, char.DescendantAdded:Connect(disable))
                end)
            end
        end))
        EO:Notify("AntiFling", "เปิดแล้ว!", 2)
    else
        for _, conn in ipairs(af.Connections) do conn:Disconnect() end
        af.Connections = {}
        EO:Notify("AntiFling", "ปิดแล้ว", 2)
    end
end, EO.Ranks.Normal)

EO:AddCommand("antisit", "เปิด/ปิด Anti Sit", function()
    local feature = Features.AntiSit
    if feature.Connection and feature.Connection.Connected then
        feature.Connection:Disconnect()
        feature.Connection = nil
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end
        end
        EO:Notify("AntiSit", "ปิดแล้ว", 2)
    else
        local function noSit(char)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false); hum.Sit = false end
        end
        if LocalPlayer.Character then noSit(LocalPlayer.Character) end
        feature.Connection = LocalPlayer.CharacterAdded:Connect(noSit)
        EO:Notify("AntiSit", "เปิดแล้ว!", 2)
    end
end, EO.Ranks.Normal)

EO:AddCommand("anticframetp", "เปิด/ปิด Anti CFrame TP", function()
    local a = Features.AntiCFrameTP
    a.Enabled = not a.Enabled
    if a.Enabled then
        local function setup(char)
            for _, v in ipairs(a.Connections) do v:Disconnect() end
            a.Connections = {}; a.LastCFrames = {}
            local function protect(part)
                if part:IsA("BasePart") then
                    a.LastCFrames[part] = part.CFrame
                    table.insert(a.Connections, part:GetPropertyChangedSignal("CFrame"):Connect(function()
                        if a.Enabled and part.Parent and part.CFrame ~= a.LastCFrames[part] then
                            part.CFrame = a.LastCFrames[part]
                        end
                    end))
                end
            end
            for _, part in char:GetDescendants() do protect(part) end
            table.insert(a.Connections, char.DescendantAdded:Connect(protect))
        end
        if LocalPlayer.Character then setup(LocalPlayer.Character) end
        LocalPlayer.CharacterAdded:Connect(setup)
        if a.RenderConn then a.RenderConn:Disconnect() end
        a.RenderConn = RunService.Heartbeat:Connect(function()
            if not a.Enabled then return end
            for part, cf in pairs(a.LastCFrames) do
                if part and part.Parent then a.LastCFrames[part] = part.CFrame end
            end
        end)
        EO:Notify("AntiCFrameTP", "เปิดแล้ว!", 3)
    else
        for _, v in ipairs(a.Connections) do v:Disconnect() end
        a.Connections = {}
        if a.RenderConn then a.RenderConn:Disconnect(); a.RenderConn = nil end
        EO:Notify("AntiCFrameTP", "ปิดแล้ว", 2)
    end
end, EO.Ranks.VIP)

EO:AddCommand("antivoid", "เปิด/ปิด AntiVoid (Velocity)", function()
    local av = Features.AntiVoid
    if av.Connection then
        av.Connection:Disconnect(); av.Connection = nil
        EO:Notify("AntiVoid", "ปิดแล้ว", 2)
    else
        av.Connection = RunService.Stepped:Connect(function()
            local root = getRoot()
            if root and root.Position.Y <= (Workspace.FallenPartsDestroyHeight or -500) + 25 then
                root.Velocity = Vector3.new(root.Velocity.X, 300, root.Velocity.Z)
            end
        end)
        EO:Notify("AntiVoid", "เปิดแล้ว!", 2)
    end
end, EO.Ranks.Normal)

EO:AddCommand("antivoid2", "เปิด/ปิด AntiVoid2 (FPDH)", function()
    local feature = Features.AntiVoid2
    if feature.OriginalFPDH then
        Workspace.FallenPartsDestroyHeight = feature.OriginalFPDH
        feature.OriginalFPDH = nil
        EO:Notify("AntiVoid2", "ปิดแล้ว", 2)
    else
        feature.OriginalFPDH = Workspace.FallenPartsDestroyHeight
        Workspace.FallenPartsDestroyHeight = -math.huge
        EO:Notify("AntiVoid2", "เปิดแล้ว!", 2)
    end
end, EO.Ranks.Normal)

EO:AddCommand("antiflinghard", "เปิด/ปิด AntiFling แบบแข็ง", function()
    local af = Features.AntiFlingHard
    af.On = not af.On
    if af.On then
        for _, c in ipairs(af.Connections) do c:Disconnect() end
        af.Connections = {}
        local function lock(part)
            if part:IsA("BasePart") then
                part.CanCollide = false
                table.insert(af.Connections, part:GetPropertyChangedSignal("CanCollide"):Connect(function()
                    if part.CanCollide then part.CanCollide = false end
                end))
            end
        end
        local function hook(char)
            for _, p in char:GetDescendants() do lock(p) end
            table.insert(af.Connections, char.DescendantAdded:Connect(lock))
        end
        for _, plr in Players:GetPlayers() do
            if plr ~= LocalPlayer and plr.Character then hook(plr.Character) end
        end
        table.insert(af.Connections, Players.PlayerAdded:Connect(function(plr)
            if plr ~= LocalPlayer then table.insert(af.Connections, plr.CharacterAdded:Connect(hook)) end
        end))
        EO:Notify("AntiFlingHard", "เปิดแล้ว!", 3)
    else
        for _, c in ipairs(af.Connections) do c:Disconnect() end
        af.Connections = {}
        EO:Notify("AntiFlingHard", "ปิดแล้ว", 2)
    end
end, EO.Ranks.Normal)

EO:AddCommand("setspawn", "ตั้งจุดเกิดปัจจุบัน", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Features.SpawnPoint = LocalPlayer.Character.HumanoidRootPart.CFrame
        if Features.SpawnConnection then Features.SpawnConnection:Disconnect() end
        Features.SpawnConnection = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Features.SpawnPoint and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = Features.SpawnPoint
            end
        end)
        EO:Notify("Spawn", "ตั้งจุดเกิดแล้ว!", 2)
    end
end, EO.Ranks.Normal)

EO:AddCommand("removespawn", "ลบจุดเกิด", function()
    Features.SpawnPoint = nil
    if Features.SpawnConnection then Features.SpawnConnection:Disconnect(); Features.SpawnConnection = nil end
    EO:Notify("Spawn", "ลบแล้ว", 2)
end, EO.Ranks.Normal)

--// ====================== ESP System ======================
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
                        drawing.Text = "👤 "..plr.Name.."\n["..dist.." studs]"
                        drawing.Position = Vector2.new(vector.X, vector.Y)
                    else drawing.Visible = false end
                else drawing.Visible = false end
            end)
        end
    else
        for _, drawing in pairs(Features.ESP.PlayerDrawings) do
            pcall(function() drawing.Visible = false end)
        end
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
                        drawing.Text = "🩸 "..(npc.Name:gsub("%.$","")).."\n["..dist.." studs]"
                        drawing.Position = Vector2.new(vector.X, vector.Y)
                    else drawing.Visible = false end
                else
                    drawing.Visible = false
                    if not npc.Parent then removeNPCESP(npc) end
                end
            end)
        end
    else
        for _, drawing in pairs(Features.ESP.NPCDrawings) do
            pcall(function() drawing.Visible = false end)
        end
    end
end

for _, plr in Players:GetPlayers() do createPlayerESP(plr) end
Players.PlayerAdded:Connect(createPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)
Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
        task.wait(0.5)
        if obj.Parent and not Players:GetPlayerFromCharacter(obj) then createNPCESP(obj) end
    end
end)
Workspace.DescendantRemoving:Connect(function(obj)
    if Features.ESP.NPCDrawings[obj] then removeNPCESP(obj) end
end)

EO:AddCommand("espplayers", "เปิด/ปิด ESP ผู้เล่น [on/off]", function(state)
    state = state and state:lower()
    if state == "on" then Features.ESP.PlayersEnabled = true elseif state == "off" then Features.ESP.PlayersEnabled = false else Features.ESP.PlayersEnabled = not Features.ESP.PlayersEnabled end
    if Features.ESP.PlayersEnabled or Features.ESP.NPCsEnabled then
        if not Features.ESP.Loop then Features.ESP.Loop = RunService.RenderStepped:Connect(updateESP) end
    else
        if Features.ESP.Loop then Features.ESP.Loop:Disconnect(); Features.ESP.Loop = nil end
    end
    EO:Notify("ESP", "ผู้เล่น "..(Features.ESP.PlayersEnabled and "เปิด" or "ปิด"), 2)
end, EO.Ranks.Normal)

EO:AddCommand("espnpcs", "เปิด/ปิด ESP NPC [on/off]", function(state)
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
        for _, drawing in pairs(Features.ESP.NPCDrawings) do
            pcall(function() drawing.Visible = false end)
        end
        if not Features.ESP.PlayersEnabled and Features.ESP.Loop then
            Features.ESP.Loop:Disconnect(); Features.ESP.Loop = nil
        end
    end
    EO:Notify("ESP", "NPC "..(Features.ESP.NPCsEnabled and "เปิด" or "ปิด"), 2)
end, EO.Ranks.Normal)

--// ====================== NPC Hunter ======================
EO:AddCommand("npcspeed", "ตั้งความเร็ว NPC <ค่า>", function(val)
    val = tonumber(val) or 20
    Features.NpcHunter.Speed = val
    for _, npc in Workspace:GetDescendants() do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(npc) then
            npc.Humanoid.WalkSpeed = val
        end
    end
    EO:Notify("NPC Speed", "ตั้งเป็น "..val, 2)
end, EO.Ranks.Normal)

EO:AddCommand("hunterv1", "เปิด/ปิด NPC Hunter V1", function()
    Features.NpcHunter.HuntV1 = not Features.NpcHunter.HuntV1
    if Features.NpcHunter.HuntV1 then
        Features.NpcHunter.Connections.V1 = RunService.Heartbeat:Connect(function()
            if not Features.NpcHunter.HuntV1 then return end
            for _, npc in Workspace:GetDescendants() do
                if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(npc) then
                    local hum = npc.Humanoid; local root = npc.HumanoidRootPart
                    hum.WalkSpeed = Features.NpcHunter.Speed
                    local closest, best = nil, math.huge
                    for _, plr in Players:GetPlayers() do
                        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            local d = (root.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                            if d < best then best = d; closest = plr end
                        end
                    end
                    if closest then
                        hum:MoveTo(closest.Character.HumanoidRootPart.Position + Vector3.new(math.random(-10,10),0,math.random(-10,10)))
                    end
                end
            end
        end)
        EO:Notify("Hunter V1", "เปิดแล้ว!", 2)
    else
        if Features.NpcHunter.Connections.V1 then Features.NpcHunter.Connections.V1:Disconnect(); Features.NpcHunter.Connections.V1 = nil end
        EO:Notify("Hunter V1", "ปิดแล้ว", 2)
    end
end, EO.Ranks.Normal)

EO:AddCommand("hunterv2", "เปิด/ปิด NPC Hunter V2 (Pathfinding)", function()
    Features.NpcHunter.HuntV2 = not Features.NpcHunter.HuntV2
    if Features.NpcHunter.HuntV2 then
        Features.NpcHunter.Connections.V2 = RunService.Heartbeat:Connect(function()
            if not Features.NpcHunter.HuntV2 then return end
            for _, npc in Workspace:GetChildren() do
                if not npc:IsA("Model") then continue end
                local hum = npc:FindFirstChild("Humanoid"); local root = npc:FindFirstChild("HumanoidRootPart")
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
        end)
        EO:Notify("Hunter V2", "เปิดแล้ว!", 2)
    else
        if Features.NpcHunter.Connections.V2 then Features.NpcHunter.Connections.V2:Disconnect(); Features.NpcHunter.Connections.V2 = nil end
        Features.NpcHunter.ActivePaths = {}
        EO:Notify("Hunter V2", "ปิดแล้ว", 2)
    end
end, EO.Ranks.Normal)

EO:AddCommand("hunterv3", "เปิด/ปิด NPC Hunter V3 (อัจฉริยะ)", function()
    Features.NpcHunter.HuntV3 = not Features.NpcHunter.HuntV3
    if Features.NpcHunter.HuntV3 then
        for _, npc in Workspace:GetChildren() do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(npc) then
                local hum = npc.Humanoid; local root = npc.HumanoidRootPart
                hum.WalkSpeed = Features.NpcHunter.Speed
                Features.NpcHunter.Connections[npc] = RunService.Heartbeat:Connect(function()
                    if not Features.NpcHunter.HuntV3 or not npc.Parent then
                        if Features.NpcHunter.Connections[npc] then Features.NpcHunter.Connections[npc]:Disconnect() end
                        return
                    end
                    hum.WalkSpeed = Features.NpcHunter.Speed
                    local target, best = nil, math.huge
                    for _, plr in Players:GetPlayers() do
                        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            local d = (root.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                            if d < best then best = d; target = plr end
                        end
                    end
                    if not target then return end
                    local myRoot = getRoot()
                    local myPos = myRoot and myRoot.Position
                    if myPos and (root.Position - myPos).Magnitude < 30 then
                        local runAway = (root.Position - myPos).Unit * 70
                        hum:MoveTo(root.Position + runAway); hum.Jump = true
                        Features.NpcHunter.ActivePaths[tostring(npc)] = nil
                        return
                    end
                    local key = tostring(npc)
                    if not Features.NpcHunter.ActivePaths[key] or tick() - (Features.NpcHunter.ActivePaths[key].Last or 0) > 1.5 then
                        local path = PathfindingService:CreatePath({AgentRadius = 3, AgentHeight = 6, AgentCanJump = true, AgentMaxSlope = 70})
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
                end)
            end
        end
        EO:Notify("Hunter V3", "เปิดแล้ว!", 3)
    else
        for npc, conn in pairs(Features.NpcHunter.Connections) do
            if typeof(npc) == "Instance" and conn.Connected then conn:Disconnect() end
        end
        Features.NpcHunter.Connections = {}
        Features.NpcHunter.ActivePaths = {}
        EO:Notify("Hunter V3", "ปิดแล้ว", 2)
    end
end, EO.Ranks.VIP)

EO:AddCommand("godfollow", "God Follow V4 <ชื่อ NPC>", function(npcName)
    if not npcName or npcName == "" then EO:Notify("GodFollow", "ระบุชื่อ NPC!", 3) return end
    local target
    for _, v in Workspace:GetChildren() do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and string.find(v.Name:lower(), npcName:lower(), 1, true) then
            target = v; break
        end
    end
    if not target then EO:Notify("GodFollow", "ไม่พบ NPC "..npcName, 3) return end
    Features.NpcHunter.FollowTarget = target
    Features.NpcHunter.FollowEnabled = true
    if Features.NpcHunter.GodFollowConn then Features.NpcHunter.GodFollowConn:Disconnect() end
    Features.NpcHunter.GodFollowConn = RunService.RenderStepped:Connect(function()
        if not Features.NpcHunter.FollowEnabled or not Features.NpcHunter.FollowTarget or not Features.NpcHunter.FollowTarget.Parent then return end
        local targetRoot = Features.NpcHunter.FollowTarget:FindFirstChild("HumanoidRootPart") or Features.NpcHunter.FollowTarget:FindFirstChild("Torso")
        if not targetRoot then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso")
        if not myRoot then return end
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, -5.5, 0)
        for _, part in myChar:GetChildren() do if part:IsA("BasePart") then part.CanCollide = false end end
    end)
    EO:Notify("GodFollow", "ตาม "..target.Name.." ใต้ดิน!", 4)
end, EO.Ranks.VIP)

EO:AddCommand("godfollowoff", "ปิด God Follow", function()
    Features.NpcHunter.FollowEnabled = false
    if Features.NpcHunter.GodFollowConn then Features.NpcHunter.GodFollowConn:Disconnect(); Features.NpcHunter.GodFollowConn = nil end
    EO:Notify("GodFollow", "ปิดแล้ว", 2)
end, EO.Ranks.VIP)

EO:AddCommand("killnpcs", "ฆ่า NPC ทั้งหมด", function()
    local count = 0
    for _, v in Workspace:GetDescendants() do
        if v:IsA("Humanoid") and v.Parent and not Players:GetPlayerFromCharacter(v.Parent) then
            v.Health = 0; count = count + 1
        end
    end
    EO:Notify("Kill NPCs", "ฆ่า "..count.." ตัว!", 3)
end, EO.Ranks.VIP)

EO:AddCommand("resetai", "รีเซ็ต AI Hunters", function()
    Features.NpcHunter.HuntV1, Features.NpcHunter.HuntV2, Features.NpcHunter.HuntV3 = false, false, false
    for _, conn in pairs(Features.NpcHunter.Connections) do
        if conn and conn.Connected then conn:Disconnect() end
    end
    Features.NpcHunter.Connections = {}
    Features.NpcHunter.ActivePaths = {}
    EO:Notify("Reset AI", "รีเซ็ตแล้ว", 2)
end, EO.Ranks.Normal)

--// ====================== คำสั่งอื่น ๆ ======================
EO:AddCommand("autorejoin", "เปิด/ปิด Auto Rejoin", function()
    if Features.AutoRejoinConn then
        Features.AutoRejoinConn:Disconnect(); Features.AutoRejoinConn = nil
        EO:Notify("AutoRejoin", "ปิดแล้ว", 2)
    else
        local placeId, jobId = game.PlaceId, game.JobId
        Features.AutoRejoinConn = GuiService.ErrorMessageChanged:Connect(function()
            coroutine.wrap(function()
                if #Players:GetPlayers() <= 1 then
                    LocalPlayer:Kick("Rejoining...")
                    task.wait(1)
                    TeleportService:Teleport(placeId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
                end
            end)()
        end)
        EO:Notify("AutoRejoin", "เปิดแล้ว", 2)
    end
end, EO.Ranks.Normal)

EO:AddCommand("namelessadmin", "โหลด Nameless-Admin", function()
    getgenv().NamelessLoaded = false
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"))()
    EO:Notify("Nameless", "โหลดแล้ว!", 3)
end, EO.Ranks.Normal)

print("[IFH_CMDS1] ✅ โหลดคำสั่งทั้งหมดสำหรับ Identity Fraud Horror แล้ว")

return true
