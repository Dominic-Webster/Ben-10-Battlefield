extends Node
class_name PlayerController

var player : Player
var game : Node


func setup(new_player : Player, new_game : Node) -> void:
	player = new_player
	game = new_game


func start_turn() -> void:
	pass
