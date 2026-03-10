--===================================================================================--
-- OBSIDIANCAT V7.1 - FLING THINGS AND PEOPLE (FULL UNCOMPRESSED & BUG-FREE)
-- By CekLuhanKarsey
-- UYARI: "Color" yazım hatası düzeltildi, UI çökmesi giderildi. Kategoriler eklendi.
--===================================================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local ScriptRunning = true
local Connections = {}
local GUI_NAME = "ObsidianCat_FTAP_Ultimate"

---------------------------------------------------------
-- 1. GÜVENLİ GUI OLUŞTURMA & TEMİZLİK
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
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = targetParent

---------------------------------------------------------
-- 2. SİYAH-PEMBE ELİT PALET
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
BlurEffect.Name = "ObsidianBlur"
BlurEffect.Size = 0
BlurEffect.Enabled = true
pcall(function() 
    if Lighting:FindFirstChild("ObsidianBlur") then Lighting.ObsidianBlur:Destroy() end
    BlurEffect.Parent = Lighting 
end)

---------------------------------------------------------
-- 3. BİLDİRİM SİSTEMİ
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
MainFrame.Size = UDim2.new(0, 0, 0, 0) 
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
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        if BlurEffect then TweenService:Create(BlurEffect, TweenInfo.new(0.4), {Size = 0}):Play() end
        
        task.delay(0.4, function() 
            MainFrame.Visible = false
            isMenuOpen = false
            isAnimating = false 
        end)
    else
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 760, 0, 460)}):Play()
        if BlurEffect then TweenService:Create(BlurEffect, TweenInfo.new(0.5), {Size = 24}):Play() end
        
        task.delay(0.55, function() 
            if MainFrame.Size.X.Offset < 700 then 
                MainFrame.Size = UDim2.new(0, 760, 0, 460) 
            end
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
-- 5. KEDİ İNTROSU
---------------------------------------------------------
local IntroContainer = Instance.new("Frame")
IntroContainer.Size = UDim2.new(1, 0, 1, 0)
IntroContainer.BackgroundTransparency = 1
IntroContainer.Parent = ScreenGui

local TerminalFrame = Instance.new("Frame")
TerminalFrame.Size = UDim2.new(0, 0, 0, 2)
TerminalFrame.AnchorPoint = Vector2.new(0.5, 0.5)
TerminalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TerminalFrame.BackgroundColor3 = Palette.PanelBG
TerminalFrame.ClipsDescendants = true
TerminalFrame.Parent = IntroContainer

Instance.new("UICorner", TerminalFrame).CornerRadius = UDim.new(0, 8)
local TermStroke = Instance.new("UIStroke", TerminalFrame)
TermStroke.Color = Palette.Accent

local TerminalText = Instance.new("TextLabel")
TerminalText.Size = UDim2.new(0.95, 0, 0.9, 0)
TerminalText.Position = UDim2.new(0.025, 0, 0.05, 0)
TerminalText.BackgroundTransparency = 1
TerminalText.Text = ""
TerminalText.TextColor3 = Palette.Accent
TerminalText.Font = Enum.Font.Code
TerminalText.TextSize = 16
TerminalText.TextXAlignment = Enum.TextXAlignment.Left
TerminalText.TextYAlignment = Enum.TextYAlignment.Top
TerminalText.Parent = TerminalFrame

task.spawn(function()
    TweenService:Create(TerminalFrame, TweenInfo.new(0.6), {Size = UDim2.new(0, 440, 0, 400)}):Play()
    task.wait(0.6)
    
    local function log(txt)
        local lines = string.split(TerminalText.Text, "\n")
        if #lines > 20 then 
            table.remove(lines, 1)
            TerminalText.Text = table.concat(lines, "\n") 
        end
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
    log("---------------------------------------------------")
    log("[SYSTEM]: ObsidianCat.exe v7.1 Initiated")
    task.wait(0.4)
    log("[KERNEL]: Fixed Engine Crash Issues...")
    task.wait(0.3)
    log("[NETWORK]: Establishing Secure Connection...")
    task.wait(0.5)
    log("[MODULE]: Loading Fling Things and People...")
    task.wait(0.6)
    log("[SUCCESS]: Arayüz Hazır.")
    task.wait(0.8)

    TweenService:Create(TerminalFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.6)
    
    if IntroContainer then 
        IntroContainer:Destroy() 
    end
    
    toggleMenu(true)
    notify("System Ready", "ObsidianCat.exe fully loaded.")
end)

---------------------------------------------------------
-- 6. TOP BAR VE PROFİL PANELİ
---------------------------------------------------------
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local TitleLayout = Instance.new("Frame")
TitleLayout.Size = UDim2.new(0.7, 0, 1, 0)
TitleLayout.Position = UDim2.new(0.03, 0, 0, 0)
TitleLayout.BackgroundTransparency = 1
TitleLayout.Parent = TopBar

local TitleList = Instance.new("UIListLayout")
TitleList.FillDirection = Enum.FillDirection.Horizontal
TitleList.VerticalAlignment = Enum.VerticalAlignment.Center
TitleList.Padding = UDim.new(0, 8)
TitleList.Parent = TitleLayout

local VersionBadge = Instance.new("Frame")
VersionBadge.Size = UDim2.new(0, 42, 0, 20)
VersionBadge.BackgroundColor3 = Palette.BadgeBG
VersionBadge.BorderSizePixel = 0
VersionBadge.Parent = TitleLayout
Instance.new("UICorner", VersionBadge).CornerRadius = UDim.new(1, 0) 

local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(1, 0, 1, 0)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v7.1"
VersionText.TextColor3 = Color3.fromRGB(0, 0, 0)
VersionText.Font = Enum.Font.GothamBold
VersionText.TextSize = 11
VersionText.Parent = VersionBadge

local Title = Instance.new("TextLabel")
Title.AutomaticSize = Enum.AutomaticSize.X
Title.Size = UDim2.new(0, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Palette.TextTitle
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "ObsidianCat.exe | FTAP Ultimate"
Title.Parent = TitleLayout

local Controls = Instance.new("Frame")
Controls.Size = UDim2.new(0, 100, 0, 30)
Controls.Position = UDim2.new(1, -110, 0.5, -15)
Controls.BackgroundTransparency = 1
Controls.Parent = TopBar

local CtrlList = Instance.new("UIListLayout")
CtrlList.FillDirection = Enum.FillDirection.Horizontal
CtrlList.HorizontalAlignment = Enum.HorizontalAlignment.Right
CtrlList.Padding = UDim.new(0, 8)
CtrlList.VerticalAlignment = Enum.VerticalAlignment.Center
CtrlList.Parent = Controls

local function createWinBtn(text, color, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 24, 0, 24)
    b.BackgroundColor3 = Palette.PanelBG
    b.Text = text
    b.TextColor3 = color
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BorderSizePixel = 0
    b.Parent = Controls
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke", b)
    s.Color = color
    s.Transparency = 0.5
    b.MouseButton1Click:Connect(callback)
end

createWinBtn("_", Palette.WinMin, function() toggleMenu() end)
createWinBtn("✖", Palette.WinClose, function()
    ScriptRunning = false
    if BlurEffect then BlurEffect:Destroy() end
    for _, conn in ipairs(Connections) do 
        pcall(function() conn:Disconnect() end) 
    end
    ScreenGui:Destroy()
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Palette.PanelBG
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 8)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.Parent = Sidebar

local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 15)
SidebarPad.Parent = Sidebar

local ProfilePanel = Instance.new("Frame")
ProfilePanel.Size = UDim2.new(0, 180, 1, -42)
ProfilePanel.Position = UDim2.new(1, -195, 0, 42)
ProfilePanel.BackgroundColor3 = Palette.PanelBG
ProfilePanel.BorderSizePixel = 0
ProfilePanel.Parent = MainFrame
Instance.new("UICorner", ProfilePanel).CornerRadius = UDim.new(0, 10)
local ProfStroke = Instance.new("UIStroke", ProfilePanel)
ProfStroke.Color = Palette.Accent
ProfStroke.Transparency = 0.7

local AvatarFrame = Instance.new("Frame")
AvatarFrame.Size = UDim2.new(0, 100, 0, 100)
AvatarFrame.Position = UDim2.new(0.5, -50, 0, 20)
AvatarFrame.BackgroundColor3 = Palette.MainBG
AvatarFrame.Parent = ProfilePanel
Instance.new("UICorner", AvatarFrame).CornerRadius = UDim.new(1, 0)
local AvStroke = Instance.new("UIStroke", AvatarFrame)
AvStroke.Color = Palette.Accent
AvStroke.Thickness = 2.5

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Size = UDim2.new(1, 0, 1, 0)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image = "rbxthumb://type=AvatarBust&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
AvatarImage.Parent = AvatarFrame
Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)

