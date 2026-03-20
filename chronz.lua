local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

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

-- Your raw pivot
local pos1 = stringToCFrame("250.79, 651.50, 244.67, 1,0,0, 0,1,0, 0,0,1")
local pos2 = stringToCFrame("260.00, 651.50, 250.00, 1,0,0, 0,1,0, 0,0,1")
local pos3 = stringToCFrame("270.00, 651.50, 260.00, 1,0,0, 0,1,0, 0,0,1")

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

local function createButton(text, yPos)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    btn.TextColor3 = Color3.new(1,1,1)
    return btn
end

local btn1 = createButton("Position 1 (1s)", 40)
local btn2 = createButton("Position 2 (2s)", 75)
local btn3 = createButton("Position 3 (3s)", 110)

-- MINI BUTTON (when minimized)
local mini = Instance.new("TextButton", gui)
mini.Size = UDim2.new(0,100,0,40)
mini.Position = UDim2.new(0,20,0.5,0)
mini.Text = "Open UI"
mini.Visible = false
mini.BackgroundColor3 = Color3.fromRGB(50,50,50)

local function makeDraggable(frame, handle)
    handle.Active = true -- important for mobile

    local dragging = false
    local dragInput
    local dragStart
    local startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input == dragInput then
            dragging = false
            dragInput = nil
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
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

local loops = {
    pos1 = false,
    pos2 = false,
    pos3 = false
}

local function startLoop(name, cf, delay, button)
    loops[name] = not loops[name]

    -- update button color
    button.BackgroundColor3 = loops[name] and Color3.fromRGB(0,200,0) or Color3.fromRGB(70,70,70)

    if loops[name] then
        task.spawn(function()
            while loops[name] do
                task.wait(delay)

                local char = player.Character
                if char and cf then
                    char:PivotTo(cf)
                end
            end
        end)
    end
end

btn1.MouseButton1Click:Connect(function()
    startLoop("pos1", pos1, 1, btn1)
end)

btn2.MouseButton1Click:Connect(function()
    startLoop("pos2", pos2, 2, btn2)
end)

btn3.MouseButton1Click:Connect(function()
    startLoop("pos3", pos3, 3, btn3)
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


