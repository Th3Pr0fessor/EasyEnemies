--!strict

--// Services
local Players: Players = game:GetService('Players')
local CollectionService: CollectionService = game:GetService("CollectionService")
local TweenService: TweenService = game:GetService("TweenService")
local ServerStorage: ServerStorage = game:GetService("ServerStorage")

--// Modules
local Modules = script.Parent.Modules

local SETTINGS : any = require(script.Parent.Settings)
local Pathfinding : any = require(Modules.Pathfinding)

-- errors
local errors = {
	humanoid = 'Humanoid is nonexistent in %q',
	enemy_object = 'Enemy model does not exist',
	registered = '%q has already been registered'
}

local warnings = {
	no_tags = 'Attacking allies is not available for %q, add tag to enemy to make a team. If you wish to generate teams automatically set GENERATE_TEAMS to true in the "Settings" module',
}

--------------------------------------------
--// Predefines
local CF = CFrame.new
local V3 = Vector3.new

local Inst = Instance.new

local ceil = math.ceil
local floor = math.floor


--------------------------------------------


--// Functions
local function CHECK_TAGS(object: Instance)
	local TAGS : any = CollectionService:GetTags(object)

	if #TAGS == 0 then 
		if SETTINGS.DEBUG_MODE then
			if not SETTINGS.GENERATE_TEAMS then
				warn(string.format(warnings.no_tags, object.Name))
			end
		end
		if SETTINGS.GENERATE_TEAMS then
			CollectionService:AddTag(object, object.Name)
		end
	end

end

local function ADD_TARGET(attack_npcs: boolean, attack_ally: boolean, enemies: any, enemy: Instance, Tag: string)
	local Tags: any = CollectionService:GetTags(enemy)

	if #Tags > 0 
	then
		local found_ally: boolean = false
		for index = 1, #Tags 
		do
			if Tags[index] == Tag 
			then
				found_ally = true
				if attack_ally then
					table.insert(enemies, enemy)
				end
			end
		end


		if attack_ally and found_ally then
			table.insert(enemies, enemy)
		else
			if attack_npcs and not found_ally then
				table.insert(enemies, enemy)
			end
		end

	else
		if attack_npcs then
			table.insert(enemies, enemy)
		end
	end
end

local function CHECK_DUPLICATES(potential_enemies: any, object: Instance)
	local add_to_table : boolean = false

	for _, enemy in pairs(potential_enemies) 
	do
		if enemy == object 
		then 
			add_to_table = true
			break;
		end
	end

	return add_to_table
end

local function GET_DISTANCE(instance: Model, target: Model)
	return (instance.PrimaryPart.Position - target.PrimaryPart.Position).Magnitude
end

local function MAKE_ANIMATION(selection, default_animations)
	local animation : any = nil
	local id : any = default_animations[selection]
	
	if typeof(selection) == 'number' or typeof(selection) == 'string' then
		animation = Inst('Animation', workspace)
		animation.AnimationId = 'rbxassetid://'..id
	else
		animation = id
	end
	
	
	return animation
end


local function TWEEN(part, destination: Vector3)
	local tweenBase = TweenService:Create(part, TweenInfo.new(0.07), {Position = destination + V3(0, 0.5, 0)})
	tweenBase:Play()
	tweenBase.Completed:Wait()
end

local function TWEENMODEL(model, CF)
	local CFrameValue = Inst("CFrameValue")
	CFrameValue.Value = model:GetPrimaryPartCFrame()

	CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		model:SetPrimaryPartCFrame(CFrameValue.Value)
	end)

	local tween = TweenService:Create(CFrameValue, TweenInfo.new(0.07), {Value = CF})
	tween:Play()

	tween.Completed:Connect(function()
		CFrameValue:Destroy()
	end)
end

------------------------------------------------------------------------
-- Visuals
local Visuals = {
	ChaseVisual = function(Unit : any, Origin : any)
		if not SETTINGS.VISUALIZE then return end
		local Part = Inst('Part')
		Part.Anchored = true
		Part.CanCollide = false
		Part.Color = Color3.fromRGB(255, 0, 0)
		Part.Size = V3(.1, .1, (Unit - Origin).Magnitude)--V3(1,1,1)--
		Part.CFrame = CF(Origin, Unit) * CF(0, 0, -Part.Size.Z/2)
		Part.Parent = workspace
	end,
}




------------------------------------------------------------------------
local Functionality = {}
Functionality.__index = Functionality
Functionality.__type = "EnemyAIFunctionality"


--// Variables
Functionality.ActiveTags = {}

local ActiveTags = Functionality.ActiveTags



function Functionality:InitChecks()
	if not self.Instance then error(errors.enemy_object) end
	
	local hum: Humanoid? = self.Instance:FindFirstChild('Humanoid') 
	
	if not hum and not SETTINGS.GENERATE_ANIMATOR then
		error(string.format(errors.humanoid, self.Instance.Name))
	elseif SETTINGS.GENERATE_ANIMATOR and not hum then
		
		local AnimationController = Inst('AnimationController')
		AnimationController.Parent = self.Instance
		
		local Animator = Inst('Animator')
		Animator.Parent = AnimationController

		self.Humanoid = Animator
	else
		self.Humanoid = hum
	end
	
	
	CHECK_TAGS(self.Instance)
end

