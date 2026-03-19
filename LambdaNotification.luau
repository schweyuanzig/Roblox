-- LAMBDA NOTIFICATION SCRIPT

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CONFIG = {
	Size = UDim2.new(0, 480, 0, 90),

	PositionMiddle = UDim2.new(0.5, 0, 0.08, 0),
	PositionLeft   = UDim2.new(0.02, 0, 0.08, 0),
	PositionRight  = UDim2.new(0.98, 0, 0.08, 0),

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

local function resolveModeAndSound(arg4, arg5)
	local mode = "Middle"
	local soundId = nil

	if isMode(arg4) then
		mode = arg4
		soundId = arg5
	else
		soundId = arg4
		if isMode(arg5) then
			mode = arg5
		end
	end

	return normalizeMode(mode), soundId
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

local function playDing(soundId)
	local sound = Instance.new("Sound")
	sound.SoundId = normalizeSoundId(soundId)
	sound.Volume = CONFIG.SoundVolume
	sound.Parent = SoundService
	sound:Play()

	Debris:AddItem(sound, 3)
end

local function createNotificationGui(mode)
	if playerGui:FindFirstChild("NotificationGui") then
		playerGui.NotificationGui:Destroy()
	end

	local modeData = getModeData(mode)

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NotificationGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Name = "NotifFrame"
	frame.Size = CONFIG.Size
	frame.AnchorPoint = modeData.AnchorPoint
	frame.Position = modeData.HidePosition
	frame.BackgroundColor3 = CONFIG.BgColor
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = CONFIG.CornerRadius
	frameCorner.Parent = frame

	local iconFrame = Instance.new("Frame")
	iconFrame.Name = "IconFrame"
	iconFrame.Size = UDim2.new(0, 90, 1, 0)
	iconFrame.BackgroundColor3 = CONFIG.IconBgColor
	iconFrame.BorderSizePixel = 0
	iconFrame.BackgroundTransparency = 1
	iconFrame.Parent = frame

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = CONFIG.CornerRadius
	iconCorner.Parent = iconFrame

	local innerFill = Instance.new("Frame")
	innerFill.Name = "InnerFill"
	innerFill.Size = UDim2.new(0, 10, 1, 0)
	innerFill.BackgroundColor3 = CONFIG.IconBgColor
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
	lambdaLabel.TextColor3 = CONFIG.IconBgColor
	lambdaLabel.TextScaled = true
	lambdaLabel.Font = Enum.Font.GothamBold
	lambdaLabel.TextTransparency = 1
	lambdaLabel.Parent = circle

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "TITLE KISMI"
	titleLabel.TextColor3 = CONFIG.TextColor
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 28
	titleLabel.TextTransparency = 1
	titleLabel.Parent = frame

	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "DescLabel"
	descLabel.BackgroundTransparency = 1
	descLabel.Text = "AÇIKLAMA"
	descLabel.TextColor3 = CONFIG.TextColor
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 16
	descLabel.TextTransparency = 1
	descLabel.Parent = frame

	if modeData.Mode == "Left" then
		-- Icon sağda, yazılar solda
		iconFrame.Position = UDim2.new(1, -90, 0, 0)
		innerFill.Position = UDim2.new(0, 0, 0, 0)

		titleLabel.Size = UDim2.new(1, -120, 0, 50)
		titleLabel.Position = UDim2.new(0, 15, 0, 10)
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left

		descLabel.Size = UDim2.new(1, -120, 0, 30)
		descLabel.Position = UDim2.new(0, 15, 0, 52)
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
	else
		-- Normal görünüm
		iconFrame.Position = UDim2.new(0, 0, 0, 0)
		innerFill.Position = UDim2.new(1, -10, 0, 0)

		titleLabel.Size = UDim2.new(1, -110, 0, 50)
		titleLabel.Position = UDim2.new(0, 100, 0, 10)
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left

		descLabel.Size = UDim2.new(1, -110, 0, 30)
		descLabel.Position = UDim2.new(0, 100, 0, 52)
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
	end

	return screenGui, frame, iconFrame, innerFill, circle, lambdaLabel, titleLabel, descLabel, modeData
end

local function showNotification(title, description, iconText, arg4, arg5)
	local mode, soundId = resolveModeAndSound(arg4, arg5)

	local screenGui, frame, iconFrame, innerFill, circle, lambdaLabel, titleLabel, descLabel, modeData =
		createNotificationGui(mode)

	lambdaLabel.Text = iconText or "λ"
	titleLabel.Text = title or "BİLDİRİM"
	descLabel.Text = description or ""

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
		{ BackgroundTransparency = 0 }
	)

	local fillTweenIn = TweenService:Create(
		innerFill,
		TweenInfo.new(CONFIG.TweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0 }
	)

	local circleTweenIn = TweenService:Create(
		circle,
		TweenInfo.new(CONFIG.TweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0 }
	)

	local lambdaTweenIn = TweenService:Create(
		lambdaLabel,
		TweenInfo.new(CONFIG.TweenTime),
		{ TextTransparency = 0 }
	)

	local titleTweenIn = TweenService:Create(
		titleLabel,
		TweenInfo.new(CONFIG.TweenTime),
		{ TextTransparency = 0 }
	)

	local descTweenIn = TweenService:Create(
		descLabel,
		TweenInfo.new(CONFIG.TweenTime),
		{ TextTransparency = 0 }
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

return showNotification
