extends Resource
class_name CardData

@export var card_name : String
@export var desc : String
@export var energy_cost : int = 1
@export var effects: Array[CardEffect] = []
