local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ScriptRunning = true
local Connections = {}
local GUI_NAME = "ObsidianCat_SiyahPembe"
local targetParent = nil

---------------------------------------------------------
-- 1. GÜVENLİ GUI OLUŞTURMA (ANTI-CRASH)
---------------------------------------------------------
local success = pcall(function() targetParent = gethui() end)
if not success or not targetParent then
    success = pcall(function() targetParent = game:GetService("CoreGui") end)
end
if not success or not targetParent then
    targetParent = LocalPlayer:WaitForChild("PlayerGui")
end

for _, v in ipairs(targetParent:GetChildren()) do
    if v.Name == GUI_NAME then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetParent

---------------------------------------------------------
-- 2. SİYAH-PEMBE ELİT PALET & EFEKTLER
---------------------------------------------------------
local SiyahPembePalette = {
    MainBG = Color3.fromRGB(12, 12, 15),    
    PanelBG = Color3.fromRGB(18, 18, 22),   
    Accent = Color3.fromRGB(255, 105, 180), 
    TextTitle = Color3.fromRGB(255, 255, 255), 
    TextDesc = Color3.fromRGB(160, 160, 170),  
    WinClose = Color3.fromRGB(255, 50, 50),   
    WinMin = Color3.fromRGB(255, 182, 193),   
    WinMax = Color3.fromRGB(219, 112, 147),
    BadgeBG = Color3.fromRGB(255, 200, 60) 
}

-- ARKA PLAN BLUR EFEKTİ
local BlurEffect = Instance.new("BlurEffect", Lighting)
BlurEffect.Size = 0
BlurEffect.Enabled = true

---------------------------------------------------------
-- 3. BİLDİRİM SİSTEMİ (NOTIFICATIONS)
---------------------------------------------------------
local NotifContainer = Instance.new("Frame", ScreenGui)
NotifContainer.Size = UDim2.new(0, 250, 1, 0)
NotifContainer.Position = UDim2.new(1, -260, 0, 0)
NotifContainer.BackgroundTransparency = 1
local NotifList = Instance.new("UIListLayout", NotifContainer)
NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifList.Padding = UDim.new(0, 10)
Instance.new("UIPadding", NotifContainer).PaddingBottom = UDim.new(0, 20)

local function notify(title, text)
    local f = Instance.new("Frame", NotifContainer)
    f.Size = UDim2.new(1, 0, 0, 0) 
    f.BackgroundColor3 = SiyahPembePalette.PanelBG
    f.BorderSizePixel = 0
    f.ClipsDescendants = true
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke", f)
    s.Color = SiyahPembePalette.Accent
    s.Thickness = 1.2
    
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, -10, 0, 20)
    t.Position = UDim2.new(0, 10, 0, 5)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = SiyahPembePalette.Accent
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    
    local d = Instance.new("TextLabel", f)
    d.Size = UDim2.new(1, -10, 0, 25)
    d.Position = UDim2.new(0, 10, 0, 25)
    d.BackgroundTransparency = 1
    d.Text = text
    d.TextColor3 = SiyahPembePalette.TextDesc
    d.Font = Enum.Font.Gotham
    d.TextSize = 11
    d.TextXAlignment = Enum.TextXAlignment.Left
    
    TweenService:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 60)}):Play()
    
    task.delay(3, function()
        TweenService:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.4)
        f:Destroy()
    end)
end

---------------------------------------------------------
-- 4. ANA MENÜ ÇERÇEVESİ & ANİMASYONLU AÇILIŞ
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 0, 0, 0) 
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5) 
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = SiyahPembePalette.MainBG
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true 
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = SiyahPembePalette.Accent
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.5

local isMenuOpen = false
local isAnimating = false

local function toggleMenu(forceOpen)
    if isAnimating then return end
    isAnimating = true
    
    if isMenuOpen and not forceOpen then
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        TweenService:Create(BlurEffect, TweenInfo.new(0.4), {Size = 0}):Play()
        task.wait(0.4)
        MainFrame.Visible = false
        isMenuOpen = false
    else
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 760, 0, 460)}):Play()
        TweenService:Create(BlurEffect, TweenInfo.new(0.5), {Size = 24}):Play() 
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
-- 5. INTRO & BOOT SEQUENCE 
---------------------------------------------------------
local IntroContainer = Instance.new("Frame", ScreenGui)
IntroContainer.Size = UDim2.new(1, 0, 1, 0)
IntroContainer.BackgroundTransparency = 1
IntroContainer.BorderSizePixel = 0

