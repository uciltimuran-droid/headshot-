-- 99%W Panel | FPS Admin Panel (Full Version)
-- Place in StarterPlayerScripts or StarterGui

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==============================
-- CONFIG
-- ==============================
local panelName = "99%W"
local headshotIcon = "rbxassetid://7072710887" -- Headshot icon
local defaultWalkSpeed = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed or 16
local defaultJumpPower = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower or 50

-- ==============================
-- CREATE PANEL
-- ==============================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = panelName
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 260, 0, 350)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Frame.Active = true
Frame.Draggable = true
Frame.ClipsDescendants = true
Frame.AnchorPoint = Vector2.new(0,0)

-- Minimize button
local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 30, 0, 30)
Minimize.Position = UDim2.new(1, -35, 0, 5)
Minimize.BackgroundColor3 = Color3.fromRGB(200,0,0)
Minimize.Text = "-"
Minimize.TextColor3 = Color3.new(1,1,1)
Minimize.TextScaled = true
Minimize.Font = Enum.Font.SourceSansBold
Minimize.Parent = Frame

-- Panel title with icon
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 30)
Title.Position = UDim2.new(0,35,0,0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Text = panelName
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local Icon = Instance.new("ImageLabel")
Icon.Size = UDim2.new(0, 25, 0, 25)
Icon.Position = UDim2.new(0,5,0,2)
Icon.Image = headshotIcon
Icon.BackgroundTransparency = 1
Icon.Parent = Frame

-- ==============================
-- FEATURES
-- ==============================
local features = {
    {name = "ESP Player", toggled = false},
    {name = "ESP Distance", toggled = false},
    {name = "ESP Gun", toggled = false},
    {name = "Set WalkSpeed", toggled = false},
    {name = "Set JumpPower", toggled = false},
}

local buttons = {}
for i, feat in ipairs(features) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 30)
    btn.Position = UDim2.new(0, 20, 0, 40 + (i-1)*40)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = feat.name .. ": OFF"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextScaled = true
    btn.Parent = Frame

    btn.MouseButton1Click:Connect(function()
        feat.toggled = not feat.toggled
        btn.Text = feat.name .. (feat.toggled and ": ON" or ": OFF")
    end)

    buttons[feat.name] = btn
end

-- WalkSpeed and JumpPower sliders
local walkSlider = Instance.new("TextBox")
walkSlider.Size = UDim2.new(0, 100, 0, 30)
walkSlider.Position = UDim2.new(0, 20, 0, 40 + 3*40)
walkSlider.BackgroundColor3 = Color3.fromRGB(70,70,70)
walkSlider.TextColor3 = Color3.new(1,1,1)
walkSlider.PlaceholderText = "WalkSpeed"
walkSlider.ClearTextOnFocus = false
walkSlider.Font = Enum.Font.SourceSans
walkSlider.TextScaled = true
walkSlider.Parent = Frame

local jumpSlider = Instance.new("TextBox")
jumpSlider.Size = UDim2.new(0, 100, 0, 30)
jumpSlider.Position = UDim2.new(0, 140, 0, 40 + 3*40)
jumpSlider.BackgroundColor3 = Color3.fromRGB(70,70,70)
jumpSlider.TextColor3 = Color3.new(1,1,1)
jumpSlider.PlaceholderText = "JumpPower"
jumpSlider.ClearTextOnFocus = false
jumpSlider.Font = Enum.Font.SourceSans
jumpSlider.TextScaled = true
jumpSlider.Parent = Frame

-- Minimize functionality
local minimized = false
Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, child in ipairs(Frame:GetChildren()) do
        if child ~= Minimize and child ~= Title and child ~= Icon then
            child.Visible = not minimized
        end
    end
end)

-- ==============================
-- ESP SYSTEM
-- ==============================
local ESPs = {}
local GunESPs = {}

local function createESP(player)
    if ESPs[player] then return ESPs[player] end
    local box = Instance.new("BillboardGui")
    box.Size = UDim2.new(0,120,0,50)
    box.Adornee = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    box.AlwaysOnTop = true
    box.Parent = ScreenGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Text = player.Name
    label.Parent = box

    ESPs[player] = box
    return box
end

local function createGunESP(gun)
    if GunESPs[gun] then return GunESPs[gun] end
    local box = Instance.new("BillboardGui")
    box.Size = UDim2.new(0,100,0,30)
    box.Adornee = gun
    box.AlwaysOnTop = true
    box.Parent = ScreenGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,200,0)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Text = gun.Name
    label.Parent = box

    GunESPs[gun] = box
    return box
end

local function updateESPs()
    -- Players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if features[1].toggled then
                createESP(player).Enabled = true
            else
                if ESPs[player] then ESPs[player].Enabled = false end
            end
        end
    end
    -- Guns
    if features[3].toggled then
        for _, gun in ipairs(Workspace:GetDescendants()) do
            if gun:IsA("BasePart") and gun.Name:lower():find("gun") then
                createGunESP(gun).Enabled = true
            end
        end
    else
        for gun, gui in pairs(GunESPs) do
            gui.Enabled = false
        end
    end
end

local function updateDistances()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if features[2].toggled then
                local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if ESPs[player] then
                    ESPs[player].TextLabel.Text = player.Name .. " [" .. math.floor(dist) .. "m]"
                end
            end
        end
    end
end

-- ==============================
-- RUNSERVICE LOOP
-- ==============================
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        -- WalkSpeed
        if features[4].toggled then
            local ws = tonumber(walkSlider.Text)
            if ws then humanoid.WalkSpeed = ws end
        else
            humanoid.WalkSpeed = defaultWalkSpeed
        end
        -- JumpPower
        if features[5].toggled then
            local jp = tonumber(jumpSlider.Text)
            if jp then humanoid.JumpPower = jp end
        else
            humanoid.JumpPower = defaultJumpPower
        end
    end

    updateESPs()
    updateDistances()
end)
