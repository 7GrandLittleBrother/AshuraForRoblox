local function createnotification(title, text, delay)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = title,
		Text = text,
		Duration = delay
	})
end

if not shared.AshuraExecuted then
	createnotification("AshuraClient", "Ashura Already Injected", 5)
end
shared.AshuraExecuted = true

shared.GuiLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandLittleBrother/AshuraForRoblox/main/GuiLibrary.lua", true))()

if game.PlaceId == 6872274481 or game.PlaceId == 8560631822 or game.PlaceId == 8444591321 then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandLittleBrother/AshuraForRoblox/main/CustomModules/bedwars.lua", true))()
end
