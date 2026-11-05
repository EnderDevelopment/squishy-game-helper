local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MAX_DISTANCE = 12
local REQUEST_COOLDOWN = 1.5
local MAX_NAME_LENGTH = 100

local remotesFolder = ReplicatedStorage:FindFirstChild("GiveSystem")
if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "GiveSystem"
    remotesFolder.Parent = ReplicatedStorage
end

local giveRequest = remotesFolder:FindFirstChild("GiveRequest")
if not giveRequest then
    giveRequest = Instance.new("RemoteEvent")
    giveRequest.Name = "GiveRequest"
    giveRequest.Parent = remotesFolder
end

local giveResult = remotesFolder:FindFirstChild("GiveResult")
if not giveResult then
    giveResult = Instance.new("RemoteEvent")
    giveResult.Name = "GiveResult"
    giveResult.Parent = remotesFolder
end

local lastRequestAt = {}

local function sendResult(player, success, message)
    giveResult:FireClient(player, success, message)
end

local function getCharacterRoot(player)
    local character = player.Character
    if not character then
        return nil
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        return nil
    end

    return root
end

local function findTool(player, requestedName)
    if typeof(requestedName) ~= "string" or #requestedName == 0 or #requestedName > MAX_NAME_LENGTH then
        return nil
    end

    local backpack = player:FindFirstChildOfClass("Backpack")
    local character = player.Character
    local containers = {backpack, character}

    for _, container in ipairs(containers) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("Tool") and child.Name == requestedName then
                    return child
                end
            end
        end
    end

    return nil
end

giveRequest.OnServerEvent:Connect(function(sender, target, toolName)
    local now = os.clock()
    local previousRequest = lastRequestAt[sender]
    if previousRequest and now - previousRequest < REQUEST_COOLDOWN then
        sendResult(sender, false, "Please wait before giving another item.")
        return
    end
    lastRequestAt[sender] = now

    if typeof(target) ~= "Instance" or not target:IsA("Player") or target == sender or target.Parent ~= Players then
        sendResult(sender, false, "That player is not available.")
        return
    end

    local senderRoot = getCharacterRoot(sender)
    local targetRoot = getCharacterRoot(target)
    if not senderRoot or not targetRoot then
        sendResult(sender, false, "Both players must be alive.")
        return
    end

    if (senderRoot.Position - targetRoot.Position).Magnitude > MAX_DISTANCE then
        sendResult(sender, false, "You are too far away from that player.")
        return
    end

    local tool = findTool(sender, toolName)
    if not tool or not tool:IsDescendantOf(sender) then
        sendResult(sender, false, "You do not have that item.")
        return
    end

    local targetBackpack = target:FindFirstChildOfClass("Backpack")
    if not targetBackpack then
        sendResult(sender, false, "The receiving player's inventory is unavailable.")
        return
    end

    tool.Parent = targetBackpack
    sendResult(sender, true, string.format("You gave %s to %s.", tool.Name, target.DisplayName))
    sendResult(target, true, string.format("%s gave you %s.", sender.DisplayName, tool.Name))
end)

Players.PlayerRemoving:Connect(function(player)
    lastRequestAt[player] = nil
end)
