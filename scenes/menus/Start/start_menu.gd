# Start Menu
extends Control

@onready var play_button : Button = $Buttons/Play
@onready var exit_button : Button = $Buttons/Exit


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)


func _on_play_pressed() -> void:
		get_tree().change_scene_to_file("res://scenes/menus/Main/main_menu.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
