-- Letakkan script ini di ServerScriptService

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Buat folder untuk menyimpan data
local DataFolder = Instance.new("Folder")
DataFolder.Name = "GameData"
DataFolder.Parent = ServerStorage

-- Buat Remote Events
local RemoteEvents = Instance.new("Folder")
RemoteEvents.Name = "RemoteEvents"
RemoteEvents.Parent = ReplicatedStorage

-- Farm Panel Remote
local FarmPanelEvent = Instance.new("RemoteEvent")
FarmPanelEvent.Name = "FarmPanelEvent"
FarmPanelEvent.Parent = RemoteEvents

-- Select Item Remote
local SelectItemEvent = Instance.new("RemoteEvent")
SelectItemEvent.Name = "SelectItemEvent"
SelectItemEvent.Parent = RemoteEvents

-- Auto Place Remote
local AutoPlaceEvent = Instance.new("RemoteEvent")
AutoPlaceEvent.Name = "AutoPlaceEvent"
AutoPlaceEvent.Parent = RemoteEvents

-- Auto Farm Remote
local AutoFarmEvent = Instance.new("RemoteEvent")
AutoFarmEvent.Name = "AutoFarmEvent"
AutoFarmEvent.Parent = RemoteEvents

-- Delay Setting Remote
local DelaySettingEvent = Instance.new("RemoteEvent")
DelaySettingEvent.Name = "DelaySettingEvent"
DelaySettingEvent.Parent = RemoteEvents

-- Data untuk setiap player
local playerData = {}

