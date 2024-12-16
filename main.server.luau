local Players = game:GetService("Players")

local function onPlayerAdded(player: Player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Parent = leaderstats
end

local function init()
    Players.PlayerAdded:Connect(onPlayerAdded)
end

init()
