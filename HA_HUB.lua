-- Cập nhật logic tìm Server cực ít người cho HA Hub
HopBtn.MouseButton1Click:Connect(function()
    HopBtn.Text = "🔍 Đang quét server..."
    local PlaceID = game.PlaceId
    local JobID = game.JobId
    local targetFound = false
    
    -- Hàm quét sâu để tìm server 1-2 người
    local function ScanForSmallServer()
        -- Sử dụng con trỏ (cursor) để quét qua nhiều trang danh sách server nếu cần
        local cursor = ""
        local attempts = 0
        local maxAttempts = 5 -- Số trang tối đa sẽ quét để tránh treo script

        while not targetFound and attempts < maxAttempts do
            local url = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor
            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)

            if success and result and result.data then
                -- Ưu tiên 1: Tìm server có đúng 1 người
                for _, server in pairs(result.data) do
                    if server.playing == 1 and server.id ~= JobID then
                        HopBtn.Text = "✅ Đã thấy server 1 người!"
                        targetFound = true
                        TeleportService:TeleportToPlaceInstance(PlaceID, server.id, game.Players.LocalPlayer)
                        return
                    end
                end

                -- Ưu tiên 2: Nếu không có 1 người, tìm server có 2 người
                if not targetFound then
                    for _, server in pairs(result.data) do
                        if server.playing == 2 and server.id ~= JobID then
                            HopBtn.Text = "✅ Đã thấy server 2 người!"
                            targetFound = true
                            TeleportService:TeleportToPlaceInstance(PlaceID, server.id, game.Players.LocalPlayer)
                            return
                        end
                    end
                end

                -- Chuyển sang trang tiếp theo nếu chưa tìm thấy
                if result.nextPageCursor then
                    cursor = result.nextPageCursor
                    attempts = attempts + 1
                    HopBtn.Text = "🔍 Đang quét trang " .. (attempts + 1) .. "..."
                else
                    break
                end
            else
                break
            end
            task.wait(0.1) -- Đợi một chút để tránh spam API
        end

        if not targetFound then
            HopBtn.Text = "❌ Không tìm thấy server 1-2 người"
            task.wait(2)
            HopBtn.Text = "🌐 Tìm Server Ít Người"
        end
    end

    ScanForSmallServer()
end)
