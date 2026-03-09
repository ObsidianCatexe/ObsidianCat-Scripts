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

local ScriptRunning = true
local Connections = {}
local GUI_NAME = "ObsidianCat_V7_Original"

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
        if v.Name == GUI_NAME then 
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
    log("[MODULE]: Tactical AIM & Wall Check Ready...")
    task.wait(0.3)
    log("[NETWORK]: Establishing Secure Connection...")
    task.wait(0.5)
    log("[SUCCESS]: Full Administrator Access Granted.")
    task.wait(0.8)

    TweenService:Create(TerminalFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.6)
    
    if IntroContainer then 
        IntroContainer:Destroy() 
    end
    
    toggleMenu(true)
    notify("System Ready", "Taktiksel Modüller Başarıyla Yüklendi.")
end)

task.spawn(function()
    task.wait(8.5)
    if not isMenuOpen then
        if IntroContainer then pcall(function() IntroContainer:Destroy() end) end
        toggleMenu(true)
    end
end)

---------------------------------------------------------
-- 6. TOP BAR VE HARDCODED BAŞLIK
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
Title.Text = "ObsidianCat.exe | Blackhawk Rescue Mission 5"

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
            if p.Name == "ObsidianESP_Text" or p.Name == "ObsidianHighlight" then p:Destroy() end 
        end 
    end)
    ScreenGui:Destroy()
end)

---------------------------------------------------------
-- 7. SOL BAR & PROFİL PANELİ (HATA DÜZELTİLDİ)
---------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Size = UDim2.new(0, 160, 1, -42)
-- İŞTE CİNAYET SEBEBİ OLAN KOD BURADAYDI! DOĞRUSU AŞAĞIDA:
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

-- AYARLARIN TUTULDUĞU TABLO
local Settings = {
    AimLock = false, 
    WallCheck = true,
    ShowFOV = false,
    FOVRadius = 150,
    Smoothness = 2,
    
    PlayerESP = false, 
    NPCESP = false, 
    EspName = false, 
    EspHealth = false, 
    EspType = false
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
    pl.SortOrder = Enum.SortOrder.LayoutOrder -- SIRA KARIŞMASINI ÖNLER
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

local function createToggle(name, settingKey, page)
    local frame = Instance.new("Frame")
    frame.Parent = page
    frame.Size = UDim2.new(1, -10, 0, 42)
    frame.BackgroundColor3 = Palette.PanelBG
    frame.LayoutOrder = #page:GetChildren() -- SIRA DÜZENİ
    
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
    end)
end