local TerminalFrame = Instance.new("Frame", IntroContainer)
TerminalFrame.Size = UDim2.new(0, 0, 0, 2)
TerminalFrame.AnchorPoint = Vector2.new(0.5, 0.5)
TerminalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TerminalFrame.BackgroundColor3 = SiyahPembePalette.PanelBG
TerminalFrame.ClipsDescendants = true
Instance.new("UICorner", TerminalFrame).CornerRadius = UDim.new(0, 8)
local TerminalStroke = Instance.new("UIStroke", TerminalFrame)
TerminalStroke.Color = SiyahPembePalette.Accent

local TerminalText = Instance.new("TextLabel", TerminalFrame)
TerminalText.Size = UDim2.new(0.95, 0, 0.9, 0)
TerminalText.Position = UDim2.new(0.025, 0, 0.05, 0)
TerminalText.BackgroundTransparency = 1
TerminalText.Text = ""
TerminalText.TextColor3 = SiyahPembePalette.Accent
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
        for i = 1, #txt do TerminalText.Text = TerminalText.Text .. string.sub(txt, i, i); task.wait(0.005) end
        TerminalText.Text = TerminalText.Text .. "\n"
    end

    log(" ", SiyahPembePalette.TextTitle)
    log("                       /\\_/\\", SiyahPembePalette.TextTitle)
    log("                      ( o.o )", SiyahPembePalette.TextTitle)
    log("                       > ^ <", SiyahPembePalette.TextTitle)
    log(" ", SiyahPembePalette.TextTitle)
    log("---------------------------------------------------")
    log("[SYSTEM]: ObsidianCat.exe v7.1 Initialized")
    task.wait(0.4)
    log("[KERNEL]: Allocating Memory Pages...")
    task.wait(0.3)
    log("[NETWORK]: Establishing Secure Connection...")
    task.wait(0.5)
    log("[AUTH]: Bypassing Anti-Cheat Protocols...")
    task.wait(0.6)
    log("[MODULE]: Injecting Physics Override...")
    task.wait(0.4)
    log("[MODULE]: Injecting Target Logic...")
    task.wait(0.4)
    log("[LOAD]: Black-Pink UI Assets Compiled.")
    task.wait(0.5)
    log("[SYSTEM]: Fetching Player Profile...")
    task.wait(0.5)
    log("[SUCCESS]: Full Administrator Access Granted.")
    task.wait(0.8)

    TweenService:Create(TerminalFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.6)
    IntroContainer:Destroy()
    
    toggleMenu(true)
    notify("System Ready", "ObsidianCat.exe successfully loaded.")
end)

-- FAILSAFE (Intro çökerse)
task.spawn(function()
    task.wait(8.5)
    if not isMenuOpen then
        if IntroContainer then pcall(function() IntroContainer:Destroy() end) end
        toggleMenu(true)
    end
end)

---------------------------------------------------------
-- 6. TOP BAR & PENCERE KONTROLLERİ
---------------------------------------------------------
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundTransparency = 1

local TitleLayout = Instance.new("Frame", TopBar)
TitleLayout.Size = UDim2.new(0.7, 0, 1, 0)
TitleLayout.Position = UDim2.new(0.03, 0, 0, 0)
TitleLayout.BackgroundTransparency = 1
local TitleList = Instance.new("UIListLayout", TitleLayout)
TitleList.FillDirection = Enum.FillDirection.Horizontal
TitleList.VerticalAlignment = Enum.VerticalAlignment.Center
TitleList.Padding = UDim.new(0, 8)

local Title = Instance.new("TextLabel", TitleLayout)
Title.AutomaticSize = Enum.AutomaticSize.X
Title.Size = UDim2.new(0, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = SiyahPembePalette.TextTitle
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
    pcall(function()
        local productInfo = MarketplaceService:GetProductInfo(game.PlaceId)
        Title.Text = "ObsidianCat.exe | " .. (productInfo.Name or game.Name)
    end)
end)

