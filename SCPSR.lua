--===================================================================================--
-- OBSIDIANCAT V7.1 - SCP ROLEPLAY (FULL ANIMATIONS + FAILSAFE + NO DROP)
-- By CekLuhanKarsey
--===================================================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local ScriptRunning = true
local Connections = {}
local GUI_NAME = "ObsidianCat_SCP_Animated"

---------------------------------------------------------
-- 1. SAFE GUI CREATION & CLEANUP
---------------------------------------------------------
local targetParent = CoreGui
pcall(function() if gethui then targetParent = gethui() end end)
if not targetParent then targetParent = LocalPlayer:WaitForChild("PlayerGui") end

pcall(function()
    for _, v in ipairs(targetParent:GetChildren()) do 
        if v.Name == GUI_NAME or v.Name:find("ObsidianCat") then 
            v:Destroy() 
        end 
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetParent

---------------------------------------------------------
-- 2. ELITE BLACK-PINK PALETTE
---------------------------------------------------------
local Palette = {
    MainBG = Color3.fromRGB(12, 12, 15),    
    PanelBG = Color3.fromRGB(18, 18, 22),   
    Accent = Color3.fromRGB(255, 105, 180), 
    TextTitle = Color3.fromRGB(255, 255, 255), 
    TextDesc = Color3.fromRGB(160, 160, 170)
}

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Name = "ObsidianBlur"
BlurEffect.Size = 0
BlurEffect.Enabled = true
pcall(function() 
    if Lighting:FindFirstChild("ObsidianBlur") then Lighting.ObsidianBlur:Destroy() end
    BlurEffect.Parent = Lighting 
end)

---------------------------------------------------------
-- 3. NOTIFICATION SYSTEM (ANIMATED)
---------------------------------------------------------
local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 250, 1, 0)
NotifContainer.Position = UDim2.new(1, -260, 0, 0)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifList = Instance.new("UIListLayout")
NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifList.Padding = UDim.new(0, 10)
NotifList.Parent = NotifContainer

local NotifPad = Instance.new("UIPadding")
NotifPad.PaddingBottom = UDim.new(0, 20)
NotifPad.Parent = NotifContainer

local function notify(title, text)
    pcall(function()
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 0)
        f.BackgroundColor3 = Palette.PanelBG
        f.BorderSizePixel = 0
        f.ClipsDescendants = true
        f.Parent = NotifContainer

        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        local stroke = Instance.new("UIStroke", f)
        stroke.Color = Palette.Accent
        stroke.Thickness = 1.2
        
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -10, 0, 20)
        t.Position = UDim2.new(0, 10, 0, 5)
        t.BackgroundTransparency = 1
        t.Text = title
        t.TextColor3 = Palette.Accent
        t.Font = Enum.Font.GothamBold
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = f
        
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -10, 0, 25)
        d.Position = UDim2.new(0, 10, 0, 25)
        d.BackgroundTransparency = 1
        d.Text = text
        d.TextColor3 = Palette.TextDesc
        d.Font = Enum.Font.Gotham
        d.TextSize = 11
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = f
        
        -- Animation with Failsafe
        pcall(function() TweenService:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 60)}):Play() end)
        task.delay(0.45, function() if f then f.Size = UDim2.new(1, 0, 0, 60) end end)
        
        task.delay(3, function()
            if f then 
                pcall(function() TweenService:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)}):Play() end)
                task.wait(0.4)
                f:Destroy() 
            end
        end)
    end)
end

---------------------------------------------------------
-- 4. MAIN MENU (ANIMATED WITH FAILSAFE)
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Starts at 0 for animation
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5) 
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Palette.MainBG
MainFrame.Visible = false 
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.ClipsDescendants = true 
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Palette.Accent
MainStroke.Thickness = 1.2

local isMenuOpen = false
local isAnimating = false