local DisplayNameLabel = Instance.new("TextLabel")
DisplayNameLabel.Size = UDim2.new(1, -10, 0, 20)
DisplayNameLabel.Position = UDim2.new(0, 5, 0, 130)
DisplayNameLabel.BackgroundTransparency = 1
DisplayNameLabel.Text = LocalPlayer.DisplayName
DisplayNameLabel.TextColor3 = Palette.TextTitle
DisplayNameLabel.Font = Enum.Font.GothamBold
DisplayNameLabel.TextSize = 14
DisplayNameLabel.Parent = ProfilePanel

local RealNameLabel = Instance.new("TextLabel")
RealNameLabel.Size = UDim2.new(1, -10, 0, 20)
RealNameLabel.Position = UDim2.new(0, 5, 0, 145)
RealNameLabel.BackgroundTransparency = 1
RealNameLabel.Text = "@" .. LocalPlayer.Name
RealNameLabel.TextColor3 = Palette.TextDesc
RealNameLabel.Font = Enum.Font.Gotham
RealNameLabel.TextSize = 11
RealNameLabel.Parent = ProfilePanel

-- İŞTE SİMSİYAH EKRANA SEBEP OLAN O HATA BURADAYDI! (Color.fromRGB yerine Color3.fromRGB yapıldı)
local HealthLabel = Instance.new("TextLabel")
HealthLabel.Size = UDim2.new(1, -10, 0, 20)
HealthLabel.Position = UDim2.new(0, 5, 0, 175)
HealthLabel.BackgroundTransparency = 1
HealthLabel.Text = "HP: Loading..."
HealthLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- HATALI KISIM %100 DÜZELTİLDİ
HealthLabel.Font = Enum.Font.GothamMedium
HealthLabel.TextSize = 11
HealthLabel.Parent = ProfilePanel

local SessionTimeBG = Instance.new("Frame")
SessionTimeBG.Size = UDim2.new(0.9, 0, 0, 30)
SessionTimeBG.AnchorPoint = Vector2.new(0.5, 1)
SessionTimeBG.Position = UDim2.new(0.5, 0, 1, -10)
SessionTimeBG.BackgroundColor3 = Palette.MainBG
SessionTimeBG.Parent = ProfilePanel
Instance.new("UICorner", SessionTimeBG).CornerRadius = UDim.new(0, 6)
local SesStroke = Instance.new("UIStroke", SessionTimeBG)
SesStroke.Color = Palette.Accent

local SessionTimeLabel = Instance.new("TextLabel")
SessionTimeLabel.Size = UDim2.new(1, 0, 1, 0)
SessionTimeLabel.BackgroundTransparency = 1
SessionTimeLabel.TextColor3 = Palette.Accent
SessionTimeLabel.Font = Enum.Font.GothamBold
SessionTimeLabel.TextSize = 11
SessionTimeLabel.Parent = SessionTimeBG

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
-- 7. İÇERİK OLUŞTURUCU VE CASCADE ANİMASYON
---------------------------------------------------------
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -380, 1, -42)
ContentArea.Position = UDim2.new(0, 175, 0, 42)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local OriginalSizes = {}