-- Fungsi untuk membuat GUI Player
local function createPlayerGUI(player)
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Main GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CraftAWorldGUI"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    
    -- Frame Utama
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 500)
    mainFrame.Position = UDim2.new(0, 50, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(255, 170, 0)
    mainFrame.Parent = screenGui
    
    -- Judul
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleLabel.Text = "CRAFT A WORLD"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    -- Tab Selection
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = "TabFrame"
    tabFrame.Size = UDim2.new(1, 0, 0, 40)
    tabFrame.Position = UDim2.new(0, 0, 0, 40)
    tabFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabFrame.Parent = mainFrame
    
    -- Farm Panel Tab
    local farmTab = Instance.new("TextButton")
    farmTab.Name = "FarmTab"
    farmTab.Size = UDim2.new(0.5, -2, 1, -4)
    farmTab.Position = UDim2.new(0, 2, 0, 2)
    farmTab.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    farmTab.Text = "FARM PANEL"
    farmTab.TextColor3 = Color3.fromRGB(0, 0, 0)
    farmTab.TextScaled = true
    farmTab.Font = Enum.Font.GothamBold
    farmTab.Parent = tabFrame
    
    -- Settings Tab
    local settingsTab = Instance.new("TextButton")
    settingsTab.Name = "SettingsTab"
    settingsTab.Size = UDim2.new(0.5, -2, 1, -4)
    settingsTab.Position = UDim2.new(0.5, 2, 0, 2)
    settingsTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    settingsTab.Text = "SETTINGS"
    settingsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsTab.TextScaled = true
    settingsTab.Font = Enum.Font.GothamBold
    settingsTab.Parent = tabFrame
    
    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -10, 1, -90)
    contentFrame.Position = UDim2.new(0, 5, 0, 85)
    contentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    contentFrame.BackgroundTransparency = 0.2
    contentFrame.Parent = mainFrame
    
    -- Farm Panel Content
    local farmContent = Instance.new("Frame")
    farmContent.Name = "FarmContent"
    farmContent.Size = UDim2.new(1, 0, 1, 0)
    farmContent.BackgroundTransparency = 1
    farmContent.Visible = true
    farmContent.Parent = contentFrame
    
    -- Settings Content
    local settingsContent = Instance.new("Frame")
    settingsContent.Name = "SettingsContent"
    settingsContent.Size = UDim2.new(1, 0, 1, 0)
    settingsContent.BackgroundTransparency = 1
    settingsContent.Visible = false
    settingsContent.Parent = contentFrame
    
    -- === FARM PANEL CONTENT ===
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -10, 0, 30)
    statusLabel.Position = UDim2.new(0, 5, 0, 5)
    statusLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    statusLabel.Text = "Status: Farm Panel OFF"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = farmContent
    
    -- Item Selection Label
    local itemLabel = Instance.new("TextLabel")
    itemLabel.Name = "ItemLabel"
    itemLabel.Size = UDim2.new(1, -10, 0, 30)
    itemLabel.Position = UDim2.new(0, 5, 0, 40)
    itemLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    itemLabel.Text = "Selected Item: None"
    itemLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    itemLabel.TextScaled = true
    itemLabel.Font = Enum.Font.Gotham
    itemLabel.Parent = farmContent
    
    -- Listbox for Items
    local itemList = Instance.new("ScrollingFrame")
    itemList.Name = "ItemList"
    itemList.Size = UDim2.new(1, -10, 0, 150)
    itemList.Position = UDim2.new(0, 5, 0, 75)
    itemList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    itemList.CanvasSize = UDim2.new(0, 0, 0, 0)
    itemList.Parent = farmContent
    
    -- Item List Layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = itemList
    listLayout.Padding = UDim.new(0, 2)
    
    -- Add sample items (sesuaikan dengan item di game Anda)
    local items = {"Wood", "Stone", "Iron Ore", "Gold Ore", "Diamond", "Coal", "Copper", "Tin"}
    
    for _, itemName in ipairs(items) do
        local itemButton = Instance.new("TextButton")
        itemButton.Name = itemName .. "Button"
        itemButton.Size = UDim2.new(1, -10, 0, 30)
        itemButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        itemButton.Text = itemName
        itemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        itemButton.TextScaled = true
        itemButton.Font = Enum.Font.Gotham
        itemButton.Parent = itemList
        itemButton.MouseButton1Click:Connect(function()
            SelectItemEvent:FireServer(player, itemName)
        end)
    end
    
    itemList.CanvasSize = UDim2.new(0, 0, 0, #items * 32)
    
    -- Auto Farm Toggle Button
    local autoFarmButton = Instance.new("TextButton")
    autoFarmButton.Name = "AutoFarmButton"
    autoFarmButton.Size = UDim2.new(1, -10, 0, 40)
    autoFarmButton.Position = UDim2.new(0, 5, 0, 230)
    autoFarmButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    autoFarmButton.Text = "START AUTO FARM"
    autoFarmButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    autoFarmButton.TextScaled = true
    autoFarmButton.Font = Enum.Font.GothamBold
    autoFarmButton.Parent = farmContent
    autoFarmButton.MouseButton1Click:Connect(function()
        AutoFarmEvent:FireServer(player)
    end)
    
    -- Auto Place Toggle Button
    local autoPlaceButton = Instance.new("TextButton")
    autoPlaceButton.Name = "AutoPlaceButton"
    autoPlaceButton.Size = UDim2.new(1, -10, 0, 40)
    autoPlaceButton.Position = UDim2.new(0, 5, 0, 275)
    autoPlaceButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    autoPlaceButton.Text = "START AUTO PLACE"
    autoPlaceButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    autoPlaceButton.TextScaled = true
    autoPlaceButton.Font = Enum.Font.GothamBold
    autoPlaceButton.Parent = farmContent
    autoPlaceButton.MouseButton1Click:Connect(function()
        AutoPlaceEvent:FireServer(player)
    end)
    
    -- === SETTINGS CONTENT ===
    
    -- Delay Setting Label
    local delayLabel = Instance.new("TextLabel")
    delayLabel.Name = "DelayLabel"
    delayLabel.Size = UDim2.new(1, -10, 0, 30)
    delayLabel.Position = UDim2.new(0, 5, 0, 5)
    delayLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    delayLabel.Text = "Farm Delay: 1.0 seconds"
    delayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    delayLabel.TextScaled = true
    delayLabel.Font = Enum.Font.Gotham
    delayLabel.Parent = settingsContent
    
    -- Delay Slider
    local delaySlider = Instance.new("Frame")
    delaySlider.Name = "DelaySlider"
    delaySlider.Size = UDim2.new(1, -20, 0, 30)
    delaySlider.Position = UDim2.new(0, 10, 0, 40)
    delaySlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    delaySlider.Parent = settingsContent
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Name = "SliderButton"
    sliderButton.Size = UDim2.new(0, 20, 1, 0)
    sliderButton.Position = UDim2.new(0.5, -10, 0, 0)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    sliderButton.Text = ""
    sliderButton.Parent = delaySlider
    
    local delayValue = Instance.new("TextLabel")
    delayValue.Name = "DelayValue"
    delayValue.Size = UDim2.new(0, 50, 1, 0)
    delayValue.Position = UDim2.new(1, -55, 0, 0)
    delayValue.BackgroundTransparency = 1
    delayValue.Text = "1.0s"
    delayValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    delayValue.TextScaled = true
    delayValue.Font = Enum.Font.Gotham
    delayValue.Parent = delaySlider
    
    -- Delay Input Box
    local delayInput = Instance.new("TextBox")
    delayInput.Name = "DelayInput"
    delayInput.Size = UDim2.new(0.5, -10, 0, 30)
    delayInput.Position = UDim2.new(0.25, 5, 0, 75)
    delayInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    delayInput.PlaceholderText = "Enter delay (seconds)"
    delayInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    delayInput.Text = "1.0"
    delayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    delayInput.TextScaled = true
    delayInput.Font = Enum.Font.Gotham
    delayInput.Parent = settingsContent
    
    -- Apply Delay Button
    local applyDelayButton = Instance.new("TextButton")
    applyDelayButton.Name = "ApplyDelayButton"
    applyDelayButton.Size = UDim2.new(0.5, -10, 0, 30)
    applyDelayButton.Position = UDim2.new(0.25, 5, 0, 110)
    applyDelayButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    applyDelayButton.Text = "APPLY DELAY"
    applyDelayButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    applyDelayButton.TextScaled = true
    applyDelayButton.Font = Enum.Font.GothamBold
    applyDelayButton.Parent = settingsContent
    applyDelayButton.MouseButton1Click:Connect(function()
        local delay = tonumber(delayInput.Text)
        if delay and delay >= 0.1 then
            DelaySettingEvent:FireServer(player, delay)
        else
            delayInput.Text = "1.0"
        end
    end)
    
    -- Tab switching functionality
    farmTab.MouseButton1Click:Connect(function()
        farmTab.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        settingsTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        farmContent.Visible = true
        settingsContent.Visible = false
    end)
    
    settingsTab.MouseButton1Click:Connect(function()
        settingsTab.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        farmTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        farmContent.Visible = false
        settingsContent.Visible = true
    end)
    
    -- Slider dragging functionality
    local dragging = false
    local function updateSlider(input)
        local pos = input.Position.X
        local sliderFrame = delaySlider.AbsolutePosition
        local sliderSize = delaySlider.AbsoluteSize.X
        local relativePos = math.clamp(pos - sliderFrame.X, 0, sliderSize - 20)
        sliderButton.Position = UDim2.new(0, relativePos, 0, 0)
        local value = (relativePos / (sliderSize - 20)) * 4.9 + 0.1
        value = math.round(value * 10) / 10
        delayValue.Text = tostring(value) .. "s"
        delayInput.Text = tostring(value)
        DelaySettingEvent:FireServer(player, value)
    end
    
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    return screenGui
end

-- Player Added Handler
local function onPlayerAdded(player)
    playerData[player] = {
        selectedItem = "Wood",
        autoFarmActive = false,
        autoPlaceActive = false,
        farmDelay = 1.0
    }
    
    -- Create GUI for player
    local success, result = pcall(function()
        return createPlayerGUI(player)
    end)
    
    if not success then
        warn("Error creating GUI for player: " .. result)
    end
    
    -- Setup remote event handlers
    FarmPanelEvent.OnServerEvent:Connect(function(plr)
        if plr ~= player then return end
        -- Toggle farm panel functionality
        playerData[player].farmPanelActive = not playerData[player].farmPanelActive
        print(player.Name .. " toggled farm panel to: " .. tostring(playerData[player].farmPanelActive))
    end)
    
    SelectItemEvent.OnServerEvent:Connect(function(plr, itemName)
        if plr ~= player then return end
        playerData[player].selectedItem = itemName
        print(player.Name .. " selected item: " .. itemName)
    end)
    
    AutoFarmEvent.OnServerEvent:Connect(function(plr)
        if plr ~= player then return end
        playerData[player].autoFarmActive = not playerData[player].autoFarmActive
        print(player.Name .. " toggled auto farm to: " .. tostring(playerData[player].autoFarmActive))
        
        if playerData[player].autoFarmActive then
            -- Start auto farming coroutine
            coroutine.wrap(function()
                while playerData[player] and playerData[player].autoFarmActive do
                    -- Simulate farming
                    print(player.Name .. " is farming " .. playerData[player].selectedItem)
                    wait(playerData[player].farmDelay)
                end
            end)()
        end
    end)
    
    AutoPlaceEvent.OnServerEvent:Connect(function(plr)
        if plr ~= player then return end
        playerData[player].autoPlaceActive = not playerData[player].autoPlaceActive
        print(player.Name .. " toggled auto place to: " .. tostring(playerData[player].autoPlaceActive))
        
        if playerData[player].autoPlaceActive then
            -- Start auto placing coroutine
            coroutine.wrap(function()
                while playerData[player] and playerData[player].autoPlaceActive do
                    -- Simulate placing items
                    print(player.Name .. " is placing " .. playerData[player].selectedItem)
                    wait(playerData[player].farmDelay)
                end
            end)()
        end
    end)
    
    DelaySettingEvent.OnServerEvent:Connect(function(plr, delay)
        if plr ~= player then return end
        playerData[player].farmDelay = delay
        print(player.Name .. " set delay to: " .. delay)
    end)
end

-- Player Removed Handler
local function onPlayerRemoving(player)
    playerData[player] = nil
end

-- Connect events
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Give hub to players already in game (e.g. when script is executed after join)
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(onPlayerAdded, player)
end

print("Craft A World script loaded successfully!")