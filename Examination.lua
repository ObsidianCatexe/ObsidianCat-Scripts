local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local ScriptRunning = true
local Connections = {}
local GUI_NAME = "ObsidianCat_Examination"

---------------------------------------------------------
-- 1. GÜVENLİ GUI OLUŞTURMA & TEMİZLİK
---------------------------------------------------------
local targetParent
pcall(function() 
    targetParent = gethui and gethui() or CoreGui 
end)

if not targetParent then 
    targetParent = LocalPlayer:WaitForChild("PlayerGui") 
end

pcall(function()
    for _, v in ipairs(targetParent:GetChildren()) do 
        if v.Name == GUI_NAME or v.Name == "Examination_By_CekLuhanKarsey_V4" then 
            v:Destroy() 
        end 
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 
ScreenGui.Parent = targetParent

---------------------------------------------------------
-- 2. SİYAH-PEMBE ELİT PALET & BLUR EFEKTİ
---------------------------------------------------------
local Palette = {
    MainBG = Color3.fromRGB(12, 12, 15),    
    PanelBG = Color3.fromRGB(18, 18, 22),   
    Accent = Color3.fromRGB(255, 105, 180), 
    TextTitle = Color3.fromRGB(255, 255, 255), 
    TextDesc = Color3.fromRGB(160, 160, 170),  
    WinClose = Color3.fromRGB(255, 50, 50),   
    WinMin = Color3.fromRGB(255, 182, 193),   
    BadgeBG = Color3.fromRGB(255, 200, 60) 
}

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Enabled = true
pcall(function() 
    BlurEffect.Parent = Lighting 
end)

---------------------------------------------------------
-- 3. BİLDİRİM SİSTEMİ (NOTIFICATIONS)
---------------------------------------------------------
local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Parent = ScreenGui
NotifContainer.Size = UDim2.new(0, 250, 1, 0)
NotifContainer.Position = UDim2.new(1, -260, 0, 0)
NotifContainer.BackgroundTransparency = 1

local NotifList = Instance.new("UIListLayout")
NotifList.Parent = NotifContainer
NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifList.Padding = UDim.new(0, 10)

local NotifPad = Instance.new("UIPadding")
NotifPad.Parent = NotifContainer
NotifPad.PaddingBottom = UDim.new(0, 20)

local function notify(title, text)
    pcall(function()
        local f = Instance.new("Frame")
        f.Parent = NotifContainer
        f.Size = UDim2.new(1, 0, 0, 0)
        f.BackgroundColor3 = Palette.PanelBG
        f.BorderSizePixel = 0
        f.ClipsDescendants = true

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = f

        local stroke = Instance.new("UIStroke")
        stroke.Color = Palette.Accent
        stroke.Thickness = 1.2
        stroke.Parent = f
        
        local t = Instance.new("TextLabel")
        t.Parent = f
        t.Size = UDim2.new(1, -10, 0, 20)
        t.Position = UDim2.new(0, 10, 0, 5)
        t.BackgroundTransparency = 1
        t.Text = title
        t.TextColor3 = Palette.Accent
        t.Font = Enum.Font.GothamBold
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        
        local d = Instance.new("TextLabel")
        d.Parent = f
        d.Size = UDim2.new(1, -10, 0, 25)
        d.Position = UDim2.new(0, 10, 0, 25)
        d.BackgroundTransparency = 1
        d.Text = text
        d.TextColor3 = Palette.TextDesc
        d.Font = Enum.Font.Gotham
        d.TextSize = 11
        d.TextXAlignment = Enum.TextXAlignment.Left
        
        TweenService:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 60)}):Play()
        
        task.delay(3, function()
            if f then 
                TweenService:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                task.wait(0.4)
                f:Destroy() 
            end
        end)
    end)
end

---------------------------------------------------------
-- 4. ANA MENÜ ÇERÇEVESİ
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 0, 0, 0) 
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5) 
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Palette.MainBG
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true 

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Palette.Accent
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.5
MainStroke.Parent = MainFrame

local isMenuOpen = false
local isAnimating = false

