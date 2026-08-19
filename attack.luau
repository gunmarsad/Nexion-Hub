local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
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

local function GetClosestPlayers()
    local playerPosition = LocalPlayer.Character
        and LocalPlayer.Character.PrimaryPart
        and LocalPlayer.Character.PrimaryPart.Position
    if not playerPosition then return nil end

    local validPlayers = {}

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local char     = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local primary  = char and char.PrimaryPart

        if humanoid and humanoid.Health > 0 and primary then
            local distance = (primary.Position - playerPosition).Magnitude
            if distance <= 100 then
                validPlayers[#validPlayers + 1] = {
                    mob      = char,
                    distance = distance,
                    player   = player,
                }
            end
        end
    end

    if #validPlayers == 0 then return nil end

    table.sort(validPlayers, function(a, b)
        return a.distance < b.distance
    end)

    return #validPlayers > 2 and { validPlayers[1], validPlayers[2] } or validPlayers
end

local function AttackPlayers()
    local targets = GetClosestPlayers()
    if not targets then return end

    local hitData = {}
    for _, target in pairs(targets) do
        local rootPart = target.mob:FindFirstChild("HumanoidRootPart")
        if rootPart then
            hitData[#hitData + 1] = { target.mob, rootPart }
        end
    end

    if #hitData > 0 then
        registerAttack:FireServer(0 / 0)
        coroutine.resume(registerHit, hitData[1][2], { table.unpack(hitData, 2) })
    end
end

return {
    Attack = Attack,
    AttackPlayers = AttackPlayers
}