local VersionBadge = Instance.new("Frame", TitleLayout)
VersionBadge.Size = UDim2.new(0, 42, 0, 20)
VersionBadge.BackgroundColor3 = SiyahPembePalette.BadgeBG
VersionBadge.BorderSizePixel = 0
Instance.new("UICorner", VersionBadge).CornerRadius = UDim.new(1, 0) 
local VersionText = Instance.new("TextLabel", VersionBadge)
VersionText.Size = UDim2.new(1, 0, 1, 0)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v7.1"
VersionText.TextColor3 = Color3.fromRGB(0, 0, 0)
VersionText.Font = Enum.Font.GothamBold
VersionText.TextSize = 11

local Controls = Instance.new("Frame", TopBar)
Controls.Size = UDim2.new(0, 100, 0, 30)
Controls.Position = UDim2.new(1, -110, 0.5, -15)
Controls.BackgroundTransparency = 1
local CtrlList = Instance.new("UIListLayout", Controls)
CtrlList.FillDirection = Enum.FillDirection.Horizontal
CtrlList.HorizontalAlignment = Enum.HorizontalAlignment.Right
CtrlList.Padding = UDim.new(0, 8)
CtrlList.VerticalAlignment = Enum.VerticalAlignment.Center

local function createWinBtn(text, color, callback)
    local b = Instance.new("TextButton", Controls)
    b.Size = UDim2.new(0, 24, 0, 24)
    b.BackgroundColor3 = SiyahPembePalette.PanelBG
    b.Text = text
    b.TextColor3 = color
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke", b)
    s.Color = color
    s.Transparency = 0.5
    b.MouseButton1Click:Connect(callback)
    return b
end

createWinBtn("_", SiyahPembePalette.WinMin, function() toggleMenu() end)
createWinBtn("◻", SiyahPembePalette.WinMax, function() end) 
createWinBtn("✖", SiyahPembePalette.WinClose, function()
    ScriptRunning = false
    BlurEffect:Destroy()
    for _, conn in ipairs(Connections) do pcall(function() conn:Disconnect() end) end
    ScreenGui:Destroy()
end)

---------------------------------------------------------
-- 7. SOL BAR & ZENGİN PROFIL
---------------------------------------------------------
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 160, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = SiyahPembePalette.PanelBG
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)
local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding = UDim.new(0, 8)
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 15)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ProfilePanel = Instance.new("Frame", MainFrame)
ProfilePanel.Size = UDim2.new(0, 180, 1, -42)
ProfilePanel.Position = UDim2.new(1, -195, 0, 42)
ProfilePanel.BackgroundColor3 = SiyahPembePalette.PanelBG
ProfilePanel.BorderSizePixel = 0
Instance.new("UICorner", ProfilePanel).CornerRadius = UDim.new(0, 10)
local ProfileStroke = Instance.new("UIStroke", ProfilePanel)
ProfileStroke.Color = SiyahPembePalette.Accent
ProfileStroke.Transparency = 0.7

local AvatarFrame = Instance.new("Frame", ProfilePanel)
AvatarFrame.Size = UDim2.new(0, 100, 0, 100)
AvatarFrame.Position = UDim2.new(0.5, -50, 0, 20)
AvatarFrame.BackgroundColor3 = SiyahPembePalette.MainBG
Instance.new("UICorner", AvatarFrame).CornerRadius = UDim.new(1, 0)
local AvatarStroke = Instance.new("UIStroke", AvatarFrame)
AvatarStroke.Color = SiyahPembePalette.Accent
AvatarStroke.Thickness = 2.5

local AvatarImage = Instance.new("ImageLabel", AvatarFrame)
AvatarImage.Size = UDim2.new(1, 0, 1, 0)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image = "rbxthumb://type=AvatarBust&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)