local function toggleMenu(forceOpen)
    if isAnimating then return end
    isAnimating = true
    
    if isMenuOpen and not forceOpen then
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        if BlurEffect then TweenService:Create(BlurEffect, TweenInfo.new(0.4), {Size = 0}):Play() end
        task.wait(0.4)
        MainFrame.Visible = false
        isMenuOpen = false
    else
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 760, 0, 460)}):Play()
        if BlurEffect then TweenService:Create(BlurEffect, TweenInfo.new(0.5), {Size = 24}):Play() end
        task.wait(0.5)
        isMenuOpen = true
    end
    isAnimating = false
end

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then 
        toggleMenu() 
    end
end))

---------------------------------------------------------
-- 5. KEDİ İNTROSU VE TERMİNAL
---------------------------------------------------------
local IntroContainer = Instance.new("Frame")
IntroContainer.Parent = ScreenGui
IntroContainer.Size = UDim2.new(1, 0, 1, 0)
IntroContainer.BackgroundTransparency = 1
IntroContainer.BorderSizePixel = 0

local TerminalFrame = Instance.new("Frame")
TerminalFrame.Parent = IntroContainer
TerminalFrame.Size = UDim2.new(0, 0, 0, 2)
TerminalFrame.AnchorPoint = Vector2.new(0.5, 0.5)
TerminalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TerminalFrame.BackgroundColor3 = Palette.PanelBG
TerminalFrame.ClipsDescendants = true

local TermCorner = Instance.new("UICorner")
TermCorner.CornerRadius = UDim.new(0, 8)
TermCorner.Parent = TerminalFrame

local TermStroke = Instance.new("UIStroke")
TermStroke.Color = Palette.Accent
TermStroke.Parent = TerminalFrame

local TerminalText = Instance.new("TextLabel")
TerminalText.Parent = TerminalFrame
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
    TweenService:Create(TerminalFrame, TweenInfo.new(0.6), {Size = UDim2.new(0, 440, 0, 400)}):Play()
    task.wait(0.6)
    
    local function log(txt)
        local lines = string.split(TerminalText.Text, "\n")
        if #lines > 20 then table.remove(lines, 1); TerminalText.Text = table.concat(lines, "\n") end
        for i = 1, #txt do 
            TerminalText.Text = TerminalText.Text .. string.sub(txt, i, i)
            task.wait(0.005) 
        end
        TerminalText.Text = TerminalText.Text .. "\n"
    end
    
    log(" ")
    log("                       /\\_/\\")
    log("                      ( o.o )")
    log("                       > ^ <")
    log(" ")
    log("---------------------------------------------------")
    log("[SYSTEM]: ObsidianCat.exe v7.1 Initiated")
    task.wait(0.4)
    log("[MODULE]: Loading Examination Scripts...")
    task.wait(0.3)
    log("[CACHE]: Initializing Monster & Item Radar...")
    task.wait(0.5)
    log("[NETWORK]: Anti-Drop Protocol Active.")
    task.wait(0.6)
    log("[SUCCESS]: Full Administrator Access Granted.")
    task.wait(0.8)

    TweenService:Create(TerminalFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.6)
    
    if IntroContainer then 
        IntroContainer:Destroy() 
    end
    
    toggleMenu(true)
    notify("System Ready", "Examination Modülleri Başarıyla Yüklendi.")
end)

task.spawn(function()
    task.wait(8.5)
    if not isMenuOpen then
        if IntroContainer then pcall(function() IntroContainer:Destroy() end) end
        toggleMenu(true)
    end
end)

---------------------------------------------------------
-- 6. TOP BAR VE BAŞLIK
---------------------------------------------------------
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundTransparency = 1

local TitleLayout = Instance.new("Frame")
TitleLayout.Parent = TopBar
TitleLayout.Size = UDim2.new(0.7, 0, 1, 0)
TitleLayout.Position = UDim2.new(0.03, 0, 0, 0)
TitleLayout.BackgroundTransparency = 1

local TitleList = Instance.new("UIListLayout")
TitleList.Parent = TitleLayout
TitleList.FillDirection = Enum.FillDirection.Horizontal
TitleList.VerticalAlignment = Enum.VerticalAlignment.Center
TitleList.Padding = UDim.new(0, 8)

local VersionBadge = Instance.new("Frame")
VersionBadge.Parent = TitleLayout
VersionBadge.Size = UDim2.new(0, 42, 0, 20)
VersionBadge.BackgroundColor3 = Palette.BadgeBG
VersionBadge.BorderSizePixel = 0

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.Parent = VersionBadge
BadgeCorner.CornerRadius = UDim.new(1, 0) 

