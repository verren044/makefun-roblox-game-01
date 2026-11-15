-- COIN RUSH server: the whole game runs on the client GUI; the server
-- only logs joins and keeps the place alive.
local Players = game:GetService("Players")

print("[Coin Rush] server ready — collect coins, dodge hazards, 60 seconds!")

Players.PlayerAdded:Connect(function(player)
	print("[Coin Rush] " .. player.Name .. " joined the rush.")
end)