local DisplayNameLabel = Instance.new("TextLabel", ProfilePanel)
DisplayNameLabel.Size = UDim2.new(1, -10, 0, 20)
DisplayNameLabel.Position = UDim2.new(0, 5, 0, 130)
DisplayNameLabel.BackgroundTransparency = 1
DisplayNameLabel.Text = LocalPlayer.DisplayName
DisplayNameLabel.TextColor3 = SiyahPembePalette.TextTitle
DisplayNameLabel.Font = Enum.Font.GothamBold
DisplayNameLabel.TextSize = 14

local RealNameLabel = Instance.new("TextLabel", ProfilePanel)
RealNameLabel.Size = UDim2.new(1, -10, 0, 20)
RealNameLabel.Position = UDim2.new(0, 5, 0, 145)
RealNameLabel.BackgroundTransparency = 1
RealNameLabel.Text = "@" .. LocalPlayer.Name
RealNameLabel.TextColor3 = SiyahPembePalette.TextDesc
RealNameLabel.Font = Enum.Font.Gotham
RealNameLabel.TextSize = 11

local UserIDLabel = Instance.new("TextLabel", ProfilePanel)
UserIDLabel.Size = UDim2.new(1, -10, 0, 20)
UserIDLabel.Position = UDim2.new(0, 5, 0, 170)
UserIDLabel.BackgroundTransparency = 1
UserIDLabel.Text = "ID: " .. LocalPlayer.UserId
UserIDLabel.TextColor3 = SiyahPembePalette.TextDesc
UserIDLabel.Font = Enum.Font.GothamMedium
UserIDLabel.TextSize = 10

local AccountAgeLabel = Instance.new("TextLabel", ProfilePanel)
AccountAgeLabel.Size = UDim2.new(1, -10, 0, 20)
AccountAgeLabel.Position = UDim2.new(0, 5, 0, 185)
AccountAgeLabel.BackgroundTransparency = 1
AccountAgeLabel.TextColor3 = SiyahPembePalette.TextDesc
AccountAgeLabel.Font = Enum.Font.GothamMedium
AccountAgeLabel.TextSize = 10
pcall(function() AccountAgeLabel.Text = "Age: " .. LocalPlayer.AccountAge .. " Days" end)

local TeamLabel = Instance.new("TextLabel", ProfilePanel)
TeamLabel.Size = UDim2.new(1, -10, 0, 20)
TeamLabel.Position = UDim2.new(0, 5, 0, 205)
TeamLabel.BackgroundTransparency = 1
TeamLabel.Font = Enum.Font.GothamMedium
TeamLabel.TextSize = 10

local HealthLabel = Instance.new("TextLabel", ProfilePanel)
HealthLabel.Size = UDim2.new(1, -10, 0, 20)
HealthLabel.Position = UDim2.new(0, 5, 0, 220)
HealthLabel.BackgroundTransparency = 1
HealthLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
HealthLabel.Font = Enum.Font.GothamMedium
HealthLabel.TextSize = 10

local SessionTimeBG = Instance.new("Frame", ProfilePanel)
SessionTimeBG.Size = UDim2.new(0.9, 0, 0, 30)
SessionTimeBG.AnchorPoint = Vector2.new(0.5, 1)
SessionTimeBG.Position = UDim2.new(0.5, 0, 1, -10)
SessionTimeBG.BackgroundColor3 = SiyahPembePalette.MainBG
Instance.new("UICorner", SessionTimeBG).CornerRadius = UDim.new(0, 6)
local stStr = Instance.new("UIStroke", SessionTimeBG)
stStr.Color = SiyahPembePalette.Accent

local SessionTimeLabel = Instance.new("TextLabel", SessionTimeBG)
SessionTimeLabel.Size = UDim2.new(1, 0, 1, 0)
SessionTimeLabel.BackgroundTransparency = 1
SessionTimeLabel.TextColor3 = SiyahPembePalette.Accent
SessionTimeLabel.Font = Enum.Font.GothamBold
SessionTimeLabel.TextSize = 11