local function toggleMenu(forceOpen)
    if isAnimating then return end
    isAnimating = true
    
    if isMenuOpen and not forceOpen then
        pcall(function() TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play() end)
        pcall(function() if BlurEffect then TweenService:Create(BlurEffect, TweenInfo.new(0.4), {Size = 0}):Play() end end)
        task.delay(0.4, function() MainFrame.Visible = false; isMenuOpen = false; isAnimating = false end)
    else
        MainFrame.Visible = true
        pcall(function() TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 700, 0, 420)}):Play() end)
        pcall(function() if BlurEffect then TweenService:Create(BlurEffect, TweenInfo.new(0.5), {Size = 24}):Play() end end)
        
        -- THE LIFESAVER: If Tween fails, force the size!
        task.delay(0.55, function() 
            if MainFrame.Size.X.Offset < 650 then MainFrame.Size = UDim2.new(0, 700, 0, 420) end
            isMenuOpen = true
            isAnimating = false
        end)
    end
end

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then 
        toggleMenu() 
    end
end))

---------------------------------------------------------
-- 5. CAT INTRO & TERMINAL (SLOW BOOT)
---------------------------------------------------------
local IntroContainer = Instance.new("Frame", ScreenGui)
IntroContainer.Size = UDim2.new(1, 0, 1, 0)
IntroContainer.BackgroundTransparency = 1

local TerminalFrame = Instance.new("Frame", IntroContainer)
TerminalFrame.Size = UDim2.new(0, 0, 0, 2)
TerminalFrame.AnchorPoint = Vector2.new(0.5, 0.5)
TerminalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TerminalFrame.BackgroundColor3 = Palette.PanelBG
TerminalFrame.ClipsDescendants = true
Instance.new("UICorner", TerminalFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", TerminalFrame).Color = Palette.Accent

local TerminalText = Instance.new("TextLabel", TerminalFrame)
TerminalText.Size = UDim2.new(0.95, 0, 0.9, 0)
TerminalText.Position = UDim2.new(0.025, 0, 0.05, 0)
TerminalText.BackgroundTransparency = 1
TerminalText.Text = ""
TerminalText.TextColor3 = Palette.Accent
TerminalText.Font = Enum.Font.Code
TerminalText.TextSize = 16
TerminalText.TextXAlignment = Enum.TextXAlignment.Left
TerminalText.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    pcall(function() TweenService:Create(TerminalFrame, TweenInfo.new(0.5), {Size = UDim2.new(0, 440, 0, 400)}):Play() end)
    task.delay(0.55, function() TerminalFrame.Size = UDim2.new(0, 440, 0, 400) end)
    task.wait(0.6)
    
    local t = ""
    local function log(txt)
        pcall(function()
            t = t .. txt .. "\n"
            TerminalText.Text = t
        end)
        task.wait(0.4) 
    end
    
    log("                       /\\_/\\")
    log("                      ( o.o )")
    log("                       > ^ <")
    log("---------------------------------------------------")
    log("[SYSTEM]: ObsidianCat.exe v7.1 Initiated")
    log("[MODULE]: Interface Engine Started...")
    log("[MODULE]: Loading SCP Tactical Cheats...")
    log("[NETWORK]: Anti-Crash Protection Active.")
    log("[SUCCESS]: System Fully Ready.")
    
    task.wait(0.5)
    
    pcall(function() TweenService:Create(TerminalFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play() end)
    task.wait(0.5)
    
    if IntroContainer then IntroContainer:Destroy() end
    if not isMenuOpen then toggleMenu(true) end
    notify("System Ready", "All Modules Injected Successfully.")
end)

-- ABSOLUTE FAILSAFE
task.spawn(function()
    task.wait(7)
    if not isMenuOpen then
        if IntroContainer then IntroContainer:Destroy() end
        toggleMenu(true)
    end
end)

---------------------------------------------------------
-- 6. TOP BAR & PROFILE PANEL
---------------------------------------------------------
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Palette.PanelBG
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0.03, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Palette.TextTitle
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "ObsidianCat.exe | SCP Roleplay"

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundColor3 = Palette.MainBG
CloseBtn.Text = "✖"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local origLighting = {b = Lighting.Brightness, t = Lighting.ClockTime, f = Lighting.FogEnd, s = Lighting.GlobalShadows}

CloseBtn.MouseButton1Click:Connect(function()
    ScriptRunning = false
    if BlurEffect then BlurEffect:Destroy() end
    for _, conn in ipairs(Connections) do pcall(function() conn:Disconnect() end) end
    pcall(function() 
        for _, p in ipairs(Workspace:GetDescendants()) do 
            if p.Name == "SadeESP" or p.Name == "SadeESP_Text" or p.Name == "ItemESP" then p:Destroy() end 
        end 
        Lighting.Brightness = origLighting.b
        Lighting.ClockTime = origLighting.t
        Lighting.FogEnd = origLighting.f
        Lighting.GlobalShadows = origLighting.s
    end)
    ScreenGui:Destroy()
end)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 160, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Palette.PanelBG
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)
local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding = UDim.new(0, 8)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 15)