function Functionality:HumanoidCheck()
	if self.Humanoid:IsA"Humanoid" then return true end
	return false
end

function Functionality:Light_Attack()
	if self.Attacking then return end
	
	
	self.Attacking = true
	
	local Animator = self.Humanoid
	local default_animations = self.Settings.default_animations
	
	local selection : Instance | number = math.random(1, #default_animations)
	local animation = MAKE_ANIMATION(selection, default_animations)
	
	
	local _animation = Animator:LoadAnimation(animation)
	_animation.Priority = 4
	_animation:Play()

	_animation.Stopped:Connect(function()
		task.delay(.5, function()
			self.Attacking = false
		end)
	end)
	
	if self.Settings.default_functions[selection] ~= nil then
		self.Settings.default_functions[selection](self.Target)
	end
	
	_animation.Stopped:Wait()
	
	
end


function Functionality:FindNearestTarget()
	if self:Health_Check() then return end
	
	
	local attack_range = self.Settings.attack_range
	
	local Overlap : any = OverlapParams.new(); 
	Overlap.FilterDescendantsInstances = {self.Instance}; 
	Overlap.FilterType = Enum.RaycastFilterType.Blacklist; 
	
	local target_elements : any = workspace:GetPartBoundsInBox(self.Instance:FindFirstChild('HumanoidRootPart').CFrame, V3(attack_range, attack_range, attack_range), Overlap)
	local potential_enemies: any = {}
	local enemies : any = {}
	
	local closest : Model
	
	for _, instance in pairs(target_elements) 
	do
		if 
			instance.Parent:FindFirstChild('Humanoid') and
			instance.Parent.Humanoid.Health ~= 0 
		then
			
			local object: Instance = instance.Parent
			
			if not CHECK_DUPLICATES(potential_enemies, object) 
			then
				table.insert(potential_enemies, object)
			end
			
		end
	end
	
	
	for _, enemy in pairs(potential_enemies) 
	do
		local IS_PLAYER: Instance | boolean = Players:GetPlayerFromCharacter(enemy) or false
		
		if IS_PLAYER then
			
			if self.Settings.attack_players 
			then
				table.insert(enemies, enemy)
				continue;
			end
			
		else
			ADD_TARGET(self.Settings.attack_npcs, self.Settings.attack_ally, enemies, enemy, self.Tag)		
		end
	end
	
	for index, target in pairs(enemies) do
		if index == 1 then closest = target; continue end
		
		if GET_DISTANCE(self.Instance, target) < GET_DISTANCE(self.Instance, closest) then
			closest = target
		end
	end
	
	self.Target = closest
end


function Functionality:DisableStates()
	if not self:HumanoidCheck() then return end
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false) -- Disable
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false) -- Disable
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false) -- Disable
end


function Functionality:EnemySearch()
	if self:HumanoidCheck() then
		if self.Dead then return false; end
		if self:Health_Check() then return false; end
	end
	
	self:FindNearestTarget()

	if self.Target then
		
		print('test')

		local Origin : any = self.Instance.PrimaryPart.Position
		local Target : any = self.Target.PrimaryPart.Position
		local Unit = Origin + (Target - Origin).Unit * ((Target - Origin).Magnitude - self.Size.Z/2)

		Visuals.ChaseVisual(Unit, Origin)

		self.pathUnit = Unit

		self.path:Run(Unit)
		local s, e = pcall(function()
		end)
	end
	
	return true
end



function Functionality:Calibrate()
	
	if self:HumanoidCheck() then 
		self.Instance.Humanoid.Died:Connect(function()
			self.Dead = true
			self:Remove()
		end) 
	end
	
	
	self.Size = self.Instance:GetExtentsSize()
	self.Settings.attack_radius = ceil(self.Size.Z/2)
	
	self.path = Pathfinding.new(self.Instance)
	self.Visualize = true
	
	self.path.Reached:Connect(function()
		if floor(GET_DISTANCE(self.Instance, self.Target)) <= self.Settings.attack_radius then
			self:Light_Attack()
		end
	end)
	
	if not self:HumanoidCheck() then
		self.path.WaypointReached:Connect(function(model, lastWaypoint, nextWaypoint)
			TWEEN(model, CF(nextWaypoint.Position))
			self.path:Run()
		end)
	end
	
	while task.wait(.5) do
		if not self:EnemySearch() then
			break;
		end
	end
end


function Functionality:_Init()
	self:InitChecks()
	
	if not ActiveTags[self.Tag] 
	then
		ActiveTags[self.Tag] = {self}
	else
		table.insert(ActiveTags[self.Tag], self)
	end
	

	local tagConnection: RBXScriptConnection

	local function onTagRemoved(instance: Instance)
		if instance == self.Instance 
		then
			tagConnection:Disconnect()
			self:Destroy()
		end
	end
	
	self:DisableStates()
	self:Calibrate()
	tagConnection = CollectionService:GetInstanceRemovedSignal(self.Tag):Connect(onTagRemoved)
end


function Functionality:Health_Check()
	if not self:HumanoidCheck() then return false end
	if not self.Instance:FindFirstChild('Humanoid') then
		return true	
	else
		if self.Instance.Humanoid.Health < 1 then
			self:Remove()
		end
	end
	
	return false
end

function Functionality:Remove()
	--self.Instance:Destroy()
end

return Functionality
