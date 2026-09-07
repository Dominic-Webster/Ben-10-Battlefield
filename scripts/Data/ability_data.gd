extends Resource
class_name AbilityData

enum AbilityType {
	DAMAGE,
	TELEPORT
}

@export var ability_name : String
@export var ability_type : AbilityType = AbilityType.DAMAGE
@export var desc : String
@export var energy_cost : int = 1
@export var ability_range : int
@export var damage : int
