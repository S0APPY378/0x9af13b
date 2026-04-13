--// Passive Tracker GUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local chokePlaying = false
local burstWarningPlaying = false
local highlightEnabled = false
local activeHighlight = nil
local highlightedTarget = nil


local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PassiveTracker"
ScreenGui.IgnoreGuiInset = false
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.DisplayOrder = 3

-- === TOP BAR FRAME ===
local MainFrame = Instance.new("Frame")
MainFrame.Name = "TrackerFrame"
MainFrame.Size = UDim2.new(1, 0, 0, 46)
MainFrame.Position = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BorderSizePixel = 0
MainFrame.Active = false
MainFrame.Draggable = false
MainFrame.Parent = ScreenGui

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 1
UIStroke.Transparency = 0.5

local UIListLayout = Instance.new("UIListLayout", MainFrame)
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center


local function newLabel(text)
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Nunito
	lbl.TextSize = 16
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Size = UDim2.new(0, 170, 1, 0)
	lbl.Text = text
	lbl.Parent = MainFrame
	return lbl
end


local NameLabel     = newLabel("AI: —")
local DistanceLabel = newLabel("Distance: —")
local AngerLabel    = newLabel("Anger: —")
local ChokeLabel    = newLabel("Choke: —")
local BurstLabel    = newLabel("Burst: —")
local EnragedLabel  = newLabel("Enraged Meter: —")


-- === ALERT GUI ===
local alertGui = Instance.new("ScreenGui")
alertGui.Name = "AlertGui"
alertGui.ResetOnSpawn = false
alertGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local alertLabel = Instance.new("TextLabel")
alertLabel.Size = UDim2.new(0.8, 0, 0.3, 0)
alertLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
alertLabel.AnchorPoint = Vector2.new(0.5, 0.5)
alertLabel.BackgroundTransparency = 1
alertLabel.TextScaled = true
alertLabel.Font = Enum.Font.GothamBlack
alertLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
alertLabel.TextTransparency = 1
alertLabel.Parent = alertGui

local function showAlert(text, color)
	alertLabel.Text = text
	alertLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	alertLabel.TextTransparency = 1
	alertLabel.TextStrokeTransparency = 0
	alertLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	TweenService:Create(alertLabel, TweenInfo.new(0.01), {TextTransparency = 0}):Play()
	task.wait(0.8)
	TweenService:Create(alertLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
end


local AIFolder = Workspace:WaitForChild("Misc"):WaitForChild("AI")


local function format(num)
	return string.format("%.1f", num)
end


local function GetClosestAI()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	local closest, distance = nil, math.huge

	for _, ai in ipairs(AIFolder:GetChildren()) do
		local hrp = ai:FindFirstChild("HumanoidRootPart")
		if hrp then
			local mag = (hrp.Position - root.Position).Magnitude
			if mag < distance then
				closest, distance = ai, mag
			end
		end
	end

	return closest, distance
end


function getColor(value)
	if value >= 80 then
		return Color3.fromRGB(255, 0, 0)
	elseif value >= 50 then
		return Color3.fromRGB(255, 170, 0)
	elseif value >= 25 then
		return Color3.fromRGB(255, 255, 0)
	else
		return Color3.fromRGB(120, 255, 120)
	end
end


-- === HIGHLIGHT SYSTEM ===
local function removeHighlight()
	if activeHighlight then
		activeHighlight:Destroy()
		activeHighlight = nil
	end
	highlightedTarget = nil
end

local function applyHighlight(target)
	if highlightedTarget == target then return end
	removeHighlight()

	local hl = Instance.new("Highlight")
	hl.FillColor = Color3.fromRGB(255, 60, 60)
	hl.FillTransparency = 0.5
	hl.OutlineColor = Color3.fromRGB(255, 30, 30)
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee = target
	hl.Parent = Workspace
	activeHighlight = hl
	highlightedTarget = target
end

local function findChainAI()
	for _, ai in ipairs(AIFolder:GetChildren()) do
		if ai.Name:lower():find("chain") then
			return ai
		end
	end
	return nil
end


-- === MOBILE HIGHLIGHT BUTTON (draggable) ===
local MobileGui = Instance.new("ScreenGui")
MobileGui.Name = "MobileHighlightBtn"
MobileGui.ResetOnSpawn = false
MobileGui.IgnoreGuiInset = false
MobileGui.DisplayOrder = 4
MobileGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MobileHLButton = Instance.new("TextButton")
MobileHLButton.Size = UDim2.new(0, 72, 0, 42)
MobileHLButton.Position = UDim2.new(1, -88, 1, -120)
MobileHLButton.AnchorPoint = Vector2.new(0, 0)
MobileHLButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MobileHLButton.BackgroundTransparency = 0.15
MobileHLButton.BorderSizePixel = 0
MobileHLButton.Font = Enum.Font.GothamBold
MobileHLButton.TextSize = 13
MobileHLButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileHLButton.Text = "👁 OFF"
MobileHLButton.Parent = MobileGui

local BtnCorner = Instance.new("UICorner", MobileHLButton)
BtnCorner.CornerRadius = UDim.new(0, 10)

local BtnStroke = Instance.new("UIStroke", MobileHLButton)
BtnStroke.Color = Color3.fromRGB(255, 255, 255)
BtnStroke.Thickness = 1
BtnStroke.Transparency = 0.55


local function updateButtonVisual()
	if highlightEnabled then
		TweenService:Create(MobileHLButton, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(200, 40, 40)
		}):Play()
		MobileHLButton.Text = "👁 ON"
		BtnStroke.Color = Color3.fromRGB(255, 80, 80)
		BtnStroke.Transparency = 0.2
	else
		TweenService:Create(MobileHLButton, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		}):Play()
		MobileHLButton.Text = "👁 OFF"
		BtnStroke.Color = Color3.fromRGB(255, 255, 255)
		BtnStroke.Transparency = 0.55
	end
