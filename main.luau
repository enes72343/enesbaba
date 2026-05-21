-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- STATES
local menuOpen = false
local espActive = false
local espConnections = {}
local espBoxes = {}

-- UI CREATION (Pure Scripting)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AC_TestMenu_Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Menu Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Anti-Cheat Test Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- ESP Button
local EspButton = Instance.new("TextButton")
EspButton.Size = UDim2.new(0, 200, 0, 50)
EspButton.Position = UDim2.new(0.5, -100, 0.5, -10)
EspButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40) -- Default Red (Off)
EspButton.Text = "ESP: PASIF"
EspButton.TextColor3 = Color3.fromRGB(255, 255, 255)
EspButton.TextSize = 18
EspButton.Font = Enum.Font.SourceSansBold
EspButton.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = EspButton

-- ESP FUNCTIONS (Core Logic)
local function createEspBox(player)
    if player == LocalPlayer then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_Box_" .. player.Name
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.4
    
    local function updateBox()
        if not espActive then 
            box.Adornment = nil
            return 
        end
        
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                box.Adornment = player.Character.HumanoidRootPart
                box.Size = player.Character:GetExtentsSize() + Vector3.new(0.5, 0.5, 0.5)
                box.Parent = ScreenGui
                return
            end
        end
        box.Adornment = nil
    end
    
    local conn = RunService.RenderStepped:Connect(updateBox)
    espConnections[player] = conn
    espBoxes[player] = box
end

local function removeEspBox(player)
    if espConnections[player] then
        espConnections[player]:Disconnect()
        espConnections[player] = nil
    end
    if espBoxes[player] then
        espBoxes[player]:Destroy()
        espBoxes[player] = nil
    end
end

-- ESP Toggle Button Logic
EspButton.MouseButton1Click:Connect(function()
    espActive = not espActive
    if espActive then
        EspButton.Text = "ESP: AKTIF"
        EspButton.BackgroundColor3 = Color3.fromRGB(40, 180, 40) -- Green
        
        -- Existing players
        for _, p in ipairs(Players:GetPlayers()) do
            createEspBox(p)
        end
    else
        EspButton.Text = "ESP: PASIF"
        EspButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40) -- Red
        
        for _, p in ipairs(Players:GetPlayers()) do
            removeEspBox(p)
        end
    end
end)

-- Player Events for ESP
Players.PlayerAdded:Connect(function(player)
    if espActive then createEspBox(player) end
end)

Players.PlayerRemoving:Connect(function(player)
    removeEspBox(player)
end)

-- TOGGLE MENU (Insert Key Logic)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert then
        menuOpen = not menuOpen
        MainFrame.Visible = menuOpen
        
        if menuOpen then
            UserInputService.MouseIconEnabled = true
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        else
            -- Closes the menu and gives control back to the game camera
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        end
    end
end)
