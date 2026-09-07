extends PlayerController
class_name AIController


func start_turn() -> void:
	print("AI is taking its turn")
	
	await get_tree().create_timer(1.0).timeout
	
	game.end_current_turn()
