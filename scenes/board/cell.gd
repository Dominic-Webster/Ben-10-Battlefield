extends Node3D
class_name BoardCell

signal clicked(cell: BoardCell)

@export var grid_position: Vector2i

var occupied: bool = false
var character = null

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision_body: StaticBody3D = $StaticBody3D

var material: StandardMaterial3D


func _ready() -> void:
	material = StandardMaterial3D.new()
	material.albedo_color = Color(0.25, 0.25, 0.25)
	mesh.material_override = material
	
	collision_body.input_event.connect(_on_input_event)


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


func highlight_movement() -> void:
	mesh.material_override.albedo_color = Color(0.3, 0.5, 0.8)


func highlight_ability() -> void:
	mesh.material_override.albedo_color = Color(0.302, 0.675, 0.239, 1.0)


func highlight_attack() -> void:
	mesh.material_override.albedo_color = Color(0.8, 0.8, 0.3)


func highlight_enemy() -> void:
	mesh.material_override.albedo_color = Color(0.8, 0.3, 0.3)


func unhighlight() -> void:
	mesh.material_override.albedo_color = Color(0.25, 0.25, 0.25)
