local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local sleigh = Workspace:WaitForChild("Sleigh")

local toggleSleightRemote = ReplicatedStorage:WaitForChild("ToggleSleight")

local function onToggleSleightEvent(toggle)
    for _, descendant in ipairs(sleigh:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.Transparency = toggle and 0 or 1
        end
        if descendant:IsA("ProximityPrompt") then
            descendant.Enabled = toggle
        end
    end
end

local function init()
    toggleSleightRemote.OnClientEvent:Connect(onToggleSleightEvent)
end

init()
