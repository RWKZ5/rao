-- ============================================
-- [ VVOV Dynamic Camera Canvas Auto-Drawer v7.0 ]
-- [ Targeted for Delta Executor & Mobile ]
-- ============================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")

-- متغيرات الحالة
local CanvasPart = nil
local GridWidth = 32
local GridHeight = 32
local DrawSpeed = 0.015
local IsDrawing = false
local IsMinimized = false

local SortedColorsList = {}
local CurrentColorIndex = 0
local TotalPixelsInCurrentColor = 0
local ProcessedPixelsInCurrentColor = 0

-- حفظ وضع الكاميرا الأصلي
local OriginalCameraType = Camera.CameraType

-- ============================================
-- 1. بناء واجهة التحكم (GUI)
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VVOV_DynamicCanvasGUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 340, 0, 480)
MainFrame.Position = UDim2.new(0.5, -170, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- شريط العنوان
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 36)
Title.Text = "  🎨 VVOV Dynamic Camera Drawer v7.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

-- زر التصغير
local MinimizeBtn = Instance.new("TextButton", MainFrame)
MinimizeBtn.Size = UDim2.new(0, 35, 0, 36)
MinimizeBtn.Position = UDim2.new(1, -38, 0, 0)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 10)

local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -20, 1, -46)
Container.Position = UDim2.new(0, 10, 0, 42)
Container.BackgroundTransparency = 1

-- الشاشة الحوارية
local StatusLabel = Instance.new("TextLabel", Container)
StatusLabel.Size = UDim2.new(1, 0, 0, 45)
StatusLabel.Position = UDim2.new(0, 0, 0, 0)
StatusLabel.Text = "1. اضغط 'حدد سطح اللوحة'\n2. ادخل رابط الصورة ودقة شبكة اللعبة"
StatusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 10
StatusLabel.TextWrapped = true
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 6)

-- زر تحديد السطح
local SelectCanvasBtn = Instance.new("TextButton", Container)
SelectCanvasBtn.Size = UDim2.new(1, 0, 0, 30)
SelectCanvasBtn.Position = UDim2.new(0, 0, 0, 52)
SelectCanvasBtn.Text = "🎯 حدد سطح اللوحة (Canvas Part)"
SelectCanvasBtn.BackgroundColor3 = Color3.fromRGB(100, 45, 190)
SelectCanvasBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectCanvasBtn.Font = Enum.Font.GothamBold
SelectCanvasBtn.TextSize = 10
Instance.new("UICorner", SelectCanvasBtn).CornerRadius = UDim.new(0, 6)

-- حقل رابط الصورة
local UrlInput = Instance.new("TextBox", Container)
UrlInput.Size = UDim2.new(1, 0, 0, 32)
UrlInput.Position = UDim2.new(0, 0, 0, 88)
UrlInput.PlaceholderText = "رابط الصورة المباشر (https://.../image.png)"
UrlInput.Text = ""
UrlInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
UrlInput.TextColor3 = Color3.fromRGB(255, 255, 255)
UrlInput.Font = Enum.Font.Gotham
UrlInput.TextSize = 10
Instance.new("UICorner", UrlInput).CornerRadius = UDim.new(0, 6)

-- أبعاد شبكة اللوحة
local GridXInput = Instance.new("TextBox", Container)
GridXInput.Size = UDim2.new(0.48, 0, 0, 28)
GridXInput.Position = UDim2.new(0, 0, 0, 126)
GridXInput.Text = "32"
GridXInput.PlaceholderText = "العرض (Width)"
GridXInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
GridXInput.TextColor3 = Color3.fromRGB(255, 255, 255)
GridXInput.Font = Enum.Font.Gotham
GridXInput.TextSize = 10
Instance.new("UICorner", GridXInput).CornerRadius = UDim.new(0, 6)

local GridYInput = Instance.new("TextBox", Container)
GridYInput.Size = UDim2.new(0.48, 0, 0, 126)
GridYInput.Position = UDim2.new(0.52, 0, 0, 126)
GridYInput.Text = "32"
GridYInput.PlaceholderText = "الارتفاع (Height)"
GridYInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
GridYInput.TextColor3 = Color3.fromRGB(255, 255, 255)
GridYInput.Font = Enum.Font.Gotham
GridYInput.TextSize = 10
Instance.new("UICorner", GridYInput).CornerRadius = UDim.new(0, 6)

-- زر التحليل
local AnalyzeBtn = Instance.new("TextButton", Container)
AnalyzeBtn.Size = UDim2.new(1, 0, 0, 32)
AnalyzeBtn.Position = UDim2.new(0, 0, 0, 160)
AnalyzeBtn.Text = "🔍 تحليل الصورة وترتيب الألوان"
AnalyzeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 245)
AnalyzeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AnalyzeBtn.Font = Enum.Font.GothamBold
AnalyzeBtn.TextSize = 11
Instance.new("UICorner", AnalyzeBtn).CornerRadius = UDim.new(0, 6)

