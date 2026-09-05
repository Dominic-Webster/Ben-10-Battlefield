extends Node3D
class_name CameraRig

@onready var camera : Camera3D = $Camera3D

@export var pan_speed : float = 10.0
@export var zoom_speed: float = 0.5
@export var min_zoom: float = 6.0
@export var max_zoom: float = 14.0

@export var min_pan_x : float = -4.0
@export var max_pan_x : float = 4.0
@export var min_pan_z : float = -4.0
@export var max_pan_z : float = 4.0


func _process(delta: float) -> void:
	var direction := Vector3.ZERO
	
	if Input.is_action_pressed("camera_pan_left"):
		direction.x -= 1
	
	if Input.is_action_pressed("camera_pan_right"):
		direction.x += 1
	
	if Input.is_action_pressed("camera_pan_up"):
		direction.z -= 1
	
	if Input.is_action_pressed("camera_pan_down"):
		direction.z += 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		
		var camera_dir := global_transform.basis * direction
		camera_dir.y = 0.0
		camera_dir = camera_dir.normalized()
		
		position += camera_dir * pan_speed * delta
		position.x = clamp(position.x, min_pan_x, max_pan_x)
		position.z = clamp(position.z, min_pan_z, max_pan_z)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in"):
		camera.size = max(camera.size - zoom_speed, min_zoom)
	
	elif event.is_action_pressed("camera_zoom_out"):
		camera.size = min(camera.size + zoom_speed, max_zoom)