-- Profile Panel
local ProfilePanel = Instance.new("Frame", MainFrame)
ProfilePanel.Size = UDim2.new(0, 180, 1, -42)
ProfilePanel.Position = UDim2.new(1, -195, 0, 42)
ProfilePanel.BackgroundColor3 = Palette.PanelBG
Instance.new("UICorner", ProfilePanel).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", ProfilePanel).Color = Palette.Accent

local AvatarImage = Instance.new("ImageLabel", ProfilePanel)
AvatarImage.Size = UDim2.new(0, 80, 0, 80)
AvatarImage.Position = UDim2.new(0.5, -40, 0, 15)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image = "rbxthumb://type=AvatarBust&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)

local DisplayNameLabel = Instance.new("TextLabel", ProfilePanel)
DisplayNameLabel.Size = UDim2.new(1, -10, 0, 20)
DisplayNameLabel.Position = UDim2.new(0, 5, 0, 105)
DisplayNameLabel.BackgroundTransparency = 1
DisplayNameLabel.Text = LocalPlayer.DisplayName
DisplayNameLabel.TextColor3 = Palette.TextTitle
DisplayNameLabel.Font = Enum.Font.GothamBold
DisplayNameLabel.TextSize = 13

local HealthLabel = Instance.new("TextLabel", ProfilePanel)
HealthLabel.Size = UDim2.new(1, -10, 0, 20)
HealthLabel.Position = UDim2.new(0, 5, 0, 125)
HealthLabel.BackgroundTransparency = 1
HealthLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
HealthLabel.Font = Enum.Font.GothamMedium
HealthLabel.TextSize = 11

local SessionTimeLabel = Instance.new("TextLabel", ProfilePanel)
SessionTimeLabel.Size = UDim2.new(1, -10, 0, 20)
SessionTimeLabel.Position = UDim2.new(0, 5, 1, -25)
SessionTimeLabel.BackgroundTransparency = 1
SessionTimeLabel.TextColor3 = Palette.Accent
SessionTimeLabel.Font = Enum.Font.GothamBold
SessionTimeLabel.TextSize = 11

local startTime = tick()
table.insert(Connections, RunService.RenderStepped:Connect(function()
    if not ScriptRunning then return end
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then 
            HealthLabel.Text = "HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) 
        else
            HealthLabel.Text = "HP: N/A"
        end
        local elapsed = tick() - startTime
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = math.floor(elapsed % 60)
        SessionTimeLabel.Text = string.format("🕒 %02d:%02d:%02d", h, m, s)
    end)
end))

---------------------------------------------------------
-- 7. CASCADE ANIMATIONS (WITH FAILSAFE) & PAGE MANAGER
---------------------------------------------------------
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -380, 1, -42)
ContentArea.Position = UDim2.new(0, 175, 0, 42)
ContentArea.BackgroundTransparency = 1

local Settings = {
    AimLock = false, TriggerBot = false, WallCheck = true, ShowFOV = false, FOVRadius = 150, Smoothness = 2,
    EnemyESP = false, SCPESP = false, AllyESP = false, ItemESP = false,
    EspName = false, EspHealth = false, EspType = false, FullBright = false,
    NoClip = false, SpeedBoost = false, InfJump = false, ClickTP = false, FastInteract = false, AutoInteract = false
}

local Pages = {}
local TabButtons = {}
local OriginalSizes = {}

