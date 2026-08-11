
local TweenService   = game:GetService("TweenService")
local Players        = game:GetService("Players")
local localplayer    = Players.LocalPlayer

-- ─── PALETTE ────────────────────────────────────────────────────────────────
local COLORS = {
    bg          = Color3.fromRGB(15, 15, 20),
    bgCard      = Color3.fromRGB(22, 22, 30),
    border      = Color3.fromRGB(45, 45, 60),
    text        = Color3.fromRGB(235, 235, 240),
    subtext     = Color3.fromRGB(155, 155, 170),
    progressBg  = Color3.fromRGB(35, 35, 48),
    success     = Color3.fromRGB(52, 199, 120),
    error       = Color3.fromRGB(235, 75, 75),
    warning     = Color3.fromRGB(245, 170, 50),
    info        = Color3.fromRGB(80, 160, 245),
}

local ICONS = {
    success = "✓",
    error   = "✕",
    warning = "⚠",
    info    = "ℹ",
}

-- ─── TWEEN CONFIGS ──────────────────────────────────────────────────────────
local TW_IN  = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TW_OUT = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
local TW_PRG = TweenInfo.new(0.12, Enum.EasingStyle.Linear)

-- ─── CONTAINER ──────────────────────────────────────────────────────────────
local PlayerGui = localplayer:WaitForChild("PlayerGui")

local ScreenGui = PlayerGui:FindFirstChild("_NotifSystem")
if ScreenGui then ScreenGui:Destroy() end

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "_NotifSystem"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder    = 999
ScreenGui.Parent          = PlayerGui

local Container = Instance.new("Frame")
Container.Name             = "Container"
Container.BackgroundTransparency = 1
Container.Position         = UDim2.new(1, -20, 1, -20)
Container.AnchorPoint      = Vector2.new(1, 1)
Container.Size             = UDim2.new(0, 320, 1, -40)
Container.Parent           = ScreenGui

local Layout = Instance.new("UIListLayout")
Layout.FillDirection        = Enum.FillDirection.Vertical
Layout.VerticalAlignment    = Enum.VerticalAlignment.Bottom
Layout.HorizontalAlignment  = Enum.HorizontalAlignment.Right
Layout.SortOrder            = Enum.SortOrder.LayoutOrder
Layout.Padding              = UDim.new(0, 10)
Layout.Parent               = Container

-- ─── BUILD CARD ─────────────────────────────────────────────────────────────
local notifCount = 0

