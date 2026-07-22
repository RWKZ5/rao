-- ============================================
-- [ VVOV Canvas Drawer v7.0 - Mobile Edition ]
-- ============================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

-- تحديد المجلد الآمن للواجهة على الجوال
local TargetParent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- حذف الواجهة القديمة إن وجدت
if TargetParent:FindFirstChild("VVOV_DynamicCanvasGUI") then
    TargetParent.VVOV_DynamicCanvasGUI:Destroy()
end

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

-- 1. بناء واجهة الجوال
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VVOV_DynamicCanvasGUI"
ScreenGui.Parent = TargetParent
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 460)
MainFrame.Position = UDim2.new(0.5, -160, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- شريط العنوان
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 36)
Title.Text = "  🎨 VVOV Mobile Drawer v7.0"
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

local StatusLabel = Instance.new("TextLabel", Container)
StatusLabel.Size = UDim2.new(1, 0, 0, 45)
StatusLabel.Position = UDim2.new(0, 0, 0, 0)
StatusLabel.Text = "1. حدد اللوحة بالماوس\n2. ادخل رابط الصورة المباشر"
StatusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 10
StatusLabel.TextWrapped = true
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 6)

local SelectCanvasBtn = Instance.new("TextButton", Container)
SelectCanvasBtn.Size = UDim2.new(1, 0, 0, 30)
SelectCanvasBtn.Position = UDim2.new(0, 0, 0, 52)
SelectCanvasBtn.Text = "🎯 حدد سطح اللوحة (Canvas Part)"
SelectCanvasBtn.BackgroundColor3 = Color3.fromRGB(100, 45, 190)
SelectCanvasBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectCanvasBtn.Font = Enum.Font.GothamBold
SelectCanvasBtn.TextSize = 10
Instance.new("UICorner", SelectCanvasBtn).CornerRadius = UDim.new(0, 6)

local UrlInput = Instance.new("TextBox", Container)
UrlInput.Size = UDim2.new(1, 0, 0, 32)
UrlInput.Position = UDim2.new(0, 0, 0, 88)
UrlInput.PlaceholderText = "رابط الصورة (https://.../image.png)"
UrlInput.Text = ""
UrlInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
UrlInput.TextColor3 = Color3.fromRGB(255, 255, 255)
UrlInput.Font = Enum.Font.Gotham
UrlInput.TextSize = 10
Instance.new("UICorner", UrlInput).CornerRadius = UDim.new(0, 6)

local GridXInput = Instance.new("TextBox", Container)
GridXInput.Size = UDim2.new(0.48, 0, 0, 28)
GridXInput.Position = UDim2.new(0, 0, 0, 126)
GridXInput.Text = "32"
GridXInput.PlaceholderText = "العرض (X)"
GridXInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
GridXInput.TextColor3 = Color3.fromRGB(255, 255, 255)
GridXInput.Font = Enum.Font.Gotham
GridXInput.TextSize = 10
Instance.new("UICorner", GridXInput).CornerRadius = UDim.new(0, 6)

local GridYInput = Instance.new("TextBox", Container)
GridYInput.Size = UDim2.new(0.48, 0, 0, 28)
GridYInput.Position = UDim2.new(0.52, 0, 0, 126)
GridYInput.Text = "32"
GridYInput.PlaceholderText = "الارتفاع (Y)"
GridYInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
GridYInput.TextColor3 = Color3.fromRGB(255, 255, 255)
GridYInput.Font = Enum.Font.Gotham
GridYInput.TextSize = 10
Instance.new("UICorner", GridYInput).CornerRadius = UDim.new(0, 6)

local AnalyzeBtn = Instance.new("TextButton", Container)
AnalyzeBtn.Size = UDim2.new(1, 0, 0, 32)
AnalyzeBtn.Position = UDim2.new(0, 0, 0, 160)
AnalyzeBtn.Text = "🔍 تحليل الصورة وترتيب الألوان"
AnalyzeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 245)
AnalyzeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AnalyzeBtn.Font = Enum.Font.GothamBold
AnalyzeBtn.TextSize = 11
Instance.new("UICorner", AnalyzeBtn).CornerRadius = UDim.new(0, 6)

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

local ProgressText = Instance.new("TextLabel", Container)
ProgressText.Size = UDim2.new(1, 0, 0, 18)
ProgressText.Position = UDim2.new(0, 0, 0, 240)
ProgressText.Text = "المتبقي: 0 / 0"
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

local ContinueBtn = Instance.new("TextButton", Container)
ContinueBtn.Size = UDim2.new(1, 0, 0, 36)
ContinueBtn.Position = UDim2.new(0, 0, 0, 285)
ContinueBtn.Text = "اخترت اللون؟ ابدأ الرسم 🚀"
ContinueBtn.BackgroundColor3 = Color3.fromRGB(35, 165, 80)
ContinueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ContinueBtn.Font = Enum.Font.GothamBold
ContinueBtn.TextSize = 10
ContinueBtn.Visible = false
Instance.new("UICorner", ContinueBtn).CornerRadius = UDim.new(0, 6)

