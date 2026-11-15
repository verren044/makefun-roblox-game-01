-- COIN RUSH: a 2D arcade collector inside a Roblox GUI.
-- Arrow keys / WASD to move. Grab gold coins (+10), dodge the red
-- hazards (one hit costs a life), clear 60 seconds with 3 lives.
-- Every 5 coins: level up, hazards get faster and one more spawns.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local ARENA_WIDTH = 640
local ARENA_HEIGHT = 480
local PLAYER_SIZE = 40
local SPEED = 340
local GAME_TIME = 60
local COIN_SIZE = 28
local MAX_COINS = 6
local HAZARD_SIZE = 36

local gui = Instance.new("ScreenGui")
gui.Name = "CoinRushGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.fromScale(1, 1)
background.BackgroundColor3 = Color3.fromRGB(24, 28, 44)
background.BorderSizePixel = 0
background.Parent = gui

local function makeLabel(parent, name, text, size, pos, anchor)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.AnchorPoint = anchor or Vector2.new(0.5, 0)
	label.Position = pos
	label.Size = size
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(235, 235, 240)
	label.TextSize = 24
	label.Font = Enum.Font.GothamBold
	label.Parent = parent
	return label
end

local title = makeLabel(background, "Title", "COIN RUSH", UDim2.fromOffset(ARENA_WIDTH, 36),
	UDim2.new(0.5, 0, 0.5, -ARENA_HEIGHT / 2 - 92))
title.TextColor3 = Color3.fromRGB(255, 210, 63)
title.TextSize = 32

local hud = makeLabel(background, "HUD", "", UDim2.fromOffset(ARENA_WIDTH, 28),
	UDim2.new(0.5, 0, 0.5, -ARENA_HEIGHT / 2 - 48))
hud.TextSize = 20
hud.Font = Enum.Font.Gotham

local arena = Instance.new("Frame")
arena.Name = "Arena"
arena.AnchorPoint = Vector2.new(0.5, 0.5)
arena.Position = UDim2.fromScale(0.5, 0.5)
arena.Size = UDim2.fromOffset(ARENA_WIDTH, ARENA_HEIGHT)
arena.BackgroundColor3 = Color3.fromRGB(43, 52, 84)
arena.BorderColor3 = Color3.fromRGB(255, 210, 63)
arena.BorderSizePixel = 3
arena.Parent = background

local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = Color3.fromRGB(16, 18, 30)
overlay.BackgroundTransparency = 0.25
overlay.BorderSizePixel = 0
overlay.Parent = arena

local overlayTitle = makeLabel(overlay, "OverlayTitle", "COIN RUSH", UDim2.fromOffset(500, 48),
	UDim2.new(0.5, 0.5, 0.5, -90))
overlayTitle.TextColor3 = Color3.fromRGB(255, 210, 63)
overlayTitle.TextSize = 44

local overlayBody = makeLabel(overlay, "OverlayBody", "", UDim2.fromOffset(560, 120),
	UDim2.new(0.5, 0.5, 0.5, 10))
overlayBody.TextSize = 20
overlayBody.Font = Enum.Font.Gotham
overlayBody.TextWrapped = true

local overlayHint = makeLabel(overlay, "OverlayHint", "Press SPACE to start", UDim2.fromOffset(500, 32),
	UDim2.new(0.5, 0.5, 0.5, 100))
overlayHint.TextColor3 = Color3.fromRGB(120, 220, 140)
overlayHint.TextSize = 22

local playerSquare = Instance.new("Frame")
playerSquare.Name = "Player"
playerSquare.Size = UDim2.fromOffset(PLAYER_SIZE, PLAYER_SIZE)
playerSquare.BackgroundColor3 = Color3.fromRGB(64, 200, 255)
playerSquare.BorderColor3 = Color3.fromRGB(255, 255, 255)
playerSquare.BorderSizePixel = 2
playerSquare.Parent = arena

local playerCorner = Instance.new("UICorner")
playerCorner.CornerRadius = UDim.new(0, 8)
playerCorner.Parent = playerSquare

