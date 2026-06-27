-- SPIN FOR A SOCCER CARD --
local CalmLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/calmlib/refs/heads/main/src.lua"))()

local window = CalmLib:win("sub 2 vaehz")
local section1 = window:tab("Autofarm", "rbxassetid://109121102062195")
local section3 = window:tab("Packs Setup", "rbxassetid://99579688577014") 
local section2 = window:tab("Settings", "rbxassetid://99579688577014")

local plr = game:GetService("Players").LocalPlayer

getgenv().farming = false
getgenv().farmsettings = {
    packs = false,
    rebirth = false,
    collect = false,
    index = false,
}

getgenv().selectedPacksList = {}

local packPriority = {
    "Seraph", "Bloodclaw", "Infinity", "Terminus", "Valor", "Ruin", "Fallen", "Conquest", 
    "Dusk", "Dawn", "Bloom", "Wither", "Oracle", "Enigma", "Abyssal", "Genesis", 
    "Omega", "Alpha", "Ordain", "Chaos", "Heaven", "Hades", "Eclipse", "Cosmic", 
    "Corrupted", "Infernal", "Shadow", "Toxic", "Bonded", "Diamond", "Platinum", 
    "Gold", "Silver", "Bronze"
}

for _, packName in ipairs(packPriority) do
    getgenv().selectedPacksList[packName] = false
end

local function hasPackInInventory(packName)
    local playerGui = plr:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local packContainer = playerGui:FindFirstChild("OtherPacks", true) 
    if not packContainer then 
        return false
    end

    for _, item in ipairs(packContainer:GetDescendants()) do
        if string.find(string.lower(item.Name), string.lower(packName)) then
            local amountLabel = item:FindFirstChildOfClass("TextLabel") or item
            if amountLabel and amountLabel:IsA("TextLabel") then
                local text = amountLabel.Text or ""
                if string.find(text, "x0") then
                    return false
                end
            end
            return true
        end
    end

    
    return false
end

section1:label("Main Farm Settings:")

section1:toggle("Auto Packs", false, function(v)
    getgenv().farmsettings.packs = v
end)

section1:toggle("Auto Collect", false, function(v)
    getgenv().farmsettings.collect = v
end)
section1:toggle("Auto Rebirth", false, function(v)
    getgenv().farmsettings.rebirth = v
end)
section1:toggle("Auto Index", false, function(v)
    getgenv().farmsettings.index = v
end)

pcall(function()
    section3:label("Enable packs to open. Best selected will open first(lazy to find new icon)")

    for _, packName in ipairs(packPriority) do
        section3:toggle(packName .. " Pack", false, function(v)
            getgenv().selectedPacksList[packName] = v
        end)
    end
end)

getgenv().antiafk = true

plr.Idled:Connect(function()
    if not getgenv().antiafk then return end
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

section2:toggle("Disable 3D Rendering", false, function(v)
    game:GetService("RunService"):Set3dRenderingEnabled(not v)
end)

section2:toggle("Anti AFK", true, function(v)
    getgenv().antiafk = v
end)

task.spawn(function()
    local CollectEvent = game:GetService("ReplicatedStorage").Remotes:WaitForChild("CollectSlot", 5)
    local MyPlots = workspace:WaitForChild("Plots", 5)
    if not MyPlots or not CollectEvent then return end
    
    local MySlots = MyPlots:WaitForChild("3", 5):WaitForChild("Slots", 5)
    if not MySlots then return end

    while true do
        if getgenv().farmsettings and getgenv().farmsettings.collect then
            for _, slotFolder in ipairs(MySlots:GetChildren()) do
                local slotNumber = tonumber(slotFolder.Name)
                if slotNumber and slotFolder:FindFirstChild("Cash") then
                    CollectEvent:FireServer(slotNumber)
                    task.wait(0.1)
                end
            end
        end
        task.wait(1)
    end
end)

task.spawn(function()
    local RemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
    if not RemotesFolder then return end

    local RebirthEvent = RemotesFolder:FindFirstChild("Rebirth") 
        or RemotesFolder:FindFirstChild("DoRebirth") 
        or RemotesFolder:FindFirstChild("ClaimRebirth")

    while true do
        if getgenv().farmsettings and getgenv().farmsettings.rebirth then
            if RebirthEvent then
                RebirthEvent:FireServer()
            end
        end
        task.wait(5) 
    end
end)

task.spawn(function()
    local OpenPackRemote = game:GetService("ReplicatedStorage").Remotes:WaitForChild("OpenPack", 5)
    if not OpenPackRemote then return end

    pcall(function()
        local Source = game:GetService("ReplicatedStorage"):WaitForChild("Source", 2)
        local Client = Source and Source:WaitForChild("Client", 2)
        local UI = Client and Client:WaitForChild("UI", 2)
        local AnimationController = UI and UI:FindFirstChild("PackAnimationController")

        if AnimationController and AnimationController:IsA("ModuleScript") then
            local module = require(AnimationController)
            for funcName, func in pairs(module) do
                if type(func) == "function" then
                    module[funcName] = function(...) return end
                end
            end
        end
    end)

    while true do
        if getgenv().farmsettings and getgenv().farmsettings.packs then
            local targetPack = nil
            
            for _, packName in ipairs(packPriority) do
                if getgenv().selectedPacksList[packName] == true then
                    if hasPackInInventory(packName) then
                        targetPack = packName
                        break 
                    end
                end
            end
            
            if targetPack then
                pcall(function()
                    if OpenPackRemote:IsA("RemoteFunction") then
                        OpenPackRemote:InvokeServer(targetPack)
                    else
                        OpenPackRemote:FireServer(targetPack)
                    end
                end)
                task.wait(0.25)
            else
                task.wait(0.5) 
            end
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    local RemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
    if not RemotesFolder then return end
    
    local ClaimIndexEvent = RemotesFolder:WaitForChild("ClaimAllIndexGems", 5)
    if not ClaimIndexEvent then return end

    while true do
        if getgenv().farmsettings and getgenv().farmsettings.index then
            pcall(function()
                ClaimIndexEvent:FireServer()
            end)
        end
        task.wait(5)
    end
end)