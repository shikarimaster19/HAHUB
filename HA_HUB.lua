local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local p = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local h = workspace.Interiors.Offices[tostring(p.UserId)].Items.Hardware
local complete = RS.Remotes.Server.CompletePlayerCodingProgram
local store = RS.Remotes.Server.Software.Store

-- CẤU HÌNH HUB
local HubConfig = {
    AutoClickCode = false,
    AutoCollectPercent = false,
    AutoUpload = false,
    AutoSell = false,
    SellTarget = 100,
}

-- ==========================================
-- 1. TẠO GIAO DIỆN (GUI)
-- ==========================================
local gui = Instance.new("ScreenGui")
gui.Name = "HA_HUB"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = p:WaitForChild("PlayerGui") end

local function makeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- BONG BÓNG UI (BUBBLE)
local bubble = Instance.new("ImageButton", gui)
bubble.Size = UDim2.new(0, 50, 0, 50)
bubble.Position = UDim2.new(0.5, -25, 0.1, 0)
bubble.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
bubble.Image = "rbxassetid://15555139045" 
bubble.Visible = false
bubble.ClipsDescendants = true
Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)
makeDraggable(bubble)

-- MAIN UI (BẢNG ĐIỀU KHIỂN)
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 300, 0, 350)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
makeDraggable(mainFrame)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "HA HUB"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20

local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18

local container = Instance.new("ScrollingFrame", mainFrame)
container.Size = UDim2.new(1, -20, 1, -50)
container.Position = UDim2.new(0, 10, 0, 45)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function createToggle(name, configKey)
    local frame = Instance.new("Frame", container)
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 50, 0, 25)
    btn.Position = UDim2.new(1, -60, 0.5, -12.5)
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        HubConfig[configKey] = not HubConfig[configKey]
        if HubConfig[configKey] then
            btn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            btn.Text = "ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            btn.Text = "OFF"
        end
    end)
end

local function createSlider(name, min, max, configKey)
    local frame = Instance.new("Frame", container)
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = name .. ": " .. HubConfig[configKey]
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local slideBg = Instance.new("Frame", frame)
    slideBg.Size = UDim2.new(1, -20, 0, 10)
    slideBg.Position = UDim2.new(0, 10, 0, 35)
    slideBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", slideBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", slideBg)
    fill.Size = UDim2.new((HubConfig[configKey]-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local trigger = Instance.new("TextButton", slideBg)
    trigger.Size = UDim2.new(1, 0, 1, 0)
    trigger.BackgroundTransparency = 1
    trigger.Text = ""

    local dragging = false
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - slideBg.AbsolutePosition.X) / slideBg.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (max - min) * pos)
        HubConfig[configKey] = val
        lbl.Text = name .. ": " .. val
    end

    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; updateSlider(input)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
end

createToggle("Auto Collect %", "AutoCollectPercent")
createToggle("Auto Click Code (</>)", "AutoClickCode")
createToggle("Auto Upload (PC)", "AutoUpload")
createToggle("Auto Sell Code", "AutoSell")
createSlider("Sell When Reaching", 1, 1000, "SellTarget")

closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)
bubble.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)

-- ==========================================
-- HIỆU ỨNG INTRO
-- ==========================================
local introFrame = Instance.new("Frame", gui)
introFrame.Size = UDim2.new(0, 0, 0, 0)
introFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
introFrame.AnchorPoint = Vector2.new(0.5, 0.5)
introFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
introFrame.ClipsDescendants = true
Instance.new("UICorner", introFrame).CornerRadius = UDim.new(0, 15)

local introText = Instance.new("TextLabel", introFrame)
introText.Size = UDim2.new(1, 0, 0, 60)
introText.Position = UDim2.new(0, 0, 0.2, 0)
introText.BackgroundTransparency = 1
introText.Text = ""
introText.TextColor3 = Color3.fromRGB(0, 200, 255)
introText.Font = Enum.Font.GothamBlack
introText.TextSize = 35

local loadBg = Instance.new("Frame", introFrame)
loadBg.Size = UDim2.new(0.8, 0, 0, 10)
loadBg.Position = UDim2.new(0.1, 0, 0.7, 0)
loadBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", loadBg).CornerRadius = UDim.new(1, 0)

local loadFill = Instance.new("Frame", loadBg)
loadFill.Size = UDim2.new(0, 0, 1, 0)
loadFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Instance.new("UICorner", loadFill).CornerRadius = UDim.new(1, 0)

