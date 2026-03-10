-- ==========================================
-- OBSIDIANCAT UNIVERSAL HUB LOADER
-- ==========================================
local PlaceId = game.PlaceId
local StarterGui = game:GetService("StarterGui")

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "ObsidianCat.exe",
        Text = "Oyun taranıyor, uygun script seçiliyor...",
        Duration = 3
    })
end)

task.wait(1)

local UniversalScript = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/Universal.lua"

local Games = {
    [1054526971] = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/BRM5.lua",
    [3730079862] = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/Examination.lua", 
    [1165835263] = "https://raw.githubusercontent.com/ObsidianCatexe/ObsidianCat-Scripts/refs/heads/main/SCPSR.lua",
}

local scriptToLoad = Games[game.GameId]

if scriptToLoad then
    print("[ObsidianCat]: Desteklenen oyun algılandı! Özel script yükleniyor...")
    loadstring(game:HttpGet(scriptToLoad))()
else
    print("[ObsidianCat]: Bu oyuna özel script yok. Universal (Genel) menü yükleniyor...")
    loadstring(game:HttpGet(UniversalScript))()
end
