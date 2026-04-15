local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- 1. Khởi tạo ScreenGui an toàn
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HA_Hub_Pro"
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then 
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") 
end

-- 2. Nút Thu Gọn
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -20)
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "HA"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14

local UICorner_Toggle = Instance.new("UICorner")
UICorner_Toggle.CornerRadius = UDim.new(0, 10)
UICorner_Toggle.Parent = ToggleButton

-- 3. Khung Chính
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -100)
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.ClipsDescendants = true
MainFrame.Visible = false

local UICorner_Main = Instance.new("UICorner")
UICorner_Main.CornerRadius = UDim.new(0, 12)
UICorner_Main.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Font = Enum.Font.GothamBold
Title.Text = "HA HUB - PREMIUM"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextSize = 16

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function CreateButton(name, text, color, order)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = MainFrame
    btn.BackgroundColor3 = color
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.LayoutOrder = order
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    return btn
end

local BoostBtn = CreateButton("BoostBtn", "🚀 Tối Ưu FPS & Fix Lag", Color3.fromRGB(45, 45, 45), 1)
local HopBtn = CreateButton("HopBtn", "🌐 Tìm Server 3-5 Người", Color3.fromRGB(45, 45, 45), 2)

-- 4. Hiệu ứng Khởi chạy
local function StartupAnimation()
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(MainFrame, tweenInfo, {
        Size = UDim2.new(0, 250, 0, 220),
        Position = UDim2.new(0.5, -125, 0.4, -100),
        BackgroundTransparency = 0
    }):Play()
end

-- 5. Logic Thu gọn / Mở lại
local isOpen = true
ToggleButton.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    local targetSize = isOpen and UDim2.new(0, 250, 0, 220) or UDim2.new(0, 0, 0, 0)
    local targetPos = isOpen and UDim2.new(0.5, -125, 0.4, -100) or UDim2.new(0, 40, 0.5, 0)
    
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = targetSize,
        Position = targetPos
    }):Play()
    
    ToggleButton.Text = isOpen and "HA" or "Open"
end)

-- 6. Logic Tìm Server (Bản nâng cấp chống chặn API, quét sâu 50 trang)
HopBtn.MouseButton1Click:Connect(function()
    if HopBtn.Text:find("Đang") or HopBtn.Text:find("Quét") then return end 
    HopBtn.Text = "🔍 Khởi động máy quét..."
    
    task.spawn(function()
        local PlaceID = game.PlaceId
        local JobID = game.JobId
        local cursor = ""
        local attempts = 0
        local maxAttempts = 50 -- Quét siêu sâu tối đa 50 trang
        local validServers = {} 
        
        while attempts < maxAttempts do
            local url = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then url = url .. "&cursor=" .. cursor end
            
            -- Gọi API an toàn
            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)

            if success and result and result.data then
                for _, server in pairs(result.data) do
                    -- Mở rộng mốc 3 đến 10 người, loại bỏ server lỗi
                    if server.playing >= 3 and server.playing <= 10 and server.id ~= JobID then
                        table.insert(validServers, {id = server.id, playing = server.playing})
                    end
                end

                -- Nếu gom được 5 server vắng thì chốt luôn, khỏi quét thêm cho mệt máy
                if #validServers >= 5 then
                    break
                end

                if result.nextPageCursor then
                    cursor = result.nextPageCursor
                    attempts = attempts + 1
                    HopBtn.Text = "🔍 Đang đào trang " .. attempts .. "..."
                else
                    break -- Hết danh sách
                end
            else
                HopBtn.Text = "⚠️ Lỗi API/Mạng lag"
                task.wait(2)
                break
            end
            
            task.wait(0.5) -- THỜI GIAN NGHỈ CỰC KỲ QUAN TRỌNG ĐỂ KHÔNG BỊ ROBLOX CHẶN
        end

        if #validServers > 0 then
            HopBtn.Text = "🎲 Đang kết nối..."
            task.wait(0.5)
            
            local randomIndex = math.random(1, #validServers)
            local chosenServer = validServers[randomIndex]
            
            HopBtn.Text = "✅ Đang vào server " .. chosenServer.playing .. " người!"
            TeleportService:TeleportToPlaceInstance(PlaceID, chosenServer.id, game.Players.LocalPlayer)
        else
            if not HopBtn.Text:find("⚠️") then
                HopBtn.Text = "❌ Vẫn không tìm thấy!"
                task.wait(2)
            end
            HopBtn.Text = "🌐 Tìm Server 3-10 Người"
        end
    end)
end)
task.spawn(StartupAnimation)