local function cascade(page)
    local delayTime = 0
    for _, item in ipairs(page:GetChildren()) do
        if item:IsA("Frame") then
            if not OriginalSizes[item] then OriginalSizes[item] = item.Size end
            local tSize = OriginalSizes[item]
            item.Size = UDim2.new(0.4, 0, tSize.Y.Scale, tSize.Y.Offset)
            item.BackgroundTransparency = 1
            
            task.delay(delayTime, function()
                pcall(function()
                    TweenService:Create(item, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
                        Size = tSize, 
                        BackgroundTransparency = 0
                    }):Play()
                end)
            end)
            delayTime = delayTime + 0.05
        end
    end
end

local Pages = {}
local TabButtons = {}

local function createTab(name, icon, isDefault)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 38)
    btn.BackgroundColor3 = Palette.Accent
    btn.BackgroundTransparency = isDefault and 0.8 or 1
    btn.Text = "  " .. icon .. "  " .. name
    btn.TextColor3 = isDefault and Palette.TextTitle or Palette.TextDesc
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 0
    page.Visible = isDefault
    page.Parent = ContentArea
    
    local pl = Instance.new("UIListLayout")
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Padding = UDim.new(0, 10)
    pl.Parent = page
    
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.Parent = page
    
    table.insert(TabButtons, btn)
    table.insert(Pages, page)
    
    btn.MouseButton1Click:Connect(function()
        if not page.Visible then
            for i, p in ipairs(Pages) do
                p.Visible = (p == page)
                TabButtons[i].BackgroundTransparency = (p == page) and 0.8 or 1
                TabButtons[i].TextColor3 = (p == page) and Palette.TextTitle or Palette.TextDesc
            end
            cascade(page)
        end
    end)
    return page
end

local function createSection(name, page)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = "  " .. name
    label.TextColor3 = Palette.Accent
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = #page:GetChildren()
    label.Parent = page
end

local function createToggle(name, page, callback, defaultState)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 42)
    frame.BackgroundColor3 = Palette.PanelBG
    frame.LayoutOrder = #page:GetChildren()
    frame.Parent = page
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0.04, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Palette.TextTitle
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local tBtn = Instance.new("TextButton")
    tBtn.Size = UDim2.new(0, 44, 0, 22)
    tBtn.Position = UDim2.new(1, -55, 0.5, -11)
    tBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    tBtn.Text = ""
    tBtn.Parent = frame
    
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = tBtn
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.BackgroundColor3 = Palette.TextDesc
    circle.Parent = tBtn
    
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(1, 0)
    cc.Parent = circle
    
    local active = defaultState or false
    tBtn.BackgroundColor3 = active and Palette.Accent or Color3.fromRGB(30, 30, 35)
    circle.Position = active and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    
    tBtn.MouseButton1Click:Connect(function()
        active = not active
        TweenService:Create(tBtn, TweenInfo.new(0.3), {BackgroundColor3 = active and Palette.Accent or Color3.fromRGB(30, 30, 35)}):Play()
        circle:TweenPosition(active and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8), "Out", "Back", 0.3, true)
        if callback then task.spawn(callback, active) end
        notify("Toggled", name .. (active and " Enabled" or " Disabled"))
    end)
end

local function createSlider(name, min, max, default, page, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundColor3 = Palette.PanelBG
    frame.LayoutOrder = #page:GetChildren()
    frame.Parent = page
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0.04, 0, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Palette.TextTitle
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderBG = Instance.new("Frame")
    sliderBG.Size = UDim2.new(0.92, 0, 0, 6)
    sliderBG.Position = UDim2.new(0.04, 0, 0, 30)
    sliderBG.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    sliderBG.Parent = frame
    
    local sbgC = Instance.new("UICorner")
    sbgC.CornerRadius = UDim.new(1, 0)
    sbgC.Parent = sliderBG
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Palette.Accent
    fill.Parent = sliderBG
    
    local sfC = Instance.new("UICorner")
    sfC.CornerRadius = UDim.new(1, 0)
    sfC.Parent = fill
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 14, 0, 14)
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    btn.BackgroundColor3 = Palette.TextTitle
    btn.Text = ""
    btn.Parent = sliderBG
    
    local btnC = Instance.new("UICorner")
    btnC.CornerRadius = UDim.new(1, 0)
    btnC.Parent = btn
    
    local dragging = false
    btn.MouseButton1Down:Connect(function() dragging = true end)
    
    table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = false 
        end
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
            if callback then task.spawn(callback, val) end
        end
    end))
end

local function createButton(name, page, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 36)
    btn.BackgroundColor3 = Palette.PanelBG
    btn.Text = name
    btn.TextColor3 = Palette.TextTitle
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = page
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    
    local s = Instance.new("UIStroke")
    s.Color = Palette.Accent
    s.Transparency = 0.5
    s.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        if callback then task.spawn(callback) end
        notify("Executed", name)
    end)
end

local function createInput(name, placeholder, page, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 42)
    frame.BackgroundColor3 = Palette.PanelBG
    frame.Parent = page
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = frame
    
    local txtBox = Instance.new("TextBox")
    txtBox.Size = UDim2.new(1, -20, 1, 0)
    txtBox.Position = UDim2.new(0, 10, 0, 0)
    txtBox.BackgroundTransparency = 1
    txtBox.PlaceholderText = placeholder
    txtBox.Text = ""
    txtBox.TextColor3 = Palette.Accent
    txtBox.Font = Enum.Font.GothamBold
    txtBox.TextSize = 13
    txtBox.TextXAlignment = Enum.TextXAlignment.Left
    txtBox.Parent = frame
    
    txtBox.FocusLost:Connect(function()
        if callback then task.spawn(callback, txtBox.Text) end
    end)
end

---------------------------------------------------------
-- 8. FTAP VARIABLES AND SERVICES
---------------------------------------------------------
local GrabEvents, MenuToys, CharacterEvents, SetNetworkOwner, Struggle, DestroyToy

