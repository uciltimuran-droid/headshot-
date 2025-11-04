-- OKZ-ID Super Responsive Aimbot Script
-- FOR PRIVATE/EDUCATIONAL USE ONLY

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Configuration
local Config = {
    Aimbot = {
        Enabled = false,
        Target = "Head", -- Head or Body
        Smoothness = 0.1, -- Lower = more responsive
        FOV = 100, -- Degrees
        TeamCheck = true,
        VisibleCheck = true,
        Prediction = 0.1, -- For moving targets
        ResponseTime = 0.001 -- Ultra responsive
    },
    ESP = {
        Enabled = false,
        Boxes = true,
        Tracers = true,
        Names = true
    }
}

-- Main GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OKZ_ID"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 450)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Add rounded corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

-- Title Text
local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(0.7, 0, 1, 0)
TitleText.Position = UDim2.new(0.02, 0, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "OKZ-ID Panel v2.0"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Font = Enum.Font.GothamSemibold
TitleText.TextSize = 14
TitleText.Parent = TitleBar

-- Control Buttons
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 12
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -60, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 12
MinimizeButton.Parent = TitleBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 4)
MinimizeCorner.Parent = MinimizeButton

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -10, 1, -45)
ContentFrame.Position = UDim2.new(0, 5, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Tab System
local Tabs = {}

function CreateTab(tabName)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabName .. "Tab"
    TabButton.Size = UDim2.new(0.24, 0, 0, 30)
    TabButton.Position = UDim2.new(#Tabs * 0.25, 0, 0, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TabButton.BorderSizePixel = 0
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 12
    TabButton.Parent = ContentFrame
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 4)
    TabCorner.Parent = TabButton
    
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Name = tabName .. "Frame"
    TabFrame.Size = UDim2.new(1, 0, 1, -35)
    TabFrame.Position = UDim2.new(0, 0, 0, 35)
    TabFrame.BackgroundTransparency = 1
    TabFrame.BorderSizePixel = 0
    TabFrame.ScrollBarThickness = 3
    TabFrame.Visible = #Tabs == 0
    TabFrame.Parent = ContentFrame
    
    Tabs[tabName] = TabFrame
    
    TabButton.MouseButton1Click:Connect(function()
        for name, frame in pairs(Tabs) do
            frame.Visible = (name == tabName)
        end
    end)
    
    return TabFrame
end

-- Create Tabs
local AimbotTab = CreateTab("Aimbot")
local VisualsTab = CreateTab("Visuals")
local CameraTab = CreateTab("Camera")
local SettingsTab = CreateTab("Settings")

-- Aimbot Controls
local AimbotToggle = CreateToggle("Aimbot Master", AimbotTab, 10, function(state)
    Config.Aimbot.Enabled = state
end)

local TargetSelection = CreateOption("Target Part", AimbotTab, 50, {"Head", "Body"}, function(option)
    Config.Aimbot.Target = option
end)

local SmoothnessSlider = CreateSlider("Smoothness", AimbotTab, 90, 0.01, 0.5, 0.1, function(value)
    Config.Aimbot.Smoothness = value
end)

local FOVSlider = CreateSlider("Aimbot FOV", AimbotTab, 130, 1, 360, 100, function(value)
    Config.Aimbot.FOV = value
end)

local PredictionSlider = CreateSlider("Prediction", AimbotTab, 170, 0, 0.3, 0.1, function(value)
    Config.Aimbot.Prediction = value
end)

local TeamCheckToggle = CreateToggle("Team Check", AimbotTab, 210, function(state)
    Config.Aimbot.TeamCheck = state
end)

local VisibleCheckToggle = CreateToggle("Visible Check", AimbotTab, 250, function(state)
    Config.Aimbot.VisibleCheck = state
end)

-- Visuals Controls
local ESPToggle = CreateToggle("ESP Master", VisualsTab, 10, function(state)
    Config.ESP.Enabled = state
    UpdateESP()
end)

local BoxesToggle = CreateToggle("Box ESP", VisualsTab, 50, function(state)
    Config.ESP.Boxes = state
end)

local TracersToggle = CreateToggle("Tracers", VisualsTab, 90, function(state)
    Config.ESP.Tracers = state
end)

local NamesToggle = CreateToggle("Player Names", VisualsTab, 130, function(state)
    Config.ESP.Names = state
end)

-- Camera Controls
local FOVCircleToggle = CreateToggle("FOV Circle", CameraTab, 10, function(state)
    UpdateFOVCircle()
end)

local FOVCircleSlider = CreateSlider("FOV Circle Size", CameraTab, 50, 1, 100, 70, function(value)
    UpdateFOVCircle()
end)

-- UI Component Functions
function CreateToggle(label, parent, yPosition, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -10, 0, 30)
    toggleFrame.Position = UDim2.new(0, 5, 0, yPosition)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.Position = UDim2.new(0, 0, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = label
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextSize = 12
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 40, 0, 20)
    toggleButton.Position = UDim2.new(1, -40, 0, 5)
    toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggleButton
    
    local toggleDot = Instance.new("Frame")
    toggleDot.Size = UDim2.new(0, 16, 0, 16)
    toggleDot.Position = UDim2.new(0, 2, 0, 2)
    toggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleDot.BorderSizePixel = 0
    toggleDot.Parent = toggleButton
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0, 8)
    dotCorner.Parent = toggleDot
    
    local state = false
    
    local function updateToggle()
        if state then
            toggleDot.Position = UDim2.new(1, -18, 0, 2)
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        else
            toggleDot.Position = UDim2.new(0, 2, 0, 2)
            toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
        callback(state)
    end)
    
    updateToggle()
    return {Set = function(newState) state = newState; updateToggle() end}
