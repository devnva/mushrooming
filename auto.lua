-- Auto Farm LocalScript
-- StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- SETTINGS
local REFRESH_TIME = 10
local MUSHROOMS_PER_TRIP = 40
local TRADER_NAME = "Trader"

local selectedMushrooms = {}
local processedModels = {}
local mushroomsCollected = 0
local autoFarming = false
local farmGeneration = 0

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarm"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 400, 0, 430)
main.Position = UDim2.new(0, 20, 0.5, -215)
main.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
main.BorderSizePixel = 1
main.Parent = gui

-- TOP BAR
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
topBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 130, 1, 0)
title.Position = UDim2.new(0, 7, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Farm"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
title.Font = Enum.Font.ArialBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local refreshLabel = Instance.new("TextLabel")
refreshLabel.Size = UDim2.new(0, 85, 1, 0)
refreshLabel.Position = UDim2.new(1, -195, 0, 0)
refreshLabel.BackgroundTransparency = 1
refreshLabel.Text = "Refresh: 10s"
refreshLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
refreshLabel.TextSize = 11
refreshLabel.Parent = topBar

local farmButton = Instance.new("TextButton")
farmButton.Size = UDim2.new(0, 65, 0, 22)
farmButton.Position = UDim2.new(1, -108, 0, 4)
farmButton.BackgroundColor3 = Color3.fromRGB(55, 110, 65)
farmButton.Text = "Start"
farmButton.TextColor3 = Color3.new(1, 1, 1)
farmButton.TextSize = 12
farmButton.Parent = topBar

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 25, 0, 22)
minimizeButton.Position = UDim2.new(1, -55, 0, 4)
minimizeButton.Text = "-"
minimizeButton.Parent = topBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 22)
closeButton.Position = UDim2.new(1, -28, 0, 4)
closeButton.BackgroundColor3 = Color3.fromRGB(130, 55, 55)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Parent = topBar

-- CONTENT
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundTransparency = 1
content.Parent = main

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -12, 0, 25)
statusLabel.Position = UDim2.new(0, 6, 0, 5)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Select mushrooms to farm"
statusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = content

-- SCROLL LIST
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -12, 1, -38)
list.Position = UDim2.new(0, 6, 0, 32)
list.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
list.ScrollBarThickness = 8
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = content

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 2)
layout.Parent = list

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)
end)

-- HELPERS
local function getPosition(object)
    if object:IsA("BasePart") then
        return object.Position
    elseif object:IsA("Model") then
        return object:GetPivot().Position
    end
    return nil
end

local function getRoot()
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

