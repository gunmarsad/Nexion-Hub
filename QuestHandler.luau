local replicatedstorage = game:GetService("ReplicatedStorage")
local localplayer = game.Players.LocalPlayer
local Player_Data = localplayer:WaitForChild("Data")
local WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local placeId = game.PlaceId
if placeId == 2753915549 or placeId == 85211729168715 then
	FirstSea = true
elseif placeId == 4442272183 or placeId == 79091703265657  then
	SecondSea = true
elseif placeId == 7449423635 or placeId == 100117331123089 then
	ThirdSea = true
end

SeaIndex = ThirdSea and 3 or SecondSea and 2 or FirstSea and 1 or localplayer:Kick("Invalid Place ID")

repeat wait() until replicatedstorage:FindFirstChild("GuideModule") and replicatedstorage:FindFirstChild("Quests")
repeat wait() until Player_Data.Level

local Farm = {}
local QuestHandler = {}

wait(2)

-- Checkquest Globals Variables
QuestHandler.Guide = require(replicatedstorage.GuideModule)
QuestHandler.AllQuests = require(replicatedstorage.Quests)
QuestHandler.QuestAssignments = {}
QuestHandler.BagNumber = {} 
QuestHandler.QuestData = {
	[1] = nil,
	[2] = nil,
}
QuestHandler.CountCheck = 0 

-- Checkquest Functions

QuestHandler.GetAllQuests = function()
	local QuestData  = {}

	for questIndex, questDetails in pairs(QuestHandler.AllQuests) do
		QuestData[questIndex] = {
			ID = questIndex,
			Info = questDetails
		}
	end
	return QuestData 
end

QuestHandler.DetermineLevelRequirements = function()
	local LevelRequirements = {}

	for _, quest in pairs(QuestHandler.GetAllQuests()) do
		for _, details in pairs(quest.Info) do
			table.insert(LevelRequirements, details.LevelReq)
		end
	end

	local PlayerLevel
	if not QuestHandler.CustomLevel then
		PlayerLevel = Player_Data.Level.Value
	else
		PlayerLevel = QuestHandler.CustomLevel
	end

	local can_go_to_submerge = ThirdSea and game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/SubmarineWorkerSpeak"):InvokeServer("AskKilledTikiBoss") ~= false
	
	-- Adjust PlayerLevel for specific ranges

	if PlayerLevel >= 325 and PlayerLevel < 375 then
		PlayerLevel = 325
	elseif FirstSea and PlayerLevel > 675 then
		PlayerLevel = 650
	elseif SecondSea then
		if PlayerLevel > 850 and PlayerLevel < 875 then
			PlayerLevel = 800
		elseif PlayerLevel > 1450 then
			PlayerLevel = 1450
		end
	elseif PlayerLevel >= 1550 and PlayerLevel < 1575 then
		PlayerLevel = 1525
	elseif PlayerLevel >= 2700 and can_go_to_submerge then
		PlayerLevel = 2700
	elseif PlayerLevel >= 2575 and not can_go_to_submerge then
		PlayerLevel = 2575
	elseif PlayerLevel >= 210 and PlayerLevel < 250 then
		PlayerLevel = 210
	elseif PlayerLevel >= 100 and PlayerLevel < 120 then
		PlayerLevel = 100
	elseif PlayerLevel >= 250 and PlayerLevel < 300 then
		PlayerLevel = 250
	end

	-- print(PlayerLevel)

	-- Sort LevelRequirements
	table.sort(LevelRequirements)

	local PrimaryQuest, SecondaryQuest, TertiaryQuest

	for i, levelRequirement in pairs(LevelRequirements) do
		if PlayerLevel == levelRequirement then
			PrimaryQuest = LevelRequirements[i]
			if Double_Quest then
				SecondaryQuest = LevelRequirements[i - 1]
				TertiaryQuest = LevelRequirements[i - 2]
			end
			break
		elseif PlayerLevel < levelRequirement then
			PrimaryQuest = LevelRequirements[i - 1]
			if Double_Quest then
				SecondaryQuest = LevelRequirements[i - 2]
				TertiaryQuest = LevelRequirements[i - 3]
			end
			break
		end
	end

	QuestHandler.QuestAssignments = {
		[1] = PrimaryQuest,
		[2] = SecondaryQuest or nil,
	}

	if (PlayerLevel >= 400 and PlayerLevel < 625) or (PlayerLevel > 700 and PlayerLevel <= 1450) then
		QuestHandler.QuestAssignments = {
			[1] = PrimaryQuest,
			[2] = SecondaryQuest or nil,
			[3] = TertiaryQuest,
		}
	end

	-- Specific conditions for quest assignment
	if 
		(PlayerLevel > 90 and PlayerLevel < 100) or
		(PlayerLevel > 190 and PlayerLevel < 210) or
		(PlayerLevel > 300 and PlayerLevel < 325) or
		(PlayerLevel >= 950 and PlayerLevel < 975) or
		(PlayerLevel > 1000 and PlayerLevel < 1050) or
		(PlayerLevel > 1100 and PlayerLevel < 1125) or
		(PlayerLevel > 1250 and PlayerLevel < 1275) or
		(PlayerLevel > 1350 and PlayerLevel < 1375) or
		(PlayerLevel > 1425 and PlayerLevel < 1450) or
		(PlayerLevel > 1575 and PlayerLevel < 1600) or
		(PlayerLevel > 1625 and PlayerLevel < 1650) or
		(PlayerLevel > 1700 and PlayerLevel < 1725) or
		(PlayerLevel > 1775 and PlayerLevel < 1800) or
		(PlayerLevel > 1825 and PlayerLevel < 1850) or
		(PlayerLevel > 1900 and PlayerLevel < 1925) or
		(PlayerLevel > 1975 and PlayerLevel < 2000) or
		(PlayerLevel > 2025 and PlayerLevel < 2050) or
		(PlayerLevel > 2075 and PlayerLevel < 2100) or
		(PlayerLevel > 2125 and PlayerLevel < 2150) or
		(PlayerLevel > 2200 and PlayerLevel < 2225) or
		(PlayerLevel > 2250 and PlayerLevel < 2275) or
		(PlayerLevel > 2300 and PlayerLevel < 2325) or
		(PlayerLevel > 2350 and PlayerLevel < 2400) or
		(PlayerLevel > 2450 and PlayerLevel < 2475) then
		QuestHandler.QuestAssignments = {
			[1] = PrimaryQuest,
			[2] = nil,
			[3] = nil,
		}
	end

	return PrimaryQuest
