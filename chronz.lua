local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local Config = _G.CONFIG
local AUTOEGG = Config.AUTOEGG

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

-- 📦 EGG LIST
local eggs = {
    ["Candy"] = stringToCFrame("0.211440101, 883.201294, 144.431717, -0.591729462, 5.28945243e-09, -0.806136608, -6.32099173e-08, 1, 5.29595354e-08, 0.806136608, 8.22935462e-08, -0.591729462"),
    ["Void"] = stringToCFrame("109.40937, 1178.62415, 218.645935, 0.835030437, -3.80566547e-08, -0.550203741, -2.871659e-08, 1, -1.1275074e-07, 0.550203741, 1.09950278e-07, 0.835030437"),
    ["Heaven"] = stringToCFrame("54.2615204, 884.353699, 328.686371, 0.667307198, 4.28766036e-08, -0.744782627, -4.62222047e-08, 1, 1.61553135e-08, 0.744782627, 2.36449367e-08, 0.667307198"),
}

-- 📍 MACHINES
local goldenMachine = stringToCFrame("452.928772, 647.707581, -88.8344269, 0.508249521, 1.60491282e-08, 0.861209869, 4.76466653e-08, 1, -4.67546002e-08, -0.861209869, 6.47967795e-08, 0.508249521")
local rainbowMachine = stringToCFrame("-189.413116, 649.841431, 570.376709, -0.978912592, -1.51165889e-08, 0.204279631, -2.91158173e-08, 1, -6.5524155e-08, -0.204279631, -7.00901879e-08, -0.978912592")

-- 🧠 Streaming
local function ensureLoaded(position)
    pcall(function()
        player:RequestStreamAroundAsync(position)
    end)
end

-- 🧠 Smart teleport
local function smartTeleport(char, targetCF)
    local currentPos = char:GetPivot().Position
    local targetPos = targetCF.Position

    local distance = (currentPos - targetPos).Magnitude

    if distance > 200 then
        local mid = currentPos:Lerp(targetPos, 0.5)
        char:PivotTo(CFrame.new(mid))
        task.wait(0.2)
    end

    char:PivotTo(targetCF + Vector3.new(0, 3, 0))
end

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TeleportPivotUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 260, 0, 200)
main.Position = UDim2.new(0.5, -130, 0.5, -100)
main.BackgroundColor3 = Color3.fromRGB(40,40,40)

local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1,0,0,30)
topBar.BackgroundColor3 = Color3.fromRGB(25,25,25)

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1,-60,1,0)
title.Text = "Teleport UI"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

local minimize = Instance.new("TextButton", topBar)
minimize.Size = UDim2.new(0,30,1,0)
minimize.Position = UDim2.new(1,-30,0,0)
minimize.Text = "-"
minimize.BackgroundColor3 = Color3.fromRGB(80,80,80)

local textbox = Instance.new("TextBox", main)
textbox.Size = UDim2.new(1, -20, 0, 30)
textbox.Position = UDim2.new(0, 10, 0, 40)
textbox.PlaceholderText = "Enter Egg Name"
textbox.BackgroundColor3 = Color3.fromRGB(60,60,60)
textbox.Text = AUTOEGG or ""
textbox.TextColor3 = Color3.new(1,1,1)

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
local btn2 = createButton("Golden Machine (1s)", 110)
local btn3 = createButton("Rainbow Machine (1s)", 145)

-- MINI BUTTON
local mini = Instance.new("TextButton", gui)
mini.Size = UDim2.new(0,100,0,40)
mini.Position = UDim2.new(0,20,0.5,0)
mini.Text = "Open UI"
mini.Visible = false
mini.BackgroundColor3 = Color3.fromRGB(50,50,50)

-- Drag
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
    pos1 = AUTOEGG ~= "" and true or false,
    pos2 = false,
    pos3 = false
}

local MAX_DISTANCE = 25

local function autoTPToEgg()
    btn1.BackgroundColor3 = loops.pos1 and Color3.fromRGB(0,200,0) or Color3.fromRGB(70,70,70)

    if loops.pos1 then
        task.spawn(function()
            while loops.pos1 do
                if not loops.pos1 then
                        break
                    end
                task.wait(1)
                if not loops.pos1 then
                        break
                    end

                local char = player.Character
                local selectedCF = eggs[textbox.Text]

                if char and selectedCF then
                    local distance = (char:GetPivot().Position - selectedCF.Position).Magnitude

                    if distance > MAX_DISTANCE then
                        ensureLoaded(selectedCF.Position)
                        task.wait(0.2)

                        smartTeleport(char, selectedCF)

                        task.wait(0.05)

                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Packages")
                            :WaitForChild("_Index")
                            :WaitForChild("sleitnick_knit@1.7.0")
                            :WaitForChild("knit")
                            :WaitForChild("Services")
                            :WaitForChild("AutoReconnectService")
                            :WaitForChild("RE")
                            :WaitForChild("SetAutoHatchEgg")
                            :FireServer(textbox.Text)
                    end
                end
            end
        end)
    end
end

-- 🔁 AUTO HATCH
btn1.MouseButton1Click:Connect(function()
    loops.pos1 = not loops.pos1
    autoTPToEgg()
end)

-- 🟡 GOLDEN MACHINE
btn2.MouseButton1Click:Connect(function()
    loops.pos2 = not loops.pos2
    btn2.BackgroundColor3 = loops.pos2 and Color3.fromRGB(0,200,0) or Color3.fromRGB(70,70,70)

    if loops.pos2 then
        task.spawn(function()
            while loops.pos2 do
                task.wait(1)

                local char = player.Character
                if char then
                    local distance = (char:GetPivot().Position - goldenMachine.Position).Magnitude

                    if distance > MAX_DISTANCE then
                        ensureLoaded(goldenMachine.Position)
                        task.wait(0.2)

                        smartTeleport(char, goldenMachine)
                    end
                end
            end
        end)
    end
end)

-- 🌈 RAINBOW MACHINE
btn3.MouseButton1Click:Connect(function()
    loops.pos3 = not loops.pos3
    btn3.BackgroundColor3 = loops.pos3 and Color3.fromRGB(0,200,0) or Color3.fromRGB(70,70,70)

    if loops.pos3 then
        task.spawn(function()
            while loops.pos3 do
                task.wait(1)

                local char = player.Character
                if char then
                    local distance = (char:GetPivot().Position - rainbowMachine.Position).Magnitude

                    if distance > MAX_DISTANCE then
                        ensureLoaded(rainbowMachine.Position)
                        task.wait(0.2)

                        smartTeleport(char, rainbowMachine)
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

task.wait(0.5)
autoTPToEgg()
