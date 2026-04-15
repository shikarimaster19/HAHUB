local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- 1. Khởi tạo UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HA_Hub_Anti773"
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end

-- 2. Nút Thu Gọn
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Position = UDim2.new(0, 15, 0.5, -20)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "HA"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
local UICorner_T = Instance.new("UICorner")
UICorner_T.CornerRadius = UDim.new(0, 12)
UICorner_T.Parent = ToggleButton

-- 3. Khung Chính
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -100)
MainFrame.Size = UDim2.new(0, 250, 0, 230)
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
local UICorner_M = Instance.new("UICorner")
UICorner_M.CornerRadius = UDim.new(0, 15)
UICorner_M.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "HA HUB - ANTI 773"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextSize = 16

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateButton(text, color, order)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = color
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.LayoutOrder = order
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn
    return btn
end

local BoostBtn = CreateButton("🚀 Tối Ưu Cực Hạn (Low Gfx)", Color3.fromRGB(50, 50, 50), 1)
local HopBtn = CreateButton("🛡️ Săn Server 1 Người (Sạch)", Color3.fromRGB(0, 120, 255), 2)

-- 4. Animation Khởi chạy
MainFrame.Visible = true
MainFrame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = UDim2.new(0, 250, 0, 230)}):Play()

-- 5. Toggle Logic
local isOpen = true
ToggleButton.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    local targetSize = isOpen and UDim2.new(0, 250, 0, 230) or UDim2.new(0, 0, 0, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.4), {Size = targetSize}):Play()
end)

-- 6. LOGIC SĂN SERVER 1 NGƯỜI CHỐNG 773
HopBtn.MouseButton1Click:Connect(function()
    if HopBtn.Text:find("Đang") then return end
    
    task.spawn(function()
        local PlaceID = game.PlaceId
        local JobID = game.JobId
        local list = {}
        local cursor = ""
        local page = 0
        local skipCount = 0 -- Biến để bỏ qua server ma đầu danh sách
        
        while true do
            page = page + 1
            HopBtn.Text = "🔍 Quét trang " .. page .. "..."
            
            local url = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then url = url .. "&cursor=" .. cursor end
            
            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)

            if success and result and result.data then
                for _, server in pairs(result.data) do
                    if server.playing == 1 and server.id ~= JobID then
                        skipCount = skipCount + 1
                        
                        -- CHIẾN THUẬT: Bỏ qua 10 server đầu tiên tìm thấy để né server ma
                        if skipCount > 10 then
                            table.insert(list, server.id)
                        end
                    end
                    
                    -- Nếu đã gom đủ 3 server "sạch", chọn ngẫu nhiên 1 cái để vào
                    if #list >= 3 then
                        local finalId = list[math.random(1, #list)]
                        HopBtn.Text = "✅ Đã né server ma! Vào..."
                        TeleportService:TeleportToPlaceInstance(PlaceID, finalId, game.Players.LocalPlayer)
                        return
                    end
                end
                
                cursor = result.nextPageCursor
                if not cursor then 
                    -- Nếu quét hết mà vẫn chưa đủ 3 server sạch, thì lấy đại cái nào tìm được
                    if #list > 0 then
                        TeleportService:TeleportToPlaceInstance(PlaceID, list[1], game.Players.LocalPlayer)
                        return
                    end
                    cursor = "" -- Reset để quét lại từ đầu
                    page = 0
                    skipCount = 0
                    task.wait(1)
                end
            else
                HopBtn.Text = "⏳ API nghẽn, đợi tí..."
                task.wait(3)
            end
            task.wait(0.5) -- Tốc độ quét an toàn
        end
    end)
end)

-- 7. Fix Lag
BoostBtn.MouseButton1Click:Connect(function()
    BoostBtn.Text = "🚀 Đang xử lý..."
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic
        elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") then v:Destroy() end
    end
    settings().Rendering.QualityLevel = 1
    BoostBtn.Text = "✅ Mượt Như Nhung"
end)