end

function CreateSlider(label, parent, yPosition, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 40)
    sliderFrame.Position = UDim2.new(0, 5, 0, yPosition)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.Position = UDim2.new(0, 0, 0, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = label .. ": " .. default
    sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.TextSize = 12
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = sliderFrame
    
    local sliderBar = Instance.new("TextButton")
    sliderBar.Size = UDim2.new(1, 0, 0, 15)
    sliderBar.Position = UDim2.new(0, 0, 0, 25)
    sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderBar.BorderSizePixel = 0
    sliderBar.Text = ""
    sliderBar.Parent = sliderFrame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = sliderBar
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = sliderFill
    
    local dragging = false
    
    local function updateSlider(input)
        local mousePos = Vector2.new(input.Position.X, input.Position.Y)
        local sliderAbsolutePos = sliderBar.AbsolutePosition
        local sliderAbsoluteSize = sliderBar.AbsoluteSize
        
        local relativeX = math.clamp((mousePos.X - sliderAbsolutePos.X) / sliderAbsoluteSize.X, 0, 1)
        local value = min + (max - min) * relativeX
        value = math.floor(value * 100) / 100
        
        sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        sliderLabel.Text = label .. ": " .. value
        callback(value)
    end
    
    sliderBar.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    return {Set = function(value) updateSlider({Position = Vector2.new(value, 0)}) end}
end

function CreateOption(label, parent, yPosition, options, callback)
    local optionFrame = Instance.new("Frame")
    optionFrame.Size = UDim2.new(1, -10, 0, 30)
    optionFrame.Position = UDim2.new(0, 5, 0, yPosition)
    optionFrame.BackgroundTransparency = 1
    optionFrame.Parent = parent
    
    local optionLabel = Instance.new("TextLabel")
    optionLabel.Size = UDim2.new(0.7, 0, 1, 0)
    optionLabel.Position = UDim2.new(0, 0, 0, 0)
    optionLabel.BackgroundTransparency = 1
    optionLabel.Text = label
    optionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    optionLabel.Font = Enum.Font.Gotham
    optionLabel.TextSize = 12
    optionLabel.TextXAlignment = Enum.TextXAlignment.Left
    optionLabel.Parent = optionFrame
    
    local optionButton = Instance.new("TextButton")
    optionButton.Size = UDim2.new(0, 80, 0, 25)
    optionButton.Position = UDim2.new(1, -80, 0, 2)
    optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    optionButton.BorderSizePixel = 0
    optionButton.Text = options[1]
    optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    optionButton.Font = Enum.Font.Gotham
    optionButton.TextSize = 11
    optionButton.Parent = optionFrame
    
    local optionCorner = Instance.new("UICorner")
    optionCorner.CornerRadius = UDim.new(0, 4)
    optionCorner.Parent = optionButton
    
    local currentIndex = 1
    
    optionButton.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #options then
            currentIndex = 1
        end
        optionButton.Text = options[currentIndex]
        callback(options[currentIndex])
    end)
    
    return {Set = function(option) 
        for i, opt in ipairs(options) do
            if opt == option then
                currentIndex = i
                optionButton.Text = option
                callback(option)
                break
            end
        end
    end}
end

-- UI Functionality
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                  startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- Button Functionality
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    ContentFrame.Visible = not ContentFrame.Visible
    if ContentFrame.Visible then
        MainFrame.Size = UDim2.new(0, 400, 0, 450)
    else
        MainFrame.Size = UDim2.new(0, 400, 0, 35)
    end
end)

-- SUPER RESPONSIVE AIMBOT LOGIC
local CurrentTarget = nil
local FOVCircle = nil

function CreateFOVCircle()
    if FOVCircle then FOVCircle:Remove() end
    
    FOVCircle = Instance.new("Frame")
    FOVCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)
    FOVCircle.Position = UDim2.new(0.5, -Config.Aimbot.FOV, 0.5, -Config.Aimbot.FOV)
    FOVCircle.BackgroundTransparency = 1
    FOVCircle.BorderSizePixel = 0
    FOVCircle.Parent = ScreenGui
    
    local circle = Instance.new("UICorner")
    circle.CornerRadius = UDim.new(1, 0)
    circle.Parent = FOVCircle
    
    local outline = Instance.new("UIStroke")
    outline.Color = Color3.fromRGB(255, 255, 255)
    outline.Thickness = 1
    outline.Transparency = 0.3
    outline.Parent = FOVCircle
