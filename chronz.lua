local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Your raw pivot
local savedPosition = "250.791458, 651.509949, 244.670395, 0.999072254, -4.3885704e-09, -0.0430654027, 4.17922585e-09, 1, -4.95111951e-09, 0.0430654027, 4.76654627e-09, 0.999072254"

-- SETTINGS
local CHECK_DELAY = 1
local MAX_DISTANCE = 25

-- Convert string → CFrame
local function stringToCFrame(str)
    local numbers = {}
    for num in string.gmatch(str, "[^,]+") do
        table.insert(numbers, tonumber(num))
    end

    if #numbers == 12 then
        return CFrame.new(unpack(numbers))
    end
end

local targetCF = stringToCFrame(savedPosition)

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TeleportPivotUI"

-- MAIN FRAME
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 260, 0, 120)
main.Position = UDim2.new(0.5, -130, 0.5, -60)
main.BackgroundColor3 = Color3.fromRGB(40,40,40)

-- TOP BAR
local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1,0,0,30)
topBar.BackgroundColor3 = Color3.fromRGB(25,25,25)

-- TITLE
local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1,-60,1,0)
title.Text = "Teleport UI"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- MINIMIZE BUTTON
local minimize = Instance.new("TextButton", topBar)
minimize.Size = UDim2.new(0,30,1,0)
minimize.Position = UDim2.new(1,-30,0,0)
minimize.Text = "-"
minimize.BackgroundColor3 = Color3.fromRGB(80,80,80)

-- TOGGLE BUTTON
local button = Instance.new("TextButton", main)
button.Size = UDim2.new(1,-20,0,50)
button.Position = UDim2.new(0,10,0,50)
button.Text = "OFF"
button.BackgroundColor3 = Color3.fromRGB(255,0,0)

-- MINI BUTTON (when minimized)
local mini = Instance.new("TextButton", gui)
mini.Size = UDim2.new(0,100,0,40)
mini.Position = UDim2.new(0,20,0.5,0)
mini.Text = "Open UI"
mini.Visible = false
mini.BackgroundColor3 = Color3.fromRGB(50,50,50)

-- DRAG FUNCTION
local function makeDraggable(frame, handle)
    local dragging = false
    local dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Apply dragging
makeDraggable(main, topBar)
makeDraggable(mini, mini)

-- TOGGLE STATE
local enabled = false

button.MouseButton1Click:Connect(function()
    enabled = not enabled
    button.Text = enabled and "ON" or "OFF"
    button.BackgroundColor3 = enabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
end)

-- MINIMIZE
minimize.MouseButton1Click:Connect(function()
    main.Visible = false
    mini.Visible = true
end)

mini.MouseButton1Click:Connect(function()
    main.Visible = true
    mini.Visible = false
end)

-- LOOP
task.spawn(function()
    while true do
        task.wait(CHECK_DELAY)

        if enabled and targetCF then
            local char = player.Character
            if char then
                local currentPos = char:GetPivot().Position
                local targetPos = targetCF.Position

                if (currentPos - targetPos).Magnitude > MAX_DISTANCE then
                    char:PivotTo(targetCF)
                end
            end
        end
    end
end)
