extends CharacterBody3D
class_name TestCharacter

signal clicked(character : TestCharacter)

@export var owner_player : PlayerOption.Type = PlayerOption.Type.PLAYER_ONE

@export var max_health : int = 100
@export var attack_damage : int = 25
@export var movement : int = 2
@export var attack_range : int = 1

@export var grid_position : Vector2i

var current_health : int
var movement_available : bool = true
var attack_available : bool = true
var ability_available : bool = true


func _ready() -> void:
	current_health = max_health
	input_event.connect(_on_input_event)


func set_grid_position(new_position: Vector2i, board: GameBoard) -> void:
	grid_position = new_position
	position = board.grid_to_world(grid_position)


func _on_input_event(
	_camera: Camera3D,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit(self)


func reset_actions() -> void:
	movement_available = true
	attack_available = true
	ability_available = true
