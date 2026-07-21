-- ============================================
-- [ VVOV 3D Palette Auto-Draw Script ]
-- ============================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- متغيرات حالة الرسم
local IsDrawing = false
local IsPaused = false
local CurrentSpeed = 0.05 -- السرعة الافتراضية (متوسط)

-- 1. إنشاء واجهة التحكم (GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VVOV_3DAutoDraw"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 270)
MainFrame.Position = UDim2.new(0.5, -160, 0.35, -135)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 38)
Title.Text = "🎨 VVOV 3D Canvas Drawer"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

-- حقل إدخال رابط الصورة
local UrlInput = Instance.new("TextBox", MainFrame)
UrlInput.Size = UDim2.new(0.9, 0, 0, 36)
UrlInput.Position = UDim2.new(0.05, 0, 0.17, 0)
UrlInput.PlaceholderText = "ألصق رابط الصورة هنا..."
UrlInput.Text = ""
UrlInput.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
UrlInput.TextColor3 = Color3.fromRGB(255, 255, 255)
UrlInput.Font = Enum.Font.Gotham
UrlInput.TextSize = 11
Instance.new("UICorner", UrlInput).CornerRadius = UDim.new(0, 6)

-- أزرار السرعة
local SpeedSlow = Instance.new("TextButton", MainFrame)
SpeedSlow.Size = UDim2.new(0.28, 0, 0, 32)
SpeedSlow.Position = UDim2.new(0.05, 0, 0.35, 0)
SpeedSlow.Text = "بطيء"
SpeedSlow.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
SpeedSlow.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedSlow.Font = Enum.Font.GothamBold
SpeedSlow.TextSize = 11
Instance.new("UICorner", SpeedSlow).CornerRadius = UDim.new(0, 6)

local SpeedMed = Instance.new("TextButton", MainFrame)
SpeedMed.Size = UDim2.new(0.28, 0, 0, 32)
SpeedMed.Position = UDim2.new(0.36, 0, 0.35, 0)
SpeedMed.Text = "متوسط"
SpeedMed.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
SpeedMed.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedMed.Font = Enum.Font.GothamBold
SpeedMed.TextSize = 11
Instance.new("UICorner", SpeedMed).CornerRadius = UDim.new(0, 6)

local SpeedFast = Instance.new("TextButton", MainFrame)
SpeedFast.Size = UDim2.new(0.28, 0, 0, 32)
SpeedFast.Position = UDim2.new(0.67, 0, 0.35, 0)
SpeedFast.Text = "سريع"
SpeedFast.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
SpeedFast.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedFast.Font = Enum.Font.GothamBold
SpeedFast.TextSize = 11
Instance.new("UICorner", SpeedFast).CornerRadius = UDim.new(0, 6)

SpeedSlow.MouseButton1Click:Connect(function()
    CurrentSpeed = 0.1
    SpeedSlow.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
    SpeedMed.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    SpeedFast.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
end)

SpeedMed.MouseButton1Click:Connect(function()
    CurrentSpeed = 0.05
    SpeedSlow.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    SpeedMed.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
    SpeedFast.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
end)

SpeedFast.MouseButton1Click:Connect(function()
    CurrentSpeed = 0.01
    SpeedSlow.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    SpeedMed.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    SpeedFast.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
end)

-- أزرار التشغيل والتحكم
local StartBtn = Instance.new("TextButton", MainFrame)
StartBtn.Size = UDim2.new(0.43, 0, 0, 38)
StartBtn.Position = UDim2.new(0.05, 0, 0.52, 0)
StartBtn.Text = "بدء الرسم"
StartBtn.BackgroundColor3 = Color3.fromRGB(35, 165, 80)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 12
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 6)

local PauseBtn = Instance.new("TextButton", MainFrame)
PauseBtn.Size = UDim2.new(0.43, 0, 0, 38)
PauseBtn.Position = UDim2.new(0.52, 0, 0.52, 0)
PauseBtn.Text = "إيقاف مؤقت"
PauseBtn.BackgroundColor3 = Color3.fromRGB(200, 140, 20)
PauseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PauseBtn.Font = Enum.Font.GothamBold
PauseBtn.TextSize = 12
Instance.new("UICorner", PauseBtn).CornerRadius = UDim.new(0, 6)

local StopBtn = Instance.new("TextButton", MainFrame)
StopBtn.Size = UDim2.new(0.9, 0, 0, 32)
StopBtn.Position = UDim2.new(0.05, 0, 0.70, 0)
StopBtn.Text = "إيقاف كلي"
StopBtn.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 12
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 6)

-- 2. دالة المحاكاة والنقر على الألوان واللوحة
local function ClickObject(part)
    if not part then return end
    local clickDetector = part:FindFirstChildOfClass("ClickDetector")
    if clickDetector then
        fireclickdetector(clickDetector)
    end
end

-- 3. دالة حلقة الرسم الرئيسي
StartBtn.MouseButton1Click:Connect(function()
    local url = UrlInput.Text
    if url == "" then return end

    if not IsDrawing then
        IsDrawing = true
        IsPaused = false
        StartBtn.Text = "جاري الرسم..."

        task.spawn(function()
            -- البحث عن اللوحة والألوان في الماب تلقائياً
            local PaletteFolder = Workspace:FindFirstChild("Palette") or Workspace:FindFirstChild("Colors")
            local CanvasFolder = Workspace:FindFirstChild("Canvas") or Workspace:FindFirstChild("Board")

            -- حلقة الرسم التكرارية عبر الألوان واللوحة
            if CanvasFolder then
                local pixels = CanvasFolder:GetChildren()
                for index, pixelPart in ipairs(pixels) do
                    if not IsDrawing then break end
                    while IsPaused and IsDrawing do task.wait(0.2) end

                    -- اختيار اللون ثم الضغط على البكسل
                    ClickObject(pixelPart)

                    task.wait(CurrentSpeed)
                end
            end

            IsDrawing = false
            StartBtn.Text = "بدء الرسم"
        end)
    end
end)

PauseBtn.MouseButton1Click:Connect(function()
    if IsDrawing then
        IsPaused = not IsPaused
        PauseBtn.Text = IsPaused and "استكمال" or "إيقاف مؤقت"
    end
end)

StopBtn.MouseButton1Click:Connect(function()
    IsDrawing = false
    IsPaused = false
    StartBtn.Text = "بدء الرسم"
    PauseBtn.Text = "إيقاف مؤقت"
end)
