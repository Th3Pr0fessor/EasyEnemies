--!nocheck
--strict

--	EasyEnemies 2021
--	@author The_Pr0fessor
--[[
	@credit:
	- @V3N0M_Z
]] 


type ATTACK_NPCS = {attack_npcs: boolean}
type ATTACK_ALLY = {attack_ally: boolean}
type ATTACK_RANGE = {attack_range: number}
type ATTACK_PLAYERS = {attack_players: boolean}

type HEALTH = {health: number}
type DAMAGE = {damage: number}
type WANDER = {wander: boolean}

type DEFAULT_ATTACK_AIMATIONS  = {[any]: any}
type DEFAULT_ATTACK_FUNCTIONS  = {[any]: any}
type SPECIAL_ATTACK_AIMATIONS  = {[any]: any}
type SPECIAL_ATTACK_FUNCTIONS  = {[any]: any}

type e_settings = HEALTH & DAMAGE & WANDER  & ATTACK_RANGE & ATTACK_NPCS & ATTACK_PLAYERS &  DEFAULT_ATTACK_AIMATIONS & DEFAULT_ATTACK_FUNCTIONS & SPECIAL_ATTACK_AIMATIONS & SPECIAL_ATTACK_FUNCTIONS

local settings_test: e_settings = {
	health = 1,
	damage = 1,
	wander = false,
	
	attack_range = 20,
	attack_radius = 5,
	
	attack_ally = false,
	attack_npcs = false,
	attack_players = true,
	
	default_animations = {},
	default_functions = {},
	
	special_animations = {},
	special_functions = {},
}        -- ok



local default_settings: e_settings = {
	health = 100,
	damage = 5,
	wander = false,

	attack_range = 20,
	attack_radius = 5,
	
	attack_ally = false,
	attack_npcs = false,
	attack_players = true,

	default_animations = {},
	default_functions = {},

	special_animations = {},
	special_functions = {},
}   

local settings_list = {
	'health',
	'damage',
	'wander',

	'attack_range',
	'attack_radius',
	
	'attack_ally',
	'attack_npcs',
	'attack_players',

	'default_animations',
	'special_animations',   
}

--// Services
local CollectionService: CollectionService = game:GetService("CollectionService")

--// Modules
local EnemyFunctionality : ModuleScript = require(script.Functionality)
local SETTINGS : ModuleScript = require(script.Settings)

-- Allow EnemyModule to write to the output
local SHOW_OUTPUT_MESSAGES: boolean = true

-- The tag name. Used for cleanup.
local DEFAULT_COLLECTION_TAG_NAME: string = "_EnemyAI"


-- errors
local errors = {
	object_type = '1st parameter needs to be a model or CollectionService Tag'
}


local Enemy = {}
Enemy.__index = Enemy
Enemy.__type = "EnemyAI"

-- Module Settings
Enemy.MODULE_NAME = script.Parent.Name
Enemy.GENERATE_TEAMS = false;


function SettingsCheck(current_settings : e_settings)
	for i, setting: string in pairs(settings_list) do
		if current_settings[setting] == nil then
			warn(string.format('Check your enemy settings, %q is nil, setting to default value: %i', setting, default_settings[setting]))
			current_settings[setting] = default_settings[setting]
		end
	end
end


function RegisterEnemy(instance: Instance, object_tag: string, _settings : e_settings)
	
	task.spawn(function()
		local EnemyAI: any?
		
		EnemyAI = setmetatable({
			Instance = instance,
			Settings = _settings,
			Dead = false,
			Tag = object_tag,
		}, EnemyFunctionality)
		
	
	
		EnemyAI:_Init()
	end)
end

---------------------------------------------------------------------------------------------------------


function Enemy.new(object: string | Instance, _settings : e_settings)
	SettingsCheck(_settings)
	
	local object_type: string = typeof(object)
	assert(object_type == 'string' or object_type == 'Instance', errors.object_type)

	
	if object_type == 'string' then
		for 
			_, instance: Instance in 
			pairs(CollectionService:GetTagged(object)) 
		do
			RegisterEnemy(instance, object, _settings)
		end

		workspace.ChildAdded:Connect(function(instance)
			if CollectionService:HasTag(instance, object) then
				RegisterEnemy(instance, object, _settings)
			end
		end)
		
	else
		RegisterEnemy(object, object.Name, _settings)
		
		if SETTINGS.GENERATE_TEAMS then
			workspace.ChildAdded:Connect(function(instance)
				if CollectionService:HasTag(instance, object.Name) then
					RegisterEnemy(instance, object.Name, _settings)
				end
			end)
		end
	end
	
end


function Enemy.GetInstances(tag)
	return EnemyFunctionality.ActiveTags[tag]
end


---------------------------------------------------------------------------------------------------------

return Enemy