task.spawn(function()
    pcall(function()
        GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents", 5)
        MenuToys = ReplicatedStorage:WaitForChild("MenuToys", 5)
        CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents", 5)
        if GrabEvents then SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner", 5) end
        if CharacterEvents then Struggle = CharacterEvents:WaitForChild("Struggle", 5) end
        if MenuToys then DestroyToy = MenuToys:WaitForChild("DestroyToy", 5) end
    end)
end)

local toysFolder = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")

local AutoRecoverDroppedPartsCoroutine, autoStruggleCoroutine, antiKickCoroutine, autoDefendCoroutine, blobmanCoroutine, crouchSpeedCoroutine, crouchJumpCoroutine, anchorGrabCoroutine, poisonGrabCoroutine, ufoGrabCoroutine, fireGrabCoroutine, noclipGrabCoroutine, fireAllCoroutine, anchorKickCoroutine
local kickGrabConnections = {}
local anchoredParts = {}
local anchoredConnections = {}
local compiledGroups = {}
local compileConnections = {}
local renderSteppedConnections = {}

local burnPart
local blobman
local blobalter = 1

_G.strength = 400
_G.BlobmanDelay = 0.005
local crouchWalkSpeed = 50
local crouchJumpPower = 50
local decoyOffset = 15
local circleRadius = 10
local stopDistance = 5
local followMode = true
local skolko = "" 

local poisonHurtParts = {}
local paintPlayerParts = {}

task.spawn(function()
    pcall(function()
        for i, descendant in ipairs(Workspace.Map:GetDescendants()) do
            if descendant:IsA("Part") then
                if descendant.Name == "PoisonHurtPart" then table.insert(poisonHurtParts, descendant) end
                if descendant.Name == "PaintPlayerPart" then table.insert(paintPlayerParts, descendant) end
            end
            if i % 1000 == 0 then RunService.Heartbeat:Wait() end
        end
    end)
end)

---------------------------------------------------------
-- 9. FTAP CORE FUNCTIONS
---------------------------------------------------------
local function isDescendantOf(target, other)
    local currentParent = target.Parent
    while currentParent do
        if currentParent == other then return true end
        currentParent = currentParent.Parent
    end
    return false
end

local function DestroyT(toy)
    local t = toy or (toysFolder and toysFolder:FindFirstChildWhichIsA("Model"))
    if t and DestroyToy then pcall(function() DestroyToy:FireServer(t) end) end
end

local function spawnItem(itemName, position)
    task.spawn(function()
        pcall(function()
            local cframe = CFrame.new(position)
            MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, Vector3.new(0, 90, 0))
        end)
    end)
end

local function spawnItemCf(itemName, cframe)
    task.spawn(function()
        pcall(function() MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, Vector3.new(0, 0, 0)) end)
    end)
end

local function getNearestPlayer()
    local nearestPlayer, nearestDistance = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        pcall(function()
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < nearestDistance then nearestDistance = distance; nearestPlayer = player end
            end
        end)
    end
    return nearestPlayer
end

local function cleanupConnections(ct)
    for _, c in ipairs(ct) do pcall(function() c:Disconnect() end) end
    ct = {}
end

local function createHighlight(parent)
    local highlight = Instance.new("Highlight")
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.FillTransparency = 1
    highlight.Name = "Highlight"
    highlight.OutlineColor = Color3.new(0, 0, 1)
    highlight.OutlineTransparency = 0.5
    highlight.Parent = parent
    return highlight
end

local function onPartOwnerAdded(descendant, primaryPart)
    if descendant.Name == "PartOwner" and descendant.Value ~= LocalPlayer.Name then
        local highlight = primaryPart:FindFirstChild("Highlight") or (primaryPart.Parent and primaryPart.Parent:FindFirstChild("Highlight"))
        if highlight then
            if descendant.Value ~= LocalPlayer.Name then highlight.OutlineColor = Color3.new(1, 0, 0) else highlight.OutlineColor = Color3.new(0, 0, 1) end
        end
    end
end

local function createBodyMovers(part, position, rotation)
    local bodyPosition = Instance.new("BodyPosition")
    local bodyGyro = Instance.new("BodyGyro")
    bodyPosition.P = 15000; bodyPosition.D = 200; bodyPosition.MaxForce = Vector3.new(5000000, 5000000, 5000000)
    bodyPosition.Position = position; bodyPosition.Parent = part
    bodyGyro.P = 15000; bodyGyro.D = 200; bodyGyro.MaxTorque = Vector3.new(5000000, 5000000, 5000000)
    bodyGyro.CFrame = rotation; bodyGyro.Parent = part
end

local function getPlr(text)
    local name = text:lower()
    if name == "" then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(name) or p.DisplayName:lower():find(name) then return p end
    end
end

---------------------------------------------------------
-- 10. FTAP DÖNGÜ FONKSİYONLARI (GRAB, BLOBS, vs.)
---------------------------------------------------------
local function grabHandler(grabType)
    while true do
        pcall(function()
            local child = Workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                local weld = grabPart and grabPart:FindFirstChild("WeldConstraint")
                local grabbedPart = weld and weld.Part1
                local head = grabbedPart and grabbedPart.Parent and grabbedPart.Parent:FindFirstChild("Head")
                if head then
                    local partsTable = (grabType == "poison") and poisonHurtParts or paintPlayerParts
                    while Workspace:FindFirstChild("GrabParts") do
                        for _, part in pairs(partsTable) do
                            part.Size = Vector3.new(2, 2, 2); part.Transparency = 1; part.Position = head.Position
                        end
                        task.wait()
                    end
                    for _, part in pairs(partsTable) do part.Position = Vector3.new(0, -200, 0) end
                end
            end
        end)
        task.wait()
    end
end

local function fireGrab()
    while true do
        pcall(function()
            local child = Workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                local weld = grabPart and grabPart:FindFirstChild("WeldConstraint")
                local grabbedPart = weld and weld.Part1
                local head = grabbedPart and grabbedPart.Parent and grabbedPart.Parent:FindFirstChild("Head")
                if head then
                    if not toysFolder:FindFirstChild("Campfire") then spawnItem("Campfire", Vector3.new(-72.93, -5.96, -265.54)) end
                    local campfire = toysFolder:FindFirstChild("Campfire")
                    if campfire then
                        burnPart = campfire:FindFirstChild("FirePlayerPart") or campfire.FirePlayerPart
                        burnPart.Size = Vector3.new(7, 7, 7); burnPart.Position = head.Position
                        task.wait(0.3); burnPart.Position = Vector3.new(0, -50, 0)
                    end
                end
            end
        end)
        task.wait()
    end
