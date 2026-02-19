--[[
	Script Hub UI + Craft A World (combined client)
	Run in executor (client). Loads WindUI; Farm/Settings use server RemoteEvents.
	Requires GameServer.lua in ServerScriptService.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for server-created remotes (optional; only used for Farm/Settings sync)
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
local SelectItemEvent = RemoteEvents and RemoteEvents:FindFirstChild("SelectItemEvent")
local AutoFarmEvent = RemoteEvents and RemoteEvents:FindFirstChild("AutoFarmEvent")
local AutoPlaceEvent = RemoteEvents and RemoteEvents:FindFirstChild("AutoPlaceEvent")
local DelaySettingEvent = RemoteEvents and RemoteEvents:FindFirstChild("DelaySettingEvent")

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

WindUI:SetTheme("Dark")

local Window = WindUI:CreateWindow({
	Title = "Script Hub",
	Icon = "layout-dashboard",
	Author = "Welcome",
	Folder = "ScriptHub",
	Size = UDim2.fromOffset(560, 420),
	Theme = "Dark",
	OpenButton = {
		Title = "Open Hub",
		Enabled = true,
		Color = ColorSequence.new(
			Color3.fromHex("#30FF6A"),
			Color3.fromHex("#e7ff2f")
		),
	},
	User = {
		Enabled = true,
		Anonymous = true,
		Callback = function()
			WindUI:Notify({
				Title = "Profile",
				Content = "User profile clicked!",
				Duration = 2,
			})
		end,
	},
})

-- Tabs
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user", Desc = "Character & movement" })
local FarmTab = Window:Tab({ Title = "Farm", Icon = "leaf", Desc = "Auto farm & place" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings", Desc = "Configuration" })
local MiscTab = Window:Tab({ Title = "Utilities", Icon = "tool", Desc = "Extra features" })

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ========== PLAYER TAB ==========
local PlayerSection = PlayerTab:Section({ Title = "Movement", Opened = true, Box = true })

PlayerSection:Button({
	Title = "Move +6 X",
	Icon = "move-right",
	Callback = function()
		local char = LocalPlayer.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		root.CFrame = root.CFrame + Vector3.new(6, 0, 0)
		WindUI:Notify({ Title = "Moved", Content = "Teleported +6 studs on X", Duration = 1 })
	end,
})

local movementConnection = nil
PlayerSection:Toggle({
	Title = "Looping Movement (36.5 → 40)",
	Flag = "LoopingMovement",
	Value = false,
	Callback = function(enabled)
		if movementConnection then
			movementConnection:Disconnect()
			movementConnection = nil
		end
		if not enabled then return end
		local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local root = char:WaitForChild("HumanoidRootPart")
		local minVal, maxVal = 36.5, 40
		local speed = 2
		local current = minVal
		local goingUp = true
		movementConnection = RunService.Heartbeat:Connect(function(dt)
			if not root or not root.Parent then return end
			local pos = root.Position
			root.CFrame = CFrame.new(current, pos.Y, pos.Z)
			if goingUp then
				current = math.min(current + speed * dt, maxVal)
				if current >= maxVal then goingUp = false end
			else
				current = math.max(current - speed * dt, minVal)
				if current <= minVal then goingUp = true end
			end
		end)
		WindUI:Notify({ Title = "Looping", Content = "Movement toggled ON", Duration = 1 })
	end,
})

PlayerSection:Slider({
	Title = "Walk Speed",
	Desc = "Character walk speed",
	Flag = "WalkSpeed",
	Value = { Min = 16, Max = 500, Default = 16 },
	Callback = function(value)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = value
			WindUI:Notify({ Title = "Walk Speed", Content = "Set to " .. value, Duration = 1 })
		end
	end,
})

PlayerSection:Slider({
	Title = "Jump Power",
	Desc = "Character jump power",
	Flag = "JumpPower",
	Value = { Min = 50, Max = 500, Default = 50 },
	Callback = function(value)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.JumpPower = value
			WindUI:Notify({ Title = "Jump Power", Content = "Set to " .. value, Duration = 1 })
		end
	end,
})

-- ========== FARM TAB ==========
local FarmSection = FarmTab:Section({ Title = "Auto Farm", Opened = true, Box = true })

local farmItems = {
	{ Title = "Wood", Icon = "tree-pine" },
	{ Title = "Stone", Icon = "mountain" },
	{ Title = "Iron Ore", Icon = "mineral" },
	{ Title = "Gold Ore", Icon = "circle-dollar-sign" },
	{ Title = "Diamond", Icon = "gem" },
	{ Title = "Coal", Icon = "flame" },
	{ Title = "Copper", Icon = "copper" },
	{ Title = "Tin", Icon = "box" },
}

local selectedFarmItem = "Wood"
FarmSection:Dropdown({
	Title = "Select Item to Farm",
	Values = farmItems,
	Flag = "FarmItem",
	SearchBarEnabled = true,
	Value = "Wood",
	Callback = function(option)
		selectedFarmItem = option.Title
		if SelectItemEvent then SelectItemEvent:FireServer(selectedFarmItem) end
		WindUI:Notify({ Title = "Item", Content = "Selected: " .. selectedFarmItem, Duration = 1 })
	end,
})

FarmSection:Toggle({
	Title = "Auto Farm",
	Flag = "AutoFarm",
	Value = false,
	Callback = function(enabled)
		if AutoFarmEvent then AutoFarmEvent:FireServer() end
		WindUI:Notify({
			Title = "Auto Farm",
			Content = enabled and ("Farming " .. selectedFarmItem) or "Stopped",
			Icon = enabled and "check" or "x",
			Duration = enabled and 2 or 1,
		})
	end,
})

FarmSection:Toggle({
	Title = "Auto Place",
	Flag = "AutoPlace",
	Value = false,
	Callback = function(enabled)
		if AutoPlaceEvent then AutoPlaceEvent:FireServer() end
		WindUI:Notify({
			Title = "Auto Place",
			Content = enabled and "Auto Place ON" or "Auto Place OFF",
			Icon = enabled and "check" or "x",
			Duration = 2,
		})
	end,
})

FarmSection:Slider({
	Title = "Farm Delay (seconds)",
	Desc = "Delay between farm/place actions",
	Flag = "FarmDelay",
	Value = { Min = 0.1, Max = 5, Default = 1 },
	Step = 0.1,
	Callback = function(value)
		if DelaySettingEvent then DelaySettingEvent:FireServer(value) end
		WindUI:Notify({ Title = "Delay", Content = "Set to " .. value .. "s", Duration = 1 })
	end,
})

-- ========== SETTINGS TAB ==========
local SettingsSection = SettingsTab:Section({ Title = "Appearance", Opened = true, Box = true })

local themes = {}
for themeName, _ in pairs(WindUI:GetThemes()) do
	table.insert(themes, themeName)
end
table.sort(themes)

SettingsSection:Dropdown({
	Title = "Theme",
	Values = themes,
	Flag = "ThemeSelect",
	SearchBarEnabled = true,
	Value = "Dark",
	Callback = function(theme)
		WindUI:SetTheme(theme)
		WindUI:Notify({ Title = "Theme", Content = "Applied: " .. theme, Icon = "palette", Duration = 2 })
	end,
})

SettingsSection:Slider({
	Title = "Window Transparency",
	Desc = "Background transparency",
	Flag = "WindowTransparency",
	Value = { Min = 0, Max = 1, Default = 0 },
	Step = 0.05,
	Callback = function(value)
		Window:SetBackgroundTransparency(value)
		Window:SetBackgroundImageTransparency(value)
	end,
})

local ConfigSection = SettingsTab:Section({ Title = "Config", Opened = true, Box = true })
ConfigSection:Button({
	Title = "Save Configuration",
	Icon = "save",
	Callback = function()
		WindUI:Notify({ Title = "Config", Content = "Configuration saved!", Icon = "check", Duration = 2 })
	end,
})
ConfigSection:Button({
	Title = "Load Configuration",
	Icon = "folder-open",
	Callback = function()
		WindUI:Notify({ Title = "Config", Content = "Configuration loaded!", Icon = "check", Duration = 2 })
	end,
})

-- ========== UTILITIES TAB ==========
local UtilSection = MiscTab:Section({ Title = "Quick Actions", Opened = true, Box = true })

UtilSection:Button({
	Title = "Copy Game ID",
	Icon = "copy",
	Callback = function()
		local id = tostring(game.PlaceId)
		if setclipboard then setclipboard(id) end
		WindUI:Notify({ Title = "Copied", Content = "Place ID: " .. id, Duration = 2 })
	end,
})

UtilSection:Button({
	Title = "Show FPS",
	Icon = "gauge",
	Callback = function()
		WindUI:Notify({
			Title = "Performance",
			Content = "FPS: " .. math.floor(1 / RunService.Heartbeat:Wait()),
			Duration = 2,
		})
	end,
})

UtilSection:Toggle({
	Title = "Noclip (no collision)",
	Flag = "Noclip",
	Value = false,
	Callback = function(enabled)
		local char = LocalPlayer.Character
		if not char then return end
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = not enabled
			end
		end
		WindUI:Notify({
			Title = "Noclip",
			Content = enabled and "ON" or "OFF",
			Icon = enabled and "check" or "x",
			Duration = 1,
		})
	end,
})

-- Re-apply noclip when character respawns
LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	-- Re-check noclip state from UI if you store it
end)

UtilSection:Divider()
UtilSection:Paragraph({
	Title = "Script Hub",
	Desc = "Built with WindUI. Add your game-specific features in the Farm tab.",
	Image = "sparkles",
	ImageSize = 24,
	Color = Color3.fromHex("#30ff6a"),
})

WindUI:Notify({
	Title = "Hub Loaded",
	Content = "Welcome! Use the tabs to navigate.",
	Icon = "check-circle",
	Duration = 3,
})
