--[[
	Credits:
	Vape - Disguise Character
]]
local lib = shared.GuiLibrary

local players = game:GetService("Players")
local lplr = players.LocalPlayer
local cam = game:GetService("Workspace").CurrentCamera
local KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
local Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
local modules = {}

local function hashvec(vec)
	return {
		value = vec
	}
end

local function getremote(tab)
	for i,v in pairs(tab) do
		if v == "Client" then
			return tab[i + 1]
		end
	end
	return ""
end

modules = {
	AttackRemote = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.SwordController)["attackEntity"])),
	ItemMeta = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta, 1),
	KnockbackUtil = require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil,
	SprintCont = KnitClient.Controllers.SprintController,
	SwordController = KnitClient.Controllers.SwordController
}

local inventory = {
	["items"] = {},
	["armor"] = {},
	["hand"] = nil
}

local function runcode(func)
	func()
end

local function getCurrentSword()
	local sword, swordslot, swordrank = nil, nil, 0
	for i5, v5 in pairs(inventory.items) do
		if v5.itemType:lower():find("sword") or v5.itemType:lower():find("blade") or v5.itemType:lower():find("dao") then
			if modules.ItemMeta[v5.itemType].sword.damage > swordrank then
				sword = v5
				swordslot = i5
				swordrank = modules.ItemMeta[v5.itemType].sword.damage
			end
		end
	end
end

task.spawn(function()
	for i,v in pairs(game:GetService("Lighting"):GetChildren()) do
		if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
			v:Remove()
		end
	end
	local Sky = Instance.new("Sky")
	Sky.SkyboxUp = "rbxassetid://12256126435"
	Sky.SkyboxLf = "rbxassetid://12256091030"
	Sky.SkyboxBk = "rbxassetid://12256034686"
	Sky.SkyboxFt = "rbxassetid://12256077178"
	Sky.SkyboxDn = "rbxassetid://12256053605"
	Sky.SkyboxRt = "rbxassetid://12256116644"
	Sky.Parent = game:GetService("Lighting")

	local Blur = Instance.new("BlurEffect")
	Blur.Size = 4
	Blur.Parent = game:GetService("Lighting")
end)

local win = lib:CreateWindow({
	["Name"] = "AshuraV1",
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
	["KillAura"] = Tabs["Blatant"].NewSection("KillAura")
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
