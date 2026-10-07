-- LocalScript
-- Put in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local REFRESH_TIME = 10

local FOLDERS = {
	Mushrooms = "Mushrooms",
	NPCs = "NPCs",
	Story = "Story"
}

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "ObjectFinder"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 400, 0, 430)
main.Position = UDim2.new(0, 20, 0.5, -215)
main.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
main.BorderColor3 = Color3.fromRGB(0, 0, 0)
main.BorderSizePixel = 1
main.Parent = gui

--------------------------------------------------
-- TOP BAR
--------------------------------------------------

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
topBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
topBar.BorderSizePixel = 1
topBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 170, 1, 0)
title.Position = UDim2.new(0, 7, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Object Finder"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.ArialBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local refreshLabel = Instance.new("TextLabel")
refreshLabel.Size = UDim2.new(0, 100, 1, 0)
refreshLabel.Position = UDim2.new(1, -160, 0, 0)
refreshLabel.BackgroundTransparency = 1
refreshLabel.Text = "Refresh: 10s"
refreshLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
refreshLabel.TextSize = 12
refreshLabel.Font = Enum.Font.Arial
refreshLabel.Parent = topBar

--------------------------------------------------
-- MINIMIZE BUTTON
--------------------------------------------------

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 25, 0, 22)
minimizeButton.Position = UDim2.new(1, -55, 0, 4)
minimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
minimizeButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
minimizeButton.BorderSizePixel = 1
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.TextSize = 16
minimizeButton.Font = Enum.Font.ArialBold
minimizeButton.Parent = topBar

--------------------------------------------------
-- CLOSE BUTTON
--------------------------------------------------

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 22)
closeButton.Position = UDim2.new(1, -28, 0, 4)
closeButton.BackgroundColor3 = Color3.fromRGB(130, 55, 55)
closeButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
closeButton.BorderSizePixel = 1
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 13
closeButton.Font = Enum.Font.ArialBold
closeButton.Parent = topBar

--------------------------------------------------
-- CONTENT
--------------------------------------------------

local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundTransparency = 1
content.Parent = main

--------------------------------------------------
-- TABS
--------------------------------------------------

local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(1, -12, 0, 32)
tabs.Position = UDim2.new(0, 6, 0, 6)
tabs.BackgroundTransparency = 1
tabs.Parent = content

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 3)
tabLayout.Parent = tabs

--------------------------------------------------
-- OBJECT LIST
--------------------------------------------------

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -12, 1, -48)
list.Position = UDim2.new(0, 6, 0, 42)
list.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
list.BorderColor3 = Color3.fromRGB(0, 0, 0)
list.BorderSizePixel = 1
list.ScrollBarThickness = 8
list.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 120)
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = content

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 2)
layout.Parent = list

local selectedTab = "Mushrooms"

--------------------------------------------------
-- POSITION
--------------------------------------------------

local function getPosition(object)
	if object:IsA("BasePart") then
		return object.Position

	elseif object:IsA("Model") then
		return object:GetPivot().Position

	elseif object:IsA("Attachment") then
		return object.WorldPosition
	end

	return nil
end

--------------------------------------------------
-- TELEPORT
--------------------------------------------------

local function teleportToObject(objectName)
	local folder = workspace:FindFirstChild(FOLDERS[selectedTab])

	if not folder then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	local closestObject
	local closestDistance = math.huge

	for _, object in ipairs(folder:GetChildren()) do

		if object.Name == objectName then

			local position = getPosition(object)

			if position then

				local distance =
					(root.Position - position).Magnitude

				if distance < closestDistance then
					closestDistance = distance
					closestObject = object
				end
			end
		end
	end

	if closestObject then

		local position = getPosition(closestObject)

		if position then
			root.CFrame = CFrame.new(
				position + Vector3.new(0, 4, 0)
			)
		end
	end
end

--------------------------------------------------
-- CLEAR LIST
--------------------------------------------------

local function clearList()

	for _, child in ipairs(list:GetChildren()) do

		if child:IsA("TextButton")
			or child:IsA("TextLabel") then

			child:Destroy()
		end
	end
end

--------------------------------------------------
-- REFRESH
--------------------------------------------------

