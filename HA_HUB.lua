local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local p = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Remote của game (Dựa trên code gốc của bạn)
local remotes = {
    complete = RS.Remotes.Server.CompletePlayerCodingProgram,
    store = RS.Remotes.Server.Software.Store,
    bubble = RS.Remotes.Server.PopProgrammingBubble
}

-- CẤU HÌNH (Mặc định tắt hết để không lỗi khi mới mở)
local HubConfig = {
    AutoClickCode = false,
    AutoCollectPercent = false,
    AutoUpload = false,
    AutoSell = false,
    SellTarget = 100,
}

-- ==========================================
-- 1. TẠO GIAO DIỆN (ĐÃ TỐI GIẢN ĐỂ KHÔNG LỖI)
-- ==========================================
local gui = Instance.new("ScreenGui")
gui.Name = "HA_HUB_STABLE"
gui.ResetOnSpawn = false
gui.Parent = p:WaitForChild("PlayerGui")

-- Hàm kéo thả UI
local function makeDraggable(obj)
    local dragging, input, startPos, startInput
    obj.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; startInput = i.Position; startPos = obj.Position
        end
    end)
    obj.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - startInput
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i) if i == startInput then dragging = false end end)
end

-- BONG BÓNG (Nút mở UI)
local bubble = Instance.new("ImageButton", gui)
bubble.Size = UDim2.new(0, 55, 0, 55)
bubble.Position = UDim2.new(0.1, 0, 0.5, 0)
bubble.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
bubble.Image = "rbxassetid://15555139045" -- Hãy thay ID ảnh của bạn vào đây
bubble.ClipsDescendants = true
Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", bubble)
stroke.Thickness = 2; stroke.Color = Color3.fromRGB(0, 200, 255)
makeDraggable(bubble)

-- KHUNG CHÍNH
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 280, 0, 320)
main.Position = UDim2.new(0.5, -140, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.Visible = false -- Mặc định ẩn
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
makeDraggable(main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "HA HUB - STABLE"
title.TextColor3 = Color3.new(1,1,1); title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold; title.TextSize = 18

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -20, 1, -50); scroll.Position = UDim2.new(0, 10, 0, 45)
scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0, 8)

-- Hàm tạo Toggle
local function addToggle(txt, key)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, 0, 0, 35); btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.Text = txt .. ": OFF"; btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        HubConfig[key] = not HubConfig[key]
        btn.Text = txt .. ": " .. (HubConfig[key] and "ON" or "OFF")
        btn.BackgroundColor3 = HubConfig[key] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40,40,40)
    end)
end

-- Hàm tạo Slider (Dùng cho Auto Sell)
local function addSlider(txt, min, max, key)
    local frame = Instance.new("Frame", scroll)
    frame.Size = UDim2.new(1, 0, 0, 50); frame.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, 0, 0, 20); lbl.Text = txt .. ": " .. HubConfig[key]
    lbl.TextColor3 = Color3.new(1,1,1); lbl.BackgroundTransparency = 1
    
    local bar = Instance.new("TextButton", frame)
    bar.Size = UDim2.new(1, 0, 0, 10); bar.Position = UDim2.new(0,0,0,25)
    bar.BackgroundColor3 = Color3.new(0.1,0.1,0.1); bar.Text = ""
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(0.5, 0, 1, 0); fill.BackgroundColor3 = Color3.new(0, 0.6, 1)

    bar.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local percent = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                local val = math.floor(min + (max - min) * percent)
                HubConfig[key] = val
                lbl.Text = txt .. ": " .. val
            end
        end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

-- Thêm các nút
addToggle("Auto Click Code", "AutoClickCode")
addToggle("Auto Collect %", "AutoCollectPercent")
addToggle("Auto Upload PC", "AutoUpload")
addToggle("Auto Sell", "AutoSell")
addSlider("Sell At", 10, 2000, "SellTarget")

bubble.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

-- ==========================================
-- 2. LOGIC TÁC VỤ (KHÔNG DÙNG VIM - KHÔNG LỖI)
-- ==========================================

-- Chạy intro đơn giản
task.spawn(function()
    print("HA HUB LOADING...")
    task.wait(1)
    main.Visible = true
end)

task.spawn(function()
    while task.wait(0.1) do
        -- A. AUTO CLICK (GIẢ LẬP GIỮ NÚT BẰNG CÁCH BẮN REMOTE LIÊN TỤC)
        if HubConfig.AutoClickCode then
            -- Thay vì click vào UI, mình bắn thẳng Remote hoàn thành Code
            -- Đây là cách các pro-hacker hay dùng, cực nhanh và không bao giờ trượt
            pcall(function()
                remotes.complete:InvokeServer() 
            end)
        end

        -- B. AUTO COLLECT % (QUÉT NHANH)
        if HubConfig.AutoCollectPercent then
            for _, v in pairs(p.PlayerGui:GetDescendants()) do
                if v:IsA("GuiButton") and v.Visible and (v.Name:match("%%") or (v:FindFirstChildWhichIsA("TextLabel") and v:FindFirstChildWhichIsA("TextLabel").Text:match("%%"))) then
                    pcall(function() v:Activate() end)
                end
            end
            -- Bắn kèm remote thu thập bong bóng
            for i = 1, 5 do pcall(function() remotes.bubble:FireServer(tostring(i)) end) end
        end

        -- C. AUTO UPLOAD PC
        if HubConfig.AutoUpload then
            local hardware = workspace.Interiors.Offices[tostring(p.UserId)].Items.Hardware
            for _, v in pairs(hardware:GetDescendants()) do
                if v.Name == "Pc" and v:IsA("Model") then
                    local id = v:GetAttribute("Id")
                    if id then pcall(remotes.store.InvokeServer, remotes.store, id) end
                end
            end
        end

        -- D. AUTO SELL
        if HubConfig.AutoSell then
            pcall(function()
                -- Tìm số Code trong leaderstats (Thay "Codes" bằng tên chính xác trong game của bạn)
                local codeStat = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Codes")
                if codeStat and codeStat.Value >= HubConfig.SellTarget then
                    -- Lệnh bán (Bạn cần điền đúng Remote bán của game vào đây)
                    -- Ví dụ: RS.Remotes.Server.Sell:FireServer()
                end
            end)
        end
    end
end)
