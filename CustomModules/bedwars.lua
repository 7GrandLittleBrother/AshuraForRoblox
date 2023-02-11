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

local function isAlive(plr)
	if plr then
		return plr and plr.Character and plr.Character.Parent ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid")
	end
end

local function runcode(func)
	func()
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

local function targetCheck(plr, check)
	return (check and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("ForceField") == nil or check == false)
end

local function isPlayerTargetable(plr, target)
	return plr.Team ~= lplr.Team and plr and isAlive(plr) and targetCheck(plr, target)
end

local function GetAllNearestHumanoidToPosition(distance, amount)
	local returnedplayer = {}
	local currentamount = 0
	if isAlive(lplr) then -- alive check
		for i,v in pairs(game.Players:GetChildren()) do -- loop through players
			if isPlayerTargetable((v), true, true, v.Character ~= nil) and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") and currentamount < amount then -- checks
				local mag = (lplr.Character.HumanoidRootPart.Position - v.Character:FindFirstChild("HumanoidRootPart").Position).magnitude
				if mag <= distance then -- mag check
					table.insert(returnedplayer, v)
					currentamount = currentamount + 1
				end
			end
		end
		for i2,v2 in pairs(game:GetService("CollectionService"):GetTagged("Monster")) do -- monsters
			if v2:FindFirstChild("HumanoidRootPart") and currentamount < amount and v2.Name ~= "Duck" then -- no duck
				local mag = (lplr.Character.HumanoidRootPart.Position - v2.HumanoidRootPart.Position).magnitude
				if mag <= distance then -- magcheck
					table.insert(returnedplayer, {Name = (v2 and v2.Name or "Monster"), UserId = 1443379645, Character = v2}) -- monsters are npcs so I have to create a fake player for target info
					currentamount = currentamount + 1
				end
			end
		end
	end
	return returnedplayer -- table of attackable entities
end

local function playSound(id, volume) 
	local sound = Instance.new("Sound")
	sound.Parent = workspace
	sound.SoundId = id
	sound.PlayOnRemove = true 
	if volume then 
		sound.Volume = volume
	end
	sound:Destroy()
end

local function playAnimation(id) 
	if lplr.Character.Humanoid.Health > 0 then 
		local animation = Instance.new("Animation")
		animation.AnimationId = id
		local animatior = lplr.Character.Humanoid.Animator
		animatior:LoadAnimation(animation):Play()
	end
end

local function getCurrentSword()
	local sword, swordslot, swordrank = nil, nil, 0
	for i5, v5 in pairs(modules.getCurrentInventory().items) do
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
			if isAlive(lplr) then 
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
	["NoFall"] = Tabs["Blatant"].NewSection("NoFall"),
	["AntiVoid"] = Tabs["World"].NewSection("AntiVoid")
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
		["InfoText"] = "Remove knockbacks."
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
		["InfoText"] = "Bypass cps limit."
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
		["InfoText"] = "Set sprint to true."
	})
end)