-- THE CASCADE FIX: Animates, but enforces the size right after!
local function cascade(page)
    local delayTime = 0
    for _, item in ipairs(page:GetChildren()) do
        if item:IsA("Frame") then
            if not OriginalSizes[item] then OriginalSizes[item] = item.Size end
            local tSize = OriginalSizes[item]
            
            item.Size = UDim2.new(0.4, 0, tSize.Y.Scale, tSize.Y.Offset)
            item.BackgroundTransparency = 1
            
            task.delay(delayTime, function()
                pcall(function() TweenService:Create(item, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = tSize, BackgroundTransparency = 0}):Play() end)
                task.delay(0.45, function() 
                    item.Size = tSize 
                    item.BackgroundTransparency = 0
                end) -- THE LIFESAVER
            end)
            delayTime = delayTime + 0.05
        end
    end
end

local function createTab(name, icon, isDefault)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.85, 0, 0, 38)
    btn.BackgroundColor3 = Palette.Accent
    btn.BackgroundTransparency = isDefault and 0.8 or 1
    btn.Text = "  " .. icon .. "  " .. name
    btn.TextColor3 = Palette.TextTitle
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 0
    page.Visible = isDefault
    
    local pl = Instance.new("UIListLayout", page)
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Padding = UDim.new(0, 10)
    Instance.new("UIPadding", page).PaddingTop = UDim.new(0, 10)
    
    table.insert(Pages, page)
    table.insert(TabButtons, btn)
    
    btn.MouseButton1Click:Connect(function()
        if not page.Visible then
            for i, p in ipairs(Pages) do
                p.Visible = (p == page)
                TabButtons[i].BackgroundTransparency = (p == page) and 0.8 or 1
            end
            cascade(page)
        end
    end)
    return page
end

local function createSection(name, page)
    local lbl = Instance.new("TextLabel", page)
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = " " .. name
    lbl.TextColor3 = Palette.Accent
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = #page:GetChildren()
end

local function createToggle(name, settingKey, page)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Palette.PanelBG
    frame.LayoutOrder = #page:GetChildren()
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0.04, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Palette.TextTitle
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local tBtn = Instance.new("TextButton", frame)
    tBtn.Size = UDim2.new(0, 40, 0, 20)
    tBtn.Position = UDim2.new(1, -55, 0.5, -10)
    tBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    tBtn.Text = ""
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame", tBtn)
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = UDim2.new(0, 3, 0.5, -7)
    circle.BackgroundColor3 = Palette.TextDesc
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    tBtn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        
        if Settings[settingKey] then
            tBtn.BackgroundColor3 = Palette.Accent
            pcall(function() circle:TweenPosition(UDim2.new(1, -17, 0.5, -7), "Out", "Quint", 0.2, true) end)
            task.delay(0.25, function() circle.Position = UDim2.new(1, -17, 0.5, -7) end)
        else
            tBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            pcall(function() circle:TweenPosition(UDim2.new(0, 3, 0.5, -7), "Out", "Quint", 0.2, true) end)
            task.delay(0.25, function() circle.Position = UDim2.new(0, 3, 0.5, -7) end)
        end
        notify("Settings Updated", name .. (Settings[settingKey] and " Enabled" or " Disabled"))
    end)
end

local function createSlider(name, min, max, default, settingKey, page)
    Settings[settingKey] = default
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundColor3 = Palette.PanelBG
    frame.LayoutOrder = #page:GetChildren()
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0.04, 0, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Palette.TextTitle
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBG = Instance.new("Frame", frame)
    sliderBG.Size = UDim2.new(0.92, 0, 0, 4)
    sliderBG.Position = UDim2.new(0.04, 0, 0, 25)
    sliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", sliderBG).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame", sliderBG)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Palette.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton", sliderBG)
    btn.Size = UDim2.new(0, 12, 0, 12)
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    btn.BackgroundColor3 = Color3.new(1,1,1)
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    btn.MouseButton1Down:Connect(function() dragging = true end)
    table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))
    
    table.insert(Connections, RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation().X
            local sizeX = sliderBG.AbsoluteSize.X
            if sizeX == 0 then sizeX = 1 end 
            local rel = math.clamp((mousePos - sliderBG.AbsolutePosition.X) / sizeX, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            
            btn.Position = UDim2.new(rel, 0, 0.5, 0)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            label.Text = name .. ": " .. val
            Settings[settingKey] = val
        end
    end))
