local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

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

-- Positions
local pos2 = stringToCFrame("452.928772, 647.707581, -88.8344269, 0.508249521, 1.60491282e-08, 0.861209869, 4.76466653e-08, 1, -4.67546002e-08, -0.861209869, 6.47967795e-08, 0.508249521")
local pos3 = stringToCFrame("-189.413116, 649.841431, 570.376709, -0.978912592, -1.51165889e-08, 0.204279631, -2.91158173e-08, 1, -6.5524155e-08, -0.204279631, -7.00901879e-08, -0.978912592")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TeleportPivotUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- MAIN FRAME
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 260, 0, 200)
main.Position = UDim2.new(0.5, -130, 0.5, -100)
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

-- TEXTBOX (egg name)
local textbox = Instance.new("TextBox", main)
textbox.Size = UDim2.new(1, -20, 0, 30)
textbox.Position = UDim2.new(0, 10, 0, 40)
textbox.PlaceholderText = "Enter Egg Name"
textbox.Text = ""
textbox.BackgroundColor3 = Color3.fromRGB(60,60,60)
textbox.TextColor3 = Color3.new(1,1,1)

-- BUTTON CREATOR
local function createButton(text, yPos)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    btn.TextColor3 = Color3.new(1,1,1)
    return btn
end

-- BUTTONS
local btn1 = createButton("Auto Hatch (1s)", 75)
local btn2 = createButton("Position 2 (1s)", 110)
local btn3 = createButton("Position 3 (1s)", 145)

-- MINI BUTTON
local mini = Instance.new("TextButton", gui)
mini.Size = UDim2.new(0,100,0,40)
mini.Position = UDim2.new(0,20,0.5,0)
mini.Text = "Open UI"
mini.Visible = false
mini.BackgroundColor3 = Color3.fromRGB(50,50,50)

local function makeDraggable(frame, handle)
    handle.Active = true

    local dragging = false
    local dragStart
    local startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
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

makeDraggable(main, topBar)
makeDraggable(mini, mini)

-- LOOP STATES
local loops = {
    pos1 = false,
    pos2 = false,
    pos3 = false
}

-- BUTTON 1: AUTO HATCH
local MAX_DISTANCE = 25

btn1.MouseButton1Click:Connect(function()
    loops.pos1 = not loops.pos1
    btn1.BackgroundColor3 = loops.pos1 and Color3.fromRGB(0,200,0) or Color3.fromRGB(70,70,70)

    if loops.pos1 then
        task.spawn(function()
            while loops.pos1 do
                task.wait(1)

                local eggFolder = workspace:FindFirstChild("__Main")
                if eggFolder then
                    eggFolder = eggFolder:FindFirstChild("__Eggs")
                end

                local egg = eggFolder and eggFolder:FindFirstChild(textbox.Text)

                if egg then
                    local char = player.Character
                    if char then
                        local charPivot = char:GetPivot()
                        local eggPivot = egg:GetPivot()

                        local distance = (charPivot.Position - eggPivot.Position).Magnitude

                        -- ✅ ONLY teleport if too far
                        if distance > MAX_DISTANCE then
                            local targetPos = eggPivot.Position + Vector3.new(0, 3, 0) -- just above egg
                            
                            local _, y, _ = char:GetPivot():ToOrientation() -- keep your current rotation
                            
                            local safeCF = CFrame.new(targetPos) * CFrame.Angles(0, y, 0)
                            
                            char:PivotTo(safeCF)

                            task.wait(0.05)
                            -- fire remote (always runs)
                            local args = {textbox.Text}
    
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Packages")
                                :WaitForChild("_Index")
                                :WaitForChild("sleitnick_knit@1.7.0")
                                :WaitForChild("knit")
                                :WaitForChild("Services")
                                :WaitForChild("AutoReconnectService")
                                :WaitForChild("RE")
                                :WaitForChild("SetAutoHatchEgg")
                                :FireServer(unpack(args))
                        end
                    end
                end
            end
        end)
    end
end)

-- BUTTON 2 LOOP
btn2.MouseButton1Click:Connect(function()
    loops.pos2 = not loops.pos2
    btn2.BackgroundColor3 = loops.pos2 and Color3.fromRGB(0,200,0) or Color3.fromRGB(70,70,70)

    if loops.pos2 then
        task.spawn(function()
            while loops.pos2 do
                task.wait(1)

                local char = player.Character
                if char and pos2 then
                    local distance = (char:GetPivot().Position - pos2).Magnitude

                    -- ✅ ONLY teleport if too far
                    if distance > MAX_DISTANCE then
                        char:PivotTo(pos2)
                    end
                end
            end
        end)
    end
end)

-- BUTTON 3 LOOP
btn3.MouseButton1Click:Connect(function()
    loops.pos3 = not loops.pos3
    btn3.BackgroundColor3 = loops.pos3 and Color3.fromRGB(0,200,0) or Color3.fromRGB(70,70,70)

    if loops.pos3 then
        task.spawn(function()
            while loops.pos3 do
                task.wait(1)

                local char = player.Character
                if char and pos3 then
                    local distance = (char:GetPivot().Position - pos3).Magnitude

                    -- ✅ ONLY teleport if too far
                    if distance > MAX_DISTANCE then
                        char:PivotTo(pos3)
                    end
                end
            end
        end)
    end
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