-- REFRESH CHECKBOX LIST FROM REPLICATED STORAGE
local function refresh()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local folder = ReplicatedStorage:FindFirstChild("Mushrooms")
    if not folder then
        statusLabel.Text = "ReplicatedStorage.Mushrooms not found"
        return
    end

    local names = {}
    local counts = {}

    for _, object in ipairs(folder:GetChildren()) do
        counts[object.Name] = (counts[object.Name] or 0) + 1
    end

    for name in pairs(counts) do
        table.insert(names, name)
    end
    table.sort(names)

    if #names == 0 then
        statusLabel.Text = "No mushroom types found"
        return
    end

    for _, name in ipairs(names) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -4, 0, 32)
        row.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
        row.Parent = list

        local checkbox = Instance.new("TextButton")
        checkbox.Size = UDim2.new(0, 23, 0, 23)
        checkbox.Position = UDim2.new(0, 5, 0, 4)
        checkbox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        checkbox.TextColor3 = Color3.new(1, 1, 1)
        checkbox.TextSize = 16
        checkbox.Parent = row

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -80, 1, 0)
        label.Position = UDim2.new(0, 35, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(235, 235, 235)
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = row

        local count = Instance.new("TextLabel")
        count.Size = UDim2.new(0, 40, 1, 0)
        count.Position = UDim2.new(1, -45, 0, 0)
        count.BackgroundTransparency = 1
        count.Text = "[" .. counts[name] .. "]"
        count.TextColor3 = Color3.fromRGB(180, 180, 180)
        count.Parent = row

        local function updateCheckbox()
            local checked = selectedMushrooms[name] == true
            checkbox.Text = checked and "✓" or ""
            checkbox.BackgroundColor3 = checked
                and Color3.fromRGB(50, 125, 65)
                or Color3.fromRGB(40, 40, 40)
        end

        updateCheckbox()

        checkbox.MouseButton1Click:Connect(function()
            selectedMushrooms[name] = not selectedMushrooms[name] or nil
            updateCheckbox()
        end)
    end

    statusLabel.Text = "Mushrooms: " .. mushroomsCollected .. "/" .. MUSHROOMS_PER_TRIP
end

-- FIND CLOSEST SELECTED LIVE MUSHROOM
local function findClosestSelected()
    local folder = workspace:FindFirstChild("Mushrooms")
    local root = getRoot()
    if not folder or not root then
        return nil
    end

    local closest
    local closestDistance = math.huge

    for _, object in ipairs(folder:GetChildren()) do
        if selectedMushrooms[object.Name]
            and not processedModels[object]
            and (object:IsA("Model") or object:IsA("BasePart")) then

            local position = getPosition(object)
            if position then
                local distance = (root.Position - position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closest = object
                end
            end
        end
    end

    return closest
end

-- TELEPORT TO TRADER
local function teleportToTrader()
    local npcFolder = workspace:FindFirstChild("NPCs")
    local trader = npcFolder and npcFolder:FindFirstChild(TRADER_NAME, true)
    local root = getRoot()

    if not trader or not root then
        statusLabel.Text = "Trader NPC not found"
        return false
    end

    local position = getPosition(trader)
    if not position then
        statusLabel.Text = "Trader has no usable position"
        return false
    end

    root.CFrame = CFrame.new(position + Vector3.new(0, 4, 0))
    statusLabel.Text = "At Trader"
    return true
end

-- INTERACTION PLACEHOLDER
-- Connect these to your own game's supported collection system.
local function interactWithMushroom(target)
    warn("Connect the mushroom interaction for:", target.Name)
end

-- FARM LOOP
local function farmLoop(generation)
    while autoFarming and generation == farmGeneration and gui.Parent do
        if mushroomsCollected >= MUSHROOMS_PER_TRIP then
            statusLabel.Text = "Going to Trader..."
            if teleportToTrader() then
                mushroomsCollected = 0
                table.clear(processedModels)
                task.wait(2)
            else
                task.wait(2)
            end
            continue
        end

        local target = findClosestSelected()

        if not target then
            table.clear(processedModels)
            target = findClosestSelected()
        end

        if not target then
            statusLabel.Text = "Waiting for selected mushrooms..."
            task.wait(1)
            continue
        end

        local position = getPosition(target)
        local root = getRoot()

        if not position or not root then
            task.wait(1)
            continue
        end

        statusLabel.Text = "Target: " .. target.Name
            .. " | " .. mushroomsCollected .. "/" .. MUSHROOMS_PER_TRIP

        root.CFrame = CFrame.new(position + Vector3.new(0, 4, 0))
        task.wait(0.25)

        if not autoFarming or generation ~= farmGeneration then
            break
        end

        interactWithMushroom(target)

        task.wait(3)
        if not autoFarming or generation ~= farmGeneration then
            break
        end

        task.wait(4)

        mushroomsCollected += 1
        processedModels[target] = true

        if not target.Parent then
            processedModels[target] = nil
        end
    end
end

-- START / STOP
farmButton.MouseButton1Click:Connect(function()
    autoFarming = not autoFarming
    farmGeneration += 1

    if autoFarming then
        table.clear(processedModels)
        farmButton.Text = "Stop"
        farmButton.BackgroundColor3 = Color3.fromRGB(140, 55, 55)
        statusLabel.Text = "Auto farm running..."
        task.spawn(farmLoop, farmGeneration)
    else
        farmButton.Text = "Start"
        farmButton.BackgroundColor3 = Color3.fromRGB(55, 110, 65)
        statusLabel.Text = "Auto farm stopped"
    end
end)

-- MINIMIZE
local minimized = false

minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    main.Size = minimized
        and UDim2.new(0, 400, 0, 30)
        or UDim2.new(0, 400, 0, 430)
    minimizeButton.Text = minimized and "+" or "-"
end)

-- CLOSE
closeButton.MouseButton1Click:Connect(function()
    autoFarming = false
    farmGeneration += 1
    gui:Destroy()
end)

-- DRAGGING
local dragging = false
local dragStart
local startPosition

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - dragStart
    main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)

-- REFRESH COUNTDOWN
task.spawn(function()
    local countdown = REFRESH_TIME

    while gui.Parent do
        refreshLabel.Text = "Refresh: " .. countdown .. "s"
        task.wait(1)
        countdown -= 1

        if countdown <= 0 then
            refresh()
            countdown = REFRESH_TIME
        end
    end
end)