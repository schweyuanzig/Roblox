-- LAMBDA NOTIFICATION MODULE

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CONFIG = {
	Size = UDim2.new(0, 480, 0, 90),

	PositionMiddle = UDim2.new(0.5, 0, 0.08, 0),
	PositionLeft = UDim2.new(0.02, 0, 0.08, 0),
	PositionRight = UDim2.new(0.98, 0, 0.08, 0),

	BgColor = Color3.fromRGB(140, 140, 140),
	IconBgColor = Color3.fromRGB(160, 160, 160),
	TextColor = Color3.fromRGB(255, 255, 255),

	TweenTime = 0.35,
	DisplayTime = 4,
	CornerRadius = UDim.new(0, 6),

	DefaultSoundId = "rbxassetid://4590657391",
	SoundVolume = 3.5,

	OffscreenPadding = 30,
}

local soundCache = {}

local function clamp(value, minValue, maxValue)
	return math.max(minValue, math.min(maxValue, value))
end

local function shiftColor(color, amount)
	local r = clamp(math.floor(color.R * 255 + amount), 0, 255)
	local g = clamp(math.floor(color.G * 255 + amount), 0, 255)
	local b = clamp(math.floor(color.B * 255 + amount), 0, 255)

	return Color3.fromRGB(r, g, b)
end

local function resolveTheme(themeColor)
	if typeof(themeColor) == "Color3" then
		return {
			BgColor = shiftColor(themeColor, -15),
			IconBgColor = shiftColor(themeColor, 15),
			TextColor = Color3.fromRGB(255, 255, 255),
		}
	end

	return {
		BgColor = CONFIG.BgColor,
		IconBgColor = CONFIG.IconBgColor,
		TextColor = CONFIG.TextColor,
	}
end

local function isMode(value)
	if value == nil then
		return false
	end

	value = tostring(value):lower()
	return value == "left" or value == "right" or value == "middle"
end

local function normalizeMode(mode)
	mode = tostring(mode or "Middle"):lower()

	if mode == "left" then
		return "Left"
	elseif mode == "right" then
		return "Right"
	else
		return "Middle"
	end
end

local function normalizeSoundId(soundId)
	if soundId == nil or soundId == "" then
		return CONFIG.DefaultSoundId
	end

	soundId = tostring(soundId)

	if string.match(soundId, "^rbxassetid://") then
		return soundId
	end

	if string.match(soundId, "^%d+$") then
		return "rbxassetid://" .. soundId
	end

	return soundId
end

local function applyExtraArg(value, state)
    if typeof(value) == "Color3" then
        state.color = value
    elseif isMode(value) then
        state.mode = normalizeMode(value)
    elseif value ~= nil then
        state.soundId = value
    end
end

local function resolveExtraArgs(arg4, arg5, arg6)
    local state = {
        mode = "Middle",
        soundId = nil,
        color = nil,
    }

    applyExtraArg(arg4, state)
    applyExtraArg(arg5, state)
    applyExtraArg(arg6, state)

    return state.mode, state.soundId, state.color
end

local function getModeData(mode)
	mode = normalizeMode(mode)

	if mode == "Left" then
		return {
			Mode = "Left",
			AnchorPoint = Vector2.new(0, 0),
			ShowPosition = CONFIG.PositionLeft,
			HidePosition = UDim2.new(
				0,
				-(CONFIG.Size.X.Offset + CONFIG.OffscreenPadding),
				CONFIG.PositionLeft.Y.Scale,
				CONFIG.PositionLeft.Y.Offset
			),
		}
	elseif mode == "Right" then
		return {
			Mode = "Right",
			AnchorPoint = Vector2.new(1, 0),
			ShowPosition = CONFIG.PositionRight,
			HidePosition = UDim2.new(
				1,
				CONFIG.Size.X.Offset + CONFIG.OffscreenPadding,
				CONFIG.PositionRight.Y.Scale,
				CONFIG.PositionRight.Y.Offset
			),
		}
	else
		return {
			Mode = "Middle",
			AnchorPoint = Vector2.new(0.5, 0),
			ShowPosition = CONFIG.PositionMiddle,
			HidePosition = UDim2.new(
				CONFIG.PositionMiddle.X.Scale,
				CONFIG.PositionMiddle.X.Offset,
				-0.15,
				0
			),
		}
	end
end

