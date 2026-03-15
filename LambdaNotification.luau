-- LAMBDA NOTIFICATION SCRIPT

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CONFIG = {
	Position = UDim2.new(0.5, 0, 0.08, 0),
	Size     = UDim2.new(0, 480, 0, 90),
	BgColor  = Color3.fromRGB(140, 140, 140),
	IconBgColor = Color3.fromRGB(160, 160, 160),
	TextColor = Color3.fromRGB(255, 255, 255),
	TweenTime = 0.35,
	DisplayTime = 4,
	CornerRadius = UDim.new(0, 6),
}

local function playDing()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://4590657391"
    sound.Volume  = 0.5
    sound.Parent  = workspace
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 3)
end

local function createNotificationGui()
	if playerGui:FindFirstChild("NotificationGui") then
		playerGui.NotificationGui:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NotificationGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Name = "NotifFrame"
	frame.Size = CONFIG.Size
	frame.Position = CONFIG.Position
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.BackgroundColor3 = CONFIG.BgColor
	frame.BorderSizePixel = 0
	frame.Position = UDim2.new(
		CONFIG.Position.X.Scale, CONFIG.Position.X.Offset,
		-0.15, 0
	)
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = CONFIG.CornerRadius
	frameCorner.Parent = frame

	local iconFrame = Instance.new("Frame")
	iconFrame.Name = "IconFrame"
	iconFrame.Size = UDim2.new(0, 90, 1, 0)
	iconFrame.Position = UDim2.new(0, 0, 0, 0)
	iconFrame.BackgroundColor3 = CONFIG.IconBgColor
	iconFrame.BorderSizePixel = 0
	iconFrame.BackgroundTransparency = 1
	iconFrame.Parent = frame

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = CONFIG.CornerRadius
	iconCorner.Parent = iconFrame

	local iconRightFill = Instance.new("Frame")
	iconRightFill.Size = UDim2.new(0, 10, 1, 0)
	iconRightFill.Position = UDim2.new(1, -10, 0, 0)
	iconRightFill.BackgroundColor3 = CONFIG.IconBgColor
	iconRightFill.BorderSizePixel = 0
	iconRightFill.BackgroundTransparency = 1
	iconRightFill.Parent = iconFrame

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
	titleLabel.Size = UDim2.new(1, -110, 0, 50)
	titleLabel.Position = UDim2.new(0, 100, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "TITLE KISMI"
	titleLabel.TextColor3 = CONFIG.TextColor
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 28
	titleLabel.TextTransparency = 1
	titleLabel.Parent = frame

	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "DescLabel"
	descLabel.Size = UDim2.new(1, -110, 0, 30)
	descLabel.Position = UDim2.new(0, 100, 0, 52)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = "AÇIKLAMA"
	descLabel.TextColor3 = CONFIG.TextColor
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 16
	descLabel.TextTransparency = 1
	descLabel.Parent = frame

	return screenGui, frame, iconFrame, iconRightFill, circle, lambdaLabel, titleLabel, descLabel
end

local function showNotification(title, description, iconText)
	local screenGui, frame, iconFrame, iconRightFill, circle, lambdaLabel, titleLabel, descLabel
		= createNotificationGui()

	lambdaLabel.Text = iconText or "λ"

	titleLabel.Text = title or "BİLDİRİM"
	descLabel.Text  = description or ""

	playDing()

	local tweenIn = TweenService:Create(frame, TweenInfo.new(CONFIG.TweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(
			CONFIG.Position.X.Scale, CONFIG.Position.X.Offset,
			CONFIG.Position.Y.Scale, CONFIG.Position.Y.Offset
		),
		BackgroundTransparency = 0.3,
	})

	local iconTweenIn = TweenService:Create(iconFrame, TweenInfo.new(CONFIG.TweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0,
	})
	local fillTweenIn = TweenService:Create(iconRightFill, TweenInfo.new(CONFIG.TweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0,
	})
	local circleTweenIn = TweenService:Create(circle, TweenInfo.new(CONFIG.TweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0,
	})
	local lambdaTweenIn = TweenService:Create(lambdaLabel, TweenInfo.new(CONFIG.TweenTime), {
		TextTransparency = 0,
	})
	local titleTweenIn = TweenService:Create(titleLabel, TweenInfo.new(CONFIG.TweenTime), {
		TextTransparency = 0,
	})
	local descTweenIn = TweenService:Create(descLabel, TweenInfo.new(CONFIG.TweenTime), {
		TextTransparency = 0,
	})

	tweenIn:Play()
	iconTweenIn:Play()
	fillTweenIn:Play()
	circleTweenIn:Play()
	lambdaTweenIn:Play()
	titleTweenIn:Play()
	descTweenIn:Play()

	task.delay(CONFIG.DisplayTime, function()
		local tweenOut = TweenService:Create(frame, TweenInfo.new(CONFIG.TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(
				CONFIG.Position.X.Scale, CONFIG.Position.X.Offset,
				-0.15, 0
			),
			BackgroundTransparency = 1,
		})

		local iconTweenOut    = TweenService:Create(iconFrame,    TweenInfo.new(CONFIG.TweenTime), { BackgroundTransparency = 1 })
		local fillTweenOut    = TweenService:Create(iconRightFill,TweenInfo.new(CONFIG.TweenTime), { BackgroundTransparency = 1 })
		local circleTweenOut  = TweenService:Create(circle,       TweenInfo.new(CONFIG.TweenTime), { BackgroundTransparency = 1 })
		local lambdaTweenOut  = TweenService:Create(lambdaLabel,  TweenInfo.new(CONFIG.TweenTime), { TextTransparency = 1 })
		local titleTweenOut   = TweenService:Create(titleLabel,   TweenInfo.new(CONFIG.TweenTime), { TextTransparency = 1 })
		local descTweenOut    = TweenService:Create(descLabel,    TweenInfo.new(CONFIG.TweenTime), { TextTransparency = 1 })

		tweenOut:Play()
		iconTweenOut:Play()
		fillTweenOut:Play()
		circleTweenOut:Play()
		lambdaTweenOut:Play()
		titleTweenOut:Play()
		descTweenOut:Play()

		tweenOut.Completed:Connect(function()
			if screenGui then screenGui:Destroy() end
		end)
	end)
end

return showNotification
