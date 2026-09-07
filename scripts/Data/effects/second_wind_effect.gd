extends CardEffect
class_name SecondWindEffect

enum ActionType {
	MOVEMENT,
	ATTACK,
	ABILITY
}

func apply(target : TestCharacter, action_type : ActionType) -> void:
	match action_type:
		ActionType.MOVEMENT:
			target.restore_movement()
		ActionType.ATTACK:
			target.restore_attack()
		ActionType.ABILITY:
			target.restore_ability()