local startTime = tick()
table.insert(Connections, RunService.RenderStepped:Connect(function()
    if not ScriptRunning then return end
    pcall(function()
        if LocalPlayer.Team then 
            TeamLabel.Text = "Team: " .. LocalPlayer.Team.Name
            TeamLabel.TextColor3 = LocalPlayer.Team.TeamColor.Color 
        else 
            TeamLabel.Text = "Team: None"
            TeamLabel.TextColor3 = SiyahPembePalette.TextDesc 
        end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then 
            HealthLabel.Text = "HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) 
        end
        local elapsed = tick() - startTime
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = math.floor(elapsed % 60)
        SessionTimeLabel.Text = string.format("🕒 %02d:%02d:%02d", h, m, s)
    end)
end))

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -380, 1, -42)
ContentArea.Position = UDim2.new(0, 175, 0, 42)
ContentArea.BackgroundTransparency = 1

---------------------------------------------------------
-- 8. CASCADING ANIMATIONS & İÇERİK MANTIĞI
---------------------------------------------------------
local OriginalSizes = {}
local function cascade(page)
    local delayTime = 0
    for _, item in ipairs(page:GetChildren()) do
        if item:IsA("Frame") or item:IsA("TextButton") or item:IsA("TextBox") then
            if not OriginalSizes[item] then OriginalSizes[item] = item.Size end
            local targetSize = OriginalSizes[item]
            item.Size = UDim2.new(0.4, 0, targetSize.Y.Scale, targetSize.Y.Offset)
            item.BackgroundTransparency = 1
            task.delay(delayTime, function()
                TweenService:Create(item, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = targetSize, BackgroundTransparency = 0}):Play()
            end)
            delayTime = delayTime + 0.05
        end
    end
end

local Settings = { Speed = 2, FlySpeed = 60 }
local Pages = {}
local TabButtons = {}

local function createTab(name, icon, isDefault)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.85, 0, 0, 38)
    btn.BackgroundColor3 = SiyahPembePalette.Accent
    btn.BackgroundTransparency = isDefault and 0.8 or 1
    btn.Text = "  " .. icon .. "  " .. name
    btn.TextColor3 = isDefault and SiyahPembePalette.Accent or SiyahPembePalette.TextDesc
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 0
    page.Visible = isDefault
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 10)
    Instance.new("UIPadding", page).PaddingTop = UDim.new(0, 10)
    
    table.insert(TabButtons, btn)
    table.insert(Pages, page)
    
    btn.MouseButton1Click:Connect(function()
        if not page.Visible then
            for i, p in ipairs(Pages) do
                p.Visible = (p == page)
                TabButtons[i].BackgroundTransparency = (p == page) and 0.8 or 1
                TabButtons[i].TextColor3 = (p == page) and SiyahPembePalette.Accent or SiyahPembePalette.TextDesc
            end
            cascade(page)
        end
    end)
    return page
end

local function createToggle(name, page, callback)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(1, -10, 0, 42)
    frame.BackgroundColor3 = SiyahPembePalette.PanelBG
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0.04, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = SiyahPembePalette.TextTitle
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0, 44, 0, 22)
    toggleBtn.Position = UDim2.new(1, -55, 0.5, -11)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    toggleBtn.Text = ""
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame", toggleBtn)
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = UDim2.new(0, 3, 0.5, -8)
    circle.BackgroundColor3 = SiyahPembePalette.TextDesc
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local active = false
    toggleBtn.MouseButton1Click:Connect(function()
        active = not active
        TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = active and SiyahPembePalette.Accent or Color3.fromRGB(30, 30, 35)}):Play()
        circle:TweenPosition(active and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8), "Out", "Back", 0.3, true)
        callback(active)
        notify(name, active and "Status: Enabled" or "Status: Disabled")
    end)
end

