local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- 1. Khởi tạo ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HA_Hub_Pro"
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then 
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") 
end

-- 2. Nút Thu Gọn (Toggle)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -20)
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "HA"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
local UICorner_T = Instance.new("UICorner")
UICorner_T.CornerRadius = UDim.new(0, 10)
UICorner_T.Parent = ToggleButton

-- 3. Khung Chính
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -100)
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
local UICorner_M = Instance.new("UICorner")
UICorner_M.CornerRadius = UDim.new(0, 12)
UICorner_M.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Font = Enum.Font.GothamBold
Title.Text = "HA HUB - HUNTER"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextSize = 16

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateButton(text, color, order)
    local btn = Instance.new("TextButton")
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

local BoostBtn = CreateButton("🚀 Tối Ưu FPS & Fix Lag", Color3.fromRGB(45, 45, 45), 1)
local HopBtn = CreateButton("🌐 Săn Server 1 Người", Color3.fromRGB(45, 45, 45), 2)

-- 4. Animation
local function StartupAnimation()
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 250, 0, 220),
        Position = UDim2.new(0.5, -125, 0.4, -100)
    }):Play()
end

-- 5. Toggle Logic
local isOpen = true
ToggleButton.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    local targetSize = isOpen and UDim2.new(0, 250, 0, 220) or UDim2.new(0, 0, 0, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    ToggleButton.Text = isOpen and "HA" or "Open"
end)

-- 6. Logic SĂN SERVER 1 NGƯỜI (Vòng lặp vô tận)
HopBtn.MouseButton1Click:Connect(function()
    if HopBtn.Text:find("Đang tìm") then return end
    
    task.spawn(function()
        local PlaceID = game.PlaceId
        local JobID = game.JobId
        local found = false
        local pageCount = 0
        
        while not found do
            local cursor = ""
            pageCount = 0
            
            -- Bắt đầu một lượt quét toàn bộ danh sách
            repeat
                local url = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"
                if cursor ~= "" then url = url .. "&cursor=" .. cursor end
                
                local success, result = pcall(function()
                    return HttpService:JSONDecode(game:HttpGet(url))
                end)

                if success and result and result.data then
                    pageCount = pageCount + 1
                    HopBtn.Text = "🔍 Đang tìm... Trang " .. pageCount
                    
                    for _, server in pairs(result.data) do
                        -- Kiểm tra ĐÚNG 1 người
                        if server.playing == 1 and server.id ~= JobID then
                            found = true
                            HopBtn.Text = "✅ ĐÃ THẤY! Đang vào..."
                            TeleportService:TeleportToPlaceInstance(PlaceID, server.id, game.Players.LocalPlayer)
                            return
                        end
                    end
                    
                    cursor = result.nextPageCursor
                else
                    HopBtn.Text = "⚠️ Đợi API hồi chiêu..."
                    task.wait(2)
                end
                task.wait(0.6) -- Nghỉ 0.6s mỗi trang để tránh bị Roblox khóa
            until not cursor or found
            
            if not found then
                HopBtn.Text = "🔄 Hết list, quét lại từ đầu..."
                task.wait(1)
            end
        end
    end)
end)

-- 7. Fix Lag
BoostBtn.MouseButton1Click:Connect(function()
    BoostBtn.Text = "Đang dọn dẹp..."
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic
        elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") then v:Destroy() end
    end
    settings().Rendering.QualityLevel = 1
    BoostBtn.Text = "✅ Đã Tối Ưu"
end)

task.spawn(StartupAnimation)