-- مربع اللون الحالي
local ColorDisplayBox = Instance.new("Frame", Container)
ColorDisplayBox.Size = UDim2.new(1, 0, 0, 36)
ColorDisplayBox.Position = UDim2.new(0, 0, 0, 198)
ColorDisplayBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
Instance.new("UICorner", ColorDisplayBox).CornerRadius = UDim.new(0, 6)

local ColorPreview = Instance.new("Frame", ColorDisplayBox)
ColorPreview.Size = UDim2.new(0, 26, 0, 26)
ColorPreview.Position = UDim2.new(0, 6, 0.5, -13)
ColorPreview.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
Instance.new("UICorner", ColorPreview).CornerRadius = UDim.new(0, 4)

local ColorTextLabel = Instance.new("TextLabel", ColorDisplayBox)
ColorTextLabel.Size = UDim2.new(1, -40, 1, 0)
ColorTextLabel.Position = UDim2.new(0, 38, 0, 0)
ColorTextLabel.Text = "اللون الحالي: غير محدد"
ColorTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorTextLabel.Font = Enum.Font.GothamBold
ColorTextLabel.TextSize = 10
ColorTextLabel.TextXAlignment = Enum.TextXAlignment.Left

-- شريط التقدم والعداد
local ProgressText = Instance.new("TextLabel", Container)
ProgressText.Size = UDim2.new(1, 0, 0, 18)
ProgressText.Position = UDim2.new(0, 0, 0, 240)
ProgressText.Text = "المتبقي للون الحالي: 0 / 0"
ProgressText.TextColor3 = Color3.fromRGB(200, 200, 200)
ProgressText.Font = Enum.Font.Gotham
ProgressText.TextSize = 10

local ProgressBarBG = Instance.new("Frame", Container)
ProgressBarBG.Size = UDim2.new(1, 0, 0, 12)
ProgressBarBG.Position = UDim2.new(0, 0, 0, 262)
ProgressBarBG.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Instance.new("UICorner", ProgressBarBG).CornerRadius = UDim.new(0, 6)

local ProgressBarFill = Instance.new("Frame", ProgressBarBG)
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
Instance.new("UICorner", ProgressBarFill).CornerRadius = UDim.new(0, 6)

-- أزرار السرعة
local SpeedFrame = Instance.new("Frame", Container)
SpeedFrame.Size = UDim2.new(1, 0, 0, 26)
SpeedFrame.Position = UDim2.new(0, 0, 0, 280)
SpeedFrame.BackgroundTransparency = 1

local FastBtn = Instance.new("TextButton", SpeedFrame)
FastBtn.Size = UDim2.new(0.31, 0, 1, 0)
FastBtn.Position = UDim2.new(0, 0, 0, 0)
FastBtn.Text = "سريع (0.005s)"
FastBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
FastBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FastBtn.Font = Enum.Font.GothamBold
FastBtn.TextSize = 8
Instance.new("UICorner", FastBtn).CornerRadius = UDim.new(0, 4)

local MedBtn = Instance.new("TextButton", SpeedFrame)
MedBtn.Size = UDim2.new(0.31, 0, 1, 0)
MedBtn.Position = UDim2.new(0.34, 0, 0, 0)
MedBtn.Text = "متوسط (0.015s)"
MedBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
MedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MedBtn.Font = Enum.Font.GothamBold
MedBtn.TextSize = 8
Instance.new("UICorner", MedBtn).CornerRadius = UDim.new(0, 4)

local SlowBtn = Instance.new("TextButton", SpeedFrame)
SlowBtn.Size = UDim2.new(0.31, 0, 1, 0)
SlowBtn.Position = UDim2.new(0.68, 0, 0, 0)
SlowBtn.Text = "بطيء (0.04s)"
SlowBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
SlowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SlowBtn.Font = Enum.Font.GothamBold
SlowBtn.TextSize = 8
Instance.new("UICorner", SlowBtn).CornerRadius = UDim.new(0, 4)

-- زر المتابعة
local ContinueBtn = Instance.new("TextButton", Container)
ContinueBtn.Size = UDim2.new(1, 0, 0, 36)
ContinueBtn.Position = UDim2.new(0, 0, 0, 314)
ContinueBtn.Text = "اخترت اللون باللعبة؟ ابدأ رسم هذا اللون 🚀"
ContinueBtn.BackgroundColor3 = Color3.fromRGB(35, 165, 80)
ContinueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ContinueBtn.Font = Enum.Font.GothamBold
ContinueBtn.TextSize = 10
ContinueBtn.Visible = false
Instance.new("UICorner", ContinueBtn).CornerRadius = UDim.new(0, 6)

