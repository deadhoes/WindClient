local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Notification = {}
Notification.__index = Notification

Notification.DefaultConfig = {
    Duration = 4,
    Position = UDim2.new(1, -20, 0, 20),
    Size = UDim2.new(0, 300, 0, 60),
    BackgroundColor = Color3.fromRGB(20, 20, 20),
    BackgroundTransparency = 0.2,
    TextColor = Color3.fromRGB(255, 255, 255),
    AccentColor = Color3.fromRGB(0, 170, 255),
    Font = Enum.Font.GothamBold,
    TitleSize = 16,
    MessageSize = 14,
    ParticleConfig = {
        Enabled = true,
        Count = 40,
        MinSize = 1,
        MaxSize = 3,
        FadeTime = 1
    }
}

function Notification.Init(customConfig)
    local self = setmetatable({}, Notification)
    self.Config = table.clone(Notification.DefaultConfig)

    if customConfig then
        for k, v in pairs(customConfig) do
            self.Config[k] = v
        end
    end

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "NotificationGui"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.DisplayOrder = 10 -- Ensure notifications are always on top
    self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    return self
end

function Notification:ShowNotification(title, message)
    local gui = Instance.new("Frame")
    gui.Size = self.Config.Size
    gui.Position = UDim2.new(1, 20, 0, self.Config.Position.Y.Offset)
    gui.AnchorPoint = Vector2.new(1, 0)
    gui.BackgroundColor3 = self.Config.BackgroundColor
    gui.BackgroundTransparency = self.Config.BackgroundTransparency
    gui.BorderSizePixel = 0
    gui.Parent = self.ScreenGui

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = self.Config.Font
    titleLabel.TextSize = self.Config.TitleSize
    titleLabel.TextColor3 = self.Config.TextColor
    titleLabel.Text = title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTransparency = 1
    titleLabel.Parent = gui

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 1, -35)
    messageLabel.Position = UDim2.new(0, 10, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = self.Config.Font
    messageLabel.TextSize = self.Config.MessageSize
    messageLabel.TextColor3 = self.Config.TextColor
    messageLabel.Text = message
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextTransparency = 1
    messageLabel.Parent = gui

    TweenService:Create(gui, TweenInfo.new(0.4), {
        Position = self.Config.Position
    }):Play()
    TweenService:Create(titleLabel, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
    TweenService:Create(messageLabel, TweenInfo.new(0.3), { TextTransparency = 0.2 }):Play()

    task.wait(self.Config.Duration)

    TweenService:Create(gui, TweenInfo.new(0.3), {
        Position = UDim2.new(1, 20, 0, self.Config.Position.Y.Offset)
    }):Play()
    task.wait(0.3)
    gui:Destroy()
end

local Camera = {}
local notifyInstance = Notification.Init()

function Camera:FirstPerson()
    -- Remove any existing camera scripts
    local starterGui = game:GetService("StarterGui")
    for _, child in ipairs(starterGui:GetChildren()) do
        if child.Name == "FirstPersonLock" or child.Name == "ThirdPersonLock" then
            child:Destroy()
        end
    end
    
    -- Create first person script
    local script = Instance.new("LocalScript")
    script.Name = "FirstPersonLock"
    
    -- First person camera script content
    script.Source = [[
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        -- Wait for humanoid
        local humanoid = character:WaitForChild("Humanoid")
        
        -- Set camera type to scriptable
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        
        -- Camera follow function
        local function updateCamera()
            if character and character:FindFirstChild("Head") then
                workspace.CurrentCamera.CFrame = character.Head.CFrame
            end
        end
        
        -- Connect to render stepped
        RunService:BindToRenderStep("FirstPersonCamera", Enum.RenderPriority.Camera.Value, updateCamera)
        
        -- Cleanup when character is removed
        player.CharacterRemoving:Connect(function()
            RunService:UnbindFromRenderStep("FirstPersonCamera")
        end)
    ]]
    
    script.Parent = starterGui
    notifyInstance:ShowNotification("Camera Mode", "Switched to First Person")
end

function Camera:ThirdPerson()
    -- Remove any existing camera scripts
    local starterGui = game:GetService("StarterGui")
    for _, child in ipairs(starterGui:GetChildren()) do
        if child.Name == "FirstPersonLock" or child.Name == "ThirdPersonLock" then
            child:Destroy()
        end
    end
    
    -- Create third person script
    local script = Instance.new("LocalScript")
    script.Name = "ThirdPersonLock"
    
    -- Third person camera script content
    script.Source = [[
        local Players = game:GetService("Players")
        
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        -- Wait for humanoid
        local humanoid = character:WaitForChild("Humanoid")
        
        -- Reset camera to default
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        
        -- Set camera subject to character
        workspace.CurrentCamera.CameraSubject = humanoid
    ]]
    
    script.Parent = starterGui
    notifyInstance:ShowNotification("Camera Mode", "Switched to Third Person")
end

return {
    Camera = Camera,
    Notification = notifyInstance
}