end

QuestHandler.DetermineLevelRequirements()

QuestHandler.CheckBossLevel = function(bossData)
	local indexList = {}
	local dataIndex = {}

	-- Collect and sort indices
	for key, _ in pairs(bossData) do
		table.insert(indexList, key)
	end
	table.sort(indexList)

	-- Create a value table based on indices
	for key, value in pairs(bossData) do
		dataIndex[key] = value
	end

	local result

	for _, sortedIndex in pairs(indexList) do
		for _, quest in pairs(QuestHandler.QuestAssignments) do
			if sortedIndex == quest then
				if QuestHandler:FindValue(dataIndex[sortedIndex].Value.Task) == 1 then
					result = dataIndex[indexList[_ - 1]]
				else
					result = dataIndex[indexList[_]]
				end
			end

			-- Check task validity
		end
	end

	return result
end

QuestHandler.MyData = function()
	QuestHandler.BagNumber = {}

	for _, v in pairs(QuestHandler.QuestData) do
		if v.Used then
			QuestHandler.CountCheck += 1
		end
	end

	-- Reset condition
	if QuestHandler.CountCheck >= 2 then
		QuestHandler.CountCheck = 0
		QuestHandler.QuestData = {
			[1] = nil,
			[2] = nil,
		}
	end

	if not Double_Quest then
		QuestHandler.QuestData = {}
	end

	local questPool = {}

	for i, v in pairs(QuestHandler.GetAllQuests()) do
		for _, quest in pairs(v.Info) do
			if (i:sub(1, 11) == "MarineQuest" and #i == 11) or i == "BartiloQuest" or i == "CitizenQuest" then
				continue
			end
			questPool[quest.LevelReq] = {
				Index = i,
				Value = quest,
			}
		end
	end

	local selectedData = QuestHandler.CheckBossLevel(questPool)

	if Double_Quest then
		for i, quest in pairs(questPool) do
			for _, questReq in pairs(QuestHandler.QuestAssignments) do
				if questPool[i].Value.LevelReq == questReq then
					if QuestHandler:FindValue(quest.Value.Task) == 1 and Double_Quest then
						continue
					end
					table.insert(QuestHandler.BagNumber, questReq)
					if not QuestHandler.QuestData[questReq] then
						QuestHandler.QuestData[questReq] = {
							Index = quest.Index,
							Value = quest.Value,
							Used = false,
						}
					end
				end
			end
		end
	else
		for _, quest in pairs(questPool) do
			if quest.Value.LevelReq == selectedData.Value.LevelReq then
				table.insert(QuestHandler.BagNumber, selectedData.Value.LevelReq)
				if not QuestHandler.QuestData[selectedData.Value.LevelReq] then
					QuestHandler.QuestData[selectedData.Value.LevelReq] = {
						Index = quest.Index,
						Value = quest.Value,
						Used = false,
					}
				end
			end
		end
	end

	return QuestHandler.QuestData
end

function QuestHandler:FindValue(p1)
	if not p1 then 
		warn("havenil") 
		return 
	end
	for _, v in pairs(p1) do
		return v
	end
end

function QuestHandler:FindIndex(p1)
	if not p1 then 
		warn("havenil") 
		return 
	end
	for i, _ in pairs(p1) do
		return i
	end
end

function QuestHandler:FindData(questName, levelReq)
	for i, v in pairs(QuestHandler.AllQuests[questName]) do
		if v.LevelReq == levelReq then
			return {
				Value = v,
				Index = i,
			}
		end
	end
end

function QuestHandler:Npcs(levelReq, npcData)
	local positionMon
	for _, spawn in pairs(WorldOrigin.EnemySpawns:GetChildren()) do
		if spawn.Name == self:FindIndex(npcData) or spawn.Name:match(self:FindIndex(npcData)) then
			positionMon = spawn
		end
	end

	for i, npc in pairs(self.Guide.Data.NPCList) do
		for _, level in pairs(npc.Levels) do
			if level == levelReq then
				return {
					Index = i,
					Value = npc,
					MonPosition = positionMon or nil,
				}
			end
		end
	end
end

function QuestHandler:GetQuest()
	QuestHandler.DetermineLevelRequirements()
	local Data = {}

	local M_Data = self.MyData()

	local p1, p2

	if Double_Quest then
		p1 = math.max(unpack(QuestHandler.BagNumber))
	else
		p1 = QuestHandler.DetermineLevelRequirements()
	end

	table.sort(QuestHandler.BagNumber)

	for _, v in pairs(QuestHandler.BagNumber) do
		if v == p1 then continue end
		p2 = v
	end

	if not p2 then p2 = p1 end

	if Double_Quest then
		if not QuestHandler.QuestData[M_Data[p1].Value.LevelReq].Used then
			Data[M_Data[p1].Value.LevelReq] = {
				Mon = self:FindIndex(M_Data[p1].Value.Task),
				NameQuest = M_Data[p1].Index,
				NumberQuest = self:FindData(M_Data[p1].Index, M_Data[p1].Value.LevelReq).Index,
				CFrameQuest = self:Npcs(M_Data[p1].Value.LevelReq, M_Data[p1].Value.Task).Index.CFrame,
				CFrameMon = self:Npcs(M_Data[p1].Value.LevelReq, M_Data[p1].Value.Task).MonPosition,
			}
		else
			Data[M_Data[p2].Value.LevelReq] = {
				Mon = self:FindIndex(M_Data[p2].Value.Task),
				NameQuest = M_Data[p2].Index,
				NumberQuest = self:FindData(M_Data[p2].Index, M_Data[p2].Value.LevelReq).Index,
				CFrameQuest = self:Npcs(M_Data[p2].Value.LevelReq, M_Data[p2].Value.Task).Index.CFrame,
				CFrameMon = self:Npcs(M_Data[p2].Value.LevelReq, M_Data[p2].Value.Task).MonPosition,
			}
		end
	else
		local C = p2
		Data[M_Data[C].Value.LevelReq] = {
			Mon = self:FindIndex(M_Data[C].Value.Task),
			NameQuest = M_Data[C].Index,
			NumberQuest = self:FindData(M_Data[C].Index, M_Data[C].Value.LevelReq).Index,
			CFrameQuest = self:Npcs(M_Data[C].Value.LevelReq, M_Data[C].Value.Task).Index.CFrame,
			CFrameMon = self:Npcs(M_Data[C].Value.LevelReq, M_Data[C].Value.Task).MonPosition,
		}
	end

	return self:FindIndex(Data), Data
end

Double_Quest = true

return QuestHandler;