-- زر الإيقاف
local StopBtn = Instance.new("TextButton", Container)
StopBtn.Size = UDim2.new(1, 0, 0, 28)
StopBtn.Position = UDim2.new(0, 0, 0, 356)
StopBtn.Text = "إيقاف السكربت"
StopBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 10
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 6)

-- الأحداث
MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        Container.Visible = false
        MainFrame.Size = UDim2.new(0, 220, 0, 36)
        MinimizeBtn.Text = "+"
    else
        Container.Visible = true
        MainFrame.Size = UDim2.new(0, 340, 0, 480)
        MinimizeBtn.Text = "-"
    end
end)

FastBtn.MouseButton1Click:Connect(function() DrawSpeed = 0.005; FastBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80); MedBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50); SlowBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50) end)
MedBtn.MouseButton1Click:Connect(function() DrawSpeed = 0.015; FastBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50); MedBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200); SlowBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50) end)
SlowBtn.MouseButton1Click:Connect(function() DrawSpeed = 0.04; FastBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50); MedBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50); SlowBtn.BackgroundColor3 = Color3.fromRGB(180, 100, 0) end)

-- ============================================
-- 2. إدارة الكاميرا الديناميكية وحساب الإحداثيات
-- ============================================

-- تثبيت الكاميرا بمسافة معتدلة تضمن رؤية اللوحة كاملة
local function LockCameraForDrawing()
    if not CanvasPart then return end
    OriginalCameraType = Camera.CameraType

    local canvasCF = CanvasPart.CFrame
    local canvasSize = CanvasPart.Size

    -- حساب مسافة تضمن إظهار اللوحة كاملة مع هامش مريح لرؤية ألوان اللعبة
    local maxDimension = math.max(canvasSize.X, canvasSize.Y)
    local optimalDistance = maxDimension * 1.85 

    local targetPosition = canvasCF.Position + (canvasCF.LookVector * optimalDistance)

    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = CFrame.lookAt(targetPosition, canvasCF.Position)
end

-- إرجاع الكاميرا لحريتها الكاملة لاختيار اللون باليد
local function UnlockCamera()
    Camera.CameraType = Enum.CameraType.Custom
end

-- حساب الخلية والنقر
local function ClickGridCellRaycast(gridX, gridY)
    if not CanvasPart then return end

    local size = CanvasPart.Size
    local cf = CanvasPart.CFrame

    local stepX = size.X / GridWidth
    local stepY = size.Y / GridHeight

    local topLeft = cf.Position - (cf.RightVector * (size.X / 2)) + (cf.UpVector * (size.Y / 2))

    local pixelPos3D = topLeft 
        + (cf.RightVector * (stepX * (gridX - 0.5))) 
        - (cf.UpVector * (stepY * (gridY - 0.5)))
        + (cf.LookVector * 0.05)

    local screenPos, onScreen = Camera:WorldToScreenPoint(pixelPos3D)

    if onScreen then
        VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
        task.wait(0.001)
        VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
    end
end

local function HexToColor3(hex)
    hex = hex:gsub("#","")
    local r = tonumber(hex:sub(1,2), 16) or 255
    local g = tonumber(hex:sub(3,4), 16) or 255
    local b = tonumber(hex:sub(5,6), 16) or 255
    return Color3.fromRGB(r, g, b)
end

-- ============================================
-- 3. معالجة الصور واللوحة
-- ============================================
local Mouse = LocalPlayer:GetMouse()
SelectCanvasBtn.MouseButton1Click:Connect(function()
    StatusLabel.Text = "🎯 اضغط الآن على سطح اللوحة في اللعبة..."
    local conn
    conn = Mouse.Button1Down:Connect(function()
        if Mouse.Target then
            CanvasPart = Mouse.Target
            StatusLabel.Text = "✅ تم تحديد اللوحة: " .. CanvasPart.Name .. "\nالأبعاد: " .. tostring(math.floor(CanvasPart.Size.X)) .. "x" .. tostring(math.floor(CanvasPart.Size.Y))
            conn:Disconnect()
        end
    end)
end)