local function buildCard(opts)
    notifCount += 1

    local accentColor = COLORS[opts.Type] or COLORS.info
    local icon        = ICONS[opts.Type]  or ICONS.info
    local duration    = opts.Duration     or 4

    -- ── Outer card ──────────────────────────────────────────────────────────
    local Card = Instance.new("Frame")
    Card.Name                   = "Notif_" .. notifCount
    Card.BackgroundColor3       = COLORS.bgCard
    Card.BorderSizePixel        = 0
    Card.Size                   = UDim2.new(1, 0, 0, 80)
    Card.ClipsDescendants       = true
    Card.LayoutOrder             = notifCount
    Card.Position               = UDim2.new(1, 340, 0, 0) -- start off-screen
    Card.Parent                 = Container

    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = Card

    -- Outer border stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color        = COLORS.border
    stroke.Thickness    = 1
    stroke.Transparency = 0
    stroke.Parent       = Card

    -- ── Left accent bar ─────────────────────────────────────────────────────
    local AccentBar = Instance.new("Frame")
    AccentBar.Name              = "AccentBar"
    AccentBar.BackgroundColor3  = accentColor
    AccentBar.BorderSizePixel   = 0
    AccentBar.Size              = UDim2.new(0, 4, 1, 0)
    AccentBar.Position          = UDim2.new(0, 0, 0, 0)
    AccentBar.Parent            = Card

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 4)
    accentCorner.Parent = AccentBar

    -- ── Icon circle ─────────────────────────────────────────────────────────
    local IconCircle = Instance.new("Frame")
    IconCircle.Name             = "IconCircle"
    IconCircle.BackgroundColor3 = accentColor
    IconCircle.BackgroundTransparency = 0.75
    IconCircle.BorderSizePixel  = 0
    IconCircle.Size             = UDim2.new(0, 28, 0, 28)
    IconCircle.Position         = UDim2.new(0, 18, 0.5, -14)
    IconCircle.Parent           = Card

    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = IconCircle

    local IconLabel = Instance.new("TextLabel")
    IconLabel.BackgroundTransparency = 1
    IconLabel.Size                   = UDim2.new(1, 0, 1, 0)
    IconLabel.Text                   = icon
    IconLabel.TextColor3             = accentColor
    IconLabel.TextScaled             = true
    IconLabel.Font                   = Enum.Font.GothamBold
    IconLabel.Parent                 = IconCircle

    -- ── Text block ──────────────────────────────────────────────────────────
    local TextBlock = Instance.new("Frame")
    TextBlock.BackgroundTransparency = 1
    TextBlock.Size                   = UDim2.new(1, -68, 1, -8)
    TextBlock.Position               = UDim2.new(0, 56, 0, 4)
    TextBlock.Parent                 = Card

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name              = "Title"
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size              = UDim2.new(1, 0, 0, 22)
    TitleLabel.Position          = UDim2.new(0, 0, 0, 8)
    TitleLabel.Text              = opts.Title or "Notification"
    TitleLabel.TextColor3        = COLORS.text
    TitleLabel.TextSize          = 14
    TitleLabel.Font              = Enum.Font.GothamBold
    TitleLabel.TextXAlignment    = Enum.TextXAlignment.Left
    TitleLabel.TextTruncate      = Enum.TextTruncate.AtEnd
    TitleLabel.Parent            = TextBlock

    local DescLabel = Instance.new("TextLabel")
    DescLabel.Name               = "Description"
    DescLabel.BackgroundTransparency = 1
    DescLabel.Size               = UDim2.new(1, -4, 0, 32)
    DescLabel.Position           = UDim2.new(0, 0, 0, 32)
    DescLabel.Text               = opts.Description or ""
    DescLabel.TextColor3         = COLORS.subtext
    DescLabel.TextSize           = 12
    DescLabel.Font               = Enum.Font.Gotham
    DescLabel.TextXAlignment     = Enum.TextXAlignment.Left
    DescLabel.TextYAlignment     = Enum.TextYAlignment.Top
    DescLabel.TextWrapped        = true
    DescLabel.Parent             = TextBlock

    -- ── Progress bar ────────────────────────────────────────────────────────
    local ProgressBg = Instance.new("Frame")
    ProgressBg.Name              = "ProgressBg"
    ProgressBg.BackgroundColor3  = COLORS.progressBg
    ProgressBg.BorderSizePixel   = 0
    ProgressBg.Size              = UDim2.new(1, 0, 0, 3)
    ProgressBg.Position          = UDim2.new(0, 0, 1, -3)
    ProgressBg.Parent            = Card

    local ProgressFill = Instance.new("Frame")
    ProgressFill.Name            = "ProgressFill"
    ProgressFill.BackgroundColor3 = accentColor
    ProgressFill.BackgroundTransparency = 0.3
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Size            = UDim2.new(1, 0, 1, 0)
    ProgressFill.Parent          = ProgressBg

    -- ── Close button ────────────────────────────────────────────────────────
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name                = "Close"
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Size                = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position            = UDim2.new(1, -28, 0, 8)
    CloseBtn.Text                = "×"
    CloseBtn.TextColor3          = COLORS.subtext
    CloseBtn.TextSize            = 18
    CloseBtn.Font                = Enum.Font.GothamBold
    CloseBtn.Parent              = Card

    return Card, ProgressFill, CloseBtn
end

-- ─── ANIMATE IN / OUT ───────────────────────────────────────────────────────
local function slideIn(card)
    TweenService:Create(card, TW_IN, {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
end

local function slideOut(card, callback)
    local t = TweenService:Create(card, TW_OUT, {
        Position = UDim2.new(1, 340, 0, 0)
    })
    t:Play()
    t.Completed:Connect(function()
        card:Destroy()
        if callback then callback() end
    end)
end

-- ─── MAIN NOTIFY ─────────────────────────────────────────────────────────────
local function Notify(opts)
    opts = opts or {}

    local card, progressFill, closeBtn = buildCard(opts)
    local duration    = opts.Duration or 4
    local dismissed   = false

    -- Slide in
    task.defer(function() slideIn(card) end)

    -- Progress bar tween
    local progTween = TweenService:Create(progressFill, TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear
    ), { Size = UDim2.new(0, 0, 1, 0) })

    task.delay(0.1, function()
        progTween:Play()
    end)

    -- Auto dismiss
    local function dismiss()
        if dismissed then return end
        dismissed = true
        progTween:Cancel()
        slideOut(card)
    end

    -- Close button
    closeBtn.MouseButton1Click:Connect(dismiss)

    -- Hover pause
    card.MouseEnter:Connect(function()
        progTween:Pause()
    end)
    card.MouseLeave:Connect(function()
        if not dismissed then
            progTween:Play()
        end
    end)

    -- Auto timer
    task.delay(duration, function()
        dismiss()
    end)

    return dismiss -- retourne la fonction dismiss pour forcer la fermeture depuis l'extérieur
end

-- ─── EXPORT GLOBAL ──────────────────────────────────────────────────────────
getgenv().Notify = Notify

-- ─── USAGE ──────────────────────────────────────────────────────────────────
-- Notify({ Title = "Chest Collecté", Description = "12/20 chests récupérés ce run.", Type = "success", Duration = 5 })
-- Notify({ Title = "Server Hop", Description = "Aucun serveur Germany trouvé — retry...", Type = "warning", Duration = 4 })
-- Notify({ Title = "Connexion échouée", Description = "Network:Send a retourné nil.", Type = "error", Duration = 6 })
-- Notify({ Title = "BypassTP actif", Description = "Sea 3 — seuil 2000 studs.", Type = "info", Duration = 3 })
