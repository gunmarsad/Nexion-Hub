local LocalPlayer = game:GetService("Players").LocalPlayer
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Net = Modules:FindFirstChild('Net')
local registerHit = debug.getupvalue(getrenv()._G.SendHitsToServer, 1)
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local registerAttack = ReplicatedStorage.Modules.Net["RE/RegisterAttack"]
local function GetClosestEnemies()
    local enemies = CollectionService:GetTagged("BasicMob")
    if #enemies == 0 then
        return nil
    end
    local validEnemies = {}
    local playerPosition = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart.Position
    if not playerPosition then
        return nil
    end
    for _, mob in pairs(enemies) do
        local humanoid = mob:FindFirstChildOfClass("Humanoid")
        local primaryPart = mob.PrimaryPart
        if humanoid and humanoid.Health > 0 and primaryPart then
            local distance = (primaryPart.Position - playerPosition).Magnitude
            if distance <= 100 then
                validEnemies[#validEnemies + 1] = {
                    mob = mob,
                    distance = distance,
                }
            end
        end
    end
    if #validEnemies == 0 then
        return nil
    end
    table.sort(validEnemies, function(a, b)
        return a.distance < b.distance
    end)
    return #validEnemies > 2 and { validEnemies[1], validEnemies[2] } or validEnemies
end

local function Attack()
    local enemies = GetClosestEnemies()
    if not enemies then
        return
    end
    local hitData = {}
    for _, enemy in pairs(enemies) do
        local rootPart = enemy.mob:FindFirstChild("HumanoidRootPart")
        if rootPart then
            hitData[#hitData + 1] = { enemy.mob, rootPart }
        end
    end
    if #hitData > 0 then
        registerAttack:FireServer(0 / 0)
        coroutine.resume(registerHit, hitData[1][2], { table.unpack(hitData, 2) })
    end
end
