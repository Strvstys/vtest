
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Shared = ReplicatedStorage.Shared

local ReplicatedInstancesUtils = require(Shared.ReplicatedInstancesUtils)
local SwordMounts = require(Shared.ReplicatedInstances.Swords.SwordMounts)

local SwordCollection = Shared.SwordAPI.Collection
local GetSword = Shared.ReplicatedInstances.Swords.GetSword

local CurrentSword, CurrentAnimator, CurrentTrack

local function EquipSword(Character, SwordName)
	local SwordData = GetSword:Invoke(SwordName)

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local Torso = Character:FindFirstChild("Torso")
	local LeftArm = Character:FindFirstChild("Left Arm")
	local RightArm = Character:FindFirstChild("Right Arm")

	if not Humanoid or not Torso or not LeftArm or not RightArm then return end

	local Sword = ReplicatedInstancesUtils.getInstance("Swords", SwordName):Clone()

	for _, Object in ipairs(Sword:GetDescendants()) do
		if Object:IsA("BasePart") then
			Object.Anchored = false
			Object.CanCollide = false
			Object.CanTouch = false
			Object.CanQuery = false
			Object.Massless = true
		end
	end

	if CurrentTrack then
		CurrentTrack:Stop()
		CurrentTrack:Destroy()
	end

	if CurrentSword then CurrentSword:Destroy() end

	Sword.Parent = Character

	local SwordType = Sword:GetAttribute("SwordType") or "Single"
	local Handler = SwordMounts.getHandler(SwordType)

	if Handler then
		Handler({
			Character = Character,
			Sword = Sword,
			SwordName = SwordName,
			SwordType = SwordType,
			Torso = Torso,
			LeftArm = LeftArm,
			RightArm = RightArm
		})
	end

	CurrentSword = Sword

	if not CurrentAnimator or CurrentAnimator.Parent ~= Humanoid then
		CurrentAnimator = Instance.new("Animator")
		CurrentAnimator.Parent = Humanoid
	end

	local AnimationFolder = SwordCollection:FindFirstChild(SwordData.AnimationType)
	local IdleAnimation = AnimationFolder and AnimationFolder:FindFirstChild("Idle")

	if IdleAnimation then
		CurrentTrack = CurrentAnimator:LoadAnimation(IdleAnimation)
		CurrentTrack.Looped = true
		CurrentTrack.Priority = Enum.AnimationPriority.Idle
		CurrentTrack:Play()
	end
end

warn('idle')

getgenv().EquipClientSword = function(SwordName)
	if Player.Character then
		EquipSword(Player.Character, SwordName)
	end
end

if Player.Character then
	EquipSword(Player.Character, "Prince Blade")
end

for _, Connection in getconnections(ReplicatedStorage.FireSwordInfo.OnClientEvent) do
    Connection:Disable()
end
