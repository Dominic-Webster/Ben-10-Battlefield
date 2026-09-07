extends Node3D
class_name GameMap

@onready var board: GameBoard = $Board
@onready var player_one_base: Base = $PlayerOneBase
@onready var player_two_base: Base = $PlayerTwoBase


func _ready() -> void:
	register_bases()


func register_bases() -> void:
	board.register_base(
		player_one_base,
		[
			Vector2i(0, 3),
			Vector2i(0, 4)
		]
	)
	
	board.register_base(
		player_two_base,
		[
			Vector2i(7, 3),
			Vector2i(7, 4)
		]
	)