end

---------------------------------------------------------
-- 8. TABS & MENU BUILDER (ENGLISH)
---------------------------------------------------------
local pgCombat = createTab("Combat", "🎯", true)
local pgVisuals = createTab("Visuals", "👁️", false)
local pgMove = createTab("Movement", "🏃", false)
local pgUtil = createTab("Utility", "⚙️", false)

-- [COMBAT]
createSection("SMART WEAPON ASSIST", pgCombat)
createToggle("Smart AimLock (Right Click)", "AimLock", pgCombat)
createToggle("Auto Fire (TriggerBot)", "TriggerBot", pgCombat)
createToggle("Ignore Behind Walls (Wall Check)", "WallCheck", pgCombat)
createToggle("Show FOV Circle", "ShowFOV", pgCombat)

createSection("AIMBOT SETTINGS", pgCombat)
createSlider("Field of View (FOV Size)", 50, 600, 150, "FOVRadius", pgCombat)
createSlider("Lock Smoothness", 1, 15, 2, "Smoothness", pgCombat)

-- [VISUALS]
createSection("ESP RADAR", pgVisuals)
createToggle("🔴 Enemy ESP (Class-D / Chaos)", "EnemyESP", pgVisuals)
createToggle("🟣 SCP ESP (Monsters)", "SCPESP", pgVisuals)
createToggle("🔵 Ally ESP (Foundation)", "AllyESP", pgVisuals)
createToggle("💳 Item / Keycard ESP", "ItemESP", pgVisuals)

createSection("DETAILS", pgVisuals)
createToggle("Show Name", "EspName", pgVisuals)
createToggle("Show Health", "EspHealth", pgVisuals)
createToggle("Show Type", "EspType", pgVisuals)

createSection("WORLD & ENVIRONMENT", pgVisuals)
createToggle("☀️ Ultra FullBright", "FullBright", pgVisuals)

-- [MOVEMENT]
createSection("PHYSICS MODULES", pgMove)
createToggle("👻 NoClip (Walk Through Walls)", "NoClip", pgMove)
createToggle("⚡ Speed Boost", "SpeedBoost", pgMove)
createToggle("🦘 Infinite Jump", "InfJump", pgMove)

-- [UTILITY]
createSection("EXPLOITS", pgUtil)
createToggle("🛸 Click Teleport (CTRL + Click)", "ClickTP", pgUtil)
createToggle("🔓 Fast Interact (No Wait)", "FastInteract", pgUtil)
createToggle("⚡ Auto-Interact (Auto Pickup)", "AutoInteract", pgUtil)

---------------------------------------------------------
-- 9. OPTIMIZED CACHING SYSTEM (ZERO DROP)
---------------------------------------------------------
local Cache = { Items = {}, NPCs = {}, Prompts = {} }

local function checkAndCache(obj)
    pcall(function()
        if obj:IsA("ProximityPrompt") then
            Cache.Prompts[obj] = true
        elseif obj:IsA("Tool") or (obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "card") or string.find(string.lower(obj.Name), "key"))) then
            Cache.Items[obj] = true
        elseif obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") and not Players:GetPlayerFromCharacter(obj) then
            Cache.NPCs[obj] = true
        end
    end)
end

table.insert(Connections, Workspace.DescendantAdded:Connect(checkAndCache))
table.insert(Connections, Workspace.DescendantRemoving:Connect(function(obj)
    Cache.Prompts[obj] = nil; Cache.Items[obj] = nil; Cache.NPCs[obj] = nil
end))

task.spawn(function()
    local descendants = Workspace:GetDescendants()
    for i, obj in ipairs(descendants) do
        checkAndCache(obj)
        if i % 1500 == 0 then RunService.Heartbeat:Wait() end 
    end
end)

---------------------------------------------------------
-- 10. ESP ENGINE & TEAM LOGIC
---------------------------------------------------------
local FOVFrame = Instance.new("Frame", ScreenGui)
FOVFrame.BackgroundTransparency = 1
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Visible = false
Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", FOVFrame)
fovStroke.Color = Palette.Accent; fovStroke.Thickness = 1.5

