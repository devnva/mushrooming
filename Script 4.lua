local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "PlayerTeleportGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 350)
frame.Position = UDim2.new(0, 20, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Teleport to Player"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(55, 90, 160)
title.TextScaled = true
title.Parent = frame

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.new(0, 5, 0, 45)
list.Size = UDim2.new(1, -10, 1, -50)
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarThickness = 6
list.BackgroundTransparency = 1
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = list

local function refreshPlayers()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= player then
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -10, 0, 35)
            button.Text = target.DisplayName .. " (@" .. target.Name .. ")"
            button.TextScaled = true
            button.BackgroundColor3 = Color3.fromRGB(65, 65, 80)
            button.TextColor3 = Color3.new(1, 1, 1)
            button.Parent = list

            button.Activated:Connect(function()
                local character = player.Character
                local targetCharacter = target.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                local targetRoot = targetCharacter
                    and targetCharacter:FindFirstChild("HumanoidRootPart")

                if root and targetRoot then
                    root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
                end
            end)
        end
    end

    list.CanvasSize = UDim2.new(
        0, 0, 0, layout.AbsoluteContentSize.Y + 10
    )
end

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    list.CanvasSize = UDim2.new(
        0, 0, 0, layout.AbsoluteContentSize.Y + 10
    )
end)

refreshPlayers()