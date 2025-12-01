--BYW SCRIPT
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BYWMenu"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local btn = Instance.new("TextButton")
btn.Name = "BYWBtn"
btn.Size = UDim2.new(0, 40, 0, 40)
btn.Position = UDim2.new(0, 10, 0, 10)
btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
btn.TextColor3 = Color3.fromRGB(0, 0, 0)
btn.Text = "B"
btn.TextSize = 28
btn.Font = Enum.Font.GothamBold
btn.BorderSizePixel = 0
btn.Active = true
btn.Draggable = true
btn.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = btn

local invisible = false
local seat = nil
local cooldown = false
local teleportOffset = Vector3.new(0, 800, 0)
local noclip = false
local noclipConnection = nil
local function toggleNoClip(state)
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    noclip = state
    
    if state then
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            if game.Players.LocalPlayer.Character then
                for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
        end)
    else
        if game.Players.LocalPlayer.Character then
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
end

local function safeTeleport(character, cframe)
    if not character or not character.PrimaryPart then return false end
    
    local wasNoclip = noclip
    if wasNoclip then
        toggleNoClip(false)
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local wasAutoRotate = false
    
    if humanoid then
        wasAutoRotate = humanoid.AutoRotate
        humanoid.AutoRotate = false
    end
    
    character:SetPrimaryPartCFrame(cframe)
    
    task.wait(0.1)
    
    local success = (character.PrimaryPart.Position - cframe.Position).Magnitude < 5
    
    if humanoid then
        humanoid.AutoRotate = wasAutoRotate
    end
    
    if wasNoclip then
        task.wait(0.05)
        toggleNoClip(true)
    end
    
    return success
end

local function toggleInvisibility()
    if cooldown then return end
    cooldown = true
    
    invisible = not invisible
    
    if invisible then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local savedPos = hrp.CFrame  
            local teleportSuccess = safeTeleport(char, CFrame.new(savedPos.Position + teleportOffset))
            
            if not teleportSuccess then
                char:MoveTo((savedPos.Position + teleportOffset))
                task.wait(0.15)
            else
                task.wait(0.05)
            end
          
            if seat then
                seat:Destroy()
                seat = nil
            end
            
            seat = Instance.new("Seat")
            seat.Parent = workspace
            seat.Name = "InvisChair"
            seat.Transparency = 1
            seat.Anchored = false
            seat.CanCollide = false
            seat.CFrame = savedPos
            
            task.wait(0.01)
          
            local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            if torso then
                local weld = Instance.new("Weld")
                weld.Part0 = seat
                weld.Part1 = torso
                weld.C0 = CFrame.new()
                weld.C1 = CFrame.new()
                weld.Parent = seat
                weld.Enabled = true
            end
            
            safeTeleport(char, savedPos)
            toggleNoClip(true)
            task.wait(0.08)
            btn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end
    else
        if seat then
            seat:Destroy()
            seat = nil
        end
  
        toggleNoClip(false)
        
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end
    task.wait(0.2)
    cooldown = false
end

btn.MouseButton1Click:Connect(function()
    pcall(function()
        toggleInvisibility()
    end)
end)

btn.MouseButton1Down:Connect(function()
    btn.BackgroundColor3 = invisible and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 200, 200)
end)

btn.MouseButton1Up:Connect(function()
    task.wait(0.1)
    btn.BackgroundColor3 = invisible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if invisible then
        invisible = false
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        noclip = false
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

print("BYW SCRIPT loaded!")