end

local function noclipGrab()
    while true do
        pcall(function()
            local child = Workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                local weld = grabPart and grabPart:FindFirstChild("WeldConstraint")
                local grabbedPart = weld and weld.Part1
                local character = grabbedPart and grabbedPart.Parent
                if character and character:FindFirstChild("HumanoidRootPart") then
                    while Workspace:FindFirstChild("GrabParts") do
                        for _, part in pairs(character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
                        task.wait()
                    end
                    for _, part in pairs(character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = true end end
                end
            end
        end)
        task.wait()
    end
end

local function fireAll()
    while true do
        pcall(function()
            if toysFolder:FindFirstChild("Campfire") then DestroyT(toysFolder:FindFirstChild("Campfire")); task.wait(0.5) end
            local char = LocalPlayer.Character
            if not char then return end
            spawnItemCf("Campfire", char.Head.CFrame)
            local campfire = toysFolder:WaitForChild("Campfire", 3)
            if not campfire then return end
            local firePlayerPart
            for _, part in pairs(campfire:GetChildren()) do if part.Name == "FirePlayerPart" then part.Size = Vector3.new(10, 10, 10); firePlayerPart = part; break end end
            local originalPosition = char.Torso.Position
            SetNetworkOwner:FireServer(firePlayerPart, firePlayerPart.CFrame)
            char:MoveTo(firePlayerPart.Position); task.wait(0.3); char:MoveTo(originalPosition)
            
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000; bodyPosition.Position = char.Head.Position + Vector3.new(0, 600, 0); bodyPosition.Parent = campfire.Main
            
            while true do
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        bodyPosition.Position = char.Head.Position + Vector3.new(0, 600, 0)
                        if player.Character and player.Character.HumanoidRootPart and player.Character ~= char then
                            firePlayerPart.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
                            task.wait()
                        end
                    end)
                end
                task.wait()
            end
        end)
        task.wait()
    end
end

local function handleCharacterAdded(player)
    local conn = player.CharacterAdded:Connect(function(character)
        pcall(function()
            local hrp = character:WaitForChild("HumanoidRootPart", 3)
            if hrp then
                local fpp = hrp:WaitForChild("FirePlayerPart", 3)
                if fpp then fpp.Size = Vector3.new(4.5, 5, 4.5); fpp.CollisionGroup = "1"; fpp.CanQuery = true end
            end
        end)
    end)
    table.insert(kickGrabConnections, conn)
end

local function kickGrab()
    for _, player in pairs(Players:GetPlayers()) do
        pcall(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                if hrp:FindFirstChild("FirePlayerPart") then
                    local fpp = hrp.FirePlayerPart
                    fpp.Size = Vector3.new(4.5, 5.5, 4.5); fpp.CollisionGroup = "1"; fpp.CanQuery = true
                end
            end
            handleCharacterAdded(player)
        end)
    end
    local playerAddedConnection = Players.PlayerAdded:Connect(handleCharacterAdded)
    table.insert(kickGrabConnections, playerAddedConnection)
end

local function anchorGrab()
    while true do
        pcall(function()
            local grabParts = Workspace:FindFirstChild("GrabParts")
            if not grabParts then return end
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then return end
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then return end

            local p1 = weldConstraint.Part1
            local primaryPart = p1.Name == "SoundPart" and p1 or (p1.Parent and p1.Parent:FindFirstChild("SoundPart") or p1.Parent.PrimaryPart or p1)
            
            if not primaryPart or primaryPart.Anchored then return end
            if isDescendantOf(primaryPart, Workspace.Map) then return end
            for _, player in pairs(Players:GetChildren()) do if isDescendantOf(primaryPart, player.Character) then return end end
            
            local t = true
            for _, v in pairs(primaryPart:GetDescendants()) do if table.find(anchoredParts, v) then t = false end end
            
            if t and not table.find(anchoredParts, primaryPart) then
                local target = (primaryPart.Parent and primaryPart.Parent:IsA("Model") and primaryPart.Parent ~= Workspace) and primaryPart.Parent or primaryPart
                createHighlight(target)
                table.insert(anchoredParts, primaryPart)
                local connection = target.DescendantAdded:Connect(function(descendant) onPartOwnerAdded(descendant, primaryPart) end)
                table.insert(anchoredConnections, connection)
            end
            
            local parentModel = primaryPart.Parent
            if parentModel and parentModel:IsA("Model") and parentModel ~= Workspace then 
                for _, child in ipairs(parentModel:GetDescendants()) do if child:IsA("BodyPosition") or child:IsA("BodyGyro") then child:Destroy() end end
            else
                for _, child in ipairs(primaryPart:GetChildren()) do if child:IsA("BodyPosition") or child:IsA("BodyGyro") then child:Destroy() end end
            end

            while Workspace:FindFirstChild("GrabParts") do task.wait() end
            createBodyMovers(primaryPart, primaryPart.Position, primaryPart.CFrame)
        end)
        task.wait()
    end
end

local function cleanupAnchoredParts()
    for _, part in ipairs(anchoredParts) do
        if part then
            if part:FindFirstChild("BodyPosition") then part.BodyPosition:Destroy() end
            if part:FindFirstChild("BodyGyro") then part.BodyGyro:Destroy() end
            local highlight = part:FindFirstChild("Highlight") or (part.Parent and part.Parent:FindFirstChild("Highlight"))
            if highlight then highlight:Destroy() end
        end
    end
    cleanupConnections(anchoredConnections); anchoredParts = {}
end

local function recoverPartsFunc()
    while true do
        pcall(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, partModel in pairs(anchoredParts) do
                    coroutine.wrap(function()
                        if partModel then
                            local distance = (partModel.Position - hrp.Position).Magnitude
                            if distance <= 30 then
                                local highlight = partModel:FindFirstChild("Highlight") or (partModel.Parent and partModel.Parent:FindFirstChild("Highlight"))
                                if highlight and highlight.OutlineColor == Color3.new(1, 0, 0) then
                                    SetNetworkOwner:FireServer(partModel, partModel.CFrame)
                                    if partModel:WaitForChild("PartOwner") and partModel.PartOwner.Value == LocalPlayer.Name then highlight.OutlineColor = Color3.new(0, 0, 1) end
                                end
                            end
                        end
                    end)()
                end
            end
        end)
        task.wait(0.02)
    end
end

---------------------------------------------------------
-- 11. MENÜ SEKMELERİ VE BUTONLAR 
---------------------------------------------------------
local GrabTab = createTab("Combat", "⚔️", true)
local PlayerTab = createTab("Local Player", "👤", false)
local ObjectGrabTab = createTab("Object Grab", "📦", false)
local DefanseTab = createTab("Defense", "🛡️", false)
local BlobmanTab = createTab("Blob Man", "👹", false)
local FunTab = createTab("Fun / Troll", "🤡", false)

-- [COMBAT TAB]
createSection("THROW STRENGTH", GrabTab)
createSlider("Strength Power", 300, 10000, 400, GrabTab, function(v) _G.strength = v end)
createToggle("Enable Strength", GrabTab, function(enabled)
    if enabled then
        strengthConnection = Workspace.ChildAdded:Connect(function(model)
            if model.Name == "GrabParts" then
                local partToImpulse = model.GrabPart.WeldConstraint.Part1
                if partToImpulse then
                    local velocityObj = Instance.new("BodyVelocity", partToImpulse)
                    model:GetPropertyChangedSignal("Parent"):Connect(function()
                        if not model.Parent then
                            if UserInputService:GetLastInputType() == Enum.UserInputType.MouseButton2 then
                                velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                velocityObj.Velocity = Camera.CFrame.LookVector * _G.strength
                                Debris:AddItem(velocityObj, 1)
                            else velocityObj:Destroy() end
                        end
                    end)
                end
            end
        end)
        table.insert(Connections, strengthConnection)
    else if strengthConnection then strengthConnection:Disconnect() end end
end)

createSection("GRAB EFFECTS", GrabTab)
createToggle("Poison Grab", GrabTab, function(enabled)
    if enabled then poisonGrabCoroutine = coroutine.create(function() grabHandler("poison") end); coroutine.resume(poisonGrabCoroutine)
    else if poisonGrabCoroutine then coroutine.close(poisonGrabCoroutine); poisonGrabCoroutine = nil; for _, p in pairs(poisonHurtParts) do p.Position = Vector3.new(0, -200, 0) end end end
end)
createToggle("Radioactive Grab", GrabTab, function(enabled)
    if enabled then ufoGrabCoroutine = coroutine.create(function() grabHandler("radioactive") end); coroutine.resume(ufoGrabCoroutine)
    else if ufoGrabCoroutine then coroutine.close(ufoGrabCoroutine); ufoGrabCoroutine = nil; for _, p in pairs(paintPlayerParts) do p.Position = Vector3.new(0, -200, 0) end end end
end)
createToggle("Fire Grab", GrabTab, function(enabled)
    if enabled then fireGrabCoroutine = coroutine.create(fireGrab); coroutine.resume(fireGrabCoroutine)
    else if fireGrabCoroutine then coroutine.close(fireGrabCoroutine); fireGrabCoroutine = nil end end
end)
createToggle("Noclip Grab", GrabTab, function(enabled)
    if enabled then noclipGrabCoroutine = coroutine.create(noclipGrab); coroutine.resume(noclipGrabCoroutine)
    else if noclipGrabCoroutine then coroutine.close(noclipGrabCoroutine); noclipGrabCoroutine = nil end end
end)
createToggle("Kick Grab", GrabTab, function(enabled)
    if enabled then kickGrab() else
        for _, connection in pairs(kickGrabConnections) do pcall(function() connection:Disconnect() end) end
        for _, player in pairs(Players:GetPlayers()) do
            pcall(function()
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:FindFirstChild("FirePlayerPart") then
                    local fpp = hrp.FirePlayerPart
                    fpp.Size = Vector3.new(2.5, 5.5, 2.5); fpp.CollisionGroup = "Default"; fpp.CanQuery = false
                end
            end)
        end
        kickGrabConnections = {}
    end
end)

createSection("MASS DESTRUCTION", GrabTab)
createToggle("Fire All", GrabTab, function(enabled)
    if enabled then fireAllCoroutine = coroutine.create(fireAll); coroutine.resume(fireAllCoroutine)
    else if fireAllCoroutine then coroutine.close(fireAllCoroutine); fireAllCoroutine = nil end end
end)

-- [LOCAL PLAYER TAB]
createSection("PLAYER SPEED", PlayerTab)
createToggle("Crouch Speed Override", PlayerTab, function(enabled)
    if enabled then
        crouchSpeedCoroutine = coroutine.create(function()
            while task.wait() do pcall(function() local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") and char.Humanoid.WalkSpeed == 5 then char.Humanoid.WalkSpeed = crouchWalkSpeed end end) end
        end)
        coroutine.resume(crouchSpeedCoroutine)
    else if crouchSpeedCoroutine then coroutine.close(crouchSpeedCoroutine); crouchSpeedCoroutine = nil; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end end end
end)
createSlider("Set Crouch Speed", 6, 1000, 50, PlayerTab, function(v) crouchWalkSpeed = v end)

createSection("PLAYER JUMP", PlayerTab)
createToggle("Crouch Jump Override", PlayerTab, function(enabled)
    if enabled then
        crouchJumpCoroutine = coroutine.create(function()
            while task.wait() do pcall(function() local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") and char.Humanoid.JumpPower == 12 then char.Humanoid.JumpPower = crouchJumpPower end end) end
        end)
        coroutine.resume(crouchJumpCoroutine)
    else if crouchJumpCoroutine then coroutine.close(crouchJumpCoroutine); crouchJumpCoroutine = nil; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = 24 end end end
end)
createSlider("Set Crouch Jump Power", 6, 1000, 50, PlayerTab, function(v) crouchJumpPower = v end)

-- [OBJECT GRAB TAB]
createSection("OBJECT HANDLING", ObjectGrabTab)
createToggle("Anchor Grab", ObjectGrabTab, function(enabled)
    if enabled then if not anchorGrabCoroutine or coroutine.status(anchorGrabCoroutine) == "dead" then anchorGrabCoroutine = coroutine.create(anchorGrab); coroutine.resume(anchorGrabCoroutine) end
    else if anchorGrabCoroutine then coroutine.close(anchorGrabCoroutine); anchorGrabCoroutine = nil end end
end)
createButton("Unanchor Parts", ObjectGrabTab, function() cleanupAnchoredParts() end)
createButton("Disassemble Parts", ObjectGrabTab, function() cleanupAnchoredParts() end)
createToggle("Auto Recover Dropped Parts", ObjectGrabTab, function(enabled)
    if enabled then if not AutoRecoverDroppedPartsCoroutine or coroutine.status(AutoRecoverDroppedPartsCoroutine) == "dead" then AutoRecoverDroppedPartsCoroutine = coroutine.create(recoverPartsFunc); coroutine.resume(AutoRecoverDroppedPartsCoroutine) end
    else if AutoRecoverDroppedPartsCoroutine and coroutine.status(AutoRecoverDroppedPartsCoroutine) ~= "dead" then coroutine.close(AutoRecoverDroppedPartsCoroutine); AutoRecoverDroppedPartsCoroutine = nil end end
end)

-- [DEFENSE TAB]
createSection("DEFENSE SYSTEMS", DefanseTab)
createToggle("Anti Grab (Auto Struggle)", DefanseTab, function(enabled)
    if enabled then
        autoStruggleCoroutine = RunService.Heartbeat:Connect(function()
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Head") then
                    local partOwner = character.Head:FindFirstChild("PartOwner")
                    if partOwner then
                        if Struggle then Struggle:FireServer() end
                        if ReplicatedStorage:FindFirstChild("GameCorrectionEvents") then ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer() end
                        for _, part in pairs(character:GetChildren()) do if part:IsA("BasePart") then part.Anchored = true end end
                        while LocalPlayer:FindFirstChild("IsHeld") and LocalPlayer.IsHeld.Value do task.wait() end
                        for _, part in pairs(character:GetChildren()) do if part:IsA("BasePart") then part.Anchored = false end end
                    end
                end
            end)
        end)
    else if autoStruggleCoroutine then autoStruggleCoroutine:Disconnect(); autoStruggleCoroutine = nil end end
end)

createToggle("Anti Kick Grab", DefanseTab, function(enabled)
    if enabled then
        antiKickCoroutine = RunService.Heartbeat:Connect(function()
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart:FindFirstChild("FirePlayerPart") then
                    local partOwner = character.HumanoidRootPart.FirePlayerPart:FindFirstChild("PartOwner")
                    if partOwner and partOwner.Value ~= LocalPlayer.Name then
                        local args = {[1] = character:WaitForChild("HumanoidRootPart"), [2] = 0}
                        if CharacterEvents then CharacterEvents:WaitForChild("RagdollRemote"):FireServer(unpack(args)) end
                        task.wait(0.1); if Struggle then Struggle:FireServer() end
                    end
                end
            end)
        end)
    else if antiKickCoroutine then antiKickCoroutine:Disconnect(); antiKickCoroutine = nil end end
end)

createToggle("Self Defense / Air Suspend", DefanseTab, function(enabled)
    if enabled then
        autoDefendCoroutine = coroutine.create(function()
            while task.wait(0.02) do
                pcall(function()
                    local character = LocalPlayer.Character
                    if character and character:FindFirstChild("Head") then
                        local partOwner = character.Head:FindFirstChild("PartOwner")
                        if partOwner then
                            local attacker = Players:FindFirstChild(partOwner.Value)
                            if attacker and attacker.Character then
                                if Struggle then Struggle:FireServer() end
                                if SetNetworkOwner then SetNetworkOwner:FireServer(attacker.Character:FindFirstChild("Head") or attacker.Character:FindFirstChild("Torso"), attacker.Character.HumanoidRootPart.FirePlayerPart.CFrame) end
                                task.wait(0.1)
                                local target = attacker.Character:FindFirstChild("Torso")
                                if target then
                                    local velocity = target:FindFirstChild("l") or Instance.new("BodyVelocity")
                                    velocity.Name = "l"; velocity.Parent = target; velocity.Velocity = Vector3.new(0, 50, 0); velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                    Debris:AddItem(velocity, 100)
                                end
                            end
                        end
                    end
                end)
            end
        end)
        coroutine.resume(autoDefendCoroutine)
    else if autoDefendCoroutine then coroutine.close(autoDefendCoroutine); autoDefendCoroutine = nil end end
end)

-- [BLOBMAN TAB]
createSection("SERVER NUKE (REQUIRES MOUNT)", BlobmanTab)
local blobToggleActive = false
createToggle("Destroy Server (Grab All)", BlobmanTab, function(enabled)
    blobToggleActive = enabled
    if enabled then
        blobmanCoroutine = coroutine.create(function()
            local foundBlobman = false
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name == "CreatureBlobman" and obj:FindFirstChild("VehicleSeat") and obj.VehicleSeat:FindFirstChild("SeatWeld") then
                    if isDescendantOf(obj.VehicleSeat.SeatWeld.Part1, LocalPlayer.Character) then
                        blobman = obj; foundBlobman = true; break
                    end
                end
            end
            if not foundBlobman then notify("Error", "You must be mounted on a Blobman!"); blobToggleActive = false; return end
            while blobToggleActive do
                pcall(function()
                    for _, p in pairs(Players:GetChildren()) do
                        if blobman and p ~= LocalPlayer then
                            local det = blobalter == 1 and "LeftDetector" or "RightDetector"
                            local weld = blobalter == 1 and "LeftWeld" or "RightWeld"
                            local args = { [1] = blobman:FindFirstChild(det), [2] = p.Character:FindFirstChild("HumanoidRootPart"), [3] = blobman:FindFirstChild(det):FindFirstChild(weld) }
                            blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
                            blobalter = blobalter == 1 and 2 or 1
                            task.wait(_G.BlobmanDelay)
                        end
                    end
                end)
                task.wait(0.02)
            end
        end)
        coroutine.resume(blobmanCoroutine)
    else if blobmanCoroutine then coroutine.close(blobmanCoroutine); blobmanCoroutine = nil; blobman = nil end end
end)
createSlider("Nuke Speed (Delay)", 0, 1, 0.05, BlobmanTab, function(v) _G.BlobmanDelay = v end)

-- [TROLL / FUN TAB]
createSection("ECONOMY SPOOFER", FunTab)
createInput("Enter Coins Amount", "Type Number...", FunTab, function(txt) skolko = txt end)
createButton("Spoof Coins (Visual)", FunTab, function()
    pcall(function()
        local amt = tonumber(skolko) or 0
        LocalPlayer.PlayerGui.MenuGui.TopRight.CoinsFrame.CoinsDisplay.Coins.Text = tostring(amt)
    end)
end)

createSection("DECOY CIRCLE (CLONES)", FunTab)
createSlider("Decoy Offset", 1, 100, 10, FunTab, function(v) decoyOffset = v end)
createInput("Circle Radius", "Type radius number...", FunTab, function(txt) circleRadius = tonumber(txt) or 10 end)

local decoyConnections = {}
createButton("Decoy Follow", FunTab, function()
    local decoys = {}
    for _, descendant in pairs(Workspace:GetDescendants()) do
        if descendant:IsA("Model") and descendant.Name == "YouDecoy" then table.insert(decoys, descendant) end
    end
    local numDecoys = #decoys; local midPoint = math.ceil(numDecoys / 2)

    local function updateDecoyPositions()
        for index, decoy in pairs(decoys) do
            pcall(function()
                local torso = decoy:FindFirstChild("Torso")
                if torso then
                    local bodyPosition = torso:FindFirstChild("BodyPosition")
                    local bodyGyro = torso:FindFirstChild("BodyGyro")
                    if bodyPosition and bodyGyro then
                        local targetPosition
                        if followMode then
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                targetPosition = LocalPlayer.Character.HumanoidRootPart.Position
                                local offset = (index - midPoint) * decoyOffset
                                local forward = LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector
                                local right = LocalPlayer.Character.HumanoidRootPart.CFrame.RightVector
                                targetPosition = targetPosition - forward * decoyOffset + right * offset
                            end
                        else
                            local nearestPlayer = getNearestPlayer()
                            if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local angle = math.rad((index - 1) * (360 / numDecoys))
                                targetPosition = nearestPlayer.Character.HumanoidRootPart.Position + Vector3.new(math.cos(angle) * circleRadius, 0, math.sin(angle) * circleRadius)
                                bodyGyro.CFrame = CFrame.new(torso.Position, nearestPlayer.Character.HumanoidRootPart.Position)
                            end
                        end
                        if targetPosition then
                            local distance = (targetPosition - torso.Position).Magnitude
                            if distance > stopDistance then
                                bodyPosition.Position = targetPosition
                                if followMode then bodyGyro.CFrame = CFrame.new(torso.Position, targetPosition) end
                            else
                                bodyPosition.Position = torso.Position; bodyGyro.CFrame = torso.CFrame
                            end
                        end
                    end
                end
            end)
        end
    end

    local function setupDecoy(decoy)
        pcall(function()
            local torso = decoy:FindFirstChild("Torso")
            if torso then
                local bodyPosition = Instance.new("BodyPosition", torso); local bodyGyro = Instance.new("BodyGyro", torso)
                bodyPosition.MaxForce = Vector3.new(40000, 40000, 40000); bodyPosition.D = 100; bodyPosition.P = 100
                bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000); bodyGyro.D = 100; bodyGyro.P = 20000
                local connection = RunService.Heartbeat:Connect(function() updateDecoyPositions() end)
                table.insert(decoyConnections, connection)
                if SetNetworkOwner then SetNetworkOwner:FireServer(torso, LocalPlayer.Character.Head.CFrame) end
            end
        end)
    end

    for _, decoy in pairs(decoys) do setupDecoy(decoy) end
    notify("Decoys Ready", "Got " .. numDecoys .. " units active.")
end)

