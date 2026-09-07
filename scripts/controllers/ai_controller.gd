extends PlayerController
class_name AIController


func start_turn() -> void:
	print("AI is taking its turn")
	
	await get_tree().create_timer(1.0).timeout
	
	var actions_taken : int = 0
	var max_actions : int = 20
	
	while is_my_turn() and actions_taken < max_actions:
		var played_card := _play_card()
		
		if not played_card:
			break
		
		actions_taken += 1
		
		await get_tree().create_timer(0.75).timeout
	
	if not is_my_turn():
		return
	
	await get_tree().create_timer(1.0).timeout
	
	if is_my_turn():
		game.end_current_turn()


# Helper to prevent bugs
func is_my_turn() -> bool:
	return TurnManager.current_player == player.player_type


func _play_card() -> bool:
	# First look for a deploy/cell-targeted card
	for card in player.hand:
		if card.target_type != CardData.TargetType.CELL:
			continue
		
		if card.energy_cost > player.energy:
			continue
		
		var deployment_cell := _find_valid_deployment_cell()
		
		if deployment_cell != Vector2i(-1, -1):
			if game.play_card_on_cell(card, deployment_cell):
				print("AI played ", card.card_name, " at ", deployment_cell)
				return true
	
	# Otherwise, play a simple no-target card
	for card in player.hand:
		if card.target_type != CardData.TargetType.NONE:
			continue
		
		if card.energy_cost > player.energy:
			continue
		
		game.play_card(card)
		print("AI played: ", card.card_name)
		return true
	
	return false


func _find_valid_deployment_cell() -> Vector2i:
	for x in range(game.board.board_width):
		for y in range(game.board.board_height):
			var grid_position := Vector2i(x, y)
			
			if game._is_valid_deployment_cell(grid_position):
				return grid_position
	
	return Vector2i(-1, -1)
