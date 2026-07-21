-- ============================================
-- [ Auto-Draw Script Framework for Roblox ]
-- ============================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- متغيرات التحكم بالحالة والسرعة
local IsDrawing = false
local IsPaused = false
local CurrentSpeed = 0.05 -- السرعة الافتراضية (متوسط)

-- 1. إنشاء واجهة المستخدم (GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoDrawGUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.5, -150, 0.4, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Active = true
MainFrame.Draggable = true -- إمكانية سحب الواجهة

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Auto Draw Bot"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

-- حقل إدخال رابط الصورة
local UrlInput = Instance.new("TextBox", MainFrame)
UrlInput.Size = UDim2.new(0.9, 0, 0, 35)
UrlInput.Position = UDim2.new(0.05, 0, 0.18, 0)
UrlInput.PlaceholderText = "أدخل رابط الصورة هنا..."
UrlInput.Text = ""
UrlInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
UrlInput.TextColor3 = Color3.fromRGB(255, 255, 255)

-- أزرار تحديد السرعة
local SpeedSlow = Instance.new("TextButton", MainFrame)
SpeedSlow.Size = UDim2.new(0.28, 0, 0, 30)
SpeedSlow.Position = UDim2.new(0.05, 0, 0.38, 0)
SpeedSlow.Text = "بطيء"
SpeedSlow.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedSlow.TextColor3 = Color3.fromRGB(255, 255, 255)

local SpeedMed = Instance.new("TextButton", MainFrame)
SpeedMed.Size = UDim2.new(0.28, 0, 0, 30)
SpeedMed.Position = UDim2.new(0.36, 0, 0.38, 0)
SpeedMed.Text = "متوسط"
SpeedMed.BackgroundColor3 = Color3.fromRGB(0, 150, 200) -- المحدد افتراضياً
SpeedMed.TextColor3 = Color3.fromRGB(255, 255, 255)

local SpeedFast = Instance.new("TextButton", MainFrame)
SpeedFast.Size = UDim2.new(0.28, 0, 0, 30)
SpeedFast.Position = UDim2.new(0.67, 0, 0.38, 0)
SpeedFast.Text = "سريع"
SpeedFast.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedFast.TextColor3 = Color3.fromRGB(255, 255, 255)

-- أزرار التشغيل والتحكم
local StartBtn = Instance.new("TextButton", MainFrame)
StartBtn.Size = UDim2.new(0.42, 0, 0, 35)
StartBtn.Position = UDim2.new(0.05, 0, 0.58, 0)
StartBtn.Text = "بدء الرسم"
StartBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local PauseBtn = Instance.new("TextButton", MainFrame)
PauseBtn.Size = UDim2.new(0.42, 0, 0, 35)
PauseBtn.Position = UDim2.new(0.53, 0, 0.58, 0)
PauseBtn.Text = "إيقاف مؤقت"
PauseBtn.BackgroundColor3 = Color3.fromRGB(200, 140, 0)
PauseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local StopBtn = Instance.new("TextButton", MainFrame)
StopBtn.Size = UDim2.new(0.9, 0, 0, 30)
StopBtn.Position = UDim2.new(0.05, 0, 0.78, 0)
StopBtn.Text = "إيقاف كلي"
StopBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- 2. إعداد أزرار السرعة
SpeedSlow.MouseButton1Click:Connect(function()
    CurrentSpeed = 0.1 -- بطيء
    SpeedSlow.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    SpeedMed.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SpeedFast.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end)

SpeedMed.MouseButton1Click:Connect(function()
    CurrentSpeed = 0.05 -- متوسط
    SpeedSlow.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SpeedMed.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    SpeedFast.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end)

SpeedFast.MouseButton1Click:Connect(function()
    CurrentSpeed = 0.01 -- سريع
    SpeedSlow.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SpeedMed.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SpeedFast.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
end)

-- 3. دالة محاكاة إرسال البكسل إلى اللعبة
local function DrawPixelOnCanvas(x, y, color)
    -- ملاحظة: يجب تغيير هذا الجزء بالـ RemoteEvent الخاص بالماب المحدد
    -- مثال:
    -- game:GetService("ReplicatedStorage").DrawEvent:FireServer(x, y, color)
end

-- 4. حلقة الرسم الرئيسية
local function StartDrawingProcess(imageUrl)
    if IsDrawing then return end
    IsDrawing = true
    IsPaused = false
    
    -- تنبيه: يتطلب تحويل الصورة إلى مصفوفة ألوان من خلال API خارجي
    -- كمثال توضيحي لمصفوفة أبعاد 32x32:
    local canvasWidth = 32
    local canvasHeight = 32

    task.spawn(function()
        for y = 1, canvasHeight do
            for x = 1, canvasWidth do
                -- التحقق من حالة الإيقاف الكلي
                if not IsDrawing then break end
                
                -- التحقق من حالة الإيقاف المؤقت
                while IsPaused and IsDrawing do
                    task.wait(0.2)
                end

                -- لون توضيحي (يتم استبداله باللون الحقيقي القادم من الصورة)
                local pixelColor = Color3.fromRGB(255, 255, 255) 

                -- تنفيذ رسم البكسل
                DrawPixelOnCanvas(x, y, pixelColor)

                -- الانتظار بناءً على السرعة المحددة
                task.wait(CurrentSpeed)
            end
            if not IsDrawing then break end
        end

        IsDrawing = false
        StartBtn.Text = "بدء الرسم"
    end)
end

-- 5. إعداد أزرار التشغيل والتحكم
StartBtn.MouseButton1Click:Connect(function()
    local url = UrlInput.Text
    if url ~= "" and not IsDrawing then
        StartBtn.Text = "جاري الرسم..."
        StartDrawingProcess(url)
    end
end)

PauseBtn.MouseButton1Click:Connect(function()
    if IsDrawing then
        IsPaused = not IsPaused
        if IsPaused then
            PauseBtn.Text = "استكمال"
        else
            PauseBtn.Text = "إيقاف مؤقت"
        end
    end
end)

StopBtn.MouseButton1Click:Connect(function()
    IsDrawing = false
    IsPaused = false
    StartBtn.Text = "بدء الرسم"
    PauseBtn.Text = "إيقاف مؤقت"
end)