local loadTxt = Instance.new("TextLabel", introFrame)
loadTxt.Size = UDim2.new(1, 0, 0, 20)
loadTxt.Position = UDim2.new(0, 0, 0.8, 0)
loadTxt.BackgroundTransparency = 1
loadTxt.Text = "0%"
loadTxt.TextColor3 = Color3.fromRGB(200, 200, 200)
loadTxt.Font = Enum.Font.GothamSemibold
loadTxt.TextSize = 14

task.spawn(function()
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TS:Create(introFrame, tweenInfo, {Size = UDim2.new(0, 300, 0, 150)}):Play()
    task.wait(1.2)

    local textToType = "HA HUB"
    for i = 1, #textToType do
        introText.Text = string.sub(textToType, 1, i)
        task.wait(0.15)
    end
    task.wait(0.5)

    for i = 1, 100, 2 do
        loadFill.Size = UDim2.new(i/100, 0, 1, 0)
        loadTxt.Text = "Loading... " .. i .. "%"
        task.wait(0.01)
    end
    task.wait(0.3)

    introFrame:Destroy()
    mainFrame.Visible = true
    bubble.Visible = true
end)

-- ==========================================
-- LOGIC AUTO FARM KẾT HỢP VỚI CÔNG TẮC UI
-- ==========================================

-- Hàm mô phỏng click TỐI ƯU HÓA CHO MOBILE
local function forceClick(btn)
    if not btn then return end
    pcall(function()
        -- Kích hoạt mặc định
        btn:Activate()
        
        -- Dành cho Mobile Executors (Bắn TouchTap)
        if firesignal then
            firesignal(btn.TouchTap)
            firesignal(btn.MouseButton1Down)
            firesignal(btn.MouseButton1Click)
            firesignal(btn.MouseButton1Up)
            firesignal(btn.Activated)
        end
        
        -- Nếu executor dùng getconnections (Giả lập ngón tay chạm)
        if getconnections then
            for _, conn in pairs(getconnections(btn.TouchTap)) do conn:Fire() end
            for _, conn in pairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
            for _, conn in pairs(getconnections(btn.Activated)) do conn:Fire() end
        end
    end)
end

task.spawn(function()
    while true do
        -- 1. AUTO COLLECT %
        if HubConfig.AutoCollectPercent then
            for _, v in pairs(p.PlayerGui:GetDescendants()) do
                if v.Visible then
                    local isPercent = false
                    if v:IsA("TextButton") and v.Text:find("%%") then isPercent = true end
                    if v:IsA("TextLabel") and v.Text:find("%%") then isPercent = true end
                    
                    if isPercent then
                        local targetBtn = v:IsA("GuiButton") and v or v.Parent
                        if targetBtn:IsA("GuiButton") then forceClick(targetBtn) end
                    end
                end
            end
        end

        -- 2. AUTO CLICK CODE (</>) - ĐÃ NÂNG CẤP NHẬN DIỆN
        if HubConfig.AutoClickCode then
            for _, v in pairs(p.PlayerGui:GetDescendants()) do
                if (v:IsA("ImageButton") or v:IsA("TextButton")) and v.Visible then
                    
                    -- Cách 1: Tìm theo ký hiệu </> bên trong nút
                    local hasCodeSymbol = false
                    if v:IsA("TextButton") and v.Text:find("</>") then hasCodeSymbol = true end
                    for _, child in ipairs(v:GetChildren()) do
                        if child:IsA("TextLabel") and child.Text:find("</>") then hasCodeSymbol = true end
                    end

                    -- Cách 2: Tìm theo tên của nút
                    local matchName = v.Name:lower():match("code") or v.Name:lower():match("click") or v.Name:lower():match("action")

                    -- Kích hoạt nếu thỏa mãn
                    if hasCodeSymbol or matchName or (v:IsA("ImageButton") and v.Image:match("11562916684")) then
                        forceClick(v)
                    end
                end
            end
            -- Đẩy kèm remote lên server dự phòng
            pcall(function() complete:InvokeServer(complete) end)
        end

        -- 3. AUTO UPLOAD
        if HubConfig.AutoUpload then
            for _, v in ipairs(h:GetDescendants()) do
                if v.Name == "Pc" and v:IsA("Model") then
                    local id = v:GetAttribute("Id")
                    if id then pcall(store.InvokeServer, store, id) end
                end
            end
        end

        -- 4. AUTO SELL (Cần tùy chỉnh lại Remote và Leaderstats)
        if HubConfig.AutoSell then
            pcall(function()
                -- Thay đổi đường dẫn này theo game của bạn
                local currentCodes = 0 
                if currentCodes >= HubConfig.SellTarget then
                    -- Lệnh bán
                end
            end)
        end

        task.wait(0.05)
    end
end)
