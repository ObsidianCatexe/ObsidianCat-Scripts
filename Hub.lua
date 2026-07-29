local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local GUI_NAME = "ObsidianCat_Hub_Selector"

---------------------------------------------------------
-- 1. GÜVENLİ GUI OLUŞTURMA & TEMİZLİK
---------------------------------------------------------
local targetParent
pcall(function() targetParent = gethui and gethui() or CoreGui end)
if not targetParent then targetParent = LocalPlayer:WaitForChild("PlayerGui") end

pcall(function()
    for _, v in ipairs(targetParent:GetChildren()) do 
        if string.find(v.Name, "ObsidianCat") then 
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
-- 2. PALET & BLUR EFEKTİ
---------------------------------------------------------
local Palette = {
    MainBG = Color3.fromRGB(12, 12, 15),     
    PanelBG = Color3.fromRGB(18, 18, 22),   
    Accent = Color3.fromRGB(255, 105, 180), 
    TextTitle = Color3.fromRGB(255, 255, 255), 
    TextDesc = Color3.fromRGB(160, 160, 170),  
    Hover = Color3.fromRGB(30, 30, 35)
}

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Enabled = true
pcall(function() BlurEffect.Parent = Lighting end)

TweenService:Create(BlurEffect, TweenInfo.new(0.5), {Size = 24}):Play()

---------------------------------------------------------
-- 3. ANA MENÜ ÇERÇEVESİ
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 0, 0, 0) 
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5) 
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Palette.MainBG
MainFrame.ClipsDescendants = true 

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Palette.Accent
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.5

-- Açılış Animasyonu
TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 700, 0, 480)}):Play()

-- Üst Başlık
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "OBSIDIANCAT | OYUN SEÇİM MERKEZİ"
Title.TextColor3 = Palette.TextTitle
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel", TopBar)
SubTitle.Size = UDim2.new(1, -40, 0, 20)
SubTitle.Position = UDim2.new(0, 20, 0, 30)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Hileyi yüklemek istediğin oyunu seç."
SubTitle.TextColor3 = Palette.TextDesc
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 12
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 10)
CloseBtn.BackgroundColor3 = Palette.PanelBG
CloseBtn.Text = "✖"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", CloseBtn).Color = Color3.fromRGB(255, 50, 50)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    if BlurEffect then TweenService:Create(BlurEffect, TweenInfo.new(0.4), {Size = 0}):Play() end
    task.wait(0.4)
    ScreenGui:Destroy()
end)

---------------------------------------------------------
-- 4. OYUN LİSTESİ VE YAPI
---------------------------------------------------------
local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollFrame.Size = UDim2.new(1, -40, 1, -80)
ScrollFrame.Position = UDim2.new(0, 20, 0, 60)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Palette.Accent

local Grid = Instance.new("UIGridLayout", ScrollFrame)
Grid.CellSize = UDim2.new(0, 210, 0, 140)
Grid.CellPadding = UDim2.new(0, 15, 0, 15)
Grid.SortOrder = Enum.SortOrder.LayoutOrder

local Games = {
    { Name = "DesertStorm [EXT]", ID = 115872975504419, Script = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/DesertStorm.lua" },
    { Name = "Examination", ID = 10165583746, Script = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/Examination.lua" },
    { Name = "BRM5", ID = 2916899287, Script = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/BRM5.lua" },
    { Name = "SCP Site Roleplay", ID = 3226555017, Script = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/SCPSR.lua" },
    { Name = "Fling Things", ID = 2668101271, Script = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/FTAP.lua" },
    { Name = "ENTRENCHED WW1", ID = 1281592938, Script = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/WW1.lua" },
    { Name = "UTD:X", ID = 7488190691, Script = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/UTD%3AX" },
    { Name = "Universal", ID = 0, Script = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/Universal.lua", IsUniversal = true }
}

---------------------------------------------------------
-- 5. KART OLUŞTURUCU (THUMBNAIL FETCHING)
---------------------------------------------------------
local function loadScript(scriptUrl)
    -- Menüyü kapat ve efekti sil
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    if BlurEffect then TweenService:Create(BlurEffect, TweenInfo.new(0.4), {Size = 0}):Play() end
    task.wait(0.4)
    ScreenGui:Destroy()
    
    -- Seçilen hileyi çalıştır
    loadstring(game:HttpGet(scriptUrl))()
end

for index, gameData in ipairs(Games) do
    local Card = Instance.new("Frame", ScrollFrame)
    Card.BackgroundColor3 = Palette.PanelBG
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
    
    local CardStroke = Instance.new("UIStroke", Card)
    CardStroke.Color = Palette.Accent
    CardStroke.Transparency = 0.8
    CardStroke.Thickness = 1

    -- Kapak Fotoğrafı
    local IconFrame = Instance.new("Frame", Card)
    IconFrame.Size = UDim2.new(1, -10, 0, 90)
    IconFrame.Position = UDim2.new(0, 5, 0, 5)
    IconFrame.BackgroundColor3 = Palette.MainBG
    IconFrame.ClipsDescendants = true
    Instance.new("UICorner", IconFrame).CornerRadius = UDim.new(0, 6)

    local Icon = Instance.new("ImageLabel", IconFrame)
    Icon.Size = UDim2.new(1, 0, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.ScaleType = Enum.ScaleType.Crop
    
    if gameData.IsUniversal then
        -- Universal için ObsidianCat Temalı bir ikon
        Icon.Image = "rbxassetid://13247071987" -- Örnek bir terminal/hacker ikonu
        Icon.ImageColor3 = Palette.Accent
        Icon.ScaleType = Enum.ScaleType.Fit
    else
        -- Roblox API'sinden Oyun İkonunu Çekme (Asenkron)
        task.spawn(function()
            pcall(function()
                local productInfo = MarketplaceService:GetProductInfo(gameData.ID)
                if productInfo and productInfo.IconImageAssetId then
                    Icon.Image = "rbxassetid://" .. productInfo.IconImageAssetId
                else
                    -- Eğer özel/gizli ID ise (DesertStorm gibi) fallback olarak düz Asset ID dene
                    Icon.Image = "rbxthumb://type=Asset&id=" .. gameData.ID .. "&w=150&h=150"
                end
            end)
        end)
    end

    -- Oyun İsmi
    local NameLabel = Instance.new("TextLabel", Card)
    NameLabel.Size = UDim2.new(1, -10, 0, 30)
    NameLabel.Position = UDim2.new(0, 5, 0, 100)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = gameData.Name
    NameLabel.TextColor3 = Palette.TextTitle
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextSize = 12
    NameLabel.TextWrapped = true

    -- Tıklama Butonu (Bütün Kartı Kaplar)
    local ClickBtn = Instance.new("TextButton", Card)
    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Text = ""

    -- Hover Efekti
    ClickBtn.MouseEnter:Connect(function()
        TweenService:Create(Card, TweenInfo.new(0.2), {BackgroundColor3 = Palette.Hover}):Play()
        TweenService:Create(CardStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)
    
    ClickBtn.MouseLeave:Connect(function()
        TweenService:Create(Card, TweenInfo.new(0.2), {BackgroundColor3 = Palette.PanelBG}):Play()
        TweenService:Create(CardStroke, TweenInfo.new(0.2), {Transparency = 0.8}):Play()
    end)

    ClickBtn.MouseButton1Click:Connect(function()
        loadScript(gameData.Script)
    end)
end

-- Canvas boyutunu ayarlama (Grid Layout'a göre)
task.spawn(function()
    task.wait(0.1)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Grid.AbsoluteContentSize.Y + 20)
end)
