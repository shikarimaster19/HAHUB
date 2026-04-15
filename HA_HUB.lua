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
local HopBtn = CreateButton("HopBtn", "🌐 Tìm Server 1-2 Người", Color3.fromRGB(45, 45, 45), 2)

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

-- 6. Logic Tìm Server (Chiến thuật Gom & Random né 773)
HopBtn.MouseButton1Click:Connect(function()
    if HopBtn.Text:find("Đang quét") then return end 
    HopBtn.Text = "🔍 Đang thu thập server..."
    
    task.spawn(function()
        local PlaceID = game.PlaceId
        local JobID = game.JobId
        local cursor = ""
        local attempts = 0
        local maxAttempts = 15 -- Quét 15 trang để gom đủ lượng server cần thiết
        local validServers = {} -- Danh sách chứa các server 1-2 người
        
        -- Bước 1: Quét và thu thập
        while attempts < maxAttempts do
            local url = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then url = url .. "&cursor=" .. cursor end
            
            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)

            if success and result and result.data then
                for _, server in pairs(result.data) do
                    -- Chỉ lấy server 1-2 người và ping hợp lệ (loại server sập)
                    if server.playing >= 1 and server.playing <= 2 and server.id ~= JobID and server.ping ~= nil then
                        table.insert(validServers, {id = server.id, playing = server.playing})
                    end
                end

                if result.nextPageCursor then
                    cursor = result.nextPageCursor
                    attempts = attempts + 1
                    HopBtn.Text = "🔍 Đang gom... (" .. #validServers .. " server)"
                else
                    break
                end
            else
                break
            end
            task.wait(0.1)
        end

        -- Bước 2: Chọn ngẫu nhiên để né "server ma" đầu danh sách
        if #validServers > 0 then
            HopBtn.Text = "🎲 Đang lọc random..."
            task.wait(0.5)
            
            -- Ưu tiên bốc các server từ giữa hoặc cuối danh sách thu được
            local startIndex = math.max(1, math.floor(#validServers / 3)) 
            local randomIndex = math.random(startIndex, #validServers)
            local chosenServer = validServers[randomIndex]
            
            HopBtn.Text = "✅ Vào server " .. chosenServer.playing .. " người!"
            TeleportService:TeleportToPlaceInstance(PlaceID, chosenServer.id, game.Players.LocalPlayer)
        else
            HopBtn.Text = "❌ Không tìm thấy!"
            task.wait(2)
            HopBtn.Text = "🌐 Tìm Server 1-2 Người"
        end
    end)
end)

-- 7. Logic Tối Ưu Đồ Họa
BoostBtn.MouseButton1Click:Connect(function()
    BoostBtn.Text = "Đang dọn dẹp..."
    task.wait(0.1)
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
        elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v:Destroy()
        end
    end
    
    game.Lighting.GlobalShadows = false
    settings().Rendering.QualityLevel = 1
    
    BoostBtn.Text = "✅ Đã Tối Ưu"
    BoostBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
end)

task.spawn(StartupAnimation)
