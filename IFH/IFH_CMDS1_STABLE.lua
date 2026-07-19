--// 🌒 EclipseX Command Module — Basic Commands STABLE (Loads UI Hunter Externally)
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

local function getRoot(char)
    char = char or LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

local function isCharacter(obj)
    if obj:IsA("Model") then
        return obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart")
    end
    return false
end

--// [FEATURES STATE] (ไม่มี Hunter)
local Features = {
    FullBright = { Enabled = false, Original = {}, Connections = {} },
    NoJump = false,
    NoClip = { Enabled = false, Connection = nil },
    NpcNoClip = { Enabled = false, Connection = nil, Objects = {} },
    TPWalk = { Enabled = false, Speed = 200, Conn = nil },
    InfiniteJump = { Enabled = false, Conn = nil },
    XRay = { Enabled = false, SavedParts = {}, Connection = nil, Transparency = 0.8 },
    ESP = {
        PlayersEnabled = false,
        NPCsEnabled = false,
        PlayerDrawings = {},
        NPCDrawings = {},
        Loop = nil
    }
}
getgenv().CMDS_BASIC_Features = Features

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

EO:AddCommand("fixcamera", "Fix Camera + Unlock", function()
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

EO:AddCommand("unupsidedown", "ปิด Upside Down", function()
    if LocalPlayer.Character then
        LocalPlayer.Character:BreakJoints()
    end
    EO:Notify("UpsideDown", "ปิดแล้ว (เกิดใหม่)", 2)
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

EO:AddCommand("npcnoclip", "NPC NoClip — ให้ NPC ทะลุกำแพง [on/off]", function(state)
    state = state and state:lower()
    local nn = Features.NpcNoClip
    if state == "on" then nn.Enabled = true elseif state == "off" then nn.Enabled = false else nn.Enabled = not nn.Enabled end

    if nn.Enabled then
        for _, npc in Workspace:GetDescendants() do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(npc) then
                for _, part in ipairs(npc:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        table.insert(nn.Objects, part)
                    end
                end
            end
        end
        if nn.Connection then nn.Connection:Disconnect() end
        nn.Connection = Workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                coroutine.wrap(function()
                    local hum = obj:WaitForChild("Humanoid", 5)
                    local root = obj:WaitForChild("HumanoidRootPart", 5)
                    if hum and root then
                        for _, part in ipairs(obj:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                                table.insert(nn.Objects, part)
                            end
                        end
                    end
                end)()
            end
        end)
        EO:Notify("NPC NoClip", "เปิดแล้ว! NPC ทะลุกำแพง 👻", 2)
    else
        for _, part in ipairs(nn.Objects) do
            if part and part.Parent then
                part.CanCollide = true
            end
        end
        nn.Objects = {}
        if nn.Connection then
            nn.Connection:Disconnect()
            nn.Connection = nil
        end
        EO:Notify("NPC NoClip", "ปิดแล้ว", 2)
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

--// ====================== X-RAY SYSTEM ======================
local function saveAndApplyXRay()
    local parts = {}
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsDescendantOf(workspace.CurrentCamera) then
            local parentModel = part.Parent
            while parentModel do
                if parentModel:IsA("Model") and isCharacter(parentModel) then
                    parentModel = nil
                    break
                end
                parentModel = parentModel.Parent
            end
            if parentModel == nil then
                table.insert(parts, part)
                part.Transparency = Features.XRay.Transparency
            end
        end
    end
    Features.XRay.SavedParts = parts
end

local function restoreXRay()
    for _, part in ipairs(Features.XRay.SavedParts) do
        if part and part.Parent then
            part.Transparency = 0
        end
    end
    Features.XRay.SavedParts = {}
end

EO:AddCommand("xray", "X-Ray — เปิดโหมดมองทะลุกำแพง", function()
    if Features.XRay.Enabled then
        EO:Notify("X-Ray", "เปิดอยู่แล้ว!", 2)
        return
    end
    Features.XRay.Enabled = true
    saveAndApplyXRay()

    if Features.XRay.Connection then Features.XRay.Connection:Disconnect() end
    Features.XRay.Connection = RunService.Stepped:Connect(function()
        if not Features.XRay.Enabled then return end
        for _, part in ipairs(Features.XRay.SavedParts) do
            if part and part.Parent and part.Transparency < 0.7 then
                part.Transparency = Features.XRay.Transparency
            end
        end
    end)
    EO:Notify("X-Ray", "เปิดแล้ว! มองทะลุกำแพง 👁️", 3)
end, EO.Ranks.Normal)

EO:AddCommand("unxray", "ปิด X-Ray", function()
    if not Features.XRay.Enabled then
        EO:Notify("X-Ray", "ยังไม่ได้เปิด!", 2)
        return
    end
    Features.XRay.Enabled = false
    if Features.XRay.Connection then
        Features.XRay.Connection:Disconnect()
        Features.XRay.Connection = nil
    end
    restoreXRay()
    EO:Notify("X-Ray", "ปิดแล้ว", 2)
end, EO.Ranks.Normal)

--// ====================== ESP SYSTEM ======================
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
    if not npc or Players:GetPlayerFromCharacter(npc) then return end
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
    if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
        coroutine.wrap(function()
            local hum = obj:WaitForChild("Humanoid", 10)
            local root = obj:WaitForChild("HumanoidRootPart", 10)
            if hum and root and obj.Parent then
                createNPCESP(obj)
            end
        end)()
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

--// ====================== UI Hunter (External Load) ======================
local HUNTER_URL = "https://raw.githubusercontent.com/wino444/EclipseX-Commands/main/IFH/IFH_UI_HUNTER.lua"

EO:AddCommand("uihunter", "เปิด/ปิด UI Hunter (โหลดภายนอก)", function()
    -- ถ้ายังไม่เคยโหลดโมดูล → โหลดจาก GitHub ก่อน
    if not EO.ModulesLoaded["IFH_UI_HUNTER"] then
        EO:Notify("UI Hunter", "กำลังโหลดระบบ... ⏳", 2)
        local success = EO:LoadModule("IFH_UI_HUNTER", HUNTER_URL)
        if not success then
            EO:Notify("UI Hunter", "❌ โหลดไม่สำเร็จ!", 3)
            return
        end
        wait(0.3) -- รอให้โค้ดในโมดูลทำงานและสร้าง Toggle function
    end

    -- เรียกฟังก์ชัน Toggle (สร้างโดย IFH_UI_HUNTER.lua)
    local toggle = getgenv().IFH_UI_HUNTER_Toggle
    if toggle then
        toggle()
    else
        EO:Notify("UI Hunter", "❌ ไม่พบระบบ Toggle", 2)
    end
end, EO.Ranks.Normal)

print("[CMDS_BASIC] ✅ โหลดคำสั่งพื้นฐานทั้งหมด (UI Hunter ภายนอก) สำเร็จ")
return true