end


-- === SHARED TOGGLE ===
local function toggleHighlight()
	highlightEnabled = not highlightEnabled
	if highlightEnabled then
		local chain = findChainAI()
		if chain then
			applyHighlight(chain)
		else
			highlightEnabled = false
		end
	else
		removeHighlight()
		showAlert("[H] Highlight OFF", Color3.fromRGB(180, 180, 180))
	end
	updateButtonVisual()
end


-- === DRAG LOGIC ===
local dragging = false
local dragStartInput = nil
local btnStartPos = nil
local dragMoved = false

MobileHLButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragMoved = false
		dragStartInput = input.Position
		btnStartPos = MobileHLButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then return end
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then

		local delta = input.Position - dragStartInput
		if delta.Magnitude > 8 then
			dragMoved = true
		end

		local vp = workspace.CurrentCamera.ViewportSize
		local bw = MobileHLButton.AbsoluteSize.X
		local bh = MobileHLButton.AbsoluteSize.Y

		local rawX = btnStartPos.X.Scale * vp.X + btnStartPos.X.Offset + delta.X
		local rawY = btnStartPos.Y.Scale * vp.Y + btnStartPos.Y.Offset + delta.Y

		-- Clamp inside screen
		rawX = math.clamp(rawX, 0, vp.X - bw)
		rawY = math.clamp(rawY, 0, vp.Y - bh)

		MobileHLButton.Position = UDim2.new(0, rawX, 0, rawY)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if not dragging then return end
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
		-- Treat as tap (toggle) only if barely moved
		if not dragMoved then
			toggleHighlight()
		end
	end
end)


-- === H KEY TOGGLE (keyboard / PC) ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.H then
		toggleHighlight()
	end
end)


-- === MAIN LOOP ===
RunService.RenderStepped:Connect(function()
	local ai, dist = GetClosestAI()

	if highlightEnabled then
		local chain = findChainAI()
		if chain then
			applyHighlight(chain)
		else
			removeHighlight()
		end
	end

	if ai then
		local att = ai:GetAttributes()
		local anger   = att.Anger or 0
		local choke   = att.ChokeMeter or 0
		local burst   = att.Burst or 0
		local enraged = att.EnragedMeter or 0

		local hrp = ai:FindFirstChild("HumanoidRootPart")
		if hrp then
			if not hrp:FindFirstChild("ChokeSwingListener") then
				local tag = Instance.new("BoolValue")
				tag.Name = "ChokeSwingListener"
				tag.Parent = hrp

				hrp.ChildAdded:Connect(function(child)
					if child:IsA("Sound") and child.Name == "ChokeSwing" then
						if not chokePlaying then
							chokePlaying = true
							showAlert("DODGE", Color3.fromRGB(255, 0, 0))
						end

						child.AncestryChanged:Connect(function(_, parent)
							if not parent then
								chokePlaying = false
							end
						end)
					end
				end)
			end
		end

		if burst >= 100 then
			if not burstWarningPlaying then
				burstWarningPlaying = true
				showAlert("AOE ATTACK", Color3.fromRGB(255, 200, 50))

				task.delay(1.2, function()
					burstWarningPlaying = false
				end)
			end
		end

		NameLabel.Text      = "AI: " .. ai.Name
		DistanceLabel.Text  = "Distance: " .. format(dist)
		AngerLabel.Text     = "Anger: " .. format(anger) .. "%"
		AngerLabel.TextColor3   = getColor(anger)
		ChokeLabel.Text     = "Choke: " .. format(choke) .. "%"
		ChokeLabel.TextColor3   = getColor(choke)
		BurstLabel.Text     = "Burst: " .. format(burst) .. "%"
		BurstLabel.TextColor3   = getColor(burst)
		EnragedLabel.Text   = "Enraged Meter: " .. format(enraged) .. "%"
		EnragedLabel.TextColor3 = getColor(enraged)

	else
		NameLabel.Text     = "AI: —"
		DistanceLabel.Text = "Distance: —"
		AngerLabel.Text    = "Anger: —"
		ChokeLabel.Text    = "Choke: —"
		BurstLabel.Text    = "Burst: —"
		EnragedLabel.Text  = "Enraged Meter: —"

		AngerLabel.TextColor3   = Color3.new(1, 1, 1)
		ChokeLabel.TextColor3   = Color3.new(1, 1, 1)
		BurstLabel.TextColor3   = Color3.new(1, 1, 1)
		EnragedLabel.TextColor3 = Color3.new(1, 1, 1)
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	MainFrame.Visible = true
end)