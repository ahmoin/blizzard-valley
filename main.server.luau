local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local sleigh: Model = Workspace:WaitForChild("Sleigh")

local sleighPrompt: ProximityPrompt = nil

local toggleSleightRemote = Instance.new("RemoteEvent")
toggleSleightRemote.Name = "ToggleSleight"
toggleSleightRemote.Parent = ReplicatedStorage

local function setupSleigh()
    local hitbox = Instance.new("Part")
    hitbox.Anchored = true
    hitbox.Transparency = 1
    hitbox.Name = "Hitbox"
    hitbox.Size = sleigh:GetExtentsSize()
    hitbox.Position = sleigh:GetPivot().Position
    hitbox.CanCollide = false
    hitbox.CanTouch = false
    hitbox.CanQuery = false
    hitbox.Parent = sleigh

    local proximityPrompt = Instance.new("ProximityPrompt")
    proximityPrompt.Parent = hitbox
    proximityPrompt.RequiresLineOfSight = false
    proximityPrompt.ObjectText = "Sleigh"
    proximityPrompt.ActionText = "Ride"
    proximityPrompt.MaxActivationDistance = 32
    sleighPrompt = proximityPrompt
end

local function cleanUpExistingSleighs(player: Player)
    for _, sleigh in Workspace:GetChildren() do
        if sleigh:IsA("Model") and sleigh.Name == tostring(player.UserId) .. "Sleigh" then
            sleigh:Destroy()
        end
    end
end

local function onSleighPromptTriggered(player: Player)
    local character = player.Character
    if not character then
        return
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Sit then
        return
    end
    cleanUpExistingSleighs(player)
    local sleighClone = sleigh:Clone()
    sleighClone.Name = tostring(player.UserId) .. "Sleigh"
    for _, child in sleighClone:GetChildren() do
        if child:IsA("Model") then
            child:Destroy()
        end
    end
    local hitbox = sleighClone:FindFirstChild("Hitbox")
    if not hitbox or not hitbox:IsA("BasePart") then
        local newHitbox = Instance.new("Part")
        newHitbox.Anchored = true
        newHitbox.Transparency = 1
        newHitbox.Name = "Hitbox"
        newHitbox.Size = sleighClone:GetExtentsSize()
        newHitbox.Position = sleighClone:GetPivot().Position
        newHitbox.CanCollide = false
        newHitbox.CanTouch = false
        newHitbox.CanQuery = false
        newHitbox.Parent = sleighClone
        hitbox = newHitbox
    end
    if not hitbox or not hitbox:IsA("BasePart") then
        return
    end
    local seat = Instance.new("Seat")
    seat.Parent = hitbox
    seat.Position = sleighClone:GetPivot().Position
    seat.Transparency = 1
    seat.CFrame *= CFrame.Angles(0, 0, 0)
    seat.CFrame *= CFrame.new(0, 0.5, 8)
    seat.Parent = sleighClone
    for _, child in sleighClone:GetChildren() do
        if child == hitbox or not child:IsA("BasePart") then
            local proximityPrompt = child:FindFirstChildOfClass("ProximityPrompt")
            if proximityPrompt then
                proximityPrompt:Destroy()
            end
            continue
        end
        child.Anchored = false
        local weldConstraint = Instance.new("WeldConstraint")
        weldConstraint.Parent = child
        weldConstraint.Part0 = child
        weldConstraint.Part1 = hitbox
    end
    sleighClone.Parent = Workspace
    sleighClone:PivotTo(sleigh:GetPivot() * CFrame.new(0, 4, 0))
    seat:Sit(humanoid)
    local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui")
    local screenGui = playerGui:FindFirstChild("SleighScreenGui") or playerGui:WaitForChild("SleighScreenGui")
    if playerGui and screenGui and screenGui:IsA("ScreenGui") then
        screenGui.Enabled = true
    end
    local occupantChangedConnection = nil
    occupantChangedConnection = seat:GetPropertyChangedSignal("Occupant"):Connect(function()
        cleanUpExistingSleighs(player)
        toggleSleightRemote:FireClient(player, true)
        if playerGui and screenGui and screenGui:IsA("ScreenGui") then
            screenGui.Enabled = false
        end
        if occupantChangedConnection and typeof(occupantChangedConnection) == "RBXScriptConnection" then
            occupantChangedConnection:Disconnect()
        end
    end)
    toggleSleightRemote:FireClient(player)

    local tweenInfo = TweenInfo.new(
        256,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut
    )
    
    local targetCFrame = hitbox.CFrame * CFrame.new(0, 0, -2048)
    local tween = TweenService:Create(hitbox, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
end

local function onPlayerAdded(player: Player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Parent = leaderstats

    local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui")
    if not playerGui or not playerGui:IsA("PlayerGui") then
        return
    end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SleighScreenGui"
    screenGui.Parent = playerGui
    screenGui.Enabled = false

    local frame = Instance.new("Frame")
    frame.Parent = screenGui
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Position = UDim2.new(0.5, 0, 0.75, 0)
    frame.Size = UDim2.new(0.1, 0, 0.2, 0)
    frame.BackgroundTransparency = 1

    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Parent = frame
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Image = "rbxassetid://5965306994"
end

local function init()
    local backgroundMusic = Instance.new("Sound")
    backgroundMusic.Parent = SoundService
    backgroundMusic.SoundId = "rbxassetid://9041839131"
    backgroundMusic.Volume = 1
    backgroundMusic.Looped = true
    backgroundMusic:Play()
    setupSleigh()
    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    while not sleighPrompt or typeof(sleighPrompt) ~= "Instance" do
        task.wait(0.1)
    end
    sleighPrompt.Triggered:Connect(onSleighPromptTriggered)
end

init()