local VersionText = Instance.new("TextLabel")
VersionText.Parent = VersionBadge
VersionText.Size = UDim2.new(1, 0, 1, 0)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v7.1"
VersionText.TextColor3 = Color3.fromRGB(0, 0, 0)
VersionText.Font = Enum.Font.GothamBold
VersionText.TextSize = 11

local Title = Instance.new("TextLabel")
Title.Parent = TitleLayout
Title.AutomaticSize = Enum.AutomaticSize.X
Title.Size = UDim2.new(0, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Palette.TextTitle
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "ObsidianCat.exe | Examination"

local origBrightness = Lighting.Brightness
local origClock = Lighting.ClockTime
local origFog = Lighting.FogEnd
local origShadows = Lighting.GlobalShadows
local origAmbient = Lighting.Ambient

local Controls = Instance.new("Frame")
Controls.Parent = TopBar
Controls.Size = UDim2.new(0, 100, 0, 30)
Controls.Position = UDim2.new(1, -110, 0.5, -15)
Controls.BackgroundTransparency = 1

local CtrlList = Instance.new("UIListLayout")
CtrlList.Parent = Controls
CtrlList.FillDirection = Enum.FillDirection.Horizontal
CtrlList.HorizontalAlignment = Enum.HorizontalAlignment.Right
CtrlList.Padding = UDim.new(0, 8)
CtrlList.VerticalAlignment = Enum.VerticalAlignment.Center

local function createWinBtn(text, color, callback)
    local b = Instance.new("TextButton")
    b.Parent = Controls
    b.Size = UDim2.new(0, 24, 0, 24)
    b.BackgroundColor3 = Palette.PanelBG
    b.Text = text
    b.TextColor3 = color
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BorderSizePixel = 0
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = b
    
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = 0.5
    s.Parent = b
    
    b.MouseButton1Click:Connect(callback)
end

createWinBtn("_", Palette.WinMin, function() toggleMenu() end)
createWinBtn("✖", Palette.WinClose, function()
    ScriptRunning = false
    if BlurEffect then BlurEffect:Destroy() end
    for _, conn in ipairs(Connections) do pcall(function() conn:Disconnect() end) end
    pcall(function() 
        for _, p in ipairs(Workspace:GetDescendants()) do 
            if p.Name == "DevESP_Item" or p.Name == "DevESP_Ent" then p:Destroy() end 
        end 
        Lighting.Brightness = origBrightness
        Lighting.ClockTime = origClock
        Lighting.FogEnd = origFog
        Lighting.GlobalShadows = origShadows
        Lighting.Ambient = origAmbient
    end)
    ScreenGui:Destroy()
end)

---------------------------------------------------------
-- 7. SOL BAR & PROFİL PANELİ
---------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Size = UDim2.new(0, 160, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Palette.PanelBG
Sidebar.BorderSizePixel = 0

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = Sidebar

local SidebarList = Instance.new("UIListLayout")
SidebarList.Parent = Sidebar
SidebarList.Padding = UDim.new(0, 8)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SidebarPad = Instance.new("UIPadding")
SidebarPad.Parent = Sidebar
SidebarPad.PaddingTop = UDim.new(0, 15)

-- Profil Paneli
local ProfilePanel = Instance.new("Frame")
ProfilePanel.Parent = MainFrame
ProfilePanel.Size = UDim2.new(0, 180, 1, -42)
ProfilePanel.Position = UDim2.new(1, -195, 0, 42)
ProfilePanel.BackgroundColor3 = Palette.PanelBG
ProfilePanel.BorderSizePixel = 0

local ProfCorner = Instance.new("UICorner")
ProfCorner.CornerRadius = UDim.new(0, 10)
ProfCorner.Parent = ProfilePanel

local ProfStroke = Instance.new("UIStroke")
ProfStroke.Parent = ProfilePanel
ProfStroke.Color = Palette.Accent
ProfStroke.Transparency = 0.7

local AvatarFrame = Instance.new("Frame")
AvatarFrame.Parent = ProfilePanel
AvatarFrame.Size = UDim2.new(0, 100, 0, 100)
AvatarFrame.Position = UDim2.new(0.5, -50, 0, 20)
AvatarFrame.BackgroundColor3 = Palette.MainBG

local AvCorner = Instance.new("UICorner")
AvCorner.CornerRadius = UDim.new(1, 0)
AvCorner.Parent = AvatarFrame

local AvStroke = Instance.new("UIStroke")
AvStroke.Parent = AvatarFrame
AvStroke.Color = Palette.Accent
AvStroke.Thickness = 2.5

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Parent = AvatarFrame
AvatarImage.Size = UDim2.new(1, 0, 1, 0)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image = "rbxthumb://type=AvatarBust&id=" .. LocalPlayer.UserId .. "&w=150&h=150"

local AvImgCorner = Instance.new("UICorner")
AvImgCorner.CornerRadius = UDim.new(1, 0)
AvImgCorner.Parent = AvatarImage

local DisplayNameLabel = Instance.new("TextLabel")
DisplayNameLabel.Parent = ProfilePanel
DisplayNameLabel.Size = UDim2.new(1, -10, 0, 20)
DisplayNameLabel.Position = UDim2.new(0, 5, 0, 130)
DisplayNameLabel.BackgroundTransparency = 1
DisplayNameLabel.Text = LocalPlayer.DisplayName
DisplayNameLabel.TextColor3 = Palette.TextTitle
DisplayNameLabel.Font = Enum.Font.GothamBold
DisplayNameLabel.TextSize = 14

local RealNameLabel = Instance.new("TextLabel")
RealNameLabel.Parent = ProfilePanel
RealNameLabel.Size = UDim2.new(1, -10, 0, 20)
RealNameLabel.Position = UDim2.new(0, 5, 0, 145)
RealNameLabel.BackgroundTransparency = 1
RealNameLabel.Text = "@" .. LocalPlayer.Name
RealNameLabel.TextColor3 = Palette.TextDesc
RealNameLabel.Font = Enum.Font.Gotham
RealNameLabel.TextSize = 11

local HealthLabel = Instance.new("TextLabel")
HealthLabel.Parent = ProfilePanel
HealthLabel.Size = UDim2.new(1, -10, 0, 20)
HealthLabel.Position = UDim2.new(0, 5, 0, 175)
HealthLabel.BackgroundTransparency = 1
HealthLabel.Text = "HP: Yükleniyor..."
HealthLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
HealthLabel.Font = Enum.Font.GothamMedium
HealthLabel.TextSize = 11

local SessionTimeBG = Instance.new("Frame")
SessionTimeBG.Parent = ProfilePanel
SessionTimeBG.Size = UDim2.new(0.9, 0, 0, 30)
SessionTimeBG.AnchorPoint = Vector2.new(0.5, 1)
SessionTimeBG.Position = UDim2.new(0.5, 0, 1, -10)
SessionTimeBG.BackgroundColor3 = Palette.MainBG

local SesCorner = Instance.new("UICorner")
SesCorner.CornerRadius = UDim.new(0, 6)
SesCorner.Parent = SessionTimeBG

local SesStroke = Instance.new("UIStroke")
SesStroke.Parent = SessionTimeBG
SesStroke.Color = Palette.Accent

local SessionTimeLabel = Instance.new("TextLabel")
SessionTimeLabel.Parent = SessionTimeBG
SessionTimeLabel.Size = UDim2.new(1, 0, 1, 0)
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
-- 8. CASCADING ANIMATIONS & İÇERİK MANTIĞI
---------------------------------------------------------
local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Size = UDim2.new(1, -380, 1, -42)
ContentArea.Position = UDim2.new(0, 175, 0, 42)
ContentArea.BackgroundTransparency = 1

local OriginalSizes = {}
local function cascade(page)
    local delayTime = 0
    for _, item in ipairs(page:GetChildren()) do
        if item:IsA("Frame") then
            if not OriginalSizes[item] then 
                OriginalSizes[item] = item.Size 
            end
            
            local tSize = OriginalSizes[item]
            item.Size = UDim2.new(0.4, 0, tSize.Y.Scale, tSize.Y.Offset)
            item.BackgroundTransparency = 1
            
            task.delay(delayTime, function()
                TweenService:Create(item, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
                    Size = tSize, 
                    BackgroundTransparency = 0
                }):Play()
            end)
            
            delayTime = delayTime + 0.05
        end
    end
end

-- SENİN HİLE AYARLARIN
local Settings = {
    FullBright = false,
    AutoInteract = false,
    ClickTP = false,
    ItemESP = false,
    MonsterESP = false,
    PlayerESP = false,
    SpeedBoost = false,
    NoClip = false
}

local Pages = {}
local TabButtons = {}

local function createTab(name, icon, isDefault)
    local btn = Instance.new("TextButton")
    btn.Parent = Sidebar
    btn.Size = UDim2.new(0.85, 0, 0, 38)
    btn.BackgroundColor3 = Palette.Accent
    btn.BackgroundTransparency = isDefault and 0.8 or 1
    btn.Text = "  " .. icon .. "  " .. name
    btn.TextColor3 = isDefault and Palette.Accent or Palette.TextDesc
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    local page = Instance.new("ScrollingFrame")
    page.Parent = ContentArea
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 0
    page.Visible = isDefault
    
    local pl = Instance.new("UIListLayout")
    pl.Parent = page
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Padding = UDim.new(0, 10)
    
    local pad = Instance.new("UIPadding")
    pad.Parent = page
    pad.PaddingTop = UDim.new(0, 10)
    
    table.insert(TabButtons, btn)
    table.insert(Pages, page)
    
    btn.MouseButton1Click:Connect(function()
        if not page.Visible then
            for i, p in ipairs(Pages) do
                p.Visible = (p == page)
                TabButtons[i].BackgroundTransparency = (p == page) and 0.8 or 1
                TabButtons[i].TextColor3 = (p == page) and Palette.Accent or Palette.TextDesc
            end
            cascade(page)
        end
    end)
    return page
end

local function createToggle(name, settingKey, page, callback)
    local frame = Instance.new("Frame")
    frame.Parent = page
    frame.Size = UDim2.new(1, -10, 0, 42)
    frame.BackgroundColor3 = Palette.PanelBG
    frame.LayoutOrder = #page:GetChildren()
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0.04, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Palette.TextTitle
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local tBtn = Instance.new("TextButton")
    tBtn.Parent = frame
    tBtn.Size = UDim2.new(0, 44, 0, 22)
    tBtn.Position = UDim2.new(1, -55, 0.5, -11)
    tBtn.BackgroundColor3 = Settings[settingKey] and Palette.Accent or Color3.fromRGB(30, 30, 35)
    tBtn.Text = ""
    
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = tBtn
    
    local circle = Instance.new("Frame")
    circle.Parent = tBtn
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = Settings[settingKey] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    circle.BackgroundColor3 = Palette.TextDesc
    
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(1, 0)
    cc.Parent = circle
    
    tBtn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        
        TweenService:Create(tBtn, TweenInfo.new(0.3), {
            BackgroundColor3 = Settings[settingKey] and Palette.Accent or Color3.fromRGB(30, 30, 35)
        }):Play()
        
        circle:TweenPosition(
            Settings[settingKey] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8), 
            "Out", 
            "Back", 
            0.3, 
            true
        )
        
        if callback then callback(Settings[settingKey]) end
        local durum = Settings[settingKey] and "Açıldı" or "Kapatıldı"
        notify("Modül Güncellendi", name .. " " .. durum)
    end)
