--[[
	Place in ServerScriptService.
	Creates RemoteEvents and handles Farm/Place/Delay from client UI.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Data folder
local DataFolder = Instance.new("Folder")
DataFolder.Name = "GameData"
DataFolder.Parent = ServerStorage

-- Remote Events (client UI will fire these)
local RemoteEvents = Instance.new("Folder")
RemoteEvents.Name = "RemoteEvents"
RemoteEvents.Parent = ReplicatedStorage

local SelectItemEvent = Instance.new("RemoteEvent")
SelectItemEvent.Name = "SelectItemEvent"
SelectItemEvent.Parent = RemoteEvents

local AutoPlaceEvent = Instance.new("RemoteEvent")
AutoPlaceEvent.Name = "AutoPlaceEvent"
AutoPlaceEvent.Parent = RemoteEvents

local AutoFarmEvent = Instance.new("RemoteEvent")
AutoFarmEvent.Name = "AutoFarmEvent"
AutoFarmEvent.Parent = RemoteEvents

local DelaySettingEvent = Instance.new("RemoteEvent")
DelaySettingEvent.Name = "DelaySettingEvent"
DelaySettingEvent.Parent = RemoteEvents

local playerData = {}

local function ensurePlayerData(plr)
	if not playerData[plr] then
		playerData[plr] = {
			selectedItem = "Wood",
			autoFarmActive = false,
			autoPlaceActive = false,
			farmDelay = 1.0,
		}
	end
	return playerData[plr]
end

-- Connect each remote once; use plr to index playerData
SelectItemEvent.OnServerEvent:Connect(function(plr, itemName)
	local data = ensurePlayerData(plr)
	data.selectedItem = itemName or "Wood"
	print(plr.Name .. " selected item: " .. data.selectedItem)
end)

AutoFarmEvent.OnServerEvent:Connect(function(plr)
	local data = ensurePlayerData(plr)
	data.autoFarmActive = not data.autoFarmActive
	print(plr.Name .. " toggled auto farm to: " .. tostring(data.autoFarmActive))

	if data.autoFarmActive then
		task.spawn(function()
			while playerData[plr] and playerData[plr].autoFarmActive do
				print(plr.Name .. " is farming " .. (data.selectedItem or "Wood"))
				task.wait(data.farmDelay or 1)
			end
		end)
	end
end)

AutoPlaceEvent.OnServerEvent:Connect(function(plr)
	local data = ensurePlayerData(plr)
	data.autoPlaceActive = not data.autoPlaceActive
	print(plr.Name .. " toggled auto place to: " .. tostring(data.autoPlaceActive))

	if data.autoPlaceActive then
		task.spawn(function()
			while playerData[plr] and playerData[plr].autoPlaceActive do
				print(plr.Name .. " is placing " .. (data.selectedItem or "Wood"))
				task.wait(data.farmDelay or 1)
			end
		end)
	end
end)

DelaySettingEvent.OnServerEvent:Connect(function(plr, delay)
	local data = ensurePlayerData(plr)
	if type(delay) == "number" and delay >= 0.1 then
		data.farmDelay = delay
		print(plr.Name .. " set delay to: " .. delay)
	end
end)

Players.PlayerAdded:Connect(function(player)
	ensurePlayerData(player)
end)

Players.PlayerRemoving:Connect(function(player)
	playerData[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
	ensurePlayerData(player)
end

print("Craft A World server loaded (use Script Hub UI on client).")
