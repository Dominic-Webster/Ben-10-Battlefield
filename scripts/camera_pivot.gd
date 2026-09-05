extends Node3D
class_name CameraPivot

@export var x_rotation_speed : float = 3.0
@export var y_rotation_speed : float = 40.0

@export var min_vertical_angle : float = -20.0
@export var max_vertical_angle : float = 20.0

@export var mouse_vertical_rotation_sensitivity : float = 5.0
@export var mouse_horizontal_rotation_sensitivity : float = 0.02
@export var max_mouse_horizontal_rotation_speed : float = 0.2
@export var max_mouse_vertical_rotation_speed : float = 1.0

var rotating_with_mouse : bool = false
var last_mouse_position := Vector2.ZERO
var mouse_rotation := Vector2.ZERO

var vertical_angle : float = 0.0


func _process(delta: float) -> void:
	var rotation_direction := 0.0
	
	if Input.is_action_pressed("camera_rotate_left"):
		rotation_direction -= 1.0
	
	if Input.is_action_pressed("camera_rotate_right"):
		rotation_direction += 1.0
	
	if rotation_direction != 0.0:
		rotation.y += rotation_direction * x_rotation_speed * delta
	
	if Input.is_action_pressed("camera_rotate_up"):
		vertical_angle -= y_rotation_speed * delta
	
	if Input.is_action_pressed("camera_rotate_down"):
		vertical_angle += y_rotation_speed * delta
	
	# Apply mouse rotation once per frame
	if rotating_with_mouse:
		var horizontal_rotation := (
			mouse_rotation.x
			* mouse_horizontal_rotation_sensitivity
		)
		
		var vertical_rotation := (
			mouse_rotation.y
			* mouse_vertical_rotation_sensitivity
		)
		
		horizontal_rotation = clamp(
			horizontal_rotation,
			-max_mouse_horizontal_rotation_speed,
			max_mouse_horizontal_rotation_speed
		)
		
		vertical_rotation = clamp(
			vertical_rotation,
			-max_mouse_vertical_rotation_speed,
			max_mouse_vertical_rotation_speed
		)
		
		rotation.y -= horizontal_rotation
		
		vertical_angle -= vertical_rotation
		
		mouse_rotation = Vector2.ZERO
	
	vertical_angle = clamp(
		vertical_angle,
		min_vertical_angle,
		max_vertical_angle
	)
	
	rotation.x = deg_to_rad(vertical_angle)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			rotating_with_mouse = event.pressed
			
			if rotating_with_mouse:
				last_mouse_position = event.position
	
	elif event is InputEventMouseMotion and rotating_with_mouse:
		var mouse_delta : Vector2 = (
			event.position - last_mouse_position
		)
		
		last_mouse_position = event.position
		
		mouse_rotation += mouse_delta
