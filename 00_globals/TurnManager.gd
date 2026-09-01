# Turn Manager
extends Node

signal turn_started(player : PlayerOption.Type)
signal turn_ended(player : PlayerOption.Type)

var current_player : PlayerOption.Type = PlayerOption.Type.PLAYER_ONE
var turn_number : int = 1


func start_turn() -> void:
	turn_started.emit(current_player)
	
	if current_player == PlayerOption.Type.PLAYER_ONE:
		print("Player 1 Turn")
	else:
		print("Player 2 Turn")


func end_turn() -> void:
	turn_ended.emit(current_player)

	current_player = PlayerOption.Type.PLAYER_TWO if current_player == PlayerOption.Type.PLAYER_ONE else PlayerOption.Type.PLAYER_ONE
	
	if current_player == PlayerOption.Type.PLAYER_ONE:
		turn_number += 1
	
	start_turn()
