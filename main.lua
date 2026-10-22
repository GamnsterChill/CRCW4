-- [[ PROJECT: Classic Retro Craftwars - Elite Customizable Hub (v15.5) ]]
-- [[ ЧАСТЬ 4 ИЗ 4: Магниты с Заморозкой, Ротация, Полет и Финал ]]

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

local ComprehensiveOresList = {"Iron", "Gold", "Diamond", "Bluesteel", "Amberstone", "Crystal", "Viridis", "Vermite", "Ore Clump", "Ultimus", "Optimum", "Unobtanium", "Dankite", "Dark Matter", "Destinium", "Dankinite", "Uranium", "Plutonium", "Green Vermite", "Purple Vermite", "Regite", "Devumite", "Demonite", "Enchanted Iron", "Salt", "Hellstone", "Rainbonite", "Rolite", "Pure Vermite", "Pure Amberstone", "Chaotrum", "Black Vermite", "Black Iron", "Azure", "Uldragunn", "Onyx", "Serendibite", "Vantablack", "Voidite", "Uru", "Tanzanite", "Originite", "Pitcholamadamantinite"}

local function ExecuteInventoryManagement()
    if not _G.CheatConfig.AutoRotationActive then return end
    local backpack, character = player:FindFirstChild("Backpack"), player.Character
    if not backpack or not character then return end
    local currentTool = character:FindFirstChildOfClass("Tool")
    if not currentTool then
        local fb = backpack:FindFirstChild(_G.CheatConfig.MainFallbackTool)
        if fb then fb.Parent = character _G.FarmState.LastMode = _G.CheatConfig.MainFallbackTool return end
    end
    local phase = _G.CustomRotationSequence[_G.FarmState.CurrentPhaseIndex]
    if phase and _G.FarmState.LastMode ~= phase.Name then
        if not currentTool or currentTool.Name ~= phase.Name then
            local t = backpack:FindFirstChild(phase.Name)
            if t then _G.FarmState.LastMode = phase.Name if currentTool then currentTool.Parent = backpack end t.Parent = character end
        end
    end
end

local function ExecuteScheduledFly()
    if not _G.CheatConfig.ScheduledFlyActive then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local root = character.HumanoidRootPart
    local prompts = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do if obj:IsA("ProximityPrompt") then table.insert(prompts, obj) end end
    if #prompts == 0 then return end
    _G.FarmState.IsFlyingToButtons = true
    for _, p in ipairs(prompts) do
        if not _G.CheatConfig.ScheduledFlyActive then break end
        if p and p.Parent then
            pcall(function()
                local part = p.Parent:IsA("BasePart") and p.Parent or p.Parent:FindFirstChildOfClass("BasePart")
                if part then
                    root.CFrame = part.CFrame * CFrame.new(0, 2, 0)
                    task.wait(0.2)
                    if fireproximityprompt then fireproximityprompt(p) else p:InputHoldBegin() task.wait(p.HoldDuration + 0.05) p:InputHoldEnd() end
                    task.wait(0.15)
                end
            end)
        end
    end
    _G.FarmState.IsFlyingToButtons = false
end

local function ProcessWorldTriggers()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local root = character.HumanoidRootPart

    if _G.CheatConfig.AntiSitActive then
        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Sit then hum.Sit = false root.CFrame = root.CFrame * CFrame.new(0, 5, 0) end
    end
    if _G.CheatConfig.AutoClickTools then local tool = character:FindFirstChildOfClass("Tool") if tool then pcall(function() tool:Activate() end) end end

    if _G.CheatConfig.MagnetOres then
        for _, mine in ipairs(_G.CheatConfig.MineFolders) do
            local folder = Workspace:FindFirstChild(mine)
            if folder then
                for _, c in ipairs(folder:GetDescendants()) do
                    if c:IsA("Model") then
                        local match = false
                        for _, o in ipairs(ComprehensiveOresList) do if string.find(string.lower(c.Name), string.lower(o)) then match = true break end end
                        if c:FindFirstChild("Ore") or c:FindFirstChild("Block") or string.find(string.lower(c.Name), "ore") then match = true end
                        if match then
                            local part = c:FindFirstChildOfClass("Part") or c:FindFirstChildOfClass("MeshPart") or c:FindFirstChild("Ore") or c.PrimaryPart
                            if part then pcall(function() part.CanCollide = true part.Anchored = true part.Velocity = Vector3.new(0,0,0) part.CFrame = root.CFrame * CFrame.new(0, 0, -2) end) end
                        end
                    end
                end
            end
        end
    end

    if _G.CheatConfig.MagnetMobs then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and obj ~= character and obj:FindFirstChildOfClass("Humanoid") then
                local mRoot = obj:FindFirstChild("HumanoidRootPart")
                local mHum = obj:FindFirstChildOfClass("Humanoid")
                if mRoot and mHum and mHum.Health > 0 then
                    pcall(function()
                        mRoot.CFrame = root.CFrame * CFrame.new(0, 0, -((mRoot.Size.Z / 2) + 2))
                        mRoot.Anchored = true
                        mRoot.Velocity = Vector3.new(0,0,0)
                        mRoot.RotVelocity = Vector3.new(0,0,0)
                        mHum.PlatformStand = true
                    end)
                end
            end
        end
    end

    if _G.CheatConfig.AutoClickPrompts and not _G.FarmState.IsFlyingToButtons then
        for _, o in ipairs(Workspace:GetDescendants()) do if o:IsA("ProximityPrompt") then pcall(function() if fireproximityprompt then fireproximityprompt(o) else o:DoNow() end) end end
    end
end

RunService.Heartbeat:Connect(function()
    if _G.CheatConfig.MainFarmActive and not _G.FarmState.IsFlyingToButtons and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local cf = CFrame.new(_G.CheatConfig.TargetX, _G.CheatConfig.TargetY, _G.CheatConfig.TargetZ)
        player.Character.HumanoidRootPart.CFrame = _G.CheatConfig.SpinActive and cf * CFrame.Angles(0, math.rad(tick() * _G.CheatConfig.SpinSpeed * 100) % 360, 0) or cf
    end
    ExecuteInventoryManagement()
end)

RunService.RenderStepped:Connect(function() if _G.CheatConfig.ForceCameraActive and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then Workspace.CurrentCamera.CameraSubject = player.Character.HumanoidRootPart end end)

task.spawn(function()
    while true do
        if _G.CheatConfig.AutoRotationActive then
            local p = _G.CustomRotationSequence[_G.FarmState.CurrentPhaseIndex]
            task.wait(p and _G.CheatConfig[p.DurationKey] or 2)
            _G.FarmState.CurrentPhaseIndex = _G.FarmState.CurrentPhaseIndex + 1
            if _G.FarmState.CurrentPhaseIndex > #_G.CustomRotationSequence then _G.FarmState.CurrentPhaseIndex = 1 end
        else task.wait(1) end
    end
end)

task.spawn(function() while true do ProcessWorldTriggers() task.wait(_G.CheatConfig.TriggerDelay) end end)
task.spawn(function() while true do task.wait(_G.CheatConfig.ScheduledFlyInterval) if _G.CheatConfig.ScheduledFlyActive then ExecuteScheduledFly() end end end)
print("[Elite Hub v15.5]: Последняя 4-я часть успешно загружена. Всё готово к фарму!")
  
