extends CardEffect
class_name MovementEffect

@export var movement_amount : int = 1


func apply(target : TestCharacter) -> void:
	target.movement_remaining += movement_amount
