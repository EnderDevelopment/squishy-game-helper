local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local giveSystem = ReplicatedStorage:WaitForChild("GiveSystem")
local giveRequest = giveSystem:WaitForChild("GiveRequest")
local giveResult = giveSystem:WaitForChild("GiveResult")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GiveGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.AnchorPoint = Vector2.new(1, 1)
openButton.Position = UDim2.new(1, -24, 1, -24)
openButton.Size = UDim2.fromOffset(140, 44)
openButton.BackgroundColor3 = Color3.fromRGB(45, 120, 220)
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.Text = "Give item"
openButton.TextSize = 18
openButton.Font = Enum.Font.GothamBold
openButton.Parent = screenGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(360, 330)
panel.BackgroundColor3 = Color3.fromRGB(30, 34, 44)
panel.Visible = false
panel.Parent = screenGui

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(16, 8)
title.Size = UDim2.new(1, -60, 0, 38)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Text = "Give an item"
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.Parent = panel

local closeButton = Instance.new("TextButton")
closeButton.Position = UDim2.new(1, -42, 0, 10)
closeButton.Size = UDim2.fromOffset(32, 30)
closeButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = panel

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(16, 48)
status.Size = UDim2.new(1, -32, 0, 36)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(210, 215, 225)
status.Text = "Choose a nearby player and one of your tools."
status.TextWrapped = true
status.TextSize = 14
status.Font = Enum.Font.Gotham
status.Parent = panel

local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Position = UDim2.fromOffset(16, 90)
playerList.Size = UDim2.new(1, -32, 0, 105)
playerList.BackgroundColor3 = Color3.fromRGB(42, 47, 60)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 6
playerList.CanvasSize = UDim2.new()
playerList.Parent = panel

local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0, 4)
playerLayout.Parent = playerList

local toolList = Instance.new("ScrollingFrame")
toolList.Name = "ToolList"
toolList.Position = UDim2.fromOffset(16, 204)
toolList.Size = UDim2.new(1, -32, 0, 105)
toolList.BackgroundColor3 = Color3.fromRGB(42, 47, 60)
toolList.BorderSizePixel = 0
toolList.ScrollBarThickness = 6
toolList.CanvasSize = UDim2.new()
toolList.Parent = panel

local toolLayout = Instance.new("UIListLayout")
toolLayout.Padding = UDim.new(0, 4)
toolLayout.Parent = toolList

local selectedPlayer = nil
local selectedToolName = nil

local function addChoice(parent, label, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -8, 0, 32)
    button.BackgroundColor3 = Color3.fromRGB(65, 73, 91)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = label
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Parent = parent
    button.Activated:Connect(callback)
    return button
end

local function getRoot(player)
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function refreshPlayers()
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    selectedPlayer = nil
    local myRoot = getRoot(localPlayer)
    if not myRoot then
        status.Text = "Your character is not ready yet."
        return
    end
    local candidates = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local root = getRoot(player)
            if root and (root.Position - myRoot.Position).Magnitude <= 12 then
                table.insert(candidates, player)
            end
        end
    end
    table.sort(candidates, function(a, b) return a.DisplayName:lower() < b.DisplayName:lower() end)
    for _, player in ipairs(candidates) do
        addChoice(playerList, player.DisplayName .. " (@" .. player.Name .. ")", function()
            selectedPlayer = player
            status.Text = "Selected " .. player.DisplayName .. ". Now choose an item."
        end)
    end
    playerList.CanvasSize = UDim2.fromOffset(0, #candidates * 36)
    if #candidates == 0 then status.Text = "No other players are within 12 studs." end
end

local function refreshTools()
    for _, child in ipairs(toolList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    selectedToolName = nil
    local tools = {}
    local backpack = localPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then table.insert(tools, item) end
        end
    end
    local character = localPlayer.Character
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") then table.insert(tools, item) end
        end
    end
    table.sort(tools, function(a, b) return a.Name:lower() < b.Name:lower() end)
    for _, tool in ipairs(tools) do
        addChoice(toolList, tool.Name, function()
            if not selectedPlayer or selectedPlayer.Parent ~= Players then
                status.Text = "Select a nearby player first."
                return
            end
            selectedToolName = tool.Name
            giveRequest:FireServer(selectedPlayer, selectedToolName)
            status.Text = "Sending item..."
        end)
    end
    toolList.CanvasSize = UDim2.fromOffset(0, #tools * 36)
    if #tools == 0 then status.Text = "You do not have any tools to give." end
end

openButton.Activated:Connect(function()
    panel.Visible = not panel.Visible
    if panel.Visible then refreshPlayers(); refreshTools() end
end)
closeButton.Activated:Connect(function() panel.Visible = false end)
Players.PlayerAdded:Connect(function() if panel.Visible then refreshPlayers() end end)
Players.PlayerRemoving:Connect(function() if panel.Visible then refreshPlayers() end end)
giveResult.OnClientEvent:Connect(function(success, message)
    status.Text = message
    if success then refreshTools() end
end)