-- Game state
local state = "menu" -- "menu" | "playing" | "over"
local px = (ARENA_WIDTH - PLAYER_SIZE) / 2
local py = (ARENA_HEIGHT - PLAYER_SIZE) / 2
local score = 0
local coinsCollected = 0
local lives = 3
local level = 1
local timeLeft = GAME_TIME
local invulnerableUntil = 0
local coins = {}
local hazards = {}

local function placePlayer()
	playerSquare.Position = UDim2.fromOffset(math.floor(px + 0.5), math.floor(py + 0.5))
end

local function randomPos(size)
	return math.random(8, ARENA_WIDTH - size - 8), math.random(8, ARENA_HEIGHT - size - 8)
end

local function spawnCoin()
	local coin = Instance.new("Frame")
	coin.Name = "Coin"
	coin.Size = UDim2.fromOffset(COIN_SIZE, COIN_SIZE)
	coin.BackgroundColor3 = Color3.fromRGB(255, 210, 63)
	coin.BorderColor3 = Color3.fromRGB(180, 120, 0)
	coin.BorderSizePixel = 2
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = coin
	local x, y = randomPos(COIN_SIZE)
	coin.Position = UDim2.fromOffset(x, y)
	coin.Parent = arena
	table.insert(coins, { frame = coin, x = x, y = y })
end

local function clearCoins()
	for _, c in ipairs(coins) do
		c.frame:Destroy()
	end
	coins = {}
end

local function hazardCount()
	return math.min(2 + level, 7)
end

local function hazardSpeed()
	return 110 + level * 28
end

local function spawnHazards()
	for _, h in ipairs(hazards) do
		h.frame:Destroy()
	end
	hazards = {}
	for _ = 1, hazardCount() do
		local frame = Instance.new("Frame")
		frame.Name = "Hazard"
		frame.Size = UDim2.fromOffset(HAZARD_SIZE, HAZARD_SIZE)
		frame.BackgroundColor3 = Color3.fromRGB(235, 60, 70)
		frame.BorderColor3 = Color3.fromRGB(120, 0, 10)
		frame.BorderSizePixel = 2
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = frame
		local x, y = randomPos(HAZARD_SIZE)
		frame.Position = UDim2.fromOffset(x, y)
		frame.Parent = arena
		local angle = math.random() * math.pi * 2
		local speed = hazardSpeed()
		table.insert(hazards, {
			frame = frame, x = x, y = y,
			vx = math.cos(angle) * speed, vy = math.sin(angle) * speed,
		})
	end
end

local function updateHud()
	hud.Text = string.format("Score %d   |   Coins %d   |   Lives %d   |   Level %d   |   %ds",
		score, coinsCollected, lives, level, math.max(0, math.ceil(timeLeft)))
end

local function showOverlay(show, titleText, bodyText, hintText)
	overlay.Visible = show
	if titleText then
		overlayTitle.Text = titleText
	end
	if bodyText then
		overlayBody.Text = bodyText
	end
	if hintText then
		overlayHint.Text = hintText
	end
end

local function resetPositions()
	px = (ARENA_WIDTH - PLAYER_SIZE) / 2
	py = (ARENA_HEIGHT - PLAYER_SIZE) / 2
	placePlayer()
end

local function startGame()
	score = 0
	coinsCollected = 0
	lives = 3
	level = 1
	timeLeft = GAME_TIME
	invulnerableUntil = 0
	resetPositions()
	clearCoins()
	for _ = 1, MAX_COINS do
		spawnCoin()
	end
	spawnHazards()
	updateHud()
	showOverlay(false)
	state = "playing"
end

local function gameOver(reason)
	state = "over"
	showOverlay(true, "GAME OVER",
		string.format("%s\n\nFinal score: %d   |   Coins: %d   |   Level reached: %d",
			reason, score, coinsCollected, level),
		"Press R to play again")
end

local function overlaps(ax, ay, asize, bx, by, bsize)
	return ax < bx + bsize and ax + asize > bx and ay < by + bsize and ay + asize > by
