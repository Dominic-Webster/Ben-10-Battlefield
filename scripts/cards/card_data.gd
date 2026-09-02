extends Resource
class_name CardData

enum TargetType {
	NONE,
	CHARACTER,
	CELL
}

@export var card_name : String
@export var desc : String
@export var energy_cost : int = 1
@export var target_type: TargetType = TargetType.NONE
@export var effects: Array[CardEffect] = []
