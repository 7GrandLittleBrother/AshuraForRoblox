--[[
	Credits
	Vape - Winter Sky
	Vape - RunLoops
	Please notify me if you need credits
]]
local GuiLibrary = shared.GuiLibrary

local players = game:GetService("Players")
local lplr = players.LocalPlayer
local cam = game:GetService("Workspace").CurrentCamera
local modules = {}

local function runcode(func)
	func()
end

local function isAlive(plr, alivecheck)
	if plr then
		return plr and plr.Character and plr.Character.Parent ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid")
	end
end

local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, num, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = game:GetService("RunService").RenderStepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, num, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = game:GetService("RunService").Stepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, num, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = game:GetService("RunService").Heartbeat:Connect(func)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

local function hashvec(vec)
	return {value = vec}
end

local function getremote(tab)
	for i,v in pairs(tab) do
		if v == "Client" then
			return tab[i + 1]
		end
	end
	return ""
end
runcode(function()
	local KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
	local Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
	local InventoryUtil = require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil
	modules = {
		AttackRemote = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.SwordController).attackEntity)),
		BlockController = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine,
		BlockController2 = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer,
		BlockEngine = require(lplr.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine,
		ClientHandler = Client,
		getCurrentInventory = function(plr)
			local plr = plr or lplr
			local suc, result = pcall(function()
				return InventoryUtil.getInventory(plr)
			end)
			return (suc and result or {
				["items"] = {},
				["armor"] = {},
				["hand"] = nil
			})
		end,
		ItemMeta = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta, 1),
		KnockbackUtil = require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil,
		SprintCont = KnitClient.Controllers.SprintController,
		SwordController = KnitClient.Controllers.SwordController
	}
end)

local function getCurrentSword()
	local sword, swordslot, swordrank = nil, nil, 0
	for i5, v5 in pairs(modules.getCurrentInventory.items) do
		if v5.itemType:lower():find("sword") or v5.itemType:lower():find("blade") or v5.itemType:lower():find("dao") then
			if modules.ItemMeta[v5.itemType].sword.damage > swordrank then
				sword = v5
				swordslot = i5
				swordrank = modules.ItemMeta[v5.itemType].sword.damage
			end
		end
	end
	return sword, swordslot
end

task.spawn(function()
	task.spawn(function()
		for i,v in pairs(game:GetService("Lighting"):GetChildren()) do
			if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
				v:Remove()
			end
		end
		local sky = Instance.new("Sky")
		sky.StarCount = 5000
		sky.SkyboxUp = "rbxassetid://8139676647"
		sky.SkyboxLf = "rbxassetid://8139676988"
		sky.SkyboxFt = "rbxassetid://8139677111"
		sky.SkyboxBk = "rbxassetid://8139677359"
		sky.SkyboxDn = "rbxassetid://8139677253"
		sky.SkyboxRt = "rbxassetid://8139676842"
		sky.SunTextureId = "rbxassetid://6196665106"
		sky.SunAngularSize = 11
		sky.MoonTextureId = "rbxassetid://8139665943"
		sky.MoonAngularSize = 30
		sky.Parent = game:GetService("Lighting")
		local sunray = Instance.new("SunRaysEffect")
		sunray.Intensity = 0.03
		sunray.Parent = game:GetService("Lighting")
		local bloom = Instance.new("BloomEffect")
		bloom.Threshold = 2
		bloom.Intensity = 1
		bloom.Size = 2
		bloom.Parent = game:GetService("Lighting")
		local atmosphere = Instance.new("Atmosphere")
		atmosphere.Density = 0.3
		atmosphere.Offset = 0.25
		atmosphere.Color = Color3.fromRGB(198, 198, 198)
		atmosphere.Decay = Color3.fromRGB(104, 112, 124)
		atmosphere.Glare = 0
		atmosphere.Haze = 0
		atmosphere.Parent = game:GetService("Lighting")
	end)
	task.spawn(function()
		local snowpart = Instance.new("Part")
		snowpart.Size = Vector3.new(240, 0.5, 240)
		snowpart.Name = "SnowParticle"
		snowpart.Transparency = 1
		snowpart.CanCollide = false
		snowpart.Position = Vector3.new(0, 120, 286)
		snowpart.Anchored = true
		snowpart.Parent = workspace
		local snow = Instance.new("ParticleEmitter")
		snow.RotSpeed = NumberRange.new(300)
		snow.VelocitySpread = 35
		snow.Rate = 28
		snow.Texture = "rbxassetid://8158344433"
		snow.Rotation = NumberRange.new(110)
		snow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
		snow.Lifetime = NumberRange.new(8,14)
		snow.Speed = NumberRange.new(8,18)
		snow.EmissionDirection = Enum.NormalId.Bottom
		snow.SpreadAngle = Vector2.new(35,35)
		snow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
		snow.Parent = snowpart
		local windsnow = Instance.new("ParticleEmitter")
		windsnow.Acceleration = Vector3.new(0,0,1)
		windsnow.RotSpeed = NumberRange.new(100)
		windsnow.VelocitySpread = 35
		windsnow.Rate = 28
		windsnow.Texture = "rbxassetid://8158344433"
		windsnow.EmissionDirection = Enum.NormalId.Bottom
		windsnow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
		windsnow.Lifetime = NumberRange.new(8,14)
		windsnow.Speed = NumberRange.new(8,18)
		windsnow.Rotation = NumberRange.new(110)
		windsnow.SpreadAngle = Vector2.new(35,35)
		windsnow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
		windsnow.Parent = snowpart
		repeat
			task.wait()
			if isAlive(lplr, true) then 
				snowpart.Position = lplr.Character.HumanoidRootPart.Position + Vector3.new(0, 100, 0)
			end
		until lplr.Character.Parent == nil
	end)
end)