end

local function createSection(name, page)
    local label = Instance.new("TextLabel")
    label.Parent = page
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = "  " .. name
    label.TextColor3 = Palette.Accent
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = #page:GetChildren()
end

---------------------------------------------------------
-- 9. SEKMELER VE HİLE MENÜLERİ
---------------------------------------------------------
local MainPage = createTab("Main", "👑", true)
local ESPPage = createTab("Visuals", "👁️", false)
local MovePage = createTab("Movement", "🏃", false)

-- [MAIN PAGE]
createSection("WORLD & UTILITY", MainPage)
createToggle("FullBright (Karanlığı Sil)", "FullBright", MainPage, function(state)
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = origBrightness
        Lighting.ClockTime = origClock
        Lighting.FogEnd = origFog
        Lighting.GlobalShadows = origShadows
    end
end)
createToggle("Auto-Interact (Kapı/Anahtar Spam)", "AutoInteract", MainPage)
createToggle("Click Teleport (CTRL + Sol Tık)", "ClickTP", MainPage)

-- [VISUALS PAGE]
createSection("ESP (GÖRÜŞ) RADARI", ESPPage)
createToggle("Item ESP (Anahtarları Gör)", "ItemESP", ESPPage)
createToggle("Monster ESP (Yaratığı Gör)", "MonsterESP", ESPPage)
createToggle("Player ESP", "PlayerESP", ESPPage)