AnalyzeBtn.MouseButton1Click:Connect(function()
    local url = UrlInput.Text
    if url == "" then
        StatusLabel.Text = "⚠️ يرجى وضع رابط الصورة أولاً!"
        return
    end

    if not CanvasPart then
        StatusLabel.Text = "⚠️ يرجى تحديد سطح اللوحة أولاً!"
        return
    end

    GridWidth = tonumber(GridXInput.Text) or 32
    GridHeight = tonumber(GridYInput.Text) or 32

    StatusLabel.Text = "⚡ جاري تحميل ومعالجة ألوان الصورة..."

    task.spawn(function()
        local parseApi = "https://images.rbx-tools.workers.dev/parse?url=" .. HttpService:UrlEncode(url) .. "&w=" .. GridWidth .. "&h=" .. GridHeight
        local success, response = pcall(function()
            return game:HttpGet(parseApi)
        end)

        local pixelMatrix = nil
        if success and response then
            pcall(function() pixelMatrix = HttpService:JSONDecode(response) end)
        end

        if not pixelMatrix or type(pixelMatrix) ~= "table" then
            StatusLabel.Text = "❌ فشل تحليل الصورة! تأكد من الرابط."
            return
        end

        local colorGroups = {}
        for y, row in ipairs(pixelMatrix) do
            for x, hexColor in ipairs(row) do
                if not colorGroups[hexColor] then colorGroups[hexColor] = {} end
                table.insert(colorGroups[hexColor], {x = x, y = y})
            end
        end

        SortedColorsList = {}
        for hex, pixels in pairs(colorGroups) do
            table.insert(SortedColorsList, {hex = hex, pixels = pixels, count = #pixels})
        end
        table.sort(SortedColorsList, function(a, b) return a.count > b.count end)

        if #SortedColorsList == 0 then
            StatusLabel.Text = "⚠️ لم يتم العثور على ألوان!"
            return
        end

        StatusLabel.Text = "✅ اكتمل التحليل!\nاختر اللون المطلوب باللعبة ثم اضغط زر المتابعة."
        AnalyzeBtn.Visible = false
        ContinueBtn.Visible = true
        CurrentColorIndex = 1

        local firstColorData = SortedColorsList[1]
        ColorPreview.BackgroundColor3 = HexToColor3(firstColorData.hex)
        ColorTextLabel.Text = "اللون الحالي: " .. firstColorData.hex
        ProgressText.Text = "المتبقي للون الحالي: " .. firstColorData.count .. " / " .. firstColorData.count
        ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
    end)
end)

-- ============================================
-- 4. حلقة الرسم الموجهة
-- ============================================
ContinueBtn.MouseButton1Click:Connect(function()
    if IsDrawing then return end
    if CurrentColorIndex > #SortedColorsList then
        StatusLabel.Text = "🎉 اكتمل رسم اللوحة بالكامل!"
        return
    end

    IsDrawing = true
    ContinueBtn.Visible = false

    -- 1. تثبيت الكاميرا في الموقع المثالي تلقائياً قبل البدء بالرسم
    LockCameraForDrawing()
    task.wait(0.1)

    local colorData = SortedColorsList[CurrentColorIndex]
    TotalPixelsInCurrentColor = colorData.count
    ProcessedPixelsInCurrentColor = 0

    StatusLabel.Text = "⚡ جاري رسم اللون " .. colorData.hex .. "..."

    task.spawn(function()
        for _, pixelPos in ipairs(colorData.pixels) do
            if not IsDrawing then break end

            ClickGridCellRaycast(pixelPos.x, pixelPos.y)

            ProcessedPixelsInCurrentColor = ProcessedPixelsInCurrentColor + 1
            local remaining = TotalPixelsInCurrentColor - ProcessedPixelsInCurrentColor
            
            ProgressText.Text = "المتبقي للون الحالي: " .. remaining .. " / " .. TotalPixelsInCurrentColor
            ProgressBarFill.Size = UDim2.new(ProcessedPixelsInCurrentColor / TotalPixelsInCurrentColor, 0, 1, 0)

            task.wait(DrawSpeed)
        end

        -- 2. إرجاع حرية الكاميرا فور انتهاء رسم اللون الحالي لاختيار اللون التالي باليد
        UnlockCamera()

        IsDrawing = false
        CurrentColorIndex = CurrentColorIndex + 1

        if CurrentColorIndex <= #SortedColorsList then
            local nextColor = SortedColorsList[CurrentColorIndex]
            ColorPreview.BackgroundColor3 = HexToColor3(nextColor.hex)
            ColorTextLabel.Text = "اللون التالي: " .. nextColor.hex
            ProgressText.Text = "المتبقي للون التالي: " .. nextColor.count .. " / " .. nextColor.count
            ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)

            StatusLabel.Text = "🎨 اختر اللون الجديد (" .. nextColor.hex .. ") باللعبة ثم اضغط الزر الأخضر!"
            ContinueBtn.Visible = true
        else
            StatusLabel.Text = "🎉 انتهى رسم الصورة بالكامل بنجاح!"
            AnalyzeBtn.Visible = true
        end
    end)
end)

StopBtn.MouseButton1Click:Connect(function()
    IsDrawing = false
    UnlockCamera()
    ContinueBtn.Visible = false
    AnalyzeBtn.Visible = true
    StatusLabel.Text = "تم إيقاف الرسم."
end)
