local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Settings = {
    EnableAimbot = false,
    BoxESP = false,
    Tracers = false,
    Box_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Color = Color3.fromRGB(255, 0, 0),
    HealthBar_Color = Color3.fromRGB(0, 255, 0),
    Tracer_Thickness = 1,
    Box_Thickness = 1,
    Tracer_Origin = "Bottom", 
}

local LocalPlayer = Players.LocalPlayer
if not Fluent then
    warn("Fluent library failed to load!")
    return
end


local Window = Fluent:CreateWindow({
    Title = "AIMBOT Universal TEST VERSION", 
    SubTitle = "MADE BY Ogspector",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,  
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.Insert
})

if not Window then
    warn("Failed to create the window!")
    return
end
local function CreateNameLabel(player)
    local label = Drawing.new("Text")
    label.Visible = false
    label.Text = player.Name
    label.Color = Color3.fromRGB(255, 255, 255)
    label.Size = 14
    label.Center = true
    label.Outline = true
    label.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    return label
end
local AimbotSettings = {
    Enabled = false,
    Keybind = Enum.KeyCode.E,
    FOV = 100,
    Smoothness = 5,
    Speed = 5, 
    DrawFOV = true,
    FOVColor = Color3.fromRGB(0, 255, 0),
    HoldKey = true, 
    TeamCheck = true,
    TargetHitbox = "Head", 
}

local Target = nil

local UIActive = false 

-- this aimbot is fucking retarded + the visibiltiy check is broken

local function IsTargetVisible(target)
    local character = target.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    local ray = Ray.new(Camera.CFrame.Position, humanoidRootPart.Position - Camera.CFrame.Position)
    local hit, position = workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
    
    return hit == nil 
end


local function GetClosestTarget()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild(AimbotSettings.TargetHitbox) and player.Character.Humanoid.Health > 0 then
            if AimbotSettings.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            if AimbotSettings.VisibleOnly and not IsTargetVisible(player) then
                continue  
            end

            local screenPoint, onScreen = Camera:WorldToViewportPoint(player.Character[AimbotSettings.TargetHitbox].Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                if distance < shortestDistance and distance <= AimbotSettings.FOV then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end


local function AimAt(target)
    if not target or not target.Character then return end
    local targetPos = target.Character[AimbotSettings.TargetHitbox].Position
    local smoothFactor = AimbotSettings.Smoothness
    local speed = AimbotSettings.Speed
    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), smoothFactor / (100 / speed)) 
end


RunService.RenderStepped:Connect(function()
    if AimbotSettings.Enabled and Target then
        AimAt(Target)
    end
end)


local holdingKey = false
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == AimbotSettings.Keybind then
        if AimbotSettings.HoldKey then
            holdingKey = true
        else
            AimbotSettings.Enabled = not AimbotSettings.Enabled
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == AimbotSettings.Keybind and AimbotSettings.HoldKey then
        holdingKey = false
    end
end)

RunService.RenderStepped:Connect(function()
    if AimbotSettings.HoldKey then
        AimbotSettings.Enabled = holdingKey
    end

    if AimbotSettings.Enabled then
        Target = GetClosestTarget()
    else
        Target = nil
    end
end)

local function ClearTracers(library)
    library.tracer:Remove()
    library.blacktracer:Remove()
end



local Team_Check = {
    TeamCheck = false,
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0),
}


local Team_Check = {
    TeamCheck = false,
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0),
}



local function NewQuad(thickness, color)
    local quad = Drawing.new("Quad")
    quad.Visible = false
    quad.PointA = Vector2.new(0, 0)
    quad.PointB = Vector2.new(0, 0)
    quad.PointC = Vector2.new(0, 0)
    quad.PointD = Vector2.new(0, 0)
    quad.Color = color
    quad.Filled = false
    quad.Thickness = thickness
    quad.Transparency = 1
    return quad
end

local function NewLine(thickness, color)
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    line.Color = color
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

local function Visibility(state, lib)
    for _, obj in pairs(lib) do
        obj.Visible = state
    end
end



    local function Colorize(color)
        for _, obj in pairs(library) do
            if obj ~= library.healthbar and obj ~= library.greenhealth and obj ~= library.blacktracer and obj ~= library.black then
                obj.Color = color
            end
        end
    end

 -- dear god why did someone allow me to code????