local function getSoundTemplate(soundId)
	local finalId = normalizeSoundId(soundId)

	if soundCache[finalId] and soundCache[finalId].Parent then
		return soundCache[finalId]
	end

	local template = Instance.new("Sound")
	template.Name = "LambdaNotificationSoundTemplate"
	template.SoundId = finalId
	template.Volume = CONFIG.SoundVolume
	template.Parent = SoundService

	pcall(function()
		ContentProvider:PreloadAsync({template})
	end)

	soundCache[finalId] = template
	return template
end

local function preloadSound(soundId)
	getSoundTemplate(soundId)
end

local function playDing(soundId)
	local template = getSoundTemplate(soundId)

	local sound = template:Clone()
	sound.TimePosition = 0
	sound.Volume = CONFIG.SoundVolume
	sound.Parent = SoundService
	sound:Play()

	local lifeTime = 5
	if template.TimeLength and template.TimeLength > 0 then
		lifeTime = math.max(template.TimeLength + 0.5, 3)
	end

	Debris:AddItem(sound, lifeTime)
end

local function createNotificationGui(mode, themeColor)
	if playerGui:FindFirstChild("NotificationGui") then
		playerGui.NotificationGui:Destroy()
	end

	local modeData = getModeData(mode)
	local theme = resolveTheme(themeColor)

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NotificationGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  screenGui.DisplayOrder = 999999
	screenGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Name = "NotifFrame"
	frame.Size = CONFIG.Size
	frame.AnchorPoint = modeData.AnchorPoint
	frame.Position = modeData.HidePosition
	frame.BackgroundColor3 = theme.BgColor
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = CONFIG.CornerRadius
	frameCorner.Parent = frame

	local iconFrame = Instance.new("Frame")
	iconFrame.Name = "IconFrame"
	iconFrame.Size = UDim2.new(0, 90, 1, 0)
	iconFrame.BackgroundColor3 = theme.IconBgColor
	iconFrame.BorderSizePixel = 0
	iconFrame.BackgroundTransparency = 1
	iconFrame.Parent = frame

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = CONFIG.CornerRadius
	iconCorner.Parent = iconFrame

	local innerFill = Instance.new("Frame")
	innerFill.Name = "InnerFill"
	innerFill.Size = UDim2.new(0, 10, 1, 0)
	innerFill.BackgroundColor3 = theme.IconBgColor
	innerFill.BorderSizePixel = 0
	innerFill.BackgroundTransparency = 1
	innerFill.Parent = iconFrame

	local circle = Instance.new("Frame")
	circle.Name = "Circle"
	circle.Size = UDim2.new(0, 62, 0, 62)
	circle.Position = UDim2.new(0.5, 0, 0.5, 0)
	circle.AnchorPoint = Vector2.new(0.5, 0.5)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	circle.BorderSizePixel = 0
	circle.BackgroundTransparency = 1
	circle.Parent = iconFrame

	local circleCorner = Instance.new("UICorner")
	circleCorner.CornerRadius = UDim.new(1, 0)
	circleCorner.Parent = circle

	local lambdaLabel = Instance.new("TextLabel")
	lambdaLabel.Size = UDim2.new(1, 0, 1, 0)
	lambdaLabel.BackgroundTransparency = 1
	lambdaLabel.Text = "λ"
	lambdaLabel.TextColor3 = theme.IconBgColor
	lambdaLabel.TextScaled = true
	lambdaLabel.Font = Enum.Font.GothamBold
	lambdaLabel.TextTransparency = 1
	lambdaLabel.Parent = circle

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "TITLE"
	titleLabel.TextColor3 = theme.TextColor
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 28
	titleLabel.TextTransparency = 1
	titleLabel.Parent = frame

	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "DescLabel"
	descLabel.BackgroundTransparency = 1
	descLabel.Text = "DESCRIPTION"
	descLabel.TextColor3 = theme.TextColor
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextYAlignment = Enum.TextYAlignment.Center
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 16
	descLabel.TextTransparency = 1
	descLabel.Parent = frame

	if modeData.Mode == "Left" then
		iconFrame.Position = UDim2.new(1, -90, 0, 0)
		innerFill.Position = UDim2.new(0, 0, 0, 0)

		titleLabel.Size = UDim2.new(1, -120, 0, 50)
		titleLabel.Position = UDim2.new(0, 15, 0, 10)

		descLabel.Size = UDim2.new(1, -120, 0, 30)
		descLabel.Position = UDim2.new(0, 15, 0, 52)
	else
		iconFrame.Position = UDim2.new(0, 0, 0, 0)
		innerFill.Position = UDim2.new(1, -10, 0, 0)

		titleLabel.Size = UDim2.new(1, -110, 0, 50)
		titleLabel.Position = UDim2.new(0, 100, 0, 10)

		descLabel.Size = UDim2.new(1, -110, 0, 30)
		descLabel.Position = UDim2.new(0, 100, 0, 52)
	end

	return screenGui, frame, iconFrame, innerFill, circle, lambdaLabel, titleLabel, descLabel, modeData