createButton("Toggle Follow Mode", FunTab, function() followMode = not followMode; notify("Mode", "Follow Mode is now " .. tostring(followMode)) end)
createButton("Disconnect Clones", FunTab, function() cleanupConnections(decoyConnections) end)

createSection("PLAYER TARGETING", FunTab)
local targetPlayerName = ""
createInput("Enter Target Name", "Username...", FunTab, function(txt) targetPlayerName = txt end)
createButton("Teleport To (Goto)", FunTab, function()
    local t = getPlr(targetPlayerName)
    if t and t.Character and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) 
    end
end)

local brg, frz = false, false
createToggle("Bring (Loop)", FunTab, function(v) brg = v end)
createToggle("Freeze (Loop)", FunTab, function(v) frz = v end)

table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not ScriptRunning then return end
    pcall(function()
        local t = getPlr(targetPlayerName)
        if not t or not t.Character or not t.Character:FindFirstChild("HumanoidRootPart") then return end
        if brg and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
            t.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4) 
        end
        if frz then t.Character.HumanoidRootPart.Anchored = true else t.Character.HumanoidRootPart.Anchored = false end
    end)
end))

-- İntro bittikten sonra ilk sayfayı yükler
local loaded = false
task.spawn(function()
    task.wait(9) 
    if MainFrame.Visible and not loaded then
        loaded = true
        cascade(GrabTab)
    end
end)
