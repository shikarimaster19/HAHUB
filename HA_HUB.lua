local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local p = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Các Remote của game (Tích hợp từ script cũ)
local h = workspace.Interiors.Offices[tostring(p.UserId)].Items.Hardware
local complete = RS.Remotes.Server.CompletePlayerCodingProgram
local store = RS.Remotes.Server.Software.Store

-- CẤU HÌNH HUB
local HubConfig = {
    AutoClickCode = false,
    AutoCollectPercent = false,
    AutoUpload = false,
    AutoSell = false,
    SellTarget = 100, -- Mặc định
}

-- ==========================================
-- 1. TẠO GIAO DIỆN (GUI)
-- ==========================================
local gui = Instance.new("ScreenGui")
gui.Name = "HA_HUB"
gui.ResetOnSpawn = false
-- Thử đưa vào CoreGui để tránh bị game xóa, nếu lỗi thì đưa vào PlayerGui
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = p:WaitForChild("PlayerGui") end

-- Hàm làm cho UI có thể kéo thả
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

-- ==========================================
-- BONG BÓNG UI (BUBBLE)
-- ==========================================
local bubble = Instance.new("ImageButton", gui)
bubble.Size = UDim2.new(0, 50, 0, 50)
bubble.Position = UDim2.new(0.5, -25, 0.1, 0)
bubble.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
bubble.Image = "rbxassetid://15555139045" -- THAY ID HÌNH ẢNH CỦA BẠN VÀO ĐÂY (Upload hình lên Roblox lấy ID)
bubble.Visible = false
bubble.ClipsDescendants = true
local bubbleCorner = Instance.new("UICorner", bubble)
bubbleCorner.CornerRadius = UDim.new(1, 0)
makeDraggable(bubble)

-- ==========================================
-- MAIN UI (BẢNG ĐIỀU KHIỂN)
-- ==========================================
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

-- Hàm tạo công tắc (Toggle)
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

-- Hàm tạo thanh kéo (Slider)
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
            dragging = true
            updateSlider(input)
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

-- Thêm các thành phần vào UI
createToggle("Auto Collect %", "AutoCollectPercent")
createToggle("Auto Click Code (</>)", "AutoClickCode")
createToggle("Auto Upload (PC)", "AutoUpload")
createToggle("Auto Sell Code", "AutoSell")
createSlider("Sell When Reaching", 1, 1000, "SellTarget")

-- Tương tác ẩn/hiện UI
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)
bubble.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- ==========================================
-- HIỆU ỨNG INTRO (KHỞI ĐỘNG)
-- ==========================================
local introFrame = Instance.new("Frame", gui)
introFrame.Size = UDim2.new(0, 0, 0, 0) -- Bắt đầu từ 0
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

-- Chạy Intro
task.spawn(function()
    -- Phóng to ra
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TS:Create(introFrame, tweenInfo, {Size = UDim2.new(0, 300, 0, 150)}):Play()
    task.wait(1.2)

    -- Chạy chữ HA HUB
    local textToType = "HA HUB"
    for i = 1, #textToType do
        introText.Text = string.sub(textToType, 1, i)
        task.wait(0.15)
    end
    task.wait(0.5)

    -- Chạy thanh %
    for i = 1, 100 do
        loadFill.Size = UDim2.new(i/100, 0, 1, 0)
        loadTxt.Text = "Loading... " .. i .. "%"
        task.wait(0.02)
    end
    task.wait(0.5)

    -- Tắt intro, bật UI chính
    introFrame:Destroy()
    mainFrame.Visible = true
    bubble.Visible = true
end)


-- ==========================================
-- LOGIC AUTO FARM KẾT HỢP VỚI CÔNG TẮC UI
-- ==========================================
local function forceClick(button)
    if not button then return end
    pcall(function()
        if firesignal then
            firesignal(button.MouseButton1Down)
            firesignal(button.MouseButton1Click)
            firesignal(button.Activated)
        else
            button:Activate() 
        end
    end)
end

task.spawn(function()
    while true do
        -- 1. AUTO COLLECT %
        if HubConfig.AutoCollectPercent then
            for _, v in pairs(p.PlayerGui:GetDescendants()) do
                if v:IsA("TextButton") and v.Visible and v.Text:match("%%") then
                    forceClick(v)
                elseif v:IsA("TextLabel") and v.Text:match("%%") and (v.Parent:IsA("ImageButton") or v.Parent:IsA("TextButton")) then
                    forceClick(v.Parent)
                end
            end
        end

        -- 2. AUTO CLICK CODE (</>)
        if HubConfig.AutoClickCode then
            for _, v in pairs(p.PlayerGui:GetDescendants()) do
                if v:IsA("ImageButton") and v.Visible and (v.Name:lower():match("code") or v.Name:lower():match("click") or v.Image:match("11562916684")) then
                    forceClick(v)
                end
            end
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
                -- [LƯU Ý]: Chỗ này bạn cần thay đổi theo đúng game của bạn!
                -- Giả sử số lượng Code lưu ở: game.Players.LocalPlayer.leaderstats.Code.Value
                -- Giả sử Remote bán là: RS.Remotes.Server.SellCode
                
                local currentCodes = 0 
                -- Ví dụ: currentCodes = p.leaderstats.Code.Value 
                
                if currentCodes >= HubConfig.SellTarget then
                    -- Thực hiện lệnh bán
                    -- Ví dụ: RS.Remotes.Server.SellCode:InvokeServer()
                    -- print("Đã bán " .. currentCodes .. " codes!")
                end
            end)
        end

        task.wait(0.05)
    end
end)
