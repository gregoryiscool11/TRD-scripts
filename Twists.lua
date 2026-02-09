local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Prevent duplicate UI
if player.PlayerGui:FindFirstChild("TwistViewer") then
	player.PlayerGui.TwistViewer:Destroy()
end

-- Path to CurrentTwist
local CurrentTwist = RS:WaitForChild("Season"):WaitForChild("Twists"):WaitForChild("CurrentTwist")

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TwistViewer"
ScreenGui.ResetOnSpawn = false -- 🔥 respawn-proof
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 350, 0, 90)
Frame.Position = UDim2.new(0.5, -175, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BackgroundTransparency = 0.25
Frame.Active = true
Frame.Visible = true

-- Rounded corners
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 16)
Corner.Parent = Frame

-- Red glow stroke
local Stroke = Instance.new("UIStroke")
Stroke.Parent = Frame
Stroke.Color = Color3.fromRGB(255, 0, 0)
Stroke.Thickness = 2
Stroke.Transparency = 0.3

-- Glow effect
local Glow = Instance.new("Frame")
Glow.Parent = Frame
Glow.Size = UDim2.new(1, 20, 1, 20)
Glow.Position = UDim2.new(0, -10, 0, -10)
Glow.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Glow.BackgroundTransparency = 0.85
Glow.ZIndex = -1

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0, 20)
GlowCorner.Parent = Glow

-- Text label
local TextLabel = Instance.new("TextLabel")
TextLabel.Parent = Frame
TextLabel.Size = UDim2.new(1, -20, 1, -20)
TextLabel.Position = UDim2.new(0, 10, 0, 10)
TextLabel.BackgroundTransparency = 1
TextLabel.TextColor3 = Color3.fromRGB(255, 220, 220)
TextLabel.TextSize = 20
TextLabel.TextWrapped = true
TextLabel.Font = Enum.Font.GothamBold
TextLabel.Text = "Current Twist: " .. tostring(CurrentTwist.Value)

-- Live update
CurrentTwist.Changed:Connect(function()
	TextLabel.Text = "Current Twist: " .. tostring(CurrentTwist.Value)
end)

-- Tween settings
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function tweenGui(show)
	if show then
		Frame.Visible = true

		Frame.Size = UDim2.new(0, 0, 0, 0)
		Frame.BackgroundTransparency = 1
		TextLabel.TextTransparency = 1
		Stroke.Transparency = 1

		TweenService:Create(Frame, tweenInfo, {
			Size = UDim2.new(0, 350, 0, 90),
			BackgroundTransparency = 0.25
		}):Play()

		TweenService:Create(TextLabel, tweenInfo, {TextTransparency = 0}):Play()
		TweenService:Create(Stroke, tweenInfo, {Transparency = 0.3}):Play()
	else
		local t1 = TweenService:Create(Frame, tweenInfo, {
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1
		})
		local t2 = TweenService:Create(TextLabel, tweenInfo, {TextTransparency = 1})
		local t3 = TweenService:Create(Stroke, tweenInfo, {Transparency = 1})

		t1:Play(); t2:Play(); t3:Play()
		t1.Completed:Wait()
		Frame.Visible = false
	end
end

local enabled = true

-- PC toggle (F)
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.F then
		enabled = not enabled
		tweenGui(enabled)
	end
end)

-- Mobile toggle button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 120, 0, 40)
ToggleButton.Position = UDim2.new(0, 15, 0.7, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.BackgroundTransparency = 0.2
ToggleButton.Text = "Twist UI"
ToggleButton.TextColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 16
ToggleButton.AutoButtonColor = false
ToggleButton.Active = true

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 12)
BtnCorner.Parent = ToggleButton

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Parent = ToggleButton
BtnStroke.Color = Color3.fromRGB(255, 0, 0)
BtnStroke.Transparency = 0.4

ToggleButton.MouseButton1Click:Connect(function()
	enabled = not enabled
	tweenGui(enabled)
end)

-- Universal draggable function (PC + Mobile)
local function makeDraggable(obj)
	local dragging = false
	local dragStart, startPos

	obj.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = obj.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	obj.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			obj.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

makeDraggable(Frame)
makeDraggable(ToggleButton)

-- EXTRA: Reattach GUI if PlayerGui reloads (executor-proof)
player.CharacterAdded:Connect(function()
	if not player.PlayerGui:FindFirstChild("TwistViewer") then
		ScreenGui.Parent = player.PlayerGui
	end
end)
