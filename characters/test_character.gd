extends CharacterBody3D
class_name TestCharacter

signal clicked(character : TestCharacter)

@export var owner_player : PlayerOption.Type = PlayerOption.Type.PLAYER_ONE

@export var max_health : int = 100
@export var attack_damage : int = 25
@export var movement : int = 3
@export var attack_range : int = 1
@export var ability : AbilityData

@export var grid_position : Vector2i

var current_health : int
var movement_available : bool = true
var attack_available : bool = true
var ability_available : bool = true

var base_material: StandardMaterial3D
var mesh_instance: MeshInstance3D


func _ready() -> void:
	current_health = max_health
	input_event.connect(_on_input_event)
	
	mesh_instance = $MeshInstance3D
	base_material = StandardMaterial3D.new()
	base_material.albedo_color = Color.WHITE
	
	if owner_player == PlayerOption.Type.PLAYER_TWO:
		base_material.albedo_color = Color.LIGHT_CORAL
	
	mesh_instance.set_surface_override_material(0, base_material)


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


func highlight_as_target() -> void:
	var highlight_material = base_material.duplicate()
	highlight_material.emission_enabled = true
	highlight_material.emission = Color(1.0, 0.3, 0.3)
	highlight_material.emission_energy_multiplier = 1.5
	mesh_instance.set_surface_override_material(0, highlight_material)


func unhighlight_target() -> void:
	mesh_instance.set_surface_override_material(0, base_material)


func take_damage(amount : int) -> void:
	current_health -= amount