end

local function levelUpFlash()
	showOverlay(true, "LEVEL " .. level .. "!", "Hazards get faster — one more joins the hunt!", "")
	task.delay(0.9, function()
		if state == "playing" then
			showOverlay(false)
		end
	end)
end

placePlayer()
updateHud()
showOverlay(true, "COIN RUSH",
	"Arrow keys or WASD to move.\nGrab gold coins: +10 each.\nDodge the red hazards: one hit costs a life.\n60 seconds, 3 lives — every 5 coins you level up!",
	"Press SPACE to start")
gui.Parent = player:WaitForChild("PlayerGui")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if state == "menu" and input.KeyCode == Enum.KeyCode.Space then
		startGame()
	elseif state == "over" and input.KeyCode == Enum.KeyCode.R then
		startGame()
	end
end)

RunService.RenderStepped:Connect(function(dt)
	if state ~= "playing" then
		return
	end

	-- Timer
	timeLeft -= dt
	if timeLeft <= 0 then
		timeLeft = 0
		updateHud()
		gameOver("Time's up!")
		return
	end

	-- Movement (arrows + WASD)
	local dx = 0
	local dy = 0
	if UserInputService:IsKeyDown(Enum.KeyCode.Left) or UserInputService:IsKeyDown(Enum.KeyCode.A) then
		dx -= 1
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Right) or UserInputService:IsKeyDown(Enum.KeyCode.D) then
		dx += 1
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Up) or UserInputService:IsKeyDown(Enum.KeyCode.W) then
		dy -= 1
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Down) or UserInputService:IsKeyDown(Enum.KeyCode.S) then
		dy += 1
	end
	if dx ~= 0 or dy ~= 0 then
		local len = math.sqrt(dx * dx + dy * dy)
		px = math.clamp(px + (dx / len) * SPEED * dt, 0, ARENA_WIDTH - PLAYER_SIZE)
		py = math.clamp(py + (dy / len) * SPEED * dt, 0, ARENA_HEIGHT - PLAYER_SIZE)
		placePlayer()
	end

	-- Hazards drift and bounce
	for _, h in ipairs(hazards) do
		h.x += h.vx * dt
		h.y += h.vy * dt
		if h.x <= 0 then
			h.x = 0
			h.vx = math.abs(h.vx)
		elseif h.x >= ARENA_WIDTH - HAZARD_SIZE then
			h.x = ARENA_WIDTH - HAZARD_SIZE
			h.vx = -math.abs(h.vx)
		end
		if h.y <= 0 then
			h.y = 0
			h.vy = math.abs(h.vy)
		elseif h.y >= ARENA_HEIGHT - HAZARD_SIZE then
			h.y = ARENA_HEIGHT - HAZARD_SIZE
			h.vy = -math.abs(h.vy)
		end
		h.frame.Position = UDim2.fromOffset(math.floor(h.x + 0.5), math.floor(h.y + 0.5))
	end

	-- Coins: collect on touch
	for i = #coins, 1, -1 do
		local c = coins[i]
		if overlaps(px, py, PLAYER_SIZE, c.x, c.y, COIN_SIZE) then
			c.frame:Destroy()
			table.remove(coins, i)
			score += 10
			coinsCollected += 1
			spawnCoin()
			if coinsCollected % 5 == 0 then
				level += 1
				spawnHazards()
				levelUpFlash()
			end
		end
	end

	-- Hazards: hit costs a life (with 1.5 s of invulnerability + flash)
	local now = os.clock()
	if now >= invulnerableUntil then
		playerSquare.BackgroundColor3 = Color3.fromRGB(64, 200, 255)
		for _, h in ipairs(hazards) do
			if overlaps(px, py, PLAYER_SIZE, h.x, h.y, HAZARD_SIZE) then
				lives -= 1
				invulnerableUntil = now + 1.5
				playerSquare.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				if lives <= 0 then
					updateHud()
					gameOver("The hazards got you!")
					return
				end
				break
			end
		end
	end

	updateHud()
end)