local function ESP(plr)
    local library = {
        blacktracer = NewLine(Settings.Tracer_Thickness * 2, Color3.new(0, 0, 0)),
        tracer = NewLine(Settings.Tracer_Thickness, Settings.Tracer_Color),
        black = NewQuad(Settings.Box_Thickness * 2, Color3.new(0, 0, 0)),
        box = NewQuad(Settings.Box_Thickness, Settings.Box_Color),
        healthbar = NewLine(3, Settings.HealthBar_Color),
        greenhealth = NewLine(1.5, Settings.HealthBar_Color),
        
    }

    local function Updater()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.Humanoid.Health > 0 then
                local HumPos, OnScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if OnScreen then
                    local head = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                    local DistanceY = math.clamp((Vector2.new(head.X, head.Y) - Vector2.new(HumPos.X, HumPos.Y)).magnitude, 2, math.huge)

                    if Settings.BoxESP then
                        local function Size(item)
                            item.PointA = Vector2.new(HumPos.X + DistanceY, HumPos.Y - DistanceY * 2)
                            item.PointB = Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY * 2)
                            item.PointC = Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY * 2)
                            item.PointD = Vector2.new(HumPos.X + DistanceY, HumPos.Y + DistanceY * 2)
                        end
                        Size(library.box)
                        Size(library.black)
                        Visibility(true, library)
                    else
                        Visibility(false, library)
                        return
                    end

                  
                    if Settings.Tracers then
                        local origin = Settings.Tracer_Origin
                        local from = origin == "Middle" and Camera.ViewportSize * 0.5 or Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y)
                        library.tracer.From = from
                        library.tracer.To = Vector2.new(HumPos.X, HumPos.Y + DistanceY * 2)
                        library.blacktracer.From = from
                        library.blacktracer.To = Vector2.new(HumPos.X, HumPos.Y + DistanceY * 2)
                        library.tracer.Visible = true
                        library.blacktracer.Visible = true
                    else
                        ClearTracers(library)
                    end

                   
                    if Settings.HealthBar then
                        local d = (Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY * 2) - Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY * 2)).magnitude
                        local healthoffset = plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth * d

                        library.greenhealth.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY * 2)
                        library.greenhealth.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY * 2 - healthoffset)

                        library.healthbar.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY * 2)
                        library.healthbar.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y - DistanceY * 2)

                        library.healthbar.Visible = true
                        library.greenhealth.Visible = true
                    else
                        library.healthbar.Visible = false
                        library.greenhealth.Visible = false
                    end
                else
                    Visibility(false, library)
                end
            else
                Visibility(false, library)
                if not Players:FindFirstChild(plr.Name) then
                    connection:Disconnect()
                end
            end
        end)
    end

    coroutine.wrap(Updater)()
end

for _, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then
        coroutine.wrap(ESP)(v)
    end
end

Players.PlayerAdded:Connect(function(newplr)
    if newplr ~= LocalPlayer then
        coroutine.wrap(ESP)(newplr)
    end
end)

local Tabs = {
    Main = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }),
    VisualsTab = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    
}

Tabs.Main:AddToggle("AimbotEnabled", { Title = "Enable Aimbot", Default = false }):OnChanged(function(val)
    AimbotSettings.Enabled = val
end)

Tabs.Main:AddToggle("VisibleOnlyToggle", {
    Title = "COMING SOON!!!!",
    Default = AimbotSettings.test
}):OnChanged(function(val)
    AimbotSettings.test = val
end)

Tabs.Main:AddSlider("SmoothingSlider", {
    Title = "Aimbot Smoothing",
    Min = 1,
    Max = 10,
    Default = AimbotSettings.Smoothness,
    Rounding = 1
}):OnChanged(function(val)
    AimbotSettings.Smoothness = val
end)
Tabs.Main:AddSlider("FOVSlider", {
    Title = "Aimbot FOV",
    Min = 10,
    Max = 300,
    Default = AimbotSettings.FOV,
    Rounding = 0
}):OnChanged(function(val)
    AimbotSettings.FOV = val
end)


Tabs.Main:AddSlider("SpeedSlider", {
    Title = "Aimbot Speed",
    Min = 1,
    Max = 20, 
    Default = AimbotSettings.Speed,
    Rounding = 1
}):OnChanged(function(val)
    AimbotSettings.Speed = val
end)

Tabs.Main:AddDropdown("HitboxDropdown", {
    Title = "Target Hitbox",
    Values = { "Head", "Torso", "Chest", "HumanoidRootPart" },
    Default = "Head"
}):OnChanged(function(val)
    AimbotSettings.TargetHitbox = val
end)


Tabs.Main:AddToggle("TeamCheckToggle", { Title = "Team Check", Default = true }):OnChanged(function(val)
    AimbotSettings.TeamCheck = val
end)

Tabs.Main:AddKeybind("AimbotKeybind", {
    Title = "Aimbot Keybind",
    Mode = "Hold",
    Default = "LeftAlt"
}):OnChanged(function(key)
    AimbotSettings.Keybind = key
end)



local ToggleBoxESP = Tabs.VisualsTab:AddToggle("Box ESP", { Title = "Enable Box ESP", Default = true })
local ToggleTracers = Tabs.VisualsTab:AddToggle("Tracers", { Title = "Enable Tracers", Default = true })
local ToggleHealthBar = Tabs.VisualsTab:AddToggle("Health Bar", { Title = "Enable Health Bar", Default = true })
local TracerOriginDropdown = Tabs.VisualsTab:AddDropdown("Tracer Origin", {
    Title = "Tracer Origin",
    Values = { "Middle", "Bottom" },
    Default = "Bottom"
})

ToggleBoxESP:OnChanged(function(val)
    Settings.BoxESP = val
end)


ToggleHealthBar:OnChanged(function(val)
    Settings.HealthBar = val
end)

TracerOriginDropdown:OnChanged(function(val)
    Settings.Tracer_Origin = val
end)

ToggleTracers:OnChanged(function(val)
    Settings.Tracers = val
    if val then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer then
                coroutine.wrap(ESP)(v)
            end
        end
    end
end)





SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({})


InterfaceManager:SetFolder("nicehack")
SaveManager:SetFolder("nicehack")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
-- this fucking shit dosent work
Window:OnClose(function()

    AimbotSettings.Enabled = false
    Target = nil 

    Settings.BoxESP = false
    Settings.Tracers = false
    Settings.HealthBar = false


    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
            
                Visibility(false, library)
            end
        end
    end


    ClearTracers(library)


    AimbotSettings.VisibleOnly = false
    Settings.Tracer_Origin = "Bottom"
    Settings.Box_Color = Color3.fromRGB(255, 0, 0)
    Settings.Tracer_Color = Color3.fromRGB(255, 0, 0)
    Settings.HealthBar_Color = Color3.fromRGB(0, 255, 0)
    Settings.Tracer_Thickness = 1
    Settings.Box_Thickness = 1

   
    RunService:Disconnect()  
end)

Window:Display()