local win = GuiLibrary:CreateWindow({
	["Title"] = "Ashura V1",
	["Theme"] = "BloodTheme"
})

local Tabs = {
	["Combat"] = win.NewTab("Combat"),
	["Blatant"] = win.NewTab("Blatant"),
	["Render"] = win.NewTab("Render"),
	["Utility"] = win.NewTab("Utility"),
	["World"] = win.NewTab("World")
}

local Sections = {
	["AntiKnockBack"] = Tabs["Combat"].NewSection("AntiKnockBack"),
	["NoClickDelay"] = Tabs["Combat"].NewSection("NoClickDelay"),
	["Sprint"] = Tabs["Combat"].NewSection("Sprint"),
	["Killaura"] = Tabs["Blatant"].NewSection("Killaura"),
	["NoFall"] = Tabs["Blatant"].NewSection("NoFall")
}

runcode(function()
	local func
	local func2
	local AntiKnockBack = {["Enabled"] = false}
	Sections["AntiKnockBack"].NewToggle({
		["Name"] = "AntiKnockBack",
		["Function"] = function(callback)
			AntiKnockBack["Enabled"] = callback
			if AntiKnockBack["Enabled"] then
				func = modules.KnockbackUtil.applyKnockbackDirection
				func2 = modules.KnockbackUtil.applyKnockback
				modules.KnockbackUtil.applyKnockbackDirection = function(...) end
				modules.KnockbackUtil.applyKnockback = function(...) end
			else
				modules.KnockbackUtil.applyKnockbackDirection = func
				modules.KnockbackUtil.applyKnockback = func2
			end
		end,
		["Info"] = "Remove knockbacks."
	})
end)

runcode(function()
	local func
	local NoClickDelay = {["Enabled"] = false}
	Sections["NoClickDelay"].NewToggle({
		["Name"] = "NoClickDelay",
		["Function"] = function(callback)
			NoClickDelay["Enabled"] = callback
			if NoClickDelay["Enabled"] then
				func = modules.SwordController.isClickingTooFast
				modules.SwordController.isClickingTooFast = function(self)
					self.lastSwing = tick()
					return false
				end
			else
				modules.SwordController.isClickingTooFast = func
			end
		end,
		["Info"] = "Bypass cps limit."
	})
end)

runcode(function()
	local Sprint = {["Enabled"] = false}
	Sections["Sprint"].NewToggle({
		["Name"] = "Sprint",
		["Function"] = function(callback)
			Sprint["Enabled"] = callback
			if Sprint["Enabled"] then
				task.spawn(function()
					repeat
						task.wait()
						if (not modules.SprintCont.sprinting) then
							modules.SprintCont:startSprinting()
						end
					until (not Sprint["Enabled"])
				end)
			else
				modules.SprintCont:stopSprinting()
			end
		end,
		["Info"] = "Set sprint to true."
	})
end)

runcode(function()
	local KillauraRange = {["Value"] = 18}
	local Killaura = {["Enabled"] = false}
	local killauraremote = modules.ClientHandler:Get(modules.AttackRemote)
	function killaura()
		for i,v in pairs(game.Players:GetChildren()) do
			if v.Character and v.Name ~= game.Players.LocalPlayer.Name and v.Character:FindFirstChild("HumanoidRootPart") then
				local mag = (v.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
				if mag <= KillauraRange["Value"] and v.Team ~= game.Players.LocalPlayer.Team and v.Character:FindFirstChild("Humanoid") then
					if v.Character.Humanoid.Health > 0 then
						local selfpos = lplr.Character.HumanoidRootPart.Position + (KillauraRange["Value"] > 14 and (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude > 14 and (CFrame.lookAt(lplr.Character.HumanoidRootPart.Position, v.Character.HumanoidRootPart.Position).lookVector * 4) or Vector3.new(0, 0, 0))
						local sword = getCurrentSword()
						killauraremote:SendToServer({
							["weapon"] = sword ~= nil and sword.tool,
							["entityInstance"] = v.Character,
							["validate"] = {
								["raycast"] = {
									["cameraPosition"] = hashvec(cam.CFrame.Position),
									["cursorDirection"] = hashvec(Ray.new(cam.CFrame.Position, v.Character.HumanoidRootPart.CFrame.Position).Unit.Direction)
								},
								["targetPosition"] = hashvec(v.Character.HumanoidRootPart.CFrame.Position),
								["selfPosition"] = hashvec(selfpos)
							},
							["chargedAttack"] = {["chargeRatio"] = 0}
						})
					end
				end
			end
		end
	end
	Sections["Killaura"].NewToggle({
		["Name"] = "Killaura",
		["Function"] = function(callback)
			Killaura["Enabled"] = callback
			if Killaura["Enabled"] then
				RunLoops:BindToHeartbeat("Killaura", 1, function()
					killaura()
				end)
			else
				RunLoops:UnbindFromHeartbeat("Killaura")
			end
		end,
		["Info"] = "Attack players/enemies that are near."
	})
end)

runcode(function()
	local NoFall = {["Enabled"] = false}
	Sections["NoFall"].NewToggle({
		["Name"] = "NoFall",
		["Function"] = function(callback)
			NoFall["Enabled"] = callback
			if NoFall["Enabled"] then
				task.spawn(function()
					repeat
						task.wait()
						modules.ClientHandler:Get("GroundHit"):SendToServer()
					until (not NoFall["Enabled"])
				end)
			end
		end,
		["Info"] = "Prevents taking fall damage."
	})
end)