local function categorizePlayer(player)
    if not player or typeof(player) ~= "Instance" or not player:IsA("Player") then return "SCP" end
    if not player.Team then return "Ally" end
    local teamName = string.lower(player.Team.Name)
    if string.find(teamName, "class") or string.find(teamName, "d") or string.find(teamName, "chaos") then return "Enemy" end
    if string.find(teamName, "scp") then return "SCP" end
    return "Ally"
end

local function isVisible(targetPart)
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    return not Workspace:Raycast(origin, direction, params)
end

local function updateESP(char, category, nameStr, color)
    if not char or not char:FindFirstChild("Head") then return end
    
    local active = false
    if category == "Enemy" and Settings.EnemyESP then active = true end
    if category == "SCP" and Settings.SCPESP then active = true end
    if category == "Ally" and Settings.AllyESP then active = true end
    if category == "Item" and Settings.ItemESP then active = true end
    
    local hl = char:FindFirstChild("SadeESP")
    if active then
        if not hl then
            hl = Instance.new("Highlight", char)
            hl.Name = "SadeESP"
            hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
        hl.FillColor = color; hl.OutlineColor = Color3.new(1, 1, 1)
    elseif hl then pcall(function() hl:Destroy() end) end

    local showText = active and category ~= "Item" and (Settings.EspName or Settings.EspHealth or Settings.EspType)
    local bg = char.Head:FindFirstChild("SadeESP_Text")
    
    if showText then
        if not bg then
            bg = Instance.new("BillboardGui", char.Head)
            bg.Name = "SadeESP_Text"
            bg.Size = UDim2.new(0, 200, 0, 50)
            bg.StudsOffset = Vector3.new(0, 1.5, 0)
            bg.AlwaysOnTop = true
            local lbl = Instance.new("TextLabel", bg)
            lbl.Name = "Txt"
            lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1
            lbl.TextStrokeTransparency = 0.2; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12
        end
        if bg and bg:FindFirstChild("Txt") then
            local str = ""
            if Settings.EspName then str = str .. nameStr .. "\n" end
            if Settings.EspType then str = str .. "[" .. category .. "]\n" end
            if Settings.EspHealth then
                local h = char:FindFirstChild("Humanoid")
                if h then str = str .. "HP: " .. math.floor(h.Health) end
            end
            bg.Txt.Text = str; bg.Txt.TextColor3 = color
        end
    elseif bg then pcall(function() bg:Destroy() end) end
end

---------------------------------------------------------
-- 11. MAIN HACK LOOP (RENDER STEPPED)
---------------------------------------------------------
local origLighting = {b = Lighting.Brightness, t = Lighting.ClockTime, f = Lighting.FogEnd, s = Lighting.GlobalShadows}

