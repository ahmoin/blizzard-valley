local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local sleigh = Workspace:WaitForChild("Sleigh")

local toggleSleighRemote = ReplicatedStorage:WaitForChild("ToggleSleigh")
local shootGiftRemote = ReplicatedStorage:WaitForChild("ShootGift")

local function onToggleSleighEvent(toggle)
    for _, descendant in ipairs(sleigh:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Name ~= "Hitbox" then
            descendant.Transparency = toggle and 0 or 1
        end
        if descendant:IsA("ProximityPrompt") then
            descendant.Enabled = toggle
        end
    end
end

local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        local camera = Workspace.CurrentCamera
        if camera then
            shootGiftRemote:FireServer(camera.CFrame.LookVector)
        end
    end
end

local function init()
    toggleSleighRemote.OnClientEvent:Connect(onToggleSleighEvent)
    UserInputService.InputBegan:Connect(onInputBegan)
end

init()
