--// 🌒 EclipseX Plugin — UI Hunter System for Identity Fraud
local EO = getgenv().EclipseOps
if not EO or not EO.CoreLoaded then
    warn("[EclipseX] ❌ IFH_UI_HUNTER — ต้องเรียก EO:Init() ก่อน")
    return
end

--// [SERVICES]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

--// [FEATURES STATE]
local Features = {
    NpcHunter = {
        Speed = 20,
        HuntV2 = false,
        Connection = nil,
        ActivePaths = {}
    }
}
getgenv().IFH_Hunter_Features = Features

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

print("[IFH_UI_HUNTER] ✅ ระบบ UI Hunter สำหรับ Identity Fraud โหลดแล้ว")
return true