end

local function showNotification(title, description, iconText, arg4, arg5, arg6)
	local mode, soundId, color = resolveExtraArgs(arg4, arg5, arg6)

	local screenGui, frame, iconFrame, innerFill, circle, lambdaLabel, titleLabel, descLabel, modeData =
		createNotificationGui(mode, color)

	lambdaLabel.Text = iconText or "λ"
	titleLabel.Text = title or "Lambda Title"
	descLabel.Text = description or "Hello!"

	playDing(soundId)

	local tweenIn = TweenService:Create(
		frame,
		TweenInfo.new(CONFIG.TweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Position = modeData.ShowPosition,
			BackgroundTransparency = 0.3,
		}
	)

	local iconTweenIn = TweenService:Create(
		iconFrame,
		TweenInfo.new(CONFIG.TweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{BackgroundTransparency = 0}
	)

	local fillTweenIn = TweenService:Create(
		innerFill,
		TweenInfo.new(CONFIG.TweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{BackgroundTransparency = 0}
	)

	local circleTweenIn = TweenService:Create(
		circle,
		TweenInfo.new(CONFIG.TweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{BackgroundTransparency = 0}
	)

	local lambdaTweenIn = TweenService:Create(
		lambdaLabel,
		TweenInfo.new(CONFIG.TweenTime),
		{TextTransparency = 0}
	)

	local titleTweenIn = TweenService:Create(
		titleLabel,
		TweenInfo.new(CONFIG.TweenTime),
		{TextTransparency = 0}
	)

	local descTweenIn = TweenService:Create(
		descLabel,
		TweenInfo.new(CONFIG.TweenTime),
		{TextTransparency = 0}
	)

	tweenIn:Play()
	iconTweenIn:Play()
	fillTweenIn:Play()
	circleTweenIn:Play()
	lambdaTweenIn:Play()
	titleTweenIn:Play()
	descTweenIn:Play()

	task.delay(CONFIG.DisplayTime, function()
		local tweenOut = TweenService:Create(
			frame,
			TweenInfo.new(CONFIG.TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				Position = modeData.HidePosition,
				BackgroundTransparency = 1,
			}
		)

		local iconTweenOut = TweenService:Create(iconFrame, TweenInfo.new(CONFIG.TweenTime), {
			BackgroundTransparency = 1
		})

		local fillTweenOut = TweenService:Create(innerFill, TweenInfo.new(CONFIG.TweenTime), {
			BackgroundTransparency = 1
		})

		local circleTweenOut = TweenService:Create(circle, TweenInfo.new(CONFIG.TweenTime), {
			BackgroundTransparency = 1
		})

		local lambdaTweenOut = TweenService:Create(lambdaLabel, TweenInfo.new(CONFIG.TweenTime), {
			TextTransparency = 1
		})

		local titleTweenOut = TweenService:Create(titleLabel, TweenInfo.new(CONFIG.TweenTime), {
			TextTransparency = 1
		})

		local descTweenOut = TweenService:Create(descLabel, TweenInfo.new(CONFIG.TweenTime), {
			TextTransparency = 1
		})

		tweenOut:Play()
		iconTweenOut:Play()
		fillTweenOut:Play()
		circleTweenOut:Play()
		lambdaTweenOut:Play()
		titleTweenOut:Play()
		descTweenOut:Play()

		tweenOut.Completed:Connect(function()
			if screenGui then
				screenGui:Destroy()
			end
		end)
	end)
end

task.spawn(function()
	preloadSound(CONFIG.DefaultSoundId)
	
	-- preloadSound("3023237993")
	-- preloadSound("9119802009")
end)

return showNotification