end

function UpdateFOVCircle()
    if FOVCircle then
        FOVCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)
        FOVCircle.Position = UDim2.new(0.5, -Config.Aimbot.FOV, 0.5, -Config.Aimbot.FOV)
    end
end

function IsPlayerValid(targetPlayer)
    if not targetPlayer then return false end
    if not targetPlayer.Character then return false end
    
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    if Config.Aimbot.TeamCheck then
        if player.Team and targetPlayer.Team and player.Team == targetPlayer.Team then
            return false
        end
    end
    
    return true
end

function GetTargetPart(character)
    if Config.Aimbot.Target == "Head" then
        return character:FindFirstChild("Head")
    else
        return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
    end
end

function IsVisible(character)
    if not Config.Aimbot.VisibleCheck then return true end
    
    local camera = workspace.CurrentCamera
    local targetPart = GetTargetPart(character)
    if not targetPart then return false end
    
    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 1000
    
    local ray = Ray.new(origin, direction)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character, camera})
    
    if hit and hit:IsDescendantOf(character) then
        return true
    end
    
    return false
end

function FindBestTarget()
    local closestTarget = nil
    local closestDistance = math.huge
    local camera = workspace.CurrentCamera
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and IsPlayerValid(targetPlayer) then
            local character = targetPlayer.Character
            local targetPart = GetTargetPart(character)
            
            if targetPart and IsVisible(character) then
                local screenPoint, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local mousePos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
                    local distance = (mousePos - targetPos).Magnitude
                    
                    -- FOV Check
                    if distance <= Config.Aimbot.FOV then
                        if distance < closestDistance then
                            closestDistance = distance
                            closestTarget = targetPlayer
                        end
                    end
                end
            end
        end
    end
    
    return closestTarget
end

function CalculatePrediction(targetPart, character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return targetPart.Position end
    
    local velocity = targetPart.AssemblyLinearVelocity
    local distance = (targetPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
    
    -- Simple prediction based on velocity and distance
    local prediction = velocity * (Config.Aimbot.Prediction * distance / 100)
    return targetPart.Position + prediction
end

-- Ultra Responsive Aimbot Loop
local AimbotConnection = RunService.RenderStepped:Connect(function(deltaTime)
    if not Config.Aimbot.Enabled then 
        CurrentTarget = nil
        return 
    end
    
    -- Find target
    CurrentTarget = FindBestTarget()
    
    if CurrentTarget and CurrentTarget.Character then
        local targetPart = GetTargetPart(CurrentTarget.Character)
        if not targetPart then return end
        
        -- Calculate target position with prediction
        local targetPosition = CalculatePrediction(targetPart, CurrentTarget.Character)
        
        -- Get camera
        local camera = workspace.CurrentCamera
        
        -- Calculate direction
        local direction = (targetPosition - camera.CFrame.Position).Unit
        
        -- Ultra responsive aiming with minimal smoothing
        local currentLook = camera.CFrame.LookVector
        local newLook = currentLook:Lerp(direction, 1 - Config.Aimbot.Smoothness)
        
        -- Apply the new camera direction
        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + newLook)
    end
end)

-- ESP System
local ESPObjects = {}

function UpdateESP()
    if not Config.ESP.Enabled then
        for _, obj in pairs(ESPObjects) do
            if obj then
                obj:Remove()
            end
        end
        ESPObjects = {}
        return
    end
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and IsPlayerValid(targetPlayer) then
            CreateESP(targetPlayer)
        end
    end
end

function CreateESP(targetPlayer)
    local character = targetPlayer.Character
    if not character then return end
    
    if ESPObjects[targetPlayer] then
        ESPObjects[targetPlayer]:Remove()
    end
    
    local espFolder = Instance.new("Folder")
    espFolder.Name = targetPlayer.Name .. "_ESP"
    espFolder.Parent = ScreenGui
    
    ESPObjects[targetPlayer] = espFolder
    
    if Config.ESP.Boxes then
        -- Create box ESP (simplified)
        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, 100, 0, 150)
        box.BackgroundTransparency = 0.8
        box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        box.BorderSizePixel = 1
        box.Parent = espFolder
    end
    
    if Config.ESP.Names then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = targetPlayer.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(0, 100, 0, 20)
        nameLabel.Parent = espFolder
    end
end

-- Initialize
CreateFOVCircle()

-- Cleanup when player leaves
Players.PlayerRemoving:Connect(function(leftPlayer)
    if ESPObjects[leftPlayer] then
        ESPObjects[leftPlayer]:Remove()
        ESPObjects[leftPlayer] = nil
    end
end)

print("✅ OKZ-ID Super Aimbot Loaded Successfully")
print("🎯 Features: Ultra Responsive Aimbot | ESP | FOV Control")
print("⚠️  FOR PRIVATE USE ONLY")
