-- Tạo ScreenGui cơ bản cho HA Hub
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local BoostButton = Instance.new("TextButton")

-- Bảo vệ GUI (Nếu chạy qua executor, thường dùng CoreGui để không bị game xóa)
local success, err = pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

ScreenGui.Name = "HA_Hub"

-- Tùy chỉnh Khung chính (Frame)
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Position = UDim2.new(0.5, -100, 0.2, 0)
Frame.Size = UDim2.new(0, 200, 0, 120)
Frame.Active = true
Frame.Draggable = true -- Cho phép bạn kéo thả menu trên màn hình

-- Tùy chỉnh Tiêu đề
Title.Parent = Frame
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Size = UDim2.new(1, 0, 0.3, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "HA Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

-- Tùy chỉnh Nút bấm Boost FPS
BoostButton.Parent = Frame
BoostButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
BoostButton.Position = UDim2.new(0.1, 0, 0.5, 0)
BoostButton.Size = UDim2.new(0.8, 0, 0.35, 0)
BoostButton.Font = Enum.Font.GothamSemibold
BoostButton.Text = "Tối Ưu Hóa (Boost FPS)"
BoostButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BoostButton.TextSize = 14

-- Hàm xử lý Fix Lag & Boost FPS
local function OptimizeGraphics()
    BoostButton.Text = "Đang xử lý..."
    task.wait(0.1)

    -- 1. Tắt bóng đổ toàn cầu và sương mù
    game.Lighting.GlobalShadows = false
    game.Lighting.FogEnd = 9e9
    game.Lighting.ShadowSoftness = 0

    -- 2. Duyệt qua tất cả các vật thể trong Workspace để xóa texture và giảm chất lượng bề mặt
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsA("MeshPart") then
            -- Chuyển chất liệu thành SmoothPlastic để GPU đỡ phải render chi tiết
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            -- Ẩn các hình dán và texture
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            -- Tắt các hiệu ứng hạt và vệt sáng gây lag
            v.Enabled = false
        end
    end

    -- Đổi màu nút để thông báo hoàn tất
    BoostButton.Text = "Đã Tối Ưu!"
    BoostButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
end

-- Gắn sự kiện click cho nút bấm
BoostButton.MouseButton1Click:Connect(OptimizeGraphics)