local StopBtn = Instance.new("TextButton", Container)
StopBtn.Size = UDim2.new(1, 0, 0, 28)
StopBtn.Position = UDim2.new(0, 0, 0, 330)
StopBtn.Text = "إيقاف السكربت"
StopBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 10
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 6)

MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        Container.Visible = false
        MainFrame.Size = UDim2.new(0, 200, 0, 36)
        MinimizeBtn.Text = "+"
    else
        Container.Visible = true
        MainFrame.Size = UDim2.new(0, 320, 0, 460)
        MinimizeBtn.Text = "-"
    end
end)

local function LockCameraForDrawing()
    if not CanvasPart then return end
    local canvasCF = CanvasPart.CFrame
    local canvasSize = CanvasPart.Size
    local maxDimension = math.max(canvasSize.X, canvasSize.Y)
    local targetPosition = canvasCF.Position + (canvasCF.LookVector * (maxDimension * 1.85))
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = CFrame.lookAt(targetPosition, canvasCF.Position)
end

local function UnlockCamera()
    Camera.CameraType = Enum.CameraType.Custom
end

local function ClickGridCellRaycast(gridX, gridY)
    if not CanvasPart then return end
    local size = CanvasPart.Size
    local cf = CanvasPart.CFrame
    local stepX = size.X / GridWidth
    local stepY = size.Y / GridHeight
    local topLeft = cf.Position - (cf.RightVector * (size.X / 2)) + (cf.UpVector * (size.Y / 2))
    local pixelPos3D = topLeft + (cf.RightVector * (stepX * (gridX - 0.5))) - (cf.UpVector * (stepY * (gridY - 0.5))) + (cf.LookVector * 0.05)

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

local Mouse = LocalPlayer:GetMouse()
SelectCanvasBtn.MouseButton1Click:Connect(function()
    StatusLabel.Text = "🎯 اضغط الآن على اللوحة..."
    local conn
    conn = Mouse.Button1Down:Connect(function()
        if Mouse.Target then
            CanvasPart = Mouse.Target
            StatusLabel.Text = "✅ تم تحديد اللوحة: " .. CanvasPart.Name
            conn:Disconnect()
        end
    end)
end)

AnalyzeBtn.MouseButton1Click:Connect(function()
    local url = UrlInput.Text
    if url == "" or not CanvasPart then
        StatusLabel.Text = "⚠️ ادخل الرابط وحدد اللوحة أولاً!"
        return
    end

    GridWidth = tonumber(GridXInput.Text) or 32
    GridHeight = tonumber(GridYInput.Text) or 32
    StatusLabel.Text = "⚡ جاري تحميل ألوان الصورة..."

    task.spawn(function()
        local parseApi = "https://images.rbx-tools.workers.dev/parse?url=" .. HttpService:UrlEncode(url) .. "&w=" .. GridWidth .. "&h=" .. GridHeight
        local success, response = pcall(function() return game:HttpGet(parseApi) end)

        local pixelMatrix = nil
        if success and response then
            pcall(function() pixelMatrix = HttpService:JSONDecode(response) end)
        end

        if not pixelMatrix or type(pixelMatrix) ~= "table" then
            StatusLabel.Text = "❌ فشل تحليل الصورة!"
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

ContinueBtn.MouseButton1Click:Connect(function()
    if IsDrawing or CurrentColorIndex > #SortedColorsList then return end
    IsDrawing = true
    ContinueBtn.Visible = false

    LockCameraForDrawing()
    task.wait(0.1)

    local colorData = SortedColorsList[CurrentColorIndex]
    TotalPixelsInCurrentColor = colorData.count
    ProcessedPixelsInCurrentColor = 0

    StatusLabel.Text = "⚡ جاري رسم " .. colorData.hex .. "..."

    task.spawn(function()
        for _, pixelPos in ipairs(colorData.pixels) do
            if not IsDrawing then break end
            ClickGridCellRaycast(pixelPos.x, pixelPos.y)
            ProcessedPixelsInCurrentColor = ProcessedPixelsInCurrentColor + 1
            ProgressText.Text = "المتبقي: " .. (TotalPixelsInCurrentColor - ProcessedPixelsInCurrentColor) .. " / " .. TotalPixelsInCurrentColor
            ProgressBarFill.Size = UDim2.new(ProcessedPixelsInCurrentColor / TotalPixelsInCurrentColor, 0, 1, 0)
            task.wait(DrawSpeed)
        end

        UnlockCamera()
        IsDrawing = false
        CurrentColorIndex = CurrentColorIndex + 1

        if CurrentColorIndex <= #SortedColorsList then
            local nextColor = SortedColorsList[CurrentColorIndex]
            ColorPreview.BackgroundColor3 = HexToColor3(nextColor.hex)
            ColorTextLabel.Text = "اللون: " .. nextColor.hex
            ProgressText.Text = "المتبقي: " .. nextColor.count .. " / " .. nextColor.count
            ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
            StatusLabel.Text = "🎨 اختر اللون (" .. nextColor.hex .. ") ثم اضغط متابعة!"
            ContinueBtn.Visible = true
        else
            StatusLabel.Text = "🎉 اكتمل رسم اللوحة!"
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