table.insert(Connections, RunService.RenderStepped:Connect(function()
    if not ScriptRunning then return end

    pcall(function()
        local mousePos = UserInputService:GetMouseLocation()
        if Settings.ShowFOV then
            FOVFrame.Visible = true
            FOVFrame.Size = UDim2.new(0, Settings.FOVRadius * 2, 0, Settings.FOVRadius * 2)
            FOVFrame.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
        else
            FOVFrame.Visible = false
        end

        local aimTargets = {}

        -- Player ESP
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local cat = categorizePlayer(p)
                local col = Color3.new(1,1,1)
                if cat == "Enemy" then col = Color3.fromRGB(255, 50, 50) end
                if cat == "SCP" then col = Color3.fromRGB(150, 50, 255) end
                if cat == "Ally" then col = Color3.fromRGB(0, 200, 255) end
                
                updateESP(p.Character, cat, p.Name, col)
                
                if (cat == "Enemy" and Settings.EnemyESP) or (cat == "SCP" and Settings.SCPESP) or (cat == "Ally" and Settings.AllyESP) then
                    if p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        table.insert(aimTargets, p.Character.Head)
                    end
                end
            end
        end
        
        -- NPC/SCP ESP
        for npc, _ in pairs(Cache.NPCs) do
            if npc and npc.Parent then
                updateESP(npc, "SCP", "Entity", Color3.fromRGB(150, 50, 255))
                if Settings.SCPESP and npc:FindFirstChild("Head") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                    table.insert(aimTargets, npc.Head)
                end
            end
        end

        -- Item ESP
        for item, _ in pairs(Cache.Items) do
            if item and item.Parent then
                local part = item:IsA("BasePart") and item or item:FindFirstChild("Handle")
                if part then updateESP(part, "Item", "Item", Color3.fromRGB(0, 255, 150)) end
            end
        end

        -- AimLock
        if Settings.AimLock and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local bestDist = Settings.FOVRadius 
            local targetHead = nil
            for _, head in ipairs(aimTargets) do
                local pos, vis = Camera:WorldToViewportPoint(head.Position)
                if vis then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist <= bestDist then 
                        if not Settings.WallCheck or isVisible(head) then
                            bestDist = dist; targetHead = head 
                        end
                    end
                end
            end
            if targetHead then
                local pos, vis = Camera:WorldToViewportPoint(targetHead.Position)
                if vis then
                    if mousemoverel then
                        mousemoverel((pos.X - mousePos.X) / Settings.Smoothness, (pos.Y - mousePos.Y) / Settings.Smoothness)
                    else
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetHead.Position), 1 / Settings.Smoothness)
                    end
                end
            end
        end

        -- TriggerBot
        if Settings.TriggerBot and Mouse.Target and Mouse.Target.Parent:FindFirstChild("Humanoid") then
            local tPlayer = Players:GetPlayerFromCharacter(Mouse.Target.Parent)
            local cat = categorizePlayer(tPlayer)
            local shouldShoot = false
            if cat == "Enemy" and Settings.EnemyESP then shouldShoot = true end
            if cat == "SCP" and Settings.SCPESP then shouldShoot = true end
            if cat == "Ally" and Settings.AllyESP then shouldShoot = true end
            if shouldShoot and Mouse.Target.Parent.Humanoid.Health > 0 and mouse1click then mouse1click() end
        end

        -- FullBright
        if Settings.FullBright then
            Lighting.Brightness = 3; Lighting.ClockTime = 14; Lighting.FogEnd = 9e9; Lighting.GlobalShadows = false; Lighting.Ambient = Color3.new(1,1,1)
        else
            Lighting.Brightness = origLighting.b; Lighting.ClockTime = origLighting.t; Lighting.FogEnd = origLighting.f; Lighting.GlobalShadows = origLighting.s; Lighting.Ambient = origLighting.Ambient
        end
    end)
end))

---------------------------------------------------------
-- 12. MOVEMENT & INTERACT (STEPPED)
---------------------------------------------------------
table.insert(Connections, RunService.Stepped:Connect(function()
    if not ScriptRunning then return end
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end

        local hum = char:FindFirstChild("Humanoid")
        if hum then
            if Settings.SpeedBoost then hum.WalkSpeed = 40 else if hum.WalkSpeed == 40 then hum.WalkSpeed = 16 end end
        end
        
        if Settings.NoClip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end))

table.insert(Connections, UserInputService.JumpRequest:Connect(function()
    if ScriptRunning and Settings.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

table.insert(Connections, Mouse.Button1Down:Connect(function()
    if ScriptRunning and Settings.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and Mouse.Hit then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 4, 0)) end
    end
end))

table.insert(Connections, task.spawn(function()
    while task.wait(0.1) do
        if not ScriptRunning then break end
        pcall(function()
            if (Settings.FastInteract or Settings.AutoInteract) and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrpPos = LocalPlayer.Character.HumanoidRootPart.Position
                for prompt, _ in pairs(Cache.Prompts) do
                    if prompt and prompt.Parent and prompt.Parent:IsA("BasePart") then
                        if (prompt.Parent.Position - hrpPos).Magnitude <= prompt.MaxActivationDistance then
                            if Settings.FastInteract then prompt.HoldDuration = 0 end
                            if Settings.AutoInteract then
                                prompt:InputHoldBegin()
                                prompt:InputHoldEnd()
                            end
                        end
                    end
                end
            end
        end)
    end
end))

-- Yükleme Animasyonunu Başlat
task.spawn(function()
    task.wait(1)
    if MainFrame.Visible then cascade(CombatPage) end
end)