-- [MOVEMENT PAGE]
createSection("HAREKET MODÜLLERİ", MovePage)
createToggle("Speed Boost (Hızlı Koşma)", "SpeedBoost", MovePage)
createToggle("NoClip (Duvarlardan Geçme)", "NoClip", MovePage)

---------------------------------------------------------
-- 10. SENİN ÖZEL DROP ÇÖZÜMLÜ CACHE SİSTEMİN
---------------------------------------------------------
local ItemCache = {}
local EntityCache = {}

table.insert(Connections, task.spawn(function()
    while task.wait(5) do 
        if not ScriptRunning then break end
        
        local tempItems = {}
        local tempEntities = {}
        local allDescendants = Workspace:GetDescendants()
        
        for i, obj in ipairs(allDescendants) do
            if not ScriptRunning then break end
            
            if obj:IsA("ProximityPrompt") then
                table.insert(tempItems, obj)
            elseif obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= LocalPlayer.Character then
                table.insert(tempEntities, obj)
            end
            
            -- Senin efsane FPS koruma sistemin
            if i % 500 == 0 then
                RunService.Heartbeat:Wait()
            end
        end
        
        ItemCache = tempItems
        EntityCache = tempEntities
    end
end))

---------------------------------------------------------
-- 11. HİLE DÖNGÜLERİ (RENDER STEPPED & MOUSE)
---------------------------------------------------------
table.insert(Connections, RunService.RenderStepped:Connect(function()
    if not ScriptRunning then return end

    -- AUTO-INTERACT
    if Settings.AutoInteract and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrpPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, prompt in ipairs(ItemCache) do
            if prompt.Parent and prompt.Parent:IsA("BasePart") then
                if (prompt.Parent.Position - hrpPos).Magnitude <= prompt.MaxActivationDistance then
                    prompt.HoldDuration = 0
                    prompt:InputHoldBegin()
                    prompt:InputHoldEnd()
                end
            end
        end
    end

    -- ITEM ESP (Highlight Sınırına Takılmamak İçin Mesafe Korumalı)
    if Settings.ItemESP and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrpPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, prompt in ipairs(ItemCache) do
            if prompt.Parent and prompt.Parent:IsA("BasePart") then
                local hl = prompt.Parent:FindFirstChild("DevESP_Item")
                if (prompt.Parent.Position - hrpPos).Magnitude < 200 then
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "DevESP_Item"
                        hl.FillColor = Color3.fromRGB(0, 255, 0)
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = prompt.Parent
                    end
                elseif hl then
                    hl:Destroy()
                end
            end
        end
    else
        for _, prompt in ipairs(ItemCache) do
            if prompt.Parent then
                local hl = prompt.Parent:FindFirstChild("DevESP_Item")
                if hl then hl:Destroy() end
            end
        end
    end

    -- ENTITY / MONSTER / PLAYER ESP
    for _, obj in ipairs(EntityCache) do
        local isPlayer = Players:GetPlayerFromCharacter(obj)
        local hl = obj:FindFirstChild("DevESP_Ent")
        
        if (isPlayer and Settings.PlayerESP) or (not isPlayer and Settings.MonsterESP) then
            if not hl then
                hl = Instance.new("Highlight")
                hl.Name = "DevESP_Ent"
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = obj
            end
            hl.FillColor = isPlayer and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(255, 0, 0)
        elseif hl then 
            hl:Destroy() 
        end
    end
end))

-- MOVEMENT (HIZ VE NOCLIP)
table.insert(Connections, RunService.Stepped:Connect(function()
    if not ScriptRunning then return end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            if Settings.SpeedBoost then
                hum.WalkSpeed = 45
            else
                if hum.WalkSpeed == 45 then hum.WalkSpeed = 16 end
            end
        end
        if Settings.NoClip then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end))

-- TIKLAYARAK IŞINLANMA (CLICK TP)
table.insert(Connections, Mouse.Button1Down:Connect(function()
    if not ScriptRunning then return end
    if Settings.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if Mouse.Hit and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 4, 0))
        end
    end
end))

-- İntro bittikten sonra sayfaları yükler
task.spawn(function()
    task.wait(8.6)
    if MainFrame.Visible then 
        cascade(MainPage) 
    end
end)