local function createSlider(name, min, max, default, page, callback)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundColor3 = SiyahPembePalette.PanelBG
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Position = UDim2.new(0.04, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = SiyahPembePalette.TextDesc
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBG = Instance.new("Frame", frame)
    sliderBG.Size = UDim2.new(0.92, 0, 0, 4)
    sliderBG.Position = UDim2.new(0.04, 0, 0.7, 0)
    sliderBG.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderBG.BorderSizePixel = 0
    Instance.new("UICorner", sliderBG).CornerRadius = UDim.new(1, 0)
    
    local sliderFill = Instance.new("Frame", sliderBG)
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = SiyahPembePalette.Accent
    sliderFill.BorderSizePixel = 0
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
    
    local button = Instance.new("TextButton", sliderBG)
    button.Size = UDim2.new(0, 12, 0, 12)
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    button.BackgroundColor3 = SiyahPembePalette.TextTitle
    button.Text = ""
    Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update()
        local pos = math.clamp((UserInputService:GetMouseLocation().X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
        button.Position = UDim2.new(pos, 0, 0.5, 0)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (max - min) * pos)
        label.Text = name .. ": " .. val
        callback(val)
    end
    
    button.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            if dragging then notify(name, "Set to: " .. label.Text:split(": ")[2]) end
            dragging = false 
        end 
    end)
    RunService.RenderStepped:Connect(function() if dragging then update() end end)
end

---------------------------------------------------------
-- 9. HİLE MODÜLLERİ (MOVEMENT & TARGETING)
---------------------------------------------------------
local MovePage = createTab("Movement", "🏃", true)
local PlayerPage = createTab("Targeting", "🎯", false)

local moveActive = false
local flyActive = false
local noclipActive = false

createToggle("Super Speed", MovePage, function(v) moveActive = v end)
createSlider("Speed Multiplier", 1, 15, 2, MovePage, function(v) Settings.Speed = v end)
createToggle("Fly Mode", MovePage, function(v) flyActive = v end)
createSlider("Flight Speed", 10, 300, 60, MovePage, function(v) Settings.FlySpeed = v end)
createToggle("NoClip", MovePage, function(v) noclipActive = v end)

table.insert(Connections, RunService.RenderStepped:Connect(function(dt)
    if not ScriptRunning then return end
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if not hrp or not hum then return end

        if flyActive then
            hum.PlatformStand = true
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
            if dir.Magnitude > 0 then dir = dir.Unit end
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.CFrame = hrp.CFrame + (dir * Settings.FlySpeed * dt)
        else
            hum.PlatformStand = false
        end

        if moveActive and hum.MoveDirection.Magnitude > 0 and not flyActive then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * Settings.Speed * 0.1)
        end
        
        if noclipActive then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end))

local TargetBox = Instance.new("TextBox", PlayerPage)
TargetBox.Size = UDim2.new(1, -10, 0, 40)
TargetBox.BackgroundColor3 = SiyahPembePalette.PanelBG
TargetBox.TextColor3 = SiyahPembePalette.Accent
TargetBox.PlaceholderText = "Enter target name..."
TargetBox.Font = Enum.Font.GothamBold
TargetBox.TextSize = 13
Instance.new("UICorner", TargetBox).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", TargetBox).Color = Color3.fromRGB(40, 40, 50)

local function getPlr()
    local name = TargetBox.Text:lower()
    if name == "" then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(name) or p.DisplayName:lower():find(name) then return p end
    end
end

local function btn(txt, col, callback)
    local b = Instance.new("TextButton", PlayerPage)
    b.Size = UDim2.new(1, -10, 0, 38)
    b.BackgroundColor3 = SiyahPembePalette.PanelBG
    b.Text = txt
    b.TextColor3 = SiyahPembePalette.TextTitle
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", b)
    s.Color = col
    s.Transparency = 0.5
    b.MouseButton1Click:Connect(function()
        callback()
        notify(txt, "Command executed successfully.")
    end)
end

btn("Teleport To (Goto)", SiyahPembePalette.Accent, function()
    local t = getPlr()
    if t and t.Character and LocalPlayer.Character then 
        LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) 
    end
end)

local brg = false
local frz = false
createToggle("Bring (Loop)", PlayerPage, function(v) brg = v end)
createToggle("Freeze (Loop)", PlayerPage, function(v) frz = v end)

table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not ScriptRunning then return end
    pcall(function()
        local t = getPlr()
        if not t or not t.Character then return end
        if brg and LocalPlayer.Character then 
            t.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4) 
        end
        if frz then 
            t.Character.HumanoidRootPart.Anchored = true 
        else 
            t.Character.HumanoidRootPart.Anchored = false 
        end
    end)
end))

local loaded = false
task.spawn(function()
    task.wait(8.3) 
    if MainFrame.Visible and not loaded then
        loaded = true
        cascade(MovePage)
    end
end)