runcode(function()
	local killauraswing = {["Enabled"] = false}
	local killaurasound = {["Enabled"] = false}
	local killaurarange = {["Value"] = 18}
	local Killaura = {["Enabled"] = false}
	local killauraremote = modules.ClientHandler:Get(modules.AttackRemote)
	local function attackEntity(plr)
		local root = plr.Character.HumanoidRootPart
		if not root then
			return nil
		end
		local selfrootpos = lplr.Character.HumanoidRootPart.Position
		local selfpos = selfrootpos + (killaurarange["Value"] > 14 and (selfrootpos - root.Position).magnitude > 14 and (CFrame.lookAt(selfrootpos, root.Position).lookVector * 4) or Vector3.zero)
		local sword = getCurrentSword()
		killauraremote:SendToServer({
			["weapon"] = sword ~= nil and sword.tool,
			["entityInstance"] = plr.Character,
			["validate"] = {
				["raycast"] = {
					["cameraPosition"] = hashvec(cam.CFrame.Position),
					["cursorDirection"] = hashvec(Ray.new(cam.CFrame.Position, root.CFrame.Position).Unit.Direction)
				},
				["targetPosition"] = hashvec(root.CFrame.Position),
				["selfPosition"] = hashvec(selfpos)
			},
			["chargedAttack"] = {["chargeRatio"] = 0}
		})
		if not Killauraswing["Enabled"] then
			if Killaura["Enabled"] then
				playAnimation("rbxassetid://4947108314")
			end
		end
		if not Killaurasound["Enabled"] then
			if Killaura["Enabled"] then
				playSound("rbxassetid://6760544639", 0.5)
			end
		end
	end
	Sections["Killaura"].NewToggle({
		["Name"] = "Killaura",
		["Function"] = function(callback)
			Killaura["Enabled"] = callback
			if Killaura["Enabled"] then
				RunLoops:BindToHeartbeat("Killaura", 1, function()
					local plrs = GetAllNearestHumanoidToPosition(killaurarange["Value"] - 0.0001, 1)
					for i,plr in pairs(plrs) do
						task.spawn(attackEntity, plr)
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("Killaura")
			end
		end,
		["InfoText"] = "Attack players/enemies that are near."
	})
	Sections["Killaura"].NewToggle({
		["Name"] = "No Swing Sound",
		["Function"] = function(val)
			killaurasound["Enabled"] = val
		end,
		["InfoText"] = "Removes the swinging sound."
	})
	Sections["Killaura"].NewToggle({
		["Name"] = " No Swing",
		["Function"] = function(val)
			killauraswing["Enabled"] = val
		end,
		["InfoText"] = "Removes the swinging animation."
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
						game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.GroundHit:FireServer()
					until (not NoFall["Enabled"])
				end)
			end
		end,
		["InfoText"] = "Prevents taking fall damage."
	})
end)

runcode(function()
	local antivoidpart
	local antivoidconnection
	local antivoiding = false
	local antitransparent = {["Value"] = 50}
	local anticolor = {["Hue"] = 1, ["Sat"] = 1, ["Value"] = 0.55}
	local AntiVoid = {["Enabled"] = false}
	Sections["AntiVoid"].NewToggle({
		["Name"] = "AntiVoid",
		["Function"] = function(callback)
			AntiVoid["Enabled"] = callback
			if AntiVoid["Enabled"] then
				task.spawn(function()
					antivoidpart = Instance.new("Part")
					antivoidpart.CanCollide = false
					antivoidpart.Size = Vector3.new(10000, 1, 10000)
					antivoidpart.Anchored = true
					antivoidpart.Material = Enum.Material.Neon
					antivoidpart.Color = Color3.fromHSV(anticolor["Hue"], anticolor["Sat"], anticolor["Value"])
					antivoidpart.Transparency = 1 - (antitransparent["Value"] / 100)
					antivoidpart.Position = lplr.Character.HumanoidRootPart.Position - Vector3.new(0, 21, 0)
					antivoidpart.Parent = workspace
					antivoidconnection = antivoidpart.Touched:Connect(function(touched)
						if touched.Parent == lplr.Character and isAlive(lplr) then
							if (not antivoiding) and lplr.Character.Humanoid.Health > 0 then
								antivoiding = true
								lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 125, 0)
								antivoiding = false
							end
						end
					end)
				end)
			else
			if antivoidconnection then antivoidconnection:Disconnect() end
				if antivoidpart then
					antivoidpart:Remove() 
				end
			end
		end,
		["InfoText"] = "Prevents falling in void"
	})
	Sections["AntiVoid"].NewSlider({
		["Name"] = "Invisible",
		["Min"] = 1,
		["Max"] = 100,
		["Default"] = 50,
		["Function"] = function(val)
			antitransparent["Value"] = val
			if antivoidpart then
				antivoidpart.Transparency = 1 - (antitransparent["Value"] / 100)
			end
		end
	})
	Sections["AntiVoid"].NewColorPicker({
		["Name"] = "Color",
		["Default"] = Color3.fromHSV(anticolor["Hue"], anticolor["Sat"], anticolor["Value"]),
		["Function"] = function(val)
			anticolor["Hue"], anticolor["Sat"], anticolor["Value"] = val
			if antivoidpart then
				antivoidpart.Color = Color3.fromHSV(anticolor["Hue"], anticolor["Sat"], anticolor["Value"])
			end
		end
	})
end)