local function refresh()

	clearList()

	local folder =
		workspace:FindFirstChild(FOLDERS[selectedTab])

	if not folder then

		local label = Instance.new("TextLabel")

		label.Size = UDim2.new(1, -10, 0, 30)
		label.BackgroundTransparency = 1
		label.Text =
			"Folder not found: " ..
			FOLDERS[selectedTab]

		label.TextColor3 =
			Color3.fromRGB(255, 100, 100)

		label.TextSize = 13
		label.Font = Enum.Font.Arial
		label.TextXAlignment =
			Enum.TextXAlignment.Left

		label.Parent = list

		return
	end

	local counts = {}

	for _, object in ipairs(folder:GetChildren()) do

		counts[object.Name] =
			(counts[object.Name] or 0) + 1
	end

	local names = {}

	for name in pairs(counts) do
		table.insert(names, name)
	end

	table.sort(names)

	if #names == 0 then

		local empty = Instance.new("TextLabel")

		empty.Size = UDim2.new(1, -10, 0, 30)
		empty.BackgroundTransparency = 1
		empty.Text = "No objects found."
		empty.TextColor3 =
			Color3.fromRGB(180, 180, 180)

		empty.TextSize = 13
		empty.Font = Enum.Font.Arial
		empty.TextXAlignment =
			Enum.TextXAlignment.Left

		empty.Parent = list
	end

	for _, name in ipairs(names) do

		local button = Instance.new("TextButton")

		button.Size = UDim2.new(1, -4, 0, 32)
		button.BackgroundColor3 =
			Color3.fromRGB(65, 65, 65)

		button.BorderColor3 =
			Color3.fromRGB(0, 0, 0)

		button.BorderSizePixel = 1

		button.Text =
			name .. "    [" .. counts[name] .. "]"

		button.TextColor3 =
			Color3.fromRGB(235, 235, 235)

		button.TextSize = 13
		button.Font = Enum.Font.Arial
		button.TextXAlignment =
			Enum.TextXAlignment.Left

		button.Parent = list

		button.MouseButton1Click:Connect(function()
			teleportToObject(name)
		end)

		button.MouseEnter:Connect(function()
			button.BackgroundColor3 =
				Color3.fromRGB(80, 100, 130)
		end)

		button.MouseLeave:Connect(function()
			button.BackgroundColor3 =
				Color3.fromRGB(65, 65, 65)
		end)
	end

	list.CanvasSize = UDim2.new(
		0,
		0,
		0,
		layout.AbsoluteContentSize.Y + 5
	)
end

--------------------------------------------------
-- TABS
--------------------------------------------------

local function createTab(tabName)

	local button = Instance.new("TextButton")

	button.Size = UDim2.new(0, 120, 0, 30)
	button.BackgroundColor3 =
		Color3.fromRGB(60, 60, 60)

	button.BorderColor3 =
		Color3.fromRGB(0, 0, 0)

	button.BorderSizePixel = 1

	button.Text = tabName
	button.TextColor3 =
		Color3.fromRGB(220, 220, 220)

	button.TextSize = 13
	button.Font = Enum.Font.Arial

	button.Parent = tabs

	button.MouseButton1Click:Connect(function()

		selectedTab = tabName

		for _, other in ipairs(tabs:GetChildren()) do

			if other:IsA("TextButton") then

				other.BackgroundColor3 =
					Color3.fromRGB(60, 60, 60)

				other.TextColor3 =
					Color3.fromRGB(220, 220, 220)
			end
		end

		button.BackgroundColor3 =
			Color3.fromRGB(80, 110, 150)

		button.TextColor3 =
			Color3.new(1, 1, 1)

		refresh()
	end)

	return button
end

local mushroomTab = createTab("Mushrooms")
createTab("NPCs")
createTab("Story")

mushroomTab.BackgroundColor3 =
	Color3.fromRGB(80, 110, 150)

mushroomTab.TextColor3 =
	Color3.new(1, 1, 1)

--------------------------------------------------
-- MINIMIZE
--------------------------------------------------

local minimized = false

minimizeButton.MouseButton1Click:Connect(function()

	minimized = not minimized

	if minimized then

		content.Visible = false

		main.Size = UDim2.new(
			0,
			400,
			0,
			30
		)

		minimizeButton.Text = "+"

	else

		content.Visible = true

		main.Size = UDim2.new(
			0,
			400,
			0,
			430
		)

		minimizeButton.Text = "-"
	end
end)

--------------------------------------------------
-- CLOSE
--------------------------------------------------

closeButton.MouseButton1Click:Connect(function()

	-- Stop the GUI and everything associated with it.
	gui:Destroy()

	-- Disconnect the script by yielding forever.
	while true do
		task.wait()
	end
end)

--------------------------------------------------
-- DRAGGING
--------------------------------------------------

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

--------------------------------------------------
-- REFRESH COUNTDOWN
--------------------------------------------------

local timeUntilRefresh = REFRESH_TIME

task.spawn(function()

	while gui.Parent do

		refreshLabel.Text =
			"Refresh: " ..
			tostring(timeUntilRefresh) ..
			"s"

		task.wait(1)

		timeUntilRefresh -= 1

		if timeUntilRefresh <= 0 then

			refresh()

			timeUntilRefresh = REFRESH_TIME
		end
	end
end)

--------------------------------------------------
-- INITIAL REFRESH
--------------------------------------------------

refresh()