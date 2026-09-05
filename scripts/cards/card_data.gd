extends Resource
class_name CardData

enum CardType {
	REUSABLE,
	ONE_TIME
}

enum TargetType {
	NONE,
	CHARACTER,
	CELL
}

@export var card_name : String
@export var desc : String
@export var energy_cost : int = 1
@export var card_type : CardType = CardType.REUSABLE
@export var target_type: TargetType = TargetType.NONE

@export var card_frame : Texture2D
@export var card_artwork : Texture2D

@export var effects: Array[CardEffect] = []