local function createSlider(name, min, max, default, settingKey, page)
    Settings[settingKey] = default
    
    local frame = Instance.new("Frame")
    frame.Parent = page
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundColor3 = Palette.PanelBG
    frame.LayoutOrder = #page:GetChildren() -- SIRA DÜZENİ
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0.04, 0, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Palette.TextTitle
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBG = Instance.new("Frame")
    sliderBG.Parent = frame
    sliderBG.Size = UDim2.new(0.92, 0, 0, 6)
    sliderBG.Position = UDim2.new(0.04, 0, 0, 30)
    sliderBG.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    
    local sbgC = Instance.new("UICorner")
    sbgC.CornerRadius = UDim.new(1, 0)
    sbgC.Parent = sliderBG
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBG
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Palette.Accent
    
    local sfC = Instance.new("UICorner")
    sfC.CornerRadius = UDim.new(1, 0)
    sfC.Parent = sliderFill
    
    local btn = Instance.new("TextButton")
    btn.Parent = sliderBG
    btn.Size = UDim2.new(0, 14, 0, 14)
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    btn.BackgroundColor3 = Palette.TextTitle
    btn.Text = ""
    
    local btnC = Instance.new("UICorner")
    btnC.CornerRadius = UDim.new(1, 0)
    btnC.Parent = btn
    
    local dragging = false
    btn.MouseButton1Down:Connect(function() dragging = true end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = false 
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation().X
            local rel = math.clamp((mousePos - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            
            btn.Position = UDim2.new(rel, 0, 0.5, 0)
            sliderFill.Size = UDim2.new(rel, 0, 1, 0)
            label.Text = name .. ": " .. val
            Settings[settingKey] = val
        end
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
    label.LayoutOrder = #page:GetChildren() -- SIRA DÜZENİ
end

---------------------------------------------------------
-- 9. SEKMELER (AİMBOT VE ESP AYRILDI)
---------------------------------------------------------
local CombatPage = createTab("Combat", "🎯", true)
local VisualsPage = createTab("Visuals", "👁️", false)

-- COMBAT (AİMBOT)
createSection("WEAPON ASSIST", CombatPage)
createToggle("Akıllı AimLock (Sağ Tık)", "AimLock", CombatPage)
createToggle("Duvar Arkasını Yoksay (Wall Check)", "WallCheck", CombatPage)
createToggle("FOV Çemberini Göster", "ShowFOV", CombatPage)

createSection("AİMBOT AYARLARI", CombatPage)
createSlider("Görüş Alanı (FOV Çapı)", 50, 600, 150, "FOVRadius", CombatPage)
createSlider("Kilitlenme Yumuşaklığı (Smoothness)", 1, 15, 2, "Smoothness", CombatPage)

-- VISUALS (ESP)
createSection("RADAR", VisualsPage)
createToggle("Oyuncu ESP", "PlayerESP", VisualsPage)
createToggle("Düşman/NPC ESP", "NPCESP", VisualsPage)

createSection("ESP DETAYLARI", VisualsPage)
createToggle("İsim Göster", "EspName", VisualsPage)
createToggle("Can (HP) Göster", "EspHealth", VisualsPage)
createToggle("Dost/Düşman Göster", "EspType", VisualsPage)

---------------------------------------------------------
-- 10. FOV ÇİZİMİ, DUVAR TARAMASI VE HİLE MANTIĞI
---------------------------------------------------------

-- Ekrana Çizilecek FOV Dairesi
local FOVFrame = Instance.new("Frame")
FOVFrame.Parent = ScreenGui
FOVFrame.BackgroundTransparency = 1
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Visible = false

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Palette.Accent
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.3
FOVStroke.Parent = FOVFrame

-- NPC Önbellek (Kasmayı Önler)
local EnemyCache = {}

table.insert(Connections, task.spawn(function()
    while task.wait(3) do
        if not ScriptRunning then break end
        pcall(function()
            local tempEnemies = {}
            for i, obj in ipairs(Workspace:GetDescendants()) do
                if i % 1000 == 0 then task.wait() end 
                
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") then
                    if not Players:GetPlayerFromCharacter(obj) and obj.Humanoid.Health > 0 then 
                        table.insert(tempEnemies, obj) 
                    end
                end
            end
            EnemyCache = tempEnemies
        end)
    end
end))

local function updateESP(char, isNPC, nameStr)
    if not char or not char:FindFirstChild("Head") then return end
    
    local isEnabled = (isNPC and Settings.NPCESP) or (not isNPC and Settings.PlayerESP)
    local hl = char:FindFirstChild("ObsidianHighlight")
    
    -- Kutu/Parlama
    if isEnabled then
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "ObsidianHighlight"
            hl.Parent = char
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
        hl.FillColor = isNPC and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 200, 255)
        hl.OutlineColor = Color3.new(1,1,1)
    elseif hl then 
        hl:Destroy() 
    end

    -- İsim, Can ve Tip Yazıları
    local showText = isEnabled and (Settings.EspName or Settings.EspHealth or Settings.EspType)
    local bg = char.Head:FindFirstChild("ObsidianESP_Text")
    
    if showText then
        if not bg then
            bg = Instance.new("BillboardGui")
            bg.Name = "ObsidianESP_Text"
            bg.Parent = char.Head
            bg.Size = UDim2.new(0, 200, 0, 50)
            bg.StudsOffset = Vector3.new(0, 1.5, 0)
            bg.AlwaysOnTop = true
            
            local lbl = Instance.new("TextLabel")
            lbl.Name = "TextLbl"
            lbl.Parent = bg
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.TextStrokeTransparency = 0.2
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 12
        end
        
        local finalStr = ""
        if Settings.EspName then 
            finalStr = finalStr .. nameStr .. "\n" 
        end
        if Settings.EspType then 
            finalStr = finalStr .. (isNPC and "[ DÜŞMAN ]" or "[ OYUNCU ]") .. "\n" 
        end
        if Settings.EspHealth then
            local h = char:FindFirstChild("Humanoid")
            if h then 
                finalStr = finalStr .. "HP: " .. math.floor(h.Health) 
            end
        end
        
        bg.TextLbl.Text = finalStr
        bg.TextLbl.TextColor3 = isNPC and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 200, 255)
    elseif bg then 
        bg:Destroy() 
    end
end

-- Ana Motor
table.insert(Connections, RunService.RenderStepped:Connect(function()
    if not ScriptRunning then return end

    -- FOV Dairesi Güncelleme
    local mousePos = UserInputService:GetMouseLocation()
    if Settings.ShowFOV then
        FOVFrame.Visible = true
        FOVFrame.Size = UDim2.new(0, Settings.FOVRadius * 2, 0, Settings.FOVRadius * 2)
        FOVFrame.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
    else
        FOVFrame.Visible = false
    end

    local possibleTargets = {} 

    pcall(function()
        -- OYUNCU ESP
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                updateESP(p.Character, false, p.Name)
                if Settings.PlayerESP and p.Character:FindFirstChild("Head") then 
                    table.insert(possibleTargets, p.Character.Head) 
                end
            end
        end
        
        -- NPC ESP
        for _, npc in ipairs(EnemyCache) do
            if npc and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                updateESP(npc, true, "Sivil/Düşman")
                if Settings.NPCESP and npc:FindFirstChild("Head") then 
                    table.insert(possibleTargets, npc.Head) 
                end
            end
        end

        -- FPS UYUMLU AKILLI AIMLOCK & WALL CHECK
        if Settings.AimLock and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local closestDist = Settings.FOVRadius -- Sadece FOV içindekilere kitlenir
            local targetHead = nil

            for _, head in ipairs(possibleTargets) do
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    
                    if dist <= closestDist then 
                        -- DUVAR TARAMASI (WALL CHECK) MANTIĞI
                        local isVisible = true
                        
                        if Settings.WallCheck then
                            local rayOrigin = Camera.CFrame.Position
                            local rayDirection = (head.Position - rayOrigin)
                            
                            local rayParams = RaycastParams.new()
                            rayParams.FilterDescendantsInstances = {LocalPlayer.Character, head.Parent}
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                            rayParams.IgnoreWater = true
                            
                            local rayResult = Workspace:Raycast(rayOrigin, rayDirection, rayParams)
                            
                            if rayResult then
                                isVisible = false -- Araya duvar girdi
                            end
                        end
                        
                        if isVisible then
                            closestDist = dist
                            targetHead = head 
                        end
                    end
                end
            end

            -- HEDEF BULUNDUYSA PÜRÜZSÜZCE (SMOOTH) KİTLEN
            if targetHead then
                local pos, vis = Camera:WorldToViewportPoint(targetHead.Position)
                if vis then
                    local smooth = Settings.Smoothness
                    
                    if mousemoverel then
                        -- Gerçekçi (İnsansı) Fare Kaydırma
                        local moveX = (pos.X - mousePos.X) / smooth
                        local moveY = (pos.Y - mousePos.Y) / smooth
                        mousemoverel(moveX, moveY)
                    else
                        -- Eğer exploit mousemoverel desteklemiyorsa kamera bazlı yumuşatma
                        local targetCF = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / smooth)
                    end
                end
            end
        end
    end)
end))

-- İntro bittikten sonra sayfaları yükler
task.spawn(function()
    task.wait(8.6)
    if MainFrame.Visible then 
        cascade(CombatPage) 
    end
end)
