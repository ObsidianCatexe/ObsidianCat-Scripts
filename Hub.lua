local currentPlace = game.PlaceId
local currentGame = game.GameId

local UniversalScript = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/Universal.lua"

local Games = {
    -- Blackhawk Rescue Mission 5 (BRM5)
    [2916899287] = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/BRM5.lua",
    
    -- Examination
    [10165583746] = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/Examination.lua",
    
    -- SCP Site Roleplay
    [3226555017] = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/SCPSR.lua",

    --
    [2668101271] = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/FTAP.lua"
}

local scriptToLoad = Games[currentPlace] or Games[currentGame]

if scriptToLoad then
    print("[ObsidianCat]: Desteklenen oyun algılandı! Özel script yükleniyor...")
    loadstring(game:HttpGet(scriptToLoad))()
else
    print("[ObsidianCat]: Eşleşme başarısız. Kimlik tespiti yapılıyor...")
    
    -- ZORUNLU EKRAN BİLDİRİMİ (GÖRMEMEN İMKANSIZ)
    local targetParent
    pcall(function() targetParent = gethui and gethui() or game:GetService("CoreGui") end)
    if not targetParent then targetParent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

    local warningGui = Instance.new("ScreenGui")
    warningGui.Name = "ObsidianCat_Diagnostic"
    warningGui.Parent = targetParent

    local warningFrame = Instance.new("Frame", warningGui)
    warningFrame.Size = UDim2.new(0, 400, 0, 120)
    warningFrame.Position = UDim2.new(0.5, -200, 0, 20)
    warningFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", warningFrame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", warningFrame)
    stroke.Color = Color3.fromRGB(255, 50, 50)
    stroke.Thickness = 2

    local warningText = Instance.new("TextLabel", warningFrame)
    warningText.Size = UDim2.new(1, -20, 1, -20)
    warningText.Position = UDim2.new(0, 10, 0, 10)
    warningText.BackgroundTransparency = 1
    warningText.TextColor3 = Color3.fromRGB(255, 255, 255)
    warningText.Font = Enum.Font.GothamBold
    warningText.TextSize = 18
    warningText.TextWrapped = true
    warningText.Text = "HATA: ID EŞLEŞMEDİ!\n\nŞu Anki PlaceID: " .. tostring(currentPlace) .. "\nŞu Anki GameID: " .. tostring(currentGame)

    -- Kopyalama (Eğer executor destekliyorsa direkt CTRL+C yapar)
    pcall(function() setclipboard("PlaceID: " .. tostring(currentPlace) .. " | GameID: " .. tostring(currentGame)) end)

    -- Ekranda 5 saniye kalmasını bekle, sonra Universal'ı aç
    task.wait(5)
    warningGui:Destroy()
    
    loadstring(game:HttpGet(UniversalScript))()
end
