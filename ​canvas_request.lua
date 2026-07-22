AnalyzeBtn.MouseButton1Click:Connect(function()
    local url = UrlInput.Text
    if url == "" or not CanvasPart then
        StatusLabel.Text = "⚠️ ادخل الرابط وحدد اللوحة أولاً!"
        return
    end

    GridWidth = tonumber(GridXInput.Text) or 32
    GridHeight = tonumber(GridYInput.Text) or 32
    StatusLabel.Text = "⚡ جاري فحص الـ API..."

    task.spawn(function()
        local encodeUrl = HttpService:UrlEncode(url)
        local apis = {
            "https://api.vopic.dev/parse?url=" .. encodeUrl .. "&w=" .. GridWidth .. "&h=" .. GridHeight,
            "https://image-parser.rbx-tools.workers.dev/parse?url=" .. encodeUrl .. "&w=" .. GridWidth .. "&h=" .. GridHeight,
            "https://images.rbx-tools.workers.dev/parse?url=" .. encodeUrl .. "&w=" .. GridWidth .. "&h=" .. GridHeight
        }

        local pixelMatrix = nil

        for index, api in ipairs(apis) do
            print("----------------------------------------")
            
            local success, response = pcall(function()
                if request then
                    local r = request({
                        Url = api,
                        Method = "GET"
                    })

                    if not r then
                        error("No response")
                    end

                    if r.StatusCode ~= 200 then
                        error("HTTP "..tostring(r.StatusCode))
                    end

                    return r.Body
                else
                    return game:HttpGet(api)
                end
            end)

            warn("API:", api)
            warn("SUCCESS:", success)
            warn("RESPONSE:", response)

            if success and response then
                local decoded = nil
                local ok, err = pcall(function()
                    decoded = HttpService:JSONDecode(response)
                end)

                if not ok then
                    warn("JSON ERROR:", err)
                end

                if decoded and type(decoded) == "table" then
                    pixelMatrix = decoded
                    break
                end
            end
        end

        if not pixelMatrix or type(pixelMatrix) ~= "table" then
            StatusLabel.Text = "❌ فشل تحليل الصورة! تحقق من Console (F9)"
            return
        end

        local colorGroups = {}
        for y, row in ipairs(pixelMatrix) do
            if type(row) == "table" then
                for x, hexColor in ipairs(row) do
                    if not colorGroups[hexColor] then colorGroups[hexColor] = {} end
                    table.insert(colorGroups[hexColor], {x = x, y = y})
                end
            end
        end

        SortedColorsList = {}
        for hex, pixels in pairs(colorGroups) do
            table.insert(SortedColorsList, {hex = hex, pixels = pixels, count = #pixels})
        end
        table.sort(SortedColorsList, function(a, b) return a.count > b.count end)

        StatusLabel.Text = "✅ اكتمل التحليل! اختر اللون باللعبة ثم ابدأ."
        AnalyzeBtn.Visible = false
        ContinueBtn.Visible = true
        CurrentColorIndex = 1

        local firstColorData = SortedColorsList[1]
        ColorPreview.BackgroundColor3 = HexToColor3(firstColorData.hex)
        ColorTextLabel.Text = "اللون: " .. firstColorData.hex
        ProgressText.Text = "المتبقي: " .. firstColorData.count .. " / " .. firstColorData.count
        ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
    end)
end)
