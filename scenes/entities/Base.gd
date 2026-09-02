extends Node3D
class_name Base

signal clicked(base: Base)

@export var owner_player : PlayerOption.Type = PlayerOption.Type.PLAYER_ONE

@export var max_health : int = 500

var current_health : int
var base_material: StandardMaterial3D
var mesh_instance: MeshInstance3D
var static_body: StaticBody3D
var highlight_material: StandardMaterial3D


func _ready() -> void:
	current_health = max_health
	
	# Store reference to mesh and set up material
	mesh_instance = $MeshInstance3D
	base_material = StandardMaterial3D.new()
	base_material.albedo_color = Color.GRAY
	
	if owner_player == PlayerOption.Type.PLAYER_TWO:
		base_material.albedo_color = Color.LIGHT_CORAL
	
	mesh_instance.set_surface_override_material(0, base_material)
	
	# Connect static body input events
	static_body = $StaticBody3D
	static_body.input_event.connect(_on_input_event)


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


func highlight_as_target() -> void:
	if highlight_material == null:
		highlight_material = base_material.duplicate()
		highlight_material.emission_enabled = true
		highlight_material.emission = Color(1.0, 0.3, 0.3)
		highlight_material.emission_energy_multiplier = 1.5
	mesh_instance.set_surface_override_material(0, highlight_material)


func unhighlight_target() -> void:
	mesh_instance.set_surface_override_material(0, base_material)


func take_damage(amount: int) -> void:
	current_health -= amount
