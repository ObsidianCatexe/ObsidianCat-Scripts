-- ==========================================
-- OBSIDIANCAT UNIVERSAL HUB LOADER
-- ==========================================
local PlaceId = game.PlaceId
local StarterGui = game:GetService("StarterGui")

-- Loader çalıştığında ekrana ufak bir bildirim atar
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "ObsidianCat.exe",
        Text = "Oyun taranıyor, uygun script seçiliyor...",
        Duration = 3
    })
end)

task.wait(1)

-- 1. HERKESE UYGUN (UNIVERSAL) SCRIPT LİNKİN:
-- (Eğer girdiğin oyun aşağıdaki listede yoksa bu script çalışır. Buraya V7.1'in Raw linkini koy)
local UniversalScript = "https://raw.githubusercontent.com/SENIN_ADIN/ObsidianCat-Scripts/main/Universal.lua"

-- 2. OYUNLARA ÖZEL SCRİPT LİSTESİ:
-- (Köşeli parantez içine oyunun ID'sini, tırnak içine o oyun için yaptığın hilenin Raw linkini yaz)
local Games = {
    [606849621] = "https://raw.githubusercontent.com/SENIN_ADIN/ObsidianCat-Scripts/main/Jailbreak.lua", -- Jailbreak
    [155615604] = "https://raw.githubusercontent.com/SENIN_ADIN/ObsidianCat-Scripts/main/PrisonLife.lua", -- Prison Life
    [4924922222] = "https://raw.githubusercontent.com/SENIN_ADIN/ObsidianCat-Scripts/main/Brookhaven.lua", -- Brookhaven
}

-- 3. KARAR VE ÇALIŞTIRMA AŞAMASI
local scriptToLoad = Games[PlaceId]

if scriptToLoad then
    -- Eğer oyun listede varsa:
    print("[ObsidianCat]: Desteklenen oyun algılandı! Özel script yükleniyor...")
    loadstring(game:HttpGet(scriptToLoad))()
else
    -- Eğer oyun listede yoksa:
    print("[ObsidianCat]: Bu oyuna özel script yok. Universal (Genel) menü yükleniyor...")
    loadstring(game:HttpGet(UniversalScript))()
end
